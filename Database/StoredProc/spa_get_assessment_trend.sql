

IF OBJECT_ID(N'[dbo].[spa_get_assessment_trend]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_get_assessment_trend]
GO 

-- EXEC spa_get_assessment_trend '4-11', null, '2003-1-1', '2003-12-31'
-- EXEC spa_get_assessment_trend '4, 12, 18', 'o', '1/1/2003', '12/31/2003'
-- EXEC spa_get_assessment_trend '885732','o','2001-07-16','2007-10-16'
-- DROP PROC spa_get_assessment_trend

CREATE PROCEDURE [dbo].[spa_get_assessment_trend] 	
	@assmt_ids VARCHAR(8000) = NULL,
	@initial_ongoing VARCHAR(1),
	@as_of_date_from VARCHAR(20), 
	@as_of_date_to VARCHAR(20),
	@link_id INT = NULL

AS

 
--DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
--	SET CONTEXT_INFO @contextinfo
--declare @assmt_ids VARCHAR(8000),
--			@initial_ongoing VARCHAR(1),
--						@as_of_date_from VARCHAR(20), 
--						@as_of_date_to VARCHAR (20)
--set @assmt_ids='885732'
--set @initial_ongoing='o'
--set @as_of_date_from='2001-07-16'
--set @as_of_date_to='2007-10-16'
SET NOCOUNT ON
/*
DECLARE @Sql_Select VARCHAR(8000)
DECLARE @Sql_Select1 VARCHAR(8000)
DECLARE @Sql_Select2 VARCHAR(8000)
DECLARE @initial_ongoing_stmt VARCHAR(100)

SET @initial_ongoing_stmt = CASE WHEN (ISNULL(@initial_ongoing, 'b') = 'b') THEN ' (''i'', ''o'') ' ELSE ' ( ''' + @initial_ongoing + ''') ' end 

-- select @initial_ongoing_stmt
-- return 

SET @assmt_ids = '''' + REPLACE (REPLACE(@assmt_ids, ' ', ''), ',' , ''',''') + ''''

--print @assmt_ids

CREATE TABLE #temp (
					as_of_date DATETIME,
					result_value FLOAT,
					eff_test_name VARCHAR(100) COLLATE DATABASE_DEFAULT 
					)

SET @Sql_Select = '
					INSERT INTO #temp
					SELECT	results.as_of_date AS as_of_date, 
									Cast(round(fas_eff_ass_test_results.result_value, 2) as VARCHAR) AS result_value,
							dbo.FNAReplaceSpecialChars(results.eff_test_name, ''_'') eff_test_name

					FROM         fas_eff_ass_test_results INNER JOIN
						(SELECT
							fas_eff_ass_test_results.as_of_date AS as_of_date,
							fas_eff_hedge_rel_type.eff_test_profile_id AS eff_test_profile_id,
							fas_eff_hedge_rel_type.eff_test_name,
							max(fas_eff_ass_test_results.eff_test_result_id) as   eff_test_result_id
							FROM         fas_eff_ass_test_results INNER JOIN
             							fas_eff_hedge_rel_type ON fas_eff_ass_test_results.eff_test_profile_id = fas_eff_hedge_rel_type.eff_test_profile_id 
							WHERE fas_eff_ass_test_results.as_of_date BETWEEN  CONVERT(DATETIME, ''' + @as_of_date_from + ''', 102) AND CONVERT(DATETIME, ''' + @as_of_date_to + ''', 102)
								AND (cast(fas_eff_ass_test_results.eff_test_profile_id as VARCHAR) + 
								cast(fas_eff_ass_test_results.link_id as VARCHAR) + cast(fas_eff_ass_test_results.calc_level as VARCHAR)) IN (' + @assmt_ids + ')
								AND fas_eff_ass_test_results.initial_ongoing IN ' + @initial_ongoing_stmt + ' 
							group by fas_eff_ass_test_results.as_of_date, 
								fas_eff_hedge_rel_type.eff_test_profile_id, fas_eff_hedge_rel_type.eff_test_name) results
					ON fas_eff_ass_test_results.eff_test_result_id = results.eff_test_result_id
					order by results.as_of_date, results.eff_test_name'

--replaced above to fix calclevel
--AND fas_eff_hedge_rel_type.eff_test_profile_id IN (' + @assmt_ids + ')


EXEC spa_print @Sql_Select
EXEC (@Sql_Select)

 
	
DECLARE @eff_name VARCHAR(100)

DECLARE b_cursor CURSOR FOR
SELECT DISTINCT eff_test_name FROM #temp
OPEN b_cursor
FETCH NEXT FROM b_cursor
INTO @eff_name		
			       
SET @Sql_Select1 = ''
SET @Sql_Select2 = ''
	
WHILE @@FETCH_STATUS = 0   
BEGIN 
	SET @Sql_Select2 = @Sql_Select2 + ', cast(round(sum(xx.[' +  @eff_name + ']), 2) as VARCHAR) as [' + @eff_name +']'
	SET @Sql_Select1 = @Sql_Select1 + ', case when (eff_test_name = ''' + @eff_name + ''') then sum(result_value) else 0 end as [' + @eff_name +']'
	FETCH NEXT FROM b_cursor
	INTO @eff_name
END 
CLOSE b_cursor
DEALLOCATE  b_cursor

SET @Sql_Select1 = 'SELECT dbo.FNADateFormat(xx.as_of_date) as Date ' + @Sql_Select2 + ' 
					FROM (select as_of_date ' + @Sql_Select1 + ' from #temp group by as_of_date, eff_test_name) 
					xx group  by xx.as_of_date order by xx.as_of_date '
 
EXEC spa_print @Sql_Select1
exec (@Sql_Select1)
 
 */

IF OBJECT_ID('tempdb..#assessments_mult') IS NOT NULL 
	DROP TABLE #assessments_mult

CREATE TABLE #assessments_mult(
	eff_test_profile_id INT,
	link_id INT,
	calc_level INT
)

