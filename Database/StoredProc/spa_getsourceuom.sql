IF OBJECT_ID(N'spa_getsourceuom', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_getsourceuom]
GO 

-- DROP PROC spa_getsourceuom
-- exec spa_getsourceuom 's'
-- eff_test_profile_id should be the book id...

CREATE PROCEDURE [dbo].[spa_getsourceuom] 
@flag CHAR(1),
@uom_type VARCHAR(50) = NULL,
@eff_test_profile_id INT = NULL
AS 
SET NOCOUNT ON

IF @eff_test_profile_id IS NOT NULL
    SELECT d.source_uom_id value,
           d.uom_name + CASE 
                             WHEN ssd.source_system_id = 2 THEN ''
                             ELSE '.' + ssd.source_system_name
                        END AS text
    FROM   portfolio_hierarchy b,
           fas_strategy c,
           source_uom d
           INNER JOIN source_system_description ssd
                ON  d.source_system_id = ssd.source_system_id
    WHERE  b.entity_id = @eff_test_profile_id
           AND b.parent_entity_id = c.fas_strategy_id
           AND (d.source_system_id = c.source_system_id)
      
ELSE
	DECLARE @sql VARCHAR(max);
	SET @sql ='
    SELECT su.source_uom_id value, 
           su.uom_name + CASE 
                              WHEN ssd.source_system_id = 2 THEN ''''
                              ELSE ''.'' + ssd.source_system_name
                         END AS text
    FROM   source_system_description ssd
           INNER JOIN source_uom su
                ON  su.source_system_id = ssd.source_system_id'
    IF EXISTS (SELECT 1 FROM source_uom AS su WHERE uom_type_id = @uom_type)
    BEGIN
    	SET @sql += ' and su.uom_type_id='+@uom_type+' or su.uom_type_id is null'
    END
    ELSE 
    	BEGIN
    		SET @sql += ' and su.uom_type_id IS NULL'
    	END
		SET @sql +='                 
				ORDER BY
					   ssd.source_system_name + '','' + su.uom_name'
    EXEC (@sql); 

IF @@ERROR <> 0
    EXEC spa_ErrorHandler @@ERROR,
         'Currency Units',
         'spa_getcurrencyunits',
         'DB Error',
         'Failed to select currency units.',
         ''



-- select d.source_uom_id, d.uom_id, d.uom_name
-- from fas_eff_hedge_rel_type a, portfolio_hierarchy b, fas_strategy c, source_uom d
-- where a.fas_book_id = b.entity_id
-- and  b.parent_entity_id = c.fas_strategy_id
-- and a.eff_test_profile_id = @eff_test_profile_id
-- and (d.source_system_id = c.source_system_id)
-- 
-- If @@ERROR <> 0
--    Exec spa_ErrorHandler @@ERROR, 'Currency Units', 
--        'spa_getcurrencyunits', 'DB Error', 
--        'Failed to select currency units.', ''
--  Else
--    Exec spa_ErrorHandler 0, 'Currency Units', 
--        'spa_getcurrencyunits', 'Success', 
--        'Currentcy units successfully selected.', ''