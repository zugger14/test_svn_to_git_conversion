-- export_location
IF COL_LENGTH('report_paramset', 'export_location') IS NULL
BEGIN
    ALTER TABLE report_paramset ADD export_location VARCHAR(500)
END
ELSE 
	PRINT 'Column already exists : export_location.'
GO

-- output_file_format
IF COL_LENGTH('report_paramset', 'output_file_format') IS NULL
BEGIN
    ALTER TABLE report_paramset ADD output_file_format VARCHAR(6)
END
ELSE 
	PRINT 'Column already exists : output_file_format.'
GO

-- delimiter
IF COL_LENGTH('report_paramset', 'delimiter') IS NULL
BEGIN
    ALTER TABLE report_paramset ADD delimiter VARCHAR(10)
END
ELSE 
	PRINT 'Column already exists : delimiter.'
GO

-- xml_format
IF COL_LENGTH('report_paramset', 'xml_format') IS NULL
BEGIN
    ALTER TABLE report_paramset ADD xml_format INT
END
ELSE 
	PRINT 'Column already exists : xml_format.'
GO

--report_header
IF COL_LENGTH('report_paramset', 'report_header') IS NULL
BEGIN
    ALTER TABLE report_paramset ADD report_header CHAR(1) DEFAULT 'n'
END
ELSE 
	PRINT 'Column already exists : report_header.'
GO

-- Add compress_file field with default value 'n'
IF COL_LENGTH('report_paramset', 'compress_file') IS NULL
BEGIN
    ALTER TABLE report_paramset ADD compress_file CHAR(1) DEFAULT 'n'
END
ELSE 
	PRINT 'Column already exists : compress_file.'
GO

-- export_report_name
IF COL_LENGTH('report_paramset', 'export_report_name') IS NULL
BEGIN
    ALTER TABLE report_paramset ADD export_report_name VARCHAR(500)
END
ELSE 
	PRINT 'Column already exists : export_report_name.'
GO





