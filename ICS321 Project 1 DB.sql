DROP DATABASE IF EXISTS racing;
CREATE DATABASE racing;
USE racing;

-- =========================================================
-- Tables
-- =========================================================
CREATE TABLE Stable (
                        stableId   VARCHAR(15) NOT NULL,
                        stableName VARCHAR(30),
                        location   VARCHAR(30),
                        colors     VARCHAR(20),
                        PRIMARY KEY (stableId)
);

CREATE TABLE Horse (
                       horseId      VARCHAR(15) NOT NULL,
                       horseName    VARCHAR(15) NOT NULL,
                       age          INT,
                       gender       CHAR,
                       registration INT NOT NULL,
                       stableId     VARCHAR(30) NOT NULL,
                       FOREIGN KEY (stableId) REFERENCES Stable(stableId),
                       PRIMARY KEY (horseId)
);

CREATE TABLE Owner (
                       ownerId VARCHAR(15) NOT NULL,
                       lname   VARCHAR(15),
                       fname   VARCHAR(15),
                       PRIMARY KEY (ownerId)
);

CREATE TABLE Owns (
                      ownerId VARCHAR(15) NOT NULL,
                      horseId VARCHAR(15) NOT NULL,
                      PRIMARY KEY (ownerId, horseId),
                      FOREIGN KEY (ownerId) REFERENCES Owner(ownerId),
                      FOREIGN KEY (horseId) REFERENCES Horse(horseId)
);

CREATE TABLE Trainer (
                         trainerId VARCHAR(15) NOT NULL,
                         lname     VARCHAR(30),
                         fname     VARCHAR(30),
                         stableId  VARCHAR(30),
                         PRIMARY KEY (trainerId),
                         FOREIGN KEY (stableId) REFERENCES Stable(stableId)
);

CREATE TABLE Track (
                       trackName VARCHAR(30) NOT NULL,
                       location  VARCHAR(30),
                       length    INT,
                       PRIMARY KEY (trackName)
);

CREATE TABLE Race (
                      raceId    VARCHAR(15) NOT NULL,
                      raceName  VARCHAR(30),
                      trackName VARCHAR(30),
                      raceDate  DATE,
                      raceTime  TIME,
                      PRIMARY KEY (raceId),
                      FOREIGN KEY (trackName) REFERENCES Track(trackName)
);

CREATE TABLE RaceResults (
                             raceId  VARCHAR(15) NOT NULL,
                             horseId VARCHAR(15) NOT NULL,
                             results VARCHAR(15),
                             prize   FLOAT(10,2),
  PRIMARY KEY (raceId, horseId),
  FOREIGN KEY (raceId) REFERENCES Race(raceId),
  FOREIGN KEY (horseId) REFERENCES Horse(horseId)
);

-- =========================================================
-- Audit table for deleted horses + trigger
-- =========================================================
CREATE TABLE IF NOT EXISTS Old_Info (
                                        horseId VARCHAR(15) NOT NULL,
    horseName VARCHAR(15) NOT NULL,
    age INT,
    gender CHAR,
    registration INT NOT NULL,
    stableId VARCHAR(30) NOT NULL,
    deletion_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (horseId, deletion_date)
    );

DELIMITER //
CREATE TRIGGER trg_backup_horse
    BEFORE DELETE ON Horse
    FOR EACH ROW
BEGIN
    INSERT INTO Old_Info (horseId, horseName, age, gender, registration, stableId)
    VALUES (OLD.horseId, OLD.horseName, OLD.age, OLD.gender, OLD.registration, OLD.stableId);
END//
DELIMITER ;

-- =========================================================
-- Seed data
-- =========================================================
INSERT INTO Stable VALUES ('stable1', 'Zobair Farm', 'Riyadh', 'orange');
INSERT INTO Stable VALUES ('stable2', 'Zayed Farm', 'Dubai', 'kiwi');
INSERT INTO Stable VALUES ('stable3', 'Zahra Farm', 'Jeddah', 'cinnamon');
INSERT INTO Stable VALUES ('stable4', 'Sunny Stables', 'Jubail', 'lemon');
INSERT INTO Stable VALUES ('stable5', 'Ajman Stables', 'Ajman', 'lemon');
INSERT INTO Stable VALUES ('stable6', 'Dubai Stables', 'Dubai', 'bright blue');

