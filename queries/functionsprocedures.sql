-- Function: takes a movieID, loops through its reviews and returns the average rating
CREATE OR REPLACE FUNCTION getAvgRating(targetMovieID IN NUMBER)
RETURN NUMBER IS
    calculatedAvg  NUMBER := 0;
    ratingSum      NUMBER := 0;
    ratingCount    NUMBER := 0;

    CURSOR ratingsCursor IS
        SELECT rating FROM reviews WHERE movieID = targetMovieID;
BEGIN
    FOR ratingRow IN ratingsCursor LOOP
        ratingSum   := ratingSum + ratingRow.rating;
        ratingCount := ratingCount + 1;
    END LOOP;

    IF ratingCount = 0 THEN
        RETURN 0;
    ELSE
        calculatedAvg := ratingSum / ratingCount;
        RETURN ROUND(calculatedAvg, 1);
    END IF;
END;
/

-- Procedure: loops through all movies, inserts low rated ones into movie_audit
CREATE OR REPLACE PROCEDURE auditLowRatedMovies(ratingThreshold IN NUMBER) IS
    movieAvg NUMBER := 0;

    CURSOR moviesCursor IS
        SELECT movieID, movieTitle FROM movies;
BEGIN
    -- Delete old audit entries for movies that are no longer low rated
    DELETE FROM movie_audit
    WHERE movieID IN (
        SELECT movieID FROM reviews
        GROUP BY movieID
        HAVING ROUND(AVG(rating), 1) >= ratingThreshold
    );

    -- Loop through every movie
    FOR movieRow IN moviesCursor LOOP
        movieAvg := getAvgRating(movieRow.movieID);

        -- If average rating is below threshold, log it into movie_audit
        IF movieAvg < ratingThreshold AND movieAvg > 0 THEN
            INSERT INTO movie_audit (movieID, movieTitle, avgRating)
            VALUES (movieRow.movieID, movieRow.movieTitle, movieAvg);
        END IF;
    END LOOP;

    COMMIT;
END;
/

-- run the function to test it
SELECT getAvgRating(944368) FROM dual;
-- returns 5.3

-- run the procedure to test it
EXEC auditLowRatedMovies(2.0);
SELECT * FROM movie_audit;