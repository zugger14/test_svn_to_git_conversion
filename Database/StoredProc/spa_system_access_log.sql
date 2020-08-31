--/*
IF OBJECT_ID('[dbo].[spa_system_access_log]','p') IS NOT NULL 
	DROP PROCEDURE [dbo].[spa_system_access_log]
GO 

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
--This proc insert log when client logged in...

CREATE PROC [dbo].[spa_system_access_log]	
@flag AS CHAR(1),					
@user_login_id_var VARCHAR(150) = NULL,
@system_address VARCHAR(50) = NULL,
@system_name VARCHAR(50) = NULL,
@status VARCHAR(500) = NULL,
@date_from VARCHAR(20) = NULL,
@date_to VARCHAR(20) = NULL,
@invalid_user CHAR(1) = 'n',
@batch_process_id VARCHAR(250) = NULL,
@batch_report_param VARCHAR(500) = NULL,
@enable_paging INT = 0,
@page_size INT = NULL,
@page_no INT = NULL,
@user_login VARCHAR(50) = NULL,
@cookie_hash VARCHAR(100) = NULL
AS 

/* -- Debug Code
DECLARE
@flag AS CHAR(1)  = 's',					
@user_login_id VARCHAR(50) = NULL,
@system_address VARCHAR(50) = NULL,
@system_name VARCHAR(50) = NULL,
@status VARCHAR(500) = NULL,
@date_from VARCHAR(20) = '2017-02-01',
@date_to VARCHAR(20) = '2018-02-22',
@invalid_user CHAR(1) = 'n',
@batch_process_id VARCHAR(250) = 'BD7E82AB_032C_4953_881D_DCA95BB2F624',
@batch_report_param VARCHAR(500) = NULL,
@enable_paging INT = 1,
@page_size INT = 100,
@page_no INT = 1,
@user_login VARCHAR(50) = NULL

*/

SET NOCOUNT ON

DECLARE @Sql_Select VARCHAR(5000)
DECLARE @sql VARCHAR(MAX)

/*******************************************1st Paging Batch START**********************************************/
DECLARE @str_batch_table  VARCHAR(8000)
DECLARE @user_login_id    VARCHAR(50)
DECLARE @sql_paging       VARCHAR(8000)
DECLARE @is_batch         BIT

SET @str_batch_table = ''
SET @user_login_id = dbo.FNADBUser() 
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 

IF @is_batch = 1
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

IF @enable_paging = 1 --paging processing
BEGIN
	IF @batch_process_id IS NULL
		SET @batch_process_id = dbo.FNAGetNewID()

	SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

	--retrieve data from paging table instead of main table
	IF @page_no IS NOT NULL 
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
		EXEC (@sql_paging) 
		RETURN 
	END
END
/*******************************************1st Paging Batch END**********************************************/

IF @flag='i'
BEGIN
	INSERT INTO system_access_log (user_login_id, access_timestamp, system_address, system_name, [status], cookie_hash)
	VALUES(@user_login_id_var, GETDATE(), @system_address, @system_name, @status, @cookie_hash)
END

ELSE IF @flag = 's' AND @invalid_user = 'n'
BEGIN
	SET @Sql_Select = '
					SELECT user_login_id AS	''Login ID'', 
						dbo.FNADateTimeFormat(access_timestamp, 1) AS ''Time Stamp'', 
						system_address AS ''Access IP'', system_name AS ''Access From'', 
						status AS Status ' + @str_batch_table + ' 
					FROM system_access_log'
	IF (@date_from IS NOT NULL AND @date_to IS NOT NULL) OR @user_login_id_var IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' WHERE '
	IF @user_login_id_var IS NOT NULL
	BEGIN
		DECLARE @user_email_add VARCHAR(150)
		SELECT @user_email_add = user_emal_add
		FROM application_users
		WHERE user_login_id = @user_login_id_var

		SET @Sql_Select = @Sql_Select + ' ( user_login_id = ''' + @user_login_id_var + ''' OR user_login_id = ''' + @user_email_add + ''') ' 
	END
	IF @date_from IS NOT NULL AND @date_to IS NOT NULL
	BEGIN
		IF @user_login_id_var IS NOT NULL
			SET @Sql_Select = @Sql_Select + ' AND '

		SET @Sql_Select = @Sql_Select + ' access_timestamp BETWEEN CONVERT(DATETIME, ''' + @date_from + ''', 102) AND CONVERT(DATETIME, ''' + @date_to +  ' 23:59' + ''', 102)'
	END	
	SET @Sql_Select = @Sql_Select + ' ORDER BY system_access_log_id DESC '
	--PRINT @SQL_select
	EXEC(@SQL_select)
END

ELSE IF @flag='s' and @invalid_user='y'
BEGIN
	SET @Sql_Select = '
					SELECT user_login_id as ''Login ID'', 
						dbo.FNADateTimeFormat(access_timestamp, 1) AS ''Time Stamp'', 
						system_address AS ''Access IP'', 
						system_name AS ''Access From'', 
						status AS Status '+ @str_batch_table + ' 
						FROM system_access_log '
	--SET @Sql_Select = @Sql_Select + ' where  user_login_id not in(Select user_login_id from application_users) and status <>''Success'' '
	SET @Sql_Select = @Sql_Select + ' WHERE status <> ''Success'' '
	
	IF @date_from IS NOT NULL AND  @date_to IS NOT NULL
	BEGIN	
		--SET @Sql_Select = @Sql_Select + ' and  dbo.FNAConvertTZAwareDateFormat(access_timestamp,1) BETWEEN  CONVERT(DATETIME, ''' + @date_from + ''', 102) AND CONVERT(DATETIME, ''' + @date_to +  ' 23:59' + ''', 102)'
		SET @Sql_Select = @Sql_Select + ' AND  access_timestamp BETWEEN  CONVERT(DATETIME, ''' + @date_from + ''', 102) AND CONVERT(DATETIME, ''' + @date_to +  ' 23:59' + ''', 102)'
	END	
	
	SET @Sql_Select = @Sql_Select + ' ORDER BY system_access_log_id DESC '
	--PRINT @SQL_select
	EXEC(@SQL_select)
END

-- Flag used in system access log report for displaying combo
ELSE IF @flag = 'g'
BEGIN
	IF EXISTS (SELECT 1 FROM trm_session WHERE create_user = dbo.FNADBUser() AND is_active = 1 AND session_data LIKE '%"trmcloud"%')
	BEGIN
		SELECT user_login_id, (user_l_name + ', ' + user_f_name + ' ' + ISNULL(user_m_name, '') + ' (' + user_emal_add + ')') AS [user_name] FROM application_users
	END
	ELSE
	BEGIN
		SELECT user_login_id, (user_l_name + ', ' + user_f_name + ' ' + ISNULL(user_m_name, '') + ' (' + user_login_id + ')') AS [user_name] FROM application_users
	END
END

IF @is_batch = 1
BEGIN
	SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
	EXEC(@str_batch_table)                   

	SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_system_access_log', 'System Access Log Report')         
	EXEC(@str_batch_table)        
	RETURN
END

IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
	SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	EXEC (@sql_paging)
END

GO