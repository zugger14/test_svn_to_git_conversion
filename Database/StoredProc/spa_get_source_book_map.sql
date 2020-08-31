IF OBJECT_ID(N'[dbo].[spa_get_source_book_map]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_get_source_book_map]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-8-14
-- Description: Populate all source book map
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- EXEC spa_get_source_book_map 's',10131024
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_get_source_book_map]
    @flag CHAR(1),
    @function_id INT =NULL,
	@sub_book_group1 INT=NULL,
	@sub_book_group2 INT=NULL,
	@sub_book_group3 INT=NULL,
	@sub_book_group4 INT=NULL,
	@book_deal_type_map_id INT= NULL

AS

/***************************************************
DECLARE	@flag CHAR(1),
		@function_id INT =NULL,
		@sub_book_group1 INT=NULL,
		@sub_book_group2 INT=NULL,
		@sub_book_group3 INT=NULL,
		@sub_book_group4 INT=NULL,
		@book_deal_type_map_id INT= NULL
SELECT @flag='z', @function_id=10131010
--*************************************************/

SET NOCOUNT ON 
DECLARE @SQL VARCHAR(MAX)

IF OBJECT_ID('tempdb..#all_entity_rights_for_sub_book') IS NOT NULL
	DROP TABLE #all_entity_rights_for_sub_book
IF OBJECT_ID('tempdb..#sub_entity_rights_for_sub_book') IS NOT NULL
	DROP TABLE #sub_entity_rights_for_sub_book

CREATE TABLE #all_entity_rights_for_sub_book (entity_id INT)
CREATE TABLE #sub_entity_rights_for_sub_book (entity_id INT)
	
INSERT INTO #all_entity_rights_for_sub_book  
SELECT  distinct application_functional_users.entity_id AS entity_id 
FROM       application_users INNER JOIN
	        application_functional_users ON application_users.user_login_id = application_functional_users.login_id
WHERE application_functional_users.role_user_flag = 'u' AND 
		application_users.user_login_id = dbo.FNADBUser() AND
		application_functional_users.function_id = @function_id  
UNION 
SELECT DISTINCT application_functional_users.entity_id AS entity_id
FROM   application_users
	    INNER JOIN application_role_user ON  application_users.user_login_id = application_role_user.user_login_id
	    INNER JOIN application_functional_users ON  application_role_user.role_id = application_functional_users.role_id
WHERE  application_functional_users.role_user_flag = 'r'
	    AND application_users.user_login_id = dbo.FNADBUser()
	    AND application_functional_users.function_id = @function_id
	
DECLARE @all_count INT
SELECT @all_count = COUNT(*)
FROM   #all_entity_rights_for_sub_book
WHERE  entity_id IS NULL
	
IF @flag = 's'
BEGIN	
	--check for app admin role 1=true
	DECLARE @app_admin_role_check INT
	SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())
	
	If @all_count > 0 OR dbo.FNADBUser() = dbo.FNAAppAdminID() OR dbo.FNADBUser() = 'dbo' OR @app_admin_role_check = 1
	BEGIN
		-- If no sub identified or it is an app admin user all subs are authroized
		INSERT INTO #sub_entity_rights_for_sub_book 
		SELECT     book.entity_id AS entity_id
		FROM       portfolio_hierarchy book 
		WHERE     (book.entity_type_value_id = 527) and book.entity_id > 0
	END
	ELSE
	BEGIN
		INSERT INTO #sub_entity_rights_for_sub_book 
		SELECT  book.entity_id as entity_id
		FROM #all_entity_rights_for_sub_book 
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id =  #all_entity_rights_for_sub_book.entity_id
		INNER JOIN portfolio_hierarchy strategy ON sub.entity_id = strategy.parent_entity_id
		INNER JOIN portfolio_hierarchy book ON  book.parent_entity_id = strategy.entity_id
		WHERE   (sub.entity_type_value_id = 525) and book.entity_id > 0

		UNION ALL 
		SELECT  book.entity_id as entity_id
		FROM #all_entity_rights_for_sub_book 
		INNER JOIN portfolio_hierarchy strategy ON #all_entity_rights_for_sub_book.entity_id = strategy.entity_id
		INNER JOIN portfolio_hierarchy book ON  book.parent_entity_id = strategy.entity_id
		WHERE   (strategy.entity_type_value_id = 526) and book.entity_id > 0

		UNION ALL 
		SELECT  book.entity_id as entity_id
		FROM #all_entity_rights_for_sub_book 
		INNER JOIN portfolio_hierarchy book ON  book.entity_id = #all_entity_rights_for_sub_book.entity_id
		WHERE   (book.entity_type_value_id = 527) and book.entity_id > 0
	END
	
	SELECT ssbm.book_deal_type_map_id AS sub_book_id,
		   ssbm.logical_name AS sub_book_name
		   --, source_book.source_book_name + '|' + source_book_1.source_book_name + '|' + source_book_2.source_book_name + '|' + source_book_3.source_book_name AS ToolTip
	FROM   #sub_entity_rights_for_sub_book book 
		   INNER JOIN source_system_book_map ssbm ON  book.entity_id = ssbm.fas_book_id
		   INNER JOIN source_book ON  ssbm.source_system_book_id1 = source_book.source_book_id
		   INNER JOIN source_book source_book_1 ON  ssbm.source_system_book_id2 = source_book_1.source_book_id
		   INNER JOIN source_book source_book_2 ON  ssbm.source_system_book_id3 = source_book_2.source_book_id
		   INNER JOIN source_book source_book_3 ON  ssbm.source_system_book_id4 = source_book_3.source_book_id
		   INNER JOIN static_data_value deal_type ON  ssbm.fas_deal_type_value_id = deal_type.value_id
	ORDER BY ssbm.logical_name
	DROP TABLE #all_entity_rights_for_sub_book
	DROP TABLE #sub_entity_rights_for_sub_book
	
