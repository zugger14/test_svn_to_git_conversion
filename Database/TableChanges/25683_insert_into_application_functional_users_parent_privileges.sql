DECLARE @product_id INT = 10000000

IF OBJECT_ID('tempdb..#role_privilege') IS NOT NULL
	DROP TABLE #role_privilege
		
CREATE TABLE #role_privilege
(
	function_id1  INT ,
	function_name1 NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	function_id2	INT	,
	function_name2  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	function_id3		INT,
	function_name3  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	function_id4		INT,
	function_name4  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	function_id5		INT,
	function_name5  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	function_id6		INT,
	function_name6  NVARCHAR(200) COLLATE DATABASE_DEFAULT ,
	function_id7		INT,
	function_name7  NVARCHAR(200) COLLATE DATABASE_DEFAULT
)

INSERT INTO #role_privilege(
	function_id1,
	function_name1,
	function_id2,
	function_name2,
	function_id3,
	function_name3,
	function_id4,
	function_name4,
	function_id5,
	function_name5,
	function_id6,
	function_name6,
	function_id7,
	function_name7
)
EXEC spa_setup_menu @flag = 'b', @product_category = @product_id

----Insert parent of privilege to all existing privileges without parent
INSERT INTO application_functional_users(function_id, role_user_flag, login_id, role_id)
SELECT DISTINCT priv.function_id6, afu.role_user_flag, afu.login_id, afu.role_id
FROM application_functions af
INNER JOIN #role_privilege priv ON af.function_id = priv.function_id7
INNER JOIN application_functional_users afu ON afu.function_id = priv.function_id7
LEFT JOIN application_functional_users afu2 ON afu2.function_id = priv.function_id6 
	AND (afu2.role_id = afu.role_id OR afu2.login_id = afu.login_id)
WHERE afu2.functional_users_id IS NULL