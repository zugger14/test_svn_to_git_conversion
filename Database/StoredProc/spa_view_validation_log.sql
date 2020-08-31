IF OBJECT_ID(N'spa_view_validation_log' ,N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_view_validation_log]
GO 

CREATE PROC [dbo].[spa_view_validation_log]
	@report_name				VARCHAR(500) = 'batch_report',
	@batch_process_id		VARCHAR(100) = NULL,
	@flag					CHAR(1) = 's'
AS
DECLARE @user_login_id		VARCHAR(50),
        @temptablename		VARCHAR(200)

SET @user_login_id = dbo.FNADBUser()
SET @temptablename = dbo.FNAProcessTableName(@report_name, @user_login_id, @batch_process_id)

IF @flag = 's'
BEGIN
    EXEC ('SELECT * FROM ' + @temptablename)
END
