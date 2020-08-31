IF OBJECT_ID(N'spa_getsourcecommodity', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getsourcecommodity]
 GO 

-- DROP PROC spa_getsourcecommodity
-- exec spa_getsourcecommodity 's'
-- eff_test_profile_id should be the book id..

CREATE PROCEDURE [dbo].[spa_getsourcecommodity]
	@flag CHAR(1),
	@eff_test_profile_id INT = NULL,
	@gas_power BIT = 0 -- 1 if only gas/power commodity
AS

IF @eff_test_profile_id is not null
	select d.source_commodity_id, d.commodity_name + case when ssd.source_system_id=2 then '' else  '.' + ssd.source_system_name  end as commodity_name
	from portfolio_hierarchy b, fas_strategy c, source_commodity d
		INNER JOIN source_system_description ssd ON d.source_system_id = ssd.source_system_id
	where b.entity_id = @eff_test_profile_id
	and  b.parent_entity_id = c.fas_strategy_id
	and (d.source_system_id = c.source_system_id)
Else
	SELECT '' AS source_commodity_id, '' AS commodity_name
	UNION ALL
	SELECT  d.source_commodity_id AS source_commodity_id, 
	d.commodity_name  + case when ssd.source_system_id=2 then '' else  '.' + ssd.source_system_name  end as commodity_name
	FROM    source_commodity d INNER JOIN
	        source_system_description  ssd ON 
		d.source_system_id = ssd.source_system_id
	WHERE (@gas_power = 1 AND d.source_commodity_id IN (-1, -2) ) OR (ISNULL(@gas_power, 0) = 0) 
	ORDER BY commodity_name


IF @@ERROR <> 0
    EXEC spa_ErrorHandler @@ERROR,
         'Currency Units',
         'spa_getcurrencyunits',
         'DB Error',
         'Failed to select currency units.',
         ''