/****** Object:  StoredProcedure [dbo].[spa_insert_alert_output_status]    Script Date: 10/18/2012 14:05:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_insert_alert_output_status]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_insert_alert_output_status]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- This procedure inserts in alert_output_status table and all users
CREATE PROCEDURE [dbo].[spa_insert_alert_output_status](
    @sql_id           INT,
    @process_id       VARCHAR(150),
    @message          VARCHAR(1000),
    @trader_user_id   VARCHAR(50),
    @current_user_id  VARCHAR(50)
)
AS
BEGIN 
	INSERT INTO [alert_output_status]
           ([alert_sql_id]
           ,[process_id]
           ,[published]
           ,[message]
           ,[trader_user_id]
           ,[current_user_id]
           ,[create_ts]
           ,[create_user])
     SELECT @sql_id,
            @process_id,
            'n',
            @message,
            @trader_user_id,
            @current_user_id,
            GETDATE(),
            dbo.FNADBUser()
END