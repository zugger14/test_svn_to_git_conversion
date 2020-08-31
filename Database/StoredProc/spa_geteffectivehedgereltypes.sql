IF OBJECT_ID(N'spa_geteffectivehedgereltypes', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_geteffectivehedgereltypes]
GO 

--this is called from strategy property and books to get all effective hedge relationship types for 
--a particular book

CREATE PROCEDURE [dbo].[spa_geteffectivehedgereltypes]
	@flag CHAR(1),
	@fas_book_id INT = NULL
AS
IF @flag = 's'
BEGIN
	SELECT DISTINCT eff_test_profile_id,
	       fas_book_id,
	       eff_test_name,
	       eff_test_description
	FROM   fas_eff_hedge_rel_type
	WHERE  fas_book_id = @fas_book_id 
	

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR,
		     'Effective Hegde Relationship Type',
		     'spa_geeffectivethedgereltypes',
		     'DB Error',
		     'Failed to select effective hedge relationship types.',
		     ''
	ELSE
		EXEC spa_ErrorHandler 0,
		     'Effective Hegde Relationship Type',
		     'spa_geteffectivehedgereltypes',
		     'Success',
		     'Effective Hedge relationship types successfully selected.',
		     ''
			 

END