FROM python:3.11-slim

WORKDIR /app

# Copy only dependency files first for better caching
COPY pyproject.toml ./

# Install dependencies in separate layer for caching
RUN pip install --no-cache-dir fastapi uvicorn python-dotenv google-generativeai neo4j boto3 structlog slowapi

# Copy source code last to maximize cache hits
COPY . .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
