SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[forecast_error_list]', N'U') IS  NULL
BEGIN
 CREATE TABLE [dbo].[forecast_error_list]
  (
	 ID INT IDENTITY(1,1)
	,status_id INT
	,process_id VARCHAR(200)
	,[RMSE] VARCHAR(200)
	,[MAPE] VARCHAR(200) 
	,create_user VARCHAR(200) DEFAULT dbo.FNADBUser()
	,create_ts DATETIME DEFAULT GETDATE()
	,update_user VARCHAR(200)
	,update_time DATETIME 
  )
END
ELSE
BEGIN
    PRINT 'Table forecast_result EXISTS'
END
GO

--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_forecast_error_list]'))
    DROP TRIGGER  [dbo].[TRGUPD_forecast_error_list]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_forecast_error_list]
ON [dbo].[forecast_error_list]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[forecast_error_list]
        SET update_user = dbo.FNADBUser(), update_time = GETDATE()
        FROM [dbo].[forecast_error_list] fr
        INNER JOIN DELETED d ON d.id = fr.id
    END
END
GO

