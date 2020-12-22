IF OBJECT_ID('dbo.FNAGetPipeSeparatedBookStructure') IS NOT NULL
	DROP FUNCTION dbo.FNAGetPipeSeparatedBookStructure
GO

CREATE FUNCTION dbo.FNAGetPipeSeparatedBookStructure (
	@function_id INT
)
RETURNS @ssbm TABLE (
	sub_book_id INT,
	book_structure NVARCHAR(MAX) NOT NULL
)
AS
/*-----------Debug Section------------
DECLARE @function_id INT = 10131000
DECLARE @ssbm TABLE (
	sub_book_id INT,
	book_structure VARCHAR(MAX) NOT NULL
)
------------------------------------*/

BEGIN
	DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()
	DECLARE @app_admin_role_check INT
	
	SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(@user_name)
	DECLARE @application_functional_users TABLE (
		entity_id INT,
		role_id INT,
		login_id VARCHAR(200),
		function_id INT
	)

	INSERT INTO @application_functional_users
	SELECT entity_id,
		   role_id,
		   login_id,
		   function_id
	FROM application_functional_users
	WHERE login_id = @user_name
		AND function_id = @function_id
	UNION
	SELECT entity_id,
		   afu.role_id,
		   login_id,
		   function_id
	FROM [application_role_user] aru
	INNER JOIN application_functional_users afu
		ON afu.role_id = aru.role_id
	WHERE aru.user_login_id = @user_name
		AND function_id = @function_id
	
	INSERT INTO @ssbm
	SELECT DISTINCT
		   ssbm.book_deal_type_map_id sub_book_id,
		   sub.[entity_name] + ' | ' + stra.[entity_name] + ' | ' + book.[entity_name] + ' | ' + ssbm.logical_name book_structure
	FROM source_system_book_map ssbm
	INNER JOIN portfolio_hierarchy book 
		ON book.[entity_id] = ssbm.fas_book_id
	INNER JOIN portfolio_hierarchy stra 
		ON book.parent_entity_id = stra.[entity_id]
	INNER JOIN portfolio_hierarchy sub 
		ON stra.parent_entity_id = sub.[entity_id]
	LEFT JOIN @application_functional_users afu
		ON IIF(afu.entity_id IS NULL, -1, afu.entity_id) IN (IIF(afu.entity_id IS NULL, -1, book.entity_id), IIF(afu.entity_id IS NULL, -1, stra.entity_id), IIF(afu.entity_id IS NULL, -1, sub.entity_id)) 
	LEFT JOIN application_role_user aru
		ON aru.role_id = afu.role_id
	WHERE afu.login_id = @user_name 
		AND (afu.function_id = @function_id OR afu.entity_id IS NULL)
		OR aru.user_login_id = @user_name
		OR @app_admin_role_check = 1

	RETURN
END
GO