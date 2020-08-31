

IF OBJECT_ID(N'spa_my_application_log', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_my_application_log]
GO 

/**
	Insertion/Selection of the data related to log of application.
	
	Parameters:
		@flag				:	Operation flag that decides the action to be performed.
		@function_id		:	Unique identifier for a functionality of application.
		@product_category	:	Numeric Identifier for category of product.
		@record_count		:	Number of records.
*/

CREATE PROC [dbo].[spa_my_application_log]	
	@flag CHAR(1),		
	@function_id INT = NULL,
	@product_category INT = NULL,	
	@record_count INT = 10

AS 
SET NOCOUNT ON
DECLARE @Sql_Select        VARCHAR(5000),
        @user_login_id     VARCHAR(50),
        @function_name     VARCHAR(100)

IF @flag = 'i'
BEGIN
	DECLARE @file_path VARCHAR(2000)
	
	IF NULLIF(@function_id, 0) IS NOT NULL
	BEGIN
		SELECT  @function_name = sm.display_name, 
				@file_path = CASE WHEN af.function_parameter IS NULL THEN af.file_path ELSE af.file_path + '?function_parameter=' + af.function_parameter END
		FROM application_functions af

		INNER JOIN setup_menu sm ON sm.function_id = af.function_id 
		WHERE af.function_id = @function_id
		AND sm.product_category = @product_category

		INSERT INTO user_application_log (
				user_login_id,
				function_id,
				function_name,
				file_path,
				log_date,
				product_category
			 )
			VALUES (
				dbo.FNADBUser(),
				@function_id,
				@function_name,
				@file_path,
				GETDATE(),
				@product_category
			)
	END
END
ELSE IF @flag = 's'
BEGIN
	SET @user_login_id = dbo.FNADBUser()
	
	IF OBJECT_ID('tempdb..#temp_menu_items') IS NOT NULL
		DROP TABLE #temp_menu_items
		
	CREATE TABLE #temp_menu_items (	
		function_id INT,
		function_name VARCHAR(500) COLLATE DATABASE_DEFAULT ,
		file_path VARCHAR(2000) COLLATE DATABASE_DEFAULT ,
		log_date DATETIME
	)
	
	IF dbo.FNAAppAdminRoleCheck(@user_login_id) = 0 AND dbo.FNAIsUserOnAdminGroup(@user_login_id, 0) = 0
	BEGIN
		INSERT INTO #temp_menu_items
		SELECT ual.function_id,
		       ual.function_name,
		       ual.file_path,
		       ual.log_date
		FROM   application_functional_users afu
		       INNER JOIN user_application_log ual
		            ON  ual.function_id = afu.function_id
		WHERE  login_id = @user_login_id
		       AND ual.user_login_id = dbo.FNADBUser()
		       AND ual.product_category = @product_category
		UNION
		SELECT ual.function_id,
		       ual.function_name,
		       ual.file_path,
		       ual.log_date
		FROM   application_functional_users afu
		       INNER JOIN user_application_log ual
		            ON  ual.function_id = afu.function_id
		       INNER JOIN application_role_user aru
		            ON  afu.role_id = aru.role_id
		WHERE  aru.user_login_id = @user_login_id
		       AND ual.user_login_id = dbo.FNADBUser()
		       AND ual.product_category = @product_category	
	END
	-- Hide menu should not be accessed by read-only user
	ELSE IF EXISTS( SELECT 1
					FROM application_users
					WHERE user_login_id = @user_login_id
						AND read_only_user = 'y' )
	BEGIN
		INSERT INTO #temp_menu_items
		SELECT ual.function_id,
		       ual.function_name,
		       ual.file_path,
		       ual.log_date
		FROM   user_application_log ual
		WHERE  ual.user_login_id = @user_login_id
		       AND ual.product_category = @product_category
			   AND ual.function_id NOT IN( SELECT function_id
										   FROM application_functions
										   WHERE deny_privilege_to_read_only_user = 1 )
		ORDER BY
		       ual.log_date DESC
	END
	ELSE
	BEGIN
		INSERT INTO #temp_menu_items
		SELECT ual.function_id,
		       ual.function_name,
		       ual.file_path,
		       ual.log_date
		FROM   user_application_log ual
		WHERE  ual.user_login_id = @user_login_id
		       AND ual.product_category = @product_category
		ORDER BY
		       ual.log_date DESC
	END
	
	SELECT TOP(@record_count) ual.function_id, MAX(i.window_name) window_name, ual.function_name, ual.file_path, MAX(ual.log_date) log_date
	FROM #temp_menu_items ual
	LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = ual.function_id	
	WHERE ual.function_id <> 0 AND NULLIF(ual.function_name, '') IS NOT NULL
	GROUP BY ual.function_id, ual.function_name, ual.file_path
	ORDER by log_date DESC
END
--EXEC spa_my_application_log 's'
