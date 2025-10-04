# 🏛️ Rhiza API

> **Discover the Greek roots of English words through AI-powered etymology analysis**

Rhiza API is a FastAPI-based service that analyzes English words to uncover their Ancient Greek origins. Using advanced AI models and graph database technology, it provides detailed etymological insights with beautiful visualizations.

## ✨ Features

- 🤖 **AI-Powered Analysis** - Claude Sonnet 4 (AWS Bedrock) with Google Gemini fallback
- 📊 **Graph Database** - Neo4j for storing and querying etymological relationships  
- ⚡ **High Performance** - Async operations with connection pooling and caching
- 🔒 **Production Ready** - Container security, rate limiting, and comprehensive logging
- 🌐 **CORS Enabled** - Configurable cross-origin resource sharing
- 📈 **Health Monitoring** - Built-in health checks and structured logging

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Neo4j database
- AWS Bedrock access (optional)
- Google Gemini API key (optional)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/rhiza.git
cd rhiza/rhiza-api

# Install dependencies
pip install fastapi uvicorn python-dotenv google-generativeai neo4j boto3 structlog slowapi

# Set up environment variables
cp .env.example .env
# Edit .env with your API keys and configuration
```

### Environment Configuration

Create a `.env` file with the following variables:

```bash
# AI Provider Configuration
GEMINI_API_KEY=your_gemini_api_key_here
AWS_DEFAULT_REGION=us-east-1
AWS_BEARER_TOKEN_BEDROCK=your_aws_bearer_token_here

# Neo4j Configuration
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

### Running the API

```bash
# Development
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Production
uvicorn main:app --host 0.0.0.0 --port 8000
```

## 🐳 Docker Deployment

```bash
# Build the container
docker build -t rhiza-api .

# Run with environment file
docker run -p 8000:8000 --env-file .env rhiza-api
```

## 📚 API Endpoints

### Etymology Analysis
```http
GET /word/{english_word}
```
Analyzes an English word and returns its Greek roots.

**Example:**
```bash
curl http://localhost:8000/word/philosophy
```

**Response:**
```json
{
  "name": "philosophy",
  "roots": [
    {
      "name": "φίλος",
      "transliteration": "philos", 
      "meaning": "loving, friend"
    },
    {
      "name": "σοφία",
      "transliteration": "sophia",
      "meaning": "wisdom"
    }
  ]
}
```

### Graph Visualization
```http
GET /word/{english_word}/graph
```
Returns graph data for visualization of etymological relationships.

### Related Words
```http
GET /root/{root_name}/words
```
Finds all English words derived from a specific Greek root.

### Health Checks
```http
GET /health      # Basic health check
GET /ready       # Readiness check with dependencies
```

## 🏗️ Architecture

- **FastAPI** - Modern, fast web framework for building APIs
- **Neo4j** - Graph database for storing etymological relationships
- **AWS Bedrock** - Primary AI provider (Claude Sonnet 4)
- **Google Gemini** - Fallback AI provider
- **Structured Logging** - JSON logs with request tracing
- **Rate Limiting** - Protection against abuse
- **Async Operations** - Non-blocking database and AI calls

## 🔧 Configuration

### AI Providers

The API supports multiple AI providers with automatic fallback:

1. **AWS Bedrock (Primary)** - Requires bearer token authentication
2. **Google Gemini (Fallback)** - Requires API key

### Database

Neo4j is used for caching etymology results and building relationship graphs:

- **Indexes** - Automatic creation on startup for optimal performance
- **Connection Pooling** - Configurable pool size and timeouts
- **Async Operations** - Non-blocking database queries

### Security Features

- **Container Security** - Non-root user, read-only filesystem
- **Input Validation** - Comprehensive sanitization and attack prevention
- **Rate Limiting** - Configurable per-IP limits
- **CORS Protection** - Configurable allowed origins

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](../CONTRIBUTING.md) for details.

### Development Setup

```bash
# Install development dependencies
pip install -r requirements-dev.txt

# Run tests
pytest

# Format code
black .
isort .

# Lint
flake8
```

## 📄 License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0) - see the [LICENSE](../LICENSE) file for details.

**Key points about AGPL-3.0:**
- ✅ Free to use, modify, and distribute
- ✅ Must provide source code to users (including network users)
- ✅ Derivative works must also be AGPL-3.0 licensed
- ⚠️ Network use triggers copyleft obligations

## 🙏 Acknowledgments

- **Ancient Greek Language** - The foundation of Western etymology
- **Neo4j Community** - Graph database excellence
- **FastAPI Team** - Modern Python web framework
- **Anthropic & Google** - AI language models

## 📞 Support

- 📖 [Documentation](https://github.com/your-username/rhiza/wiki)
- 🐛 [Issue Tracker](https://github.com/your-username/rhiza/issues)
- 💬 [Discussions](https://github.com/your-username/rhiza/discussions)

---

**Rhiza** (ῥίζα) - *Ancient Greek for "root"* 🌱
