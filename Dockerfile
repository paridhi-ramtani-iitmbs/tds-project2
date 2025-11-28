FROM python:3.10-slim-bookworm

# ==========================================
# 1. RUN AS ROOT - Install System Dependencies
# ==========================================
# This is the exact list you provided to ensure Playwright has what it needs.
RUN apt-get update && apt-get install -y \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    wget \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# ==========================================
# 2. SETUP USER (Hugging Face Requirement)
# ==========================================
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR $HOME/app

# ==========================================
# 3. INSTALL PYTHON PACKAGES
# ==========================================
# Copy requirements first to leverage Docker cache
COPY --chown=user requirements.txt .

# Install dependencies + explicitly install playwright as requested
RUN pip install --no-cache-dir -U pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir playwright

# ==========================================
# 4. INSTALL PLAYWRIGHT BROWSERS
# ==========================================
# We don't need --with-deps here because we installed them in Step 1 using apt-get.
# We just install the Chromium browser binary now.
RUN playwright install chromium

# ==========================================
# 5. COPY APP & START
# ==========================================
COPY --chown=user . .

# Set default port to avoid "'' is not a valid port" error
ENV PORT=7860

CMD gunicorn -k uvicorn.workers.UvicornWorker app:app --bind 0.0.0.0:$PORT
