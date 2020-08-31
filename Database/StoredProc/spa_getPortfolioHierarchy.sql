IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_getPortfolioHierarchy]') AND [type] IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getPortfolioHierarchy]
GO

/**
 Stored Procedure to insert/update data in portfolio hierarchy. 
 Parameters
	@function_id: tbd
	@flag : Operation flag optional
			k - tbd
			y - tbd
			z - tbd
			x - tbd
			m - tbd			
	@runtime_user : tbd	
	@add_save_function_id : tbd
	@delete_function_id : tbd	
	@include_subbook : tbd
	@tag1 : tbd
	@tag2 : tbd
    @tag3 : tbd
    @tag4 : tbd
*/ 
--This procedure returns the portfolio hiearchy for a security function id
CREATE PROC [dbo].[spa_getPortfolioHierarchy] 	
		@function_id INT ,
		@flag CHAR(1) = 't', -- 't'-> returns Table; 'x'-> returns XML(to use in DHTMLX components),
		@runtime_user NVARCHAR(100)  = NULL,
		@add_save_function_id INT = NULL,
		@delete_function_id INT = NULL,
		@include_subbook CHAR(1) = 'y',
		@tag1 NVARCHAR(4000) = NULL,
		@tag2 NVARCHAR(4000) = NULL,
		@tag3 NVARCHAR(4000) = NULL,
		@tag4 NVARCHAR(4000) = NULL
AS 

/****************************************
------------------Insert data on temp table detail------------------
--#all_entity_rights -> This table consist of all the privilleged Subsidiary/Strategys/book/subook on defined user.
--#sub_entity_rights -> This table contains all the subsidiaries filtered out from #all_entity_rights
--#strategy_entity_rights -> This table  contains all the strategies filtered out from #all_entity_rights excluding the strategies which falls under #sub_entity_rights.
--#book_entity_rights -> This table  contains all the Book filtered out from #all_entity_rights excluding the books which falls under #sub_entity_rights and #strategy_entity_rights.
--#entity_rights_combinations -> This table contains all privileged sub_book combination
--#group_entity_rights -> all privileged sub_book (short id for #entity_rights_combinations tag combination)
--#temp_privileges  -> privileged entity_id for UI/Save/Delete function_id
---------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------


DECLARE	@function_id INT ,
		@flag CHAR(1) = 't', -- 't'-> returns Table; 'x'-> returns XML(to use in DHTMLX components),
		@runtime_user NVARCHAR(100)  = NULL,
		@add_save_function_id INT = NULL,
		@delete_function_id INT = NULL,
		@include_subbook CHAR(1) = 'y',
		@tag1 NVARCHAR(4000) = NULL,
		@tag2 NVARCHAR(4000) = NULL,
		@tag3 NVARCHAR(4000) = NULL,
		@tag4 NVARCHAR(4000) = NULL
	
SELECT @function_id='10131000',@add_save_function_id='10131010',@delete_function_id='10131011',@flag='y'--,@tag1='4470,4387',@tag2='4403,-2',@tag3='-3',@tag4='-4'

----------COMMENT THE ABOVE FOR PRODUCTION VERSION
--*******************************************/

DECLARE @sql_stmt NVARCHAR(4000)
DECLARE @all_count INT
DECLARE @view_id_base_no INT
DECLARE @user_name NVARCHAR(100)
DECLARE @node_level INT

SET @function_id = NULLIF(@function_id, '')
SET @add_save_function_id = NULLIF(@add_save_function_id, '')
SET @delete_function_id = NULLIF(@delete_function_id, '')
SET @user_name = dbo.FNADBUser();
SET @all_count = 0
SET @tag1 = NULLIF(@tag1, '')
SET @tag2 = NULLIF(@tag2, '')
SET @tag3 = NULLIF(@tag3, '')
SET @tag4 = NULLIF(@tag4, '')

/* Same parameter @function_id is used to pass both Application Function ID
* or Report Writer View ID. So to differentiate between the two, a base no. 
* of 100000000 is added in every Report Writer View ID
*/
SET @view_id_base_no = 100000000

-- for admin select all and on...
-- if null entity_id it means all...
-- first collect all subs and select all strategies and books (turn them on)
-- second collect all not in stratgies and select susbs (off) and books(on)
-- collect not in books and strategies (off) and sub (off) 

SET NOCOUNT ON
SET QUOTED_IDENTIFIER ON

IF ISNULL(@runtime_user, '') <> '' AND @runtime_user <> dbo.FNADBUser()   
BEGIN
	--EXECUTE AS USER = @runtime_user;
	DECLARE @contextinfo VARBINARY(128)
	SELECT @contextinfo = CONVERT(VARBINARY(128), @runtime_user)
	SET CONTEXT_INFO @contextinfo
END

IF OBJECT_ID('tempdb..#all_entity_rights') IS NOT NULL
DROP TABLE #all_entity_rights

CREATE TABLE #all_entity_rights
(entity_id int)

IF OBJECT_ID('tempdb..#sub_entity_rights') IS NOT NULL
	DROP TABLE #sub_entity_rights

CREATE TABLE #sub_entity_rights
(entity_id int)

IF OBJECT_ID('tempdb..#strategy_entity_rights') IS NOT NULL
	DROP TABLE #strategy_entity_rights

CREATE TABLE #strategy_entity_rights
(entity_id int)

IF OBJECT_ID('tempdb..#book_entity_rights') IS NOT NULL
	DROP TABLE #book_entity_rights

CREATE TABLE #book_entity_rights
(entity_id int)

IF OBJECT_ID('tempdb..#return_entity') IS NOT NULL
	DROP TABLE #return_entity

CREATE TABLE #return_entity
(entity_id int, 
parent_entity_id int,
entity_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
have_rights int,
node_type int)

IF OBJECT_ID('tempdb..#sorted_return_entity') IS NOT NULL
	DROP TABLE #sorted_return_entity

CREATE TABLE #sorted_return_entity
(next_id int identity,
entity_id int, 
parent_entity_id int,
entity_name NVARCHAR(1000) COLLATE DATABASE_DEFAULT,
have_rights int,
node_type int)

IF OBJECT_ID('tempdb..#entity_rights_combinations') IS NOT NULL
	DROP TABLE #entity_rights_combinations

CREATE TABLE #entity_rights_combinations (id1 INT, id2 INT, id3 INT, id4 INT)

IF OBJECT_ID('tempdb..#group_entity_rights') IS NOT NULL
	DROP TABLE #group_entity_rights

CREATE TABLE #group_entity_rights (entity_id INT)

IF OBJECT_ID('tempdb..#sub_book_entity_rights') IS NOT NULL
	DROP TABLE #sub_book_entity_rights

CREATE TABLE #sub_book_entity_rights (entity_id INT)

IF OBJECT_ID('tempdb..#source_system_book_map') IS NOT NULL
	DROP TABLE #source_system_book_map

IF OBJECT_ID('tempdb..#filtered_porfolio_by_tags') IS NOT NULL
	DROP TABLE #filtered_porfolio_by_tags

CREATE TABLE #filtered_porfolio_by_tags (
	sub_id	INT
	, stra_id INT
	, book_id INT
	, sub_book_id INT
	--enable when debugging
	--, subsidiary VARCHAR(100) COLLATE DATABASE_DEFAULT
	--, strategy VARCHAR(100) COLLATE DATABASE_DEFAULT
	--, book VARCHAR(100) COLLATE DATABASE_DEFAULT
	--, sub_book VARCHAR(100) COLLATE DATABASE_DEFAULT
)

