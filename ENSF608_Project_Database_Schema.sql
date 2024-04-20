/*
Create entire Cirque du Soliel database schema:

Written by:
Ehsan Liaqat
Robby Parmar
Dillon Pullano
Yaad Sra

*/
drop schema if exists ensf608project;
create database ensf608project;
use ensf608project;

drop database if exists cirque;
create database cirque;
use cirque;

CREATE TABLE VENUE (
	VenueID INT AUTO_INCREMENT PRIMARY KEY,
    Date DATE NOT NULL,
    StreetAddress VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    ProvinceState VARCHAR(50) NOT NULL,
    VenueName VARCHAR(100) NOT NULL,
    Capacity INT NOT NULL,
    TransitAccess TINYINT NOT NULL
);

CREATE TABLE SHOWS (
	Year INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Producer VARCHAR(50) NOT NULL,
    Sponsor VARCHAR(50) NOT NULL,
    PRIMARY KEY (Year, Name)
);

CREATE TABLE PERFORMER (
	PerformerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Citizenship VARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    UnderstudyID INT,
    ShowYear INT NOT NULL,
    ShowName VARCHAR(50) NOT NULL,
    FOREIGN KEY (ShowYear, ShowName) REFERENCES SHOWS(Year, Name)
);

CREATE TABLE MUSICIAN (
	PerformerID INT NOT NULL,
    FOREIGN KEY (PerformerID) REFERENCES PERFORMER(PerformerID) ON DELETE CASCADE
);

CREATE TABLE INSTRUMENTS_PLAYED (
	PerformerID INT NOT NULL,
    Instrument VARCHAR(50) NOT NULL,
    FOREIGN KEY (PerformerID) REFERENCES MUSICIAN(PerformerID) ON DELETE CASCADE
);

CREATE TABLE AERIALIST (
	PerformerID INT NOT NULL,
    Sport VARCHAR(50) NOT NULL,
    FOREIGN KEY (PerformerID) REFERENCES PERFORMER(PerformerID) ON DELETE CASCADE
);

CREATE TABLE EQUIPMENT (
	PerformerID INT NOT NULL,
    Equipment VARCHAR(100) NOT NULL,
    FOREIGN KEY (PerformerID) REFERENCES AERIALIST(PerformerID) ON DELETE CASCADE
);

CREATE TABLE ENTERTAINER (
	PerformerID INT NOT NULL,
    MainAct VARCHAR(100) NOT NULL,
    FOREIGN KEY (PerformerID) REFERENCES PERFORMER(PerformerID) ON DELETE CASCADE
);

CREATE TABLE EMERGENCY_CONTACT (
	PerformerID INT NOT NULL,
    EmergencyNum VARCHAR(15) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Relationship VARCHAR(50) NOT NULL,
    FOREIGN KEY (PerformerID) REFERENCES PERFORMER(PerformerID) ON DELETE CASCADE
);

CREATE TABLE SHOW_HOSTINGS (
	VenueID INT NOT NULL,
    Year INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    FOREIGN KEY (VenueID) REFERENCES VENUE(VenueID),
    FOREIGN KEY (Year, Name) REFERENCES SHOWS(Year, Name) ON DELETE CASCADE
);

CREATE TABLE MEDICATIONS (
	PerformerID INT NOT NULL,
    Medication VARCHAR(100) NOT NULL,
    FOREIGN KEY (PerformerID) REFERENCES PERFORMER(PerformerID) ON DELETE CASCADE
);

CREATE TABLE DIETARY_INFORMATION (
	PerformerID INT NOT NULL,
    DietaryInformation VARCHAR(100),
    FOREIGN KEY (PerformerID) REFERENCES PERFORMER(PerformerID) ON DELETE CASCADE
);

-- Trigger definition for cascading PERFORMER deletion to specialization types:
DELIMITER //
CREATE TRIGGER delete_performer_trigger
AFTER DELETE ON PERFORMER
FOR EACH ROW
BEGIN
	-- Declare and assign value to performer_id to be deleted from other tables:
    DECLARE performer_id INT;
    SET performer_id = OLD.PerformerID;
    
    -- Delete PERFORMER from other specialization tables if it exists:
    DELETE FROM MUSICIAN WHERE PerformerID = performer_id;
    DELETE FROM AERIALIST WHERE PerformerID = performer_id;
    DELETE FROM ENTERTAINER WHERE PerformerID = performer_id;
    
    -- Delete from EMERGENCY_CONTACT, MEDICATIONS, and DIETARY_INFORMATION if it exists:
    DELETE FROM EMERGENCY_CONTACT WHERE PerformerID = performer_id;
    DELETE FROM MEDICATIONS WHERE PerformerID = performer_id;
    DELETE FROM DIETARY_INFORMATION WHERE PerformerID = performer_id;
    
