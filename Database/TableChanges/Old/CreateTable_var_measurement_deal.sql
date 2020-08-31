SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[var_measurement_deal]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[var_measurement_deal]
    (
    	[var_measurement_deal_id]  INT IDENTITY(1, 1) NOT NULL,
    	[var_criteria_id]          INT NULL,
    	[deal_id]                  INT NULL,
    	[create_user]              VARCHAR(50) NULL,
    	[create_ts]                DATETIME NULL,
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL
    )
    
    ALTER TABLE dbo.var_measurement_deal ADD CONSTRAINT
    DF_var_measurement_deal_create_ts DEFAULT GETDATE() FOR create_ts

	ALTER TABLE dbo.var_measurement_deal ADD CONSTRAINT
		DF_var_measurement_deal_create_user DEFAULT dbo.FNADBUser() FOR create_user
    
END
ELSE
BEGIN
    PRINT 'Table var_measurement_deal EXISTS'
END

GO



