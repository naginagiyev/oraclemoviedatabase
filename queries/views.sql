-- view 1: joins movies, directors and reviews with a WHERE filter
CREATE OR REPLACE VIEW viewMovieDetails AS
SELECT 
    m.movieID,
    m.movieTitle,
    m.genre,
    m.releaseYear,
    d.directorName,
    ROUND(AVG(r.rating), 1) AS avgRating
FROM movies m
JOIN directors d ON m.directorID = d.directorID
JOIN reviews r ON m.movieID = r.movieID
WHERE m.releaseYear >= 2015
GROUP BY m.movieID, m.movieTitle, m.genre, m.releaseYear, d.directorName;

-- view 2: joins movies and reviews, uses subquery, GROUP BY and HAVING
CREATE OR REPLACE VIEW viewPopularMovies AS
SELECT 
    m.movieID,
    m.movieTitle,
    m.genre,
    COUNT(r.reviewID) AS reviewCount,
    ROUND(AVG(r.rating), 1) AS avgRating
FROM movies m
JOIN reviews r ON m.movieID = r.movieID
WHERE m.movieID IN (
    SELECT movieID FROM reviews
    GROUP BY movieID
    HAVING COUNT(*) > 10
)
GROUP BY m.movieID, m.movieTitle, m.genre
HAVING ROUND(AVG(r.rating), 1) > 6;

-- display the created views
SELECT * FROM viewMovieDetails;
SELECT * FROM viewPopularMovies;