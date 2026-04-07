-- create directors table
CREATE TABLE directors (
  directorID   NUMBER(6)     PRIMARY KEY,
  directorName VARCHAR2(24)  NOT NULL,
  birthYear    NUMBER(4)     NOT NULL
);

-- create actor table
CREATE TABLE actors (
  actorID      NUMBER(6)     PRIMARY KEY,
  actorName    VARCHAR2(28)  NOT NULL,
  birthYear    NUMBER(4)     NOT NULL,
  nationality  VARCHAR2(16)  NOT NULL
);

-- create user table
CREATE TABLE users (
  userID           NUMBER(6)     PRIMARY KEY,
  username         VARCHAR2(24)  NOT NULL,
  country          VARCHAR2(52)  NOT NULL,
  registrationDate DATE          NOT NULL
);

-- create movies table
CREATE TABLE movies (
  movieID     NUMBER(6)     PRIMARY KEY,
  movieTitle  VARCHAR2(36)  NOT NULL,
  releaseYear NUMBER(4)     NOT NULL,
  genre       VARCHAR2(12)  NOT NULL,
  directorID  NUMBER(6)     NOT NULL REFERENCES directors(directorID),
  duration    NUMBER(3)     NOT NULL CHECK (duration > 0)
);

-- create roles table
CREATE TABLE roles (
  movieID   NUMBER(6)      NOT NULL REFERENCES movies(movieID),
  actorID   NUMBER(6)      NOT NULL REFERENCES actors(actorID),
  roleName  VARCHAR2(28)   NOT NULL,
  CONSTRAINT pkRoles PRIMARY KEY (movieID, actorID)
);

-- create reviews table
CREATE TABLE reviews (
    reviewID    NUMBER(6)   NOT NULL,
    movieID     NUMBER(6)   NOT NULL REFERENCES movies(movieID),
    userID      NUMBER(6)   NOT NULL REFERENCES users(userID),
    rating      NUMBER(2)   NOT NULL CHECK (rating BETWEEN 0 AND 10),
    reviewDate  DATE        NOT NULL
)
-- partition the reviews table into 5 parts based on review date
PARTITION BY RANGE (reviewDate) (
    PARTITION reviews_2005_2010 VALUES LESS THAN (TO_DATE('2010-01-01','YYYY-MM-DD')),
    PARTITION reviews_2010_2015 VALUES LESS THAN (TO_DATE('2015-01-01','YYYY-MM-DD')),
    PARTITION reviews_2015_2020 VALUES LESS THAN (TO_DATE('2020-01-01','YYYY-MM-DD')),
    PARTITION reviews_2020_2025 VALUES LESS THAN (TO_DATE('2025-01-01','YYYY-MM-DD')),
    PARTITION reviews_2025_now  VALUES LESS THAN (MAXVALUE)
);

ALTER TABLE reviews ADD CONSTRAINT reviewsPk PRIMARY KEY (reviewID, reviewDate) USING INDEX LOCAL;