INSERT INTO Horse VALUES ('horse1', 'Warrior', 2, 'C', 11111, 'stable1');
INSERT INTO Horse VALUES ('horse2', 'Conquerer', 2, 'F', 22222, 'stable6');
INSERT INTO Horse VALUES ('horse3', 'Dove of Peace', 3, 'C', 33333, 'stable1');
INSERT INTO Horse VALUES ('horse4', 'Ever Faster', 3, 'F', 44444, 'stable3');
INSERT INTO Horse VALUES ('horse5', 'Slow Winner', 2, 'C', 55555, 'stable3');
INSERT INTO Horse VALUES ('horse6', 'Windrunner', 2, 'F', 66666, 'stable2');
INSERT INTO Horse VALUES ('horse7', 'Catapult', 4, 'M', 77777, 'stable6');
INSERT INTO Horse VALUES ('horse8', 'Flying Force', 2, 'C', 88888, 'stable4');
INSERT INTO Horse VALUES ('horse9', 'Laggard', 2, 'F', 99999, 'stable4');
INSERT INTO Horse VALUES ('horse10', 'Formula One', 6, 'G', 10101, 'stable2');
INSERT INTO Horse VALUES ('horse11', 'Frisky Frolic', 3, 'C', 11011, 'stable4');
INSERT INTO Horse VALUES ('horse12', 'Fantastic', 3, 'F', 12121, 'stable2');
INSERT INTO Horse VALUES ('horse13', 'Midnight', 2, 'C', 13131, 'stable3');
INSERT INTO Horse VALUES ('horse14', 'Running Wild', 4, 'S', 14141, 'stable2');
INSERT INTO Horse VALUES ('horse15', 'FastOffMyFeet', 3, 'C', 15151, 'stable1');
INSERT INTO Horse VALUES ('horse16', 'Slow Poke', 2, 'C', 16161, 'stable3');
INSERT INTO Horse VALUES ('horse17', 'Slinger', 3, 'F', 17171, 'stable2');
INSERT INTO Horse VALUES ('horse18', 'Sublime', 5, 'M', 18181, 'stable6');
INSERT INTO Horse VALUES ('horse19', 'Front Runner', 4, 'G', 19191, 'stable4');
INSERT INTO Horse VALUES ('horse20', 'Night', 3, 'C', 20200, 'stable1');
INSERT INTO Horse VALUES ('horse21', 'Negative', 3, 'F', 21210, 'stable3');
INSERT INTO Horse VALUES ('horse22', 'Lightening', 2, 'C', 22220, 'stable6');
INSERT INTO Horse VALUES ('horse23', 'Lazy Loser', 4, 'G', 23230, 'stable1');
INSERT INTO Horse VALUES ('horse24', 'Leaping Lizard', 2, 'C', 24240, 'stable1');
INSERT INTO Horse VALUES ('horse25', 'Beautiful Brown', 3, 'F', 25250, 'stable6');
INSERT INTO Horse VALUES ('horse26', 'Sick Winner', 5, 'M', 26260, 'stable2');

INSERT INTO Owner VALUES('owner1', 'Saeed', 'Ahmed');
INSERT INTO Owner VALUES('owner2', 'Mohammed', 'Khalid');
INSERT INTO Owner VALUES('owner3', 'Mohammed', 'Faisal');
INSERT INTO Owner VALUES('owner4', 'Fahd', 'Abdul Rahman');
INSERT INTO Owner VALUES('owner5', 'Nasr', '');
INSERT INTO Owner VALUES('owner6', 'Mohammed', 'Sheikh');
INSERT INTO Owner VALUES('owner7', 'Abed', 'Ahmed');
INSERT INTO Owner VALUES('owner8', 'Mashour', '');
INSERT INTO Owner VALUES('owner9', 'Said', 'Sheikh');
INSERT INTO Owner VALUES('owner10', 'Faisal', 'Khan');
INSERT INTO Owner VALUES('owner11', 'Jabr', 'Mohammed');
INSERT INTO Owner VALUES('owner12', 'Faleh', 'Mahmood');
INSERT INTO Owner VALUES('owner13', 'Yahya', 'Mohammed');
INSERT INTO Owner VALUES('owner14', 'Sulaiman', '');
INSERT INTO Owner VALUES('owner15', 'Saeed', 'Ali');
INSERT INTO Owner VALUES('owner16', 'Ahmed', 'Faisal');
INSERT INTO Owner VALUES('owner17', 'Saud', 'Mohammed');
INSERT INTO Owner VALUES('owner18', 'Nazir', 'Mohammed');
INSERT INTO Owner VALUES('owner19', 'Saleh', 'Fahd');
INSERT INTO Owner VALUES('owner20', 'Mohammed', 'Naeem');

