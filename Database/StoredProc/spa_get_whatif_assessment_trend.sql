
IF OBJECT_ID(N'spa_get_whatif_assessment_trend', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_get_whatif_assessment_trend]
GO

-- EXEC spa_get_whatif_assessment_trend '4-11,432,5-11', 'o', '2003-1-1', '2003-12-31'
-- EXEC spa_get_whatif_assessment_trend '4, 12, 18', 'o', '1/1/2003', '12/31/2003'

-- DROP PROC spa_get_whatif_assessment_trend

CREATE PROCEDURE [dbo].[spa_get_whatif_assessment_trend] 	
	@assmt_ids VARCHAR(8000),
	@initial_ongoing VARCHAR(1),
	@as_of_date_from VARCHAR(20), 
	@as_of_date_to VARCHAR(20)
AS

SET NOCOUNT ON

DECLARE @Sql_Select   VARCHAR(8000)
DECLARE @Sql_Select1  VARCHAR(8000)
DECLARE @Sql_Select2  VARCHAR(8000)

SET @assmt_ids = '''' + REPLACE (REPLACE(@assmt_ids, ' ', ''), ',' , ''',''') + ''''

--print @assmt_ids

CREATE TABLE #temp
(
as_of_date datetime,
result_value float,
eff_test_name varchar(100) COLLATE DATABASE_DEFAULT
)

SET @Sql_Select = '
INSERT INTO #temp
SELECT	results.as_of_date AS as_of_date, 
                Cast(round(fas_eff_ass_test_results.result_value, 2) as varchar) AS result_value,
		dbo.FNAReplaceSpecialChars(results.eff_test_name, ''_'') eff_test_name

FROM         fas_eff_ass_test_results INNER JOIN
	(SELECT
		fas_eff_ass_test_results.as_of_date AS as_of_date,
		fas_eff_hedge_rel_type_whatif.eff_test_profile_id AS eff_test_profile_id,
		fas_eff_hedge_rel_type_whatif.eff_test_name,
		max(fas_eff_ass_test_results.eff_test_result_id) as   eff_test_result_id
		FROM         fas_eff_ass_test_results INNER JOIN
             		fas_eff_hedge_rel_type_whatif ON fas_eff_ass_test_results.eff_test_profile_id = fas_eff_hedge_rel_type_whatif.eff_test_profile_id 
		WHERE fas_eff_ass_test_results.as_of_date BETWEEN  CONVERT(DATETIME, ''' + @as_of_date_from + ''', 102) AND CONVERT(DATETIME, ''' + @as_of_date_to + ''', 102)
			AND fas_eff_ass_test_results.eff_test_profile_id IN (' + @assmt_ids + ')
			AND fas_eff_ass_test_results.link_id = -1 AND fas_eff_ass_test_results.calc_level = 3
			AND fas_eff_ass_test_results.initial_ongoing = ''' + @initial_ongoing + '''
		group by fas_eff_ass_test_results.as_of_date, 
			fas_eff_hedge_rel_type_whatif.eff_test_profile_id, fas_eff_hedge_rel_type_whatif.eff_test_name) results
ON fas_eff_ass_test_results.eff_test_result_id = results.eff_test_result_id
order by results.as_of_date, results.eff_test_name'

--replaced above to fix calclevel
--AND fas_eff_hedge_rel_type.eff_test_profile_id IN (' + @assmt_ids + ')


exec (@Sql_Select)

--print @Sql_Select

--select * from #temp
	
Declare @eff_name varchar(100)

DECLARE b_cursor CURSOR FOR
	select distinct eff_test_name from #temp
	
open b_cursor
FETCH NEXT FROM b_cursor
INTO @eff_name		
			       
SET @Sql_Select1 = ''
SET @Sql_Select2 = ''
	
WHILE @@FETCH_STATUS = 0   
BEGIN 
	SET @Sql_Select2 = @Sql_Select2 + ', cast(round(sum(xx.' +  @eff_name + '), 2) as varchar) as ' + @eff_name
	SET @Sql_Select1 = @Sql_Select1 + ', case when (eff_test_name = ''' + @eff_name + ''') then sum(result_value) else 0 end as ' + @eff_name 

	FETCH NEXT FROM b_cursor
	INTO @eff_name
END 
CLOSE b_cursor
DEALLOCATE  b_cursor

SET @Sql_Select1 = 'select dbo.FNADateFormat(xx.as_of_date) as Date ' + @Sql_Select2 + ' from (select as_of_date ' + @Sql_Select1 + ' from #temp group by as_of_date, eff_test_name) xx group  by xx.as_of_date order by xx.as_of_date '
 
EXEC spa_print @Sql_Select1
exec (@Sql_Select1)
return