END

IF @flag = 'v'
BEGIN
IF @book_deal_type_map_id > 0
	BEGIN
		IF EXISTS (SELECT 1 
					FROM source_system_book_map
					WHERE sub_book_group1 = @sub_book_group1 
					AND sub_book_group2 = @sub_book_group2 
					AND sub_book_group3 = @sub_book_group3 
					AND sub_book_group4 = @sub_book_group4 
					AND book_deal_type_map_id<>@book_deal_type_map_id
				)
		BEGIN
			SELECT 'true'
		END
		ELSE
		BEGIN
			SELECT 'false'
		END
	END
ELSE
	BEGIN
		IF EXISTS (SELECT 1
				   FROM source_system_book_map
					WHERE sub_book_group1 = @sub_book_group1 
					AND sub_book_group2 = @sub_book_group2 
					AND sub_book_group3 = @sub_book_group3 
					AND sub_book_group4 = @sub_book_group4
			)
		BEGIN
			SELECT 'true'
		END
		ELSE
		BEGIN
			SELECT 'false'
		END
	END
END

IF @flag = 't'
BEGIN
	CREATE TABLE #all_entity_rights_for_sub_book_entity (entity_id INT)
	CREATE TABLE #sub_entity_rights_for_sub_book_entity (entity_id INT)
	
	INSERT INTO #all_entity_rights_for_sub_book_entity  
	SELECT  distinct application_functional_users.entity_id AS entity_id 
	FROM       application_users INNER JOIN
	           application_functional_users ON application_users.user_login_id = application_functional_users.login_id
	WHERE application_functional_users.role_user_flag = 'u' AND 
		  application_users.user_login_id = dbo.FNADBUser() AND
		  application_functional_users.function_id = @function_id  
	UNION 
	SELECT DISTINCT application_functional_users.entity_id AS entity_id
	FROM   application_users
	       INNER JOIN application_role_user ON  application_users.user_login_id = application_role_user.user_login_id
	       INNER JOIN application_functional_users ON  application_role_user.role_id = application_functional_users.role_id
	WHERE  application_functional_users.role_user_flag = 'r'
	       AND application_users.user_login_id = dbo.FNADBUser()
	       AND application_functional_users.function_id = @function_id
	
	DECLARE @all_count_num INT
	SELECT @all_count = COUNT(*)
	FROM   #all_entity_rights_for_sub_book_entity
	WHERE  entity_id IS NULL
	
	--check for app admin role 1=true
	DECLARE @app_role_check INT
	SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())
	
	If @all_count_num > 0 OR @app_role_check = 1
	BEGIN
		-- If no sub identified or it is an app admin user all subs are authroized
		INSERT INTO #sub_entity_rights_for_sub_book_entity 
		SELECT     sub.entity_id AS entity_id
		FROM       portfolio_hierarchy sub 
		WHERE     (sub.entity_type_value_id = 525) and sub.entity_id > 0

	END
	ELSE
	BEGIN
		--INSERT INTO #sub_entity_rights_for_sub_book 
		--SELECT  #all_entity_rights_for_sub_book.entity_id as entity_id
		--	FROM #all_entity_rights_for_sub_book 
		--	INNER JOIN portfolio_hierarchy sub ON sub.entity_id =  #all_entity_rights_for_sub_book.entity_id
		--WHERE   (sub.entity_type_value_id = 525) AND sub.entity_id > 0
		
		INSERT INTO #sub_entity_rights_for_sub_book_entity
		SELECT     sub.entity_id AS entity_id
		FROM       portfolio_hierarchy sub 
		WHERE     (sub.entity_type_value_id = 525) and sub.entity_id > 0
	END
	
	SELECT ssbm.book_deal_type_map_id AS sub_book_id,
		   isnull(ssbm.logical_name, '') AS sub_book_name
	FROM   #sub_entity_rights_for_sub_book_entity sub  
		   --INNER JOIN portfolio_hierarchy sub ON sub.entity_id = aer.entity_id
		   INNER JOIN portfolio_hierarchy strategy ON sub.entity_id = strategy.parent_entity_id
		   INNER JOIN portfolio_hierarchy book ON  book.parent_entity_id = strategy.entity_id
		   INNER JOIN source_system_book_map ssbm ON  book.entity_id = ssbm.fas_book_id
		   INNER JOIN source_book ON  ssbm.source_system_book_id1 = source_book.source_book_id
		   INNER JOIN source_book source_book_1 ON  ssbm.source_system_book_id2 = source_book_1.source_book_id
		   INNER JOIN source_book source_book_2 ON  ssbm.source_system_book_id3 = source_book_2.source_book_id
		   INNER JOIN source_book source_book_3 ON  ssbm.source_system_book_id4 = source_book_3.source_book_id
		   INNER JOIN static_data_value deal_type ON  ssbm.fas_deal_type_value_id = deal_type.value_id
	WHERE  book.entity_type_value_id = 527 ORDER BY ssbm.logical_name
	
	DROP TABLE #all_entity_rights_for_sub_book_entity
	DROP TABLE #sub_entity_rights_for_sub_book_entity
