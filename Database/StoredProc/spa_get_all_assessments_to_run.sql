

IF OBJECT_ID('[dbo].[spa_get_all_assessments_to_run]') IS NOT NULL
	DROP  PROCEDURE [dbo].[spa_get_all_assessments_to_run]
GO

--This gets all assessment that has to be run
-- exec spa_get_all_assessments_to_run NULL, NULL, NULL, NULL, 'n'
-- exec spa_get_all_assessments_to_run NULL, null, '304', NULL
-- exec spa_get_all_assessments_to_run NULL, null, '300', NULL

-- exec spa_get_all_assessments_to_run '1', NULL, '216', NULL, 'y'
-- exec spa_get_all_assessments_to_run '30', '228', NULL, NULL
create PROCEDURE [dbo].[spa_get_all_assessments_to_run]  
	@subId varchar(MAX),
	@strategyId varchar(MAX) = NULL,
	@bookId varchar(MAX) = NULL,
	@assessmentId varchar(5000) = NULL,
	@internal_call varchar(1) = 'n'
AS
 
--  DECLARE @subId varchar(100)
--  DECLARE @strategyId varchar(100)
--  DECLARE @bookId varchar(100)
--  DECLARE @assessmentId varchar(100)
--  DECLARE @internal_call varchar(1)
--  SET @subId = null
--  SET @strategyId = null
--  SET @bookId = 126
--  SET @assessmentId = null
--  SET @internal_call = 'y'
--  drop table #temp

DECLARE @selectStmt1  VARCHAR(8000)
DECLARE @selectStmt2  VARCHAR(8000)
DECLARE @selectStmt3  VARCHAR(8000)
DECLARE @selectStmt4  VARCHAR(8000)
DECLARE @addWhereStmt  VARCHAR(8000)


SET @assessmentId = '''' + REPLACE (REPLACE(@assessmentId, ' ', ''), ',' , ''',''') + ''''


EXEC (@selectStmt1)
-- EXEC spa_print ('select eff_test_profile_id from fas_eff_hedge_rel_type where 
--    (cast(eff_test_profile_id as varchar) + cast(''-11'' as varchar)) IN (' + @assessmentId + ')' )

CREATE TABLE #TEMP(
eff_test_profile_id int,
link_id int,
calc_level int,
Id varchar(8000) COLLATE DATABASE_DEFAULT ,
[Name] varchar(8000) COLLATE DATABASE_DEFAULT ,
[Description] varchar(2500) COLLATE DATABASE_DEFAULT 
)


SET @addWhereStmt = ''

