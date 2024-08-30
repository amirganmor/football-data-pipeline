# Stage 1: FastAPI Application Setup
FROM python:3.10-slim AS fastapi

# Set the working directory inside the container
WORKDIR /app

# Copy only the requirements file to the container
COPY requirements.txt .

# Install the dependencies for FastAPI
RUN pip install --no-cache-dir -r requirements.txt

# Copy the FastAPI application file to the working directory
COPY venv/main.py /app/

# Command to run the FastAPI application using Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# Stage 2: Airflow Setup
FROM python:3.10-slim AS airflow

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the FastAPI dependencies from the first stage
COPY --from=fastapi /usr/local /usr/local

# Install Airflow and its Postgres provider
RUN pip install apache-airflow==2.8.0 apache-airflow-providers-postgres==2.0.2 psycopg2-binary==2.9.6 requests==2.28.1

# Copy Airflow DAG file to the container
COPY airflow/data_pipeline.py /app/airflow/

# Set environment variables for Airflow
ENV AIRFLOW_HOME=/app/airflow
ENV AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://user:password@postgres:5432/airflow
ENV AIRFLOW__CORE__EXECUTOR=LocalExecutor
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False

# Initialize Airflow database
RUN airflow db init

# Expose ports for FastAPI and Airflow
EXPOSE 8000
EXPOSE 8080

# Start both FastAPI and Airflow services
CMD ["sh", "-c", "airflow webserver --port 8080 & uvicorn main:app --host 0.0.0.0 --port 8000"]
