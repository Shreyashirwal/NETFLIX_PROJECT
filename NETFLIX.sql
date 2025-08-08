--Netflix project
DROP TABLE IF EXISTS netflix;

CREATE TABLE NETFLIX
(
	show_id	VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
)

SELECT * FROM netflix;

SELECT 
	COUNT(*) AS TOTAL_CONTENT
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;

--Q.1 Count the Number of Movies vs TV Shows
SELECT 
	type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type;

--Q.2 Find the Most Common Rating for Movies and TV Shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

--Q.3 List All Movies Released in a Specific Year (e.g., 2020)
SELECT 
	title
FROM netflix
WHERE 
	type = 'Movie' 
	and 
	release_year = 2020;

--Q.4 Find the Top 5 Countries with the Most Content on Netflix

SELECT * 
FROM
(
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS country,
        COUNT(*) AS total_content
    FROM netflix
    GROUP BY 1
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

--Q.5 Identify the Longest Movie

SELECT
	title
FROM netflix
WHERE
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)

--Q.6 Find Content Added in the Last 5 Years

SELECT 
	*
FROM netflix
WHERE
	TO_DATE(date_added, 'Month DD,YYYY')  >=  CURRENT_DATE - INTERVAL '5 years'

--Q.7 Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT * 
FROM (
	SELECT 
		*,
		UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
	FROM netflix
	) as T
WHERE director_name = 'Rajiv Chilaka'

--Q.8 List All TV Shows with More Than 5 Seasons

SELECT 
	*
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ',1) :: numeric > 5

--Q.9 Count the Number of Content Items in Each Genre

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS GENRE,
	COUNT(show_id) AS TOTAL_COUNT
FROM netflix
GROUP BY 1

--Q.10 Find each year and the average number of content release in India on netflix.

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--Q.11  List All Movies that are Documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

--Q.12 Find All Content Without a Director

SELECT * 
FROM netflix
WHERE director IS NULL;

--Q.13 Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

 --Q.14 Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

 SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

--Q.15 Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
