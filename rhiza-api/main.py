import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List
import google.generativeai as genai

# --- Configuration ---
# It's best practice to load your API key from an environment variable
# For example: export GEMINI_API_KEY="your_api_key_here"
# genai.configure(api_key=os.environ["GEMINI_API_KEY"])

app = FastAPI(
    title="Project Logos API",
    description="API for exploring the Greek roots of English words.",
    version="1.0.0",
)

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
async def get_word_roots(english_word: str):
    """
    Analyzes an English word to find its Ancient Greek roots.
    """
    try:
        # --- Placeholder for Gemini API Call ---
        # In a real implementation, you would make the API call here.
        # For example:
        # model = genai.GenerativeModel('gemini-pro')
        # full_prompt = f"{SYSTEM_PROMPT}\n{english_word}"
        # response = await model.generate_content_async(full_prompt)
        # response_json = json.loads(response.text)
        # return response_json

        # For now, we'll return a hardcoded example for testing.
        if english_word.lower() == "philosophy":
            return {
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
        else:
            return {"name": english_word, "roots": []}

    except Exception as e:
        # Handle potential errors, like the LLM not returning valid JSON
        raise HTTPException(status_code=500, detail=str(e))