INSERT INTO #assessments_mult 
SELECT eff_test_profile_id, link_id, calc_level FROM (
	SELECT DISTINCT (rtype.eff_test_profile_id) eff_test_profile_id, 
			-1 as link_id, 1 as calc_level,
			cast(rtype.eff_test_profile_id as varchar) + '-11' AS Id,
			eff_test_name AS [Name]
	FROM fas_eff_hedge_rel_type rtype 
	INNER JOIN portfolio_hierarchy book ON  rtype.fas_book_id = book.entity_id  
	INNER JOIN portfolio_hierarchy strat ON book.parent_entity_id = strat.entity_id  
	INNER JOIN portfolio_hierarchy sub  ON strat.parent_entity_id = sub.entity_id 
	WHERE profile_approved = 'y' and profile_active = 'y' 
		AND  (individual_link_calc IS NULL OR individual_link_calc = 'n')
	UNION 
	SELECT flh.eff_test_profile_id, 
		flh.link_id, 
		2 as calc_level,
		cast(flh.eff_test_profile_id as varchar) + cast(flh.link_id as varchar) + '2' As [Id],
		(cast(flh.link_id as varchar) + '- ' + flh.link_description + 
		' (' + cast(rel.eff_test_profile_id as varchar) + '- ' + eff_test_name + ')') AS Name
	 FROM fas_link_header flh 
	 INNER JOIN (SELECT DISTINCT(eff_test_profile_id) as  eff_test_profile_id, eff_test_name
				FROM fas_eff_hedge_rel_type rtype 
				INNER JOIN portfolio_hierarchy book ON  rtype.fas_book_id = book.entity_id  
				INNER JOIN portfolio_hierarchy strat ON book.parent_entity_id = strat.entity_id  
				INNER JOIN fas_strategy fs ON fs.fas_strategy_id = strat.entity_id  
				INNER JOIN portfolio_hierarchy sub  ON strat.parent_entity_id = sub.entity_id 
				WHERE 	profile_approved = 'y' and profile_active = 'y' and 
				(individual_link_calc IS NOT NULL AND individual_link_calc = 'y')) rel ON rel.eff_test_profile_id = flh.eff_test_profile_id
	WHERE flh.link_type_value_id = 450 --and isnull(fully_dedesignated, 'n') <> 'y'
	UNION 
	SELECT MAX(COALESCE(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)) no_links_fas_eff_test_profile_id, 
			-1 * fs.fas_strategy_id link_id, 
			2 as calc_level,
			MAX(CAST(COALESCE(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) as varchar) + cast(-1 * fs.fas_strategy_id as varchar) + '2') As [Id],
			MAX(eff_test_name + ' for Strategy (' +  cast(-1 * fs.fas_strategy_id as varchar) + ') ' + strat.entity_name) AS [Name]
	FROM	portfolio_hierarchy book 
	INNER JOIN portfolio_hierarchy strat ON strat.entity_id = book.parent_entity_id  
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = strat.parent_entity_id  
	INNER JOIN fas_strategy fs ON fs.fas_strategy_id = strat.entity_id 
	INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id  
	INNER JOIN fas_eff_hedge_rel_type rtype ON rtype.eff_test_profile_id = COALESCE(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)
	WHERE   profile_approved = 'y' 
		AND profile_active = 'y' 
		AND fs.hedge_type_value_id IN (150, 151) 
		AND (fs.mes_gran_value_id = 178 )		
	GROUP BY fs.fas_strategy_id  
	
	UNION 
	SELECT COALESCE(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) no_links_fas_eff_test_profile_id, 
			-1 * fb.fas_book_id  link_id, 
			2 as calc_level,
			cast (coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id) as varchar) + 
			cast (-1 * fb.fas_book_id as varchar) +
			'2' Id, 
			eff_test_name + ' for Book  (' +  cast(-1 * book.entity_id as varchar) + ') ' + book.entity_name AS [Name]
	FROM	portfolio_hierarchy book 
	INNER JOIN portfolio_hierarchy strat ON strat.entity_id = book.parent_entity_id  
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = strat.parent_entity_id  
	INNER JOIN fas_strategy fs ON fs.fas_strategy_id = strat.entity_id 
	INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id  
	INNER JOIN fas_eff_hedge_rel_type rtype ON rtype.eff_test_profile_id = coalesce(fs.no_links_fas_eff_test_profile_id, fb.no_links_fas_eff_test_profile_id)
	WHERE   profile_approved = 'y' 
	AND profile_active = 'y' 
	AND fs.hedge_type_value_id IN (150, 151) 
	AND (fs.mes_gran_value_id =177)
) a


