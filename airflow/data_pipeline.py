from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime, timedelta
import requests

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2024, 8, 30),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'football_data_pipeline',
    default_args=default_args,
    description='A DAG for football data ingestion and power ranking',
    schedule_interval='@daily',
)

def fetch_and_load_data():
    pg_hook = PostgresHook(postgres_conn_id='postgres_conn')
    conn = pg_hook.get_conn()
    cursor = conn.cursor()

    # Fetch data from API endpoints
    games_response = requests.get('http://localhost:8000/matches')
    teams_response = requests.get('http://localhost:8000/teams')

    games_data = games_response.json()
    teams_data = teams_response.json()

    # Insert teams data
    for team in teams_data:
        cursor.execute("""
            INSERT INTO teams (id, name, city, primary_color) 
            VALUES (%s, %s, %s, %s)
            ON CONFLICT (id) DO NOTHING;
        """, (team['id'], team['name'], team['city'], team['primary_color']))

    # Insert matches data
    for match in games_data:
        cursor.execute("""
            INSERT INTO matches (match_date, home_team_id, home_team_score, away_team_id, away_team_score)
            VALUES (%s, %s, %s, %s, %s);
        """, (match['game_date'], match['home_team_id'], match['home_team_score'], match['away_team_id'], match['away_team_score']))

    conn.commit()
    cursor.close()
    conn.close()

def calculate_power_ranking():
    pg_hook = PostgresHook(postgres_conn_id='postgres_conn')
    conn = pg_hook.get_conn()
    cursor = conn.cursor()

    # Calculate power ranking
    cursor.execute("""
        WITH team_stats AS (
            SELECT
                t.id AS team_id,
                t.name AS team_name,
                COUNT(CASE WHEN m.home_team_score > m.away_team_score AND m.home_team_id = t.id THEN 1 END) AS wins,
                COUNT(CASE WHEN m.away_team_score > m.home_team_score AND m.away_team_id = t.id THEN 1 END) AS losses,
                SUM(CASE WHEN m.home_team_id = t.id THEN m.home_team_score - m.away_team_score ELSE m.away_team_score - m.home_team_score END) AS score_differential,
                (2 * COUNT(CASE WHEN m.home_team_score > m.away_team_score AND m.home_team_id = t.id THEN 1 END) +
                 COUNT(CASE WHEN m.away_team_score > m.home_team_score AND m.away_team_id = t.id THEN 1 END)) AS points
            FROM teams t
            LEFT JOIN matches m ON t.id = m.home_team_id OR t.id = m.away_team_id
            GROUP BY t.id, t.name
        )
        SELECT
            ROW_NUMBER() OVER (ORDER BY points DESC, score_differential DESC) AS rank,
            team_id,
            team_name,
            wins,
            losses,
            points,
            score_differential
        FROM team_stats
    """)
    
    ranking_data = cursor.fetchall()
    
    # Clear and insert power ranking data
    cursor.execute("TRUNCATE power_ranking;")
    for row in ranking_data:
        cursor.execute("""
            INSERT INTO power_ranking (rank, team_id, team_name, wins, losses, points, score_differential)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
        """, row)

    conn.commit()
    cursor.close()
    conn.close()

# Define Airflow tasks
fetch_and_load_data_task = PythonOperator(
    task_id='fetch_and_load_data',
    python_callable=fetch_and_load_data,
    dag=dag,
)

calculate_power_ranking_task = PythonOperator(
    task_id='calculate_power_ranking',
    python_callable=calculate_power_ranking,
    dag=dag,
)

fetch_and_load_data_task >> calculate_power_ranking_task