END
ELSE IF @flag = 'z'
BEGIN
	DECLARE @login_id VARCHAR(100)
	SET @login_id = dbo.FNADBUser()

	SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(@login_id)
	
	SELECT DISTINCT book_deal_type_map_id,
				logical_name
	FROM portfolio_hierarchy sub
		INNER JOIN portfolio_hierarchy strategy
		  ON sub.entity_id = strategy.parent_entity_id
		INNER JOIN portfolio_hierarchy book
		  ON book.parent_entity_id = strategy.entity_id
		INNER JOIN source_system_book_map ssbm
		  ON book.entity_id = ssbm.fas_book_id
		INNER JOIN source_book
		  ON ssbm.source_system_book_id1 = source_book.source_book_id
		INNER JOIN source_book source_book_1
		  ON ssbm.source_system_book_id2 = source_book_1.source_book_id
		INNER JOIN source_book source_book_2
		  ON ssbm.source_system_book_id3 = source_book_2.source_book_id
		INNER JOIN source_book source_book_3
		  ON ssbm.source_system_book_id4 = source_book_3.source_book_id
		INNER JOIN static_data_value deal_type
		  ON ssbm.fas_deal_type_value_id = deal_type.value_id
		LEFT JOIN application_functional_users afu
		  ON afu.entity_id IN (book.entity_id, strategy.entity_id, sub.entity_id)
		LEFT JOIN application_functions af
		  ON af.function_id = afu.function_id
		LEFT JOIN application_security_role asr
			ON afu.role_id = asr.role_id
		LEFT JOIN application_role_user aru
			ON aru.role_id = asr.role_id
	WHERE ((afu.login_id = @login_id  OR aru.user_login_id = @login_id) AND afu.function_id = @function_id) 
			OR @app_admin_role_check = 1
			OR @all_count = 1
			OR (ssbm.create_user = @login_id AND afu.functional_users_id IS NULL)

	ORDER BY 2
END