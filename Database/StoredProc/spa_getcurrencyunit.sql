
IF OBJECT_ID('spa_getcurrencyunit','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getcurrencyunit]
 GO 



-- EXEC spa_getcurrencyunit 's', 10
-- DROP PROC spa_getcurrencyunit 

-- eff_test_profile_id should be the book id...

CREATE PROCEDURE [dbo].[spa_getcurrencyunit]
	@flag CHAR(1),
	@eff_test_profile_id INT = NULL,
	@strategy_id INT = NULL
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(8000)

CREATE TABLE #currency(
	source_currency_id INT NULL,
	currency_name VARCHAR(100) COLLATE DATABASE_DEFAULT
)

IF @eff_test_profile_id is NOT NULL
BEGIN
	SET @sql = 'INSERT INTO #currency
		select d.source_currency_id, d.currency_name + CASE WHEN ssd.source_system_name=''farrms'' THEN '''' ELSE ''.'' + ssd.source_system_name END AS currency_name
		from portfolio_hierarchy b, fas_strategy c, source_currency d
		 INNER JOIN source_system_description ssd ON d.source_system_id = ssd.source_system_id
		where b.entity_id = '+CAST(@eff_test_profile_id AS VARCHAR)+'
		and  b.parent_entity_id = c.fas_strategy_id
		and (d.source_system_id = c.source_system_id)
	'
	IF @strategy_id IS NOT NULL
		SET @sql = @sql + 'AND c.fas_strategy_id = ' + CAST ( @strategy_id AS VARCHAR)
	--PRINT @sql
	--EXEC (@sql)
	
END
ELSE
BEGIN
	SET @sql = 'INSERT INTO #currency
			select 
				d.source_currency_id
				, d.currency_name + case when ssd.source_system_name=''farrms'' then '''' else ''.'' + ssd.source_system_name end as currency_name
			from source_system_description ssd
			INNER JOIN source_currency d on ssd.source_system_id = d.source_system_id
			LEFT JOIN fas_strategy fs on ssd.source_system_id = fs.source_system_id
			WHERE d.source_system_id = ssd.source_system_id
			AND ISNULL(fs.source_system_id, d.source_system_id) = d.source_system_id
			'
			IF @strategy_id IS NOT NULL
				SET @sql = @sql + 'AND fs.fas_strategy_id =' + CAST(@strategy_id AS VARCHAR)
	SET @sql = @sql + ' order by ssd.source_system_name + '','' + currency_name'
	--PRINT @sql
	--EXEC (@sql)		
END

EXEC (@sql)

SELECT DISTINCT source_currency_id ,currency_name FROM #currency ORDER BY currency_name


If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Currency Units', 
				'spa_getcurrencyunits', 'DB Error', 
				'Failed to select currency units.', ''


-- select d.source_currency_id, d.currency_id, d.currency_name
-- from fas_eff_hedge_rel_type a, portfolio_hierarchy b, fas_strategy c, source_currency d
-- where a.fas_book_id = b.entity_id
-- and  b.parent_entity_id = c.fas_strategy_id
-- and a.eff_test_profile_id = @eff_test_profile_id
-- and (d.source_system_id = c.source_system_id)
-- 
-- If @@ERROR <> 0
-- 		Exec spa_ErrorHandler @@ERROR, 'Currency Units', 
-- 				'spa_getcurrencyunits', 'DB Error', 
-- 				'Failed to select currency units.', ''
-- 	Else
-- 		Exec spa_ErrorHandler 0, 'Currency Units', 
-- 				'spa_getcurrencyunits', 'Success', 
-- 				'Currentcy units successfully selected.', ''



