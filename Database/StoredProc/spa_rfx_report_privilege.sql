GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rfx_report_privilege]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rfx_report_privilege]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 8/28/2012
-- Description: CRUD Operations for table report_privilege
--				Populates list of users and roles aiigned/unassigned and perform insert delete of privileges.
 
-- Params:
-- @flag					: Operation flag			           
-- @listuser				: list of user CSV
-- @listroles				: list of roles CSV
-- @report_hash				: report hash value
-- @report_privilege_type	: privilege type for report
-- ===========================================================================================================

CREATE PROCEDURE dbo.spa_rfx_report_privilege
	@flag					CHAR(1)			= NULL , -- i: INSERT Privileges, u: Select assigned users, r: Select assigned roles, x: List Users, y: List Roles
	@listuser				VARCHAR(1000)	= NULL ,  
	@listroles				VARCHAR(1000)	= NULL ,  
	@report_hash			VARCHAR(5000)	= NULL ,
	@report_privilege_type	CHAR(1)			= 'e' ,
	
	@batch_process_id		VARCHAR(250)	= NULL,
	@batch_report_param		VARCHAR(500)	= NULL, 
	@enable_paging			INT				= 0,  --'1' = enable, '0' = disable
	@page_size				INT				= NULL,
	@page_no				INT				= NULL   
	
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

	DECLARE @source VARCHAR(50), @is_admin INT, @is_owner INT, @sql VARCHAR(MAX);
	SET @source=dbo.FNADBUser(); --sender
		
	IF @flag = 'i'
	BEGIN
		BEGIN TRY
			DELETE FROM report_privilege WHERE [report_hash] = @report_hash
				AND report_privilege_type = @report_privilege_type
				AND [user_id] IS NOT NULL
			INSERT INTO report_privilege([user_id], [role_id], [report_hash], report_privilege_type)
			SELECT fna.item,
			       NULL,
			       @report_hash,
			       @report_privilege_type
			FROM   dbo.SplitCommaSeperatedValues(@listuser) fna
			LEFT OUTER JOIN report_privilege rp ON  rp.[user_id] = fna.item
			       AND rp.[report_hash] = @report_hash
			       AND rp.report_privilege_type = @report_privilege_type
			--WHERE  rp.[report_hash] IS NULL	
		END TRY
		BEGIN CATCH 
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler -1, 'report_privilege', 
					'spa_rfx_report_privilege', 'DB Error', 
					'Failed to assign privileges for Report Manager.', ''
				RETURN			 
		END CATCH
		
		BEGIN TRY
			DELETE FROM report_privilege WHERE [report_hash] = @report_hash 
				AND report_privilege_type = @report_privilege_type
				AND [role_id] IS NOT NULL
			INSERT INTO report_privilege([user_id], [role_id], [report_hash], report_privilege_type)
			SELECT NULL, 
				   fna.item, 
				   @report_hash,
				   @report_privilege_type
			FROM dbo.SplitCommaSeperatedValues(@listroles) fna
			LEFT OUTER JOIN report_privilege rp ON	rp.[role_id] = fna.item 
					AND rp.[report_hash] = @report_hash
					AND rp.report_privilege_type = @report_privilege_type
			--WHERE rp.[report_hash] IS NULL
		END TRY
		BEGIN CATCH 
			IF @@ERROR <> 0
				EXEC spa_ErrorHandler -1, 'report_privilege', 
					'spa_rfx_report_privilege', 'DB Error', 
					'Failed to assign privileges for Report Manager.', ''
				RETURN			 
		END CATCH
		
		EXEC spa_ErrorHandler 0, 'Send Message', 
			'spa_rfx_report_privilege', 'Success', 
			'Privileges assigned successfully for Report Manager.', ''
	END
	ELSE IF @flag = 'u'
	BEGIN
		--print 'Select Assigned USERS'
		SELECT rp.[user_id] [value], au.user_f_name + ' ' + ISNULL(au.user_m_name + ' ', '') + au.user_l_name [label] 
		FROM report_privilege rp
		INNER JOIN application_users au ON au.user_login_id = rp.[user_id] 
		WHERE report_hash = @report_hash 
			AND [user_id] IS NOT NULL 
			AND rp.report_privilege_type = @report_privilege_type
	END
	ELSE IF @flag = 'r'
	BEGIN
		--print 'Select Assigned ROLES'
		SELECT asr.[role_id],asr.[role_name] FROM report_privilege rp
			INNER JOIN application_security_role asr ON asr.[role_id]= rp.[role_id]
		WHERE rp.report_hash=@report_hash 
			  AND rp.[role_id] IS NOT NULL
			  AND rp.report_privilege_type = @report_privilege_type 
	END

	ELSE IF @flag = 'x'
	BEGIN
		--print 'Select USERS Lists not yet assigned for a individual Report Manager'
		SELECT au.user_login_id [value], au.user_f_name + ' ' + ISNULL(au.user_m_name + ' ', '') + au.user_l_name [label]
		FROM application_users au 
		LEFT OUTER JOIN report_privilege rp ON au.user_login_id = rp.[user_id] 
			AND rp.report_hash = @report_hash
			AND rp.report_privilege_type = @report_privilege_type
		WHERE  rp.report_hash  IS  NULL
		ORDER BY [label]
	END
	ELSE IF @flag = 'y'
	BEGIN
		--print 'Select ROLES Lists not yet assigned for a individual Report Manager'
		SELECT asr.[role_id],asr.[role_name] FROM application_security_role asr
		LEFT OUTER JOIN report_privilege rp ON asr.[role_id] = rp.[role_id] 
			AND rp.report_hash = @report_hash
			AND rp.report_privilege_type = @report_privilege_type
		WHERE  rp.report_hash IS NULL
		ORDER BY asr.[role_name]
		
	END
	ELSE IF @flag = 'g'-- for editablegrid
	BEGIN
		
		select r.report_hash [Report Hash], r.name [Report Name], 
				max(pvg_e_user.user_ids) [User (Edit Report)],
				max(pvg_e_role.role_name) [Role (Edit Report)],
				max(pvg_a_user.user_ids) [User (Add Paramset)],
				max(pvg_a_role.role_name) [Role (Add Paramset)], '' [Action] into #cte_temp
		FROM   report r 
		LEFT JOIN report_privilege rp ON rp.report_hash = r.report_hash
		LEFT JOIN application_security_role asr ON  asr.role_id = rp.role_id
		inner JOIN dbo.SplitCommaSeperatedValues(@report_hash) scsv ON scsv.item = r.report_hash
		cross apply (

			select left(s.user_ids, len(s.user_ids) - 1) as user_ids from (
			select (user_id+',') from report_privilege  
			where report_hash = rp.report_hash and user_id is not null 
				and report_privilege_type = 'a'
			for xml path('')
			) as s (user_ids)

		) pvg_a_user
		cross apply (

			select left(s.user_ids, len(s.user_ids) - 1) as user_ids from (
			select (user_id+',') from report_privilege  
			where report_hash = rp.report_hash and user_id is not null 
				and report_privilege_type = 'e'
			for xml path('')
			) as s (user_ids)

		) pvg_e_user

		cross apply (

			select left(s.role_name, len(s.role_name) - 1) as role_name from (
			select (asr.role_name+',') from report_privilege rp_i inner join application_security_role asr on asr.role_id = rp_i.role_id
			where rp_i.report_hash = rp.report_hash and rp_i.role_id is not null 
				and report_privilege_type = 'a'
			for xml path('')
			) as s (role_name)

		) pvg_a_role
		cross apply (

			select left(s.role_name, len(s.role_name) - 1) as role_name from (
			select (asr.role_name+',') from report_privilege rp_i inner join application_security_role asr on asr.role_id = rp_i.role_id
			where rp_i.report_hash = rp.report_hash and rp_i.role_id is not null 
				and report_privilege_type = 'e'
			for xml path('')
			) as s (role_name)

		) pvg_e_role
		group by r.report_hash, r.name

		
		set @sql  = 'SELECT [Report Hash],
		                    [Report Name],
		                    [User (Edit Report)],
							[Role (Edit Report)],
							[User (Add Paramset)],
							[Role (Add Paramset)],
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
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_rfx_report_privilege', 'Report Manager Report Privilege')
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
