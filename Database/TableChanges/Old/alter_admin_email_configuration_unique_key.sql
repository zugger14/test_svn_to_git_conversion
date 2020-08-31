DECLARE @constraint_name VARCHAR(100), @sql VARCHAR(100)

SELECT @constraint_name = ccu.CONSTRAINT_NAME 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON ccu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
WHERE ccu.TABLE_NAME = 'admin_email_configuration' AND ccu.COLUMN_NAME = 'template_name' AND CONSTRAINT_TYPE = 'UNIQUE'

SET @sql = 'ALTER TABLE admin_email_configuration DROP CONSTRAINT ' + @constraint_name
EXEC(@sql)

IF NOT EXISTS (
    SELECT 1
    FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
    WHERE  TABLE_NAME              = 'admin_email_configuration'
            AND CONSTRAINT_TYPE     = 'UNIQUE'
            AND CONSTRAINT_NAME     = 'UQ_admin_email_configuration'
)
BEGIN
	ALTER TABLE admin_email_configuration ADD CONSTRAINT UQ_admin_email_configuration UNIQUE(template_name, module_type)
END
ELSE
BEGIN
 	PRINT 'Already created Unique contriant for template_name and module_type.'
END

