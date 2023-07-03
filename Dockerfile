# Use the official Python image as the base
FROM python:3.9-slim

# Set the version as a build argument (default to 1.0.0 if not provided)
ARG VERSION

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install the dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY . .

# Expose the port on which the Flask app runs
EXPOSE 5000

# Set an environment variable with the version
ENV APP_VERSION=${VERSION}

# Run the Flask app
CMD ["python", "app.py"]
