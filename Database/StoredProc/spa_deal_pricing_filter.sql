IF OBJECT_ID(N'[dbo].[spa_deal_pricing_filter]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_pricing_filter]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_pricing_filter]
    @flag CHAR(1),
	@filter_id INT = NULL,
	@filter_name VARCHAR(50) = NULL,
	@form_json VARCHAR(MAX) = NULL,
	@grid_json VARCHAR(MAX) = NULL,
	@deemed_form VARCHAR(MAX) = NULL,
	@std_form VARCHAR(MAX) = NULL,
	@custom_form VARCHAR(MAX) = NULL,
	@predefined_formula_form VARCHAR(MAX) = NULL,
	@price_adjustment VARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(MAX)
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()

IF @flag = 's'
BEGIN
    SELECT
		[dpf].[deal_pricing_filter_id],
		[dpf].[deal_pricing_filter_name]
	FROM deal_pricing_filter AS dpf
END

IF @flag = 't'
BEGIN
	SELECT prv.form_json, prv.grid_json, prv.deemed_form_json, prv.std_form_json, prv.custom_form_json, prv.predefined_formula_form_json, prv.price_adjustment
	FROM deal_pricing_filter prv
    WHERE prv.deal_pricing_filter_id = @filter_id
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
	
		DECLARE @new_id INT
		
		IF EXISTS( 
			SELECT 1
			FROM deal_pricing_filter prv
			WHERE prv.deal_pricing_filter_name = @filter_name 
			AND prv.deal_pricing_filter_id <> ISNULL(@filter_id, -1)
		) 
		BEGIN
			EXEC spa_ErrorHandler 0
					, 'pinned_reports'
					, 'spa_deal_pricing_filter'
					, 'Error' 
					, 'Filter Name already exists.'
					, ''
			COMMIT 
			RETURN		
		END

		IF @filter_id IS NOT NULL
		BEGIN
			UPDATE dpf
			SET dpf.deal_pricing_filter_name = @filter_name,
				dpf.form_json = @form_json,
				dpf.grid_json = @grid_json,
				dpf.deemed_form_json = @deemed_form,
				dpf.std_form_json = @std_form,
				dpf.custom_form_json = @custom_form,
				dpf.predefined_formula_form_json = @predefined_formula_form,
				dpf.price_adjustment = @price_adjustment
			FROM deal_pricing_filter dpf
			WHERE dpf.deal_pricing_filter_id = @filter_id

			SET @new_id = @filter_id
		END
		ELSE
		BEGIN			
			INSERT INTO deal_pricing_filter(deal_pricing_filter_name, form_json, grid_json, deemed_form_json, std_form_json, custom_form_json, [user_name], predefined_formula_form_json, price_adjustment)
			SELECT @filter_name, @form_json, @grid_json, @deemed_form, @std_form, @custom_form, @user_name, @predefined_formula_form, @price_adjustment

			SET @new_id = SCOPE_IDENTITY()
		END
		
		COMMIT
	
		EXEC spa_ErrorHandler 0
			, 'deal_pricing_filter'
			, 'spa_deal_pricing_filter'
			, 'Success' 
			, 'Changes are saved successfully.'
			, @new_id

	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @desc = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'deal_pricing_filter'
		   , 'spa_deal_pricing_filter'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM deal_pricing_filter WHERE deal_pricing_filter_id = @filter_id	
	
		EXEC spa_ErrorHandler 0
			, 'deal_pricing_filter'
			, 'spa_deal_pricing_filter'
			, 'Success' 
			, 'Changes are saved successfully.'
			, @filter_id
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'deal_pricing_filter'
		   , 'spa_deal_pricing_filter'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
IF @flag = 'p'
BEGIN
	BEGIN TRY
		DECLARE @copy_filter_name VARCHAR(200) 
		
		INSERT INTO deal_pricing_filter(deal_pricing_filter_name, form_json, grid_json, deemed_form_json, std_form_json, custom_form_json, [user_name], predefined_formula_form_json, price_adjustment)
		SELECT	'COPY_' + deal_pricing_filter_name, form_json, grid_json, deemed_form_json, std_form_json, custom_form_json, [user_name], predefined_formula_form_json, price_adjustment
		FROM deal_pricing_filter 
		WHERE deal_pricing_filter_id = @filter_id

		SET @new_id = SCOPE_IDENTITY()

		UPDATE deal_pricing_filter
		SET deal_pricing_filter_name = deal_pricing_filter_name + '_' + CAST(@new_id AS VARCHAR(20))
		WHERE deal_pricing_filter_id = @new_id

		SELECT @copy_filter_name = deal_pricing_filter_name
		FROM deal_pricing_filter
		WHERE deal_pricing_filter_id = @new_id

		SET @copy_filter_name = CAST(@new_id AS VARCHAR(20)) + ':::' + @copy_filter_name

		EXEC spa_ErrorHandler 0,
            'Copy Filter.',
            'spa_deal_pricing_filter',
            'Success',
            'View copied sucessfully.',
            @copy_filter_name
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		SET @desc = 'Fail to copy view. ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		SELECT @err_no = ERROR_NUMBER()
	 
		EXEC spa_ErrorHandler @err_no
		   , 'Copy View.'
		   , 'spa_deal_pricing_filter'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END