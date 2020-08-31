SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[eod_process_status]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[eod_process_status]
    (
    	[id]				INT IDENTITY(1, 1) NOT NULL,
    	[master_process_id]	VARCHAR(100) NOT NULL,
    	[process_id]		VARCHAR(100) NOT NULL,
    	[source]			VARCHAR(100) NOT NULL,
    	[status]			VARCHAR(100) NULL,
    	[message]			VARCHAR(MAX) NULL,
    	[create_user]		VARCHAR(50) NULL,
    	[create_ts]			DATETIME NULL,
    	[update_user]		VARCHAR(50) NULL,
    	[update_ts]			DATETIME NULL
    )
    
    
END
ELSE
BEGIN
    PRINT 'Table ''eod_process_status'' already EXISTS'
END

GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_EOD_PROCESS_STATUS]'))
DROP TRIGGER [dbo].[TRGINS_EOD_PROCESS_STATUS]
GO

CREATE TRIGGER [dbo].[TRGINS_EOD_PROCESS_STATUS]
ON [dbo].[eod_process_status]
FOR INSERT
AS
UPDATE eps
	 SET eps.create_user =  dbo.FNADBUser(), eps.create_ts = getdate() 
FROM eod_process_status eps	 
INNER JOIN  inserted eps_d
	ON eps.id = [eps_d].[id]
		AND eps.[source] = eps_d.[source]
		AND eps.[status] = eps_d.[status]
		AND eps.[message] = eps_d.[message]


