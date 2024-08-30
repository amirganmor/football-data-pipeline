-- 1. Average Number of Wins for Teams Grouped by Their Primary Color
SELECT
    t.primary_color,
    AVG(wins) AS average_wins
FROM (
    SELECT
        t.primary_color,
        COUNT(CASE WHEN m.home_team_score > m.away_team_score AND m.home_team_id = t.id THEN 1 END) AS wins
    FROM teams t
    LEFT JOIN matches m ON t.id = m.home_team_id
    GROUP BY t.id, t.primary_color
) AS team_wins
GROUP BY primary_color;

-- 2. High Scoring Game
SELECT
    match_date,
    home_team_id,
    home_team_score,
    away_team_id,
    away_team_score,
    (home_team_score + away_team_score) AS total_score
FROM matches
ORDER BY total_score DESC
LIMIT 1;

-- 3. Team with the Highest Number of Home Game Wins
SELECT
    t.id,
    t.name,
    COUNT(*) AS home_wins
FROM teams t
JOIN matches m ON t.id = m.home_team_id
WHERE m.home_team_score > m.away_team_score
GROUP BY t.id, t.name
ORDER BY home_wins DESC
LIMIT 1;

-- 4. Total Score for Each Team Over All Games
SELECT
    t.id,
    t.name,
    COALESCE(SUM(CASE WHEN m.home_team_id = t.id THEN m.home_team_score ELSE m.away_team_score END), 0) AS total_score
FROM teams t
LEFT JOIN matches m ON t.id = m.home_team_id OR t.id = m.away_team_id
GROUP BY t.id, t.name;

-- 5. Team with the Most Significant Improvement in Wins Between Two Consecutive Years
WITH year_wins AS (
    SELECT
        t.id AS team_id,
        EXTRACT(YEAR FROM m.match_date) AS year,
        COUNT(CASE WHEN m.home_team_score > m.away_team_score AND m.home_team_id = t.id THEN 1 END) AS wins
    FROM teams t
    LEFT JOIN matches m ON t.id = m.home_team_id
    GROUP BY t.id, year
),
yearly_improvement AS (
    SELECT
        team_id,
        year,
        wins - LAG(wins) OVER (PARTITION BY team_id ORDER BY year) AS improvement
    FROM year_wins
)
SELECT
    t.id,
    t.name,
    MAX(improvement) AS max_improvement
FROM yearly_improvement
JOIN teams t ON t.id = team_id
GROUP BY t.id, t.name
ORDER BY max_improvement DESC
LIMIT 1;

-- 6. Game with the Largest Point Difference
SELECT
    match_date,
    home_team_id,
    home_team_score,
    away_team_id,
    away_team_score,
    ABS(home_team_score - away_team_score) AS point_difference
FROM matches
ORDER BY point_difference DESC
LIMIT 1;

-- 7. Team that Played the Most Games in Their Home City
SELECT
    t.id,
    t.name,
    COUNT(*) AS home_games
FROM teams t
JOIN matches m ON t.id = m.home_team_id
GROUP BY t.id, t.name
ORDER BY home_games DESC
LIMIT 1;

-- 8. Win Rate for Each Team
SELECT
    t.id,
    t.name,
    COALESCE(
        COUNT(CASE WHEN m.home_team_score > m.away_team_score AND m.home_team_id = t.id THEN 1 END) * 1.0 /
        NULLIF(COUNT(*), 0), 
        0
    ) AS win_rate
FROM teams t
LEFT JOIN matches m ON t.id = m.home_team_id OR t.id = m.away_team_id
GROUP BY t.id, t.name;

-- 9. Team with the Most Losses in Away Games
SELECT
    t.id,
    t.name,
    COUNT(*) AS away_losses
FROM teams t
JOIN matches m ON t.id = m.away_team_id
WHERE m.away_team_score < m.home_team_score
GROUP BY t.id, t.name
ORDER BY away_losses DESC
LIMIT 1;

-- 10. Distribution of Home and Away Wins for Each Team
SELECT
    t.id,
    t.name,
    COUNT(CASE WHEN m.home_team_score > m.away_team_score AND m.home_team_id = t.id THEN 1 END) AS home_wins,
    COUNT(CASE WHEN m.away_team_score > m.home_team_score AND m.away_team_id = t.id THEN 1 END) AS away_wins
FROM teams t
LEFT JOIN matches m ON t.id = m.home_team_id OR t.id = m.away_team_id
GROUP BY t.id, t.name;
