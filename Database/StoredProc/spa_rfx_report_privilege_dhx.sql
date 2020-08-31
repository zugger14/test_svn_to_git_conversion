
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rfx_report_privilege_dhx]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rfx_report_privilege_dhx]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE dbo.spa_rfx_report_privilege_dhx
	@flag					CHAR(1)			= NULL , -- i: INSERT Report Privileges, u: Select assigned users, r: Select assigned roles, x: List Users, y: List Roles
	@listuser				VARCHAR(1000)	= NULL ,  
	@listroles				VARCHAR(1000)	= NULL ,  
	@report_id				VARCHAR(3000)	= NULL ,
	@report_privilege_type	CHAR(1)			= 'e'  ,
	@report_hash			VARCHAR(100)	= NULL ,
	@xml					VARCHAR(MAX)	= NULL
	
AS
SET NOCOUNT ON

/*
declare @flag					CHAR(1)			= NULL , -- i: INSERT Privileges, u: Select assigned users, r: Select assigned roles, x: List Users, y: List Roles
	@listuser				VARCHAR(1000)	= NULL ,  
	@listroles				VARCHAR(1000)	= NULL ,  
	@report_id				VARCHAR(3000)	= NULL ,
	@report_privilege_type	CHAR(1)			= 'e',
	@report_hash			varchar(100)	= NULL,
	@xml					VARCHAR(MAX)	= NULL

select @flag='g',@report_id='15095,15096'
--*/

BEGIN try
	begin tran
	DECLARE @source VARCHAR(50), @is_admin INT = 0, @is_owner INT = 0, @sql VARCHAR(MAX), @err_msg varchar(5000), @report_hashes varchar(5000);
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
			report_hash VARCHAR(max) COLLATE DATABASE_DEFAULT ,
			[user_id] VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
			[role_id] VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
		)

		set @err_msg = 'Report Privileges assignment failed.'
		
		INSERT INTO #tmp_report_privileges (
				report_hash,
				[user_id],
				[role_id]
		)
		SELECT 
			report_hash,
			[user_id],
			[role_id]
				
		FROM   OPENXML (@idoc, '/Root/PSRecordset', 1)
				WITH ( 
					report_hash VARCHAR(MAX) '@hash',
					[user_id]	VARCHAR(MAX) '@user_id',
					[role_id]	VARCHAR(MAX) '@role_id'
				)
				 
		SELECT @report_hashes =  STUFF((
					SELECT ',' + CAST(trp.report_hash AS VARCHAR(200)) 
					FROM #tmp_report_privileges trp FOR XML PATH('')
				), 1, 1, '')
					 
			

		DELETE r
		--SELECT * 
		FROM report_privilege r
		INNER JOIN dbo.SplitCommaSeperatedValues(@report_hashes) scsv ON scsv.item = r.report_hash
		
		INSERT INTO report_privilege (report_hash, [user_id], [role_id], report_privilege_type)
		select trpr.report_hash,  
				user_role.user_id,
				user_role.role_id,
				user_role.report_privilege_type
		from #tmp_report_privileges trpr
		cross apply (
			select item [user_id], null [role_id], 'e' report_privilege_type from dbo.SplitCommaSeperatedValues(trpr.[user_id]) 
			union 
			select null, item [role_id], 'e' from dbo.SplitCommaSeperatedValues(trpr.[role_id]) scsv
			--union
			--select item, null, 'a' report_privilege_type from dbo.SplitCommaSeperatedValues(trpr.user_ids_a) 
			--union 
			--select null, asr.role_id, 'a' from dbo.SplitCommaSeperatedValues(trpr.role_names_a) scsv
			--inner join application_security_role asr on asr.role_name = scsv.item
		) user_role

		EXEC spa_ErrorHandler 0
			, 'Report Privilege'
			, 'spa_rfx_report_privilege_dhx'
			, 'Success'
			, 'Report Privileges successfully assigned.'
			, ''
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
	ELSE IF @flag = 'z'
	BEGIN
		--check for allow of privilege for user
		declare @return_msg varchar(100) = 'not_allowed'
		select @is_admin = dbo.FNAIsUserOnAdminGroup(@source, 1)

		--if admin return with msg
		if @is_admin = 1
		begin
			select @return_msg = 'allow_admin' 
			
		end

		--if report owner return with msg
		else if exists(
			select top 1 1
			from report r
			inner JOIN dbo.SplitCommaSeperatedValues(@report_id) scsv ON scsv.item = r.report_id AND r.[owner] = @source
		)
		begin
			select @return_msg = 'allow_report_owner' 
			
		end

		select @return_msg [allow_message]
		
	END
	ELSE IF @flag = 'g'-- for editablegrid
	BEGIN
		select @is_admin = dbo.FNAIsUserOnAdminGroup(@source, 1)
		DECLARE @check_report_admin_role INT = ISNULL(dbo.FNAReportAdminRoleCheck(@source), 0)

		SELECT @report_hashes = STUFF(
			(
				SELECT ',' + r.report_hash
				FROM report r
				INNER JOIN dbo.SplitCommaSeperatedValues(@report_id) scsv ON scsv.item = r.report_id
				FOR XML PATH('')
			)
		, 1, 1, '')

		if OBJECT_ID('tempdb..#cte_temp') is not null
			drop table #cte_temp
		select r.report_hash [hash], r.name [report_name], 
				max(pvg_e_user.user_ids) [user_ids],
				max(pvg_e_role.role_name) [role_names],
				max(pvg_e_role_id.role_id) [role_ids],
				max(pvg_a_user.user_ids) [user_ap],
				max(pvg_a_role.role_name) [role_ap]
		into #cte_temp
		FROM   report r 
		LEFT JOIN report_privilege rp ON rp.report_hash = r.report_hash
		LEFT JOIN application_security_role asr ON  asr.role_id = rp.role_id
		inner JOIN dbo.SplitCommaSeperatedValues(@report_hashes) scsv ON scsv.item = r.report_hash
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
		cross apply (

			select left(s.role_id, len(s.role_id) - 1) as role_id from (
			select (cast(asr.role_id as varchar(10))+',') from report_privilege rp_i inner join application_security_role asr on asr.role_id = rp_i.role_id
			where rp_i.report_hash = rp.report_hash and rp_i.role_id is not null 
				and report_privilege_type = 'e'
			for xml path('')
			) as s (role_id)

		) pvg_e_role_id
		WHERE r.[owner] = @source OR @is_admin = 1 OR @check_report_admin_role = 1
		group by r.report_hash, r.name

		select 1 [subgrid],
				 [hash], 
				 [report_name], 
				 'Edit' [type],
				[user_ids],
				[role_names],
				[user_ap],
				[role_ap],
				[role_ids]
				 FROM #cte_temp
				
		--set @sql  = 'SELECT 1 test, [hash],	report_name,	user_ids,	role_names,	role_id, user_ap, role_ap FROM #cte_temp'
		--PRINT @sql
		--EXEC(@sql)
	END

