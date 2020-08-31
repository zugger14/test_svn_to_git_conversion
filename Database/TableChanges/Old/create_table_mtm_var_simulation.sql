IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[mtm_var_simulation]') AND TYPE IN (N'U'))
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[mtm_var_simulation]
		   ([as_of_date] DATETIME
		   ,[var_criteria_id] INT
		   ,term DATETIME
		   ,source_deal_header_id INT
		   ,mtm_value FLOAT
		   ,mtm_value_C FLOAT
		   ,mtm_value_I FLOAT
		   ,counterparty_id INT
		   ,[create_user] VARCHAR(50)
		   ,[create_ts] DATETIME
		   ,[update_user] VARCHAR(50)
		   ,[update_ts] DATETIME)
		   
	PRINT 'Table Successfully Created'
END	
GO