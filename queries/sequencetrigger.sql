-- previous tables that I inserted already came with IDs
-- so I am creating a new table called movie_audit...
-- in order to satisfy incremental ID and trigger requirements of the task
CREATE TABLE movie_audit (
    auditID     NUMBER(6)       PRIMARY KEY,
    movieID     NUMBER(6)       NOT NULL,
    movieTitle  VARCHAR2(36)    NOT NULL,
    avgRating   NUMBER(3,1)     NOT NULL CHECK (avgRating BETWEEN 0 AND 10),
    auditDate   DATE            DEFAULT SYSDATE NOT NULL
);

-- sequence for movie_audit
CREATE SEQUENCE auditSeq
    START WITH 1
    INCREMENT BY 1;

-- trigger that fires before every insert on movie_audit
CREATE OR REPLACE TRIGGER auditBeforeInsert
BEFORE INSERT ON movie_audit
FOR EACH ROW
BEGIN
    IF :NEW.auditID IS NULL THEN
        SELECT auditSeq.NEXTVAL INTO :NEW.auditID FROM dual;
    END IF;
END;
/