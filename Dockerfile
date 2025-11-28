FROM python:3.10-slim-bookworm

# Install system dependencies for Playwright (as root)
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcurl4 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libglib2.0-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxrender1 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies and Playwright
RUN pip install --no-cache-dir -r requirements.txt

# Create a user with UID 1000 (standard for Hugging Face Spaces)
# This prevents permission errors often seen with Playwright
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Update working directory permissions
WORKDIR /app
COPY --chown=user . $HOME/app

# Set a default PORT to 7860 if the environment doesn't provide one
ENV PORT=7860

# Expose the port
EXPOSE $PORT

# Start the app with Gunicorn, using the PORT environment variable
CMD gunicorn -k uvicorn.workers.UvicornWorker app:app --bind 0.0.0.0:$PORTorker app:app --bind 0.0.0.0:$PORT
