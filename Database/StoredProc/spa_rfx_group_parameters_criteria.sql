IF OBJECT_ID(N'[dbo].[spa_rfx_group_parameters_criteria]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_rfx_group_parameters_criteria
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: CRUD operations for table spa_rfx_group_parameters_criteria
 
-- Params:
-- @flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_rfx_group_parameters_criteria
    @flag									CHAR(1),
	@report_group_parameters_criteria_id	INT = NULL, 
	@report_writer_id						INT = NULL,
	@critetia								VARCHAR(8000) = NULL,
	@report_name							VARCHAR(8000) = NULL,
	@report_manager_group_id				INT = NULL,
	@paramset_id							INT = NULL,
	@items_combined							VARCHAR(500) = NULL,
	@report_description						VARCHAR(500)= NULL,
	@paramset_hash							VARCHAR(200)= NULL
AS
IF @flag = 's'
BEGIN
    SELECT [report_group_parameters_criteria_id] AS [Report Group Parameter ID]
			, r.[name] + '_' + rp2.[name]  AS [Report Name]
			, [report_manager_group_id] AS [Report Group Manger ID]
			, rgpc.paramset_hash
	FROM report_group_parameters_criteria rgpc
	INNER JOIN report_paramset rp ON rp.paramset_hash = rgpc.paramset_hash
	INNER JOIN report_page rp2 ON rp.page_id = rp2.report_page_id
	INNER JOIN report r ON rp2.report_id = r.report_id
    WHERE report_manager_group_id = @report_manager_group_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT	[report_group_parameters_criteria_id]
			, [criteria]
			, [report_manager_group_id]
			, report_description
			, paramset_hash   
	FROM report_group_parameters_criteria 
	WHERE report_group_parameters_criteria_id = @report_group_parameters_criteria_id
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO report_group_parameters_criteria ([paramset_hash], [report_description], report_manager_group_id, criteria)
			SELECT @paramset_hash, @report_description, @report_manager_group_id, @critetia
			
		COMMIT
	 
		EXEC spa_ErrorHandler 0
				, 'report_group_parameters_criteria'
				, 'spa_rfx_group_parameters_criteria'
				, 'Success.'
				, 'Report Criteria Parameter Inserted.'
				, ''
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @DESC VARCHAR(500)
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 	 
		EXEC spa_ErrorHandler -1
				, 'report_group_parameters_criteria'
				, 'spa_rfx_group_parameters_criteria'
				, 'Delete Failed.'
				, @DESC
				, ''
	END CATCH									
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			UPDATE report_group_parameters_criteria
			SET    [paramset_hash] = @paramset_hash,
			       report_description = @report_description,
			       criteria = @critetia
			WHERE  [report_group_parameters_criteria_id] = @report_group_parameters_criteria_id
			
		EXEC spa_ErrorHandler 0
				, 'report_group_parameters_criteria'
				, 'spa_rfx_group_parameters_criteria'
				, 'Success.'
				, 'Report Criteria Parameter Updated.'
				, ''
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @DESC2 VARCHAR(500)
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC2 = 'Fail to update Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 	 
		EXEC spa_ErrorHandler -1
				, 'report_group_parameters_criteria'
				, 'spa_rfx_group_parameters_criteria'
				, 'Update Failed.'
				, @DESC2
				, ''
	END CATCH				
END
ELSE IF @flag = 'd'
BEGIN
    BEGIN TRY
		DELETE FROM report_group_parameters_criteria WHERE report_group_parameters_criteria_id = @report_group_parameters_criteria_id
	 
		EXEC spa_ErrorHandler 0
				, 'report_group_parameters_criteria'
				, 'spa_rfx_group_parameters_criteria'
				, 'Success.'
				, 'Report Criteria Parameter Deleted.'
				, ''
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @DESC3 VARCHAR(500)
	 
		IF @@TRANCOUNT > 0
		   ROLLBACK
	 
		SET @DESC3 = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
	 
		EXEC spa_ErrorHandler -1
				, 'report_group_parameters_criteria'
				, 'spa_rfx_group_parameters_criteria'
				, 'Delete Failed.'
				, @DESC3
				, ''
	END CATCH
END