INSERT INTO Owns VALUES('owner14', 'horse1');
INSERT INTO Owns VALUES('owner3', 'horse2');
INSERT INTO Owns VALUES('owner2', 'horse3');
INSERT INTO Owns VALUES('owner2', 'horse4');
INSERT INTO Owns VALUES('owner1', 'horse5');
INSERT INTO Owns VALUES('owner12', 'horse5');
INSERT INTO Owns VALUES('owner14', 'horse5');
INSERT INTO Owns VALUES('owner1', 'horse6');
INSERT INTO Owns VALUES('owner5', 'horse6');
INSERT INTO Owns VALUES('owner20', 'horse7');
INSERT INTO Owns VALUES('owner19', 'horse8');
INSERT INTO Owns VALUES('owner2', 'horse9');
INSERT INTO Owns VALUES('owner18', 'horse10');
INSERT INTO Owns VALUES('owner3', 'horse10');
INSERT INTO Owns VALUES('owner4', 'horse11');
INSERT INTO Owns VALUES('owner16', 'horse12');
INSERT INTO Owns VALUES('owner17', 'horse13');
INSERT INTO Owns VALUES('owner15', 'horse14');
INSERT INTO Owns VALUES('owner15', 'horse15');
INSERT INTO Owns VALUES('owner20', 'horse16');
INSERT INTO Owns VALUES('owner4', 'horse17');
INSERT INTO Owns VALUES('owner6', 'horse19');
INSERT INTO Owns VALUES('owner12', 'horse20');
INSERT INTO Owns VALUES('owner7', 'horse21');
INSERT INTO Owns VALUES('owner7', 'horse22');
INSERT INTO Owns VALUES('owner10', 'horse23');
INSERT INTO Owns VALUES('owner12', 'horse24');
INSERT INTO Owns VALUES('owner13', 'horse25');
INSERT INTO Owns VALUES('owner2', 'horse26');
INSERT INTO Owns VALUES('owner9', 'horse23');
INSERT INTO Owns VALUES('owner8', 'horse18');

INSERT INTO Trainer VALUES('trainer1', 'Mohammed', 'Fahd', 'stable2');
INSERT INTO Trainer VALUES('trainer2', 'Saleh', 'Saeed', 'stable1');
INSERT INTO Trainer VALUES('trainer3', 'Ali', 'Raad', 'stable4');
INSERT INTO Trainer VALUES('trainer4', 'Sayed', 'Wasim', 'stable3');
INSERT INTO Trainer VALUES('trainer5', 'Ahmed', 'Ali', 'stable3');
INSERT INTO Trainer VALUES('trainer6', 'Faisal', 'Salah', 'stable5');
INSERT INTO Trainer VALUES('trainer7', 'Hamid', 'Ahmed', 'stable6');
INSERT INTO Trainer VALUES('trainer8', 'Khalid', 'Ahmed', 'stable6');

INSERT INTO Track VALUES('Doha', 'QT', 20);
INSERT INTO Track VALUES('Jubail', 'SA', 15);
INSERT INTO Track VALUES('Yanbu', 'SA', 18);
INSERT INTO Track VALUES('Dubai', 'UE', 17);
INSERT INTO Track VALUES('Jeddah', 'SA', 19);
INSERT INTO Track VALUES('Bahrain', 'BH', 18);
INSERT INTO Track VALUES('Sharjah', 'UE', 20);
INSERT INTO Track VALUES('Riyadh', 'SA', 22);
INSERT INTO Track VALUES('Dhahran', 'SA', 20);

