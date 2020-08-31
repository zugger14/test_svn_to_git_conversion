IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_dashboard_template_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_dashboard_template_detail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

-- ===============================================================================================================
-- Created By : Biju Maharjan
-- Create date: 2014-04-24 
-- Description:	CRUD operation for dashboard template detail
-- Params:
-- @flag CHAR(1) -  Flag 's' to select dashboard template detail
--				    Flag 'i' to insert dashboard template detail
--					Flag 'u' to update dashboard template detail
--					Flag 'f' to insert filter
--					Flag 'o' to insert option
--					Flag 'p' to select option
--					Flag 'r' to return filter
-- @dashboard_template_detail_id INT = NULL 
-- @dashboard_template_id INT = NULL - dashboard template id to filter the dashboard detail
-- @xmltext	TEXT = NULL 
-- @filter NVARCHAR(MAX) = NULL - exec statement of filter
-- @option_editable NCHAR(1) = NULL - Formula option - editable
-- @option_formula INT = NULL - Formula id
-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_dashboard_template_detail]
	@flag							NCHAR(1),
	@dashboard_template_detail_id	INT = NULL,
	@dashboard_template_id			INT = NULL,
	@xmltext						TEXT = NULL,
	@filter							NVARCHAR(MAX) = NULL,
	@option_editable				NCHAR(1) = NULL,
	@option_formula					NVARCHAR(100) = NULL,
	@debug_mode						BIT = NULL
	
AS
IF ISNULL(@debug_mode, 0) = 0
   SET NOCOUNT ON
   
DECLARE @idoc INT

IF @flag = 's'
BEGIN
	SELECT	dtd1.dashboard_template_detail_id,
			dtd1.template_data_type,
			dtd1.template_data_type_name, 
			dtd1.template_data_type_order, 
			dtd1.category_order,
			dtd1.dashboard_template_id
	FROM dashboard_template_detail dtd1
	WHERE dtd1.dashboard_template_id = @dashboard_template_id
	UNION ALL
	SELECT DISTINCT 0,
					0,
					category, 
					0, 
					dtd2.category_order,
					dtd2.dashboard_template_id 
	FROM dashboard_template_detail dtd2
	WHERE dtd2.dashboard_template_id = @dashboard_template_id
	ORDER BY dtd1.category_order, dtd1.template_data_type_order
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmltext
		SELECT * INTO #dtd_xmlvalue
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 2)
			   WITH (
				   dashboard_template_id INT '@dashboard_template_id',
				   template_data_type NVARCHAR(4000) '@template_data_type',
				   category NVARCHAR(250) '@category',
				   template_data_type_order INT '@template_data_type_order',
				   category_order INT '@category_order',
				   template_data_type_name NVARCHAR(200) '@template_data_type_name'
			   )
		
		INSERT INTO dashboard_template_detail
		(
			dashboard_template_id,
			template_data_type,
			category,
			template_data_type_order,
			category_order,
			template_data_type_name
		)
		SELECT	d.dashboard_template_id,
				d.template_data_type,
				d.category,
				d.template_data_type_order,
				d.category_order,
				d.template_data_type_name
		FROM #dtd_xmlvalue d 
		
		EXEC spa_ErrorHandler 0
			, 'dashboard_template_detail'
			, 'spa_dashboard_template_detail'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'dashboard_template_detail'
			, 'spa_dashboard_template_detail'
			, 'Error'
			, 'Failed to save Dashboard Template Detail'
			, ''
	END CATCH
	
END

IF @flag = 'u'
BEGIN
	BEGIN TRY
		SELECT * INTO #temp_delete FROM dashboard_template_detail WHERE dashboard_template_id = @dashboard_template_id
		
		DELETE FROM dashboard_template_detail WHERE dashboard_template_id = @dashboard_template_id
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmltext
		SELECT * INTO #dtdu_xmlvalue
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 2)
			   WITH (
				   dashboard_template_id INT '@dashboard_template_id',
				   template_data_type NVARCHAR(4000) '@template_data_type',
				   category NVARCHAR(250) '@category',
				   template_data_type_order INT '@template_data_type_order',
				   category_order INT '@category_order',
				   template_data_type_name NVARCHAR(200) '@template_data_type_name'
			   )
		       
		INSERT INTO dashboard_template_detail
		(
			dashboard_template_id,
			template_data_type,
			category,
			template_data_type_order,
			category_order,
			filter,
			option_editable,
			option_formula,
			template_data_type_name
		)
		SELECT	d.dashboard_template_id,
				d.template_data_type,
				d.category,
				d.template_data_type_order,
				d.category_order,
				td.filter,
				td.option_editable,
				td.option_formula,
				d.template_data_type_name
		FROM #dtdu_xmlvalue d 
		LEFT JOIN #temp_delete td ON d.dashboard_template_id = td.dashboard_template_id AND 
									 d.template_data_type = td.template_data_type AND 
									 d.template_data_type_name = td.template_data_type_name AND
									 d.category = td.category
		
		EXEC spa_ErrorHandler 0
			, 'dashboard_template_detail'
			, 'spa_dashboard_template_detail'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'dashboard_template_detail'
			, 'spa_dashboard_template_detail'
			, 'Error'
			, 'Failed to update Dashboard Template Detail'
			, ''
	END CATCH
	
END

IF @flag = 'f' -- To insert the filter
BEGIN
	BEGIN TRY
		UPDATE dashboard_template_detail
		SET	
			filter =  @filter
		WHERE
			dashboard_template_detail_id = @dashboard_template_detail_id
			
		EXEC spa_ErrorHandler 0
			, 'dashboard_template_detail'
			, 'spa_dashboard_template_detail'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'dashboard_template_detail'
			, 'spa_dashboard_template_detail'
			, 'Error'
			, 'Failed to save Filter'
			, ''
	END CATCH
END

IF @flag = 'o' -- To insert the option
BEGIN
	BEGIN TRY
		UPDATE dashboard_template_detail
		SET
			option_editable = @option_editable,
			option_formula = @option_formula
		WHERE
			dashboard_template_detail_id = @dashboard_template_detail_id
	
		EXEC spa_ErrorHandler 0
				, 'dashboard_template_detail'
				, 'spa_dashboard_template_detail'
				, 'Success'
				, 'Changes have been saved successfully.'
				, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'dashboard_template_detail'
			, 'spa_dashboard_template_detail'
			, 'Error'
			, 'Failed to save Options'
			, ''
	END CATCH
END

IF @flag = 'p' -- Select the option values
BEGIN
	SELECT	
			CASE option_editable
			WHEN 'y' THEN 'true'
			ELSE 'false'
			END AS option_editable,
			option_formula
	FROM dashboard_template_detail
	WHERE dashboard_template_detail_id = @dashboard_template_detail_id
END


IF @flag = 'r' -- Return the filter
BEGIN
	SELECT dtd.filter 
	FROM dashboard_template_detail dtd
	WHERE dtd.dashboard_template_detail_id = @dashboard_template_detail_id
END
	
