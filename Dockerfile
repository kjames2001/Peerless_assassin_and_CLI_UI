# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libhidapi-dev \
    libhidapi-hidraw0 \
    libhidapi-libusb0 \
    libudev-dev \
    jq \
    usbutils \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy entire project
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make shell script executable
RUN chmod +x led_control.sh 2>/dev/null || true

# Create a non-root user for running the application
RUN useradd -m -u 1000 peerless && \
    chown -R peerless:peerless /app

# Switch to non-root user
USER peerless

# Try to run as a module first (if __main__.py exists), otherwise list files for debugging
ENTRYPOINT ["sh", "-c", "if [ -f src/__main__.py ]; then python -m src; else echo 'Available files in src/:'; ls -la src/; echo ''; echo 'Try running with: docker run <image> python src/<file>.py'; sleep infinity; fi"]
