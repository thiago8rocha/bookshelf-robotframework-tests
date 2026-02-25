FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PATH="/root/.local/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl unzip wget gnupg libnss3 libatk1.0-0 libatk-bridge2.0-0 \
    libcups2 libxkbcommon0 libxcomposite1 libxrandr2 libgbm1 \
    libasound2 libpangocairo-1.0-0 libgtk-3-0 libxdamage1 \
    libxfixes3 libxext6 libx11-6 libxcb1 libdrm2 libpango-1.0-0 \
    fonts-liberation ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instala as bibliotecas usando o próprio Python para garantir o vínculo
RUN python -m pip install --upgrade pip && \
    python -m pip install --no-cache-dir \
    robotframework \
    robotframework-browser \
    robotframework-faker \
    robotframework-requests \
    allure-robotframework

# Inicializa o Browser do Robot
RUN rfbrowser init

COPY . .

# Usamos 'python -m robot' em vez de apenas 'robot' para garantir que ele veja os pacotes
CMD ["python", "-m", "robot", "-d", "results", "tests"]