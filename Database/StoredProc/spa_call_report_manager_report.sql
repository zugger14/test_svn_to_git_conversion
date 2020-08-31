IF OBJECT_ID(N'[dbo].[spa_call_report_manager_report]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].spa_call_report_manager_report

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON 
GO

/**
	Get informations for calling report manager reports from other windows
	Parameters
	@flag			: 'scheduling_report' get layout,report,scheduling related informations for scheduling report call
	@report_name	: Report Name
	@deal_id		: Deal Id
	@shipment_id	: Shipment Id
*/
CREATE PROCEDURE [dbo].[spa_call_report_manager_report]
	@flag CHAR(50),
	@report_name VARCHAR(100) = NULL,
	@deal_id VARCHAR(100) = NULL,
	@shipment_id VARCHAR(100) = NULL
AS
/*
declare
	@flag CHAR(50),
	@report_name VARCHAR(100) = NULL,
	@deal_id VARCHAR(100) = NULL,
	@shipment_id VARCHAR(100) = NULL
--*/
SET NOCOUNT ON;
IF @flag = 'scheduling_report'
BEGIN
	DECLARE @items_combined VARCHAR(1000), @paramset_id VARCHAR(10)

	DECLARE @ProductTotals TABLE (
		tab_id INT,
		tab_json VARCHAR(MAX),
		form_json VARCHAR(MAX),
		layout_pattern VARCHAR(100),
		grid_json VARCHAR(MAX),
		seq INT,
		dependent_combo VARCHAR(MAX),
		filter_status CHAR(1)
	)

	INSERT INTO @ProductTotals 
	EXEC spa_view_report @flag= 'c'
		, @report_name= @report_name
		, @call_from= 'report_manager_dhx'

	SELECT @paramset_id = rpm.report_paramset_id, @items_combined = dbo.FNARFXGenerateReportItemsCombined(rpg.report_page_id)
	FROM report_paramset rpm 
	INNER JOIN report_page rpg ON rpg.report_page_id = rpm.page_id
	WHERE rpm.name = @report_name

	SELECT TOP 1 layout_pattern [process_id],
		@paramset_id [paramset_id],
		@items_combined [items_combined],
		@deal_id [deal_id],
		@shipment_id [shipment_id],
		@report_name [report_name]
	FROM @ProductTotals

END
GO