-- Fixed race inserts (no line breaks in date)
INSERT INTO Race VALUES('race1',  'Kings Cup',            'Riyadh',  '2007-05-03','14:00');
INSERT INTO Race VALUES('race2',  '2-year-old fillies',   'Doha',    '2007-05-03','13:00');
INSERT INTO Race VALUES('race3',  '2-year-old colts',     'Doha',    '2007-05-03','13:30');
INSERT INTO Race VALUES('race4',  'Handicap',             'Doha',    '2007-05-03','12:00');
INSERT INTO Race VALUES('race5',  'Claiming Stake',       'Sharjah', '2007-05-03','12:30');
INSERT INTO Race VALUES('race6',  '3-year-old fillies',   'Jubail',  '2007-06-02','12:30');
INSERT INTO Race VALUES('race7',  'Handicap',             'Jubail',  '2007-06-02','09:30');
INSERT INTO Race VALUES('race8',  '2-year-old colts',     'Riyadh',  '2007-06-02','10:30');
INSERT INTO Race VALUES('race9',  '2-year-old fillies',   'Jubail',  '2007-06-02','11:30');
INSERT INTO Race VALUES('race10', 'Claiming Stake',       'Sharjah', '2007-06-02','12:30');
INSERT INTO Race VALUES('race11', '3-year-old fillies',   'Dubai',   '2007-04-02','10:30');
INSERT INTO Race VALUES('race12', 'Handicap',             'Yanbu',   '2007-05-03','11:30');
INSERT INTO Race VALUES('race13', '3-year-old fillies',   'Yanbu',   '2007-05-03','11:00');
INSERT INTO Race VALUES('race14', 'Handicap',             'Dhahran', '2007-05-10','10:00');
INSERT INTO Race VALUES('race15', '3-year-old colts',     'Dubai',   '2007-05-12','15:00');
INSERT INTO Race VALUES('race16', 'Claiming Stake',       'Yanbu',   '2007-05-20','14:30');
INSERT INTO Race VALUES('race17', 'Handicap',             'Doha',    '2007-05-20','13:00');
INSERT INTO Race VALUES('race18', '3-year-old fillies',   'Sharjah', '2007-05-21','08:00');
INSERT INTO Race VALUES('race19', '2-year-old colts',     'Dhahran', '2007-05-25','11:00');
INSERT INTO Race VALUES('race20', 'Claiming Stake',       'Jeddah',  '2007-05-25','08:30');
INSERT INTO Race VALUES('race21', '3-year-old colts',     'Riyadh',  '2007-03-19','14:30');
INSERT INTO Race VALUES('race22', 'Handicap',             'Dhahran', '2007-03-27','15:00');
INSERT INTO Race VALUES('race23', '3-year-old fillies',   'Jeddah',  '2007-03-28','09:30');
INSERT INTO Race VALUES('race24', '3-year-old colts',     'Jubail',  '2007-03-28','13:30');
INSERT INTO Race VALUES('race25', 'Claiming Stake',       'Jeddah',  '2007-03-29','10:00');
INSERT INTO Race VALUES('race26', '3-year-old colts',     'Yanbu',   '2007-03-30','12:30');
INSERT INTO Race VALUES('race27', 'Handicap',             'Dubai',   '2007-04-03','14:00');
INSERT INTO Race VALUES('race28', '2-year-old fillies',   'Jeddah',  '2007-04-04','08:30');
INSERT INTO Race VALUES('race29', '3-year-old colts',     'Bahrain', '2007-04-05','08:00');
INSERT INTO Race VALUES('race30', 'Claiming Stake',       'Dhahran', '2007-04-08','09:30');
INSERT INTO Race VALUES('race31', 'Handicap',             'Dhahran', '2007-04-08','09:00');
INSERT INTO Race VALUES('race32', '2-year-old colts',     'Jubail',  '2007-04-09','11:00');
INSERT INTO Race VALUES('race33', 'Claiming Stake',       'Bahrain', '2007-04-10','13:00');
INSERT INTO Race VALUES('race34', '3-year-old colts',     'Dubai',   '2007-05-12','12:00');
INSERT INTO Race VALUES('race35', 'Handicap',             'Dubai',   '2007-04-13','10:30');
INSERT INTO Race VALUES('race36', '3-year-old colts',     'Jeddah',  '2007-05-03','14:30');

