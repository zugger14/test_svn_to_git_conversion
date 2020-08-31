

IF OBJECT_ID('dbo.spa_rfx_privileges_iu_post','p') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.spa_rfx_privileges_iu_post
END
GO
CREATE PROC dbo.spa_rfx_privileges_iu_post
	@flag CHAR(1),
	@xml VARCHAR(MAX) = NULL

AS

--IF OBJECT_ID(N'tempdb..#tmp_report_privileges') IS NOT NULL
--DROP TABLE #tmp_report_privileges
--IF OBJECT_ID(N'tempdb..#tmp_report_privileges_r') IS NOT NULL
--DROP TABLE #tmp_report_privileges_r

--DECLARE @flag CHAR(1) = 'r',
--	@xml VARCHAR(MAX) = '<Root><PSRecordset  editGrid1="2612C1D2_C60B_4032_B3B0_09A9D5DC13D8" editGrid3="AdminUser,arbajracharya" editGrid4="accountant,&&test role name" editGrid5="achyut,user100" editGrid6="BG Risk Management,BET Trading"></PSRecordset></Root>'

DECLARE @idoc INT
DECLARE @st_sql VARCHAR(5000) 
SELECT @xml = REPLACE(@xml, '&', '&amp;')

EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

CREATE TABLE #tmp_report_privileges (
	paramset_hash VARCHAR(max) COLLATE DATABASE_DEFAULT,
	[user_ids] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	[role_names] VARCHAR(MAX) COLLATE DATABASE_DEFAULT
)
CREATE TABLE #tmp_report_privileges_r (
	report_hash varchar(max) COLLATE DATABASE_DEFAULT,
	[user_ids_e] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	[role_names_e] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	[user_ids_a] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
	[role_names_a] VARCHAR(MAX) COLLATE DATABASE_DEFAULT
)

IF @flag = 'p'
BEGIN
DECLARE @paramset_hashs VARCHAR(200)

	BEGIN TRY
		BEGIN TRAN
			INSERT INTO #tmp_report_privileges (
				paramset_hash,
				[user_ids],
				[role_names]
			)
			SELECT 
				paramset_hash,
				[user_ids],
				[role_names]
				
			FROM   OPENXML (@idoc, '/Root/PSRecordset', 1)
				 WITH ( 
						paramset_hash VARCHAR(MAX)	'@editGrid1',
						user_ids  VARCHAR(MAX) '@editGrid3',
						[role_names] VARCHAR(MAX) '@editGrid4'
				 )
				 
			SELECT @paramset_hashs =  STUFF((
						SELECT ',' + CAST(trp.paramset_hash AS VARCHAR(200)) 
						FROM #tmp_report_privileges trp FOR XML PATH('')
					), 1, 1, '')
					 
			--SELECT @paramset_hashs
			DELETE rpp
			--SELECT * 
			FROM report_paramset_privilege rpp 
			INNER JOIN dbo.SplitCommaSeperatedValues(@paramset_hashs) paramset_hashs ON paramset_hashs.item = rpp.paramset_hash
			
			--insert user privileges
			INSERT INTO report_paramset_privilege (paramset_hash,[user_id],[report_paramset_privilege_type])
			SELECT trp.paramset_hash, scsv.item, 'v'
			FROM #tmp_report_privileges trp
			CROSS APPLY dbo.SplitCommaSeperatedValues(trp.user_ids) scsv
						
			--insert role privileges
			INSERT INTO report_paramset_privilege (paramset_hash,[role_id],[report_paramset_privilege_type])
			SELECT trp.paramset_hash, asr.role_id, 'v'
			FROM #tmp_report_privileges trp
			CROSS APPLY dbo.SplitCommaSeperatedValues(trp.role_names) scsv
			INNER JOIN application_security_role asr ON asr.role_name = scsv.item
			
		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0
			, 'Report Manager Privilege'
			, 'spa_rfx_privileges_iu_post'
			, 'Success'
			, 'Privileges successfully assigned for Report Manager.'
			, ''
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT ERROR_MESSAGE()
		BEGIN 
			EXEC spa_ErrorHandler -1
				, 'Report Manager Privilege'
				, 'spa_rfx_privileges_iu_post'
				, 'DB Error'
				, 'Failed to assign privileges for Report Manager.'
				, 'Failed to assign privileges for Report Manager.'
		END
		RETURN
	END CATCH
