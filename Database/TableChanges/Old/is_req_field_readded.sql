IF NOT EXISTS ( SELECT COLUMN_NAME
			FROM INFORMATION_SCHEMA.COLUMNS
		    WHERE (   TABLE_NAME = 'user_defined_fields_template'
			   	  AND COLUMN_NAME = 'is_required'
				  )
)
BEGIN
	ALTER TABLE [dbo].[user_defined_fields_template] ADD is_required CHAR(1) DEFAULT 'n'
END
ELSE
	PRINT 'Column already exists'