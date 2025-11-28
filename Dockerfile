# Use Python 3.10
FROM python:3.10-slim-bookworm

# 1. Install system dependencies for Playwright (Requires Root)
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
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

# 2. Set up a new user 'user' (Required for Hugging Face Spaces)
RUN useradd -m -u 1000 user

# 3. Switch to the new user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# 4. Set working directory to the user's home folder
WORKDIR $HOME/app

# 5. Copy requirements.txt FIRST (Optimizes cache)
COPY --chown=user requirements.txt .

# 6. Install Python dependencies
# Note: We install playwright here via pip, then install the browser
RUN pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir -r requirements.txt

# 7. Install Playwright Browser (Chromium) as the user
RUN playwright install chromium

# 8. Copy the rest of the application code
COPY --chown=user . .

# 9. Set the Default Port (Fixes the "'' is not a valid port" error)
ENV PORT=7860

# 10. Start the application
CMD gunicorn -k uvicorn.workers.UvicornWorker app:app --bind 0.0.0.0:$PORT