END
ELSE IF @flag = 'r'
DECLARE @report_hash VARCHAR(max)
BEGIN
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO #tmp_report_privileges_r (
				report_hash,
				[user_ids_e],
				[role_names_e],
				[user_ids_a],
				[role_names_a]
			)
			SELECT 
				report_hash,
				[user_ids_e],
				[role_names_e],
				[user_ids_a],
				[role_names_a]
				
			FROM   OPENXML (@idoc, '/Root/PSRecordset', 1)
				 WITH ( 
						report_hash VARCHAR(MAX)	'@editGrid1',
						[user_ids_e]  VARCHAR(MAX) '@editGrid3',
						[role_names_e] VARCHAR(MAX) '@editGrid4',
						[user_ids_a]  VARCHAR(MAX) '@editGrid5',
						[role_names_a] VARCHAR(MAX) '@editGrid6'
				 )
				 
			SELECT @report_hash =  STUFF((
						SELECT ',' + CAST(trp.report_hash AS VARCHAR(200)) 
						FROM #tmp_report_privileges_r trp FOR XML PATH('')
					), 1, 1, '')
					 
			--SELECT @report_hash
			--select * FROM #tmp_report_privileges_r
			--select trpr.paramset_hash,  
			--		user_role.user_id,
			--		user_role.role_id,
			--		user_role.report_privilege_type
			--from #tmp_report_privileges_r trpr
			--cross apply (
			--	select item [user_id], null [role_id], 'e' report_privilege_type from dbo.SplitCommaSeperatedValues(trpr.user_ids_e) 
			--	union 
			--	select null, asr.role_id, 'e' from dbo.SplitCommaSeperatedValues(trpr.role_names_e) scsv
			--	inner join application_security_role asr on asr.role_name = scsv.item
			--	union
			--	select item, null, 'a' report_privilege_type from dbo.SplitCommaSeperatedValues(trpr.user_ids_a) 
			--	union 
			--	select null, asr.role_id, 'a' from dbo.SplitCommaSeperatedValues(trpr.role_names_a) scsv
			--	inner join application_security_role asr on asr.role_name = scsv.item
			--) user_role
			--return

			DELETE r
			--SELECT * 
			FROM report_privilege r
			INNER JOIN dbo.SplitCommaSeperatedValues(@report_hash) scsv ON scsv.item = r.report_hash
			
			--insert user privileges

			--todo:new
			INSERT INTO report_privilege (report_hash, [user_id], [role_id], report_privilege_type)
			select trpr.report_hash,  
					user_role.user_id,
					user_role.role_id,
					user_role.report_privilege_type
			from #tmp_report_privileges_r trpr
			cross apply (
				select item [user_id], null [role_id], 'e' report_privilege_type from dbo.SplitCommaSeperatedValues(trpr.user_ids_e) 
				union 
				select null, asr.role_id, 'e' from dbo.SplitCommaSeperatedValues(trpr.role_names_e) scsv
				inner join application_security_role asr on asr.role_name = scsv.item
				union
				select item, null, 'a' report_privilege_type from dbo.SplitCommaSeperatedValues(trpr.user_ids_a) 
				union 
				select null, asr.role_id, 'a' from dbo.SplitCommaSeperatedValues(trpr.role_names_a) scsv
				inner join application_security_role asr on asr.role_name = scsv.item
			) user_role

			--INSERT INTO report_privilege (report_hash,[user_id], report_privilege_type)
			--SELECT trp.paramset_hash, scsv.item, 'v'
			--FROM #tmp_report_privileges trp
			--CROSS APPLY dbo.SplitCommaSeperatedValues(trp.user_ids) scsv
						
			----insert role privileges
			--INSERT INTO report_paramset_privilege (paramset_hash,[role_id],[report_paramset_privilege_type])
			--SELECT trp.paramset_hash, asr.role_id, 'v'
			--FROM #tmp_report_privileges trp
			--CROSS APPLY dbo.SplitCommaSeperatedValues(trp.role_names) scsv
			--INNER JOIN application_security_role asr ON asr.role_name = scsv.item
			
		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0
			, 'Report Manager Privilege'
			, 'spa_rfx_privileges_iu_post'
			, 'Success'
			, 'Privileges successfully assigned for Report Manager.'
			, ''
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT ERROR_MESSAGE()
		BEGIN 
			EXEC spa_ErrorHandler -1
				, 'Report Manager Privilege'
				, 'spa_rfx_privileges_iu_post'
				, 'DB Error'
				, 'Failed to assign privileges for Report Manager.'
				, 'Failed to assign privileges for Report Manager.'
		END
		RETURN
	END CATCH
END
