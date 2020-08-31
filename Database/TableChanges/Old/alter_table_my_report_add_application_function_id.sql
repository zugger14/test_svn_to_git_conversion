IF COL_LENGTH('my_report', 'application_function_id') IS NULL
BEGIN
    ALTER TABLE my_report ADD application_function_id INT
END