ELSE IF @flag = 'h'-- for editablegrid
	BEGIN
		
		if OBJECT_ID('tempdb..#cte_temp1') is not null
			drop table #cte_temp1
		;WITH CTE1 AS(
						SELECT rpp.[user_id],
						       asr.role_name,asr.role_id,
						       CASE WHEN rp.[name] <> 'Default' THEN rp.[name] ELSE r.name + ' ' + rpg.[name] END paramset_name,
						       rp.paramset_hash,
						       r.report_hash
						FROM   report_paramset rp 
						       INNER JOIN report_page rpg ON rpg.report_page_id = rp.page_id
						       INNER JOIN report r ON r.report_id = rpg.report_id
						       inner JOIN dbo.SplitCommaSeperatedValues(@report_hash) scsv ON scsv.item = r.report_hash	
							   LEFT JOIN report_paramset_privilege rpp ON rpp.paramset_hash = rp.paramset_hash
						       LEFT JOIN application_security_role asr ON  asr.role_id = rpp.role_id
						       --INNER JOIN dbo.SplitCommaSeperatedValues(@paramset_hashes) scsv ON scsv.item = rp.paramset_hash
						WHERE  rp.report_status_id = 3				            
						
					)


		SELECT [paramset_hash] AS [hash], paramset_name,
				STUFF((SELECT ',' + [user_id]
						FROM CTE1
						WHERE paramset_hash = C.paramset_hash
						FOR XML PATH ('')), 1, 1, '') AS user_ids, 
				STUFF((SELECT ',' + CAST(role_name AS VARCHAR(MAX))
						FROM CTE1
						WHERE paramset_hash = C.paramset_hash
						FOR XML PATH ('')), 1, 1, '') AS role_names,
				STUFF((SELECT ',' + CAST(role_id AS VARCHAR(MAX))
						FROM CTE1
						WHERE paramset_hash = C.paramset_hash
						FOR XML PATH ('')), 1, 1, '') AS role_ids,
						MAX(report_hash) AS [report_hash]
		INTO #cte_temp1
		FROM CTE1 C
		GROUP BY paramset_hash, paramset_name
		
		set @sql  = 'SELECT [hash],
		                    [paramset_name],
							''View'' [type],
		                    [user_ids],
		                    [role_ids],
		                    [role_names]
					 FROM #cte_temp1 '
		--PRINT @sql
		EXEC(@sql)
		
	END
	commit
END try
begin catch
	rollback
	set @err_msg = isnull(@err_msg, error_message())
	EXEC spa_ErrorHandler -1, 'report_privilege', 
		'spa_rfx_report_paramset_privilege_dhx', 'DB Error', 
		@err_msg, ''
end catch



GO
