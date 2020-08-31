
IF COL_LENGTH('dedesignation_criteria_result', 'dedesignate_type') IS NULL
BEGIN
    ALTER TABLE dedesignation_criteria_result ADD dedesignate_type int
END
GO
