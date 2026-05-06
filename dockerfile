# Use a slim Python image to keep the footprint small
FROM python:3.10-slim

# Set environment variables to prevent Python from writing .pyc files
# and to ensure output is sent straight to logs (useful for Unraid console)
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Install system dependencies for building certain Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Create the cache directory so it exists when we map the volume in Unraid
RUN mkdir -p /app/cache

# Expose the port (Gunicorn default is often 8000, but we can stick to 5000)
EXPOSE 5000

# Start the application using Gunicorn for better performance
# -b 0.0.0.0:5000 binds it to all interfaces so Docker can see it
# 'app:app' assumes your entry file is app.py and the Flask instance is named 'app'
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
