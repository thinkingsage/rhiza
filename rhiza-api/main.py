import os
from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List
import google.generativeai as genai
from services.neo4j_service import EtymologyGraphService

# --- Configuration ---
# It's best practice to load your API key from an environment variable
# For example: export GEMINI_API_KEY="your_api_key_here"
# genai.configure(api_key=os.environ["GEMINI_API_KEY"])

app = FastAPI(
    title="Project Logos API",
    description="API for exploring the Greek roots of English words.",
    version="1.0.0",
)

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

# --- API Endpoint ---

@app.get("/word/{english_word}", response_model=WordResponse)
async def get_word_roots(english_word: str, response: Response):
    """
    Analyzes an English word to find its Ancient Greek roots.
    Checks graph database first, falls back to AI if not found.
    """
    response.headers["Content-Type"] = "application/json; charset=utf-8"
    try:
        # First, check if we have this word in our graph
        cached_result = graph_service.find_word_roots(english_word)
        if cached_result:
            return cached_result
        
        # If not in graph, use hardcoded response for now
        # TODO: Replace with actual AI call
        if english_word.lower() == "philosophy":
            result = {
              "name": "philosophy",
              "roots": [
                {
                  "name": "φίλος",
                  "transliteration": "philos",
                  "meaning": "loving, dear"
                },
                {
                  "name": "σοφία",
                  "transliteration": "sophia",
                  "meaning": "wisdom, knowledge"
                }
              ]
            }
            
            # Store the result in graph for future queries
            graph_service.store_etymology(english_word, result["roots"])
            return result
        else:
            return {"name": english_word, "roots": []}

    except Exception as e:
        # Handle potential errors, like the LLM not returning valid JSON
        raise HTTPException(status_code=500, detail=str(e))

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
async def get_word_graph(english_word: str):
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
                return record["graph"]
            else:
                return {"nodes": [], "links": []}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))