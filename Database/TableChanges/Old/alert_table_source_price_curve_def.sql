IF COL_LENGTH('source_price_curve_def', 'monte_carlo_model_parameter_id') IS NULL
BEGIN
    ALTER TABLE source_price_curve_def ADD monte_carlo_model_parameter_id INT
END
GO

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND tc.Table_Name = 'monte_carlo_model_parameter'           --table name
                    AND ccu.COLUMN_NAME = 'monte_carlo_model_parameter_id')
ALTER TABLE [dbo].monte_carlo_model_parameter 
	WITH NOCHECK ADD CONSTRAINT [PK_monte_carlo_model_parameter_id] PRIMARY KEY(monte_carlo_model_parameter_id) 


GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND tc.Table_Name = 'source_price_curve_def'           --table name
                    AND ccu.COLUMN_NAME = 'monte_carlo_model_parameter_id'          --column name where FK constaint is to be created
)
ALTER TABLE [dbo].source_price_curve_def 
	WITH NOCHECK ADD CONSTRAINT [FK_monte_carlo_model_parameter_id] FOREIGN KEY(monte_carlo_model_parameter_id)
	REFERENCES [dbo].monte_carlo_model_parameter (monte_carlo_model_parameter_id)
	
GO	
	
                  