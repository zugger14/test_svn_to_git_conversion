
IF OBJECT_ID(N'[spa_GetAllHedgingRelationshipTypes]', N'P') IS NOT NULL
DROP PROC [spa_GetAllHedgingRelationshipTypes]
GO


--===========================================================================================
--This Procedure returns all hedging relationship type within a book
--Input Parameters:
-- book_id Int
-- get_individual_calc if this  flagged passed as  'y' then it brings all the links/rel  type combo


--===========================================================================================

--EXEC spa_GetAllHedgingRelationshipTypes 216
--EXEC spa_GetAllHedgingRelationshipTypes 126, 'y'
--EXEC spa_GetAllHedgingRelationshipTypes 10, 'y'
--EXEC spa_GetAllHedgingRelationshipTypes 10, 'n'

CREATE PROCEDURE [dbo].[spa_GetAllHedgingRelationshipTypes]  
	@book_id VARCHAR(MAX) = NULL, 
	@get_individual_calc VARCHAR(1) = NULL
AS

CREATE TABLE #TEMP(
eff_test_profile_id int,
link_id int,
calc_level int,
Id varchar(50) COLLATE DATABASE_DEFAULT,
[Name] varchar(1000) COLLATE DATABASE_DEFAULT,
[Description] varchar(1000) COLLATE DATABASE_DEFAULT
)

INSERT #TEMP
EXEC spa_get_all_assessments_to_run  NULL, NULL, @book_id, NULL, 'y'

select Id, [Name], Description, eff_test_profile_id rel_id, link_id, calc_level from #TEMP
order by rel_id
return

--SELECT	(Cast(eff_test_profile_id  as varchar) + '-11') AS Id, 
--	eff_test_name AS Name, 
----	(cast(eff_test_profile_id as varchar) + '- ' + eff_test_name) AS Description,
--	dbo.FNAHyperLinkText(50, (cast(eff_test_profile_id as varchar) + '- ' + eff_test_name), eff_test_profile_id) AS Description,
--	eff_test_profile_id as rel_id, -1 as link_id, 1 as calc_level
--FROM         fas_eff_hedge_rel_type
--where 		inherit_assmt_eff_test_profile_id IS NULL
--		AND profile_for_value_id <> 326
--		AND (individual_link_calc IS NULL OR individual_link_calc = 'n')
--		AND fas_eff_hedge_rel_type.fas_book_id = @book_id 
--
--UNION
--
--Select 	(CAST(flh.eff_test_profile_id AS VARCHAR) + cast(flh.link_id as varchar) + '2') AS Id, 
--	(cast(flh.link_id as varchar) + '- ' + flh.link_description + 
--		' (' + cast(type.eff_test_profile_id as varchar) + '- ' + eff_test_name + ')') AS Name,
--	dbo.FNAHyperLinkText(61, (cast(flh.link_id as varchar) + '- ' + flh.link_description + 
--		' (' + cast(type.eff_test_profile_id as varchar) + ': ' + eff_test_name + ')'), flh.link_id) AS Description,
---- 	(cast(flh.link_id as varchar) + '- ' + flh.link_description + 
---- 		' (' + cast(type.eff_test_profile_id as varchar) + ': ' + eff_test_name + ')') AS Description,
--	flh.eff_test_profile_id as rel_id, flh.link_id as link_id, 2 as calc_level
--from fas_link_header flh INNER JOIN  
--	(Select eff_test_profile_id as  eff_test_profile_id,
--				eff_test_name 
--		from fas_eff_hedge_rel_type 
--		WHERE 		(individual_link_calc IS NOT NULL OR individual_link_calc = 'y') 
--			and fas_eff_hedge_rel_type.fas_book_id = @book_id
--	) type
--	ON type.eff_test_profile_id = flh.eff_test_profile_id
--WHERE 1 = CASE WHEN (@get_individual_calc = 'y') then 1 else 2 end
--
--ORDER BY  rel_id
		