INSERT INTO RaceResults VALUES('race1','horse3','first',500000);
INSERT INTO RaceResults VALUES('race1','horse11','second',200000);
INSERT INTO RaceResults VALUES('race1','horse15','third',500000);
INSERT INTO RaceResults VALUES('race2','horse6','first',100000);
INSERT INTO RaceResults VALUES('race2','horse2','second',50000);
INSERT INTO RaceResults VALUES('race2','horse20','third',20000);
INSERT INTO RaceResults VALUES('race3','horse22','first',70000);
INSERT INTO RaceResults VALUES('race3','horse5','second',50000);
INSERT INTO RaceResults VALUES('race3','horse1','third',20000);
INSERT INTO RaceResults VALUES('race4','horse19','first',50000);
INSERT INTO RaceResults VALUES('race4','horse18','no show',0);
INSERT INTO RaceResults VALUES('race4','horse14','no show',0);
INSERT INTO RaceResults VALUES('race6','horse25','first',5000);
INSERT INTO RaceResults VALUES('race7','horse7','second',2000);
INSERT INTO RaceResults VALUES('race9','horse11','last',0);
INSERT INTO RaceResults VALUES('race10','horse18','fourth',500);
INSERT INTO RaceResults VALUES('race11','horse12','first',50000);
INSERT INTO RaceResults VALUES('race11','horse17','second',25000);
INSERT INTO RaceResults VALUES('race11','horse21','fourth',10000);
INSERT INTO RaceResults VALUES('race12','horse14','first',6000);
INSERT INTO RaceResults VALUES('race12','horse18','second',5000);
INSERT INTO RaceResults VALUES('race13','horse25','first',100000);
INSERT INTO RaceResults VALUES('race13','horse4','second',50000);
INSERT INTO RaceResults VALUES('race13','horse12','third',30000);
INSERT INTO RaceResults VALUES('race14','horse23','first',25000);
INSERT INTO RaceResults VALUES('race14','horse26','second',20000);
INSERT INTO RaceResults VALUES('race15','horse11','second',10000);
INSERT INTO RaceResults VALUES('race15','horse24','third',8000);
INSERT INTO RaceResults VALUES('race16','horse10','second',5000);
INSERT INTO RaceResults VALUES('race16','horse14','third',4000);
INSERT INTO RaceResults VALUES('race17','horse7','first',15000);
INSERT INTO RaceResults VALUES('race17','horse10','second',1100);
INSERT INTO RaceResults VALUES('race18','horse6','first',70000);
INSERT INTO RaceResults VALUES('race19','horse22','first',1000000);
INSERT INTO RaceResults VALUES('race19','horse1','second',80000);
INSERT INTO RaceResults VALUES('race19','horse8','third',60000);
INSERT INTO RaceResults VALUES('race20','horse23','first',1500);
INSERT INTO RaceResults VALUES('race20','horse14','second',1000);
INSERT INTO RaceResults VALUES('race20','horse26','third',800);
INSERT INTO RaceResults VALUES('race20','horse10','fourth',500);
INSERT INTO RaceResults VALUES('race21','horse24','first',70000);
INSERT INTO RaceResults VALUES('race21','horse15','second',55000);
INSERT INTO RaceResults VALUES('race21','horse3','third',40000);
INSERT INTO RaceResults VALUES('race22','horse18','first',10000);
INSERT INTO RaceResults VALUES('race22','horse19','second',8000);
INSERT INTO RaceResults VALUES('race23','horse25','first',150000);
INSERT INTO RaceResults VALUES('race24','horse7','first',10000);
INSERT INTO RaceResults VALUES('race25','horse10','second',8000);
INSERT INTO RaceResults VALUES('race25','horse20','fourth',2000);
INSERT INTO RaceResults VALUES('race26','horse24','first',8000);
INSERT INTO RaceResults VALUES('race26','horse20','fourth',2000);
INSERT INTO RaceResults VALUES('race27','horse18','first',70000);
INSERT INTO RaceResults VALUES('race27','horse23','third',40000);
INSERT INTO RaceResults VALUES('race28','horse25','first',90000);
INSERT INTO RaceResults VALUES('race29','horse15','first',80000);
INSERT INTO RaceResults VALUES('race29','horse3','second',65000);
INSERT INTO RaceResults VALUES('race29','horse24','third',50000);
INSERT INTO RaceResults VALUES('race30','horse14','second',1500);
INSERT INTO RaceResults VALUES('race30','horse10','fourth',500);
INSERT INTO RaceResults VALUES('race31','horse7','first',90000);
INSERT INTO RaceResults VALUES('race31','horse26','second',70000);
INSERT INTO RaceResults VALUES('race31','horse23','third',50000);
INSERT INTO RaceResults VALUES('race31','horse10','fourth',30000);
INSERT INTO RaceResults VALUES('race32','horse22','first',150000);
INSERT INTO RaceResults VALUES('race32','horse13','second',125000);
INSERT INTO RaceResults VALUES('race32','horse16','third',100000);
INSERT INTO RaceResults VALUES('race33','horse23','second',1700);
INSERT INTO RaceResults VALUES('race33','horse26','third',1200);
INSERT INTO RaceResults VALUES('race34','horse11','first',50000);
INSERT INTO RaceResults VALUES('race34','horse15','second',30000);
INSERT INTO RaceResults VALUES('race35','horse7','first',45000);
INSERT INTO RaceResults VALUES('race35','horse19','second',25000);
INSERT INTO RaceResults VALUES('race36','horse11','first',100000);
INSERT INTO RaceResults VALUES('race36','horse15','second',80000);
INSERT INTO RaceResults VALUES('race36','horse20','third',50000);