SET @selectStmt1 = 'INSERT INTO #TEMP	Select distinct (rtype.eff_test_profile_id) as  eff_test_profile_id, 
			-1 as link_id, 1 as calc_level,
			cast(rtype.eff_test_profile_id as varchar) + ''-11'' AS Id,
			eff_test_name AS [Name],
			dbo.FNATRMWinHyperlink(''a'', 10231900, (cast(eff_test_profile_id as varchar) + ''- '' + eff_test_name), ABS(eff_test_profile_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [Description]
			--dbo.FNAHyperLinkText(10232000, (cast(eff_test_profile_id as varchar) + ''- '' + eff_test_name), eff_test_profile_id) AS Description 		 
		FROM fas_eff_hedge_rel_type rtype INNER JOIN 
		--fas_link_header on fas_link_header.eff_test_profile_id =  rtype.eff_test_profile_id INNER JOIN
		portfolio_hierarchy book ON  rtype.fas_book_id = book.entity_id  INNER JOIN 
		portfolio_hierarchy strat ON book.parent_entity_id = strat.entity_id  INNER JOIN 
		portfolio_hierarchy sub  ON strat.parent_entity_id = sub.entity_id 
		WHERE 		profile_approved = ''y'' and profile_active = ''y'' and 
		(individual_link_calc IS NULL OR individual_link_calc = ''n'')
	'
        
If @subId IS NOT NULL 
   SET @addWhereStmt = @addWhereStmt +  ' AND sub.entity_id in  (' + @subId + ')'
If @strategyId IS NOT NULL 
   SET @addWhereStmt = @addWhereStmt +  ' AND strat.entity_id in  (' + @strategyId + ')'
If @bookId IS NOT NULL 
   SET @addWhereStmt = @addWhereStmt +  ' AND book.entity_id in  (' + @bookId + ')'
-- If @assessmentId IS NOT NULL 
--    SET @addWhereStmt = @addWhereStmt +  ' AND type.eff_test_profile_id in  (' + @assessmentId + ')'

--print @selectStmt

SET @selectStmt1 = @selectStmt1 + @addWhereStmt

SET @selectStmt2 = 'Select flh.eff_test_profile_id, 
		flh.link_id, 
		2 as calc_level,
		cast(flh.eff_test_profile_id as varchar) + cast(flh.link_id as varchar) + ''2'' As [Id],
		(cast(flh.link_id as varchar) + ''- '' + flh.link_description + 
		'' ('' + cast(rel.eff_test_profile_id as varchar) + ''- '' + eff_test_name + '')'') AS Name,

		dbo.FNATRMWinHyperlink(''a'', 10233700, (cast(flh.link_id as varchar) + ''- '' + flh.link_description + 
		'' ('' + cast(rel.eff_test_profile_id as varchar) + '': '' + eff_test_name + '')''), ABS(flh.link_id),null,null,null,null,null,null,null,null,null,null,null,0) AS Description

	--dbo.FNAHyperLinkText(10233710, (cast(flh.link_id as varchar) + ''- '' + flh.link_description + 
	--	'' ('' + cast(rel.eff_test_profile_id as varchar) + '': '' + eff_test_name + '')''), flh.link_id) 
		from fas_link_header flh INNER JOIN  
		(Select distinct(eff_test_profile_id) as  eff_test_profile_id, eff_test_name
		from fas_eff_hedge_rel_type rtype INNER JOIN  
		portfolio_hierarchy book ON  rtype.fas_book_id = book.entity_id  INNER JOIN 
		portfolio_hierarchy strat ON book.parent_entity_id = strat.entity_id  INNER JOIN 
		fas_strategy fs ON fs.fas_strategy_id = strat.entity_id  INNER JOIN 
		portfolio_hierarchy sub  ON strat.parent_entity_id = sub.entity_id 
		WHERE 	profile_approved = ''y'' and profile_active = ''y'' and 
		(individual_link_calc IS NOT NULL AND individual_link_calc = ''y'')' + 
		@addWhereStmt + ') rel ON rel.eff_test_profile_id = flh.eff_test_profile_id
	where flh.link_type_value_id = 450 --and isnull(fully_dedesignated, ''n'') <> ''y''
'


--SET @selectStmt2 = @selectStmt2 
--print @selectStmt1 + ' UNION  ' + @selectStmt2

 -- we will always have it at the book level
SET @selectStmt3 = 'Select max(coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)) no_links_fas_eff_test_profile_id, 
		-1 * fs.fas_strategy_id link_id, 
		2 as calc_level,
		max(cast(coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) as varchar) + cast(-1 * fs.fas_strategy_id as varchar) + ''2'') As [Id],
		max(eff_test_name + '' for Strategy ('' +  cast(-1 * fs.fas_strategy_id as varchar) + '') '' + strat.entity_name) AS [Name],
		--max(dbo.FNAHyperLinkText(10232000, (cast(fs.no_links_fas_eff_test_profile_id as varchar) + ''- '' + eff_test_name + '' for Strategy ('' +  cast(-1 * fs.fas_strategy_id as varchar) + ''): '' + strat.entity_name), 
		--	fs.no_links_fas_eff_test_profile_id)) AS Description 		 
		
		max(dbo.FNATRMWinHyperlink(''a'', 10232000, (cast(fs.no_links_fas_eff_test_profile_id as varchar) + ''- '' + eff_test_name + '' for Strategy ('' +  cast(-1 * fs.fas_strategy_id as varchar) + ''): '' + strat.entity_name), ABS(fs.no_links_fas_eff_test_profile_id),null,null,null,null,null,null,null,null,null,null,null,0)) AS Description

		from	portfolio_hierarchy book INNER JOIN
				portfolio_hierarchy strat ON strat.entity_id = book.parent_entity_id  INNER JOIN 
				portfolio_hierarchy sub ON sub.entity_id = strat.parent_entity_id  INNER JOIN 				
				fas_strategy fs ON fs.fas_strategy_id = strat.entity_id INNER JOIN
				fas_books fb ON fb.fas_book_id = book.entity_id  INNER JOIN
				fas_eff_hedge_rel_type rtype ON rtype.eff_test_profile_id = coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)
		where   profile_approved = ''y'' and profile_active = ''y'' and 
				fs.hedge_type_value_id IN (150, 151) AND 
				(fs.mes_gran_value_id = 178 )
		
		'
SET @selectStmt3 = @selectStmt3 + @addWhereStmt + ' group by fs.fas_strategy_id '

--print @selectStmt3

SET @selectStmt4 = 'Select coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) no_links_fas_eff_test_profile_id, 
		-1 * fb.fas_book_id  link_id, 
		2 as calc_level,
		cast (coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) as varchar) + 
				cast (-1 * fb.fas_book_id as varchar) +
			''2'' Id, 
		eff_test_name + '' for Book  ('' +  cast(-1 * book.entity_id as varchar) + '') '' + book.entity_name AS [Name],
		--dbo.FNAHyperLinkText(10232000, (cast(coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) as varchar) 
		--		+ ''- '' + eff_test_name + '' for Book: ('' +  cast(-1 * book.entity_id as varchar) + ''): '' + book.entity_name ), 
		--	coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)) AS Description 
		
		dbo.FNATRMWinHyperlink(''a'', 10232000, (cast(coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) as varchar) 
				+ ''- '' + eff_test_name + '' for Book: ('' +  cast(-1 * book.entity_id as varchar) + ''): '' + book.entity_name ), ABS(coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)),null,null,null,null,null,null,null,null,null,null,null,0) AS Description


		from	portfolio_hierarchy book INNER JOIN
				portfolio_hierarchy strat ON strat.entity_id = book.parent_entity_id  INNER JOIN 
				portfolio_hierarchy sub ON sub.entity_id = strat.parent_entity_id  INNER JOIN 				
				fas_strategy fs ON fs.fas_strategy_id = strat.entity_id INNER JOIN
				fas_books fb ON fb.fas_book_id = book.entity_id  INNER JOIN
				fas_eff_hedge_rel_type rtype ON rtype.eff_test_profile_id = coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)
		where   profile_approved = ''y'' and profile_active = ''y'' and 
				fs.hedge_type_value_id IN (150, 151) AND (fs.mes_gran_value_id =177)
				
		'
