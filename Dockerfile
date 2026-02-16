FROM python:3.11-slim

# Evita prompts interativos
ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências do sistema necessárias pro Playwright
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    wget \
    gnupg \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpangocairo-1.0-0 \
    libgtk-3-0 \
    libxdamage1 \
    libxfixes3 \
    libxext6 \
    libx11-6 \
    libxcb1 \
    libdrm2 \
    libpango-1.0-0 \
    fonts-liberation \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Diretório do projeto dentro do container
WORKDIR /app

# Instala Robot + Browser Library + Allure
RUN pip install --no-cache-dir \
    robotframework \
    robotframework-browser \
    robotframework-requests \
    allure-robotframework

# Instala browsers do Playwright
RUN rfbrowser init

# Copia projeto
COPY . .

# Pasta de resultados
RUN mkdir -p results

# Comando padrão
CMD ["robot", "-d", "results", "tests"]