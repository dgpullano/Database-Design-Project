/*
Queries File:

Written by:
Ehsan Liaqat
Robby Parmar
Dillon Pullano
Yaad Sra

*/
-- QUERY 1
SELECT *
FROM VENUE;

-- QUERY 2
SELECT *
FROM PERFORMER;

-- QUERY 3
SELECT *
FROM PERFORMER
ORDER BY LastName ASC;

-- QUERY 4
SELECT FirstName, LastName, PerformerID
FROM PERFORMER
WHERE PerformerID IN (
SELECT PerformerID
FROM Emergency_Contact
WHERE Relationship = 'Mother'
-- WHERE Relationship = 'Brother'
);

-- QUERY 5
DROP VIEW IF EXISTS PER_DIET_MED;
CREATE VIEW PER_DIET_MED AS
SELECT EMERGENCY_CONTACT.*, Dietary_Information.DietaryInformation
FROM EMERGENCY_CONTACT 
JOIN Dietary_Information ON EMERGENCY_CONTACT.PerformerID = Dietary_Information.PerformerID;
SELECT *
FROM PER_DIET_MED;

-- QUERY 6
-- When an emergency contact relationship is updated, 'check_relationship_trigger' is triggered and makes sure that only family members are used.
UPDATE EMERGENCY_CONTACT 
SET EmergencyNum = '1(403)-766-4336',
	FirstName = 'Jim',
    LastName = 'Harris',
    Relationship = 'Brother'
WHERE PerformerID = 9;


-- QUERY 7
-- Deleting a performer record and confirming it a trigger that logs this deletion
DELETE FROM PERFORMER WHERE PerformerID = 3;