SET @sql_stmt = 'INSERT INTO #filtered_porfolio_by_tags --TODO: expand cols name
					SELECT  sub.entity_id sub_id, strategy.entity_id stra_id, book.entity_id book_id, ssbm.book_deal_type_map_id sub_book_id
					--enable when debugging
					--, sub.entity_name subsidiary, strategy.entity_name strategy, book.entity_name book, ssbm.logical_name sub_book
					FROM portfolio_hierarchy sub
					LEFT JOIN portfolio_hierarchy strategy
						ON sub.entity_id = strategy.parent_entity_id 
					LEFT JOIN portfolio_hierarchy book
						ON strategy.entity_id = book.parent_entity_id 
					LEFT JOIN source_system_book_map ssbm
						ON book.entity_id = ssbm.fas_book_id
					WHERE  sub.hierarchy_level = 2 
						AND sub.entity_id <> -1
					 '
+ 
CASE 
	WHEN @tag1 IS NOT NULL THEN ' AND ssbm.source_system_book_id1 IN(' + @tag1 + ') '
	ELSE ''
END
+
CASE 
	WHEN @tag2 IS NOT NULL THEN ' AND ssbm.source_system_book_id2 IN(' + @tag2 + ') ' 
	ELSE ''
END
+
CASE 
	WHEN @tag3 IS NOT NULL THEN ' AND ssbm.source_system_book_id3 IN(' + @tag3 + ') ' 
	ELSE ''
END
+
CASE 
	WHEN @tag4 IS NOT NULL THEN ' AND ssbm.source_system_book_id4 IN(' + @tag4 + ') ' 
	ELSE ''
END
EXEC spa_print @sql_stmt
EXEC(@sql_stmt)

--SELECT '' [#filtered_porfolio_by_tags], * FROM #filtered_porfolio_by_tags

IF @function_id >= @view_id_base_no
BEGIN
	DECLARE @view_id int
	SET @view_id = @function_id - @view_id_base_no
	
	INSERT INTO #all_entity_rights 
	SELECT DISTINCT rwvu.entity_id AS entity_id 
	FROM report_writer_view_users rwvu
	INNER JOIN application_users au ON rwvu.login_id = au.user_login_id
	WHERE rwvu.login_id = dbo.FNADBUser() AND rwvu.function_id  = @view_id

	UNION 

	SELECT DISTINCT rwvu.entity_id AS entity_id 
	FROM report_writer_view_users rwvu
	INNER JOIN application_role_user aru ON aru.role_id = rwvu.role_id
	WHERE aru.user_login_id = dbo.FNADBUser() AND rwvu.function_id  = @view_id 
		
	UNION
		
	SELECT DISTINCT rmvu.entity_id AS entity_id 
	FROM report_manager_view_users rmvu
	INNER JOIN application_users au ON rmvu.login_id = au.user_login_id
	WHERE rmvu.login_id = dbo.FNADBUser() AND rmvu.data_source_id  = @view_id
		AND COALESCE(rmvu.source_system_book_id1, rmvu.source_system_book_id2, rmvu.source_system_book_id3, rmvu.source_system_book_id4) IS NULL
	UNION 

	SELECT DISTINCT rmvu.entity_id AS entity_id 
	FROM report_manager_view_users rmvu
	INNER JOIN application_role_user aru ON aru.role_id = rmvu.role_id
	WHERE aru.user_login_id = dbo.FNADBUser() AND rmvu.data_source_id  = @view_id 
		AND COALESCE(rmvu.source_system_book_id1, rmvu.source_system_book_id2, rmvu.source_system_book_id3, rmvu.source_system_book_id4) IS NULL
	
	-- Tagging/Goup Privilege instead of Book Structure
	-- Get the rights combination with the source_system_book_id1, source_system_book_id2, source_system_book_id3 and source_system_book_id4 specified in privilege
	INSERT INTO #entity_rights_combinations
	SELECT DISTINCT ssbm1.id id1, ssbm2.id id2, ssbm3.id id3, ssbm4.id id4
	FROM application_users au
	INNER JOIN report_manager_view_users rmvu ON au.user_login_id = rmvu.login_id
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(rmvu.source_system_book_id1) s) ssbm1
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(rmvu.source_system_book_id2) s) ssbm2
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(rmvu.source_system_book_id3) s) ssbm3
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(rmvu.source_system_book_id4) s) ssbm4
	WHERE au.user_login_id = dbo.FNADBUser() AND rmvu.data_source_id  = @view_id
		AND COALESCE(ssbm1.id, ssbm2.id, ssbm3.id, ssbm4.id) IS NOT NULL
	UNION
	SELECT DISTINCT ssbm1.id id1, ssbm2.id id2, ssbm3.id id3, ssbm4.id id4
	FROM application_role_user aru
	INNER JOIN report_manager_view_users rmvu ON aru.role_id = rmvu.role_id
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(rmvu.source_system_book_id1) s) ssbm1
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(rmvu.source_system_book_id2) s) ssbm2
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(rmvu.source_system_book_id3) s) ssbm3
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(rmvu.source_system_book_id4) s) ssbm4
	WHERE aru.user_login_id = dbo.FNADBUser() AND rmvu.data_source_id  = @view_id
		AND COALESCE(ssbm1.id, ssbm2.id, ssbm3.id, ssbm4.id) IS NOT NULL
END
ELSE
BEGIN
	INSERT INTO #all_entity_rights  
	SELECT DISTINCT afu.[entity_id] AS [entity_id] 
	FROM application_users
	INNER JOIN application_functional_users afu ON application_users.user_login_id = afu.login_id
	WHERE afu.function_id = @function_id
		AND afu.role_user_flag = 'u'
		AND application_users.user_login_id = dbo.FNADBUser() 
		AND COALESCE(afu.source_system_book_id1, afu.source_system_book_id2, afu.source_system_book_id3, afu.source_system_book_id4) IS NULL
	UNION 
	SELECT DISTINCT afu.[entity_id] AS [entity_id]
	FROM application_users
	INNER JOIN application_role_user ON application_users.user_login_id = application_role_user.user_login_id
	INNER JOIN application_functional_users afu ON application_role_user.role_id = afu.role_id
	WHERE afu.role_user_flag = 'r'
		AND application_users.user_login_id = dbo.FNADBUser()
		AND afu.function_id = @function_id
		AND COALESCE(afu.source_system_book_id1, afu.source_system_book_id2, afu.source_system_book_id3, afu.source_system_book_id4) IS NULL
	
	-- Get the rights combination with the source_system_book_id1, source_system_book_id2, source_system_book_id3 and source_system_book_id4 specified in privilege
	INSERT INTO #entity_rights_combinations
	SELECT DISTINCT ssbm1.id id1, ssbm2.id id2, ssbm3.id id3, ssbm4.id id4
	FROM application_users au
	INNER JOIN application_functional_users afu ON au.user_login_id = afu.login_id
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(afu.source_system_book_id1) s) ssbm1
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(afu.source_system_book_id2) s) ssbm2
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(afu.source_system_book_id3) s) ssbm3
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(afu.source_system_book_id4) s) ssbm4
	WHERE afu.role_user_flag = 'u' AND au.user_login_id = dbo.FNADBUser() AND afu.function_id = @function_id
		AND COALESCE(ssbm1.id, ssbm2.id, ssbm3.id, ssbm4.id) IS NOT NULL
	UNION
	SELECT DISTINCT ssbm1.id id1, ssbm2.id id2, ssbm3.id id3, ssbm4.id id4
	FROM application_role_user aru
	INNER JOIN application_functional_users afu ON aru.role_id = afu.role_id
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(afu.source_system_book_id1) s) ssbm1
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(afu.source_system_book_id2) s) ssbm2
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(afu.source_system_book_id3) s) ssbm3
	OUTER APPLY (SELECT s.item [id] FROM dbo.SplitCommaSeperatedValues(afu.source_system_book_id4) s) ssbm4
	WHERE afu.role_user_flag = 'r' AND aru.user_login_id = dbo.FNADBUser() AND afu.function_id = @function_id
		AND COALESCE(ssbm1.id, ssbm2.id, ssbm3.id, ssbm4.id) IS NOT NULL
