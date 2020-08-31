IF OBJECT_ID(N'spa_hedge_rel_type_inherits_other', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_hedge_rel_type_inherits_other]
GO 

--this procedure checks if a passed relationship types inherits value
-- from other type. if it inherits then it would return inherits_from_other_type > 0
-- If it does not inherit it will return o as inherits_from_other_type

CREATE PROCEDURE [dbo].[spa_hedge_rel_type_inherits_other]
	@eff_test_profile_id INT
AS

SELECT ISNULL(p.inherit_assmt_eff_test_profile_id, 0) AS 
       inherits_from_other_type_id,
       ISNULL(i.eff_test_name, '') AS inherits_from_other_type_name
FROM   fas_eff_hedge_rel_type p
       LEFT OUTER JOIN fas_eff_hedge_rel_type i
            ON  p.inherit_assmt_eff_test_profile_id = i.eff_test_profile_id
WHERE  p.eff_test_profile_id = @eff_test_profile_id