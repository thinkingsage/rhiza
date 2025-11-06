# Copilot Instructions for Rhiza

## Project Overview

Rhiza (ῥίζα, meaning "root" in Ancient Greek) is a web application that explores the Greek etymology of English words using AI-powered analysis and interactive graph visualizations. The application helps users discover and understand the Ancient Greek roots of English words through beautiful, interactive visualizations.

## Technology Stack

### Backend (rhiza-api)
- **Language**: Python 3.11+
- **Framework**: FastAPI with async operations
- **Database**: Neo4j 5.15+ (graph database)
- **AI Providers**: 
  - Primary: AWS Bedrock (Claude Sonnet 4)
  - Fallback: Google Gemini
- **Key Libraries**: 
  - `uvicorn` - ASGI server
  - `neo4j` - Graph database driver
  - `boto3` - AWS SDK
  - `google-generativeai` - Gemini API
  - `structlog` - Structured logging
  - `slowapi` - Rate limiting
- **Dependency Management**: Poetry
- **Container**: Docker with security hardening

### Frontend (rhiza-ui)
- **Language**: JavaScript (ES6+)
- **Framework**: SvelteKit (Svelte 5)
- **Visualization**: D3.js for force-directed graphs
- **Build Tool**: Vite
- **Package Manager**: pnpm
- **Key Features**:
  - Interactive graph visualizations
  - Semantic category clustering
  - Frequency-based node sizing
  - Part-of-speech visual indicators
  - Educational modes (Category Explorer, Grammar Guide)

### Infrastructure
- **Containerization**: Docker & Docker Compose
- **Proxy**: Nginx for load balancing
- **Database**: Neo4j Community Edition
- **CI/CD**: GitHub Actions

## Code Style & Standards

### Python (rhiza-api)
- **Formatting**: Use Black for code formatting
- **Import Sorting**: Use isort for organizing imports
- **Style Guide**: Follow PEP 8 guidelines
- **Type Hints**: Always include type hints for function parameters and return values
- **Documentation**: Write docstrings for all functions, classes, and modules
- **Async/Await**: Use async/await for I/O operations
- **Error Handling**: Use structured logging with contextual information

Example:
```python
async def analyze_word(word: str) -> dict:
    """Analyze an English word for Greek etymology.
    
    Args:
        word: The English word to analyze
        
    Returns:
        Dictionary containing word name and Greek roots
    """
    # Implementation
```

### JavaScript/Svelte (rhiza-ui)
- **Formatting**: Use Prettier for code formatting
- **Linting**: Follow ESLint rules
- **Naming**: Use camelCase for variables and functions, PascalCase for components
- **Components**: Keep Svelte components focused and reusable
- **Comments**: Add JSDoc comments for complex functions
- **Reactivity**: Use Svelte's reactive declarations (`$:`) appropriately

Example:
```javascript
/**
 * Fetch etymology data for a given word
 * @param {string} word - The word to analyze
 * @returns {Promise<Object>} Etymology data
 */
async function fetchEtymology(word) {
    // Implementation
}
```

## Project Structure

```
rhiza/
├── .github/
│   ├── workflows/       # GitHub Actions CI/CD
│   └── copilot-instructions.md
├── rhiza-api/          # FastAPI backend
│   ├── main.py         # API entry point
│   ├── services/       # Business logic services
│   ├── pyproject.toml  # Poetry dependencies
│   └── Dockerfile      # API container
├── rhiza-ui/           # SvelteKit frontend
│   ├── src/
│   │   ├── lib/
│   │   │   ├── components/  # Svelte components
│   │   │   ├── constants.js # App constants
│   │   │   └── utils.js     # Utility functions
│   │   └── routes/          # SvelteKit routes
│   ├── package.json         # NPM dependencies
│   └── Dockerfile           # UI container
├── data/
│   └── cypher/         # Neo4j seed data
├── scripts/            # Build and test scripts
├── docker-compose.yml  # Container orchestration
├── GEMINI.md          # AI prompt for Gemini
└── README.md          # Project documentation
```

## Development Workflow

### Setting Up Development Environment

1. **Prerequisites**: Docker, Docker Compose, Python 3.11+, Node.js 18+
2. **Environment Variables**: Copy `.env.example` to `.env` and configure:
   - `AWS_BEARER_TOKEN_BEDROCK` - AWS Bedrock credentials
   - `GEMINI_API_KEY` - Google Gemini API key
   - `NEO4J_URI`, `NEO4J_USER`, `NEO4J_PASSWORD` - Database config

