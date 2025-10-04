"""
Rhiza API - Greek Etymology Explorer

A FastAPI application for analyzing English words to discover their Ancient Greek roots
using AI-powered analysis and graph database storage.
"""

import os
import json
import uuid
import re
import asyncio
from typing import List, Dict, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Response, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import google.generativeai as genai
import boto3
from botocore.exceptions import ClientError, NoCredentialsError
import structlog
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from services.neo4j_service import EtymologyGraphService

# Load environment variables
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

# CORS configuration
ALLOWED_ORIGINS = os.environ.get("ALLOWED_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000").split(",")

# Handle wildcard for development
if ALLOWED_ORIGINS == ["*"]:
    ALLOWED_ORIGINS = ["*"]

# --- Pydantic Models ---

class GreekRoot(BaseModel):
    name: str = Field(..., description="The root in Ancient Greek script.")
    transliteration: str = Field(..., description="The common English transliteration.")
    meaning: str = Field(..., description="A concise English meaning.")
    category: Optional[str] = Field(None, description="Semantic category of the root.")
    frequency: Optional[str] = Field(None, description="Usage frequency in English.")
    part_of_speech: Optional[str] = Field(None, description="Grammatical category.")

class EnglishWordNode(BaseModel):
    name: str = Field(..., description="The English word.")
    definition: Optional[str] = Field(None, description="Word definition.")
    first_use_year: Optional[int] = Field(None, description="First recorded use year.")
    field: Optional[str] = Field(None, description="Academic or professional field.")
    complexity_level: Optional[str] = Field(None, description="Word complexity level.")

class Relationship(BaseModel):
    type: str = Field(..., description="Relationship type.")
    strength: Optional[float] = Field(None, description="Relationship strength (0-1).")
    position: Optional[str] = Field(None, description="Position in word (prefix/suffix).")

class GraphNode(BaseModel):
    id: str = Field(..., description="Unique node identifier.")
    label: str = Field(..., description="Node display label.")
    type: str = Field(..., description="Node type (EnglishWord, GreekRoot, etc.).")
    properties: Dict[str, Any] = Field(default_factory=dict, description="Node properties.")

class GraphEdge(BaseModel):
    source: str = Field(..., description="Source node ID.")
    target: str = Field(..., description="Target node ID.")
    type: str = Field(..., description="Relationship type.")
    properties: Dict[str, Any] = Field(default_factory=dict, description="Edge properties.")

class GraphResponse(BaseModel):
    nodes: List[GraphNode] = Field(..., description="Graph nodes.")
    edges: List[GraphEdge] = Field(..., description="Graph edges.")

class WordResponse(BaseModel):
    name: str = Field(..., description="The original English word provided.")
    roots: List[GreekRoot] = Field(..., description="An array of root objects.")
    word_info: Optional[EnglishWordNode] = Field(None, description="Additional word information.")

# --- AI Configuration ---

# Configure Gemini if API key is available
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    logger.info("Gemini API configured")

# Initialize Bedrock client with bearer token
bedrock_client = None
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
        logger.warning("AWS_BEARER_TOKEN_BEDROCK not provided, Bedrock unavailable")
except Exception as e:
    logger.warning(f"Failed to initialize Bedrock client: {e}")

# --- FastAPI App Configuration ---

app = FastAPI(
    title="Project Logos API",
    description="API for exploring the Greek roots of English words with build caching.",
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
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
)

# Initialize Neo4j service
graph_service = EtymologyGraphService()

# --- System Prompt ---

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

