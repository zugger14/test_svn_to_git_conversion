IF OBJECT_ID(N'[dbo].[spa_get_next_sequence_no]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_next_sequence_no]
GO 

-- This procedure retrieves next sequence number or leg used 
-- while setting up hedging relationship type detail
CREATE PROCEDURE [dbo].[spa_get_next_sequence_no]
	@flag char,
	@eff_test_profile_id int,
	@hedge_or_item char,
	@deal_sequence_number int = NULL
AS

-- SET @eff_test_profile_id = 4
-- SET @hedge_or_item = 'h'
-- SET @deal_sequence_number = 1

If @flag = 's'
BEGIN
	SELECT     (isnull(max(deal_sequence_number), 0) + 1) AS next_deal_sequence_number
	FROM         fas_eff_hedge_rel_type_detail
	WHERE eff_test_profile_id = @eff_test_profile_id AND
	hedge_or_item = @hedge_or_item
END
Else
BEGIN
	SELECT     (isnull(max(leg), 0) + 1) AS next_leg
	FROM         fas_eff_hedge_rel_type_detail
	WHERE eff_test_profile_id = @eff_test_profile_id AND
	hedge_or_item = @hedge_or_item AND
	deal_sequence_number = @deal_sequence_number
END




