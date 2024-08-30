# football-data-pipeline
# Data Engineer Exam Project


## Project strucrue
project_dir/
├── README.md (You are here!)
├── Dockerfile
├── requirements.txt
├── queries.sql
├── venv/   # Virtual environment for Python dependencies (may vary)
│   ├── main.py
│   └── ... (other Python files, if needed)
└── airflow/ (may vary)
    ├── data_pipeline.py
    └── ... (other Airflow DAG files, if needed)


## Overview

It is divided into three parts:

1. **Part 1: Python** - Develop a FastAPI application with endpoints for football data.
2. **Part 2: Data Pipeline** - Build an Airflow data pipeline to manage data ingestion and power ranking.
3. **Part 3: SQL** - Write SQL queries to analyze and extract insights from the data.

## Part 1: Python

### Overview

Create a FastAPI web server with the following endpoints:

- **Games**: Provides data about games with the following schema:
  - `game_date`: The date of the game
  - `home_team_id`: The ID of the home team
  - `home_team_score`: The score of the home team
  - `away_team_id`: The ID of the away team
  - `away_team_score`: The score of the away team

- **Teams**: Provides data about teams with the following schema:
  - `id`: The ID of the team
  - `name`: The name of the team
  - `city`: The city of the team
  - `primary_color`: The primary color of the team

### Files

- `venv/main.py`: FastAPI application file.
- `requirements.txt`: Dependencies for the FastAPI application.

# Part 2: Data Pipeline

## Overview

In this part, you are required to create an Airflow data pipeline to handle data ingestion and power ranking for football data. The pipeline includes:

1. **Data Ingestion**: Insert new data into a PostgreSQL database daily.
2. **Power Ranking**: Create and update a table to rank teams based on their performance.

## Files

- `airflow/data_pipeline.py`: Airflow DAG file for managing the data pipeline.
- `Dockerfile`: Contains setup instructions for both FastAPI and Airflow environments.

# Part 3: Sql Queries

## Overview

In this part, you have 10 useful  sql queries:

## Files

- `queries.sql`: 10 sql queries

## Dockerfile

The Dockerfile is organized into two stages:

1. **FastAPI Application Setup**: Sets up the FastAPI application environment.
2. **Airflow Setup**: Configures the Airflow environment with necessary dependencies and settings.

# Running the Data Pipeline

## Build and Run the Docker Container

### Build the Docker Image

```bash
docker build -t data-pipeline-app .
docker run -p 8000:8000 -p 8080:8080 data-pipeline-app


# Project Configuration and Access

## Access the Services

- **FastAPI Application:** Access the FastAPI application at [http://localhost:8000](http://localhost:8000).
- **Airflow Web Interface:** Access the Airflow web interface at [http://localhost:8080](http://localhost:8080).

## Configuration

- **PostgreSQL Connection:** Ensure PostgreSQL is running and accessible. Modify the `AIRFLOW__CORE__SQL_ALCHEMY_CONN` environment variable in the Dockerfile to match your PostgreSQL setup if necessary.

## Notes

- The Airflow DAG is configured to handle both data ingestion and power ranking tasks.
- Ensure that the `requirements.txt` file contains all necessary dependencies for FastAPI and Airflow.
- Review and adjust Airflow settings and environment variables based on your setup and requirements.
