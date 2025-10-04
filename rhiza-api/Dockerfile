FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy only dependency files first for better caching
COPY pyproject.toml ./

# Install dependencies in separate layer for caching
RUN pip install --no-cache-dir fastapi uvicorn python-dotenv google-generativeai neo4j boto3 structlog slowapi

# Copy source code and set ownership
COPY . .
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