---
Now, analyze the following word:
"""

# --- Utility Functions ---

def is_valid_english_word(word: str) -> bool:
    """Enhanced validation for English words with security checks."""
    if not word or not isinstance(word, str):
        return False
    
    # Strip whitespace and convert to lowercase for validation
    word = word.strip().lower()
    
    # Length constraints
    if len(word) < 1 or len(word) > 50:
        return False
    
    # Only allow letters, hyphens, apostrophes, and spaces
    if not re.match(r"^[a-zA-Z\s'-]+$", word):
        return False
    
    # Prevent SQL injection patterns
    sql_patterns = [
        r"(union|select|insert|update|delete|drop|create|alter|exec|execute)",
        r"(script|javascript|vbscript|onload|onerror)",
        r"(<|>|&lt;|&gt;|%3c|%3e)",
        r"(--|#|/\*|\*/)"
    ]
    
    for pattern in sql_patterns:
        if re.search(pattern, word, re.IGNORECASE):
            return False
    
    # Reject obvious non-English patterns
    if re.search(r'[qxz]{3,}|[bcdfghjklmnpqrstvwxyz]{6,}', word):
        return False
    
    # Reject repeated characters (potential DoS)
    if re.search(r'(.)\1{10,}', word):
        return False
    
    # Reject common attack strings
    attack_strings = ['null', 'undefined', 'eval', 'function', 'constructor']
    if word.lower() in attack_strings:
        return False
    
    return True

def sanitize_input(text: str) -> str:
    """Sanitize input text to prevent XSS and injection attacks."""
    if not text or not isinstance(text, str):
        return ""
    
    # Remove null bytes and control characters
    text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', text)
    
    # HTML entity encoding for dangerous characters
    text = text.replace('&', '&amp;')
    text = text.replace('<', '&lt;')
    text = text.replace('>', '&gt;')
    text = text.replace('"', '&quot;')
    text = text.replace("'", '&#x27;')
    
    # Limit length to prevent DoS
    return text[:100].strip()

# --- AI Service Functions ---

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

# --- Event Handlers ---

@app.on_event("startup")
async def startup_event():
    # ASCII art Rho logo
    rho_logo = """
    ██████╗ ██╗  ██╗██╗███████╗ █████╗ 
    ██╔══██╗██║  ██║██║╚══███╔╝██╔══██╗
    ██████╔╝███████║██║  ███╔╝ ███████║
    ██╔══██╗██╔══██║██║ ███╔╝  ██╔══██║
    ██║  ██║██║  ██║██║███████╗██║  ██║
    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝
    
    🏛️  Greek Etymology API v1.0.0
    🔗 Neo4j Database | 🤖 AI-Powered Analysis
    ⚡ Async Operations | 📊 Structured Logging
    """
    print(rho_logo, flush=True)
    
    logger.info("🚀 Initializing Rhiza API services...")
    
    # Database connection with enhanced logging
    max_retries = 10
    retry_delay = 2
    
    logger.info("🔌 Connecting to Neo4j database...")
    for attempt in range(max_retries):
        try:
            await graph_service.create_indexes()
            logger.info("✅ Database connected and indexes created successfully")
            break
        except Exception as e:
            if attempt < max_retries - 1:
                logger.warning(f"⚠️  Database connection failed (attempt {attempt + 1}/{max_retries}), retrying in {retry_delay}s", error=str(e))
                await asyncio.sleep(retry_delay)
            else:
                logger.error("❌ Failed to connect to database after all retries", error=str(e))
                raise
    
    # AI providers status
    ai_status = []
    if bedrock_client:
        ai_status.append("🧠 AWS Bedrock (Claude Sonnet 4)")
    if GEMINI_API_KEY:
        ai_status.append("🔮 Google Gemini")
    
    if ai_status:
        logger.info(f"🤖 AI providers ready: {', '.join(ai_status)}")
    else:
        logger.warning("⚠️  No AI providers configured")
    
    logger.info("🎯 Rhiza API ready to explore Greek etymology!")

@app.on_event("shutdown")
async def shutdown_event():
    await graph_service.close()

# --- API Endpoints ---

@app.get("/health")
async def health_check():
    """Basic health check endpoint"""
    return {"status": "healthy"}

@app.get("/ready")
async def readiness_check():
    """Readiness check - verifies dependencies are available"""
    try:
        # Test Neo4j connection
        async with graph_service.driver.session() as session:
            await session.run("RETURN 1")
        
        # Test AI providers (non-blocking)
        ai_status = {
            "bedrock": bedrock_client is not None,
            "gemini": GEMINI_API_KEY is not None
        }
        
        return {
            "status": "ready",
            "dependencies": {
                "neo4j": "healthy",
                "ai_providers": ai_status
            }
        }
    except Exception as e:
        logger.error("Readiness check failed", error=str(e))
        raise HTTPException(status_code=503, detail="Service not ready")

@app.get("/word/{english_word}", response_model=WordResponse)
@limiter.limit("30/minute")  # 30 requests per minute per IP
async def get_word_roots(request: Request, english_word: str, response: Response):
    """
    Analyzes an English word to find its Ancient Greek roots.
    Checks graph database first, falls back to AI if not found.
    """
    response.headers["Content-Type"] = "application/json; charset=utf-8"
    
    # Sanitize input first
    english_word = sanitize_input(english_word)
    
    logger.info("Etymology request started", word=english_word)
    
    # Enhanced input validation
    if not is_valid_english_word(english_word):
        logger.warning("Invalid word format", word=english_word, ip=get_remote_address(request))
        if not english_word.strip():
            raise HTTPException(status_code=400, detail="Please enter a word to search")
        elif len(english_word) < 1:
            raise HTTPException(status_code=400, detail="Word cannot be empty")
        elif len(english_word) > 50:
            raise HTTPException(status_code=400, detail="Word is too long (maximum 50 characters)")
        elif not re.match(r"^[a-zA-Z\s'-]+$", english_word):
            raise HTTPException(status_code=400, detail="Please use only letters, spaces, hyphens, and apostrophes")
        else:
            raise HTTPException(status_code=400, detail="Invalid input detected. Please enter a valid English word")
    
    # Normalize word for processing
    normalized_word = english_word.strip().lower()
    
    try:
        # First, check if we have this word in our graph
        cached_result = await graph_service.find_word_roots(normalized_word)
        if cached_result:
            logger.info("Found cached result", word=normalized_word, source="graph_db")
            # Cache for 1 hour since data is stable
            response.headers["Cache-Control"] = "public, max-age=3600"
            response.headers["ETag"] = f'"{hash(str(cached_result))}"'
            return cached_result
        
        # If not in graph, use AI to analyze the word
        logger.info("No cached result, using AI", word=normalized_word)
        result = await get_ai_etymology(normalized_word)
        
        # Store the result in graph for future queries (even if no roots found)
        await graph_service.store_etymology(normalized_word, result["roots"])
        if result.get("roots"):
            logger.info("Stored etymology in graph", word=normalized_word, roots_count=len(result["roots"]))
        else:
            logger.info("Stored word with no roots in graph", word=normalized_word)
        
        # Cache new results for 1 hour
        response.headers["Cache-Control"] = "public, max-age=3600"
        response.headers["ETag"] = f'"{hash(str(result))}"'
        
        logger.info("Etymology request completed", word=normalized_word, roots_found=len(result.get("roots", [])))
        return result

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Unexpected error in etymology request", word=normalized_word, error=str(e), error_type=type(e).__name__)
        if "DNS resolve" in str(e) or "connection" in str(e).lower():
            raise HTTPException(status_code=503, detail="Database temporarily unavailable. Please try again later.")
        elif "timeout" in str(e).lower():
            raise HTTPException(status_code=504, detail="Request timed out. Please try again with a shorter word.")
        else:
            raise HTTPException(status_code=500, detail="An unexpected error occurred. Please try again.")

@app.get("/word/{english_word}/graph")
@limiter.limit("60/minute")  # 60 requests per minute per IP (lighter endpoint)
async def get_word_graph(request: Request, english_word: str, response: Response):
    """
    Get graph visualization data for a word and its roots.
    """
    # Sanitize and validate input
    english_word = sanitize_input(english_word)
    
    if not is_valid_english_word(english_word):
        logger.warning("Invalid word format in graph request", word=english_word, ip=get_remote_address(request))
        raise HTTPException(status_code=400, detail="Invalid input detected. Please enter a valid English word")
    
    normalized_word = english_word.strip().lower()
    
    try:
        async with graph_service.driver.session() as session:
            result = await session.run("""
                MATCH (w:EnglishWord {name: $word})-[:DERIVES_FROM]->(r:GreekRoot)
                RETURN {
                    nodes: collect(DISTINCT {id: w.name, label: w.name, type: 'word'}) + 
                           collect(DISTINCT {id: r.transliteration, label: r.name + ' (' + r.meaning + ')', type: 'root'}),
                    links: collect({source: w.name, target: r.transliteration, type: 'derives_from'})
                } as graph
            """, word=normalized_word)
            
            record = await result.single()
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
        logger.error("Error in graph request", word=normalized_word, error=str(e))
        raise HTTPException(status_code=500, detail="Unable to generate graph data")

@app.get("/root/{root_name}/words")
async def get_words_from_root(root_name: str):
    """
    Find all words that derive from a specific Greek root.
    """
    # Sanitize and validate input
    root_name = sanitize_input(root_name)
    
    if not root_name or len(root_name) > 100:
        raise HTTPException(status_code=400, detail="Invalid root name")
    
    # Allow Greek characters, Latin characters, and common transliteration symbols
    if not re.match(r"^[\u0370-\u03FF\u1F00-\u1FFFa-zA-Z\s'-]+$", root_name):
        raise HTTPException(status_code=400, detail="Invalid characters in root name")
    
    try:
        words = await graph_service.get_related_words(root_name.strip())
        return {"root": root_name, "words": words}
    except Exception as e:
        logger.error("Error in related words request", root=root_name, error=str(e))
        raise HTTPException(status_code=500, detail="Unable to retrieve related words")

@app.get("/word/{english_word}/graph", response_model=GraphResponse)
async def get_word_graph(english_word: str):
    """Get enriched graph data for visualization."""
    if not re.match(r"^[a-zA-Z\s'-]+$", english_word):
        raise HTTPException(status_code=400, detail="Invalid characters in word")
    
    try:
        # Get word and its roots
        word_data = await get_word_etymology(english_word)
        
        # Build graph nodes and edges
        nodes = []
        edges = []
        
        # Add English word node
        word_node = GraphNode(
            id=f"word_{english_word}",
            label=english_word,
            type="EnglishWord",
            properties={"name": english_word}
        )
        nodes.append(word_node)
        
        # Add root nodes and edges
        for root in word_data.roots:
            root_node = GraphNode(
                id=f"root_{root.transliteration}",
                label=f"{root.name}\n({root.transliteration})",
                type="GreekRoot",
                properties={
                    "name": root.name,
                    "transliteration": root.transliteration,
                    "meaning": root.meaning,
                    "category": getattr(root, 'category', None),
                    "frequency": getattr(root, 'frequency', None)
                }
            )
            nodes.append(root_node)
            
            # Add derivation edge
            edge = GraphEdge(
                source=f"word_{english_word}",
                target=f"root_{root.transliteration}",
                type="DERIVES_FROM",
                properties={"strength": 0.9}
            )
            edges.append(edge)
        
        return GraphResponse(nodes=nodes, edges=edges)
        
    except Exception as e:
        logger.error("Error in graph request", word=english_word, error=str(e))
        raise HTTPException(status_code=500, detail="Unable to generate graph data")