SET @selectStmt4 = @selectStmt4 + @addWhereStmt

--print @selectStmt4 
--print @selectStmt1 + ' UNION ' + @selectStmt2 + ' UNION ' + @selectStmt3 + ' UNION ' + @selectStmt4


--print @selectStmt1 + ' UNION ' + @selectStmt2+ ' UNION ' + @selectStmt3 + ' UNION ' + @selectStmt4

exec (@selectStmt1 + ' UNION ' + @selectStmt2+ ' UNION ' + @selectStmt3 + ' UNION ' + @selectStmt4)


IF @internal_call = 'y'
BEGIN
	SELECT * FROM #TEMP
	RETURN
END

--If (@subId IS NOT NULL or @strategyId IS NOT NULL or @bookId IS NOT NULL) and (isnull(@assessmentId,'')='')
If @assessmentId IS NULL
	set @selectStmt1 = 'SELECT eff_test_profile_id, link_id, calc_level FROM  #TEMP'
else
	set @selectStmt1 = 'SELECT eff_test_profile_id, link_id, calc_level FROM  #TEMP a
			WHERE (cast(a.eff_test_profile_id as varchar) + cast(a.link_id as varchar) + cast(a.calc_level as varchar)) IN (' + 
			@assessmentId + ')'

--print @selectStmt1
EXEC (@selectStmt1)


