-- =========================================================
-- Stored Procedure: DeleteOwner (corrected logic)
-- =========================================================
DROP PROCEDURE IF EXISTS DeleteOwner;

DELIMITER //
CREATE PROCEDURE DeleteOwner(IN owner_id VARCHAR(15))
BEGIN
    DECLARE exit_handler BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET exit_handler = TRUE;

START TRANSACTION;

-- Check if owner is also a trainer
IF EXISTS (SELECT 1 FROM Trainer WHERE trainerId = owner_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete owner who is also a trainer';
END IF;

    -- Backup horses that will be deleted to Old_Info (ONLY exclusively owned horses)
INSERT INTO Old_Info (horseId, horseName, age, gender, registration, stableId)
SELECT DISTINCT h.horseId, h.horseName, h.age, h.gender, h.registration, h.stableId
FROM Horse h
         JOIN Owns o ON h.horseId = o.horseId
WHERE o.ownerId = owner_id
  AND NOT EXISTS (
    SELECT 1 FROM Owns o2
    WHERE o2.horseId = h.horseId
      AND o2.ownerId != owner_id
);

-- Delete from RaceResults for horses owned ONLY by this owner
DELETE rr FROM RaceResults rr
    WHERE rr.horseId IN (
        SELECT o.horseId FROM Owns o
        WHERE o.ownerId = owner_id
        AND NOT EXISTS (
            SELECT 1 FROM Owns o2
            WHERE o2.horseId = o.horseId
            AND o2.ownerId != owner_id
        )
    );

    -- Delete ownership relationships for this owner
DELETE FROM Owns WHERE ownerId = owner_id;

-- Delete horses owned ONLY by this owner (no other owners)
DELETE h FROM Horse h
    WHERE NOT EXISTS (
        SELECT 1 FROM Owns o WHERE o.horseId = h.horseId
    )
    AND h.horseId IN (
        SELECT horseId FROM Owns WHERE ownerId = owner_id
    );

    -- Finally delete the owner
DELETE FROM Owner WHERE ownerId = owner_id;

IF exit_handler THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error deleting owner and related information';
ELSE
        COMMIT;
END IF;
END//
DELIMITER ;