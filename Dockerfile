FROM python:3.11.6-slim-bookworm as base

# Install poetry
RUN pip install pipx
RUN python3 -m pipx ensurepath
RUN pipx install poetry
ENV PATH="/root/.local/bin:$PATH"
ENV PATH=".venv/bin/:$PATH"

# https://python-poetry.org/docs/configuration/#virtualenvsin-project
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

FROM base as dependencies
WORKDIR /home/worker/app
COPY pyproject.toml poetry.lock ./

RUN poetry install --extras "ui weaviate vllm"

FROM base as app

ENV PYTHONUNBUFFERED=1
ENV PORT=8080
EXPOSE 8080

# Prepare a non-root user
# RUN adduser --system worker
WORKDIR /home/worker/app

# COPY --chown=worker --from=dependencies /home/worker/app/.venv/ .venv
# COPY --chown=worker --chmod=700 src/ src
# COPY --chown=worker *.yaml ./
# COPY --chown=worker main.py main.py

COPY --from=dependencies /home/worker/app/.venv/ .venv
COPY --chmod=700 src/ src
COPY *.yaml ./
COPY main.py main.py

# USER worker

ENTRYPOINT gunicorn main:app \
    --bind 0.0.0.0:${PORT}  \
    --worker-class uvicorn.workers.UvicornWorker \
    --timeout=${RAG_TIMEOUT:-6000} \
    --threads=${RAG_THREADS:-1} \
    --workers=${RAG_WORKERS:-8}