END

--SELECT '' [#all_entity_rights], * FROM #all_entity_rights ORDER BY entity_id
--SELECT '' [#entity_rights_combinations], * FROM #entity_rights_combinations

-- Get the sub book entities with the rights combination
INSERT INTO #group_entity_rights
SELECT DISTINCT ssbm.book_deal_type_map_id
FROM source_system_book_map ssbm
INNER JOIN #entity_rights_combinations erc ON ISNULL(erc.id1, -1) = IIF(erc.id1 IS NULL, -1, source_system_book_id1)
	AND ISNULL(erc.id2, -1) = IIF(erc.id2 IS NULL, -1, source_system_book_id2)
	AND ISNULL(erc.id3, -1) = IIF(erc.id3 IS NULL, -1, source_system_book_id3)
	AND ISNULL(erc.id4, -1) = IIF(erc.id4 IS NULL, -1, source_system_book_id4)

--SELECT '' AS [#group_entity_rights], * FROM #group_entity_rights 

SELECT @all_count = COUNT(*) FROM #all_entity_rights
WHERE entity_id IS NULL

--this is a temporary test >> delete the following after the test ----
-- -- Use the following to test *************************
-- -- SELECT @all_count = 0
-- -- insert into #all_entity_rights values(7) --Producer 2 strategy
-- -- insert into #all_entity_rights values(10) --Nymex Hedges book
-- -- insert into #all_entity_rights values(9) --MTM 2 strategy
-- -- insert into #all_entity_rights values(21) --FX 2 strategy
-- -- --insert into #all_entity_rights values(23) --FX 2 strategy
-- -- insert into #all_entity_rights values(24) --FX 2 book
-- -- select * from #all_entity_rights
-- delete the above lines after test

--check for app admin role 1=true
DECLARE @app_admin_role_check INT
SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())

DECLARE @check_report_admin_role INT
SELECT @check_report_admin_role = ISNULL(dbo.FNAReportAdminRoleCheck(dbo.FNADBUser()), 0)

DECLARE @check_security_admin_role INT
SET @check_security_admin_role = ISNULL(dbo.FNASecurityAdminRoleCheck(dbo.FNADBUser()), 0)

SELECT @node_level = ISNULL(node_level,5) 
	FROM fas_subsidiaries
	WHERE fas_subsidiary_id = -1

-- Check if the user has Edit/Delete privilege on Setup Book Structure.
-- If yes, then all of the available portfolio hierarchy will be shown for that user.
DECLARE @calc_function_id VARCHAR(1000)

SELECT DISTINCT @calc_function_id = function_id
FROM application_functional_users
WHERE login_id = dbo.FNADBUser()
	AND function_id IN (10101210, 10101211)

If @all_count > 0
	OR @app_admin_role_check = 1
	OR @check_security_admin_role = 1
	OR (@check_report_admin_role = 1 AND @function_id >= @view_id_base_no)
	OR @function_id < 0 --TO ENTER WHEN DATA SOURCE TYPE IS SQL WHILE RUNNING REPORT FROM REPORT MANAGER TO GET ALL PORTFOLIO STRUCTURE.
	OR @calc_function_id IN (10101210, 10101211) -- Setup Book Structure Add/Save Or Delete(show all book structure)
BEGIN
	-- If no sub identified or it is an app admin user all subs are authroized
	INSERT INTO #sub_entity_rights 
	SELECT sub.entity_id AS entity_id
	FROM portfolio_hierarchy sub 
	INNER JOIN (SELECT DISTINCT sub_id FROM #filtered_porfolio_by_tags) fpbt ON sub.entity_id = fpbt.sub_id
	WHERE (sub.entity_type_value_id = 525) and sub.entity_id > 0

	--SELECT 'all'

END
ELSE
BEGIN

	--SELECT 'single'
	-- First collect all subsidiaries
	INSERT INTO #sub_entity_rights 
	SELECT #all_entity_rights.entity_id as entity_id	
	FROM #all_entity_rights 
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id =  #all_entity_rights.entity_id
	--DISTINCT is required as #filtered_porfolio_by_tags may contain duplicates
	INNER JOIN (SELECT DISTINCT sub_id FROM #filtered_porfolio_by_tags) fpbt ON sub.entity_id = fpbt.sub_id
	WHERE   (sub.entity_type_value_id = 525) and sub.entity_id > 0

	--SELECT '' [#sub_entity_rights], * FROM #sub_entity_rights

	-- now insert all strategies that are not already included above
	INSERT INTO #strategy_entity_rights 
	SELECT  #all_entity_rights.entity_id as entity_id
	FROM    #all_entity_rights
	INNER JOIN portfolio_hierarchy strategy ON strategy.entity_id =  #all_entity_rights.entity_id
	INNER JOIN  (SELECT DISTINCT stra_id FROM #filtered_porfolio_by_tags) fpbt ON strategy.entity_id = fpbt.stra_id
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = strategy.parent_entity_id 
	WHERE   (strategy.entity_type_value_id = 526) AND
		sub.entity_id not in (select entity_id from #sub_entity_rights)

	--SELECT '' [#strategy_entity_rights], * FROM #strategy_entity_rights

	-- now insert all BOOKS that are not already included above
	INSERT INTO #book_entity_rights 
	SELECT  #all_entity_rights.entity_id as entity_id
	FROM    #all_entity_rights INNER JOIN
		portfolio_hierarchy book ON book.entity_id =  #all_entity_rights.entity_id INNER JOIN
		portfolio_hierarchy strategy ON strategy.entity_id =  book.parent_entity_id  INNER JOIN
		portfolio_hierarchy sub ON sub.entity_id = strategy.parent_entity_id 
	INNER JOIN (SELECT DISTINCT book_id FROM #filtered_porfolio_by_tags) fpbt ON book.entity_id = fpbt.book_id
	WHERE   (book.entity_type_value_id = 527) AND
		(sub.entity_id not in (select entity_id from #sub_entity_rights) and
		strategy.entity_id not in (select entity_id from #strategy_entity_rights))
	
	--SELECT '' [#book_entity_rights], * FROM #book_entity_rights	

	-- Insert all sub books which are not included by Sub/Stra/Book itself


	
	INSERT INTO #sub_book_entity_rights
	SELECT ger.entity_id
	FROM #group_entity_rights ger 
	INNER JOIN #filtered_porfolio_by_tags fpbt ON ger.entity_id = fpbt.sub_book_id
	INNER JOIN source_system_book_map sub_book ON sub_book.book_deal_type_map_id = fpbt.sub_book_id
	INNER JOIN portfolio_hierarchy book ON book.[entity_id] = sub_book.fas_book_id
	INNER JOIN portfolio_hierarchy strategy ON strategy.[entity_id] = book.parent_entity_id 
	INNER JOIN portfolio_hierarchy sub ON sub.[entity_id] = strategy.parent_entity_id
	 WHERE (
	 sub.[entity_id] NOT IN (SELECT [entity_id] FROM #sub_entity_rights)
		AND strategy.[entity_id] NOT IN (SELECT [entity_id] FROM #strategy_entity_rights)
		AND book.[entity_id] NOT IN (SELECT [entity_id] FROM #book_entity_rights)
		)
	
	--SELECT '' [#sub_book_entity_rights], * FROM #sub_book_entity_rights
END

-- code for ALL option (non data are selected while giving privilege to view)
/*
IF NOT EXISTS(SELECT 1 FROM #all_entity_rights)
BEGIN 
	INSERT INTO #sub_entity_rights
	SELECT [entity_id] AS [entity_id]
	FROM  portfolio_hierarchy sub 
	WHERE   (sub.entity_type_value_id = 525) and sub.entity_id > 0
	EXCEPT
	SELECT [entity_id] FROM #sub_entity_rights
END 
*/

--TODO: Refactor using CTE to load child nodes of all levels instead of repeatative code
---Get all child node for subsidiaries which will all have rights
--load subsidiary itself
INSERT INTO #return_entity
SELECT  sub.entity_id AS entity_id, -1 AS parent_entity_id, 
	sub.entity_name AS entity_name, 1 as have_rights, 2 as node_type
FROM #sub_entity_rights 
INNER JOIN portfolio_hierarchy sub on sub.entity_id = #sub_entity_rights.entity_id
WHERE sub.entity_type_value_id = 525 and sub.entity_id > 0

--load strategy of subisiary
INSERT INTO #return_entity
SELECT  strategy.entity_id AS entity_id, strategy.parent_entity_id AS parent_entity_id, 
	strategy.entity_name AS entity_name, 1 as have_rights, 1 as node_type
FROM portfolio_hierarchy sub 
INNER JOIN #sub_entity_rights ON #sub_entity_rights.entity_id = sub.entity_id 
INNER JOIN portfolio_hierarchy strategy ON strategy.parent_entity_id = sub.entity_id
INNER JOIN (SELECT DISTINCT stra_id FROM #filtered_porfolio_by_tags)  fpbt ON strategy.entity_id = fpbt.stra_id
WHERE strategy.entity_type_value_id = 526

--load book of strategy of subsidiary
INSERT INTO #return_entity
SELECT  book.entity_id AS entity_id, book.parent_entity_id AS parent_entity_id, 
	book.entity_name AS entity_name, 1 as have_rights, 0 as node_type
FROM portfolio_hierarchy sub 
INNER JOIN #sub_entity_rights ON #sub_entity_rights.entity_id = sub.entity_id  
INNER JOIN portfolio_hierarchy strategy  ON strategy.parent_entity_id = sub.entity_id  
INNER JOIN portfolio_hierarchy book on book.parent_entity_id = strategy.entity_id
INNER JOIN (SELECT DISTINCT book_id FROM #filtered_porfolio_by_tags)  fpbt ON book.entity_id = fpbt.book_id
WHERE book.entity_type_value_id = 527

--load sub book of book of strategy of subsidiary
INSERT INTO #return_entity
SELECT ssbm.book_deal_type_map_id AS entity_id,
       book.entity_id AS parent_entity_id,
       ssbm.logical_name AS entity_name,
       1 AS have_rights,
       -1 AS node_type
FROM   #sub_entity_rights sub
		INNER JOIN portfolio_hierarchy strategy  ON strategy.parent_entity_id = sub.entity_id  
		INNER JOIN portfolio_hierarchy book on book.parent_entity_id = strategy.entity_id
		INNER JOIN source_system_book_map ssbm ON  book.entity_id = ssbm.fas_book_id
		INNER JOIN #filtered_porfolio_by_tags fpbt ON ssbm.book_deal_type_map_id = fpbt.sub_book_id
WHERE   book.entity_type_value_id = 527


--Get all parent/child nodes for strategies where only subs wont have rights
--load parent subsidiary for strategy
INSERT INTO #return_entity
SELECT sub.entity_id AS entity_id, -1 AS parent_entity_id, 
	sub.entity_name AS entity_name, 0 as have_rights, 2 as node_type
FROM portfolio_hierarchy strategy 
INNER JOIN #strategy_entity_rights ON #strategy_entity_rights.entity_id = strategy.entity_id  
INNER JOIN portfolio_hierarchy sub on sub.entity_id = strategy.parent_entity_id
WHERE sub.entity_type_value_id = 525 and sub.entity_id > 0

--load strategy itself
INSERT INTO #return_entity
SELECT strategy.entity_id AS entity_id, strategy.parent_entity_id AS parent_entity_id, 
	strategy.entity_name AS entity_name, 1 as have_rights, 1 as node_type
FROM #strategy_entity_rights 
INNER JOIN portfolio_hierarchy strategy on strategy.entity_id = #strategy_entity_rights.entity_id 
WHERE strategy.entity_type_value_id = 526

--load books of strategy
INSERT INTO #return_entity
SELECT book.entity_id AS entity_id, book.parent_entity_id AS parent_entity_id, book.entity_name AS entity_name, 1 as have_rights, 0 as node_type
FROM #strategy_entity_rights  
INNER JOIN portfolio_hierarchy strategy on strategy.entity_id = #strategy_entity_rights.entity_id  
INNER JOIN portfolio_hierarchy book on book.parent_entity_id = strategy.entity_id
INNER JOIN (SELECT DISTINCT book_id FROM #filtered_porfolio_by_tags)  fpbt ON book.entity_id = fpbt.book_id
WHERE book.entity_type_value_id = 527

--loads sub books of book of strategy
INSERT INTO #return_entity
SELECT ssbm.book_deal_type_map_id AS entity_id,
       book.entity_id AS parent_entity_id,
       ssbm.logical_name AS entity_name,
       1 AS have_rights,
       -1 AS node_type
FROM #strategy_entity_rights  
	INNER JOIN portfolio_hierarchy strategy on strategy.entity_id = #strategy_entity_rights.entity_id  
	INNER JOIN portfolio_hierarchy book on book.parent_entity_id = strategy.entity_id
	INNER JOIN source_system_book_map ssbm ON  book.entity_id = ssbm.fas_book_id
	INNER JOIN #filtered_porfolio_by_tags fpbt ON ssbm.book_deal_type_map_id = fpbt.sub_book_id
WHERE book.entity_type_value_id = 527	

--Get all child nodes for books where subs and stratgies won't have rights
--load parent subsidiary of strategy of book
INSERT INTO #return_entity
SELECT  sub.entity_id AS entity_id, -1 AS parent_entity_id, 
	sub.entity_name AS entity_name, 0 as have_rights, 2 as node_type
FROM #book_entity_rights 
INNER JOIN portfolio_hierarchy book on book.entity_id = #book_entity_rights.entity_id 
INNER JOIN portfolio_hierarchy strategy on strategy.entity_id = book.parent_entity_id 
INNER JOIN portfolio_hierarchy sub on sub.entity_id = strategy.parent_entity_id 
WHERE sub.entity_type_value_id = 525 and sub.entity_id > 0

--load parent strategy of book
INSERT INTO #return_entity
SELECT strategy.entity_id AS entity_id, strategy.parent_entity_id AS parent_entity_id, 
	strategy.entity_name AS entity_name, 0 as have_rights, 1 as node_type
FROM #book_entity_rights 
INNER JOIN portfolio_hierarchy book on book.entity_id = #book_entity_rights.entity_id 
INNER JOIN portfolio_hierarchy strategy on strategy.entity_id = book.parent_entity_id 
WHERE strategy.entity_type_value_id = 526

--load book itself
INSERT INTO #return_entity
SELECT book.entity_id AS entity_id, book.parent_entity_id AS parent_entity_id, 
	book.entity_name AS entity_name, 1 as have_rights, 0 as node_type
FROM #book_entity_rights 
INNER JOIN portfolio_hierarchy book on book.entity_id = #book_entity_rights.entity_id 
WHERE book.entity_type_value_id = 527

--loads sub books of book
INSERT INTO #return_entity
SELECT ssbm.book_deal_type_map_id AS entity_id,
       book.entity_id AS parent_entity_id,
       ssbm.logical_name AS entity_name,
       1 AS have_rights,
       -1 AS node_type
FROM   #book_entity_rights
       INNER JOIN portfolio_hierarchy book ON  book.entity_id = #book_entity_rights.entity_id
       INNER JOIN source_system_book_map ssbm ON  book.entity_id = ssbm.fas_book_id
	   INNER JOIN #filtered_porfolio_by_tags fpbt ON ssbm.book_deal_type_map_id = fpbt.sub_book_id
WHERE   book.entity_type_value_id = 527	

-- Sub Book Group Privilege Start
-- Get all parent nodes for sub books where sub/str/book won't have rights
--load parent subsidiary of strategy of book of sub book
INSERT INTO #return_entity
SELECT sub.[entity_id] AS [entity_id], -1 AS parent_entity_id, 
	sub.[entity_name] AS [entity_name], 0 AS have_rights, 2 AS node_type
FROM #sub_book_entity_rights
INNER JOIN source_system_book_map sub_book ON sub_book.book_deal_type_map_id = #sub_book_entity_rights.[entity_id]
INNER JOIN portfolio_hierarchy book ON book.[entity_id] = sub_book.fas_book_id
INNER JOIN portfolio_hierarchy strategy ON strategy.[entity_id] = book.parent_entity_id
INNER JOIN portfolio_hierarchy sub ON sub.[entity_id] = strategy.parent_entity_id 
WHERE sub.entity_type_value_id = 525 AND sub.[entity_id] > 0

--load parent strategy of book of sub book
INSERT INTO #return_entity
SELECT strategy.[entity_id] AS [entity_id], strategy.parent_entity_id AS parent_entity_id, 
	strategy.[entity_name] AS [entity_name], 0 AS have_rights, 1 AS node_type
FROM #sub_book_entity_rights 
INNER JOIN source_system_book_map sub_book ON sub_book.book_deal_type_map_id = #sub_book_entity_rights.[entity_id] 
INNER JOIN portfolio_hierarchy book ON book.[entity_id] = sub_book.fas_book_id
INNER JOIN portfolio_hierarchy strategy ON strategy.[entity_id] = book.parent_entity_id 
WHERE strategy.entity_type_value_id = 526

--load parent book of sub book
INSERT INTO #return_entity
SELECT book.[entity_id] AS [entity_id], book.parent_entity_id AS parent_entity_id, 
	book.[entity_name] AS [entity_name], 1 AS have_rights, 0 AS node_type
FROM #sub_book_entity_rights
INNER JOIN source_system_book_map sub_book ON sub_book.book_deal_type_map_id = #sub_book_entity_rights.[entity_id] 
INNER JOIN portfolio_hierarchy book ON book.[entity_id] = sub_book.fas_book_id 
WHERE book.entity_type_value_id = 527

--load sub book itself
INSERT INTO #return_entity
SELECT sub_book.book_deal_type_map_id AS [entity_id], sub_book.fas_book_id AS parent_entity_id, 
	sub_book.logical_name AS [entity_name], 1 AS have_rights, -1 AS node_type
FROM #sub_book_entity_rights
INNER JOIN source_system_book_map sub_book ON sub_book.book_deal_type_map_id = #sub_book_entity_rights.[entity_id] 
-- Sub Book Group Privilege End

CREATE NONCLUSTERED INDEX NCI_RE_EID ON #return_entity (entity_id)
CREATE NONCLUSTERED INDEX NCI_RE_PEID ON #return_entity (parent_entity_id)

--SELECT '' [#return_entity], *  FROM #return_entity

IF OBJECT_ID('tempdb..#temp_privileges') IS NOT NULL
	DROP TABLE #temp_privileges
	
SELECT DISTINCT afu.function_id, sub.entity_id --,sub.entity_name,afu.login_id,aru.user_login_id,sub.create_user
INTO #temp_privileges
FROM portfolio_hierarchy sub 
LEFT JOIN application_functional_users afu
	ON ISNULL(afu.entity_id, -1) = ISNULL(sub.entity_id, -1)
LEFT JOIN application_functions af
	ON af.function_id = afu.function_id
LEFT JOIN application_security_role asr
	ON afu.role_id = asr.role_id
LEFT JOIN application_role_user aru
	ON aru.role_id = asr.role_id
WHERE ((afu.login_id = @user_name OR aru.user_login_id = @user_name) AND afu.function_id IN (@function_id, @add_save_function_id, @delete_function_id))

--SELECT '' [#temp_privileges], * from #temp_privileges



--SELECT '' [#return_entity], * FROM #return_entity re

Declare @sub_level_json NVARCHAR(MAX), 
@stra_level_json NVARCHAR(MAX) 
SET @sub_level_json = (SELECT '[' + STUFF((
						SELECT 
							',{"subsidiary_id":' + '"a_' + CAST(fas_subsidiary_id AS NVARCHAR(20)) + '"'
							+ ',"node_level":' +  CAST(ISNULL(node_level, 4) AS NVARCHAR(20)) 
							+'}'

						FROM fas_subsidiaries fs
						INNER JOIN #return_entity re
							ON re.entity_id = fs.fas_subsidiary_id
						WHERE fs.fas_subsidiary_id <> - 1
								AND node_type = 2
						FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(max)'), 1, 1, '') + ']') 

SET @stra_level_json = (SELECT '[' + STUFF((
						SELECT 
							',{"strategy_id":' + '"b_' + CAST(fas_strategy_id AS NVARCHAR(20)) + '"'
							+ ',"node_level":' +  CAST(ISNULL(node_level, 3) AS NVARCHAR(20)) 
							+'}'

						FROM fas_strategy fs
						INNER JOIN #return_entity re
							ON re.entity_id = fs.fas_strategy_id
						WHERE node_type = 1
						AND fs.node_level IS NOT NULL
						FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(max)'), 1, 1, '') + ']') 

IF @flag = 'z'
BEGIN
	IF @include_subbook = 'n'
	BEGIN
		DELETE FROM #return_entity WHERE node_type = -1
	END
	
	

	DECLARE @book_process_table NVARCHAR(200), @process_id NVARCHAR(100) = dbo.FNAGetNewID()	
	SET @book_process_table = dbo.FNAProcessTableName('book_structure', @user_name, @process_id)
	
	
	IF OBJECT_ID('tempdb..#temp_book_privilege') IS NOT NULL
		DROP TABLE #temp_book_privilege
	
	SELECT sub_book.entity_id [sub_book_id], book.entity_id [book_id], stra.entity_id [stra_id], sub.entity_id [sub_id], 0 [function_id], 0 add_function_id, 0 delete_function_id
	INTO #temp_book_privilege
	FROM #return_entity sub_book
	OUTER APPLY (
		SELECT book.entity_id, book.parent_entity_id
		FROM #return_entity book 
		WHERE book.entity_id = sub_book.parent_entity_id
		AND book.node_type = 0
	) book
	OUTER APPLY (
		SELECT stra.entity_id, stra.parent_entity_id
		FROM #return_entity stra 
		WHERE stra.entity_id = book.parent_entity_id
		AND stra.node_type = 1
	) stra
	OUTER APPLY (
		SELECT sub.entity_id, sub.parent_entity_id
		FROM #return_entity sub 
		WHERE sub.entity_id = stra.parent_entity_id
		AND sub.node_type = 2
	) sub
	WHERE node_type = -1	
	
	UPDATE temp
	SET function_id = ISNULL(temp_r.has_privilege, 0)
	FROM #temp_book_privilege temp
	OUTER APPLY (
		SELECT 1 has_privilege, afu.entity_id 
		FROM application_role_user aru
		INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
		INNER JOIN application_functional_users afu 
			ON afu.role_id = aru.role_id
			AND afu.function_id = @function_id
		WHERE aru.user_login_id = @user_name 
		AND	(
				(
					(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
					AND afu.entity_id IS NOT NULL
				)
			OR afu.entity_id IS NULL
		)
	) temp_r

	UPDATE temp
	SET add_function_id = ISNULL(temp_r.has_privilege, 0)
	FROM #temp_book_privilege temp
	OUTER APPLY (
		SELECT 1 has_privilege, afu.entity_id 
		FROM application_role_user aru
		INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
		INNER JOIN application_functional_users afu 
			ON afu.role_id = aru.role_id
			AND afu.function_id = @add_save_function_id
		WHERE aru.user_login_id = @user_name
		AND	(
				(
					(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
					AND afu.entity_id IS NOT NULL
				)
			OR afu.entity_id IS NULL
		)
	) temp_r

	UPDATE temp
	SET delete_function_id = ISNULL(temp_r.has_privilege, 0)
	FROM #temp_book_privilege temp
	OUTER APPLY (
		SELECT 1 has_privilege, afu.entity_id 
		FROM application_role_user aru
		INNER JOIN application_security_role asr ON asr.role_id = aru.role_id
		INNER JOIN application_functional_users afu 
			ON afu.role_id = aru.role_id
			AND afu.function_id = @delete_function_id
		WHERE aru.user_login_id = @user_name
		AND	(
				(
					(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
					AND afu.entity_id IS NOT NULL
				)
			OR afu.entity_id IS NULL
		)
	) temp_r


	UPDATE temp
	SET function_id = ISNULL(temp_r.has_privilege, 0)
	FROM #temp_book_privilege temp
	OUTER APPLY (
		SELECT 1 has_privilege
		FROM application_functional_users afu 
		WHERE afu.function_id = @function_id
		AND afu.login_id = @user_name
		AND	(
				(
					(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
					AND afu.entity_id IS NOT NULL
				)
			OR afu.entity_id IS NULL
		)
	) temp_r
	WHERE ISNULL(temp.function_id, 0) = 0

	UPDATE temp
	SET add_function_id = ISNULL(temp_r.has_privilege, 0)
	FROM #temp_book_privilege temp
	OUTER APPLY (
		SELECT 1 has_privilege
		FROM application_functional_users afu 
		WHERE afu.function_id = @add_save_function_id
		AND afu.login_id = @user_name
		AND	(
				(
					(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
					AND afu.entity_id IS NOT NULL
				)
			OR afu.entity_id IS NULL
		)
	) temp_r
	WHERE ISNULL(temp.add_function_id, 0) = 0

	UPDATE temp
	SET delete_function_id = ISNULL(temp_r.has_privilege, 0)
	FROM #temp_book_privilege temp
	OUTER APPLY (
		SELECT 1 has_privilege
		FROM application_functional_users afu 
		WHERE afu.function_id = @delete_function_id
		AND afu.login_id = @user_name
		AND	(
				(
					(afu.entity_id = temp.book_id OR afu.entity_id = temp.stra_id OR afu.entity_id = temp.sub_id) 
					AND afu.entity_id IS NOT NULL
				)
			OR afu.entity_id IS NULL
		)
	) temp_r
	WHERE ISNULL(temp.delete_function_id, 0) = 0	
	
	SET @sql_stmt = '
		SELECT ''x_1'' entity_id, ''0'' parent_entity_id, entity_name, ''company_small.gif'' im0, ''company_small.gif'' im1, ''company_small.gif'' im2, NULL privilege
		INTO ' + @book_process_table + '
		FROM portfolio_hierarchy where entity_id=-1

		UNION ALL
		SELECT CASE WHEN node_type = 2 THEN ''a_'' + CAST(entity_id AS NVARCHAR(20))
					WHEN node_type = 1 THEN ''b_'' + CAST(entity_id AS NVARCHAR(20))
					WHEN node_type = 0 THEN ''c_'' + CAST(entity_id AS NVARCHAR(20))
					WHEN node_type = -1 THEN ''d_'' + CAST(entity_id AS NVARCHAR(20))
				END,
			   CASE WHEN parent_entity_id = -1 THEN ''x_1''
					WHEN node_type = 2 THEN ''x_1''
					WHEN node_type = 1 THEN ''a_'' + CAST(parent_entity_id AS NVARCHAR(20))
					WHEN node_type = 0 THEN ''b_'' + CAST(parent_entity_id AS NVARCHAR(20))
					WHEN node_type = -1 THEN ''c_'' + CAST(parent_entity_id AS NVARCHAR(20))
				END,
			   entity_name,
			   CASE WHEN node_type = 2 THEN ''subsidiary_open.gif''
					WHEN node_type = 1 THEN ''strategy_open.gif''
					WHEN node_type = 0 THEN ''book_open.gif''
					WHEN node_type = -1 THEN ''leaf.gif''
				END,
				CASE WHEN node_type = 2 THEN ''subsidiary_open.gif''
					WHEN node_type = 1 THEN ''strategy_open.gif''
					WHEN node_type = 0 THEN ''book_open.gif''
					WHEN node_type = -1 THEN NULL
				END,
				CASE WHEN node_type = 2 THEN ''subsidiary_close.gif''
					WHEN node_type = 1 THEN ''strategy_close.gif''
					WHEN node_type = 0 THEN ''book_close.gif''
					WHEN node_type = -1 THEN NULL
				END,
				CAST(t1.function_id AS NVARCHAR(10)) + '','' + 	CAST(t1.add_function_id AS NVARCHAR(10))	+ '','' + 	CAST(t1.delete_function_id AS NVARCHAR(10))	[privilege]				
		FROM #return_entity r
		LEFT JOIN #temp_book_privilege t1 ON r.entity_id = t1.sub_book_id AND r.node_type = -1
	
	
	'
	
	EXEC(@sql_stmt)
	SELECT @book_process_table [process_table], @node_level [node_level], ISNULL(@sub_level_json,'{}') [sub_level_json], ISNULL(@stra_level_json,'{}') [stra_level_json]
	RETURN
END

IF @flag = 'x'
-- Return tree XML for use in DHTMLX components (Sub Book Nodes are hidden)
/*
@XML returned will be :
 <tree id="0">
  <item text="Subsidiary" id="1">
    <item text="Strategy" id="2">
      <item text="Book" id="3">
        <item text="Sub Book" id="4" />
      </item>
    </item>
  </item>
</tree>
*/
BEGIN

	DECLARE @company NVARCHAR(100)
	SELECT @company = entity_name FROM portfolio_hierarchy where entity_id=-1
	DECLARE @XML NVARCHAR(MAX)
	SELECT @XML = 
	(
		SELECT '0' AS [@id],
		(
			(SELECT entity_name AS [@text], 'x_1' AS[@id], 'company_small.gif' AS[@im0], 'company_small.gif' AS[@im1], 'company_small.gif' AS[@im2],
				(SELECT entity_name AS [@text], 'a_' + CAST(entity_id AS NVARCHAR) AS[@id], 'subsidiary_open.gif' AS[@im0], 'subsidiary_open.gif' AS[@im1], 'subsidiary_close.gif' AS[@im2],
					(SELECT entity_name AS [@text], 'b_' + CAST(entity_id AS NVARCHAR) AS[@id], 'strategy_open.gif' AS[@im0], 'strategy_open.gif' AS[@im1], 'strategy_close.gif' AS[@im2],
						(SELECT DISTINCT entity_name AS [@text], 'c_' + CAST(entity_id AS NVARCHAR) AS[@id], 'book_open.gif' AS[@im0], 'book_open.gif' AS[@im1], 'book_close.gif' AS[@im2]
							--(SELECT DISTINCT  entity_name AS [@text], 'd_' + CAST(entity_id AS NVARCHAR) AS [@id], 'leaf.gif' AS[@im0] FROM #return_entity d WHERE node_type=-1 AND c.entity_id = d.parent_entity_id
							--	ORDER BY entity_name
							--	FOR XML Path('item'), Type              
							--)							
							FROM (SELECT DISTINCT  entity_id, entity_name, parent_entity_id FROM #return_entity WHERE node_type=0) c
							WHERE b.entity_id = c.parent_entity_id ORDER BY entity_name           
							FOR XML PATH('item'), TYPE
						)    
						FROM (SELECT DISTINCT  entity_id, entity_name, parent_entity_id FROM #return_entity WHERE node_type=1) b
						WHERE a.entity_id = b.parent_entity_id ORDER BY entity_name           
						FOR XML PATH('item'), TYPE
					)
				FROM (SELECT DISTINCT entity_id, entity_name FROM #return_entity WHERE node_type=2) a ORDER BY entity_name
				FOR XML PATH('item'), TYPE
				)		
			FROM (SELECT DISTINCT entity_id, entity_name FROM portfolio_hierarchy where entity_id=-1) a ORDER BY entity_name
			FOR XML PATH('item'), TYPE
			)	
		) FOR XML PATH('tree')
	)

	SELECT REPLACE(@XML, '''', '!colon!') as xml_value, @node_level [node_level], ISNULL(@sub_level_json,'{}') [sub_level_json], ISNULL(@stra_level_json,'{}') [stra_level_json]
	RETURN
END

IF @flag = 'y'


-- Return tree XML for use in DHTMLX components (Sub Book Nodes are shown)
/*
@XML returned will be :
 <tree id="0">
  <item text="Subsidiary" id="1">
    <item text="Strategy" id="2">
      <item text="Book" id="3">
        <item text="Sub Book" id="4" />
      </item>
    </item>
  </item>
</tree>
*/
BEGIN
	DECLARE @company_y NVARCHAR(100)
	SELECT @company_y = entity_name FROM portfolio_hierarchy where entity_id=-1
	DECLARE @XML_y NVARCHAR(MAX)
	SELECT @XML_y =  
	(
		SELECT '0' AS [@id],
		(
			(SELECT entity_name AS [@text], 'x_1' AS[@id], 'company_small.gif' AS[@im0], 'company_small.gif' AS[@im1], 'company_small.gif' AS[@im2],
				(SELECT entity_name AS [@text], 'a_' + CAST(entity_id AS NVARCHAR) AS[@id], 'subsidiary_open.gif' AS[@im0], 'subsidiary_open.gif' AS[@im1], 'subsidiary_close.gif' AS[@im2],
					(SELECT entity_name AS [@text], 'b_' + CAST(entity_id AS NVARCHAR) AS[@id], 'strategy_open.gif' AS[@im0], 'strategy_open.gif' AS[@im1], 'strategy_close.gif' AS[@im2],
						(SELECT entity_name AS [@text], 'c_' + CAST(entity_id AS NVARCHAR) AS[@id], 'book_open.gif' AS[@im0], 'book_open.gif' AS[@im1], 'book_close.gif' AS[@im2],
							(SELECT   entity_name AS [@text], 'd_' + CAST(entity_id AS NVARCHAR) AS [@id], 'leaf.gif' AS[@im0], 
								(	SELECT name AS [userdata/@name], val AS userdata FROM (SELECT DISTINCT 'privilege' AS name, 
													CASE WHEN aa.function_id IS NOT NULL THEN '1' ELSE '0' END + ',' +
													CASE WHEN bb.function_id IS NOT NULL THEN '1' ELSE '0' END + ',' +
													CASE WHEN cc.function_id IS NOT NULL THEN '1' ELSE '0' END AS val
									FROM (
										SELECT DISTINCT temp.function_id function_id,sub.entity_name 
										FROM portfolio_hierarchy sub 
										LEFT JOIN #temp_privileges temp ON sub.entity_id = temp.entity_id
										WHERE 1 =1
											--AND ISNULL(temp.function_id, @function_id) = @function_id
											AND temp.function_id = @function_id
											AND (sub.entity_name IN (c.entity_name, b.entity_name, a.entity_name) OR temp.entity_id= -1)
										) aa
									OUTER APPLY (
										SELECT DISTINCT temp.function_id function_id
										FROM portfolio_hierarchy sub 
										LEFT JOIN #temp_privileges temp ON sub.entity_id = temp.entity_id
										WHERE 1 =1
											AND temp.function_id = @add_save_function_id
											--AND ISNULL(temp.function_id, @add_save_function_id) = @add_save_function_id
											AND (sub.entity_name IN (c.entity_name, b.entity_name, a.entity_name) OR temp.entity_id= -1)										
										) bb
									OUTER APPLY (
										SELECT DISTINCT temp.function_id function_id,sub.entity_name ,temp.entity_id
										FROM portfolio_hierarchy sub 
										LEFT JOIN #temp_privileges temp ON sub.entity_id = temp.entity_id
										WHERE 1 =1
											AND temp.function_id = @delete_function_id
											--AND ISNULL(temp.function_id,  @delete_function_id) = @delete_function_id
											AND (sub.entity_name IN (c.entity_name, b.entity_name, a.entity_name) OR temp.entity_id= -1)
										) cc
									UNION 
									SELECT 'privilege' AS [@name], '1,1,1' val WHERE @app_admin_role_check = 1
									) dd
									FOR XML Path(''), Type                
							)
								FROM #return_entity d WHERE node_type=-1 AND c.entity_id = d.parent_entity_id
								ORDER BY entity_name
								FOR XML Path('item'), Type              
							)
							FROM (SELECT DISTINCT  entity_id, entity_name, parent_entity_id FROM #return_entity WHERE node_type=0) c	--book
							WHERE b.entity_id = c.parent_entity_id ORDER BY entity_name          
							FOR XML PATH('item'), TYPE
						)    
						FROM (SELECT DISTINCT  entity_id, entity_name, parent_entity_id FROM #return_entity WHERE node_type=1) b	--strategy
						WHERE a.entity_id = b.parent_entity_id ORDER BY entity_name           
						FOR XML PATH('item'), TYPE
					)
				FROM (SELECT DISTINCT entity_id, entity_name FROM #return_entity WHERE node_type=2) a ORDER BY entity_name		--subsidiary
				FOR XML PATH('item'), TYPE
				)		
			FROM (SELECT DISTINCT entity_id, entity_name FROM portfolio_hierarchy where entity_id=-1) a ORDER BY entity_name	--company name
			FOR XML PATH('item'), TYPE)	
		) FOR XML PATH('tree') 
	)
	SELECT REPLACE(@XML_y, '''', '!colon!') as xml_value, @node_level [node_level], ISNULL(@sub_level_json,'{}') [sub_level_json], ISNULL(@stra_level_json,'{}') [stra_level_json]
	RETURN
END


------- now sort the results and return distinct nodes only
/*
* For Subsidiaries (depth: 0), sort_number will be 00001, 00002.....
* For Strategies (depth: 1), sort_number will be 0000100001, 0000100002..., 0000200001...
* For Books (depth: 2), sort_number will be 000010000100001, 000010000100002..., 000010000200001..., 000020000100001
* 
* 00001
*	0000100001
*		000010000100001
*		000010000100002
*	0000100002
*		000010000200001
*		000010000200002
*		000010000200003
* 00002
*	0000200001
*		000020000100001
*		000020000100002
*
* Each hierarchy has been allocated 5 digit number with min 00001 to max 99999. Making sort_number
* of fixed length will make them sortable.
*/

/*
* --TODO: new logic has some problems, it doesn't remove duplicate items
;WITH cte_ph (entity_id, entity_name, have_rights, node_type, depth, sort_number) AS 
(
	--get all subsidiaries
	SELECT DISTINCT entity_id, CAST(entity_name + '|' AS NVARCHAR(1000)) AS entity_name, have_rights, node_type, 0 AS depth
	, CAST(RIGHT('000000' + CAST(ROW_NUMBER() OVER(ORDER BY entity_name) AS NVARCHAR(5)), 5) AS NVARCHAR(MAX)) AS sort_number
	FROM #return_entity 
	WHERE node_type = 2 
	
	UNION ALL
	
	SELECT ph.entity_id, CAST(cte_ph.entity_name + ph.entity_name + (CASE WHEN cte_ph.depth >= 1 THEN '' ELSE '|' END) AS NVARCHAR(1000)), ph.have_rights, ph.node_type, (cte_ph.depth + 1) AS depth
	, CAST(sort_number + RIGHT('000000' + CAST(ROW_NUMBER() OVER(ORDER BY ph.entity_name) AS NVARCHAR(5)), 5) AS NVARCHAR(MAX))
	FROM #return_entity ph
	INNER JOIN cte_ph ON cte_ph.entity_id = ph.parent_entity_id AND ph.node_type <> 2
)
SELECT entity_id, entity_name, have_rights, node_type,ssd.source_system_name [sourcesystem]
FROM cte_ph
LEFT JOIN fas_strategy fs ON fs.fas_strategy_id=cte_ph.entity_id
LEFT JOIN source_system_description ssd ON ssd.source_system_id=fs.source_system_id 
ORDER BY sort_number;
*/


--old logic to sort the result

--SELECT '' [#return_entity], * FROM #return_entity
--RETURN


DECLARE @entity_id int, @parent_entity_id int, @entity_name NVARCHAR(1000),
	@have_rights int, @node_type int, @sub_entity_name NVARCHAR(1000), 
	@str_entity_name NVARCHAR(1000), @book_entity_name NVARCHAR(1000), @source_book_map_name NVARCHAR(2000)

DECLARE	@sub_entity_id int, @strategy_entity_id INT, @book_entity_id INT

DECLARE sub_cursor CURSOR FOR
select entity_id, parent_entity_id, entity_name, node_type, max(have_rights) as have_rights
from #return_entity
where node_type = 2
group by entity_id, parent_entity_id, entity_name, node_type
order by entity_name

OPEN sub_cursor

FETCH NEXT FROM sub_cursor
INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights

WHILE @@FETCH_STATUS = 0   -- sub
BEGIN 

SET @sub_entity_name = @entity_name
SET @sub_entity_id = @entity_id
INSERT INTO #sorted_return_entity values(@entity_id, @parent_entity_id, @entity_name + '|' , @have_rights, @node_type)

	DECLARE strategy_cursor CURSOR FOR
	select entity_id, parent_entity_id, entity_name, node_type, max(have_rights) as have_rights
	from #return_entity
	where node_type = 1 AND parent_entity_id = @sub_entity_id
	group by entity_id, parent_entity_id, entity_name, node_type
	order by entity_name
	
	OPEN strategy_cursor
	
	FETCH NEXT FROM strategy_cursor
	INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights

	WHILE @@FETCH_STATUS = 0   -- strategy
	BEGIN 

		SET @str_entity_name = @entity_name
		SET @strategy_entity_id = @entity_id
		INSERT INTO #sorted_return_entity values(@entity_id, @parent_entity_id, @sub_entity_name + '|' + @entity_name + '|' , @have_rights, @node_type)
	
		DECLARE book_cursor CURSOR FOR
		select entity_id, parent_entity_id, entity_name, node_type, max(have_rights) as have_rights
		from #return_entity
		where node_type = 0 AND parent_entity_id = @strategy_entity_id
		group by entity_id, parent_entity_id, entity_name, node_type
		order by entity_name
		
		OPEN book_cursor
		
		FETCH NEXT FROM book_cursor
		INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights
	
		WHILE @@FETCH_STATUS = 0   -- book
		BEGIN 
			SET @book_entity_id = @entity_id
			SET @book_entity_name = @entity_name
			INSERT INTO #sorted_return_entity values(@entity_id, @parent_entity_id, @sub_entity_name + '|' + @str_entity_name + '|' + @entity_name, @have_rights, @node_type)
			
			DECLARE source_book_map_cursor CURSOR FOR 
			SELECT entity_id,
			       parent_entity_id,
			       entity_name,
			       node_type,
			       MAX(have_rights) AS have_rights
			FROM   #return_entity
			WHERE  node_type = -1 AND parent_entity_id = @book_entity_id
			GROUP BY entity_id, parent_entity_id, entity_name, node_type
			ORDER BY entity_name
			
			OPEN source_book_map_cursor
			
			FETCH NEXT FROM source_book_map_cursor
			INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights
			
			WHILE @@FETCH_STATUS = 0 -- source_book_maping
			BEGIN
				SET @source_book_map_name = @entity_name
				INSERT INTO #sorted_return_entity values(@entity_id, @parent_entity_id, @sub_entity_name + '|' + @str_entity_name + '|' + @book_entity_name + '|' + @entity_name, @have_rights, @node_type)
				
				FETCH NEXT FROM source_book_map_cursor
				INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights
				
			END
			CLOSE source_book_map_cursor
			DEALLOCATE  source_book_map_cursor
			
			FETCH NEXT FROM book_cursor
			INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights
		END -- end book
		CLOSE book_cursor
		DEALLOCATE  book_cursor
	
		FETCH NEXT FROM strategy_cursor
		INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights
	END  -- end strategy
	CLOSE strategy_cursor
	DEALLOCATE  strategy_cursor

FETCH NEXT FROM sub_cursor
INTO @entity_id, @parent_entity_id, @entity_name, @node_type, @have_rights
END  -- end sub
CLOSE sub_cursor
DEALLOCATE  sub_cursor

--SELECT '' [#sorted_return_entity], entity_id, parent_entity_id, entity_name, have_rights, node_type FROM #sorted_return_entity

IF @flag = 'm'  -- used for mobile book-structure
BEGIN
	SELECT ph.entity_id, entity_name, ph.[have_rights], ph.[node_type], ph.[sourcesystem], ph.next_id
		FROM (SELECT DISTINCT entity_id, entity_name, 1 [have_rights], 3 [node_type], NULL [sourcesystem], 0 next_id FROM portfolio_hierarchy where entity_id=-1) ph
	UNION
	SELECT entity_id, entity_name, have_rights, node_type, ssd.source_system_name [sourcesystem], next_id
	FROM #sorted_return_entity sre
	LEFT JOIN fas_strategy fs ON fs.fas_strategy_id=sre.entity_id
	LEFT JOIN source_system_description ssd ON ssd.source_system_id=fs.source_system_id 
	order by next_id
END 
ELSE
BEGIN
	SELECT entity_id, entity_name, have_rights, node_type, ssd.source_system_name [sourcesystem]
	FROM #sorted_return_entity sre
	LEFT JOIN fas_strategy fs ON fs.fas_strategy_id=sre.entity_id
	LEFT JOIN source_system_description ssd ON ssd.source_system_id=fs.source_system_id 
	order by next_id

	--order by parent_entity_id +  node_type + entity_id desc
END


IF @flag = 'k'
BEGIN
	SELECT entity_id, entity_name
	FROM #sorted_return_entity sre
	LEFT JOIN fas_strategy fs ON fs.fas_strategy_id=sre.entity_id
	LEFT JOIN source_system_description ssd ON ssd.source_system_id=fs.source_system_id 

END

