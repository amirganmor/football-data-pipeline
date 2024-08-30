from fastapi import FastAPI
from pydantic import BaseModel
from datetime import date
from typing import List

app = FastAPI()

class Match(BaseModel):
    match_date: date
    home_team_id: int
    home_team_score: int
    away_team_id: int
    away_team_score: int

class Team(BaseModel):
    id: int
    name: str
    city: str
    primary_color: str

# Example data with the specified teams
matches_data = [
    {"match_date": "2024-01-01", "home_team_id": 1, "home_team_score": 3, "away_team_id": 2, "away_team_score": 1},
    {"match_date": "2024-01-02", "home_team_id": 3, "home_team_score": 2, "away_team_id": 4, "away_team_score": 2},
    {"match_date": "2024-01-03", "home_team_id": 5, "home_team_score": 1, "away_team_id": 6, "away_team_score": 3},
    {"match_date": "2024-01-04", "home_team_id": 7, "home_team_score": 2, "away_team_id": 1, "away_team_score": 2},
]

teams_data = [
    {"id": 1, "name": "Real Madrid", "city": "Madrid", "primary_color": "White"},
    {"id": 2, "name": "Barcelona", "city": "Barcelona", "primary_color": "Blue/Red"},
    {"id": 3, "name": "Bayern Munich", "city": "Munich", "primary_color": "Red"},
    {"id": 4, "name": "Manchester United", "city": "Manchester", "primary_color": "Red"},
    {"id": 5, "name": "Manchester City", "city": "Manchester", "primary_color": "Sky Blue"},
    {"id": 6, "name": "AC Milan", "city": "Milan", "primary_color": "Red/Black"},
    {"id": 7, "name": "Paris Saint-Germain", "city": "Paris", "primary_color": "Blue"},
]

@app.get("/matches", response_model=List[Match])
def get_matches():
    return matches_data

@app.get("/teams", response_model=List[Team])
def get_teams():
    return teams_data
