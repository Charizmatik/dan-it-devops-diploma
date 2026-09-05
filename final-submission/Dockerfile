FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

COPY backend/app.py ./app.py
COPY backend/static/ ./static/

USER 10001:10001

EXPOSE 8000

CMD ["python", "app.py"]
