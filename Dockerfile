FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies needed by pygame and pydub (ffmpeg)
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   build-essential \
	   ffmpeg \
	   libsdl2-dev \
	   libsdl2-image-dev \
	   libsdl2-mixer-dev \
	   libsdl2-ttf-dev \
	   libportmidi-dev \
	   libfreetype6-dev \
	   libjpeg-dev \
	&& rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip setuptools wheel \
	&& pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . /app

# Expose Flask default port and allow override via PORT env var
ENV PORT=5000
EXPOSE ${PORT}

# Run the app with gunicorn (app.py should expose `app` WSGI application)
# Use a shell form so the PORT env var can be interpolated at runtime
CMD ["sh", "-c", "gunicorn --bind 0.0.0.0:${PORT} app:app --workers 3"]
