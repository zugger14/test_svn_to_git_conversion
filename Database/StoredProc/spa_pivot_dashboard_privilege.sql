IF OBJECT_ID(N'[dbo].[spa_pivot_dashboard_privilege]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_pivot_dashboard_privilege]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_pivot_dashboard_privilege]
    @flag CHAR(1),
	@dashboard_id VARCHAR(1000) = NULL,
	@xml_data VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON

DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#temp_privilege') IS NOT NULL
		DROP TABLE #temp_privilege

	IF OBJECT_ID('tempdb..#temp_concat') IS NOT NULL
		DROP TABLE #temp_concat
	
    SELECT prd.pivot_report_dashboard_id dashboard_id, prd.dashboard_name, pdp.user_login_id, pdp.role_id, asr.role_name
	INTO #temp_privilege
	FROM pivot_report_dashboard prd
	INNER JOIN dbo.SplitCommaSeperatedValues(@dashboard_id) scsv ON scsv.item = prd.pivot_report_dashboard_id
	LEFT JOIN pivot_dashboard_privilege pdp ON pdp.dashboard_id = prd.pivot_report_dashboard_id
	LEFT JOIN application_security_role asr ON pdp.role_id = asr.role_id

	SELECT dashboard_id, dashboard_name,
			STUFF((SELECT ',' + [user_login_id]
					FROM #temp_privilege t1
					WHERE t1.dashboard_id = t.dashboard_id
					FOR XML PATH ('')), 1, 1, '') AS user_login_id, 
			STUFF((SELECT ',' + CAST(role_name AS VARCHAR(MAX))
					FROM #temp_privilege t1
					WHERE t1.dashboard_id = t.dashboard_id
					FOR XML PATH ('')), 1, 1, '') AS role_name
	INTO #temp_concat
	FROM #temp_privilege t
	GROUP BY dashboard_id, dashboard_name

	SELECT dashboard_id, dashboard_name, user_login_id, role_name FROM #temp_concat ORDER BY dashboard_name
END
ELSE IF @flag = 'y'
BEGIN
	BEGIN TRY
		BEGIN TRAN

		IF OBJECT_ID('tempdb..#temp_dashboard_privilege') IS NOT NULL
			DROP TABLE #temp_dashboard_privilege	

		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		SELECT dashboard_id		
			, dashboard_name			
			, CASE WHEN [user_id] = 'None' OR [user_id] = '' THEN NULL ELSE [user_id] END [user_id]
			, CASE WHEN [role_name] = 'None' OR [role_name] = '' THEN NULL ELSE [role_name] END [role_name]
			, '' active_state
		INTO #temp_dashboard_privilege			
		FROM   OPENXML (@idoc, '/GridXml/GridRow', 1)
		WITH ( 
			dashboard_id		VARCHAR(5000)	'@dashboard_id',						
			dashboard_name		VARCHAR(5000)	'@dashboard_name', 
			[user_id]			VARCHAR(5000)	'@user_id',
			[role_name]			VARCHAR(5000)	'@role_name' 
		)
		EXEC sp_xml_removedocument @idoc

		IF OBJECT_ID('tempdb..#dashboard_privilege_row') IS NOT NULL
			DROP TABLE #dashboard_privilege_row	

		CREATE TABLE #dashboard_privilege_row (
			[dashboard_id] INT,
			[user]         VARCHAR(1000) COLLATE DATABASE_DEFAULT,
			[role]         VARCHAR(1000) COLLATE DATABASE_DEFAULT
		) 

		DECLARE @user VARCHAR(50), @role VARCHAR(100), @db_id INT
 		DECLARE priv_cursor CURSOR FORWARD_ONLY READ_ONLY 
 		FOR
 			SELECT dashboard_id, [user_id], [role_name]
 			FROM #temp_dashboard_privilege
 		OPEN priv_cursor
 		FETCH NEXT FROM priv_cursor INTO @db_id, @user, @role                                      
 		WHILE @@FETCH_STATUS = 0
 		BEGIN
			IF @user = 'All'
			BEGIN 			
				INSERT INTO #dashboard_privilege_row([dashboard_id], [user])
				SELECT @db_id, user_login_id FROM application_users
			END 
			ELSE IF @user IS NOT NULL
			BEGIN 
				INSERT INTO #dashboard_privilege_row([dashboard_id], [user])
				SELECT @db_id, item FROM dbo.FNASplit(@user, ',') 
			END 

			IF @role = 'All'
			BEGIN				  
				INSERT INTO #dashboard_privilege_row([dashboard_id], [role])
				SELECT @db_id, asr.role_id  FROM application_security_role asr 		 			 
			END 
			ELSE IF @role IS NOT NULL 
			BEGIN 
				INSERT INTO #dashboard_privilege_row([dashboard_id], [role])
				SELECT @db_id, asr.role_id FROM dbo.FNASplit(@role, ',') i
				INNER JOIN application_security_role asr ON asr.role_name = i.item
			END 

			FETCH NEXT FROM priv_cursor INTO @db_id, @user, @role   
 		END
 		CLOSE priv_cursor
 		DEALLOCATE priv_cursor

		-- Delete all previously assigned privileges, because all privileges are send on every save event
		DELETE pdp
		FROM pivot_dashboard_privilege pdp
		INNER JOIN #temp_dashboard_privilege tdp ON tdp.dashboard_id = pdp.dashboard_id

		IF EXISTS (SELECT 1 FROM #dashboard_privilege_row)
		BEGIN
			INSERT INTO pivot_dashboard_privilege (dashboard_id, user_login_id, role_id)
			SELECT dashboard_id, [user], [role] FROM #dashboard_privilege_row
		END

		COMMIT
		EXEC spa_ErrorHandler 0
		   , 'spa_pivot_dashboard_privilege'
		   , 'spa_pivot_dashboard_privilege'
		   , 'Success'
		   , 'Privilege assigned successfully.'
		   , ''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRAN
 
	    EXEC spa_ErrorHandler -1
	        , 'spa_pivot_dashboard_privilege'
			, 'spa_pivot_dashboard_privilege'
			, 'DB ERROR'
			, 'Error while assigning privilege.'
			, ''		
	END CATCH
END