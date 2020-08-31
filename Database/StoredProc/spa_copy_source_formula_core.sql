/****** Object:  StoredProcedure [dbo].[spa_copy_source_formula_core]    Script Date: 07/05/2009 15:23:34 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_copy_source_formula_core]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_copy_source_formula_core]
GO
/****** Object:  StoredProcedure [dbo].[spa_copy_source_formula_core]    Script Date: 07/05/2009 15:25:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Create date: 2009-07-05
-- Description:	Copies source formula & all its child objects (formula items) of a given source formula.
-- No error handler/transaction processing has been done in this sp so that this sp can be used
-- in both cases (source model copy or source formula copy). Caller of this proc is responsible 
-- for managing transaction processing/error handling
--
-- Params:
-- @ems_source_formula_id: source formula to copy
-- @new_ems_source_model_id: source model to put new formula
-- @new_ems_source_model_detail_id: source model detail to put new formula
-- @new_ems_source_formula_id: newly copied id of source formula
-- =============================================
CREATE PROCEDURE [dbo].[spa_copy_source_formula_core] 
	@ems_source_formula_id			int,
	@new_ems_source_model_detail_id	int = NULL,
	@new_ems_source_model_id		int = NULL,
	@new_ems_source_formula_id		int	OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @formula_group_id_for_formula			int
	DECLARE @formula_group_id_for_formula_reduction	int
	
	--load source model & detail id if not given (i.e. formula is being copied to same source model)
	IF @new_ems_source_model_detail_id IS NULL
		SELECT @new_ems_source_model_id = ems_source_model_id, @new_ems_source_model_detail_id = ems_source_model_detail_id
		FROM ems_source_formula
		WHERE ems_source_formula_id = @ems_source_formula_id

	--copy formula items for formula
	EXEC spa_copy_source_formula_items @ems_source_formula_id, 0, @formula_group_id_for_formula OUTPUT

	--copy formula items for formula reduction
	EXEC spa_copy_source_formula_items @ems_source_formula_id, 1, @formula_group_id_for_formula_reduction OUTPUT

	--finally copy source formula
	INSERT INTO ems_source_formula (ems_source_model_id, sequence_order, curve_id, forecast_type, formula_id
									, formula_reduction, default_inventory, ems_source_model_detail_id)
		SELECT 	@new_ems_source_model_id, sequence_order, curve_id, forecast_type, @formula_group_id_for_formula
							, @formula_group_id_for_formula_reduction, default_inventory, @new_ems_source_model_detail_id
		FROM ems_source_formula 
			WHERE ems_source_formula_id = @ems_source_formula_id

	SET @new_ems_source_formula_id = SCOPE_IDENTITY()

END
GO