3. **Start Services**:
```bash
docker compose up --build
```

### Running Tests

**API Tests**:
```bash
cd rhiza-api
pytest tests/
```

**UI Tests**:
```bash
cd rhiza-ui
npm test
```

**Integration Tests**:
```bash
./scripts/test.sh --ci
```

### Code Formatting

**Python**:
```bash
cd rhiza-api
black .
isort .
```

**JavaScript**:
```bash
cd rhiza-ui
npm run format
```

## Key Concepts & Domain Knowledge

### Etymology Structure
The application returns etymology data in this format:
```json
{
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
```

### Graph Database Schema
- **Nodes**: English words and Greek roots
- **Relationships**: `HAS_ROOT` connecting words to their etymological roots
- **Properties**: Include metadata like frequency, category, part-of-speech

### AI Integration
- The GEMINI.md file contains the exact prompt used for etymology analysis
- AI responses must return valid JSON matching the etymology structure
- Caching is implemented to reduce API costs

### Visualization Features
- **Categories**: 13 semantic categories (science, emotion, philosophy, etc.)
- **Frequency Levels**: very_high, high, medium, low
- **Node Sizing**: Based on word frequency in English
- **Color Coding**: Each category has a distinct color
- **Part-of-Speech**: Visual indicators using border styles

## Common Tasks & Patterns

### Adding a New API Endpoint
1. Define the endpoint in `rhiza-api/main.py`
2. Add input validation using Pydantic models
3. Implement business logic in `rhiza-api/services/`
4. Add structured logging
5. Include error handling
6. Write tests

### Adding a New UI Component
1. Create component in `rhiza-ui/src/lib/components/`
2. Use Svelte 5 syntax
3. Export props with proper types
4. Add JSDoc documentation
5. Test with various data inputs

### Modifying Graph Visualization
- D3.js code is in `rhiza-ui/src/lib/enriched_graph.js`
- Force simulation parameters control layout
- Node and link styling uses data-driven properties
- Interactive features use event listeners

## Security Considerations

- **Input Validation**: Always validate and sanitize user inputs
- **API Keys**: Never commit secrets; use environment variables
- **Rate Limiting**: API endpoints are rate-limited via SlowAPI
- **CORS**: Configure allowed origins appropriately
- **Container Security**: Run as non-root user, read-only filesystems
- **SQL/Cypher Injection**: Use parameterized queries for Neo4j

## Important Files to Review

- **GEMINI.md**: Contains the AI prompt - critical for etymology accuracy
- **CONTRIBUTING.md**: Contribution guidelines
- **README.md**: User-facing documentation
- **docker-compose.yml**: Service orchestration
- **.github/workflows/test.yml**: CI/CD pipeline

## Common Pitfalls to Avoid

1. **Don't modify GEMINI.md** without careful consideration - it's the core of etymology accuracy
2. **Don't commit .env files** - use .env.example as template
3. **Don't break the JSON structure** - AI responses must match expected format
4. **Don't ignore Neo4j connection errors** - check database health first
5. **Don't skip Docker builds** - changes may require container rebuilds
6. **Test with Greek characters** - ensure UTF-8 encoding throughout
7. **Consider mobile/responsive** - UI should work on various screen sizes

## Testing Strategy

- **Unit Tests**: Test individual functions and components
- **Integration Tests**: Test API endpoints with database
- **E2E Tests**: Test complete user workflows via scripts/test.sh
- **Manual Testing**: Try various English words, especially edge cases
- **Performance Testing**: Monitor API response times and graph rendering

## Deployment Notes

- Application is containerized for easy deployment
- Requires environment variables for AI providers
- Neo4j needs persistent storage volume
- Consider caching strategies for production
- Monitor API rate limits and costs

## Resources & References

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SvelteKit Documentation](https://kit.svelte.dev/)
- [Neo4j Cypher Manual](https://neo4j.com/docs/cypher-manual/)
- [D3.js Documentation](https://d3js.org/)
- [Greek Alphabet Reference](https://en.wikipedia.org/wiki/Greek_alphabet)

## When Making Changes

1. **Understand the context**: Greek etymology is the core domain
2. **Preserve accuracy**: Don't break etymology analysis
3. **Test thoroughly**: Words with multiple roots, no Greek roots, invalid inputs
4. **Update documentation**: Keep README and comments current
5. **Follow conventions**: Match existing code style
6. **Consider performance**: Graph rendering with many nodes
7. **Think about UX**: Make etymology exploration delightful
