SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[forecast_result]', N'U') IS  NULL
BEGIN
 CREATE TABLE [dbo].[forecast_result]
  (
	 ID INT IDENTITY(1,1)
	,status_id INT
	,process_id VARCHAR(200)
	,forecasted_data_id VARCHAR(200)
	,forecasted_data_table VARCHAR(200)
	,Year VARCHAR(50)
	,Month VARCHAR(50)
	,Day VARCHAR(50)
	,maturity VARCHAR(50)
	,predicition_data VARCHAR(400)
	,test_data VARCHAR(400)
	,is_approved CHAR(1)  DEFAULT 0 
	,create_user VARCHAR(200) DEFAULT dbo.FNADBUser()
	,create_ts DATETIME DEFAULT GETDATE()
	,update_user VARCHAR(200)
	,update_time DATETIME 
	,hour VARCHAR(5)
  )
END
ELSE
BEGIN
    PRINT 'Table forecast_result EXISTS'
END
GO

--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_forecast_result]'))
    DROP TRIGGER [dbo].[TRGUPD_forecast_result]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_forecast_result]
ON [dbo].[forecast_result]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[forecast_result]
        SET update_user = dbo.FNADBUser(), update_time = GETDATE()
        FROM [dbo].[forecast_result] fr
        INNER JOIN DELETED d ON d.id = fr.id
    END
END
GO

