IF OBJECT_ID(N'[dbo].[spa_deal_pricing_quality_provisional_filter]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_pricing_quality_provisional_filter]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2018-06-07
-- Description: Save deal price quality
--=============================================================
CREATE PROCEDURE [dbo].[spa_deal_pricing_quality_provisional_filter]
    @flag CHAR(1),
	@filter_id INT = NULL,
	@filter_name VARCHAR(50) = NULL,
	@grid_json VARCHAR(MAX) = NULL

AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(MAX)
DECLARE @DESC VARCHAR(500)
DECLARE @err_no INT
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()

IF @flag = 's'
BEGIN
    SELECT
		[dpf].[deal_pricing_quality_filter_id],
		[dpf].[deal_pricing_quality_filter_name]
	FROM deal_pricing_quality_filter AS dpf
END

IF @flag = 't'
BEGIN
	SELECT prv.grid_json
	FROM deal_pricing_quality_filter prv
    WHERE prv.deal_pricing_quality_filter_id = @filter_id
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
	
		DECLARE @new_id INT
		
		IF EXISTS( 
			SELECT 1
			FROM deal_pricing_quality_filter prv
			WHERE prv.deal_pricing_quality_filter_name = @filter_name 
			AND prv.deal_pricing_quality_filter_id <> ISNULL(@filter_id, -1)
		) 
		BEGIN
			EXEC spa_ErrorHandler 0
					, 'pinned_reports'
					, 'spa_deal_pricing_quality_provisional_filter'
					, 'Error' 
					, 'Filter Name already exists.'
					, ''
			COMMIT 
			RETURN		
		END

		IF @filter_id IS NOT NULL
		BEGIN
			UPDATE dpf
			SET 
				dpf.grid_json = @grid_json
			FROM deal_pricing_quality_filter dpf
			WHERE dpf.deal_pricing_quality_filter_id = @filter_id

			SET @new_id = @filter_id
		END
		ELSE
		BEGIN			
			INSERT INTO deal_pricing_quality_filter(deal_pricing_quality_filter_name, grid_json, [user_name])
			SELECT @filter_name, @grid_json, @user_name

			SET @new_id = SCOPE_IDENTITY()
		END
		
		COMMIT
	
		EXEC spa_ErrorHandler 0
			, 'deal_pricing_quality_filter'
			, 'spa_deal_pricing_quality_provisional_filter'
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
		   , 'deal_pricing_quality_filter'
		   , 'spa_deal_pricing_quality_provisional_filter'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		DELETE FROM deal_pricing_quality_filter WHERE deal_pricing_quality_filter_id = @filter_id	
	
		EXEC spa_ErrorHandler 0
			, 'deal_pricing_quality_filter'
			, 'spa_deal_pricing_quality_provisional_filter'
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
		   , 'deal_pricing_quality_filter'
		   , 'spa_deal_pricing_quality_provisional_filter'
		   , 'Error'
		   , @DESC
		   , ''
	END CATCH
END
IF @flag = 'p'
BEGIN
	BEGIN TRY
		DECLARE @copy_filter_name VARCHAR(200) 
		
		INSERT INTO deal_pricing_quality_filter(deal_pricing_quality_filter_name,  grid_json, [user_name])
		SELECT	'COPY_' + deal_pricing_quality_filter_name, grid_json, [user_name]
		FROM deal_pricing_quality_filter 
		WHERE deal_pricing_quality_filter_id = @filter_id

		SET @new_id = SCOPE_IDENTITY()

		UPDATE deal_pricing_quality_filter
		SET deal_pricing_quality_filter_name = deal_pricing_quality_filter_name + '_' + CAST(@new_id AS VARCHAR(20))
		WHERE deal_pricing_quality_filter_id = @new_id

		SELECT @copy_filter_name = deal_pricing_quality_filter_name
		FROM deal_pricing_quality_filter
		WHERE deal_pricing_quality_filter_id = @new_id

		SET @copy_filter_name = CAST(@new_id AS VARCHAR(20)) + ':::' + @copy_filter_name

		EXEC spa_ErrorHandler 0,
            'Copy Filter.',
            'spa_deal_pricing_quality_provisional_filter',
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
		   , 'spa_deal_pricing_quality_provisional_filter'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END