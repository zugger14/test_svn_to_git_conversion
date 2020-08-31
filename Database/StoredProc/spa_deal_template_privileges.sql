IF OBJECT_ID(N'[dbo].[spa_deal_template_privileges]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_deal_template_privileges
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2012/06/15
-- Description: Deal template privileges

-- Params:
-- @flag CHAR(1) - Operation flag
-- @deal_template_id INT - deal template id,
-- @role_ids VARCHAR(MAX) - role ids ,
-- @login_ids VARCHAR(MAX) - login ids
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_deal_template_privileges
    @flag CHAR(1),
    @deal_template_id VARCHAR(MAX) = NULL,
    @role_ids VARCHAR(MAX) = NULL,
    @login_ids VARCHAR(MAX) = NULL,
    
    @batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
	
AS
/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch BIT
 
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

DECLARE @sql VARCHAR(MAX)

IF @flag = 's' --select those user who have not been assigned 
BEGIN
    SELECT au.user_login_id FROM application_users au 
	LEFT OUTER JOIN deal_template_privilages dtp ON au.user_login_id = dtp.[user_id] 
		AND dtp.deal_template_id = @deal_template_id
	WHERE  dtp.deal_template_id IS NULL
END
ELSE IF @flag = 'u' --assigned users
BEGIN
	SELECT [user_id] FROM deal_template_privilages WHERE deal_template_id = @deal_template_id AND [user_id] IS NOT NULL
END
IF @flag = 'r' --'Select Assigned ROLES'
BEGIN
	SELECT asr.[role_id],asr.[role_name] FROM deal_template_privilages dtp
	INNER JOIN application_security_role asr ON asr.[role_id]= dtp.[role_id]
	WHERE dtp.deal_template_id = @deal_template_id 
		AND dtp.[role_id] IS NOT NULL 
END
IF @flag = 'y'--'Select ROLES Lists not yet assigned for a individual report writer'
BEGIN
	SELECT asr.[role_id],asr.[role_name] 
	FROM application_security_role asr
	LEFT OUTER JOIN deal_template_privilages dtp ON asr.[role_id] = dtp.[role_id] 
		AND dtp.deal_template_id = @deal_template_id
	WHERE  dtp.deal_template_id IS NULL
	
END
ELSE IF @flag = 'i' --insert role and user role
BEGIN
	DELETE FROM deal_template_privilages WHERE deal_template_id = @deal_template_id
	--insert role
	INSERT INTO deal_template_privilages(role_id, deal_template_id)
	SELECT item, @deal_template_id AS deal_template_id  FROM dbo.FNASplit(@role_ids, ',')
	
	--insert users
	INSERT INTO deal_template_privilages([user_id], deal_template_id)
	SELECT item, @deal_template_id AS deal_template_id  FROM dbo.FNASplit(@login_ids, ',')
	
	EXEC spa_ErrorHandler 0
		, 'Send Message'
		, 'spa_deal_template_privileges'
		, 'Success'
		, 'Privileges successfully assigned for Deal Template.'
		, ''
END
ELSE IF @flag = 'g'-- for editablegrid
BEGIN
	
	;WITH CTE AS(
	                SELECT sdht.template_id,
	                       sdht.template_name [Template Name],
	                       [user_id] AS [User],
	                       [user_id] AS [User ID],
	                       asr.role_id role_id,
	                       asr.role_name AS [Role],
	                       '' AS [Action]
	                FROM   source_deal_header_template sdht
	                       LEFT JOIN deal_template_privilages dtp ON  dtp.deal_template_id = sdht.template_id
	                       LEFT JOIN application_security_role asr ON  asr.role_id = dtp.role_id
	                       INNER JOIN dbo.FNASplit(@deal_template_id, ',') deal_template_id ON  deal_template_id.item = sdht.template_id
	            )
	SELECT template_id AS [Template ID], [Template Name], 
			STUFF((SELECT ',' + [User]
					FROM CTE
					WHERE template_id = C.template_id
					FOR XML PATH ('')), 1, 1, '') AS [User], 
			STUFF((SELECT ',' + CAST(role_id AS VARCHAR(50))
					FROM CTE
					WHERE template_id = C.template_id
					FOR XML PATH ('')), 1, 1, '') AS [Role ID],
			STUFF((SELECT  ',' + [User ID] 
					FROM CTE
					WHERE template_id = C.template_id
					FOR XML PATH ('')), 1, 1, '') AS [User ID],
			STUFF((SELECT ',' + CAST([Role] AS VARCHAR(MAX))
					FROM CTE
					WHERE template_id = C.template_id
					FOR XML PATH ('')), 1, 1, '') AS [Role],
			MAX([Action]) AS [Action]
	INTO #cte_temp
	FROM CTE C
	GROUP BY template_id, [Template Name]
	
	--SELECT [Template ID], [Template Name], [User], [Role ID], [User ID] AS [User ID], [Role], [Action] FROM #cte_temp 
	SET @sql = 'SELECT [Template ID], [Template Name], [User], [Role ID], [User ID], [Role], [Action] '
			+ @str_batch_table + ' FROM #cte_temp'

EXEC spa_print @sql
EXEC(@sql)	
END
ELSE IF @flag = 'x' --get role names
BEGIN
	DECLARE @role_names VARCHAR(MAX)
	SELECT @role_names = STUFF(
	           (
	               SELECT ':::' + CAST(role_name AS VARCHAR(MAX)) 
	               FROM   application_security_role asr
	                      INNER JOIN dbo.FNASplit(@role_ids, ',') f
	                           ON  f.item = asr.role_id
	                               FOR XML PATH('')
	           ), 1, 3, '')	
	SELECT @role_names							  
END
ELSE IF @flag = 'z'-- for report
BEGIN
	;WITH REPORT_CTE AS(
	                       SELECT sdht.template_id,
	                              sdht.template_name [Template Name],
	                              [user_id] AS [User],
	                              [user_id] AS [User ID],
	                              asr.role_id role_id,
	                              asr.role_name AS [Role]
	                       FROM   source_deal_header_template sdht
	                              LEFT JOIN deal_template_privilages dtp ON  dtp.deal_template_id = sdht.template_id
	                              LEFT JOIN application_security_role asr ON  asr.role_id = dtp.role_id
	                              INNER JOIN dbo.FNASplit(@deal_template_id, ',') deal_template_id ON  deal_template_id.item = sdht.template_id
	                   )
	SELECT template_id AS [Template ID], [Template Name], 
			STUFF((SELECT ',' + [User]
					FROM REPORT_CTE
					WHERE template_id = RC.template_id
					FOR XML PATH ('')), 1, 1, '') AS [User], 
			STUFF((SELECT ',' + CAST(role_id AS VARCHAR(50))
					FROM REPORT_CTE
					WHERE template_id = RC.template_id
					FOR XML PATH ('')), 1, 1, '') AS [Role ID],
			STUFF((SELECT ',' + [User ID] 
					FROM REPORT_CTE
					WHERE template_id = RC.template_id
					FOR XML PATH ('')), 1, 1, '') AS [User ID],
			STUFF((SELECT ',' + CAST([Role] AS VARCHAR(MAX)) 
					FROM REPORT_CTE
					WHERE template_id = RC.template_id
					FOR XML PATH ('')), 1, 1, '') AS [Role]
	FROM REPORT_CTE RC
	GROUP BY template_id, [Template Name]
END

/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_deal_template_privileges', 'Deal Template Privileges')
   EXEC(@sql_paging)  
 
   RETURN
END
 
--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO
