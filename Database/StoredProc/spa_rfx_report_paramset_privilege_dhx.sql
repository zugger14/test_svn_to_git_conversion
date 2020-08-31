


/****** Object:  StoredProcedure [dbo].[spa_rfx_report_paramset_privilege_dhx]    Script Date: 02/24/2014 12:07:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rfx_report_paramset_privilege_dhx]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rfx_report_paramset_privilege_dhx]
GO

/****** Object:  StoredProcedure [dbo].[spa_rfx_report_paramset_privilege_dhx]    Script Date: 02/24/2014 12:07:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spa_rfx_report_paramset_privilege_dhx]
	@flag				CHAR(1)			= NULL , -- i: INSERT Privileges, u: Select assigned users, r: Select assigned roles, x: List Users, y: List Roles
	@listuser			VARCHAR(1000)	= NULL , -- 
	@listroles			VARCHAR(1000)	= NULL , -- 
	@paramset_hash		VARCHAR(5000)	= NULL ,
	@report_paramset_privilege_type CHAR(1) = NULL,
	@paramset_id		VARCHAR(3000)	= NULL,
	@xml				VARCHAR(MAX)	= NULL
	
AS
SET NOCOUNT ON
/*
declare @flag				CHAR(1)			= NULL , -- i: INSERT Privileges, u: Select assigned users, r: Select assigned roles, x: List Users, y: List Roles
	@listuser			VARCHAR(1000)	= NULL , -- 
	@listroles			VARCHAR(1000)	= NULL , -- 
	@paramset_hash		VARCHAR(5000)	= NULL ,
	@report_paramset_privilege_type CHAR(1) = NULL,
	@paramset_id		VARCHAR(3000)	= NULL,
	@xml				VARCHAR(MAX)	= NULL

select @flag='z', @paramset_id='17980'
--*/

