IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[mtm_gmar_simulation_whatif]') AND TYPE IN (N'U'))
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[mtm_gmar_simulation_whatif]
		   ([as_of_date] DATETIME
		   ,[whatif_criteria_id] INT
		   ,term DATETIME
		   ,source_deal_header_id INT
		   ,cash_flow FLOAT
		   ,cash_flow_c FLOAT
		   ,cash_flow_i FLOAT
		   ,counterparty_id INT
		   ,[create_user] VARCHAR(50)
		   ,[create_ts] DATETIME)
	PRINT 'Table Successfully Created'
END	
GO