SELECT 
	fas_eff_ass_test_results.as_of_date AS [As of Date], 	 
	CAST(CAST(rph.regression_rsq AS NUMERIC(38,2)) AS VARCHAR(100)) AS RSQ, 
	CAST(CAST(rph.regression_corr AS NUMERIC(38,2)) AS VARCHAR(100)) AS Correlation, 
	CAST(CAST(rph.regression_slope AS NUMERIC(38,2)) AS VARCHAR(100)) AS Slope--,	 
	--CAST(CASE WHEN(fas_eff_ass_test_results.link_id = -1) THEN ' ' ELSE fas_eff_ass_test_results.link_id END AS VARCHAR) [Link ID] 
FROM  #assessments_mult asm 
INNER JOIN fas_eff_ass_test_results on asm.link_id=fas_eff_ass_test_results.link_id and asm.calc_level=fas_eff_ass_test_results.calc_level
LEFT JOIN fas_eff_hedge_rel_type  on asm.eff_test_profile_id=fas_eff_hedge_rel_type.eff_test_profile_id and asm.calc_level = 1
LEFT JOIN fas_link_header flh  on asm.link_id=flh.link_id and asm.calc_level=2 and asm.link_id > 0
LEFT JOIN fas_books book on abs(asm.link_id)=book.fas_book_id and asm.calc_level=2 and asm.link_id < 0
LEFT JOIN fas_strategy st on abs(asm.link_id)=st.fas_strategy_id and asm.calc_level=2 and asm.link_id < 0
INNER JOIN static_data_value static_data_value_1 ON fas_eff_ass_test_results.eff_test_approach_value_id = static_data_value_1.value_id
LEFT JOIN portfolio_hierarchy phbook ON phbook.entity_id = COALESCE(flh.fas_book_id,book.fas_book_id)
LEFT JOIN portfolio_hierarchy phstr ON phstr.entity_id = COALESCE(phbook.parent_entity_id, st.fas_strategy_id)
LEFT JOIN portfolio_hierarchy phsub ON phsub.entity_id = phstr.parent_entity_id
LEFT OUTER JOIN   fas_eff_ass_test_results_process_header rph ON rph.eff_test_result_id = fas_eff_ass_test_results.eff_test_result_id 
WHERE fas_eff_ass_test_results.as_of_date BETWEEN  CONVERT(DATETIME, @as_of_date_from, 102) AND CONVERT(DATETIME, @as_of_date_to, 102) 
	AND initial_ongoing = @initial_ongoing
	AND CASE WHEN(fas_eff_ass_test_results.link_id = -1) THEN '' ELSE fas_eff_ass_test_results.link_id END = @link_id
ORDER BY phsub.entity_name,
		phstr.entity_name,
		phbook.entity_name,
		fas_eff_hedge_rel_type.eff_test_profile_id, 
		fas_eff_ass_test_results.eff_test_result_id desc,
		fas_eff_hedge_rel_type.eff_test_name, 
		fas_eff_ass_test_results.as_of_date DESC, 
		fas_eff_ass_test_results.create_ts DESC


 GO



