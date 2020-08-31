/****** Object:  StoredProcedure [dbo].[spa_copy_source_formula_items]    Script Date: 07/09/2009 19:17:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_copy_source_formula_items]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_copy_source_formula_items]
GO

/****** Object:  StoredProcedure [dbo].[spa_copy_source_formula_items]    Script Date: 07/09/2009 19:16:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Create date: 2009-07-03
-- Description:	Copies formula items (formula_editor & formula_nested) for given source_formula
--
-- Params:
-- @ems_source_formula_id: id of source formula to copy
-- @is_formula_reduction: copy formula or formula reduction items for given source formula
-- @formula_group_id: id of newly copied formula items
-- =============================================

/*
DECLARE @formula_group_id int
EXEC spa_copy_source_formula_items 444, 0, @formula_group_id OUTPUT
select @formula_group_id
*/

CREATE PROCEDURE [dbo].[spa_copy_source_formula_items] 
	@ems_source_formula_id int,
	@is_formula_reduction bit = 0,
	@formula_group_id int OUTPUT
	
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @old_formula_id	int 
	DECLARE @old_formula	varchar(8000)
	DECLARE @old_formula_type varchar(1) 
	DECLARE @old_statis_value_id int
	DECLARE @old_formula_group_id int
	DECLARE @new_formula_id	int 
		
	BEGIN TRY

		--copy main nested formula group id
		INSERT INTO formula_editor (formula, formula_type, static_value_id)
			SELECT formula, formula_type, static_value_id
				FROM formula_editor fe
				INNER JOIN ems_source_formula esf ON fe.formula_id = (CASE WHEN @is_formula_reduction = 1 THEN esf.formula_reduction ELSE esf.formula_id END)
				WHERE esf.ems_source_formula_id = @ems_source_formula_id
		
		SET @formula_group_id = SCOPE_IDENTITY()
			
		 --copy all formula ids except the main formula group id (main id of nested formula: formula_group_id)				
		DECLARE cur_formula_editor CURSOR LOCAL FOR	
		SELECT 	
			fe.formula_id, formula, formula_type, static_value_id, fn.formula_group_id
		FROM formula_editor fe
		INNER JOIN formula_nested fn ON fn.formula_id = fe.formula_id
		INNER JOIN ems_source_formula esf ON fn.formula_group_id = (CASE WHEN @is_formula_reduction = 1 THEN esf.formula_reduction ELSE esf.formula_id END)
		WHERE esf.ems_source_formula_id = @ems_source_formula_id
			AND fe.formula_id <> fn.formula_group_id
		
		OPEN cur_formula_editor;

		FETCH NEXT FROM cur_formula_editor INTO @old_formula_id, @old_formula, @old_formula_type, @old_statis_value_id, @old_formula_group_id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--copy formula_editor
			INSERT INTO formula_editor (formula, formula_type, static_value_id)
			VALUES(@old_formula, @old_formula_type, @old_statis_value_id)
			
			SELECT @new_formula_id = SCOPE_IDENTITY()
			
			--copy formula_nested
			INSERT INTO formula_nested (sequence_order, description1, description2, formula_id, formula_group_id
									, granularity, include_item, show_value_id, uom_id, rate_id, total_id)
			SELECT sequence_order, description1, description2, @new_formula_id, @formula_group_id, granularity
					, include_item, show_value_id, uom_id, rate_id, total_id
			FROM formula_nested
			WHERE formula_id = @old_formula_id
				AND formula_group_id = @old_formula_group_id --to prevent accidental copy if there are orphaned 
															 --formula in formula_nested
			
			FETCH NEXT FROM cur_formula_editor INTO @old_formula_id, @old_formula, @old_formula_type, @old_statis_value_id, @old_formula_group_id
		END
		
		CLOSE cur_formula_editor;
		DEALLOCATE cur_formula_editor;

	END TRY
	BEGIN CATCH
		
		IF CURSOR_STATUS('local', 'cur_formula_editor') >= 0 
		BEGIN
			CLOSE cur_formula_editor
			DEALLOCATE cur_formula_editor;
		END
		
		 -- RAISERROR with severity 11-19 will cause exeuction to jump to the CATCH block.
		RAISERROR ('Error Copying Source Formula items.', -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );

	END CATCH   
		
END

