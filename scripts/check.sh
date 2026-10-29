#!/usr/bin/env bash
# The one check agents and CI run before calling a change done.
# Runs lint, format check, type check and an import smoke test inside Docker.
# Ruff and mypy use the versions pinned in .pre-commit-config.yaml; mypy runs
# before the runtime dependencies are installed, like the pre-commit hook does.
set -euo pipefail
cd "$(dirname "$0")/.."

# Git Bash on Windows needs a Windows-style path for the bind mount.
repo="$(pwd -W 2>/dev/null || pwd)"

MSYS_NO_PATHCONV=1 docker run --rm -v "$repo:/app" -w /app python:3.10-slim bash -euo pipefail -c '
  pip install --quiet --disable-pip-version-check ruff==0.4.4 mypy==1.10.0 poetry==1.8.3
  ruff check --ignore=E501 --per-file-ignores=__init__.py:F401 src
  ruff format --check src
  (cd src && mypy --ignore-missing-imports .)
  poetry config virtualenvs.create false
  poetry install --quiet --only main --no-root --no-interaction
  # Import smoke test; the values are placeholders, not credentials.
  cd src
  EXCHANGE_RATES_DATA_API_KEY=placeholder \
  EXCHANGE_RATES_DATA_API_CURRENCY_CONVERSION_ENDPOINT=http://localhost/convert \
  python -c "import main"
' 2>&1 | grep -v -E "WARNING: Running pip"
exit "${PIPESTATUS[0]}"
