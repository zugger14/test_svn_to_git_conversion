IF OBJECT_ID(N'[dbo].[spa_ssrs_html]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ssrs_html]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- Generates HTML Contents of rdl
-- Example  : EXEC spa_ssrs_html 'Deal Detail by Counterparty_Deal Detail by Counterparty', 'ITEM_DealDetailbyCounterparty_tablix:53992,paramset_id:53915,report_filter:''sub_id=1278,stra_id=1663,book_id=1687,sub_book_id=2402!2403!2513!2514!3759,block_define_id=NULL,block_type=NULL,buy_sell_flag=NULL,commodity_id=NULL,contract_id=NULL,counterparty_id=NULL,create_ts_from=2017-01-01,create_ts_to=2017-10-31,curve_id=NULL,deal_date_from=NULL,deal_date_to=NULL,deal_id=NULL,deal_lock=NULL,formula_curve_id=NULL,header_buy_sell_flag=NULL,header_physical_financial_flag=NULL,location_id=NULL,source_deal_header_id=NULL,source_deal_type_id=NULL,template_id=NULL,term_start=NULL,term_end=NULL,trader_id=NULL,update_ts_from=NULL,update_ts_to=NULL'''
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_ssrs_html]
    @report_name NVARCHAR(1000),
	@parameters NVARCHAR(max),
	@device_info NVARCHAR(MAX) = '<DeviceInfo><Toolbar>False</Toolbar></DeviceInfo>',
	@sorting  NVARCHAR(MAX) =  '', --'<Sort><Item>SortItem</Item><Direction>Ascending</Direction><Clear>True</Clear></Sort>'
	@toggle_item NVARCHAR(MAX) = '',
	@execution_id NVARCHAR(100) = '',
	@export_type NVARCHAR(20) = 'HTML4.0'

AS

SET NOCOUNT ON

BEGIN
	DECLARE @Server_url NVARCHAR(1000),@userName NVARCHAR(100),@password NVARCHAR(1000),@domain NVARCHAR(200), @output_html  NVARCHAR(MAX), @status  NVARCHAR(MAX), @document_path NVARCHAR(MAX)
	SELECT @Server_url		= report_server_url,
	       @report_name     = report_folder + '/' + @report_name,
	       @userName        = report_server_user_name,
	       @password        = dbo.[FNADecrypt](report_server_password),
	       @domain          = report_server_domain,
		   @document_path	= REPLACE(REPLACE(document_path, '\\','\'),'\','\\') + '\\temp_Note\\'
	FROM   connection_string
	
	IF @export_type <> 'HTML4.0'
	begin
		SET @device_info = '<DeviceInfo><Toolbar>False</Toolbar></DeviceInfo>'
		SET @sorting = 'NULL'
		SET @toggle_item = ''
		SET @execution_id = ''
	end

	EXEC [spa_export_rdl_to_html] @Server_url, @userName, @password, @domain, @report_name, @parameters, @device_info, @sorting, @toggle_item, @document_path, @execution_id, @export_type

		 
END









 