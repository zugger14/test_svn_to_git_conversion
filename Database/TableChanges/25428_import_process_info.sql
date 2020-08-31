IF OBJECT_ID(N'dbo.import_process_info', N'U') IS NULL 
BEGIN
	CREATE TABLE dbo.import_process_info(
	/**
		Used to collect import process information at runtime.

		Columns
		process_id : Unique import process identifier.
		ixp_rule_id : Rule ID.
		translate_language : Specify if source column header needs language translation or not.
		import_file_name : Source file used to import data.

	*/
		process_id				NVARCHAR(100)
		, ixp_rule_id			INT
		, translate_language	BIT DEFAULT 0
		, import_file_name		NVARCHAR(1000)
	)
END
ELSE
BEGIN
    PRINT 'Table ''import_process_info'' already EXISTS'
END