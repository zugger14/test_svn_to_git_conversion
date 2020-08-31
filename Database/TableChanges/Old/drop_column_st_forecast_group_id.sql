IF EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'short_term_forecast_mapping'           --table name
                    AND ccu.COLUMN_NAME = 'st_forecast_group_id'          --column name where FK constaint is to be created
)
BEGIN
	DECLARE @cons VARCHAR(100) = NULL
	SELECT @cons = tc.Constraint_name
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'short_term_forecast_mapping'           --table name
                    AND ccu.COLUMN_NAME = 'st_forecast_group_id'
    IF @cons IS NOT NULL
    BEGIN
    	EXEC('ALTER TABLE short_term_forecast_mapping DROP CONSTRAINT ' + @cons)
    END                
END

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'short_term_forecast_mapping' AND column_name = 'st_forecast_group_id')
	ALTER TABLE short_term_forecast_mapping DROP COLUMN st_forecast_group_id

GO

IF COL_LENGTH('short_term_forecast_mapping', 'st_forecast_group_header_id') IS NULL
BEGIN
    ALTER TABLE short_term_forecast_mapping ADD st_forecast_group_header_id INT
END
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'short_term_forecast_mapping'           --table name
                    AND ccu.COLUMN_NAME = 'st_forecast_group_header_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].short_term_forecast_mapping 
	WITH NOCHECK ADD CONSTRAINT [FK_st_forecast_group_header_id] FOREIGN KEY(st_forecast_group_header_id)
	REFERENCES [dbo].st_forecast_group_header (st_forecast_group_header_id)
	
GO