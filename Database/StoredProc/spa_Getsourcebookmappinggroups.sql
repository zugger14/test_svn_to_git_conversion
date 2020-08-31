IF OBJECT_ID(N'[dbo].[spa_Getsourcebookmappinggroups]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Getsourcebookmappinggroups]
GO 

/*
-- ## @flag = s => Lists the Tags/Groups from source_book Table
-- ## If @application_function_id provided, Tags will be filtered as privilege assigned to this function id
*/
CREATE PROC [dbo].[spa_Getsourcebookmappinggroups]
	@flag CHAR(1),
	@source_system_book_type_value_id INT = NULL,
	@fas_strategy_id INT = NULL,
	@source_system_id INT = NULL,
	@application_function_id INT = NULL
AS
SET NOCOUNT ON
/*
DECLARE @flag CHAR(1) = 's',
		@source_system_book_type_value_id INT = 50,
		@fas_strategy_id INT = NULL,
		@source_system_id INT = NULL,
		@application_function_id INT = 10131000
--*/

DECLARE @sql_stmt AS VARCHAR(4000)

IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#source_book_id_rights') IS NOT NULL
		DROP TABLE #source_book_id_rights

	CREATE TABLE #source_book_id_rights(source_book_id INT)

	DECLARE @tag_assigned_count INT = 0
	
	IF @application_function_id IS NOT NULL
	BEGIN
		DECLARE @id INT = NULL
		SELECT @id = CASE @source_system_book_type_value_id
						  WHEN 50 THEN '1'
						  WHEN 51 THEN '2'
						  WHEN 52 THEN '3'
						  WHEN 53 THEN '4'
						  ELSE ''
					 END
	
		SET @sql_stmt = '
			INSERT INTO #source_book_id_rights
			SELECT s.item [source_book_id]
			FROM application_functional_users afu
			CROSS APPLY dbo.SplitCommaSeperatedValues(afu.source_system_book_id' + CAST(@id AS VARCHAR(1)) + ') s
			WHERE afu.function_id = ' + CAST(@application_function_id AS VARCHAR(20)) + ' AND afu.login_id = dbo.FNADBUser()
			UNION
			SELECT s.item
			FROM application_functional_users afu
			INNER JOIN application_role_user aru ON aru.role_id = afu.role_id
			CROSS APPLY dbo.SplitCommaSeperatedValues(afu.source_system_book_id' + CAST(@id AS VARCHAR(1)) + ') s
			WHERE afu.function_id = ' + CAST(@application_function_id AS VARCHAR(20)) + ' AND aru.user_login_id = dbo.FNADBUser()
			'
		EXEC(@sql_stmt)
	
		SELECT @tag_assigned_count = COUNT(source_book_id) FROM #source_book_id_rights
	END

	SET @sql_stmt = '
		SELECT b.source_book_id,
				b.source_book_name + CASE WHEN ssd.source_system_id = 2 THEN '''' ELSE ''.''+ ssd.source_system_name END AS BookName
		FROM source_book b ' +
		CASE WHEN @tag_assigned_count > 0 THEN ' INNER JOIN #source_book_id_rights sbir ON sbir.source_book_id = b.source_book_id ' ELSE '' END +
		'INNER JOIN source_system_description ssd
			ON b.source_system_id = ssd.source_system_id ' +
		CASE WHEN @fas_strategy_id IS NOT NULL
				THEN ' INNER JOIN fas_strategy fs ON fs.source_system_id = ssd.source_system_id AND fs.fas_strategy_id = ' + CAST(@fas_strategy_id AS VARCHAR(10))
			ELSE ''
		END
	
	SET @sql_stmt += ' WHERE b.source_system_book_type_value_id = ' + CAST(@source_system_book_type_value_id AS VARCHAR(50))
	
	IF @source_system_id IS NOT NULL
		SET @sql_stmt += ' AND b.source_system_id = ' + CAST(@source_system_id AS VARCHAR(50))
	
	SET @sql_stmt += ' ORDER BY ssd.source_system_name, b.source_book_name'
	EXEC(@sql_stmt)

	--PRINT @sql_stmt
	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'Source System Books',
	         'spa_Getsourcebookmappinggroups',
	         'DB Error',
	         'Failed to select Source System Book data.',
	         ''
END