BEGIN try
	begin tran
	
	DECLARE @source VARCHAR(50), @sql VARCHAR(MAX), @is_admin INT, @is_owner INT, @err_msg varchar(5000), @paramset_hashes varchar(5000);
	SET @source=dbo.FNADBUser(); --sender
		
	IF @flag = 'i'
	BEGIN
		DECLARE @idoc INT
		DECLARE @st_sql VARCHAR(5000) 
		SELECT @xml = REPLACE(@xml, '&', '&amp;')

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		if OBJECT_ID('tempdb..#tmp_report_privileges') is not null
			drop table #tmp_report_privileges
		CREATE TABLE #tmp_report_privileges (
			paramset_hash VARCHAR(max) COLLATE DATABASE_DEFAULT ,
			[user_id] VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			[role_id] VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
		)

		set @err_msg = 'Paramset Privileges assignment failed.'
		
		INSERT INTO #tmp_report_privileges (
				paramset_hash,
				[user_id],
				[role_id]
			)
			SELECT 
				paramset_hash,
				[user_id],
				[role_id]
				
			FROM   OPENXML (@idoc, '/Root/PSRecordset', 1)
				WITH ( 
					paramset_hash VARCHAR(MAX) '@hash',
					[user_id]	VARCHAR(MAX) '@user_id',
					[role_id]	VARCHAR(MAX) '@role_id'
				)
				 
			SELECT @paramset_hashes =  STUFF((
						SELECT ',' + CAST(trp.paramset_hash AS VARCHAR(200)) 
						FROM #tmp_report_privileges trp FOR XML PATH('')
					), 1, 1, '')
					 
			--SELECT @paramset_hashs
			DELETE rpp
			--SELECT * 
			FROM report_paramset_privilege rpp 
			INNER JOIN dbo.SplitCommaSeperatedValues(@paramset_hashes) paramset_hashs ON paramset_hashs.item = rpp.paramset_hash
			
			--insert user privileges
			INSERT INTO report_paramset_privilege (paramset_hash,[user_id],[report_paramset_privilege_type])
			SELECT trp.paramset_hash, scsv.item, 'v'
			FROM #tmp_report_privileges trp
			CROSS APPLY dbo.SplitCommaSeperatedValues(trp.user_id) scsv
						
			--insert role privileges
			INSERT INTO report_paramset_privilege (paramset_hash,[role_id],[report_paramset_privilege_type])
			SELECT trp.paramset_hash, scsv.item, 'v'
			FROM #tmp_report_privileges trp
			CROSS APPLY dbo.SplitCommaSeperatedValues(trp.role_id) scsv
		
		EXEC spa_ErrorHandler 0
			, 'Paramset Privilege'
			, 'spa_rfx_report_paramset_privilege_dhx'
			, 'Success'
			, 'Privilege has been assigned successfully.'
			, ''
	END
	ELSE IF @flag = 'z'
	BEGIN
		--check for allow of privilege for user
		declare @return_msg varchar(100) = 'not_allowed_user'
		declare @is_param_private int = 0
		if not exists(
			select top 1 1
			FROM report_paramset rp
			where rp.report_paramset_id = @paramset_id and rp.report_status_id = 3
		)
		begin
			select @return_msg = 'not_allowed_not_private' 
			
		end
		else
		begin
			select @is_param_private = 1
			select @is_admin = dbo.FNAIsUserOnAdminGroup(@source, 1)

			--if admin return with msg
			if @is_admin = 1 and @is_param_private = 1
			begin
				select @return_msg = 'allow_admin' 
			
			end 

			--if report owner return with msg
			else if exists(
				select top 1 1
				from report_paramset r
				where r.report_paramset_id = @paramset_id and r.create_user = @source
			) and @is_param_private = 1
			begin
				select @return_msg = 'allow_report_owner' 
			
			end
		end
		
		select @return_msg [allow_message]
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
		SELECT @paramset_hashes = STUFF(
			(
				SELECT ',' + r.paramset_hash
				FROM report_paramset r
				INNER JOIN dbo.SplitCommaSeperatedValues(@paramset_id) scsv ON scsv.item = r.report_paramset_id
				FOR XML PATH('')
			)
		, 1, 1, '')


		if OBJECT_ID('tempdb..#cte_temp') is not null
			drop table #cte_temp
		;WITH CTE AS(
						SELECT rpp.[user_id],
						       asr.role_name,asr.role_id,
						       CASE WHEN rp.[name] <> 'Default' THEN rp.[name] ELSE r.name + ' ' + rpg.[name] END paramset_name,
						       rp.paramset_hash
						FROM   report_paramset rp 
							   LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rp.paramset_hash
						       LEFT JOIN application_security_role asr ON  asr.role_id = rpp.role_id
						       INNER JOIN dbo.SplitCommaSeperatedValues(@paramset_hashes) scsv ON scsv.item = rp.paramset_hash
						       INNER JOIN report_page rpg ON rpg.report_page_id = rp.page_id
						       INNER JOIN report r ON r.report_id = rpg.report_id					            
						
					)
		SELECT paramset_hash [hash], paramset_name,
				STUFF((SELECT ',' + [user_id]
						FROM CTE
						WHERE paramset_hash = C.paramset_hash
						FOR XML PATH ('')), 1, 1, '') AS user_ids, 
				STUFF((SELECT ',' + CAST(role_name AS VARCHAR(MAX))
						FROM CTE
						WHERE paramset_hash = C.paramset_hash
						FOR XML PATH ('')), 1, 1, '') AS role_names,
				STUFF((SELECT ',' + CAST(role_id AS VARCHAR(MAX))
						FROM CTE
						WHERE paramset_hash = C.paramset_hash
						FOR XML PATH ('')), 1, 1, '') AS role_ids
		INTO #cte_temp
		FROM CTE C
		GROUP BY paramset_hash, paramset_name
		
		set @sql  = 'SELECT [hash],
		                    [paramset_name],
		                    [user_ids],
		                    [role_ids],
		                    [role_names] 
					 FROM #cte_temp '
		--PRINT @sql
		EXEC(@sql)
		
	END
	commit
END try
begin catch
	rollback
	set @err_msg = isnull(@err_msg, error_message())
	EXEC spa_ErrorHandler -1, 'report_paramset_privilege', 
		'spa_rfx_report_paramset_privilege_dhx', 'DB Error', 
		@err_msg, ''
end catch

GO


