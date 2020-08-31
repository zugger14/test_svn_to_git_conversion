
IF OBJECT_ID(N'[dbo].[spa_ipx_privileges]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_ipx_privileges
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 
-- ===========================================================================================================
-- Author: kacharya@pioneersolutionsglobal.com
-- Create date: 2013-9-2
-- Description: privileges management for table import_export_privileges
 
-- Params:
-- @flag CHAR(1) - Operation flag
--@@ipx_privileges_id INT - used for update, deleted
--@user_id VARCHAR(50) - authorized user
--@role_id INT - Assigned Role
--@import_export_id INT - import export type

-- ===========================================================================================================

CREATE PROCEDURE [dbo].spa_ipx_privileges
	@flag						CHAR(1) = NULL,
	@ipx_privileges_id			INT = NULL,
	@user_id					NVARCHAR(4000) = NULL,
	@role_id					NVARCHAR(4000) = NULL,
	@import_export_id			VARCHAR(5000) = NULL,	
	@xml_data					NVARCHAR(MAX) = NULL 
AS
SET NOCOUNT ON
BEGIN
DECLARE @desc VARCHAR(500)
DECLARE @err_no  INT
DECLARE @sql VARCHAR(MAX)

IF @flag = 'i'
BEGIN
BEGIN TRY  
	SET @sql = 'DELETE FROM ipx_privileges WHERE import_export_id IN (' + @import_export_id + ') AND [user_id] IS NOT NULL'
	EXEC(@sql)
	--DELETE FROM ipx_privileges WHERE import_export_id = @import_export_id AND [user_id] IS NOT NULL
	
	EXEC('
		INSERT INTO ipx_privileges (
			[user_id],
			import_export_id
		)
		SELECT fna_user.item,
				a.item
		FROM   dbo.SplitCommaSeperatedValues('''+@user_id+''') fna_user
		LEFT JOIN ipx_privileges iep ON  iep.[user_id] = fna_user.item  AND iep.import_export_id IN (' + @import_export_id + ') 
		CROSS JOIN dbo.SplitCommaSeperatedValues(''' + @import_export_id + ''') a
		WHERE iep.ipx_privileges_id IS NULL') 
	
    SET @sql = 'DELETE FROM ipx_privileges WHERE import_export_id IN (' + @import_export_id + ') AND [role_id] IS NOT NULL'
	EXEC(@sql)
	---DELETE FROM ipx_privileges WHERE import_export_id = @import_export_id AND [role_id] IS NOT NULL
    
	EXEC('
		INSERT INTO ipx_privileges (
			[role_id],
			import_export_id
		)
		SELECT fna_role.item,
				a.item
		FROM   dbo.SplitCommaSeperatedValues('''+@role_id+''') fna_role
		LEFT JOIN ipx_privileges iep ON  iep.[role_id] = fna_role.item  AND iep.import_export_id IN (' + @import_export_id + ') 
		CROSS JOIN dbo.SplitCommaSeperatedValues(''' + @import_export_id + ''') a
		WHERE iep.ipx_privileges_id IS NULL')
    
    
	EXEC spa_ErrorHandler 0,
		'ipx_privileges',
		'spa_ipx_privileges',
		'Success',
		'Data Save successfully.',
		''
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK

	IF ERROR_MESSAGE() = 'CatchError'
		SET @desc = 'Fail to insert Data ( Errr Description:' + @desc + ')'
	ELSE
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

	SELECT @err_no = ERROR_NUMBER()
		
	EXEC spa_ErrorHandler @err_no,
		'ipx_privileges',
		'spa_ipx_privileges',
		'Error',
		@desc,
		''
END CATCH
END

IF @flag = 'u'
BEGIN
	SELECT  DISTINCT [user_id] 
	FROM ipx_privileges 
	WHERE import_export_id = @import_export_id AND [user_id] IS NOT NULL 
END
ELSE IF @flag = 'x'
BEGIN
	SELECT au.user_login_id FROM application_users au 
	LEFT OUTER JOIN ipx_privileges ipxp ON au.user_login_id = ipxp.[user_id] 
		AND ipxp.import_export_id = @import_export_id
	WHERE  ipxp.import_export_id IS NULL
END
ELSE IF @flag = 'y'
BEGIN
	SELECT asr.[role_id],asr.[role_name] 
	FROM application_security_role asr
	LEFT OUTER JOIN ipx_privileges ip ON asr.[role_id] = ip.[role_id] 
	AND ip.import_export_id = @import_export_id
	WHERE  ip.import_export_id IS NULL
END
ELSE IF @flag = 'r'
	BEGIN
		SELECT DISTINCT asr.[role_id],asr.[role_name] 
		FROM ipx_privileges ip
		INNER JOIN application_security_role asr ON asr.[role_id] = ip.[role_id]
		WHERE ip.import_export_id = @import_export_id 
	END

ELSE IF @flag = 'a'
	BEGIN 
		SET @sql = 'SELECT TOP (1) 
					CAST ((SELECT     LTRIM(RTRIM([user_id])) + '','' 
						FROM         ipx_privileges
						WHERE     import_export_id IN (' + @import_export_id + ')
						FOR XML PATH('''')) AS VARCHAR(8000)) 
					AS users,
					CAST ((SELECT     dbo.FNAGetUserName([user_id]) + '','' 
						FROM         ipx_privileges
						WHERE     import_export_id IN (' + @import_export_id + ')
						FOR XML PATH('''')) AS VARCHAR(8000)) 
					AS user_name,
					CAST ((SELECT     LTRIM(RTRIM([role_id])) + '',''
						FROM         ipx_privileges
						WHERE     import_export_id IN (' + @import_export_id + ')
						FOR XML PATH('''')) AS VARCHAR(8000)) 
					AS roles					
					FROM  ipx_privileges AS ip' 
		EXEC(@sql)		    
	END
	
	IF @flag = 'g'
	BEGIN
	BEGIN TRY  
		IF @role_id != ''
		BEGIN
			SET @sql = 'DELETE FROM ipx_privileges WHERE import_export_id IN (' + @import_export_id + ') AND [role_id] IS NOT NULL'
			EXEC(@sql) 
    
			EXEC('
				INSERT INTO ipx_privileges (
					[role_id],
					import_export_id
				)
				SELECT fna_role.item,
						a.item
				FROM   dbo.SplitCommaSeperatedValues('''+@role_id+''') fna_role
				LEFT JOIN ipx_privileges iep ON  iep.[role_id] = fna_role.item  AND iep.import_export_id IN (' + @import_export_id + ') 
				CROSS JOIN dbo.SplitCommaSeperatedValues(''' + @import_export_id + ''') a
				WHERE iep.ipx_privileges_id IS NULL')
		END
		
		IF @user_id != ''
		BEGIN 
			SET @sql = 'DELETE FROM ipx_privileges WHERE import_export_id IN (' + @import_export_id + ') AND [user_id] IS NOT NULL'
			EXEC(@sql)
	
			EXEC('
				INSERT INTO ipx_privileges (
					[user_id],
					import_export_id
				)
				SELECT fna_user.item,
						a.item
				FROM   dbo.SplitCommaSeperatedValues('''+@user_id+''') fna_user
				LEFT JOIN ipx_privileges iep ON  iep.[user_id] = fna_user.item  AND iep.import_export_id IN (' + @import_export_id + ') 
				CROSS JOIN dbo.SplitCommaSeperatedValues(''' + @import_export_id + ''') a
				WHERE iep.ipx_privileges_id IS NULL') 
		END
		
    
    
		EXEC spa_ErrorHandler 0,
			'ipx_privileges',
			'spa_ipx_privileges',
			'Success',
			'Data Save successfully.',
			''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		IF ERROR_MESSAGE() = 'CatchError'
			SET @desc = 'Fail to insert Data ( Errr Description:' + @desc + ')'
		ELSE
			SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

		SELECT @err_no = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no,
			'ipx_privileges',
			'spa_ipx_privileges',
			'Error',
			@desc,
			''
	END CATCH
	END
		
	
	IF @flag = 'o'
	BEGIN
		 SET @sql = 'SELECT role_name FROM application_security_role WHERE role_id IN (' + @role_id + ')'
		 EXEC(@sql);
	END

	IF @flag = 'e'
	BEGIN
		 SET @sql = 'SELECT dbo.FNAGetUserName(fna_user.item) user_name
					FROM   dbo.SplitCommaSeperatedValues('''+@user_id+''') fna_user
					'
		 EXEC(@sql);
	END
	
	IF @flag = 'v'
	BEGIN
		BEGIN TRY 
			DECLARE @idoc INT
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

			SELECT rule_id		
				, [user]			 
				, role_ids	  
			INTO #temp_privilege_grid			
			FROM   OPENXML (@idoc, '/gridXml/GridRow', 1)
					WITH ( 
						rule_id		VARCHAR(5000)	'@rule_id',						
						[user]		VARCHAR(5000)	'@user', 
						role_ids	VARCHAR(5000)	'@role_ids' 
						)
			EXEC sp_xml_removedocument @idoc
			
			SELECT * FROM #temp_privilege_grid
		
			
			
		 
			CREATE TABLE #role_and_user (rule_id INT, [user] VARCHAR(200) COLLATE DATABASE_DEFAULT, [role] INT)
		
			INSERT INTO #role_and_user
			(
				rule_id,
				[user],
				role
			) 
			SELECT	t.rule_id,
					a.item 
					,NULL 
			FROM #temp_privilege_grid t 
			CROSS APPLY dbo.SplitCommaSeperatedValues(t.[user]) a 
			UNION ALL
			SELECT	t.rule_id,
					NULL, 
					x.item  
			FROM #temp_privilege_grid t
			CROSS APPLY dbo.SplitCommaSeperatedValues(t.role_ids) x   
			
			DELETE ip 
			FROM ipx_privileges ip
				INNER JOIN #temp_privilege_grid tpg
					ON ip.import_export_id = tpg.rule_id			
		
			INSERT INTO ipx_privileges ([user_id], [role_id], import_export_id)
			SELECT [user], [role], [rule_id] FROM #role_and_user AS rau
			
			EXEC spa_ErrorHandler 0,
				'ipx_privileges',
				'spa_ipx_privileges',
				'Success',
				'Data Save successfully.',
				''
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK

			IF ERROR_MESSAGE() = 'CatchError'
				SET @desc = 'Fail to insert Data ( Errr Description:' + @desc + ')'
			ELSE
				SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

			SELECT @err_no = ERROR_NUMBER()
		
			EXEC spa_ErrorHandler @err_no,
				'ipx_privileges',
				'spa_ipx_privileges',
				'Error',
				@desc,
				''
		END CATCH 
		
	END
END
GO

