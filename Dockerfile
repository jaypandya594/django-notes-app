# Use a slim version of Python to reduce image size
FROM python:3.9-slim

# Set environment variables to optimize Python performance
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    WORKDIR=/app/backend

WORKDIR ${WORKDIR}

# Install system dependencies in a single layer and clean up to save space
# Added 'libmariadb-dev' as it is often more compatible with mysqlclient on slim images
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies first to leverage Docker's layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir mysqlclient \
    && pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Create a non-root user for security and switch to it
RUN adduser --disabled-password --no-create-home appuser
USER appuser

EXPOSE 8000

# Start the application
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
#RUN python manage.py migrate
#RUN python manage.py makemigrations
