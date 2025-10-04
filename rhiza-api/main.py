import os
import json
import uuid
import re
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Response, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List
import google.generativeai as genai
import boto3
from botocore.exceptions import ClientError, NoCredentialsError
import structlog
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from services.neo4j_service import EtymologyGraphService

# Load environment variables from .env file
load_dotenv()

# Configure structured logging
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger(__name__)

# --- Configuration ---
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
AWS_REGION = os.environ.get("AWS_DEFAULT_REGION", "us-east-1")
AWS_BEARER_TOKEN = os.environ.get("AWS_BEARER_TOKEN_BEDROCK")

# Configure Gemini if API key is available
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    logger.info("Gemini API configured")

# Initialize Bedrock client with bearer token
try:
    if AWS_BEARER_TOKEN:
        bedrock_client = boto3.client(
            'bedrock-runtime', 
            region_name=AWS_REGION,
            aws_access_key_id=None,
            aws_secret_access_key=None,
            aws_session_token=AWS_BEARER_TOKEN
        )
        logger.info(f"Bedrock client initialized with bearer token for region {AWS_REGION}")
    else:
        bedrock_client = None
        logger.warning("AWS_BEARER_TOKEN_BEDROCK not provided, Bedrock unavailable")
except Exception as e:
    logger.warning(f"Failed to initialize Bedrock client: {e}")
    bedrock_client = None

app = FastAPI(
    title="Project Logos API",
    description="API for exploring the Greek roots of English words.",
    version="1.0.0",
)

# Configure rate limiter
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Add request ID middleware
@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request_id = str(uuid.uuid4())[:8]
    request.state.request_id = request_id
    
    # Add request ID to structured logging context
    structlog.contextvars.clear_contextvars()
    structlog.contextvars.bind_contextvars(request_id=request_id)
    
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    return response

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Neo4j service
graph_service = EtymologyGraphService()

@app.on_event("shutdown")
def shutdown_event():
    graph_service.close()

# --- Pydantic Models for Data Validation ---

class GreekRoot(BaseModel):
    name: str = Field(..., description="The root in Ancient Greek script.")
    transliteration: str = Field(..., description="The common English transliteration.")
    meaning: str = Field(..., description="A concise English meaning.")

class WordResponse(BaseModel):
    name: str = Field(..., description="The original English word provided.")
    roots: List[GreekRoot] = Field(..., description="An array of root objects.")


# --- System Prompt for the AI Model ---
# This is the detailed prompt we crafted earlier.
SYSTEM_PROMPT = """
You are an expert linguist and etymologist with a specialization in Ancient Greek and its influence on the English language. Your sole function is to analyze an English word and provide its Greek root components in a structured JSON format.

**Your Task:**
Given an English word, identify its primary Ancient Greek root(s). For each root, you must provide the original Greek term, its common English transliteration, and its concise meaning.

**Output Rules:**
1.  Your response MUST be a single, valid JSON object.
2.  Do NOT include any explanatory text, apologies, or markdown formatting like ```json before or after the JSON object.
3.  The JSON object must conform to the following structure:
    - `name`: The original English word provided.
    - `roots`: An array of root objects.
        - Each root object must contain three string keys: `name` (the root in Ancient Greek script), `transliteration` (the common English transliteration), and `meaning` (a concise English meaning).
4.  If the word is not of Greek origin, the `roots` array MUST be empty (`[]`).
5.  If the word has multiple Greek roots, include an object for each root in the `roots` array.

**Examples:**
... (Examples from previous prompt omitted for brevity) ...

---
Now, analyze the following word:
"""

# --- Helper Functions ---

def is_valid_english_word(word: str) -> bool:
    """Basic validation for English words."""
    if not word or len(word) < 2 or len(word) > 45:
        return False
    
    # Only allow letters, hyphens, and apostrophes
    if not re.match(r"^[a-zA-Z'-]+$", word):
        return False
    
    # Reject obvious non-English patterns
    if re.search(r'[qxz]{2,}|[bcdfghjklmnpqrstvwxyz]{5,}', word.lower()):
        return False
    
    return True

# --- AI Helper Functions ---

async def call_bedrock_ai(word: str) -> dict:
    """Call AWS Bedrock Claude model for etymology analysis."""
    if not bedrock_client:
        raise Exception("Bedrock client not available")
    
    try:
        full_prompt = f"{SYSTEM_PROMPT}\n{word}"
        
        logger.info("Calling Bedrock API", word=word, model="claude-sonnet-4")
        
        response = bedrock_client.invoke_model(
            modelId='us.anthropic.claude-sonnet-4-20250514-v1:0',
            body=json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 1000,
                "messages": [{"role": "user", "content": full_prompt}]
            })
        )
        
        response_body = json.loads(response['body'].read())
        content = response_body['content'][0]['text']
        
        # Parse the JSON response
        result = json.loads(content)
        
        logger.info("Bedrock API success", 
                   word=word, 
                   roots_found=len(result.get('roots', [])),
                   response_length=len(content))
        return result
        
    except (ClientError, NoCredentialsError, json.JSONDecodeError) as e:
        logger.error("Bedrock API error", word=word, error=str(e), error_type=type(e).__name__)
        raise Exception(f"Bedrock API error: {e}")

async def call_gemini_ai(word: str) -> dict:
    """Call Google Gemini model for etymology analysis."""
    if not GEMINI_API_KEY:
        raise Exception("Gemini API key not available")
    
    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        full_prompt = f"{SYSTEM_PROMPT}\n{word}"
        
        logger.info("Calling Gemini API", word=word, model="gemini-1.5-flash")
        
        response = model.generate_content(full_prompt)
        
        # Parse the JSON response
        result = json.loads(response.text)
        
        logger.info("Gemini API success", 
                   word=word, 
                   roots_found=len(result.get('roots', [])),
                   response_length=len(response.text))
        return result
        
    except (json.JSONDecodeError, Exception) as e:
        logger.error("Gemini API error", word=word, error=str(e), error_type=type(e).__name__)
        raise Exception(f"Gemini API error: {e}")

