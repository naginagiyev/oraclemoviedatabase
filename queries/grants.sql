-- Grants for assignment

-- TABLES
GRANT SELECT ON directors TO lkpeter;
GRANT SELECT ON actors TO lkpeter;
GRANT SELECT ON users TO lkpeter;
GRANT SELECT ON movies TO lkpeter;
GRANT SELECT ON roles TO lkpeter;
GRANT SELECT ON reviews TO lkpeter;
GRANT SELECT ON movie_audit TO lkpeter;

-- VIEWS
GRANT SELECT ON viewMovieDetails TO lkpeter;
GRANT SELECT ON viewPopularMovies TO lkpeter;

-- SEQUENCES
GRANT SELECT ON auditSeq TO lkpeter;

-- PL/SQL (Function / Procedure)
GRANT EXECUTE ON getAvgRating TO lkpeter;
GRANT EXECUTE ON auditLowRatedMovies TO lkpeter;