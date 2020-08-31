

/****** Object:  StoredProcedure [dbo].[spa_rfx_report_paramset_privilege]    Script Date: 02/24/2014 12:07:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rfx_report_paramset_privilege]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rfx_report_paramset_privilege]
GO

/****** Object:  StoredProcedure [dbo].[spa_rfx_report_paramset_privilege]    Script Date: 02/24/2014 12:07:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 8/28/2012
-- Description: CRUD Operations for table report_paramset_privilege
--				Populates list of users and roles aiigned/unassigned and perform insert delete of privileges.
 
-- Params:
-- @flag							: Operation flag			           
-- @listuser						: list of user CSV
-- @listroles						: list of roles CSV
-- @paramset_hash					: paramset hash value
-- @report_paramset_privilege_type	: privilege type for report paramset
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_rfx_report_paramset_privilege]
	@flag				CHAR(1)			= NULL , -- i: INSERT Privileges, u: Select assigned users, r: Select assigned roles, x: List Users, y: List Roles
	@listuser			VARCHAR(1000)	= NULL , -- 
	@listroles			VARCHAR(1000)	= NULL , -- 
	@paramset_hash		VARCHAR(5000)	= NULL ,
	@report_paramset_privilege_type CHAR(1) = NULL --
	--@message			VARCHAR(100)	= NULL	 --
	
	,@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
	
AS
SET NOCOUNT ON
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
BEGIN

	DECLARE @source VARCHAR(50), @sql VARCHAR(MAX), @is_admin INT, @is_owner INT;
	SET @source=dbo.FNADBUser(); --sender
		
	IF @flag = 'i'
	BEGIN
		BEGIN TRY
		SET @sql = '
			DELETE FROM report_paramset_privilege WHERE [paramset_hash] = ''' + @paramset_hash  + ''' 
					AND report_paramset_privilege_type = ''' + CAST(@report_paramset_privilege_type AS VARCHAR(50)) + ''' 
					AND [user_id] IS NOT NULL'
			--PRINT @sql
			EXEC(@sql)
		SET @sql = '
			INSERT INTO report_paramset_privilege
			  (
			    report_paramset_privilege_type,
			    [user_id],
			    [role_id],
			    [paramset_hash]
			  )
			SELECT ''' + cast(@report_paramset_privilege_type AS VARCHAR(50)) + ''',
			       fna.item,
			       NULL,
			       ''' + @paramset_hash + '''
			FROM   dbo.SplitCommaSeperatedValues(''' + @listuser + ''') fna
			       LEFT OUTER JOIN report_paramset_privilege rpp
			            ON  rpp.[user_id] = fna.item
			            AND rpp.[paramset_hash] = ''' + @paramset_hash + '''
			--WHERE rpp.[paramset_hash] IS NULL'
			--PRINT @sql
			EXEC(@sql)	
		END TRY
		BEGIN CATCH 
		--EXEC spa_print ERROR_MESSAGE()
			IF @@ERROR <> 0
				  
				EXEC spa_ErrorHandler -1, 'report_paramset_privilege', 
					'spa_rfx_report_paramset_privilege', 'DB Error', 
					'Failed to assign privileges for Report Manager.', ''
				RETURN
			 
		END CATCH
		
		BEGIN TRY
			DELETE FROM report_paramset_privilege WHERE [paramset_hash] = @paramset_hash 
					AND report_paramset_privilege_type = @report_paramset_privilege_type
					AND [role_id] IS NOT NULL
			INSERT INTO report_paramset_privilege(report_paramset_privilege_type, [user_id], [role_id], [paramset_hash])
			SELECT @report_paramset_privilege_type, NULL, fna.item, @paramset_hash
			FROM dbo.SplitCommaSeperatedValues(@listroles) fna
			LEFT OUTER JOIN report_paramset_privilege rpp ON	rpp.[role_id] = fna.item 
			AND rpp.[paramset_hash] = @paramset_hash
			--WHERE rpp.[paramset_hash] IS NULL
		END TRY
		BEGIN CATCH 
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler -1, 'report_paramset_privilege', 
					'spa_rfx_report_paramset_privilege', 'DB Error', 
					'Failed to assign privileges for Report Manager.', ''
				RETURN
			 
		END CATCH
	
		EXEC spa_ErrorHandler 0, 'Send Message', 
			'spa_rfx_report_paramset_privilege', 'Success', 
			'Privileges assigned successfully for Report Manager.', ''
	END
	ELSE IF @flag = 'u'
	BEGIN
		--print 'Select Assigned USERS'
		SELECT rpp.[user_id] [value], au.user_f_name + ' ' + ISNULL(au.user_m_name + ' ', '') + au.user_l_name [label] 
		FROM report_paramset_privilege rpp
		INNER JOIN application_users au ON au.user_login_id = rpp.[user_id]
		WHERE paramset_hash = @paramset_hash 
			AND report_paramset_privilege_type = @report_paramset_privilege_type
			AND [user_id] IS NOT NULL 
	END
	ELSE IF @flag = 'r'
	BEGIN
		--print 'Select Assigned ROLES'
		SELECT asr.[role_id],asr.[role_name] FROM report_paramset_privilege rpp
			INNER JOIN application_security_role asr ON asr.[role_id]= rpp.[role_id]
		WHERE rpp.paramset_hash=@paramset_hash 
			AND report_paramset_privilege_type = @report_paramset_privilege_type
			AND rpp.[role_id] IS NOT NULL 
	END

	ELSE IF @flag = 'x'
	BEGIN
		--print 'Select USERS Lists not yet assigned for a individual report Manager'
		SELECT au.user_login_id [value], au.user_f_name + ' ' + ISNULL (au.user_m_name + ' ', '') + au.user_l_name [label] 
		FROM application_users au 
		LEFT OUTER JOIN report_paramset_privilege rpp ON au.user_login_id = rpp.[user_id] 
			AND rpp.paramset_hash = @paramset_hash
			AND rpp.report_paramset_privilege_type = @report_paramset_privilege_type
		WHERE  rpp.paramset_hash  IS  NULL
		ORDER BY [label]
	END
	ELSE IF @flag = 'y'
	BEGIN
		--print 'Select ROLES Lists not yet assigned for a individual report Manager'
		SELECT asr.[role_id],asr.[role_name] FROM application_security_role asr
			LEFT OUTER JOIN report_paramset_privilege rpp ON asr.[role_id] = rpp.[role_id] 
			AND rpp.report_paramset_privilege_type = @report_paramset_privilege_type
			AND rpp.paramset_hash = @paramset_hash
		WHERE  rpp.paramset_hash IS NULL
		ORDER BY asr.[role_name]
		
	END
	ELSE IF @flag = 'g'-- for editablegrid
	BEGIN
		
		;WITH CTE AS(
						SELECT rpp.[user_id] [User],
						       asr.role_name [Role],
						       CASE WHEN rp.[name] <> 'Default' THEN rp.[name] ELSE r.name + ' ' + rpg.[name] END [Report Paramset],
						       rp.paramset_hash [Paramset Hash],
						       '' [Action]
						FROM   report_paramset rp 
							   LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rp.paramset_hash
						       LEFT JOIN application_security_role asr ON  asr.role_id = rpp.role_id
						       INNER JOIN dbo.SplitCommaSeperatedValues(@paramset_hash) scsv ON scsv.item = rp.paramset_hash
						       INNER JOIN report_page rpg ON rpg.report_page_id = rp.page_id
						       INNER JOIN report r ON r.report_id = rpg.report_id					            
						
					)
		SELECT [Paramset Hash], [Report Paramset],
				STUFF((SELECT ',' + [User]
						FROM CTE
						WHERE [Paramset Hash] = C.[Paramset Hash]
						FOR XML PATH ('')), 1, 1, '') AS [User], 
				STUFF((SELECT ',' + CAST([Role] AS VARCHAR(MAX))
						FROM CTE
						WHERE [Paramset Hash] = C.[Paramset Hash]
						FOR XML PATH ('')), 1, 1, '') AS [Role],
				MAX([Action]) AS [Action]
		INTO #cte_temp
		FROM CTE C
		GROUP BY [Paramset Hash], [Report Paramset]
		
		set @sql  = 'SELECT [Paramset Hash],
		                    [Report Paramset],
		                    [User],
		                    [Role],
		                    [Action] 
					 ' + @str_batch_table + ' FROM #cte_temp '
		--PRINT @sql
		EXEC(@sql)
		
	END

END
/*******************************************2nd Paging Batch START**********************************************/
 
--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)
 
   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_rfx_report_paramset_privilege', 'Report Manager Paramset Privilege')
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


