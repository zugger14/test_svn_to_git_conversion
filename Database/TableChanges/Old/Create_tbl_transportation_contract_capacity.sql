SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[transportation_contract_capacity]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[transportation_contract_capacity]
    (
    	[ID]                       INT IDENTITY(1, 1) NOT NULL,
    	[contract_id]              INT NOT NULL,
    	[effective_date]		   VARCHAR(100) NULL,
    	[field_id]			       INT NULL,
    	[value]                    FLOAT NULL,
    	[uom_id]                   INT NULL,
    	[create_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME NULL DEFAULT GETDATE(),
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL	
    ) 
END
ELSE
BEGIN
    PRINT 'Table transportation_contract_capacity already EXISTS.'
END

GO
