# Poetic Translator

A single-page application (SPA) built with React and Phoenix/Elixir that demonstrates poetic text translation using the Hugging Face Router API.

## Requirements

- Docker
- Docker Compose

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/poetic-translator.git
   cd poetic-translator
   ```

2. Copy the environment file and set required variables:
   ```bash
   cp .env.example .env
   ```
   Open `.env` and fill in the following values:
   ```dotenv
   DATABASE_URL=ecto://postgres:postgres@db/api_prod
   SECRET_KEY_BASE=your_secret_key
   # If you use OpenAI routes, set your API key (Bearer token):
   OPENAI_API_KEY=Bearer sk-xxxxxxxxxxxxxxxxxxxxx
   ```

3. Build and start all services:
   ```bash
   docker-compose up -d --build
   ```

4. Check container status:
   ```bash
   docker-compose ps
   ```

5. Access the application:
   - Frontend UI: http://localhost:8080
   - Backend health check: http://localhost:4000/health

6. Test the poetic translation endpoint using `curl`:
   ```bash
   curl -X POST http://localhost:4000/api/translate/poetic/router \
     -H "Content-Type: application/json" \
     -d '{"text":"Hello, world!","from_lang":"en","to_lang":"ru"}'
   ```

## Repository Structure

```
.
├── api/                # Phoenix/Elixir backend
│   ├── Dockerfile
│   ├── config/
│   └── lib/
├── frontend/           # React frontend
│   ├── Dockerfile
│   └── src/
├── docker-compose.yml  # Docker Compose configuration
├── .env.example        # Example environment file
└── README.md           # Project documentation
```

## Production-Ready Considerations

- Frontend optimizations (minification, gzip, tree-shaking)
- Separate `docker-compose.prod.yml` with pre-built images
- Enable CORS, HTTPS, HSTS and secure headers
- CI/CD pipeline with linting, tests, and automated deploy
- Monitoring, centralized logging, and metrics
- OpenAPI/Swagger documentation for backend routes

_For demonstration purposes, cloning the repository and running `docker-compose up -d --build` is sufficient to see the SPA in action._