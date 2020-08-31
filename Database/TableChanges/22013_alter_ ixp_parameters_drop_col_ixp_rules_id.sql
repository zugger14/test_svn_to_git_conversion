DECLARE @Constraint_name VARCHAR(500)
SELECT @Constraint_name = tc.Constraint_name
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'ixp_parameters'
                    AND ccu.COLUMN_NAME = 'ixp_rules_id'
IF @Constraint_name IS NOT NULL
BEGIN
	EXEC ('ALTER TABLE dbo.ixp_parameters DROP CONSTRAINT '+@Constraint_name+';')
END
 
GO 

IF COL_LENGTH('ixp_parameters', 'ixp_rules_id') IS NOT NULL 
BEGIN
	ALTER TABLE ixp_parameters
	DROP COLUMN ixp_rules_id
END
GO