END;
//
DELIMITER ;


-- Trigger definition for cascading MUSICIAN deletion to INSTRUMENTS_PLAYED:
DELIMITER //
CREATE TRIGGER delete_musician_trigger
AFTER DELETE ON MUSICIAN
FOR EACH ROW
BEGIN
	-- Declare and assign value to performer_id, and delete from other tables:
    DECLARE performer_id INT;
    SET performer_id = OLD.PerformerID;
    
    DELETE FROM INSTRUMENTS_PLAYED WHERE PerformerID = performer_id;
    
END;
//
DELIMITER ;


-- Trigger definition for cascading AERIALIST deletion to EQUIPMENT:
DELIMITER //
CREATE TRIGGER delete_aerialist_trigger
AFTER DELETE ON AERIALIST
FOR EACH ROW
BEGIN
	-- Declare and assign value to performer_id, and delete from other tables:
    DECLARE performer_id INT;
    SET performer_id = OLD.PerformerID;
    
    DELETE FROM EQUIPMENT WHERE PerformerID = performer_id;
    
END;
//
DELIMITER ;


-- Trigger definition for cascading VENUE deletion to SHOW_HOSTINGS:
DELIMITER //
CREATE TRIGGER delete_venue_trigger
AFTER DELETE ON VENUE
FOR EACH ROW
BEGIN
	-- Declare and assign value to venue_id, and delete from other tables:
    DECLARE venue_id INT;
    SET venue_id = OLD.VenueID;
    
    DELETE FROM SHOW_HOSTINGS WHERE VenueID = venue_id;
    
END;
//
DELIMITER ;


-- Trigger definition for cascading SHOWS deletion to SHOW_HOSTINGS:
DELIMITER //
CREATE TRIGGER delete_shows_trigger
AFTER DELETE ON SHOWS
FOR EACH ROW
BEGIN
	-- Declare and assign value to year & name, and delete from other tables:
    DECLARE year INT;
    DECLARE name VARCHAR(100);
    
    SET year = OLD.Year;
    SET name = OLD.Name;
    
    DELETE FROM SHOW_HOSTINGS WHERE Year = year AND Name = name;
    
END;
//
DELIMITER ;


-- Trigger definition for cascading SHOWS deletion to SHOW_HOSTINGS:
DELIMITER //
CREATE TRIGGER check_relationship_trigger
BEFORE UPDATE ON EMERGENCY_CONTACT
FOR EACH ROW
BEGIN
	-- Declare flag for tracking if change is valid:
    DECLARE valid_relationship TINYINT;
    
    SET valid_relationship = 0;
    
    IF NEW.Relationship IN ('Mother', 'Father', 'Sister', 'Brother', 'Aunt', 'Uncle', 'Spouse') THEN
		SET valid_relationship = 1;
	END IF;
    
    IF valid_relationship = 0 THEN
		SIGNAL SQLSTATE '42000'
        SET MESSAGE_TEXT = 'Please enter a family member. Cannot add friend as emergency contact!';
	END IF;
END;
//
DELIMITER ;


/*
Populate entire Cirque du Soliel database schema
*/
use cirque;

INSERT INTO VENUE (Date, StreetAddress, City, ProvinceState, VenueName, Capacity, TransitAccess)
VALUES
	('2023-12-23', '123 Cedar Street', 'Red Deer', 'AB', 'Festival Hall', 2000, 1),
    ('2024-02-16', '555 Saddledome Rise', 'Calgary', 'AB', 'Scotiabank Saddledome', 19000, 1);
    
INSERT INTO SHOWS (Year, Name, Sponsor, Producer)
VALUES
	(2023, 'Cirque du Prairies', 'Entertainment 365', 'Farmers Association'),
    (2024, 'Cirque du Mountain View', 'Entertainment 365', 'Big 4 Motors');
    
