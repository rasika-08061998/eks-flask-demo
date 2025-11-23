# Use an official Python image as base
FROM python:3.11-slim

# Set working directory inside container
WORKDIR /app

# Copy dependency file first (for layer caching)
COPY app/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY app/ .

# Expose the port Flask will run on
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
