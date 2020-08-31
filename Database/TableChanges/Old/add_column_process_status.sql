IF COL_LENGTH('dedesignation_criteria_result', 'process_status') IS NULL
BEGIN
    ALTER TABLE dedesignation_criteria_result ADD process_status CHAR(1)
END
GO