INSERT INTO PERFORMER (FirstName, LastName, Citizenship, BirthDate, UnderstudyID, ShowYear, ShowName)
VALUES
	('Sarah', 'Smith', 'Canada', '1993-04-17', NULL, 2023, 'Cirque du Prairies'),
    ('Felix', 'Wagner', 'Germany', '1989-07-05', NULL, 2023, 'Cirque du Prairies'),
    ('Paul', 'Grenner', 'Canada', '1997-03-26', NULL, 2023, 'Cirque du Prairies'),
    ('Emily', 'Rodrigues', 'Spain', '1990-10-12', 5, 2024, 'Cirque du Mountain View'),
    ('Lucas', 'Zhang', 'United States', '1995-02-28', NULL, 2024, 'Cirque du Mountain View'),
    ('Sophie', 'Lefebvre', 'Canada', '1998-09-18', NULL, 2024, 'Cirque du Mountain View'),
    ('Connor', 'Lee', 'Canada', '1990-05-30', 8, 2024, 'Cirque du Mountain View'),
    ('Nick', 'Stern', 'United States', '1996-05-22', NULL, 2024, 'Cirque du Mountain View'),
    ('Juan', 'Vasquez', 'Venezuela', '1993-04-08', NULL, 2024, 'Cirque du Mountain View');
    
INSERT INTO MUSICIAN (PerformerID)
VALUES
	(1),
    (4),
    (5);
    
INSERT INTO INSTRUMENTS_PLAYED (PerformerID, Instrument)
VALUES
	(1, 'Oboe'),
    (1, 'Clarinet'),
    (1, 'Jazz Flute'),
    (4, 'Didgeridoo'),
    (4, 'Jazz Flute'),
    (5, 'Didgeridoo');
    
INSERT INTO AERIALIST (PerformerID, Sport)
VALUES
	(2, 'Trapeze'),
    (6, 'Aerial Hoop');
    
INSERT INTO EQUIPMENT (PerformerID, Equipment)
VALUES
	(2, 'Hook Sling'),
    (2, 'Balance Bar'),
    (2, 'Safety Net'),
    (6, 'Hook Sling'),
    (6, 'Ring Hoop');
    
INSERT INTO ENTERTAINER (PerformerID, MainAct)
VALUES
	(3, 'Juggler'),
    (7, 'Fire Performer'),
    (8, 'Fire Performer'),
    (9, 'Stilt Walker');
    
INSERT INTO EMERGENCY_CONTACT (PerformerID, EmergencyNum, FirstName, LastName, Relationship)
VALUES
	('1', '1(403)-766-4336', 'Kara', 'Smith', 'Mother'),
    ('2', '1(040)-355-8077', 'Elias', 'Wagner', 'Father'),
    ('3', '1(706)-555-0945', 'Sarah', 'Grenner', 'Spouse'),
    ('4', '1(403)-987-6573', 'Leah', 'Miller', 'Sister'),
    ('5', '1(403)-777-1487', 'Max', 'Hoffman', 'Brother'),
    ('6', '1(706)-890-4495', 'Karen', 'Tims', 'Aunt'),
    ('7', '1(613)-968-9644', 'Olivia', 'Lee', 'Mother'),
    ('8', '1(902)-984-5479', 'Paul', 'Stern', 'Brother'),
    ('9', '1(514)-533-6635', 'Maria', 'Vasquez', 'Spouse');
    
INSERT INTO SHOW_HOSTINGS (VenueID, Year, Name)
VALUES
	(1, 2023, 'Cirque du Prairies'),
    (2, 2024, 'Cirque du Mountain View');
    
INSERT INTO MEDICATIONS (PerformerID, Medication)
VALUES
	(1, 'Lisinopril'),
    (1, 'Claritin'),
    (3, 'Claritin'),
    (4, 'Ibuprofen'),
    (5, 'Lisinopril'),
    (5, 'Claritin'),
    (7, 'Ibuprofen'),
    (7, 'Lisinopril'),
    (7, 'Claritin');
    
INSERT INTO DIETARY_INFORMATION (PerformerID, DietaryInformation)
VALUES
	(1, 'Vegetarian'),
    (1, 'Nut Allergy'),
    (3, 'Vegan'),
    (3, 'Gluten Intolerant'),
    (4, 'Vegetarian'),
    (5, 'Nut Allergy'),
    (8, 'Vegetarian'),
    (9, 'Nut Allergy');
  