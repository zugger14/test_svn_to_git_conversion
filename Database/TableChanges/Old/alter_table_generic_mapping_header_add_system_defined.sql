IF COL_LENGTH('generic_mapping_header' ,'system_defined') IS NULL
BEGIN
    ALTER TABLE generic_mapping_header ADD system_defined BIT NULL DEFAULT 0 WITH VALUES
END
ELSE
BEGIN
    PRINT 'Column Already Exists'
END