async def get_ai_etymology(word: str) -> dict:
    """Get etymology from AI with Bedrock first, Gemini fallback."""
    logger.info("Starting AI etymology analysis", word=word)
    
    # Try Bedrock first
    if bedrock_client:
        try:
            result = await call_bedrock_ai(word)
            logger.info("AI etymology completed", word=word, provider="bedrock")
            return result
        except Exception as e:
            logger.warning("Bedrock failed, trying Gemini", word=word, error=str(e))
    
    # Fallback to Gemini
    if GEMINI_API_KEY:
        try:
            result = await call_gemini_ai(word)
            logger.info("AI etymology completed", word=word, provider="gemini")
            return result
        except Exception as e:
            logger.error("All AI providers failed", word=word, error=str(e))
            raise HTTPException(status_code=503, detail="AI services unavailable")
    
    # No AI providers available - return empty result instead of error
    logger.warning("No AI providers configured, returning empty result", word=word)
    return {"name": word, "roots": []}

# --- API Endpoint ---

@app.get("/word/{english_word}", response_model=WordResponse)
@limiter.limit("30/minute")  # 30 requests per minute per IP
async def get_word_roots(request: Request, english_word: str, response: Response):
    """
    Analyzes an English word to find its Ancient Greek roots.
    Checks graph database first, falls back to AI if not found.
    """
    response.headers["Content-Type"] = "application/json; charset=utf-8"
    
    logger.info("Etymology request started", word=english_word)
    
    # Validate input as English word
    if not is_valid_english_word(english_word):
        logger.warning("Invalid word format", word=english_word)
        if not english_word.strip():
            raise HTTPException(status_code=400, detail="Please enter a word to search")
        elif len(english_word) < 2:
            raise HTTPException(status_code=400, detail="Word must be at least 2 characters long")
        elif len(english_word) > 45:
            raise HTTPException(status_code=400, detail="Word is too long (maximum 45 characters)")
        elif not re.match(r"^[a-zA-Z'-]+$", english_word):
            raise HTTPException(status_code=400, detail="Please use only letters, hyphens, and apostrophes")
        else:
            raise HTTPException(status_code=400, detail="Please enter a valid English word")
    
    try:
        # First, check if we have this word in our graph
        cached_result = graph_service.find_word_roots(english_word)
        if cached_result:
            logger.info("Found cached result", word=english_word, source="graph_db")
            # Cache for 1 hour since data is stable
            response.headers["Cache-Control"] = "public, max-age=3600"
            response.headers["ETag"] = f'"{hash(str(cached_result))}"'
            return cached_result
        
        # If not in graph, use AI to analyze the word
        logger.info("No cached result, using AI", word=english_word)
        result = await get_ai_etymology(english_word)
        
        # Store the result in graph for future queries (even if no roots found)
        graph_service.store_etymology(english_word, result["roots"])
        if result.get("roots"):
            logger.info("Stored etymology in graph", word=english_word, roots_count=len(result["roots"]))
        else:
            logger.info("Stored word with no roots in graph", word=english_word)
        
        # Cache new results for 1 hour
        response.headers["Cache-Control"] = "public, max-age=3600"
        response.headers["ETag"] = f'"{hash(str(result))}"'
        
        logger.info("Etymology request completed", word=english_word, roots_found=len(result.get("roots", [])))
        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error in etymology request", word=english_word, error=str(e), error_type=type(e).__name__)
        if "DNS resolve" in str(e) or "connection" in str(e).lower():
            raise HTTPException(status_code=503, detail="Database temporarily unavailable. Please try again later.")
        elif "timeout" in str(e).lower():
            raise HTTPException(status_code=504, detail="Request timed out. Please try again with a shorter word.")
        else:
            raise HTTPException(status_code=500, detail="An unexpected error occurred. Please try again.")

@app.get("/root/{root_name}/words")
async def get_words_from_root(root_name: str):
    """
    Find all words that derive from a specific Greek root.
    """
    try:
        words = graph_service.get_related_words(root_name)
        return {"root": root_name, "words": words}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/word/{english_word}/graph")
@limiter.limit("60/minute")  # 60 requests per minute per IP (lighter endpoint)
async def get_word_graph(request: Request, english_word: str, response: Response):
    """
    Get graph visualization data for a word and its roots.
    """
    try:
        with graph_service.driver.session() as session:
            result = session.run("""
                MATCH (w:EnglishWord {name: $word})-[:DERIVES_FROM]->(r:GreekRoot)
                RETURN {
                    nodes: collect(DISTINCT {id: w.name, label: w.name, type: 'word'}) + 
                           collect(DISTINCT {id: r.transliteration, label: r.name + ' (' + r.meaning + ')', type: 'root'}),
                    links: collect({source: w.name, target: r.transliteration, type: 'derives_from'})
                } as graph
            """, word=english_word.lower())
            
            record = result.single()
            if record and record["graph"]["nodes"]:
                graph_data = record["graph"]
                # Cache graph data for 1 hour
                response.headers["Cache-Control"] = "public, max-age=3600"
                response.headers["ETag"] = f'"{hash(str(graph_data))}"'
                return graph_data
            else:
                empty_result = {"nodes": [], "links": []}
                # Cache empty results for shorter time (15 minutes)
                response.headers["Cache-Control"] = "public, max-age=900"
                return empty_result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))