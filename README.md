# Rhiza

Rhiza (ῥίζα, "root" in Ancient Greek) analyzes English words to identify their Greek etymological origins using AI and displays relationships as interactive graphs.

![Rhiza Demo](https://via.placeholder.com/800x400/2c5aa0/ffffff?text=Rhiza+Etymology+Explorer)

## Features

**AI Analysis**
- Claude Sonnet 4 (AWS Bedrock) with Google Gemini fallback
- Greek root identification with transliterations and meanings
- Response caching

**Graph Visualization**
- D3.js force-directed graphs
- Semantic category clustering (13 categories)
- Frequency-based node sizing
- Part-of-speech indicators
- Interactive filtering by category and frequency
- Zoom and pan controls

**Stack**
- FastAPI backend with async operations
- SvelteKit frontend
- Neo4j graph database
- Docker containerization

**Security**
- Non-root container users
- Input validation and sanitization
- Rate limiting and CORS protection
- Structured logging

## Quick Start

### Prerequisites

API keys required for AI services:

1. AWS Bedrock access (primary)
   - AWS account with Bedrock enabled
   - Claude Sonnet 4 available in your region
   - AWS access credentials

2. Google Gemini API key (fallback)
   - Obtain from [Google AI Studio](https://aistudio.google.com/)

### Environment Setup

Create a `.env` file in the project root with your API keys:

```bash
# Copy the example file
cp .env.example .env

# Edit with your API keys
AWS_BEARER_TOKEN_BEDROCK=your_aws_bedrock_token_here
GEMINI_API_KEY=your_gemini_api_key_here

# Optional: Configure other settings
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=password
```

**Note:** At least one AI provider key is required for etymology analysis.

### Using Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/your-username/rhiza.git
cd rhiza

# Set up environment variables (see above)
cp .env.example .env
# Edit .env with your API keys

# Start all services
docker compose up --build

# Access the application
open http://localhost:5173
```

### Manual Setup

```bash
# Start Neo4j database
docker run -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/password neo4j:5.15-community

# Start the API
cd rhiza-api
pip install -r requirements.txt
uvicorn main:app --reload

# Start the UI
cd ../rhiza-ui
npm install
npm run dev
```

## Usage Examples

| Word | Greek Roots | Meaning |
|------|-------------|---------|
| **philosophy** | φίλος + σοφία | loving + wisdom |
| **democracy** | δῆμος + κρατία | people + power |
| **biology** | βίος + λόγος | life + study |
| **psychology** | ψυχή + λόγος | soul + study |
| **geography** | γῆ + γραφή | earth + writing |

## Architecture

### Components

- **proxy** - Nginx reverse proxy
- **rhiza-ui** - SvelteKit frontend with D3.js visualizations
- **rhiza-api** - FastAPI backend
- **Neo4j** - Graph database
- **AI Providers** - AWS Bedrock (Claude) and Google Gemini

## API Reference

### Etymology Analysis
```http
GET /word/{english_word}
```

**Example Response:**
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

Returns D3.js-compatible graph data for visualization.

### Health Monitoring
```http
GET /health      # Service health
GET /ready       # Dependency readiness
```

## Development

### Prerequisites

- Docker & Docker Compose (recommended)
- Python 3.11+ for API development
- Node.js 18+ for UI development
- Neo4j 5.15+ for database

### Environment Setup

```bash
# API Configuration
AWS_BEARER_TOKEN_BEDROCK=your_bedrock_token
GEMINI_API_KEY=your_gemini_key
NEO4J_URI=bolt://localhost:7687

# UI Configuration  
VITE_API_URL=http://localhost:8000

# Security
ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000
```

### Development Workflow

```bash
# Start development environment
docker compose -f docker-compose.dev.yml up

# Run tests
cd rhiza-api && pytest
cd rhiza-ui && npm test

# Format code
cd rhiza-api && black . && isort .
cd rhiza-ui && npm run format
```

## Deployment

### Production Docker

```bash
# Build production images
docker compose build

# Deploy with environment variables
docker compose -f docker-compose.prod.yml up -d
```

### Cloud Deployment Options

- AWS ECS/Fargate
- Google Cloud Run
- Azure Container Instances
- Kubernetes

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on submitting bug reports, feature requests, and code contributions.

Areas for contribution:
- Etymology accuracy improvements
- Additional language support (Latin, Sanskrit, etc.)
- Graph visualization enhancements
- Performance optimization
- Accessibility improvements

## Roadmap

- [x] Category clustering, frequency sizing, interactive filtering
- [x] Educational modes (Category Explorer, Grammar Guide)
- [ ] Multi-language support (Latin, Sanskrit, Germanic roots)
- [ ] Timeline views and etymology trees
- [ ] User accounts and word collections
- [ ] Educational features (quizzes, learning paths)
- [ ] Batch processing API
- [ ] Mobile applications

## License

Licensed under the GNU Affero General Public License v3.0 (AGPL-3.0). See [LICENSE](LICENSE) for details.

Key requirements:
- Free for personal, educational, and commercial use
- Derivative works must be open source
- Network users must have access to source code

## Acknowledgments

- Neo4j Community
- Anthropic & Google for AI models
- Open Source Community
