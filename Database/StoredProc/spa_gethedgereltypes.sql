IF OBJECT_ID(N'spa_gethedgereltypes', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_gethedgereltypes]
GO 

--exec spa_gethedgereltypes 's', 15

--this is called from hedging relationship details to get active approved and assesment type
CREATE PROCEDURE [dbo].[spa_gethedgereltypes]
	@flag CHAR(1),
	@fas_book_id INT = NULL
AS
IF @flag = 's'
BEGIN
	select distinct a.eff_test_profile_id, a.fas_book_id, a.eff_test_name,a.eff_test_description
--	select distinct a.eff_test_profile_id, a.fas_book_id, dbo.FNAHyperLinkText(50, a.eff_test_name, a.eff_test_profile_id) ASeff_test_name, a.eff_test_description
	from fas_eff_hedge_rel_type a   --,  fas_link_header b
	where a.fas_book_id = @fas_book_id 
	--and a.fas_book_id = b.fas_book_id
	and upper(a.profile_approved) = 'Y'
	and upper(a.profile_active) = 'Y'
	and profile_for_value_id <> 326


	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'Hegde Relationship Type', 
				'spa_gethedgereltypes', 'DB Error', 
				'Failed to select hedge relationship types.', ''
	Else
		Exec spa_ErrorHandler 0, 'Hegde Relationship Type', 
				'spa_gethedgereltypes', 'Success', 
				'Hedge relationship types successfully selected.', ''

END