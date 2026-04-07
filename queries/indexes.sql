-- STEP 1: EXECUTION PLAN WITHOUT INDEXES
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(USER);
EXPLAIN PLAN FOR
    SELECT m.movieTitle, d.directorName, COUNT(r.reviewID) AS totalReviews
    FROM movies m
    JOIN directors d ON m.directorID = d.directorID
    JOIN reviews r ON m.movieID = r.movieID
    WHERE d.directorName = 'Nicole Mendez'
    GROUP BY m.movieTitle, d.directorName;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- STEP 2: CREATE INDEXES
CREATE INDEX idxReviewsMovieId   ON reviews(movieID);
CREATE INDEX idxReviewsUserId    ON reviews(userID);
CREATE INDEX idxMoviesDirectorId ON movies(directorID);
CREATE INDEX idxRolesActorId     ON roles(actorID);
CREATE INDEX idxDirectorsName    ON directors(directorName);


-- STEP 3: EXECUTION PLAN WITH INDEXES
EXEC DBMS_STATS.GATHER_SCHEMA_STATS(USER);
EXPLAIN PLAN FOR
    SELECT m.movieTitle, d.directorName, COUNT(r.reviewID) AS totalReviews
    FROM movies m
    JOIN directors d ON m.directorID = d.directorID
    JOIN reviews r ON m.movieID = r.movieID
    WHERE d.directorName = 'Nicole Mendez'
    GROUP BY m.movieTitle, d.directorName;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);