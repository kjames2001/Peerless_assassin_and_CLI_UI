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

# Copy project files
COPY requirements.txt pyproject.toml uv.lock ./
COPY config.json layout.json peerless_layout.json ./
COPY src/ ./src/
COPY led_control.sh ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make shell script executable
RUN chmod +x led_control.sh

# Create a non-root user for running the application
RUN useradd -m -u 1000 peerless && \
    chown -R peerless:peerless /app

# Switch to non-root user
USER peerless

# Set the entrypoint to run the LED display controller
ENTRYPOINT ["python", "-m", "src.led_display_controller"]

# Default command (can be overridden)
CMD []
