IF OBJECT_ID(N'[dbo].[spa_scheduling_workbench]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_scheduling_workbench]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**    
CRUD operation for match and bookout. 
Shows storage report for created storage deals crerated for templates that are mapped in generic mapping 
 
Parameters
@flag : Flag Operation
        - 's' AND @process_id IS NULL- load all valid deals
        - 's' AND @process_id IS NOT NULL- Collect deals for receipt and delivery grid and populate in process table.
        - 'b' - Insert bookout.
        - 'v' - Get max volume, and pre-generate lineup, shipment ids.
        - 'z' - Loading for match grid.
        - 'y' - Insert actual volume.
        - 'r' - Remove shipment.
        - 'm' - For match grid (match.php).
        - 'w' - Schedule_match_viewer(match.php).
        - 'f' - Get and load form data(match.php).
        - 'p' - Save match data in process table(match.php) -- Called on every row grid row changed.
        - 'q' - Populate match grid data(match.php).
        - 'c' - Final save for match screen(match.php).
        - 't' - Call from actualize_schedule.
        - 'l' - Get default uom.
        - 'check_split_volume' - Load split deal detail volume split grids.
        - 'n' - Load split deal detail volume split grids.
        - 'g' - Save split deal detail volume split grids.
        - 'u' - Unsplit.
        - 'j' - Storage report grid.
        - 'k' - Create storage deal.
        - 'x' - Create match if deal grid and storage grid is selected.
        - 'h' - Check if counterparty is valid and commodity are same.
        - 'e' - Update editable fields for receipt and delivery grid(sc).
        - '1' - Get default value for dependent columns.
        - '2' - Get shipment details.
        - '3' - Get Match Group ID of Shipment ID.
        - 'transbasedeal' - Not in use. 
        - 'iscreatedtransdeal' - Check if transportation deal has alrady been created for the shipment.
        - 'remove_trans_deal' - Remove transportation deals.(match.php).
        - 'replace' - Not in use. 
        - 'recall' - Recall shipment line items (match.php)
        - 'get_prod_desc_of_match_header' - Get PGS full name.
        - 'replace_into_storage' - Replace_into_storage shipment line items (match.php).
        - 'complete' - Mark shipment as complete.             
	@sell_deals : Sell deal ids.
	@buy_deals :  Buy deal ids.
	@buy_sell_flag : 'b' for buy deal and 's' for sell deal.
	@xml_value : filter values for the form
	@bookout_show : Not in use.
	@remove_book_out_id : Not in use.
	@actual_checkbox : Not in use.
	@process_id    : Unique identifier of process.
	@filter_xml : Filter data in XML format.
	@bookout_match :b for bookout m for match
	@match_deal_detail_id : 
	@xml_form : 
	@match_id : match group id
	@location_name : location from storage grid
	@mode : insert update mode
	@split_deal_detail_volume_id : split id of source_deal_detail_id
	@no_of_rows : number of rows to split line items(shipment or deal detail)
	@split_quantity : volume to split 
	@percentage : split shipment or deal detail via percentage
	@total_quantity : total qouantity available in deal during split
	@convert_uom : conversion UOM
	@convert_frequency : conversion frequency
	@deal_detail_id_split_deal_detail_volume_id : deal detail id with its respective split id
	@merge_quantity : merge  quantity 
	@injection_withdrawal :i for injection and w for withdrawal for creating storage deals
	@term_start : term start of source deal detail 
	@shipment_name : shipmnet name 
	@location_id : location id from storage grid
	@wacog FLOAT : wacog or price from the storage grid
	@contract_id : contract from the storage grid
	@get_group_id :get new group id 
	@spilt_deal_detail_id : split id for the deal detail 
	@region INT : locatin region 
	@commodity_name : commodity from the storage grid
	@term_end : term end of deal detail 
	@to_select : used to exec final statement or load to process table only
	@commodity_id : commidity id 
	@column_name : column names for dependent commodity combos
	@match_group_shipment_id : match group shipment id
	@location_contract_commodity : seqence number of storage grid
	@match_group_id : match group id 
	@grid_name : grid name for Match tab tree grid
	@match_group_header_id : match group header id
	@call_from : call from 
	@product_description : commodity string with all the attributes
	@base_transportation_deal : to check of it has base transportation deal --not in use
	@packaging_uom : Packaing UOM
	@match_shipment_id : 
	@match_group_detail_id : match group detail id 
	@replaced_id :  ID of detail id that is to be replaced
	@is_back_to_back : back to back deal type flag
	@purchase_deal_id : purchase deal id
	@lot : purchase deal detail id 
	@is_transport_created : check if transportation is created 
	@storage_location_volume : strorage grid volume --not in use
	@recall_flag : recall deal detail id 
	@recalled_ids : recalled match group detail id
	@storage_operator : counterparty of storage grid
	@location_to : destination location for creating storage 
	@replace_or_replace_into_storage : replace for replace into storage flag
	@product_type : --1 Fungible 0 warehouse-- check for static data value.
	@is_pipeline : check if location iud pipeline or not

	*************************************************************************************************
	-------------------naming conventions-----------------------
	PRINCIPAL 	 	 
		
	Group 		GRP - [Group ID] | [First Origin Deal ID] - [First Origin Deal CP] | [Last Destination Deal ID] - [LastDestination Deal CP] 	
	Shipment    SHP - [Shipment ID] | [Origin Deal ID] - [Origin Deal Line Group Description] - [Origin Deal CP] | [Destination Deal ID] - [Destination Deal Line Group Description] - [Destination Deal CP] 		
	Match 		MTC - [Match ID] | [Location] | [Product] 		
	Calendar 	SHP - [Shipment ID] | [Origin Deal ID] - [Origin Deal Line Group Description] - [Origin Deal CP] | [Destination Deal ID] - [Destination Deal Line Group Description] - [Destination Deal CP] | [Next  Section] | [Next Action] 

	AGENCY 	 	 		
	Group 		GRP - [Group ID] | [Agency Deal ID] - [Agency Deal Seller] - [Agency Deal Buyer] 	
	Shipment 	SHP - [Shipment ID] | [Agency Deal ID] - [Agency Deal Line Group Description] - [Agency Deal Seller] - [Agency Deal Buyer] 	
	Match 		MTC - [Match ID] | [Product] 		
	Calendar 	SHP - [Shipment ID] | [Agency Deal ID] - [Agency Deal Line Group Description] - [Agency Deal Seller] - [Agency Deal Buyer] | [Next Section] | [Next Action] 
	*************************************************************************************************
*/

CREATE PROCEDURE [dbo].[spa_scheduling_workbench]
	@flag VARCHAR(1000),
	@sell_deals VARCHAR(5000) = NULL,
	@buy_deals VARCHAR(5000) = NULL,
	@buy_sell_flag CHAR(1) = NULL,
	@xml_value VARCHAR(MAX)  = NULL,
	@bookout_show CHAR(1) = NULL,
	@remove_book_out_id VARCHAR(5000) = NULL,
	@actual_checkbox CHAR(1) = NULL,
	@process_id	 VARCHAR(255) = NULL,
	@filter_xml VARCHAR(MAX) = NULL,
	@bookout_match CHAR(1) = NULL,
	@match_deal_detail_id VARCHAR(MAX) = NULL,
	@xml_form VARCHAR(MAX)  = NULL,
	@match_id VARCHAR(5000) = NULL,  -- also used for complete flag for match_group_header_id
	@location_name VARCHAR(5000) = NULL,
	@mode CHAR(1) = NULL, 
	@split_deal_detail_volume_id INT = NULL,
	@no_of_rows VARCHAR(100) = NULL,
	@split_quantity  VARCHAR(100) = NULL,
	@percentage INT = NULL,
	@total_quantity NUMERIC(38,18) = NULL,
	@convert_uom INT = NULL,
	@convert_frequency INT = NULL,
	@deal_detail_id_split_deal_detail_volume_id VARCHAR(1000) = NULL,
	@merge_quantity FLOAT = NULL,
	@injection_withdrawal CHAR(1) = NULL,
	@term_start DATETIME = NULL,
	@shipment_name VARCHAR(1000) = NULL,
	@location_id VARCHAR(1000) = NULL,
	@wacog FLOAT = NULL,
	@contract_id VARCHAR(1000) = NULL,
	@get_group_id INT = NULL,
	@spilt_deal_detail_id INT = NULL,
	@region INT = NULL,
	@commodity_name VARCHAR(1000) = NULL,
	@term_end DATETIME = NULL,
	@to_select CHAR(1) = NULL,
	@commodity_id INT = NULL,
	@column_name VARCHAR(1000) = NULL,
	@match_group_shipment_id VARCHAR(100) = NULL,
	@location_contract_commodity VARCHAR(MAX) = NULL,
	@match_group_id INT = NULL,
	@grid_name VARCHAR(1000) = NULL,
	@match_group_header_id INT = NULL,
	@call_from VARCHAR(100) = 's',
	@product_description VARCHAR(MAX) = NULL,
	@base_transportation_deal VARCHAR(MAX) = NULL,
	@packaging_uom VARCHAR(MAX) = NULL,
	@match_shipment_id INT = NULL,
	@match_group_detail_id VARCHAR(MAX) = NULL,
	@replaced_id INT = NULL,
	@is_back_to_back CHAR(1) = 'n',  --y for back to back deal only; 'n' for other default 
	@purchase_deal_id VARCHAR(MAX) = NULL,
	@lot VARCHAR(MAX) = NULL,
	@is_transport_created INT = 0,
	@storage_location_volume VARCHAR(MAX) = NULL,
	@recall_flag VARCHAR(MAX) = NULL,
	@recalled_ids VARCHAR(MAX) = NULL,
	@storage_operator INT = NULL,
	@location_to INT = NULL,
	@replace_or_replace_into_storage VARCHAR(100) = NULL,
	@product_type INT = 1, --1 Fungible 0 warehouse-- check for static data value.
	@is_pipeline VARCHAR(1000) = NULL
AS
 
SET NOCOUNT ON
 
/*

DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo

DECLARE
	@flag CHAR(1) = 's',
	@sell_deals VARCHAR(5000) = NULL,
	@buy_deals VARCHAR(5000) = NULL,
	@buy_sell_flag CHAR(1) = NULL,
	@xml_value VARCHAR(MAX)  = NULL,
	@bookout_show CHAR(1) = NULL,
	@remove_book_out_id VARCHAR(5000) = NULL,
	@actual_checkbox CHAR(1) = NULL,
	@process_id	 VARCHAR(255) = NULL,
	@filter_xml VARCHAR(MAX) = NULL,
	@bookout_match CHAR(1) = NULL,
	@match_deal_detail_id INT = NULL,
	@xml_form VARCHAR(MAX)  = NULL,
	@match_id VARCHAR(500) = NULL,
	@location_name VARCHAR(5000) = NULL,
	@mode CHAR(1) = NULL, 
	@split_deal_detail_volume_id INT = NULL,
	@no_of_rows VARCHAR(100) = NULL,
	@split_quantity  VARCHAR(100) = NULL,
	@percentage INT = NULL,
	@total_quantity NUMERIC(38,18) = NULL,
	@convert_uom INT = NULL,
	@convert_frequency INT = NULL,
	@deal_detail_id_split_deal_detail_volume_id VARCHAR(1000) = NULL,
	@merge_quantity FLOAT = NULL,
	@injection_withdrawal CHAR(1) = NULL,
	@term_start DATETIME = NULL,
	@shipment_name VARCHAR(1000) = NULL,
	@location_id VARCHAR(1000) = NULL,
	@wacog FLOAT = NULL,
	@contract_id VARCHAR(1000) = NULL,
	@get_group_id INT = NULL,
	@spilt_deal_detail_id INT = NULL,
	@region INT = NULL,
	@commodity_name VARCHAR(1000) = NULL,
	@term_end DATETIME = NULL,
	@to_select CHAR(1) = NULL,
	@commodity_id INT = NULL,
	@column_name VARCHAR(1000) = NULL,
	@match_group_shipment_id VARCHAR(100) = 6881,
	@location_contract_commodity VARCHAR(MAX) = NULL,
	@match_group_header_id INT = 6881,
	@match_group_id INT = NULL,
	@grid_name VARCHAR(1000) = NULL,
	--@match_group_header_id INT = NULL,
	@call_from  VARCHAR(100)  = 'view_match_deal',
	@product_description VARCHAR(MAX) = NULL,
	@base_transportation_deal VARCHAR(MAX) = NULL,
	@packaging_uom VARCHAR(MAX) = NULL,
	@match_shipment_id INT = NULL,
	@match_group_detail_id VARCHAR(MAX) = NULL,
	@replaced_id INT = NULL,
	@is_back_to_back CHAR(1) = 'n',  --y for back to back deal only; 'n' for other default 
	@purchase_deal_id VARCHAR(MAX) = NULL,
	@lot VARCHAR(MAX) = NULL,
	@is_transport_created INT = 0,
	@storage_location_volume VARCHAR(MAX) = NULL,
	@recall_flag VARCHAR(MAX) = NULL,
	@recalled_ids VARCHAR(MAX) = NULL,
	@storage_operator INT = NULL,
	@location_to INT = NULL,
	@replace_or_replace_into_storage  VARCHAR(100) = NULL


--select @flag='s',@buy_sell_flag=NULL,@process_id='FF63253A_D84C_4E27_BAD5_FC558F30317E', @call_from = 'view_match_deal', @match_group_shipment_id = 6881	

select @flag = 'v', @process_id = 'FF63253A_D84C_4E27_BAD5_FC558F30317E', @buy_deals = '', @sell_deals = ''
			, @convert_uom = 1082, @convert_frequency=703, @mode = 'u', @get_group_id = 1, @bookout_match = 'm'
			, @match_group_id = 6707, @call_from = 'view_match_deal'
			, @match_group_shipment_id = 6881
			
--select  @flag='q',@process_id='AD6DCDB3_05C1_46FC_A32C_6AA27083DAC9',@buy_deals='',@sell_deals='',@match_id=NULL,@convert_uom='1083',@convert_frequency='703',@shipment_name=NULL,@mode='u',@location_id=NULL,@bookout_match='m'
--,@contract_id=NULL,@commodity_name=NULL,@location_contract_commodity=NULL,@match_group_id='26'
--select * from  adiha_process.dbo.all_deals_farrms_admin_1916CA82_3CE0_4E19_872A_7F5E940F6364
*/
DECLARE @jobs_process_id VARCHAR(200) = dbo.FNAGETNewID()
DECLARE @alert_process_table VARCHAR(300)

IF @sell_deals = ''  
	SET  @sell_deals = NULL

IF @match_group_id = ''  
	SET  @match_group_id = NULL

IF @buy_sell_flag = ''
	SET @buy_sell_flag = NULL

IF @location_contract_commodity = ''
	SET @location_contract_commodity = NULL

IF OBJECT_ID('tempdb..#filter_xml_data') IS NOT NULL 
	DROP TABLE #filter_xml_data

IF OBJECT_ID('tempdb..#quantity_conversion') IS NOT NULL 
	DELETE FROM #quantity_conversion

IF OBJECT_ID('tempdb..#price_conversion') IS NOT NULL 
	DROP TABLE #price_conversion
	
IF OBJECT_ID('tempdb..#all_deals_collection') IS NOT NULL 
	DROP TABLE #all_deals_collection	

IF OBJECT_ID('tempdb..#commodity_attribute_form_detail') IS NOT NULL 
	DELETE FROM #commodity_attribute_form_detail

IF OBJECT_ID('tempdb..#application_users') IS NOT NULL 
	DROP TABLE #application_users

IF @no_of_rows = '' 
	SET @no_of_rows = NULL

IF @split_quantity = '' 
	SET @split_quantity = NULL

IF @to_select IS NULL
	SET @to_select = 'y'

DECLARE @sql VARCHAR(MAX)
DECLARE @report_position VARCHAR(150)
DECLARE @user_name VARCHAR(30) = dbo.FNADBUser()	
DECLARE @idoc INT
DECLARE @org_deal_id INT
DECLARE @chk_deal_volume INT
DECLARE @st1 VARCHAR(MAX)
DECLARE @spa VARCHAR(MAX)
DECLARE @job_name VARCHAR(150)
DECLARE @all_deal_coll VARCHAR(MAX)
DECLARE @all_deal_coll_b_m VARCHAR(MAX)
DECLARE @deal_detail_volume_split VARCHAR(MAX)
DECLARE @match_properties VARCHAR(5000)
DECLARE @template_id INT 
DECLARE @sub_book INT
DECLARE @sub_type	VARCHAR(100)			
DECLARE @internal_deal_type VARCHAR(100)	
DECLARE @internal_sub_type VARCHAR(100)	
DECLARE @header_buy_sell_flag VARCHAR(100)
DECLARE @new_deal_counterparty_id VARCHAR(1000) 
DECLARE @transportation_deal_collect_tbl VARCHAR(100)
DECLARE @same_location_data VARCHAR(500)
DECLARE @new_source_deal_groups INT 

/*commodity attribute variables */
DECLARE @origin VARCHAR(1000)
DECLARE @form VARCHAR(1000)
DECLARE @organic CHAR(1)
DECLARE @attribute1 VARCHAR(1000)
DECLARE @attribute2 VARCHAR(1000)
DECLARE @attribute3 VARCHAR(1000)
DECLARE @attribute4 VARCHAR(1000)
DECLARE @attribute5 VARCHAR(1000)
DECLARE @crop_year VARCHAR(1000)
DECLARE @detail_inco_terms VARCHAR(1000)
 
IF @filter_xml = ''
	SET @filter_xml = NULL

IF @location_contract_commodity = 'NULL'
	SET @location_contract_commodity = NULL		

IF @product_type IS NULL 
	SET @product_type = 1


IF @flag = 's' AND @process_id IS NULL  
BEGIN 
	SET @process_id = dbo.FNAGetNewID()
	DECLARE @return_match_group_id INT = ''

	IF @match_group_shipment_id IS NOT NULL OR @match_group_shipment_id <> ''
	BEGIN
		SELECT @return_match_group_id = match_group_id FROM match_group_shipment 
		WHERE match_group_shipment_id = @match_group_shipment_id
	END
	ELSE
	BEGIN
		SET @return_match_group_id = @match_group_id
	END
		
	--SET @all_deal_coll = dbo.FNAProcessTableName('all_deals', @user_name, @process_id)
	--SET @all_deal_coll_b_m = dbo.FNAProcessTableName('all_deals_b_m', @user_name, @process_id)
	IF @call_from = 'view_match_deal' --this value is passed from view shipment grid hyperlink to view match deal.
	BEGIN
		EXEC spa_scheduling_workbench @flag = 's'
			, @buy_sell_flag = NULL
			, @process_id = @process_id
			, @call_from = @call_from
			, @match_group_shipment_id = @match_group_shipment_id
			, @convert_uom = @convert_uom	
		RETURN
	END
	ELSE
	BEGIN
		SELECT @process_id [process_id], @return_match_group_id [parent_object_id]		
		RETURN
	END		
END

/* for filters */
CREATE TABLE #filter_xml_data (row_id						INT IDENTITY(1, 1), 
								commodity					VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
								deal_type					VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
								period_from					DATETIME, 
								commodity_group				VARCHAR(5000) COLLATE DATABASE_DEFAULT,
								period_to					DATETIME, 
								loc_group					VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
								[location]					VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
								quantity_uom				VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
								price_uom					VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
								ticket_number				VARCHAR(5000) COLLATE DATABASE_DEFAULT,
								label_ticket_number			VARCHAR(5000) COLLATE DATABASE_DEFAULT,
								match_number				VARCHAR(5000) COLLATE DATABASE_DEFAULT,
								show_match_ticket			CHAR(1) COLLATE DATABASE_DEFAULT,
								match_status				CHAR(1) COLLATE DATABASE_DEFAULT, 
								frequency					INT,
								split_status				CHAR(1) COLLATE DATABASE_DEFAULT,
								schedule_match_status		INT,
								--commodity_origin_id			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
								--commodity_form_id			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
								--commodity_form_attribute1	VARCHAR(1000) COLLATE DATABASE_DEFAULT,
								--commodity_form_attribute2	VARCHAR(1000) COLLATE DATABASE_DEFAULT,
								--commodity_form_attribute3	VARCHAR(1000) COLLATE DATABASE_DEFAULT,
								--commodity_form_attribute4	VARCHAR(1000) COLLATE DATABASE_DEFAULT,
								--commodity_form_attribute5	VARCHAR(1000) COLLATE DATABASE_DEFAULT,
								--organic						CHAR(1) COLLATE DATABASE_DEFAULT,
								incoterm					INT, 
								crop_year					INT,
								sub_deal_type				VARCHAR(5000) COLLATE DATABASE_DEFAULT,
								lot							VARCHAR(5000) COLLATE DATABASE_DEFAULT,
								shipment_id					VARCHAR(5000) COLLATE DATABASE_DEFAULT,
								actualized_match			CHAR(1) COLLATE DATABASE_DEFAULT,
								show_zero_volume			CHAR(1) COLLATE DATABASE_DEFAULT,
								purchase_deal_id			VARCHAR(1000) COLLATE DATABASE_DEFAULT,
								sale_deal_id				VARCHAR(1000) COLLATE DATABASE_DEFAULT
								)

--collect filter data
IF @filter_xml IS NOT NULL
BEGIN 
	EXEC sp_xml_preparedocument @idoc OUTPUT, @filter_xml
	
	INSERT INTO #filter_xml_data(commodity, deal_type, period_from, period_to, loc_group, location, quantity_uom, frequency, price_uom
								, commodity_group,ticket_number, label_ticket_number, match_number,show_match_ticket,match_status
								, split_status, schedule_match_status
								--, commodity_origin_id
								--, commodity_form_id
								--, commodity_form_attribute1
								--, commodity_form_attribute2
								--, commodity_form_attribute3
								--, commodity_form_attribute4
								--, commodity_form_attribute5
								--, organic
								, incoterm
								, crop_year	
								, sub_deal_type
								, lot
								, shipment_id
								, actualized_match
								, show_zero_volume								
								, purchase_deal_id		
								, sale_deal_id			
								)
	SELECT commodity, deal_type, period_from, period_to, loc_group, location, quantity_uom, frequency, price_uom, commodity_group,ticket_number, label_ticket_number, match_number,show_match_ticket,match_status
			, split_status, schedule_match_status
			--, commodity_origin_id, commodity_form_id, commodity_form_attribute1, commodity_form_attribute2, commodity_form_attribute3, commodity_form_attribute4, commodity_form_attribute5, organic
			, incoterm, crop_year, sub_deal_type, lot, shipment_id, actualized_match, show_zero_volume
			, purchase_deal_id		
			, sale_deal_id			
	FROM   OPENXML (@idoc, '/Root/FormFilterXML', 2)
			WITH ( 
				commodity					VARCHAR(5000)	'@commodity_id',						
				deal_type					VARCHAR(5000)	'@deal_type', 
				period_from					DATETIME		'@period_from',
				period_to					DATETIME		'@period_to',
				loc_group					VARCHAR(5000)	'@location_group',
				[location]					VARCHAR(5000)	'@location',
				quantity_uom				VARCHAR(5000)	'@quantity_uom',
				frequency					VARCHAR(5000)	'@frequency',
				price_uom					VARCHAR(5000)	'@price_uom',
				commodity_group				VARCHAR(5000)	'@commodity_group',
				ticket_number				VARCHAR(5000)	'@ticket_number',
				label_ticket_number			VARCHAR(5000)	'@label_ticket_number',
				match_number				VARCHAR(5000)	'@match_number',
				show_match_ticket			VARCHAR(100)	'@show_match_ticket',
				match_status				VARCHAR(100)	'@match_status',
				split_status				VARCHAR(100)	'@split_status',
				schedule_match_status		VARCHAR(100)	'@schedule_match_status',
				--commodity_origin_id			VARCHAR(100)	'@commodity_origin_id',		
				--commodity_form_id			VARCHAR(100)	'@commodity_form_id',		
				--commodity_form_attribute1	VARCHAR(100)	'@commodity_form_attribute1',
				--commodity_form_attribute2	VARCHAR(100)	'@commodity_form_attribute2',
				--commodity_form_attribute3	VARCHAR(100)	'@commodity_form_attribute3',
				--commodity_form_attribute4	VARCHAR(100)	'@commodity_form_attribute4',
				--commodity_form_attribute5	VARCHAR(100)	'@commodity_form_attribute5',
				--organic						CHAR(1)			'@organic',
				incoterm					VARCHAR(100)	'@inco_terms', 
				crop_year					VARCHAR(100)	'@crop_year',
				sub_deal_type				VARCHAR(100)	'@sub_deal_type',
				lot							VARCHAR(100)	'@lot',
				shipment_id					VARCHAR(5000)	'@shipment_id',
				actualized_match			CHAR(1)			'@actualized_match',
				show_zero_volume			CHAR(1)			'@show_zero_volume',
				purchase_deal_id			VARCHAR(1000)	'@purchase_deal_id', 
				sale_deal_id				VARCHAR(1000)	'@sale_deal_id'
				)
	EXEC sp_xml_removedocument @idoc
	
	UPDATE #filter_xml_data
	SET commodity = CASE WHEN commodity = '' THEN NULL ELSE commodity END , 
		deal_type = CASE WHEN deal_type = '' THEN NULL ELSE deal_type END, 
		period_from = CASE WHEN period_from = '' THEN NULL  ELSE period_from END, 
		period_to = CASE WHEN  period_to = '' THEN NULL  ELSE period_to END, 
		loc_group = CASE WHEN loc_group = '' THEN NULL ELSE loc_group END, 
		location = CASE WHEN location= '' THEN NULL ELSE location END, 
		quantity_uom = CASE WHEN quantity_uom = '' THEN  NULL ELSE quantity_uom END, 	
		price_uom = CASE WHEN price_uom = '' THEN NULL ELSE price_uom END,
		commodity_group = CASE WHEN commodity_group = '' THEN NULL ELSE commodity_group END,
		ticket_number = CASE WHEN ticket_number = '' THEN NULL ELSE ticket_number END,
		label_ticket_number = CASE WHEN label_ticket_number = '' THEN NULL ELSE label_ticket_number END,
		match_number = CASE WHEN match_number = '' THEN NULL ELSE match_number END,
		show_match_ticket = CASE WHEN ticket_number = '' THEN NULL ELSE show_match_ticket END,
		match_status = CASE WHEN match_status = '' THEN NULL ELSE match_status END,
		split_status = CASE WHEN split_status = '' THEN NULL ELSE split_status END,
		frequency = CASE WHEN frequency = '' THEN 703 ELSE frequency END,
		schedule_match_status = CASE WHEN schedule_match_status = '' THEN NULL ELSE schedule_match_status END,
		--commodity_origin_id = CASE WHEN commodity_origin_id = '' THEN NULL ELSE commodity_origin_id END,
		--commodity_form_id = CASE WHEN commodity_form_id = '' THEN NULL ELSE commodity_form_id END,	 
		--commodity_form_attribute1 = CASE WHEN commodity_form_attribute1 = '' THEN NULL ELSE commodity_form_attribute1 END,
		--commodity_form_attribute2 = CASE WHEN commodity_form_attribute2 = '' THEN NULL ELSE commodity_form_attribute2 END,
		--commodity_form_attribute3 = CASE WHEN commodity_form_attribute3 = '' THEN NULL ELSE commodity_form_attribute3 END,
		--commodity_form_attribute4 = CASE WHEN commodity_form_attribute4 = '' THEN NULL ELSE commodity_form_attribute4 END,
		--commodity_form_attribute5 = CASE WHEN commodity_form_attribute5 = '' THEN NULL ELSE commodity_form_attribute5 END,
		--organic = CASE WHEN organic = '' THEN 'n' ELSE organic END,
		incoterm = CASE WHEN incoterm = '' THEN NULL ELSE incoterm END,
		crop_year = CASE WHEN crop_year = '' THEN NULL ELSE crop_year END,
		sub_deal_type = CASE WHEN sub_deal_type = '' THEN NULL ELSE sub_deal_type END,
		lot = CASE WHEN lot = '' THEN NULL ELSE lot END,
		shipment_id = CASE WHEN shipment_id = '' THEN NULL ELSE shipment_id END,
		actualized_match = CASE WHEN actualized_match = '' THEN NULL ELSE actualized_match END,
		show_zero_volume = CASE WHEN show_zero_volume = '' THEN NULL ELSE show_zero_volume END,
		purchase_deal_id = CASE WHEN purchase_deal_id = '' THEN NULL ELSE purchase_deal_id END,
		sale_deal_id = CASE WHEN sale_deal_id = '' THEN NULL ELSE sale_deal_id END
END

DECLARE @commodity VARCHAR(5000)
DECLARE @deal_type VARCHAR(5000)	
DECLARE @loc_group VARCHAR(5000)
DECLARE @location VARCHAR(5000)
DECLARE @quantity_uom VARCHAR(50)
DECLARE @quantity_uom_name VARCHAR(5000)
DECLARE @frequency VARCHAR(5000)
DECLARE @price_uom VARCHAR(5000)
DECLARE @commodity_group VARCHAR(5000)
DECLARE @ticket_number VARCHAR(5000)
DECLARE @label_ticket_number VARCHAR(5000)
DECLARE @match_number VARCHAR(5000)
DECLARE @shipment_id VARCHAR(5000)
DECLARE @split_status VARCHAR(100)
DECLARE @schedule_match_status VARCHAR(100)
DECLARE @show_match_ticket VARCHAR(10)
DECLARE @match_status VARCHAR(10)
DECLARE @period_from DATETIME
DECLARE @period_to DATETIME
DECLARE @lineup_vol_id_tbl VARCHAR(5000)
DECLARE @new_source_deal_detail_id INT
DECLARE @report_position_deals VARCHAR(300)
DECLARE @total_vol_sql VARCHAR(MAX)	
DECLARE @user_login_id VARCHAR(1000)
DECLARE @deal_pre VARCHAR(100)
DECLARE @new_source_deal_header_id INT
DECLARE @max_bookout_available FLOAT 
DECLARE @ini_book_out_value VARCHAR(1000) 
DECLARE @ini_group_name VARCHAR(1000) 
DECLARE @ini_lineup VARCHAR(1000) 
DECLARE @parent_line VARCHAR(1000)
DECLARE @row_count INT
DECLARE @row_count_group INT
DECLARE @deal_split_id_check INT 
DECLARE @match_group_id_check INT
DECLARE @rec_counterparty VARCHAR(MAX)
DECLARE @del_counterparty VARCHAR(MAX)
DECLARE @buy_deals_final VARCHAR(MAX)
DECLARE @sell_deals_final VARCHAR(MAX)
DECLARE @transportation_deals VARCHAR(MAX)
DECLARE @actualized_match CHAR(1)
DECLARE @show_zero_volume CHAR(1) 
DECLARE @purchase_deal_id_fil VARCHAR(1000)	
DECLARE @sale_deal_id_fil VARCHAR(1000)		
 
DECLARE @commodity_origin_id VARCHAR(100)
DECLARE @commodity_form_id VARCHAR(100)
DECLARE @commodity_form_attribute1 VARCHAR(100)
DECLARE @commodity_form_attribute2 VARCHAR(100)
DECLARE @commodity_form_attribute3 VARCHAR(100)
DECLARE @commodity_form_attribute4 VARCHAR(100)
DECLARE @commodity_form_attribute5 VARCHAR(100)
DECLARE @shipment_status VARCHAR(1000)
DECLARE @match_group_shipment VARCHAR(1000)
DECLARE @incoterm VARCHAR(1000)
DECLARE @sub_deal_type VARCHAR(1000)
DECLARE @return_str VARCHAR(MAX)

DECLARE @template_header_inco_term INT
DECLARE @template_detail_inco_term INT
DECLARE @template_deal_locked CHAR(1)

SELECT @commodity = commodity,
		@deal_type = deal_type,
		@loc_group = loc_group,
		@location = [location],
		@quantity_uom = quantity_uom,
		@price_uom = price_uom,
		@period_from = period_from,
		@period_to = period_to,
		@commodity_group = commodity_group,
		@ticket_number = ticket_number,
		@label_ticket_number = label_ticket_number,
		@match_number = match_number,
		@show_match_ticket = show_match_ticket,
		@frequency = frequency,
		@split_status = split_status,
		@schedule_match_status = schedule_match_status,
		@match_status  = match_status,
		--@commodity_origin_id = commodity_origin_id,
		--@commodity_form_id = commodity_form_id,
		--@commodity_form_attribute1 = commodity_form_attribute1, 	 
		--@commodity_form_attribute2 = commodity_form_attribute2, 	 
		--@commodity_form_attribute3 = commodity_form_attribute3, 	 
		--@commodity_form_attribute4 = commodity_form_attribute4, 
		--@commodity_form_attribute5 = commodity_form_attribute5, 
		--@organic = organic, 
		@incoterm = incoterm,
		@crop_year = crop_year,
		@sub_deal_type = sub_deal_type,
		@lot = lot,
		@shipment_id = shipment_id,
		@actualized_match = actualized_match,
		@show_zero_volume = show_zero_volume,
		@purchase_deal_id_fil = purchase_deal_id,
		@sale_deal_id_fil = sale_deal_id
FROM #filter_xml_data
 
SELECT @quantity_uom_name = uom_name 
FROM source_uom 
WHERE source_uom_id = @quantity_uom
 
DECLARE @wacog_data_coll VARCHAR(MAX)
	SET @wacog_data_coll = dbo.FNAProcessTableName('wacog_data_coll', @user_name, @process_id)

/* filters end */
DECLARE @term_start_storage DATETIME, @term_end_storage DATETIME
DECLARE @final_storage_inventory_grouped VARCHAR(MAX)

--get location commodity from storage report grid(scheduling workbech window)
IF @location_contract_commodity IS NOT NULL OR @location_contract_commodity <> 'NULL'  
BEGIN 
	SET @final_storage_inventory_grouped = dbo.FNAProcessTableName('final_storage_inventory_grouped', @user_name, @process_id)
	
	IF OBJECT_ID('tempdb..#to_generate_match_id_storage_deal_temp') IS NOT NULL 
		DROP TABLE #to_generate_match_id_storage_deal_temp

	CREATE TABLE #to_generate_match_id_storage_deal_temp(location_id INT, contract_id INT, source_commodity_id INT	
														, commodity_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
														, region INT
														, region_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
														, term_start DATETIME, buy_sell CHAR(1) COLLATE DATABASE_DEFAULT
														, total_volume NUMERIC(38, 18), wacog NUMERIC(38, 18)
														, product_description VARCHAR(1000) COLLATE DATABASE_DEFAULT
														, base_id VARCHAR(1000) COLLATE DATABASE_DEFAULT
														, lot VARCHAR(1000) COLLATE DATABASE_DEFAULT
														, location_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
														, batch_id VARCHAR(1000) COLLATE DATABASE_DEFAULT
														, seq_no INT
														, storage_deal_id INT
														, packing_uom VARCHAR(MAX) COLLATE DATABASE_DEFAULT
														, counterparty_id INT)
	
	SET @sql = '
				INSERT INTO #to_generate_match_id_storage_deal_temp(location_id, contract_id, source_commodity_id,  commodity_name
																	 , region, region_name, term_start, buy_sell, total_volume, wacog
																	 , product_description, base_id, lot, location_name, batch_id
																	 , seq_no, storage_deal_id, packing_uom, counterparty_id)
				 SELECT  a.source_minor_location_id, cg.contract_id, a.commodity_id, a.product 
						, ISNULL(sdv.value_id, a.source_minor_location_id), ISNULL(sdv.code, sml.location_id), NULL
						, CASE WHEN ''' + @buy_deals + ''' = '''' THEN ''b'' ELSE ''s'' END
						, a.schedule_volume, a.price
						, a.product, a.parent_source_deal_header_id, a.lot, sml.location_id, NULL production_batch_reference_id
						, NULL, a.storage_deal_id, NULL, sco.source_counterparty_id
				FROM ' + @final_storage_inventory_grouped + ' a
				INNER JOIN dbo.FNASplit(''' + @location_contract_commodity + ''', '':'') z On z.item = a.seq_no
				LEFT JOIN source_commodity sc ON sc.source_commodity_id = a.commodity_id
				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = a.source_minor_location_id
				LEFT JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID
				LEFT JOIN static_data_value sdv ON sml.region = sdv.value_id 
				LEFT JOIN contract_group cg ON cg.[contract_name] = a.[contract] 
				LEFT JOIN source_counterparty sco ON sco.counterparty_id = a.operator

		'
	EXEC spa_print @sql
	EXEC(@sql)  

	/*
	UPDATE sdd
	SET packing_uom = udddf.udf_value 
	FROM user_defined_deal_detail_fields udddf
	INNER JOIN #to_generate_match_id_storage_deal_temp sdd ON udddf.source_deal_detail_id = sdd.lot
	INNER JOIN user_defined_deal_fields_template uddft ON udddf.udf_template_id = uddft.udf_template_id 
	INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
	WHERE  1 = 1
		AND udft.Field_label IN ('Packaging UOM')
	*/

	UPDATE a 
	SET a.seq_no = b.seq_no 
	FROM #to_generate_match_id_storage_deal_temp a 
	INNER JOIN (
				SELECT location_id
					, source_commodity_id
					, buy_sell
					, lot 
					, ROW_NUMBER() OVER(ORDER BY location_id, base_id, lot, ISNULL(batch_id, '''')) seq_no  
				FROM #to_generate_match_id_storage_deal_temp temp) b ON 
					b.location_id			= a.location_id			
					AND b.source_commodity_id = a.source_commodity_id 
					AND b.buy_sell			= a.buy_sell			
					AND b.lot				= a.lot		 

	IF @product_type = 1
	BEGIN 
		--select *
		--UPDATE a
		--SET a.lot = b.source_deal_detail_id,
		--	a.base_id = b.source_deal_header_id			 
		--FROM #to_generate_match_id_storage_deal_temp a
		--INNER JOIN (
		--		SELECT 
		--			MAX(sdd_pur.source_deal_header_id) source_deal_header_id
		--			, MAX(mgd.lot) source_deal_detail_id 
		--			, tgt.source_commodity_id
		--			, tgt.contract_id
		--			, tgt.location_id
		--		--, mgd.lot, sdd_pur.source_deal_header_id
		--		FROM source_deal_header sdh
		--		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 
		--		INNER JOIN match_group_detail mgd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
		--		INNER JOIN #to_generate_match_id_storage_deal_temp tgt ON tgt.location_id = sdd.location_id
		--			AND ISNULL(tgt.contract_id, '') = ISNULL(sdh.contract_id, '')
		--		LEFT JOIN general_assest_info_virtual_storage gaivs ON gaivs.agreement = tgt.contract_id AND gaivs.storage_location = tgt.location_id
		--		LEFT JOIN source_commodity sssc ON sssc.source_commodity_id = gaivs.commodity_id
		--		INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		--		INNER JOIN source_deal_detail sdd_pur ON sdd_pur.source_deal_detail_id = mgd.lot		
		--		WHERE 1 = 1 
		--			AND sdt.deal_type_id = 'Storage'
		--			GROUP BY tgt.location_id, tgt.contract_id, tgt.source_commodity_id
		--		) b ON a.source_commodity_id = b.source_commodity_id
		--AND a.contract_id = b.contract_id
		--AND a.location_id = b.location_id

		SELECT @term_start_storage = MIN(sdd.term_start) , @term_end_storage = MAX(sdd.term_end) 
		FROM source_deal_detail sdd 
		INNER JOIN (
					SELECT SUBSTRING(combined_id, 1, CHARINDEX('_', combined_id) - 1) AS source_deal_detail_id,
						SUBSTRING(combined_id, CHARINDEX('_', combined_id) + 1, LEN(combined_id)) AS split_deal_detail_volume_id,
						buy_sell_flag
					FROM (SELECT item combined_id, 'b' buy_sell_flag FROM dbo.FNASplit(@buy_deals, ',') 
					UNION ALL
					SELECT item, 's' FROM dbo.FNASplit(@sell_deals, ',')) a 
			) b ON sdd.source_deal_detail_id = b.source_deal_detail_id
		UPDATE #to_generate_match_id_storage_deal_temp SET term_start = @term_start_storage WHERE term_start IS NULL
	END
	ELSE 
	BEGIN 
		UPDATE #to_generate_match_id_storage_deal_temp SET term_start = GETDATE() WHERE term_start IS NULL		
	END 
END  

DECLARE @default_uom INT
SELECT @default_uom = CAST(source_uom_id AS INT) FROM source_uom WHERE uom_id = 'tons' -- default as pound
--select @default_uom

IF @convert_uom IS NULL
	SET @convert_uom = ISNULL(@quantity_uom, @default_uom)

IF @price_uom IS NULL
	SET @price_uom = @price_uom

IF @frequency IS NULL 
	SET @frequency = 703 -- default monthly

/* coversion for quanity and price uom start */
IF OBJECT_ID('tempdb..#quantity_conversion') IS NULL
BEGIN 
	CREATE TABLE #quantity_conversion(from_source_uom_id INT, to_source_uom_id INT, conversion_factor NUMERIC(38,18), uom_name_from VARCHAR(1000) COLLATE DATABASE_DEFAULT)
END

--quantity_conversion
INSERT INTO #quantity_conversion(from_source_uom_id, to_source_uom_id, conversion_factor, uom_name_from)
SELECT from_source_uom_id,to_source_uom_id,  MAX(conversion_factor) conversion_factor, uom_name uom_name_from
FROM (SELECT rvuc.from_source_uom_id, rvuc.to_source_uom_id, rvuc.conversion_factor, su.uom_name
	FROM rec_volume_unit_conversion rvuc
	INNER JOIN source_uom su ON rvuc.from_source_uom_id = su.source_uom_id
	WHERE to_source_uom_id = ISNULL(@quantity_uom, @convert_uom)
	UNION 
	SELECT to_source_uom_id from_source_uom_id, from_source_uom_id to_source_uom_id,  1/conversion_factor conversion_factor, su.uom_name
	FROM rec_volume_unit_conversion rvuc
	INNER JOIN source_uom su ON rvuc.to_source_uom_id = su.source_uom_id
	WHERE from_source_uom_id = ISNULL(@quantity_uom, @convert_uom)
) a
GROUP BY from_source_uom_id,to_source_uom_id, uom_name

IF NOT EXISTS(SELECT 1
			FROM tempdb..sysobjects o, tempdb..sysindexes i
			WHERE o.id = i.id
			AND o.name like '#quantity_conversion%' 
			AND i.name like 'IX_QUANTITY_CONVERSION'
			 )
BEGIN 
	CREATE CLUSTERED INDEX IX_QUANTITY_CONVERSION ON #quantity_conversion (from_source_uom_id, to_source_uom_id)
END

--price conversion
SELECT from_source_uom_id,to_source_uom_id,  MAX(1 / conversion_factor) conversion_factor
	INTO #price_conversion
FROM (SELECT from_source_uom_id,to_source_uom_id,  conversion_factor
	FROM rec_volume_unit_conversion
	WHERE to_source_uom_id = @price_uom
	UNION ALL
	SELECT to_source_uom_id from_source_uom_id, from_source_uom_id to_source_uom_id,  1 / conversion_factor conversion_factor
	FROM rec_volume_unit_conversion
	WHERE from_source_uom_id = @price_uom
) a
GROUP BY from_source_uom_id,to_source_uom_id
/* coversion for quanity and price uom end*/
 
--collect PGS ids 
IF OBJECT_ID('tempdb..#commodity_attribute_form_detail') IS NULL
BEGIN
	CREATE TABLE #commodity_attribute_form_detail(
		commodity_attribute_id			INT
		, commodity_name				VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		, commodity_attribute_form_id	INT
		, commodity_form_name			VARCHAR(MAX) COLLATE DATABASE_DEFAULT
		, commodity_attribute_value		VARCHAR(MAX) COLLATE DATABASE_DEFAULT
	)
END

INSERT INTO #commodity_attribute_form_detail(
	commodity_attribute_id			
	, commodity_name				
	, commodity_attribute_form_id	
	, commodity_form_name			
	, commodity_attribute_value		
)
SELECT ca.commodity_attribute_id
		, ca.commodity_name
		, caf.commodity_attribute_form_id
		, caf.commodity_form_name
		, caf.commodity_attribute_value
FROM commodity_attribute ca
INNER JOIN commodity_attribute_form caf ON caf.commodity_attribute_id = ca.commodity_attribute_id
WHERE 1 = CASE WHEN @product_type = 1 THEN 2 ELSE 1 END 

IF NOT EXISTS(SELECT 1
			FROM tempdb..sysobjects o, tempdb..sysindexes i
			WHERE o.id = i.id
			AND o.name like '#commodity_attribute_form_detail%' 
			AND i.name like 'IX_COMMODITY_ATTRIBUTE_FORM_DETAIL'
			 )
BEGIN 
	CREATE CLUSTERED INDEX IX_COMMODITY_ATTRIBUTE_FORM_DETAIL ON #commodity_attribute_form_detail (commodity_attribute_id, commodity_attribute_form_id)
END

/* collect deals for receipt and devlivery grid 
first buy side grid loads and sell side grid loads */		
IF @flag = 's' AND @process_id IS NOT NULL  --collect deals for receipt and delivery grid and populate in process table
BEGIN	
	/* collect deals with contract volume start */
	SET @all_deal_coll = dbo.FNAProcessTableName('all_deals', @user_name, @process_id)

	IF @convert_uom IS NULL OR @convert_uom = ''
		SET @convert_uom = -1

	IF @frequency IS NULL OR @frequency = ''
		SET @frequency = 703
		
 	IF @buy_sell_flag = 'b' OR @call_from = 'p' OR @call_from = 'report'
	BEGIN
	IF OBJECT_ID('tempdb..#udf_values')	IS NULL 
	BEGIN 
			CREATE TABLE #udf_values (source_deal_header_id INT, source_deal_detail_id INT, packaging VARCHAR(MAX) COLLATE DATABASE_DEFAULT
									, packaging_uom VARCHAR(MAX) COLLATE DATABASE_DEFAULT )		
	END
		
	INSERT INTO #udf_values(source_deal_header_id, source_deal_detail_id, packaging, packaging_uom)
	SELECT source_deal_header_id, source_deal_detail_id,  [Package#] packaging, [Packaging UOM] packaging_uom
	FROM (
			SELECT udddf.udf_value, sdh.template_id, sdh.source_deal_header_id, sdd.source_deal_detail_id, udft.Field_label 
			FROM user_defined_deal_detail_fields udddf
			INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN user_defined_deal_fields_template uddft ON udddf.udf_template_id = uddft.udf_template_id 
						AND uddft.template_id = sdh.template_id
			INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
			WHERE  1 = CASE WHEN @product_type = 1 THEN 2 ELSE 1 END 
				AND udft.Field_label IN ('Package#', 'Packaging UOM')
		) up
	PIVOT (MAX(udf_value) FOR Field_label IN ([Package#], [Packaging UOM])) AS pvt
	
	IF NOT EXISTS(SELECT 1
			FROM tempdb..sysobjects o, tempdb..sysindexes i
			WHERE o.id = i.id
			AND o.name like '#udf_values%' 
			AND i.name like 'IX_UDF_VALUES'
			 )
	BEGIN 
		CREATE NONCLUSTERED INDEX IX_UDF_VALUES ON #udf_values (source_deal_detail_id, source_deal_header_id)
	END

	IF OBJECT_ID('tempdb..#all_deals_collection') IS NOT NULL 
		DROP TABLE #all_deals_collection

	IF OBJECT_ID('tempdb..#all_deals_collection') IS NULL
	BEGIN 
		CREATE TABLE #all_deals_collection(source_deal_header_id INT, source_deal_detail_id INT)
	END

	SET @sql = 'INSERT INTO #all_deals_collection
				SELECT sdh.source_deal_header_id, sdd.source_deal_detail_id 
				FROM source_deal_header sdh
				INNER JOIN match_group_deal_status mgds ON mgds.value_id = sdh.deal_status
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
				INNER JOIN maintain_field_template_detail mftd ON mftd.field_template_id = sdht.field_template_id
				INNER JOIN maintain_field_deal mfd ON mfd.field_id = mftd.field_id 
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
				LEFT JOIN source_commodity sc ON sc.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
				LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
				'
				+ CASE WHEN @location IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @location + ''', '','')) location ON location.item = sdd.location_id ' ELSE '' END 
				+ CASE WHEN @loc_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @loc_group + ''', '','')) loc_group ON loc_group.item = sml.region  ' ELSE '' END 
				+ CASE WHEN @commodity IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity + ''', '','')) commodity ON commodity.item = ISNULL(sdd.detail_commodity_id, sdh.commodity_id) '  ELSE '' END 
				+ CASE WHEN @deal_type IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @deal_type + ''', '','')) deal_type ON deal_type.item = sdh.source_deal_type_id '  ELSE '' END 
				+ CASE WHEN @commodity_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_group + ''', '','')) commodity_group ON commodity_group.item = sc.commodity_group1 '  ELSE '' END 
				--+ CASE WHEN @commodity_id IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + CAST(@commodity_id AS VARCHAR(1000)) + ''', '','')) commodity ON commodity.item = ISNULL(sdd.detail_commodity_id, sdd.commodity_id) '  ELSE '' END 
				+ CASE WHEN @commodity_origin_id IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_origin_id + ''', '','')) commodity_origin_id ON commodity_origin_id.item = sdd.origin ' ELSE '' END 
				+ CASE WHEN @commodity_form_id IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_id + ''', '','')) commodity_form_id ON commodity_form_id.item = sdd.form ' ELSE '' END 
				+ CASE WHEN @commodity_form_attribute1 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute1 + ''', '','')) commodity_form_attribute1 ON commodity_form_attribute1.item = sdd.attribute1 ' ELSE '' END 
				+ CASE WHEN @commodity_form_attribute2 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute2 + ''', '','')) commodity_form_attribute2 ON commodity_form_attribute2.item = sdd.attribute2 ' ELSE '' END 
				+ CASE WHEN @commodity_form_attribute3 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute3 + ''', '','')) commodity_form_attribute3 ON commodity_form_attribute3.item = sdd.attribute3 ' ELSE '' END 
				+ CASE WHEN @commodity_form_attribute4 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute4 + ''', '','')) commodity_form_attribute4 ON commodity_form_attribute4.item = sdd.attribute4 ' ELSE '' END 
				+ CASE WHEN @commodity_form_attribute5 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute5 + ''', '','')) commodity_form_attribute5 ON commodity_form_attribute5.item = sdd.attribute5 ' ELSE '' END 
				+ CASE WHEN @organic IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @organic + ''', '','')) organic ON ' + CASE WHEN @organic = 'b' THEN 'ISNULL(sdd.organic, '''')' ELSE 'organic.item' END + ' =  ISNULL(sdd.organic, '''') ' ELSE '' END 							
				+ CASE WHEN @incoterm IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @incoterm + ''', '','')) incoterm ON incoterm.item = sdd.detail_inco_terms ' ELSE '' END 							
				+ CASE WHEN @crop_year IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @crop_year + ''', '','')) crop_year ON crop_year.item = sdd.crop_year ' ELSE '' END 							
				+ CASE WHEN @sub_deal_type IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @sub_deal_type + ''', '','')) sub_deal_type ON sub_deal_type.item = sdh.deal_sub_type_type_id ' ELSE '' END 							
				--+ CASE WHEN @lot IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @lot + ''', '','')) lot ON lot.item = adc.lot ' ELSE '' END 							
				+ '
				WHERE farrms_field_id = ''contractual_volume''
					AND COALESCE(sdd.physical_financial_flag, sdh.physical_financial_flag, ''p'') = ''p'' --physical deal only
					--AND account_status <> 10085 -- remove ''No Trade'' deals
					AND sdh.deal_id NOT LIKE ''%Beginning Balance%''
					AND sdt.deal_type_id <> ''Transportation'''

	IF @call_from <> 'p'
	BEGIN 
		SET @sql = @sql + ' AND (''' + CAST(@period_from AS VARCHAR(12)) + ''' <= sdd.term_end AND  ''' + CAST(@period_to AS VARCHAR(12)) + ''' >= sdd.term_start) '
	END

		 
	SET @sql = @sql + ' GROUP BY sdh.source_deal_header_id, sdd.source_deal_detail_id'

	EXEC spa_print @sql
	EXEC(@sql) 

	CREATE NONCLUSTERED INDEX IX_all_deals_collection ON #all_deals_collection (source_deal_header_id, source_deal_detail_id)
	 	 
	/* collect deals with contract volume end */	
	SET @sql = ' IF OBJECT_ID(''' + @all_deal_coll + ''', ''U'') IS NOT NULL
					DROP TABLE ' + @all_deal_coll 

	EXEC spa_print @sql
	EXEC(@sql)
	
	SET @sql = 'SELECT 
						CAST(sdh.source_deal_header_id AS VARCHAR(1000)) + '' ['' + sdh.deal_id + '']'' deal_id
						, sdd.source_deal_detail_id
						, sdd.buy_sell_flag
						, sdt.source_deal_type_id
						, sdt.source_deal_type_name deal_type
						, sc.source_counterparty_id
						, sc.counterparty_name 
						, sml.source_minor_location_id
						--, CASE WHEN sml.Location_Name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smj.location_name IS NULL THEN '''' ELSE  '' ['' + smj.location_name + '']'' END location
						, sml.source_minor_location_id location
						, smj.source_major_location_ID
						, commodity.source_commodity_id
						, commodity.commodity_name
						, ISNULL(sdd.product_description, commodity.commodity_name) product_description
						, ROUND(sdd.total_volume * ISNULL(qc.conversion_factor, 1) /  CASE WHEN ' + @frequency + ' = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,''l'')) END, 2) [contractual_volume]
						, ROUND(ISNULL(sddv.quantity, sdd.total_volume) * ISNULL(qc.conversion_factor, 1) /  CASE WHEN ' + @frequency + ' = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,''l'')) END, 2) [Rec Quantity]
						, ROUND(ISNULL(sddv.quantity, sdd.total_volume) * ISNULL(qc.conversion_factor, 1) /  CASE WHEN ' + @frequency + ' = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,''l'')) END, 2) [Del Quantity]
						, ROUND(ROUND(ISNULL(sddv.quantity, sdd.total_volume) * ISNULL(qc.conversion_factor, 1) /  CASE WHEN ' + @frequency + ' = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,''l'')) END, 2) - ISNULL(mgd.bookout_split_volume, 0) * ISNULL(qc.conversion_factor, 1) , 2) [Bal Quantity]
						, ROUND(mgd.quantity, 4) actual_volume
						, ROUND(sdd.fixed_price * ISNULL(pc.conversion_factor, 1), 4) fixed_price
						, sdd.term_start
						, sdd.term_end
						, sdd.price_uom_id
						, COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id) converted_uom_id
						, spcd.display_uom_id
						, spcd.uom_id
						, sdd.deal_volume_uom_id
						, commodity.commodity_group1
						, sddv.quantity splited_qty
						, ISNULL(sddv.split_deal_detail_volume_id, -1) split_deal_detail_volume_id
						, su.uom_name
						, CASE WHEN finalized = ''1'' or finalized = ''y'' THEN ''y'' ELSE ''n'' END finalized
						, bookout_split_volume
						, ISNULL(mgd.is_complete, ''n'') is_complete
						, ISNULL(sml.region, sml.source_minor_location_id) region
						, CASE WHEN sddv.is_parent = ''n'' THEN ''Child'' ELSE ''Parent'' END is_parent
						, sml.source_minor_location_id source_minor_location_id_split
						--, CASE WHEN sml.Location_Name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smj.location_name IS NULL THEN '''' ELSE  '' ['' + smj.location_name + '']'' END location_split
						, sml.source_minor_location_id location_split
						, mgh.match_group_id
						, mgh.match_group_header_id
						, sdh.contract_id
						, sdt1.source_deal_type_id sub_source_deal_type_id
						, sdt1.source_deal_type_name sub_deal_type_id
						, DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,''l'')) no_of_days
						, sdh.source_deal_header_id
						--, commodity_origin_id.code commodity_origin_id
						--, commodity_form_id.commodity_form_description commodity_form_id
						--, ISNULL(cafd1.commodity_name, '''') + '' '' + ISNULL(sdv1.code, '''') commodity_form_attribute1
						--, ISNULL(cafd2.commodity_name, '''') + '' '' + ISNULL(sdv2.code, '''') commodity_form_attribute2
						--, ISNULL(cafd3.commodity_name, '''') + '' '' + ISNULL(sdv3.code, '''') commodity_form_attribute3
						--, ISNULL(cafd4.commodity_name, '''') + '' '' + ISNULL(sdv4.code, '''') commodity_form_attribute4
						--, ISNULL(cafd5.commodity_name, '''') + '' '' + ISNULL(sdv5.code, '''') commodity_form_attribute5
						--, ISNULL(mgh.commodity_origin_id, sdd.origin) saved_origin
						--, ISNULL(mgh.commodity_form_id, sdd.form) saved_form
						--, ISNULL(mgh.commodity_form_attribute1, sdd.attribute1) saved_commodity_form_attribute1
						--, ISNULL(mgh.commodity_form_attribute2, sdd.attribute2) saved_commodity_form_attribute2
						--, ISNULL(mgh.commodity_form_attribute3, sdd.attribute3) saved_commodity_form_attribute3
						--, ISNULL(mgh.commodity_form_attribute4, sdd.attribute4) saved_commodity_form_attribute4
						--, ISNULL(mgh.commodity_form_attribute5, sdd.attribute5) saved_commodity_form_attribute5	
						, ISNULL(sddv.est_movement_date, mgh.estimated_movement_date) est_movement_date
						, ISNULL(sddv.est_movement_date_to, mgh.est_movement_date_to) est_movement_date_to 					
						--, CASE WHEN sdd.organic = '''' THEN ''n'' ELSE COALESCE(mgh.organic, sdd.organic, ''n'') END organic	
						, org_uom.uom_name org_uom
						, price_uom.uom_name price_uom
						, org_price_uom.uom_name org_price_uom						
						, detail_inco_terms.code incoterm
						, crop_year.code crop_year
						, detail_inco_terms.value_id inco_terms_id
						, crop_year.value_id crop_year_id
						, sdd.lot lot
						, ISNULL(mgd.batch_id, sdd.batch_id) batch_id
						, mgh.container_number
						, sdh.deal_sub_type_type_id		
						, packaging_uom.uom_desc packaging_uom
						 
						--, CASE WHEN uv.packaging_uom IS NOT NULL THEN 
						--	ROUND((ISNULL(sddv.quantity, sdd.total_volume) /  CASE WHEN ' + @frequency + ' = 703 THEN 1 
						--	ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,''l'')) END - ISNULL(mgd.bookout_split_volume, 0)) 
						--	*  ISNULL(qc.conversion_factor, 1) * (ISNULL(qty_con.conversion_factor, 1)), 0) ELSE NULL END 	
						--, ROUND( ISNULL(sddv.quantity, sdd.total_volume  /  CASE WHEN ' + @frequency + ' = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,''l'')) END, 2) - ISNULL(mgd.bookout_split_volume, 0) * ISNULL(qc.conversion_factor, 1) , 2) * (ISNULL(1/NULLIF(qty_con.conversion_factor, 0), 1)) packaging		
						, ISNULL(rvuc.conversion_factor, 1)  * (ISNULL(sddv.quantity, sdd.total_volume) - ISNULL(mgd.bookout_split_volume, 0)) packaging
						, rvuc.conversion_factor  qq
						, org_uom.source_uom_id org_uom_id
						, deal_sub_type_type_id.deal_type_id sub_type_name
						, sdh.scheduler
						, sdh.description1
						, COALESCE(sddv.comments, sdd.deal_detail_description, sdh.description4) comments										
						, sddv.scheduled_from
						, sddv.scheduled_to
						, sdd.fixed_price_currency_id
						, currency.currency_id
						, buyer_seller_option.code buyer_seller_option
						, sdh.deal_status

						-- added fields
						--detail 
						, NULL estimated_no_of_packages
						, NULL packaging_type
						, NULL deal_counterparty_reference_id   
						, NULL purchase_deal_reference_id 
						, NULL purchase_counterparty_reference_id
						, NULL purchase_counterparty
						, NULL product
						, uv.packaging_uom packaging_uom_id
						, CASE WHEN sdd.buy_sell_flag = ''b'' THEN sdg.quantity ELSE NULL END no_of_loads
						, CASE WHEN sdd.buy_sell_flag = ''b'' THEN sdv_load_type.value_id ELSE NULL END load_type
						, sml.pipeline			
					INTO ' + @all_deal_coll + '
				FROM  source_deal_detail sdd 
				INNER JOIN #all_deals_collection adc ON adc.source_deal_header_id = sdd.source_deal_header_id
					AND adc.source_deal_detail_id = sdd.source_deal_detail_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
				LEFT JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.source_deal_group_id = sdg.source_deal_groups_id
				LEFT JOIN static_data_value sdv_load_type ON sdv_load_type.code = sdg.static_group_name
				LEFT JOIN #udf_values uv ON uv.source_deal_detail_id = CASE WHEN ' + CAST(@product_type AS VARCHAR(100)) + ' = 1 THEN 2 ELSE sdd.source_deal_detail_id END
				LEFT JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = sdd.source_deal_detail_id
				LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
				LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
				LEFT JOIN source_commodity commodity ON commodity.source_commodity_id = CASE WHEN sdd.detail_commodity_id = 0 THEN sdh.commodity_id ELSE ISNULL(sdd.detail_commodity_id,sdh.commodity_id) END
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
				LEFT JOIN match_group_detail mgd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
					AND sddv.split_deal_detail_volume_id = mgd.split_deal_detail_volume_id 
				LEFT JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id

				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = COALESCE(mgh.location, sddv.changed_location, sdd.location_id)
				LEFT JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID

				LEFT JOIN source_deal_type sdt1 ON sdt1.source_deal_type_id = sdh.deal_sub_type_type_id
				LEFT JOIN source_uom su ON su.source_uom_id = CASE WHEN ' + CAST(ISNULL(@quantity_uom, -1)  AS VARCHAR(100)) + '= -1 THEN  COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id) ELSE '  + CAST(ISNULL(@quantity_uom, -1) AS VARCHAR(100)) + ' END
				LEFT JOIN source_uom org_uom ON org_uom.source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)  
				LEFT JOIN source_uom price_uom ON price_uom.source_uom_id = CASE WHEN ' + CAST(ISNULL(@price_uom, -1)  AS VARCHAR(100)) + '= -1 THEN  sdd.price_uom_id ELSE '  + CAST(ISNULL(@price_uom, -1) AS VARCHAR(100)) + ' END
				LEFT JOIN source_uom org_price_uom ON org_price_uom.source_uom_id = sdd.price_uom_id 
				
				/*
				LEFT JOIN commodity_origin co ON co.commodity_origin_id = ISNULL(mgh.commodity_origin_id, sdd.origin)
 				LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
					AND commodity_origin_id.type_id = 14000
				
				LEFT JOIN commodity_form cf ON cf.commodity_form_id = ISNULL(mgh.commodity_form_id, sdd.form)
				LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
				
				LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = ISNULL(mgh.commodity_form_attribute1, sdd.attribute1)
				LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
					AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value
				
				LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = ISNULL(mgh.commodity_form_attribute2, sdd.attribute2)
				LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
					AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
				LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

				LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = ISNULL(mgh.commodity_form_attribute3, sdd.attribute3)
				LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
					AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
				LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

				LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = ISNULL(mgh.commodity_form_attribute4, sdd.attribute4)
				LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
					AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
				LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

				LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = ISNULL(mgh.commodity_form_attribute5, sdd.attribute5)
				LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
					AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
				LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value
				*/

				LEFT JOIN static_data_value detail_inco_terms ON detail_inco_terms.value_id = sdd.detail_inco_terms
					AND detail_inco_terms.type_id = 40200
				LEFT JOIN static_data_value crop_year ON crop_year.value_id = sdd.crop_year
					AND crop_year.type_id = 10092

				LEFT JOIN rec_volume_unit_conversion rvuc ON rvuc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id) 
					AND to_source_uom_id = uv.packaging_uom	 		 
 
				LEFT JOIN source_uom packaging_uom ON packaging_uom.source_uom_id = uv.packaging_uom

				LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)
				LEFT JOIN #price_conversion pc ON pc.from_source_uom_id = sdd.price_uom_id
				LEFT JOIN source_deal_type deal_sub_type_type_id ON deal_sub_type_type_id.source_deal_type_id = sdh.deal_sub_type_type_id
			
				LEFT JOIN #quantity_conversion qty_con ON qty_con.from_source_uom_id = uv.packaging_uom
				LEFT JOIN source_currency currency ON currency.source_currency_id = sdd.fixed_price_currency_id

				LEFT JOIN static_data_value buyer_seller_option ON buyer_seller_option.value_id = sdd.buyer_seller_option

				LEFT JOIN ticket_match tm ON tm.match_group_header_id = mgh.match_group_header_id
				LEFT JOIN ticket_detail td ON td.ticket_detail_id = tm.ticket_detail_id
				LEFT JOIN rec_volume_unit_conversion qc_actual ON qc_actual.from_source_uom_id = td.quantity_uom
					AND qc_actual.to_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)
				WHERE 1 = 1 '
					+ CASE WHEN @show_zero_volume = 0 THEN 
						'AND ROUND(ROUND(ISNULL(sddv.quantity, sdd.total_volume) * ISNULL(qc.conversion_factor, 1) /  CASE WHEN ' + @frequency + ' = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,''l'')) END, 2) - ISNULL(mgd.bookout_split_volume, 0) * ISNULL(qc.conversion_factor, 1) , 2) > 0' ELSE ' AND ISNULL(sddv.quantity, sdd.total_volume) = 0 ' 
					END + '  
					AND sdh.deal_id NOT LIKE ''%Beginning Balance%'' 	
					AND ISNULL(sddv.ignored_amount, ''n'') = ''n''
				'

		IF @call_from = 'p' AND @commodity_id IS NOT NULL -- for recall grid commodity filter
		BEGIN 
			SET @sql = @sql + ' AND commodity.source_commodity_id IN ( ' + @commodity_id + ')'		
		END 
				
		EXEC spa_print @sql
		EXEC(@sql)  
	END
 
	IF @call_from NOT IN ('view_match_deal', 'operation')
	BEGIN	
		SET @sql = 'SELECT ''<a href= "javascript:void(0);" onclick="parent.TRMHyperlink(10131010, '' + CAST(adc.source_deal_header_id AS VARCHAR(1000)) + '',''''n'''')">'' + deal_id +  ''</a>''
						, adc.description1
						, adc.deal_type 
						, sub_type_name	
						, adc.counterparty_name 
						, adc.product_description
						--, crop_year
						, incoterm
						, buyer_seller_option
						, adc.source_minor_location_id location
						, dbo.FNADateFormat(adc.term_start) term_start					
						, dbo.FNADateFormat(adc.term_end) term_end
						, dbo.FNARemoveTrailingZeroes(contractual_volume) contractual_volume ' 
						+ CASE WHEN @buy_sell_flag = 'b' 
							THEN ' , dbo.FNARemoveTrailingZeroes([Rec Quantity]) [rec_quantity]' 
							ELSE ' , dbo.FNARemoveTrailingZeroes([Del Quantity]) del_quantity' 
						END + '
						, dbo.FNARemoveTrailingZeroes(adc.[Bal Quantity]) [bal_quantity]
						, dbo.FNARemoveTrailingZeroes(actual_volume) actual_volume
						
						, su.uom_name uom
						, org_uom									
						, packaging_uom 
						--, CEILING(packaging) packaging
						, dbo.FNARemoveTrailingZeroes(adc.fixed_price) fixed_price
						, currency_id
						, price_uom
						, org_price_uom
						, comments
						, adc.is_parent
						, est_movement_date
						, est_movement_date_to
						, adc.commodity_name 
						, lot
						, CASE WHEN batch_id = ''-1'' THEN '''' ELSE batch_id END batch_id
						, container_number
						, finalized split_finilized_status
						, CASE WHEN is_complete = ''n'' THEN ''No'' ELSE ''Yes'' END match_status						
						, adc.source_deal_detail_id 
						, adc.buy_sell_flag
						, split_deal_detail_volume_id
						, CAST(adc.source_deal_detail_id AS VARCHAR(100)) + ''_'' + CAST(ISNULL(split_deal_detail_volume_id, -1) AS VARCHAR(100)) deal_detail_id_split_deal_detail_volume_id
					    , scheduled_from
						, scheduled_to
						, adc.pipeline pipeline_id						
				FROM ' + @all_deal_coll + ' adc 				
				LEFT JOIN source_uom su ON su.source_uom_id = CASE WHEN ' + CAST(@convert_uom  AS VARCHAR(100)) + '= -1 THEN adc.uom_id ELSE '  + CAST(@convert_uom AS VARCHAR(100)) + ' END
				' 
				+ CASE WHEN @lot IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @lot + ''', '','')) lot ON lot.item = adc.lot ' ELSE '' END 							
				+ ' WHERE 1 = 1 '
				+ ' AND ISNULL(adc.split_deal_detail_volume_id, -1) NOT IN (SELECT split_deal_detail_volume_id FROM match_group_detail) '					 
				+ CASE WHEN @buy_sell_flag IS NOT NULL THEN  ' AND adc.buy_sell_flag = ''' + @buy_sell_flag + '''' ELSE '' END  
				+ ' AND adc.finalized = ''' + ISNULL(@split_status, 'n') + ''''
				
		SET @sql = @sql + ' ORDER BY deal_id ' 
		 
	--select  @sql
	EXEC spa_print @sql
	EXEC(@sql) 

	END
	/*
	@call_from = 'view_match_deal' value is passed from view shipment grid hyperlink to view match deal.
	After collecting 
	*/
	IF @call_from = 'view_match_deal' 
	BEGIN	
		SELECT @match_group_id = match_group_id
		FROM match_group_shipment WHERE match_group_shipment_id = @match_group_shipment_id
	
		EXEC spa_scheduling_workbench @flag = 'v', @process_id = @process_id, @buy_deals = '', @sell_deals = ''
			, @convert_uom = @convert_uom, @convert_frequency=703, @mode = 'u', @get_group_id = 1, @bookout_match = 'm'
			, @match_group_id = @match_group_id, @call_from = @call_from, @match_group_shipment_id = @match_group_shipment_id

		RETURN
	END
END
IF @flag = 'b' --insert bookout 
BEGIN
	CREATE TABLE #bookout_xml_data (row_id INT IDENTITY(1, 1), bookoutid VARCHAR(1000) COLLATE DATABASE_DEFAULT, bookout_date DATETIME, quantity NUMERIC(38,10)
									, lineup VARCHAR(1000) COLLATE DATABASE_DEFAULT
									, source_deal_detail_id_from VARCHAR(1000) COLLATE DATABASE_DEFAULT, source_deal_detail_id_to VARCHAR(1000) COLLATE DATABASE_DEFAULT, convert_uom INT, convert_frequency INT)
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value

	INSERT INTO #bookout_xml_data(bookoutid, bookout_date, quantity, lineup, source_deal_detail_id_from, source_deal_detail_id_to, convert_uom, convert_frequency)
	SELECT bookoutid, bookout_date, quantity, lineup, SUBSTRING(@buy_deals, 1, CHARINDEX('_', @buy_deals) - 1), SUBSTRING(@sell_deals, 1, CHARINDEX('_', @sell_deals) - 1), @convert_uom, @convert_frequency
	FROM   OPENXML (@idoc, '/Root/FormXML', 2)
			WITH ( 
				bookoutid VARCHAR(1000) '@BookOutID',						
				bookout_date DATETIME '@bookout_date',
				lineup VARCHAR(1000) '@lineup',
				quantity NUMERIC(38,10)	'@quantity')


	EXEC sp_xml_removedocument @idoc

	DECLARE @quantity_bookout NUMERIC(38, 18)
	SELECT @quantity_bookout = quantity FROM #bookout_xml_data

	EXEC spa_scheduling_workbench_wrapper
		@flag = 's',
		@source_deal_header_id_purchase = @buy_deals,
		@source_deal_header_id_sell = @sell_deals,
		@quantity = @quantity_bookout,
		@balance_qty =  @quantity_bookout,
		@converted_uom = @convert_uom,
		@is_back_to_back  ='n',
		@call_from = 'b',
		@process_id = @process_id

 
	/*
	INSERT INTO #quantity_conversion
	SELECT from_source_uom_id,to_source_uom_id, MAX(conversion_factor) conversion_factor, '' 
	FROM (
		SELECT from_source_uom_id,to_source_uom_id, CAST(conversion_factor AS NUMERIC(38,18)) conversion_factor
		FROM rec_volume_unit_conversion
		WHERE from_source_uom_id = @convert_uom
		UNION ALL
		SELECT to_source_uom_id from_source_uom_id, from_source_uom_id to_source_uom_id,  CAST(1 AS NUMERIC(38,20))/CAST(conversion_factor AS FLOAT) conversion_factor
		FROM rec_volume_unit_conversion
		WHERE to_source_uom_id = @convert_uom
	) a

	GROUP BY from_source_uom_id,to_source_uom_id

	SET @all_deal_coll = dbo.FNAProcessTableName('all_deals', @user_name, @process_id)

	SELECT SUBSTRING(combined_id, 1, CHARINDEX('_', combined_id) - 1) AS source_deal_detail_id,
		SUBSTRING(combined_id, CHARINDEX('_', combined_id) + 1, LEN(combined_id)) AS split_deal_detail_volume_id,
		buy_sell_flag
		INTO #source_deal_detail_id_pre_1
	FROM (SELECT item combined_id, 'b' buy_sell_flag FROM dbo.FNASplit(@buy_deals, ',') 
		UNION ALL
		SELECT item, 's' FROM dbo.FNASplit(@sell_deals, ',')) a
	
	SELECT @lot =  source_deal_detail_id FROM #source_deal_detail_id_pre_1 WHERE buy_sell_flag = 'b'
	 
			
	CREATE TABLE #source_deal_detail_id_1(source_deal_detail_id INT, split_deal_detail_volume_id INT, quantity FLOAT, bookout_qty FLOAT, bookout_date DATETIME)

	INSERT INTO #source_deal_detail_id_1(source_deal_detail_id, split_deal_detail_volume_id, quantity)
	SELECT s.source_deal_detail_id, sddv.split_deal_detail_volume_id
		, ISNULL(sddv.quantity, sdd.total_volume) --* ISNULL(qc.conversion_factor, 1) * CASE WHEN @frequency = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start, 'l')) END 
		quantity 
	FROM #source_deal_detail_id_pre_1 s
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = s.source_deal_detail_id
	LEFT JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = s.split_deal_detail_volume_id 



	DECLARE @missing_counterparty VARCHAR(MAX) = NULL
	DECLARE @missing_counterparty_msg VARCHAR(MAX) = ' counterparty not found in the system'
	DECLARE @line_up VARCHAR(5000)

	SELECT @line_up = lineup FROM #bookout_xml_data
	SET @missing_counterparty = STUFF((
											SELECT ',' + lineup.item
											FROM dbo.FNASplit(@line_up, '-') lineup
											LEFT JOIN source_counterparty sc ON sc.counterparty_id = lineup.item
											WHERE sc.counterparty_id IS NULL
											FOR XML PATH('')
										), 1, 1, '')
		 	
	IF @missing_counterparty IS NOT NULL
	BEGIN 
		SET @missing_counterparty_msg = @missing_counterparty + @missing_counterparty_msg
		EXEC spa_ErrorHandler -1,
				'LineUp Check',
				'spa_scheduling_workbench',
				'DB Error',
				@missing_counterparty_msg,
				''
		RETURN
	END

	IF EXISTS (SELECT 1 FROM deal_volume_split dvs 
				INNER JOIN #bookout_xml_data bxd ON bxd.bookoutid = dvs.bookout_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
				'LineUp Check',
				'spa_scheduling_workbench',
				'DB Error',
				'BookoutID already exists.',
				''
		RETURN
	END
			
	SET @lineup_vol_id_tbl = dbo.FNAProcessTableName('lineup_vol_id_tbl', @user_name, @process_id)

	BEGIN TRY
		BEGIN TRAN

		SET @sql = 'INSERT INTO match_group(group_name)
					SELECT DISTINCT group_name FROM ' + @lineup_vol_id_tbl
		
		EXEC spa_print @sql
		EXEC(@sql)
		--EXEC('select * from ' + @lineup_vol_id_tbl)
		--#bookout_xml_data
	 
		SET @match_group_id  = IDENT_CURRENT('match_group')
		
		SET @sql = 'INSERT INTO  match_group_shipment (match_group_id
											, match_group_shipment
											, is_transport_deal_created)
					SELECT DISTINCT ' + CAST(@match_group_id AS VARCHAR(1000)) + ', transportation_grp, 1 FROM ' + @lineup_vol_id_tbl
					
		EXEC spa_print @sql
		EXEC(@sql)	

		SET @match_group_shipment_id  = IDENT_CURRENT('match_group_shipment')

		SELECT a.source_deal_detail_id, a.quantity total_qty, ISNULL(rec.quantity, del.quantity) bookout_qty, 'y' finalized
			, ISNULL(rec.bookoutid, del.bookoutid) bookoutid, split_deal_detail_volume_id
			, ISNULL(rec.bookout_date, del.bookout_date) bookout_date
			, @match_group_id match_group_id
			, @match_group_shipment_id match_group_shipment_id
			INTO #final_source_deal_detail_id
		FROM #source_deal_detail_id_1 a
		LEFT JOIN #bookout_xml_data rec  ON a.source_deal_detail_id = rec.source_deal_detail_id_from
		LEFT JOIN #bookout_xml_data del ON a.source_deal_detail_id = del.source_deal_detail_id_to

		--SELECT s.source_deal_detail_id, s.total_qty
		--		, s.bookout_qty
		--		, s.finalized
		--		, s.total_qty - (ISNULL(qc.conversion_factor, 1)  * s.bookout_qty) total_qty_after_bookout_conversion
		--		, CASE WHEN @frequency = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start,'l')) END frequency_calc
		--		, ISNULL(qc.conversion_factor, 1) * s.bookout_qty converted_qty
		--		, qc.conversion_factor 
		--		, s.bookoutid
		--		, s.split_deal_detail_volume_id
		--		, s.bookout_date
		--		, s.match_group_id
		--		, s.match_group_shipment_id
		--		, sdd.location_id
		--		, sdd.detail_commodity_id
		--		, sdd.origin
		--		, sdd.form
		--		, sdd.attribute1
		--		, sdd.attribute2
		--		, sdd.attribute3
		--		, sdd.attribute4
		--		, sdd.attribute5
		--		, sdd.organic
		--		, sdd.term_start
		--		, sdd.term_end
		--		, sdd.detail_inco_terms incoterm
		--		, sdd.crop_year
		--	INTO #final_source_deal_detail_id_conversion
		--FROM #final_source_deal_detail_id s
		--INNER JOIN source_deal_detail sdd On sdd.source_deal_detail_id = s.source_deal_detail_id
		--LEFT JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = s.split_deal_detail_volume_id 
		--LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 
		--LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = @convert_uom
		--	AND  qc.to_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)		

		--INSERT INTO match_group_header(
		--								match_group_id	
		--								, match_group_shipment_id	
		--								, match_book_auto_id	
		--								, bookout_match_total_amount	
		--								, match_bookout
		--								, source_minor_location_id
		--								, last_edited_by
		--								, last_edited_on
		--								, status
		--								, scheduled_from
		--								, scheduled_to
		--								, match_number
		--								, line_up
		--								, commodity_origin_id
		--								, commodity_form_id
		--								, organic
		--								, commodity_form_attribute1
		--								, commodity_form_attribute2
		--								, commodity_form_attribute3
		--								, commodity_form_attribute4
		--								, commodity_form_attribute5										
		--						)
 
		--SELECT TOP 1 match_group_id, match_group_shipment_id, fsddic.bookoutid, bookout_qty, 'b', location_id, dbo.FNAdbUser(), GETDATE(), 'c', term_start, term_end, NULL, bxd.lineup,
		--		origin, form, organic,	attribute1, attribute2,	attribute3,	attribute4,	attribute5 
		--FROM #final_source_deal_detail_id_conversion fsddic
		--CROSS APPLY #bookout_xml_data  bxd
		
		--SET @match_group_header_id = IDENT_CURRENT('match_group_header')

		--SET @sql = '
		--			INSERT INTO split_deal_detail_volume (source_deal_detail_id
		--						, quantity
		--						, finalized
		--						, bookout_id
		--						, is_parent)
		--			SELECT a.source_deal_detail_id, converted_qty quantity, ''n'' finalized, bookoutid, ''n'' is_parent
		--			FROM #final_source_deal_detail_id_conversion a
		--			WHERE split_deal_detail_volume_id IS NULL 
		--			UNION ALL 
		--			SELECT a.source_deal_detail_id, total_qty_after_bookout_conversion, ''n'', bookoutid, ''y''
		--			FROM #final_source_deal_detail_id_conversion a
		--			WHERE split_deal_detail_volume_id IS NULL'
		
		--EXEC spa_print @sql
		--EXEC(@sql)
		
		----select * 
		--UPDATE a
		--SET a.split_deal_detail_volume_id = sddv.split_deal_detail_volume_id
		--FROM #final_source_deal_detail_id_conversion a
		--LEFT JOIN split_deal_detail_volume sddv ON sddv.bookout_id = a.bookoutid
		--	AND sddv.quantity = a.converted_qty
		--	AND sddv.source_deal_detail_id = a.source_deal_detail_id
		--WHERE a.split_deal_detail_volume_id IS NULL 

		--INSERT INTO match_group_detail(
		--								source_commodity_id
		--								, scheduling_period
		--								, source_deal_detail_id
		--								, is_complete
		--								, bookout_split_volume
		--								, quantity
		--								, split_deal_detail_volume_id
										
		--								, match_group_header_id
		--								, match_group_shipment_id
		--								, lot
		--								, incoterm
		--								, crop_year
		--								)
		--SELECT detail_commodity_id,  CAST(DATEPART(yy,term_start) AS VARCHAR(100)) + ' - ' + CAST(DATENAME(MM, term_start) AS VARCHAR(3))  scheduling_period
		--	, source_deal_detail_id, 'y', converted_qty, converted_qty, split_deal_detail_volume_id,  @match_group_header_id, match_group_shipment_id 
		--	, @lot, incoterm, crop_year
		--FROM #final_source_deal_detail_id_conversion
					
		--ROLLBACK TRAN 
		--RETURN 


		COMMIT TRAN	
		
		EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Success',
			'Changes has been saved successfully.',
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler @@ERROR,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Fail to Bookout deals.',
				''
	END CATCH
	*/
END
IF @flag = 'v' -- get max volume, and pre-generate lineup, shipment ids
BEGIN
	DECLARE @match_year_month VARCHAR(100)
	SELECT @match_year_month = CAST(YEAR(GETDATE()) AS VARCHAR(10)) + ' - ' + CAST(MONTH(GETDATE()) AS VARCHAR(10)) 
	
	IF @bookout_match IS NULL 
		SET @bookout_match = 'b'
	
	SELECT combined_id
		INTO #combined_deal_split_ids
	FROM (
		SELECT item combined_id FROM dbo.FNASplit(@buy_deals, ',') 
		UNION ALL
		SELECT item FROM dbo.FNASplit(@sell_deals, ',')
	) a
	
	CREATE TABLE #source_deal_detail_id_pre(source_deal_detail_id INT, split_deal_detail_volume_id INT)

	IF @match_group_id IS NULL
	BEGIN 
		INSERT INTO #source_deal_detail_id_pre
		SELECT SUBSTRING(combined_id, 1, CHARINDEX('_', combined_id) - 1) AS source_deal_detail_id,
				SUBSTRING(combined_id, CHARINDEX('_', combined_id) + 1, LEN(combined_id)) AS split_deal_detail_volume_id
		FROM #combined_deal_split_ids
	END
	ELSE
	BEGIN
		INSERT INTO #source_deal_detail_id_pre
		SELECT source_deal_detail_id, split_deal_detail_volume_id 
		FROM match_group_detail mgd
		INNER JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id
		INNER JOIN match_group_shipment ms ON mgh.match_group_shipment_id = ms.match_group_shipment_id
		INNER JOIN match_group mg ON mg.match_group_id = ms.match_group_id
		WHERE mg.match_group_id = @match_group_id
	END 
 
	SELECT DISTINCT  
		 s.source_deal_detail_id, ISNULL(sddv.split_deal_detail_volume_id, s.split_deal_detail_volume_id) split_deal_detail_volume_id
		, ISNULL(sddv.quantity, sdd.total_volume) * ISNULL(qc.conversion_factor, 1) / CASE WHEN @convert_frequency = 703 THEN 1 ELSE DATEPART(dd, dbo.[FNAGetFirstLastDayOfMonth] (sdd.term_start, 'l')) END quantity
		, ISNULL(sddv.quantity, sdd.total_volume) * ISNULL(qc.conversion_factor, 1)  quantity_total
		, sddv.changed_location  
		, sdd.product_description
		--, sdd.attribute5
		--, sdd.attribute4
		--, sdd.attribute3
		--, sdd.attribute2
		--, sdd.attribute1
		--, CASE WHEN sdd.organic = '' OR sdd.organic IS NULL THEN 'n' ELSE sdd.organic END  organic
		--, sdd.form
		--, sdd.origin
		, sdg.source_deal_groups_id
		, sdg.source_deal_groups_name
		, sdg.static_group_name
		, sdd.buy_sell_flag
		, sdd.lot
		, sdd.batch_id
		, qc.conversion_factor
		, CASE WHEN @product_type = 1 THEN NULL ELSE udddf.udf_value END packing_uom 
		INTO #source_deal_detail_id
	FROM #source_deal_detail_id_pre s
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = s.source_deal_detail_id
	LEFT JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = s.split_deal_detail_volume_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 
	LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)
	LEFT JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = sdd.source_deal_group_id
	LEFT JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
	LEFT JOIN user_defined_deal_fields_template uddft ON udddf.udf_template_id = uddft.udf_template_id 
	LEFT JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
	WHERE  1 = 1
		AND ISNULL(udft.Field_label, 1) = CASE WHEN @product_type = 1 THEN ISNULL(udft.Field_label, 1) ELSE 'Packaging UOM' END 

	IF @is_back_to_back = 'y' --back to back deals
	BEGIN 
		--select a.source_deal_groups_id, b.source_deal_groups_id  source_deal_groups_idb, a.source_deal_detail_id
		UPDATE a
		SET a.source_deal_groups_id = b.source_deal_groups_id
		FROM #source_deal_detail_id a
		LEFT JOIN #source_deal_detail_id b ON  1 = 1
			AND a.buy_sell_flag <> b.buy_sell_flag
			--AND ISNULL(a.attribute5, '') = ISNULL(b.attribute5, '')
			--AND ISNULL(a.attribute4, '') = ISNULL(b.attribute4, '')
			--AND ISNULL(a.attribute3, '') = ISNULL(b.attribute3, '')
			--AND ISNULL(a.attribute2, '') = ISNULL(b.attribute2, '')
			--AND ISNULL(a.attribute1, '') = ISNULL(b.attribute1, '')
			--AND ISNULL(a.organic, 'n') 	 = ISNULL(b.organic, 'n') 
			--AND ISNULL(a.form, '')		 = ISNULL(b.form, '')
			--AND ISNULL(a.origin, '')	 = ISNULL(b.origin, '')				
			AND ISNULL(a.source_deal_groups_name, '') = ISNULL(b.source_deal_groups_name, '')
			AND ISNULL(a.static_group_name, '') = ISNULL(b.static_group_name, '')							
		WHERE b.buy_sell_flag = 'b'
			AND a.buy_sell_flag = 's'
		--GROUP BY a.source_deal_groups_id, b.source_deal_groups_id , a.source_deal_detail_id
	END 
	 
	SELECT @parent_line = sc.counterparty_id 
	FROM portfolio_hierarchy pf 
	INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = pf.entity_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id
		AND pf.entity_id = -1

	DECLARE @group_name VARCHAR(1000)
	DECLARE @row_count_match_group_shipment INT

	SELECT @row_count = COUNT(match_group_header_id) FROM match_group_header
	SELECT @row_count_group = COUNT(match_group_id) FROM match_group
	SELECT @row_count_match_group_shipment = COUNT(match_group_shipment_id) FROM match_group_shipment

	SELECT @group_name = CAST(MONTH(MIN(sdd.term_start)) AS VARCHAR(100)) + '-' + CAST(YEAR(MIN(sdd.term_start))  AS VARCHAR(100))  
						+ '-' + CAST(MONTH(MAX(sdd.term_start)) AS VARCHAR(100)) + '-' + CAST(YEAR(MAX(sdd.term_start))  AS VARCHAR(100))  
	FROM #source_deal_detail_id sddi 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddi.source_deal_detail_id
		
	/*get counterparty if location is not null */
 
 	IF @location_contract_commodity IS NOT NULL OR @location_contract_commodity <> 'NULL'
	BEGIN 
		SET @injection_withdrawal = CASE WHEN @sell_deals IS NULL THEN 'w' ELSE 'i' END
		SELECT @template_id = clm3_value 
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		WHERE gmh.mapping_name = 'Scheduling Storage Mapping'
			AND clm1_value = @injection_withdrawal

		SELECT   MAX(sc.counterparty_id) counterparty_id, temp.base_id, temp.location_id
				, ISNULL(mgd.batch_id, NULL) batch_id 
			  , temp.lot
			  --, sdh.source_deal_header_id, temp.base_id
		INTO #base_deal_counterparty_id
		FROM match_group_detail mgd 
		INNER JOIN #to_generate_match_id_storage_deal_temp temp ON temp.lot = mgd.lot
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id 
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id	
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
		WHERE 1 = 1 AND sdd.buy_sell_flag = 's' 
			AND sdd.location_id = temp.location_id		 
			--AND ISNULL(temp.batch_id, '') = ISNULL(mgd.batch_id, '')
			AND sdt.deal_type_id = 'Storage'
		GROUP BY temp.base_id, temp.location_id, ISNULL(mgd.batch_id, NULL), temp.lot	 
	END

	--select * from #to_generate_match_id_storage_deal_temp
	--select * FROM #base_deal_counterparty_id
	--select * from #source_deal_detail_id
	--return 
	
 	SELECT CASE WHEN @buy_deals = '' THEN @new_deal_counterparty_id ELSE sc.counterparty_id END rec
			, CASE WHEN @sell_deals = '' THEN @new_deal_counterparty_id ELSE sc1.counterparty_id END del
			,  sml.source_minor_location_id location_id
			, sdd.buy_sell_flag
			, UPPER(@bookout_match) bookout_match
			, CAST(MONTH(sdd.term_start) AS VARCHAR(100)) term_start_mth
			, CAST(YEAR(sdd.term_start)  AS VARCHAR(100)) term_start_year
			, ISNULL(sml.location_id, 'NOL') location_name
			, ISNULL(commodity_name, 'NOC') commodity_name
			, 'GRP -' group_name
			, CASE WHEN @row_count_group = 0 THEN '1' ELSE CAST(IDENT_CURRENT('match_group') + 1 AS VARCHAR(100)) END match_group_id
			, CASE WHEN @row_count_match_group_shipment = 0 THEN 1 
				ELSE CAST(IDENT_CURRENT('match_group_shipment' ) + 1 AS VARCHAR(100)) END 
					+ CASE WHEN @is_back_to_back = 'y' THEN  (DENSE_RANK () OVER (ORDER BY CASE WHEN @sell_deals IS NULL OR @sell_deals = '' 
						THEN CAST(temp.source_deal_groups_id AS VARCHAR(1000)) ELSE temp.source_deal_groups_name END DESC) -1) 
						ELSE 0 END match_group_shipment_id 
			, CASE WHEN @row_count = 0 THEN '1' ELSE CAST(IDENT_CURRENT('match_group_header') + 1 AS VARCHAR(100)) END 
				+ (DENSE_RANK() OVER (ORDER BY sml.source_minor_location_id																																	--, temp.attribute5
				--, temp.attribute4
				--, temp.attribute3
				--, temp.attribute2
				--, temp.attribute1
				--, temp.organic
				--, temp.form
				--, temp.origin
				--, temp.organic
			, CASE WHEN @is_back_to_back = 'y' THEN temp.source_deal_groups_id ELSE '' END) - 1) match_group_header_id 			
			, COALESCE(sml.region, sml.source_minor_location_id) region
			, temp.source_deal_detail_id
			, temp.split_deal_detail_volume_id
			, temp.quantity total_volume
			, ISNULL(sdd.detail_commodity_id, sdh.commodity_id) commodity_id	
			--, COALESCE(sdv.code, sml2.location_id,sml.location_id) region_name
			, COALESCE(sdv.code,sml.location_id) region_name
			--, temp.attribute5
			--, temp.attribute4
			--, temp.attribute3
			--, temp.attribute2
			--, temp.attribute1
			--, temp.organic
			--, temp.form
			--, temp.origin
			, temp.source_deal_groups_id
			, temp.source_deal_groups_name
			, temp.static_group_name		
			, sdd.lot
			, sdd.batch_id	
			, NULL base_id
			, sdh.deal_id
			, counterparty_id2.counterparty_id seller_counterparty
			, temp.packing_uom
			, sdt.deal_type_id
			, sdd.crop_year
		INTO #coll_rec_del_counterparty
	FROM #source_deal_detail_id temp
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id

	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		AND sdd.buy_sell_flag ='b'
	LEFT JOIN source_counterparty sc1 ON sc1.source_counterparty_id = sdh.counterparty_id
		AND sdd.buy_sell_flag ='s'
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = ISNULL(temp.changed_location, sdd.location_id)
	LEFT JOIN static_data_value sdv ON sml.region = sdv.value_id 
	LEFT JOIN source_commodity commodity ON commodity.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
	LEFT JOIN source_counterparty counterparty_id2 ON counterparty_id2.source_counterparty_id = sdh.counterparty_id2
		AND sdd.buy_sell_flag ='b'
		 	
    IF @location_contract_commodity <> 'NULL'
	BEGIN 
		DECLARE @new_deal_id VARCHAR(MAX)

		SELECT @deal_pre = ISNULL(prefix, 'ST-') 
		FROM deal_reference_id_prefix drp
		INNER JOIN source_deal_type sdp ON sdp.source_deal_type_id = drp.deal_type
		WHERE deal_type_id = 'Storage'

		IF @deal_pre IS NULL 
			SET @deal_pre = 'ST-'

		SET @new_deal_id = @deal_pre + CAST(IDENT_CURRENT('source_deal_header') + 1 AS VARCHAR(1000))

		INSERT INTO #coll_rec_del_counterparty  
		SELECT DISTINCT  MAX(CASE WHEN ISNULL(@buy_deals, '') = '' THEN bdc.counterparty_id ELSE NULL END) rec,
			MAX(CASE WHEN ISNULL(@sell_deals, '') = '' THEN bdc.counterparty_id ELSE NULL END) del, 
			t.location_id,
			MAX(CASE WHEN @buy_deals = '' THEN 'b' ELSE 's' END) buy_sell,
			UPPER(@bookout_match) bookout_match,
			MAX(CAST(MONTH(t.term_start) AS VARCHAR(100))) term_start_mth,
			MAX(CAST(YEAR(t.term_start)  AS VARCHAR(100))) term_start_year,
			MAX(location_name) location_name,
			MAX(ISNULL(commodity_name, 'NOC')) commodity_name,
			'GRP -' group_name,
			MAX(CASE WHEN @row_count_group = 0  THEN '1' ELSE CAST(IDENT_CURRENT('match_group' ) + 1 AS VARCHAR(100)) END) match_group_id,
			MAX(CASE WHEN @row_count_match_group_shipment = 0  THEN '1' ELSE CAST(IDENT_CURRENT('match_group_shipment' ) + 1 AS VARCHAR(100)) END) match_group_shipment_id,
			MAX(CASE WHEN @row_count = 0  THEN '1' ELSE CAST(IDENT_CURRENT('match_group_header' ) + 2 AS VARCHAR(100)) END) match_group_header_id ,		
			MAX(region),
			-1,
			NULL,
			MAX(t.total_volume) total_volume,
			MAX(source_commodity_id),
			MAX(ISNULL(region_name, '')),
			--MAX(CASE WHEN str_sdd.attribute5 = '' OR str_sdd.attribute5 IS NULL THEN NULL ELSE str_sdd.attribute5 END),	
			--MAX(CASE WHEN str_sdd.attribute4 = '' OR str_sdd.attribute4 IS NULL THEN NULL ELSE str_sdd.attribute4 END),
			--MAX(CASE WHEN str_sdd.attribute3 = '' OR str_sdd.attribute3 IS NULL THEN NULL ELSE str_sdd.attribute3 END),
			--MAX(CASE WHEN str_sdd.attribute2 = '' OR str_sdd.attribute2 IS NULL THEN NULL ELSE str_sdd.attribute2 END),
			--MAX(CASE WHEN str_sdd.attribute1 = '' OR str_sdd.attribute1 IS NULL THEN NULL ELSE str_sdd.attribute1 END),
			--MAX(CASE WHEN str_sdd.organic = '' OR str_sdd.organic IS NULL THEN 'n' ELSE str_sdd.organic END),
			--MAX(str_sdd.form),
			--MAX(str_sdd.origin),
			MAX(sdg.source_deal_groups_id) source_deal_groups_id,
			MAX(sdg.source_deal_groups_name) source_deal_groups_name,
			MAX(sdg.static_group_name) static_group_name,
			MAX(ISNULL(t.lot, NULL)),
			ISNULL(t.batch_id, '') batch_id,
			t.base_id, 
			@deal_pre + CAST(IDENT_CURRENT('source_deal_header') + (ROW_NUMBER() OVER (ORDER BY MAX(t.location_id)
				--, MAX(str_sdd.attribute5)
				--, MAX(str_sdd.attribute4)
				--, MAX(str_sdd.attribute3)
				--, MAX(str_sdd.attribute2)
				--, MAX(str_sdd.attribute1)
				--, MAX(str_sdd.organic)
				--, MAX(str_sdd.form)
				--, MAX(str_sdd.origin)
				)) AS VARCHAR(1000)) deal_id
			, NULL seller_counterparty
			, MAX(t.packing_uom) packing_uom			
			, MAX(sdt.deal_type_id) deal_type_id	
			, MAX(sdd_lot.crop_year)
		FROM #to_generate_match_id_storage_deal_temp t
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t.base_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
			--AND sdd.product_description = t.product_description	
		LEFT JOIN source_deal_header str_sdh ON str_sdh.source_deal_header_id = t.storage_deal_id
		LEFT JOIN source_deal_detail str_sdd ON str_sdd.source_deal_header_id = str_sdh.source_deal_header_id
		LEFT JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN #base_deal_counterparty_id bdc ON bdc.base_id = t.base_id		
			AND bdc.location_id = t.location_id		
			AND ISNULL(t.batch_id, '') = ISNULL(bdc.batch_id, '')		
			AND bdc.lot = t.lot		
		LEFT JOIN  source_deal_detail sdd_lot ON CAST(sdd_lot.source_deal_detail_id AS VARCHAR(1000)) = t.lot
		GROUP BY t.base_id, t.location_id, ISNULL(t.batch_id, ''), t.lot

		--select * from #to_generate_match_id_storage_deal_temp
		--select  * from #base_deal_counterparty_id

		SELECT CASE WHEN @row_count = 0 THEN '1' ELSE CAST(IDENT_CURRENT('match_group_header') + 1 AS VARCHAR(100)) END 
				+ (DENSE_RANK() OVER (ORDER BY location_id, commodity_id
				--, attribute5
				--, attribute4
				--, attribute3
				--, attribute2
				--, attribute1
				--, organic
				--, form
				--, origin
				, CASE WHEN @is_back_to_back = 'y' THEN source_deal_groups_id ELSE '' END) - 1) match_group_header_id 		
			, location_id
			--, attribute5
			--, attribute4
			--, attribute3
			--, attribute2
			--, attribute1
			--, organic
			--, form
			--, origin
			, commodity_id
			INTO #to_update_ids
		FROM #coll_rec_del_counterparty	

		--select
		UPDATE b 
		SET b.match_group_header_id = a.match_group_header_id
		FROM #to_update_ids a 
		INNER JOIN #coll_rec_del_counterparty b ON   b.location_id	= a.location_id	
			AND  b.commodity_id =  a.commodity_id
												--AND ISNULL(b.attribute5	, '')= ISNULL(a.attribute5	, '')
												--AND ISNULL(b.attribute4	, '')= ISNULL(a.attribute4	, '')
												--AND ISNULL(b.attribute3	, '')= ISNULL(a.attribute3	, '')
												--AND ISNULL(b.attribute2	, '')= ISNULL(a.attribute2	, '')
												--AND ISNULL(b.attribute1	, '')= ISNULL(a.attribute1	, '')
												--AND ISNULL(b.organic	, '')= ISNULL(a.organic		, '')
												--AND ISNULL(b.form		, '')= ISNULL(a.form		, '')	
												--AND ISNULL(b.origin	   	, '')= ISNULL(a.origin		, '')		
	END
	 
	CREATE TABLE #back_to_back_shipment_name(shipment_name VARCHAR(MAX) COLLATE DATABASE_DEFAULT, match_group_shipment_id INT)
	  
	IF @is_back_to_back = 'y' AND @sell_deals IS NOT NULL --back to back case
	BEGIN 
		INSERT INTO #back_to_back_shipment_name
		SELECT DISTINCT a.deal_id + ' - ' + a.source_deal_groups_name + ' - ' + a.rec  + ' | '  + b.deal_id + ' - ' + b.source_deal_groups_name + ' - ' + b.del shipment_name
			, a.match_group_shipment_id
		FROM #coll_rec_del_counterparty a 
		OUTER APPLY (SELECT * FROM  #coll_rec_del_counterparty WHERE buy_sell_flag = 's') b
		WHERE b.source_deal_groups_name = a.source_deal_groups_name
			--AND b.commodity_id = a.commodity_id
			--AND b.buy_sell_flag <> a.buy_sell_flag
			AND a.buy_sell_flag = 'b'
	END
	ELSE IF @is_back_to_back = 'y' AND @sell_deals IS  NULL --agency deal case
	BEGIN 
		INSERT INTO #back_to_back_shipment_name
		SELECT DISTINCT a.deal_id + ' - ' + a.source_deal_groups_name + ' - ' + a.rec + ' - ' + seller_counterparty  shipment_name, a.match_group_shipment_id
		FROM #coll_rec_del_counterparty a 
	END

  	SELECT CASE WHEN @sell_deals IS NULL AND @location_contract_commodity IS NULL --agency deals
			THEN STUFF((SELECT DISTINCT ' - ' + rec  
						FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b' AND deal_type_id <> 'Transportation'
						FOR XML PATH('')
						), 1, 3, '') 
				+ ' - ' 
				+ STUFF((SELECT DISTINCT ' - ' + seller_counterparty  
						FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b' AND deal_type_id <> 'Transportation'
						FOR XML PATH('')
						), 1, 3, '')
				ELSE 
					CASE WHEN buy_sell_flag = 'b' THEN rec 
						ELSE STUFF((SELECT DISTINCT ' - ' + rec  
									FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b' AND deal_type_id <> 'Transportation'
									FOR XML PATH('')
									), 1, 3, '') END + ' - ' + ISNULL(@parent_line, '') 
							+ ' - ' 
							+ CASE WHEN buy_sell_flag = 'b' THEN ISNULL(STUFF((SELECT DISTINCT ' - ' + del  
									FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 's' AND deal_type_id <> 'Transportation'
									FOR XML PATH('')
						), 1, 3, ''), '') ELSE ISNULL(del, '') END 
			END lineup
			, location_id
			, buy_sell_flag
			, CASE WHEN bookout_match = 'b' THEN bookout_match ELSE 'MTC' END  
				+ ' - ' 
				+ '[ID]'
				+ CASE WHEN @sell_deals IS NULL AND @location_contract_commodity IS NULL --agency deals
					THEN '' ELSE ' | ' + ISNULL(location_name, region_name) END 
				+ ' | ' + crdc.commodity_name 
				--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.value_id < 0 OR sdv_form.code = '- Not Specified -'THEN '' ELSE ' ' + sdv_form.code END 
				--+ ' | ' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = '- Not Specified -'THEN '' ELSE commodity_origin_id.code END		
				--+ ' | ' + CASE WHEN crdc.organic IS NULL OR crdc.organic = '' OR crdc.organic = 'n' THEN '' ELSE ' Organic ' END 		
				--+ CASE WHEN sdv1.code IS NULL OR sdv1.value_id < 0 OR sdv1.code = '- Not Specified -' THEN '' ELSE ' ' + sdv1.code END  
				--+ CASE WHEN sdv2.code IS NULL OR sdv2.value_id < 0 OR sdv2.code = '- Not Specified -' THEN '' ELSE ' ' + sdv2.code END  
				--+ CASE WHEN sdv3.code IS NULL OR sdv3.value_id < 0 OR sdv3.code = '- Not Specified -' THEN '' ELSE ' ' + sdv3.code END  
				--+ CASE WHEN sdv4.code IS NULL OR sdv4.value_id < 0 OR sdv4.code = '- Not Specified -' THEN '' ELSE ' ' + sdv4.code END  
				--+ CASE WHEN sdv5.code IS NULL OR sdv5.value_id < 0 OR sdv5.code = '- Not Specified -' THEN '' ELSE ' ' + sdv5.code END  
				 bookout_id
			, match_group_id
			, crdc.match_group_shipment_id
			, match_group_header_id
			, group_name + ' [ID]' 
				+ ' | ' 
				+ STUFF(( SELECT DISTINCT ' , ' + deal_id  
					FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b' AND deal_type_id <> 'Transportation'
					FOR XML PATH('')), 1, 3, '') 
				+ ' - '
				+ STUFF(( SELECT DISTINCT ' , ' + rec  
					FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b' AND deal_type_id <> 'Transportation'
					FOR XML PATH('')), 1, 3, '')   
				+ CASE WHEN @sell_deals IS NULL AND @location_contract_commodity IS NULL --agency deals
				THEN ' - ' + STUFF((SELECT DISTINCT ' - ' + seller_counterparty  
									FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b'
									FOR XML PATH('')
									), 1, 3, '') 
				ELSE + ' | '
					+ ISNULL(STUFF((SELECT DISTINCT ' , ' + deal_id
					FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 's' AND deal_type_id <> 'Transportation'
					FOR XML PATH('')), 1, 3, ''), '')
					+ ' - '
					+ ISNULL(STUFF(( SELECT DISTINCT ' , ' + del
						FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 's' AND deal_type_id <> 'Transportation'
						FOR XML PATH('')), 1, 3, ''), '')						  
				END group_name						
			, 'SHP - [ID]' 
				+ ' | ' 
				+ CASE WHEN @is_back_to_back = 'y'  THEN ISNULL(btb.shipment_name, '') -- back to back 
					ELSE ISNULL(STUFF((SELECT DISTINCT ' , ' + deal_id + ' - ' + ISNULL(source_deal_groups_name, '')
										FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b' AND deal_type_id <> 'Transportation'							
										FOR XML PATH('')), 1, 3, '') , '')	
					 		
					+ ' - '
					+ STUFF(( SELECT DISTINCT ' , ' + rec  
						FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b' AND deal_type_id <> 'Transportation'
						FOR XML PATH('')), 1, 3, '') 				
					+ 
					CASE WHEN @sell_deals IS NULL AND @location_contract_commodity IS NULL AND @is_back_to_back = 'n' --agency deals 
						THEN ' - ' + STUFF((SELECT DISTINCT ' - ' + seller_counterparty  
											FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 'b' AND deal_type_id <> 'Transportation'
											FOR XML PATH('')
											), 1, 3, '') 
						ELSE 
						 ' | ' + ISNULL(STUFF(( SELECT DISTINCT ' , ' + deal_id + ' - ' + ISNULL(source_deal_groups_name, '')
								FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 's' AND deal_type_id <> 'Transportation'
								FOR XML PATH('')), 1, 3, ''), '')		
					 														
						+ ' - '
						+ ISNULL(STUFF(( SELECT DISTINCT ' , ' + del
							FROM #coll_rec_del_counterparty WHERE buy_sell_flag = 's' AND deal_type_id <> 'Transportation'
							FOR XML PATH('')), 1, 3, ''), '')
						 
						END
					END transportation_grp			  
			, region
			, source_deal_detail_id
			, split_deal_detail_volume_id
			, total_volume
			, commodity_id
			--, ISNULL(crdc.attribute5, NULL) attribute5
			--, ISNULL(crdc.attribute4, NULL) attribute4
			--, ISNULL(crdc.attribute3, NULL) attribute3
			--, ISNULL(crdc.attribute2, NULL) attribute2
			--, ISNULL(crdc.attribute1, NULL) attribute1
			--, ISNULL(crdc.organic, 'n')  organic
			--, ISNULL(crdc.form, NULL) form
			--, ISNULL(crdc.origin, NULL)	origin	 
			, ISNULL(crdc.lot, NULL) lot
			, ISNULL(crdc.batch_id, NULL) batch_id
			, base_id
			, source_deal_groups_id
			, crdc.commodity_name 
				--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.value_id < 0 OR sdv_form.code = '- Not Specified -'THEN '' ELSE ' ' + sdv_form.code END 
				--+ ' | ' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = '- Not Specified -'THEN '' ELSE commodity_origin_id.code END		
				--+ ' |' + CASE WHEN crdc.organic IS NULL OR crdc.organic = '' OR crdc.organic = 'n' THEN '' ELSE ' Organic' END 		
				--+ CASE WHEN sdv1.code IS NULL OR sdv1.value_id < 0 OR sdv1.code = '- Not Specified -' THEN '' ELSE ' ' + sdv1.code END  
				--+ CASE WHEN sdv2.code IS NULL OR sdv2.value_id < 0 OR sdv2.code = '- Not Specified -' THEN '' ELSE ' ' + sdv2.code END  
				--+ CASE WHEN sdv3.code IS NULL OR sdv3.value_id < 0 OR sdv3.code = '- Not Specified -' THEN '' ELSE ' ' + sdv3.code END  
				--+ CASE WHEN sdv4.code IS NULL OR sdv4.value_id < 0 OR sdv4.code = '- Not Specified -' THEN '' ELSE ' ' + sdv4.code END  
				--+ CASE WHEN sdv5.code IS NULL OR sdv5.value_id < 0 OR sdv5.code = '- Not Specified -' THEN '' ELSE ' ' + sdv5.code END  
				  product
				, crdc.packing_uom
				, crdc.deal_type_id
			, crdc.crop_year
	 	INTO #max_rec_del_counterparty
	FROM #coll_rec_del_counterparty crdc
	LEFT JOIN #back_to_back_shipment_name btb ON btb.match_group_shipment_id = crdc.match_group_shipment_id
		
		/*
	LEFT JOIN commodity_origin co ON co.commodity_origin_id = crdc.origin
	LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
		AND type_id = 14000

	LEFT JOIN commodity_form cf ON cf.commodity_form_id = crdc.form
	LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
	LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = commodity_form_id.commodity_form_value
				 
	LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = crdc.attribute1
	LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
		AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value
				
	LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id =crdc.attribute2
	LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
		AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
	LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

	LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = crdc.attribute3
	LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
		AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
	LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

	LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = crdc.attribute4
	LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
		AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
	LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

	LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = crdc.attribute5
	LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
		AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
	LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value
	*/

	SELECT MIN(temp.quantity) vol
			, sdd.buy_sell_flag buy_sell_flag
			, MAX(sdd.location_id) location_id
			, MIN(quantity_total) quantity_total, ISNULL(sml.region, sdd.location_id) region
			, ISNULL(sdd.detail_commodity_id, sdh.commodity_id) commodity_id
			--, ISNULL(temp.attribute5, NULL) attribute5
			--, ISNULL(temp.attribute4, NULL) attribute4
			--, ISNULL(temp.attribute3, NULL) attribute3
			--, ISNULL(temp.attribute2, NULL) attribute2
			--, ISNULL(temp.attribute1, NULL) attribute1
			--, ISNULL(temp.organic, 'n') organic
			--, ISNULL(temp.form, NULL) form
			--, ISNULL(temp.origin, NULL) origin	 
			, ISNULL(temp.lot, NULL) lot
			, ISNULL(temp.batch_id, NULL) batch_id 
			, MAX(sdd.product_description) product_description
		INTO #volume_temp
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #source_deal_detail_id temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
	LEFT JOIN source_minor_location sml On sml.source_minor_location_id = sdd.location_id
	LEFT JOIN match_group_detail mgd ON temp.source_deal_detail_id = mgd.source_deal_detail_id
		AND temp.split_deal_detail_volume_id = mgd.split_deal_detail_volume_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	WHERE sdt.deal_type_id <> 'Transportation'
	GROUP BY ISNULL(sml.region, sdd.location_id)
			, ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
			, sdd.buy_sell_flag
			--, ISNULL(temp.attribute5, NULL)
			--, ISNULL(temp.attribute4, NULL)
			--, ISNULL(temp.attribute3, NULL)
			--, ISNULL(temp.attribute2, NULL)
			--, ISNULL(temp.attribute1, NULL)
			--, ISNULL(temp.organic, 'n') 
			--, ISNULL(temp.form, NULL)
			--, ISNULL(temp.origin, NULL)			
			, ISNULL(temp.lot, NULL) 
			, ISNULL(temp.batch_id, NULL) 			 

	/* insert  volume form storage deal */
	IF @location_contract_commodity <> 'NULL'
	BEGIN 
		IF EXISTS(SELECT 1 FROM #to_generate_match_id_storage_deal_temp temp
				INNER JOIN source_deal_detail sdd ON CAST(sdd.source_deal_detail_id AS VARCHAR(1000)) = temp.lot
				INNER JOIN #volume_temp vt ON vt.product_description = temp.product_description
					AND vt.location_id = temp.location_id)
		BEGIN 
			--SELECT 
			UPDATE vt
			SET  vt.vol = CASE WHEN vt.vol < temp.total_volume THEN vt.vol ELSE temp.total_volume END
			FROM #to_generate_match_id_storage_deal_temp temp
			INNER JOIN #volume_temp vt ON vt.product_description = temp.product_description
				AND vt.location_id = temp.location_id
		END 
		ELSE 
		BEGIN 
			INSERT INTO #volume_temp(vol, buy_sell_flag, location_id, quantity_total, region	
									, commodity_id
									--, attribute5, attribute4, attribute3, attribute2	
									--, attribute1, organic, form, origin
									, lot, batch_id, product_description)
 			SELECT temp.total_volume vol, temp.buy_sell, temp.location_id, temp.total_volume quantity_total, temp.region	
				, sdd.detail_commodity_id	
				--, sdd.attribute5, sdd.attribute4, sdd.attribute3, sdd.attribute2, sdd.attribute1	
				--, ISNULL(sdd.organic, 'n'), sdd.form, sdd.origin
				, temp.lot, sdd.batch_id, temp.product_description 
			FROM #to_generate_match_id_storage_deal_temp temp
			INNER JOIN source_deal_detail sdd ON CAST(sdd.source_deal_detail_id AS VARCHAR(1000)) = temp.lot			 
		END 
	END
	
	/* insert  volume form storage deal end */	 
	 
	--SELECT * 
	UPDATE vt 
	SET vt.vol = a.vol 
	FROM #volume_temp vt
	INNER JOIN (SELECT MIN(vol) vol, region, commodity_id 
				--, ISNULL(attribute5, NULL) attribute5
				--, ISNULL(attribute4, NULL) attribute4
				--, ISNULL(attribute3, NULL) attribute3
				--, ISNULL(attribute2, NULL) attribute2
				--, ISNULL(attribute1, NULL) attribute1
				--, ISNULL(organic, 'n') organic
				--, ISNULL(form, NULL) form
				--, ISNULL(origin, NULL) origin
				, ISNULL(lot, NULL) lot
				, ISNULL(batch_id, NULL) batch_id
				FROM #volume_temp 
				GROUP BY region, commodity_id
						--, ISNULL(attribute5, NULL)
						--, ISNULL(attribute4, NULL)
						--, ISNULL(attribute3, NULL)
						--, ISNULL(attribute2, NULL)
						--, ISNULL(attribute1, NULL)
						--, ISNULL(organic, 'n') 
						--, ISNULL(form, NULL)
						--, ISNULL(origin, NULL)
						, ISNULL(lot, NULL) 
						, ISNULL(batch_id, NULL) 
							) a ON vt.commodity_id = a.commodity_id 
		AND a.region = vt.region
		--AND ISNULL(vt.attribute5, NULL)	= ISNULL(a.attribute5, NULL)
		--AND ISNULL(vt.attribute4, NULL)	= ISNULL(a.attribute4, NULL)
		--AND ISNULL(vt.attribute3, NULL)	= ISNULL(a.attribute3, NULL)
		--AND ISNULL(vt.attribute2, NULL)	= ISNULL(a.attribute2, NULL)
		--AND ISNULL(vt.attribute1, NULL)	= ISNULL(a.attribute1, NULL)
		--AND ISNULL(vt.organic, 'n') 	= ISNULL(a.organic, 'n') 
		--AND ISNULL(vt.form, NULL)		= ISNULL(a.form, NULL)
		--AND ISNULL(vt.origin, NULL)		= ISNULL(a.origin, NULL)				
		AND ISNULL(vt.lot, NULL)  		= ISNULL(a.lot, NULL) 
		AND ISNULL(vt.batch_id, NULL)  	= ISNULL(a.batch_id, NULL) 		

 	SET @lineup_vol_id_tbl = dbo.FNAProcessTableName('lineup_vol_id_tbl', @user_name, @process_id)
 
	SET @sql = ' IF OBJECT_ID(''' + @lineup_vol_id_tbl + ''', ''U'') IS NOT NULL
				BEGIN 
					DELETE FROM  ' + @lineup_vol_id_tbl + '
				END 
				ELSE 
				BEGIN 
					CREATE TABLE ' + @lineup_vol_id_tbl + '	(
					bookoutid						VARCHAR(1000)
					, lineup						VARCHAR(1000)
					, vol							NUMERIC(38, 18)
					, group_name					VARCHAR(1000)
					, match_group_id				VARCHAR(1000)
					, match_group_shipment_id		VARCHAR(1000)
					, match_group_header_id			VARCHAR(1000)
					, buy_sell_flag					VARCHAR(1000)
					, location_id					VARCHAR(1000)
					, transportation_grp			VARCHAR(1000)
					, region						VARCHAR(1000)
					, source_deal_detail_id			VARCHAR(1000)
					, split_deal_detail_volume_id	VARCHAR(1000)
					, quantity_total				NUMERIC(38, 18)
					, commodity_id					VARCHAR(1000)
					, lot							VARCHAR(1000)
					, batch_id						VARCHAR(1000)
					, base_id						VARCHAR(1000)
					, match_order_sequence			INT
					--, attribute5					VARCHAR(1000)
					--, attribute4					VARCHAR(1000)
					--, attribute3					VARCHAR(1000)
					--, attribute2					VARCHAR(1000)
					--, attribute1					VARCHAR(1000)
					--, organic						VARCHAR(1000)
					--, form							VARCHAR(1000)
					--, origin						VARCHAR(1000)
					, source_deal_groups_id			VARCHAR(1000)
					, packing_uom					VARCHAR(1000)
					, is_lot_updated				CHAR(1)
					, deal_type_id					VARCHAR(1000)
					, crop_year						INT
					)
				END '
	
	EXEC spa_print @sql
	EXEC(@sql)

	--select * from #max_rec_del_counterparty
	--select * from #volume_temp
	--return
	SET @sql = 'INSERT INTO ' + @lineup_vol_id_tbl + '	(
														bookoutid						
														, lineup						
														, vol							
														, group_name					
														, match_group_id				
														, match_group_shipment_id		
														, match_group_header_id			
														, buy_sell_flag					
														, location_id					
														, transportation_grp			
														, region						
														, source_deal_detail_id			
														, split_deal_detail_volume_id	
														, quantity_total				
														, commodity_id					
														, lot							
														, batch_id						
														, base_id						
														, match_order_sequence			
														--, attribute5					
														--, attribute4					
														--, attribute3					
														--, attribute2					
														--, attribute1					
														--, organic						
														--, form							
														--, origin						
														, source_deal_groups_id			
														, packing_uom	
														, deal_type_id				
														, crop_year				
				)
				SELECT DISTINCT bookout_id bookoutid
					, lineup
					, ISNULL(vol, mrdc.total_volume) vol
					, group_name
					, match_group_id
					, match_group_shipment_id
					, match_group_header_id
					, mrdc.buy_sell_flag
					, mrdc.location_id
					, mrdc.transportation_grp
					, mrdc.region
					, source_deal_detail_id
					, split_deal_detail_volume_id
					, ISNULL(vt.quantity_total, mrdc.total_volume) quantity_total
					, mrdc.commodity_id
					, CASE WHEN mrdc.buy_sell_flag = ''b'' 
						THEN 
							CASE WHEN ''' + ISNULL(@location_contract_commodity, 'NULL') + ''' <> ''NULL'' 
								THEN ISNULL(mrdc.lot, CAST(mrdc.source_deal_detail_id AS VARCHAR(1000))) 
								ELSE CAST(mrdc.source_deal_detail_id AS VARCHAR(1000)) END ELSE NULL END lot
					, mrdc.batch_id
					, mrdc.base_id
					, CASE WHEN  mrdc.buy_sell_flag = ''b'' THEN 1 ELSE ROW_NUMBER() OVER(PARTITION BY mrdc.buy_sell_flag ORDER BY mrdc.buy_sell_flag, match_group_header_id, mrdc.commodity_id ASC) END  match_order_sequence
					--, ISNULL(mrdc.attribute5, NULL) attribute5
					--, ISNULL(mrdc.attribute4, NULL) attribute4
					--, ISNULL(mrdc.attribute3, NULL) attribute3
					--, ISNULL(mrdc.attribute2, NULL) attribute2
					--, ISNULL(mrdc.attribute1, NULL) attribute1
					--, ISNULL(mrdc.organic, ''n'') 	organic
					--, ISNULL(mrdc.form, NULL)	 form	
					--, ISNULL(mrdc.origin, NULL) origin				
					, source_deal_groups_id			
					, packing_uom 	
					, mrdc.deal_type_id	
					, mrdc.crop_year	
				FROM #max_rec_del_counterparty mrdc
				LEFT JOIN #volume_temp vt ON 1 = 1
					AND mrdc.region = vt.region
					AND mrdc.commodity_id = vt.commodity_id
					AND vt.buy_sell_flag = mrdc.buy_sell_flag
					--AND ISNULL(vt.attribute5, NULL)	= ISNULL(mrdc.attribute5, NULL)
					--AND ISNULL(vt.attribute4, NULL)	= ISNULL(mrdc.attribute4, NULL)
					--AND ISNULL(vt.attribute3, NULL)	= ISNULL(mrdc.attribute3, NULL)
					--AND ISNULL(vt.attribute2, NULL)	= ISNULL(mrdc.attribute2, NULL)
					--AND ISNULL(vt.attribute1, NULL)	= ISNULL(mrdc.attribute1, NULL)
					--AND ISNULL(vt.organic, ''n'') 	= ISNULL(mrdc.organic, ''n'') 
					--AND ISNULL(vt.form, NULL)		= ISNULL(mrdc.form, NULL)
					--AND ISNULL(vt.origin, NULL)		= ISNULL(mrdc.origin, NULL)
					AND ISNULL(vt.lot, NULL)  		= ISNULL(mrdc.lot, NULL)  
					AND ISNULL(vt.batch_id, NULL)  	= ISNULL(mrdc.batch_id, NULL)  

					'

	EXEC spa_print @sql 
	EXEC(@sql) 
	
	--EXEC('select * from ' + @lineup_vol_id_tbl)
	-- return 
	--/*
	---for lot calculation start
	CREATE TABLE #lot_collection(
								commodity_id	VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								--, origin		VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								--, form			VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								--, organic		VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								--, attribute1	VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								--, attribute2	VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								--, attribute3	VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								--, attribute4	VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								--, attribute5	VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								, lot_id		VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								, lot_org		VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								, source_deal_groups_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT
								, match_group_shipment_id INT
								)

	SET @sql = 'INSERT INTO #lot_collection
				SELECT
						commodity_id
						--, origin	   
						--, form	   
						--, organic	   
						--, attribute1 
						--, attribute2 
						--, attribute3 
						--, attribute4 
						--, attribute5 							
						, CASE WHEN STUFF(
						 (SELECT DISTINCT '','' +  CAST((source_deal_detail_id) AS VARCHAR(1000))
						  FROM ' + @lineup_vol_id_tbl + '
						  WHERE buy_sell_flag = ''b''
							AND deal_type_id <> ''Transportation''
						  	AND source_deal_detail_id <> -1
							AND commodity_id = a.commodity_id  
							--AND ISNULL(origin, '''')	 = 	ISNULL(a.origin, '''')	   
							--AND ISNULL(form, '''')		 = 	ISNULL(a.form, '''')	   
							--AND ISNULL(organic, ''n'')	 = 	ISNULL(a.organic, ''n'')	   
							--AND ISNULL(attribute1, '''') = 	ISNULL(a.attribute1, '''') 
							--AND ISNULL(attribute2, '''') = 	ISNULL(a.attribute2, '''') 
							--AND ISNULL(attribute3, '''') = 	ISNULL(a.attribute3, '''') 
							--AND ISNULL(attribute4, '''') = 	ISNULL(a.attribute4, '''') 
							--AND ISNULL(attribute5, '''') = 	ISNULL(a.attribute5, '''') 
							' + CASE WHEN @is_back_to_back = 'y'  THEN ' AND source_deal_groups_id = a.source_deal_groups_id ' ELSE '' END + '
						  FOR XML PATH (''''))
						  , 1, 1, '''')  = ''NULL'' THEN NULL
							ELSE STUFF(
							 (SELECT DISTINCT '','' +  CAST((source_deal_detail_id) AS VARCHAR(1000))
							  FROM ' + @lineup_vol_id_tbl + '
							  WHERE buy_sell_flag = ''b''
								AND commodity_id = a.commodity_id 
								AND deal_type_id <> ''Transportation''
								AND source_deal_detail_id <> -1
								--AND ISNULL(origin, '''')	 = 	ISNULL(a.origin, '''')	   
								--AND ISNULL(form, '''')		 = 	ISNULL(a.form, '''')	   
								--AND ISNULL(organic, ''n'')	 = 	ISNULL(a.organic, ''n'')	   
								--AND ISNULL(attribute1, '''') = 	ISNULL(a.attribute1, '''') 
								--AND ISNULL(attribute2, '''') = 	ISNULL(a.attribute2, '''') 
								--AND ISNULL(attribute3, '''') = 	ISNULL(a.attribute3, '''') 
								--AND ISNULL(attribute4, '''') = 	ISNULL(a.attribute4, '''') 
								--AND ISNULL(attribute5, '''') = 	ISNULL(a.attribute5, '''') 
								' + CASE WHEN @is_back_to_back = 'y'  THEN ' AND source_deal_groups_id = a.source_deal_groups_id ' ELSE '' END + '
								ORDER BY  '','' +  CAST((source_deal_detail_id) AS VARCHAR(1000))
							  FOR XML PATH (''''))
							  , 1, 1, '''') END lot_detail_id
						, STUFF(
							 (SELECT DISTINCT '','' +  CAST(ISNULL(lot, source_deal_detail_id) AS VARCHAR(1000))
							  FROM ' + @lineup_vol_id_tbl + '
							  WHERE buy_sell_flag = ''b''
								AND deal_type_id <> ''Transportation''
								AND commodity_id = a.commodity_id  
								--AND ISNULL(origin, '''')	 = 	ISNULL(a.origin, '''')	   
								--AND ISNULL(form, '''')		 = 	ISNULL(a.form, '''')	   
								--AND ISNULL(organic, ''n'')	 = 	ISNULL(a.organic, ''n'')	   
								--AND ISNULL(attribute1, '''') = 	ISNULL(a.attribute1, '''') 
								--AND ISNULL(attribute2, '''') = 	ISNULL(a.attribute2, '''') 
								--AND ISNULL(attribute3, '''') = 	ISNULL(a.attribute3, '''') 
								--AND ISNULL(attribute4, '''') = 	ISNULL(a.attribute4, '''') 
								--AND ISNULL(attribute5, '''') = 	ISNULL(a.attribute5, '''') 
								' + CASE WHEN @is_back_to_back = 'y'  THEN ' AND source_deal_groups_id = a.source_deal_groups_id ' ELSE '' END + '
							ORDER BY '','' +  CAST(ISNULL(lot, source_deal_detail_id) AS VARCHAR(1000))
							  FOR XML PATH (''''))
							  , 1, 1, '''')  AS lot_from_detail
					, source_deal_groups_id
					, match_group_shipment_id  
				FROM ' + @lineup_vol_id_tbl + ' AS a
				WHERE buy_sell_flag = ''b''
				GROUP BY commodity_id
				--, origin
				--, form
				--, organic
				--, attribute1
				--, attribute2
				--, attribute3
				--, attribute4
				--, attribute5
				, source_deal_groups_id
				, match_group_shipment_id
	'
	EXEC spa_print @sql
	EXEC(@sql)

	IF @location_contract_commodity <> 'NULL'
	BEGIN 
		--update by matching all pgs
		SET @sql = ' --select * 
					UPDATE a 
					SET a.lot = b.lot_org
					FROM  #lot_collection b
					INNER JOIN ' + @lineup_vol_id_tbl + ' a ON 
						ISNULL(b.commodity_id, '''') = ISNULL(a.commodity_id, '''')
						--AND ISNULL(b.attribute5  , '''') = ISNULL(a.attribute5  , '''')
						--AND ISNULL(b.attribute4  , '''') = ISNULL(a.attribute4  , '''')
						--AND ISNULL(b.attribute3  , '''') = ISNULL(a.attribute3  , '''')
						--AND ISNULL(b.attribute2  , '''') = ISNULL(a.attribute2  , '''')
						--AND ISNULL(b.attribute1  , '''') = ISNULL(a.attribute1  , '''')
						--AND ISNULL(b.form, '''') = ISNULL(a.form, '''')
						--AND ISNULL(b.origin, '''') = ISNULL(a.origin, '''')
						--AND ISNULL(b.organic, ''n'') = ISNULL(a.organic, ''n'')
					WHERE 1=1 AND buy_sell_flag = ''s''' 

		EXEC spa_print @sql
		EXEC(@sql)

		--update lot for remaining 
		SET @sql = '--SELECT * 
					UPDATE a 
					SET a.lot = lot_cal.lot
					FROM ' + @lineup_vol_id_tbl + ' a
					INNER JOIN (
					SELECT  STUFF(
									(SELECT DISTINCT '','' +  CAST((lot_org) AS VARCHAR(1000))
									FROM #lot_collection inn
									WHERE inn.commodity_id = a.commodity_id
									ORDER BY '','' +  CAST((lot_org) AS VARCHAR(1000))
									FOR XML PATH (''''))
									, 1, 1, '''') lot, match_group_shipment_id, commodity_id
								FROM #lot_collection a) lot_cal
						ON lot_cal.match_group_shipment_id = a.match_group_shipment_id
							AND lot_cal.commodity_id = a.commodity_id
						WHERE a.buy_sell_flag = ''s''
							AND a.lot IS NULL
					'

		EXEC spa_print @sql
		--EXEC(@sql)

		--update lot for remaining for matching commodity
		SET @sql = ' --SELECT * 
					UPDATE a 
					SET a.lot = lot_cal.lot
					FROM ' + @lineup_vol_id_tbl + ' a
					INNER JOIN (
					SELECT  STUFF(
									(SELECT DISTINCT '','' +  CAST((lot_org) AS VARCHAR(1000))
									FROM #lot_collection inn
									WHERE 1 = 1 --AND inn.commodity_id = a.commodity_id
									ORDER BY '','' +  CAST((lot_org) AS VARCHAR(1000))
									FOR XML PATH (''''))
									, 1, 1, '''') lot, match_group_shipment_id--, commodity_id
								FROM #lot_collection a) lot_cal
						ON lot_cal.match_group_shipment_id = a.match_group_shipment_id
							--AND lot_cal.commodity_id = a.commodity_id
						WHERE a.buy_sell_flag = ''s''
							AND a.lot IS NULL
					'

		EXEC spa_print @sql
		EXEC(@sql)
		--EXEC('select lot, * from ' + @lineup_vol_id_tbl)
		--return 

	END
	ELSE 
	BEGIN 
		--update by matching all pgs
	SET @sql = '--SELECT * 
				UPDATE b 
				SET b.lot = a.lot_id				
				FROM #lot_collection a
				INNER JOIN ' + @lineup_vol_id_tbl + ' b ON 1 = 1 AND b.match_group_shipment_id = a.match_group_shipment_id  
					AND b.commodity_id = a.commodity_id
					--AND ISNULL(b.origin, '''')	 = 	ISNULL(a.origin, '''')	   
					--AND ISNULL(b.form, '''')		 = 	ISNULL(a.form, '''')	   
					--AND ISNULL(b.organic, ''n'')	 = 	ISNULL(a.organic, ''n'')	   
					--AND ISNULL(b.attribute1, '''') = 	ISNULL(a.attribute1, '''') 
					--AND ISNULL(b.attribute2, '''') = 	ISNULL(a.attribute2, '''') 
					--AND ISNULL(b.attribute3, '''') = 	ISNULL(a.attribute3, '''') 
					--AND ISNULL(b.attribute4, '''') = 	ISNULL(a.attribute4, '''') 
					--AND ISNULL(b.attribute5, '''') = 	ISNULL(a.attribute5, '''')  
					WHERE b.buy_sell_flag = ''s'''
	EXEC spa_print @sql
	EXEC(@sql)
	
		--update lot for remaining 
		SET @sql = '--SELECT * 
					UPDATE a 
					SET a.lot = lot_cal.lot
					FROM ' + @lineup_vol_id_tbl + ' a
					INNER JOIN (
					SELECT  STUFF(
									(SELECT DISTINCT '','' +  CAST((lot_id) AS VARCHAR(1000))
									FROM #lot_collection inn
									WHERE 1 = 1 --AND inn.commodity_id = a.commodity_id
									FOR XML PATH (''''))
									, 1, 1, '''') lot, match_group_shipment_id--, commodity_id
								FROM #lot_collection a) lot_cal
						ON lot_cal.match_group_shipment_id = a.match_group_shipment_id
							--AND lot_cal.commodity_id = a.commodity_id
						WHERE a.buy_sell_flag = ''s''
							AND a.lot IS NULL
		'
		
		EXEC spa_print @sql
		EXEC(@sql)
	END
	 
	--EXEC('select *, lot, buy_sell_flag from ' + @lineup_vol_id_tbl)
	--return 

	--lot calcualtion end
	--*/
 
	DECLARE @min_volume VARCHAR(1000) 
	DECLARE @buy_sell_min_volume CHAR(1)
	
	SELECT TOP 1 @min_volume = SUM(total_volume), @buy_sell_min_volume = buy_sell_flag 
	FROM #max_rec_del_counterparty
	GROUP BY buy_sell_flag
	ORDER BY SUM(total_volume) 

	SELECT SUM(total_volume) total_volume, buy_sell_flag, commodity_id, COUNT(1) no_of_counts 
		, RANK() OVER(PARTITION BY commodity_id ORDER BY MIN(total_volume)) min_orders
		INTO #min_volumes_commodity
	FROM #max_rec_del_counterparty
	GROUP BY buy_sell_flag, commodity_id
	ORDER BY MIN(total_volume) 
	-- select @min_volume,@buy_sell_min_volume

 	--- update volume when 1 to 1 --support multiple single commodites
	IF NOT EXISTS (SELECT 1 FROM #min_volumes_commodity WHERE no_of_counts <> 1)
	BEGIN 
		SET @sql = '--select * 
				UPDATE a 
				SET a.vol = z.total_volume
				FROM ' + @lineup_vol_id_tbl + ' a
				INNER JOIN #min_volumes_commodity z ON z.commodity_id = a.commodity_id
					AND a.buy_sell_flag <> z.buy_sell_flag
				WHERE min_orders = 1 '
		EXEC spa_print @sql
		EXEC(@sql)
	END
	 

	--EXEC('select * from '  + @lineup_vol_id_tbl)
	IF @product_type = 1
	BEGIN 
		SET @sql = '	
					--select * 
					UPDATE w 
					SET vol = blending_quantity
						, quantity_total = CASE WHEN ''' + ISNULL(@sell_deals, '''''') + ''' = '''' AND ''' + @location_contract_commodity + ''' <> '''' THEN blending_quantity
											ELSE quantity_total END 
					FROM ' + @lineup_vol_id_tbl + ' w
					INNER JOIN (
						SELECT available_quantity * (ISNULL(blend_contribution/100, 1)) blending_quantity, commodity_id 
						FROM ' + @lineup_vol_id_tbl + ' a
						LEFT JOIN commodity_recipe_product_mix crpm ON crpm.recipe_commodity_id = a.commodity_id
							AND source_commodity_id = (SELECT commodity_id FROM ' + @lineup_vol_id_tbl + '
														WHERE buy_sell_flag = ''s'')
						CROSS APPLY (
							SELECT CASE WHEN ''' + ISNULL(@sell_deals, '''''') + ''' = '''' AND ''' + @location_contract_commodity + ''' <> '''' 
							THEN
								MAX((CAST(vol AS NUMERIC(38, 18)) * CASE WHEN blend_contribution IS NULL THEN 1 ELSE 100 END) / ISNULL(blend_contribution, 1)) 
							ELSE
								MIN((CAST(vol AS NUMERIC(38, 18)) * CASE WHEN blend_contribution IS NULL THEN 1 ELSE 100 END) / ISNULL(blend_contribution, 1)) 
							END 
							available_quantity
							FROM ' + @lineup_vol_id_tbl + '  a
							LEFT JOIN commodity_recipe_product_mix crpm ON crpm.recipe_commodity_id = a.commodity_id
							AND source_commodity_id = (SELECT commodity_id FROM ' + @lineup_vol_id_tbl + '
												WHERE buy_sell_flag = ''s'')) z
						) e ON w.commodity_id = e.commodity_id'
	
		EXEC spa_print @sql
		EXEC(@sql)
	END

	--1 to many case
	SET @sql = ' IF (SELECT COUNT(1) FROM ' + @lineup_vol_id_tbl + '
					WHERE buy_sell_flag = ''s'') = 1 
					AND (
					SELECT COUNT(1) FROM ' + @lineup_vol_id_tbl + '
					WHERE buy_sell_flag = ''b'') > 1
				BEGIN 
					UPDATE ' + @lineup_vol_id_tbl + '
					SET vol = CASE WHEN vol > ' + @min_volume + ' THEN ' + @min_volume + '  ELSE vol END
					WHERE buy_sell_flag <> ''' + @buy_sell_min_volume + '''
				END

				IF (SELECT COUNT(1) FROM ' + @lineup_vol_id_tbl + '
					WHERE buy_sell_flag = ''s'') > 1 
					AND (
					SELECT COUNT(1) FROM ' + @lineup_vol_id_tbl + '
					WHERE buy_sell_flag = ''b'') = 1
				BEGIN 
					UPDATE ' + @lineup_vol_id_tbl + '
					SET vol = CASE WHEN vol > ' + @min_volume + ' THEN ' + @min_volume + '  ELSE vol END
					WHERE buy_sell_flag <> ''' + @buy_sell_min_volume + '''
				END
				'
 	EXEC spa_print @sql
	EXEC(@sql)
	
	IF @get_group_id = 1 AND @bookout_match <> 'b'
	BEGIN
		IF @call_from = 'view_match_deal'
		BEGIN
			EXEC spa_scheduling_workbench  @flag='q',@process_id=@process_id,@buy_deals='',@sell_deals='',@convert_uom = @convert_uom
				,@convert_frequency='703',@mode='u',@location_id=NULL,@bookout_match='m',@contract_id=NULL,@commodity_name=NULL
				,@location_contract_commodity=NULL,@match_group_id=@match_group_shipment_id, @match_group_header_id = @match_group_id
				,@call_from=@call_from, @product_type = 1
		END
		ELSE
		BEGIN
			EXEC('SELECT TOP 1 match_group_id match_group_id FROM ' + @lineup_vol_id_tbl)
		END
	END
		
	IF @bookout_match = 'b'
	BEGIN 
		EXEC('SELECT TOP 1 MAX(bookoutid) bookoutid, MAX(lineup) lineup, SUM(vol) vol 
				FROM  ' + @lineup_vol_id_tbl + '
				GROUP BY buy_sell_flag
				ORDER BY vol' )
	END

END
IF @flag = 'z'  -- loading for match grid
BEGIN	
	SET @all_deal_coll_b_m = dbo.FNAProcessTableName('all_deals_b_m', @user_name, @process_id)

	SET @sql = ' IF OBJECT_ID(''' + @all_deal_coll_b_m + ''', ''U'') IS NOT NULL
					DROP TABLE ' + @all_deal_coll_b_m 
	
	EXEC spa_print @sql
	EXEC(@sql)
	
	IF OBJECT_ID('tempdb..#temp_data_deal_purchase_sell') IS NOT NULL 
		DROP TABLE #temp_data_deal_purchase_sell

	CREATE TABLE #temp_data_deal_purchase_sell(source_deal_header_id INT, source_deal_detail_id INT, buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT, deal_id VARCHAR(1000) COLLATE DATABASE_DEFAULT)


 	SET @sql = 'INSERT INTO #temp_data_deal_purchase_sell(source_deal_header_id, source_deal_detail_id, buy_sell_flag, deal_id)
				SELECT sdh.source_deal_header_id, sdd.source_deal_detail_id, sdd.buy_sell_flag, sdh.deal_id
				FROM source_deal_detail sdd 
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
				WHERE 1 = ' + CASE WHEN @purchase_deal_id_fil IS NOT NULL THEN  '1' ELSE '2' END +'
				' + CASE WHEN @purchase_deal_id_fil IS NOT NULL THEN ' AND sdh.deal_id LIKE ''%' + @purchase_deal_id_fil + '%'' AND sdd.buy_sell_flag = ''b''' ELSE '' END 
				+ CASE WHEN @sale_deal_id_fil IS NOT NULL 
				THEN 
				 'UNION ALL 
				 SELECT sdh.source_deal_header_id, sdd.source_deal_detail_id, sdd.buy_sell_flag, sdh.deal_id
					FROM source_deal_detail sdd 
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
					WHERE 1 = 1 AND  sdh.deal_id LIKE ''%' + @sale_deal_id_fil + '%'' AND sdd.buy_sell_flag = ''s''' ELSE '' END 
 
	EXEC spa_print @sql
	EXEC(@sql)
 		 
	--select * from #temp_data_deal_purchase_sell
	--return 

	DECLARE @purchase_sale_fil CHAR(1) = 'n'

	IF EXISTS(SELECT 1 FROM #temp_data_deal_purchase_sell)
	BEGIN 
		SET @purchase_sale_fil = 'y'
	END 

 	SET @sql = '
		SELECT 
			--shipment_information
			mgs.match_group_shipment_id
			, mgs.match_group_shipment
			, shipment_status.code  shipment_status
			, shipment_workflow_status.code shipment_workflow_status 
			--header
			, mgh.match_group_header_id
			, mgh.match_group_id
			, mgh.match_book_auto_id
			, ROUND(mgd.bookout_split_volume * ISNULL(conversion_factor, 1), 4) bookout_match_total_amount
			, CASE WHEN mgh.match_bookout = ''m'' THEN ''Match'' ELSE ''Bookout'' END match_bookout
			--, sml.location_name
			, CASE WHEN sml.Location_Name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smj.location_name IS NULL THEN '''' ELSE  '' ['' + smj.location_name + '']'' END location_name

			, mgh.scheduler
			, mgh.last_edited_by
			, mgh.last_edited_on
			, shipment_status_header.code header_status
			, mgh.scheduled_from
			, mgh.scheduled_to
			, mgh.match_number
			, mgh.comments
			, pipeline_cycle.code pipeline_cycle
			, consignee.counterparty_id consignee
			, carrier.counterparty_id carrier
			, mgh.po_number
			, container.container_name container
			, mgh.line_up
			, commodity.commodity_name 
				--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.value_id < 0 OR sdv_form.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv_form.code END 
				--+ '' | '' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = ''- Not Specified -'' THEN '''' ELSE commodity_origin_id.code END		
				--+ '' |'' + CASE WHEN mgh.organic IS NULL OR mgh.organic = '''' OR mgh.organic = ''n'' THEN '''' ELSE '' Organic'' END 		
				--+ CASE WHEN sdv1.code IS NULL OR sdv1.value_id < 0 OR sdv1.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv1.code END  
				--+ CASE WHEN sdv2.code IS NULL OR sdv2.value_id < 0 OR sdv2.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv2.code END  
				--+ CASE WHEN sdv3.code IS NULL OR sdv3.value_id < 0 OR sdv3.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv3.code END  
				--+ CASE WHEN sdv4.code IS NULL OR sdv4.value_id < 0 OR sdv4.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv4.code END  
				--+ CASE WHEN sdv5.code IS NULL OR sdv5.value_id < 0 OR sdv5.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv5.code END  
				  product
			, NULL commodity_origin_id--commodity_origin_id.code commodity_origin_id
			, NULL commodity_form_id--commodity_form_id.commodity_form_description commodity_form_id
			, NULL commodity_form_attribute1--ISNULL(cafd1.commodity_name, '''') + '' '' + ISNULL(cafd1.commodity_form_name, '''') commodity_form_attribute1
			, NULL commodity_form_attribute2--ISNULL(cafd2.commodity_name, '''') + '' '' + ISNULL(cafd2.commodity_form_name, '''') commodity_form_attribute2
			, NULL commodity_form_attribute3--ISNULL(cafd3.commodity_name, '''') + '' '' + ISNULL(cafd3.commodity_form_name, '''') commodity_form_attribute3
			, NULL commodity_form_attribute4--ISNULL(cafd4.commodity_name, '''') + '' '' + ISNULL(cafd4.commodity_form_name, '''') commodity_form_attribute4
			, NULL commodity_form_attribute5--ISNULL(cafd5.commodity_name, '''') + '' '' + ISNULL(cafd5.commodity_form_name, '''') commodity_form_attribute5
			, NULL organic--ISNULL(mgh.organic, ''n'') organic
			, mgh.estimated_movement_date
			, mgh.est_movement_date_to
			--detail
			, mgd.match_group_detail_id
			, CAST(sdh.source_deal_header_id AS VARCHAR(1000)) + '' [''+ sdh.deal_id + '']'' deal_id
			, mgd.bookout_split_volume * ISNULL(conversion_factor, 1) bookout_split_volume
			, mgd.quantity * ISNULL(conversion_factor, 1)  act_vol
			, mgd.bookout_split_volume * ISNULL(conversion_factor, 1) - CASE WHEN mgh.match_bookout = ''b'' OR mgs.shipment_status = 47007 THEN mgd.bookout_split_volume * ISNULL(conversion_factor, 1) ELSE ISNULL(mgd.quantity, 0) * ISNULL(conversion_factor, 1)  END unmoved_amt
			, mgd.source_commodity_id
			, mgd.scheduling_period
			, mgd.notes
			, mgd.source_deal_detail_id
			, mgd.split_deal_detail_volume_id
			, mgd.lot
			, CAST(mgd.batch_id AS VARCHAR(1000)) batch_id
			, detail_inco_terms.code incoterm
			, crop_year.code crop_year
			, sc.counterparty_id
			, sdt.source_deal_type_name											 
			, CASE WHEN mgh.match_bookout = ''b'' THEN ''Yes'' ELSE CASE WHEN mgd.is_complete = 0 THEN ''No'' ELSE ''Yes'' END END is_complete
			, mgd.frequency							 
			, sml.region				
			, commodity.commodity_group1	
			, sdt.source_deal_type_id		
			, sdd.buy_sell_flag	 
			, mgh.container_number
			, su.uom_name
			, commodity.commodity_name
			, sml.source_minor_location_id
			, mgs.match_group_shipment shipment_name
			, mgd.match_group_header_id deal_volume_split_id
			, sdd.total_volume * ISNULL(conversion_factor, 1)  deal_volume
			, sdd.fixed_price
			, mgd.is_parent
			, sdh.deal_sub_type_type_id
			, mgs.shipment_status shipment_status_id
			, detail_inco_terms.value_id incoterm_id
			, cc.name scheduler_name	
			, cg.contract_name
			, mgh.seq_no match_order_sequence
			, au.user_f_name + '' '' + CASE WHEN user_m_name IS NULL OR user_m_name = '''' THEN '''' ELSE user_m_name + '' '' END + ISNULL(user_l_name, '''') create_user
 			INTO  ' + @all_deal_coll_b_m  + '												 
	FROM match_group_detail mgd
	
	INNER JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id
		' + CASE WHEN @match_group_header_id IS NOT NULL THEN ' AND mgh.match_group_header_id = ' + CAST(@match_group_header_id AS VARCHAR(1000)) + ''
		ELSE '' END + '
	INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = mgd.split_deal_detail_volume_id
	INNER JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = mgh.match_group_shipment_id
	INNER JOIN match_group mg ON mgs.match_group_id = mg.match_group_id
	INNER JOIN source_deal_detail sdd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
	' + CASE WHEN @purchase_sale_fil = 'y' THEN ' INNER JOIN #temp_data_deal_purchase_sell tddps ON tddps.source_deal_detail_id = mgd.source_deal_detail_id 
		AND sdd.buy_sell_flag = tddps.buy_sell_flag' ELSE '' END + '

	INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN match_group_deal_status mgds ON mgds.value_id = mgs.shipment_workflow_status
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = mgh.source_minor_location_id 
	LEFT JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
	LEFT JOIN source_commodity commodity ON commodity.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
	LEFT JOIN commodity_type ct ON ct.commodity_type_id = commodity.commodity_type
	LEFT JOIN static_data_value sdt_prod_type ON ct.category_id = sdt_prod_type.value_id
		AND sdt_prod_type.type_id = 108400
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN source_uom su ON su.source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id) 
	LEFT JOIN contract_group cg ON 	cg.contract_id = sdh.contract_id			
	/*
	LEFT JOIN commodity_origin co ON co.commodity_origin_id = mgh.commodity_origin_id
	LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
		AND type_id = 14000
				
	LEFT JOIN commodity_form cf ON cf.commodity_form_id = mgh.commodity_form_id
	LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
	LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = commodity_form_id.commodity_form_value
				
	LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = mgh.commodity_form_attribute1
	LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
		AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value

	LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id = mgh.commodity_form_attribute2 
	LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
		AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
	LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

	LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = mgh.commodity_form_attribute3
	LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
		AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
	LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

	LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = mgh.commodity_form_attribute4
	LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
		AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
	LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

	LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = mgh	.commodity_form_attribute5
	LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
		AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
	LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value
	*/
	LEFT JOIN static_data_value detail_inco_terms ON detail_inco_terms.value_id = sdd.detail_inco_terms
		--AND detail_inco_terms.type_id = 40200
	LEFT JOIN static_data_type sdt_inco ON sdt_inco.type_id = detail_inco_terms.type_id
		AND sdt_inco.type_name = ''INCOTerms''
	LEFT JOIN static_data_value crop_year ON crop_year.value_id = mgd.crop_year
		AND crop_year.type_id = 10092
	LEFT JOIN static_data_value shipment_workflow_status ON shipment_workflow_status.value_id = mgs.shipment_workflow_status
	LEFT JOIN static_data_value pipeline_cycle ON pipeline_cycle.value_id = mgh.pipeline_cycle
		AND pipeline_cycle.type_id = 41000
	LEFT JOIN source_counterparty consignee ON consignee.source_counterparty_id = mgh.consignee
	LEFT JOIN source_container container ON container.source_container_id = mgh.container
	LEFT JOIN source_counterparty carrier ON carrier.source_counterparty_id = mgh.carrier
	LEFT JOIN #quantity_conversion qc  ON qc.from_source_uom_id = su.source_uom_id

	LEFT JOIN counterparty_contacts cc ON cc.counterparty_contact_id = mgh.scheduler
	LEFT JOIN static_data_value shipment_status ON shipment_status.value_id = mgs.shipment_status AND shipment_status.type_id = 47000
 	LEFT JOIN static_data_value shipment_status_header ON shipment_status_header.value_id = mgh.status AND shipment_status_header.type_id = 47000
	LEFT JOIN application_users au ON au.user_login_id = mgs.create_user
	WHERE 1 = 1		
		AND ISNULL(sdt_prod_type.code, ''Fungible'') = ''Fungible''  
		AND mgd.is_complete = ' + CASE WHEN @match_status = 'a' THEN '0'
								WHEN @match_status = 'c' THEN '1'
								ELSE 'mgd.is_complete' END			
	 
	IF @match_group_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND mgh.match_group_header_id=' + CAST(@match_group_header_id AS VARCHAR(1000))
	END

	--IF @call_from ='actulize'
	--	SET @sql = @sql + ' AND sdt.deal_type_id <> ''Transportation'''
					
	EXEC spa_print @sql
	EXEC(@sql)
		 
	SET @sql = ' SELECT ' + CASE WHEN @grid_name = 'MatchGroupShipment' THEN ' DISTINCT match_group_shipment_id
																				, match_group_shipment
																				, shipment_status
																				, shipment_workflow_status
																				, match_group_id
																				, CASE WHEN is_parent = ''y'' THEN ''Yes'' ELSE ''No'' END is_parent	
																					 																
																				'

									WHEN @grid_name = 'MatchGroupHeader' THEN ' DISTINCT MAX(match_group_header_id) match_group_header_id
																				, MAX(match_group_id) match_group_id
																				, MAX(match_bookout) match_bookout
																				, MAX(match_book_auto_id) match_book_auto_id
																				, dbo.FNAAddThousandSeparator(SUM(ROUND(ISNULL(act_vol, bookout_match_total_amount), 2))) bookout_match_total_amount																			
																				, MAX(location_name) location_name
																				, MAX(scheduler_name) scheduler
																				, MAX(last_edited_by) last_edited_by
																				, MAX(dbo.FNADateFormat(last_edited_on)) last_edited_on
																				, MAX(header_status) header_status
																				, MAX(dbo.FNADateFormat(scheduled_from)) scheduled_from
																				, MAX(dbo.FNADateFormat(scheduled_to)) scheduled_to
																				, MAX(match_number) match_number
																				, MAX(comments) comments
																				, MAX(pipeline_cycle) pipeline_cycle
																				, MAX(consignee) consignee
																				, MAX(carrier) carrier
																				, MAX(po_number) po_number
																				, MAX(container) container
																				, MAX(line_up) line_up
																				, MAX(product) product
																				, MAX(dbo.FNADateFormat(estimated_movement_date)) estimated_movement_date
																				, MAX(dbo.FNADateFormat(est_movement_date_to)) est_movement_date_to
																				, MAX(container_number) container_number
																				, adc.buy_sell_flag
																				 
																					'

									WHEN @grid_name = 'MatchGroupDetail' THEN ' match_group_detail_id
																			, deal_id
																			, location_name
																			, contract_name
																			, commodity_name
																			, dbo.FNAAddThousandSeparator(ROUND(bookout_split_volume, 2)) bookout_split_volume
																			, dbo.FNAAddThousandSeparator(ROUND(act_vol, 2)) act_vol
																			, dbo.FNAAddThousandSeparator(unmoved_amt) unmoved_amt
																			, source_commodity_id
																			, scheduling_period
																			, notes
																			, source_deal_detail_id
																			, split_deal_detail_volume_id
																			, lot
																			, CASE WHEN batch_id = ''-1'' THEN '''' ELSE batch_id END batch_id
																			, incoterm
																			, crop_year
																			, counterparty_id
																			, source_deal_type_name											 
																			, is_complete
																			, frequency							 
																			, region
																			, match_group_id
																			, adc.buy_sell_flag																			
																			
																			'
							ELSE '*' END
							+ ' INTO #final_table 
							FROM  ' + @all_deal_coll_b_m + ' adc '


	--filters
	+ CASE WHEN @location IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @location + ''', '','')) location ON location.item = adc.source_minor_location_id ' ELSE '' END 
	+ CASE WHEN @loc_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @loc_group + ''', '','')) loc_group ON loc_group.item = adc.region ' ELSE '' END 
	+ CASE WHEN @commodity IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity + ''', '','')) commodity ON commodity.item = adc.source_commodity_id '  ELSE '' END 
	+ CASE WHEN @deal_type IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @deal_type + ''', '','')) deal_type ON deal_type.item = adc.source_deal_type_id '  ELSE '' END 
	+ CASE WHEN @commodity_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_group + ''', '','')) commodity_group ON commodity_group.item = adc.commodity_group1 '  ELSE '' END 
		-- added filters
	+ CASE WHEN @commodity_origin_id IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_origin_id + ''', '','')) commodity_origin_id ON commodity_origin_id.item = adc.filter_commodity_origin_id ' ELSE '' END 
	+ CASE WHEN @commodity_form_id IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_id + ''', '','')) commodity_form_id ON commodity_form_id.item = adc.filter_commodity_form_id ' ELSE '' END 
	+ CASE WHEN @commodity_form_attribute1 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute1 + ''', '','')) commodity_form_attribute1 ON commodity_form_attribute1.item = adc.filter_sdd_commodity_form_attribute1 ' ELSE '' END 
	+ CASE WHEN @commodity_form_attribute2 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute2 + ''', '','')) commodity_form_attribute2 ON commodity_form_attribute2.item = adc.filter_sdd_commodity_form_attribute2 ' ELSE '' END 
	+ CASE WHEN @commodity_form_attribute3 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute3 + ''', '','')) commodity_form_attribute3 ON commodity_form_attribute3.item = adc.filter_sdd_commodity_form_attribute3 ' ELSE '' END 
	+ CASE WHEN @commodity_form_attribute4 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute4 + ''', '','')) commodity_form_attribute4 ON commodity_form_attribute4.item = adc.filter_sdd_commodity_form_attribute4 ' ELSE '' END 
	+ CASE WHEN @commodity_form_attribute5 IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_form_attribute5 + ''', '','')) commodity_form_attribute5 ON commodity_form_attribute5.item = adc.filter_sdd_commodity_form_attribute5 ' ELSE '' END 
	+ CASE WHEN @organic IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @organic + ''', '','')) organic ON ' + CASE WHEN @organic = 'b' THEN 'adc.organic' ELSE 'organic.item' END + ' = adc.organic ' ELSE '' END 
	+ CASE WHEN @sub_deal_type IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @sub_deal_type + ''', '','')) sub_deal_type ON sub_deal_type.item = adc.deal_sub_type_type_id ' ELSE '' END 							
	+ CASE WHEN @lot IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @lot + ''', '','')) lot ON lot.item = adc.lot ' ELSE '' END 	
	+ CASE WHEN @schedule_match_status IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @schedule_match_status + ''', '','')) schedule_match_status ON schedule_match_status.item = adc.shipment_status_id ' ELSE '' END 							
  								
	SET @sql = @sql 
				+ ' WHERE 1 = 1 '

	IF @period_from IS NOT NULL
		SET @sql = @sql + ' AND ''' + CAST(@period_from AS VARCHAR(12)) + '''  <= adc.scheduled_to '
				
	IF @period_to IS NOT NULL		
		SET @sql = @sql + ' AND ''' + CAST(@period_to AS VARCHAR(12)) + ''' >= adc.scheduled_from '
	
	IF @match_group_shipment_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND match_group_shipment_id=' + @match_group_shipment_id
	END

	IF @match_group_header_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND match_group_header_id=' + CAST(@match_group_header_id AS VARCHAR(1000))
	END

	IF @grid_name = 'MatchGroupHeader' 
	BEGIN 
		SET @sql = @sql + ' GROUP BY match_group_header_id, adc.buy_sell_flag '
	END

	SET @sql = @sql + ' SELECT ' + CASE WHEN @grid_name = 'MatchGroupHeader' THEN ' match_group_header_id  match_group_header_id
																				, MAX(match_group_id) match_group_id
																				, MAX(match_bookout) match_bookout
																				, MAX(match_book_auto_id) match_book_auto_id
																				, MAX(bookout_match_total_amount) bookout_match_total_amount																			
																				, MAX(location_name) location_name
																				, MAX(scheduler) scheduler
																				, MAX(last_edited_by) last_edited_by
																				, MAX(last_edited_on) last_edited_on
																				, MAX(header_status) header_status
																				, MAX(scheduled_from) scheduled_from
																				, MAX(scheduled_to) scheduled_to
																				, MAX(match_number) match_number
																				, MAX(comments) comments
																				, MAX(pipeline_cycle) pipeline_cycle
																				, MAX(consignee) consignee
																				, MAX(carrier) carrier
																				, MAX(po_number) po_number
																				, MAX(container) container
																				, MAX(line_up) line_up
																				, MAX(product) product
																				, MAX(estimated_movement_date) estimated_movement_date
																				, MAX(est_movement_date_to) est_movement_date_to
																				, MAX(container_number) container_number
																				' ELSE '*' END + ' 
				FROM #final_table 
				'	+ CASE WHEN @grid_name = 'MatchGroupHeader' THEN ' GROUP BY match_group_header_id ' ELSE '' END 		

	SET @sql = @sql + ' ORDER BY ' + CASE WHEN @grid_name = 'MatchGroupShipment' THEN ' match_group_shipment_id DESC' ELSE ' match_group_id DESC ' END
	
	IF @grid_name = 'MatchGroupDetail' --OR @grid_name = 'MatchGroupHeader'
	BEGIN 
		SET @sql = @sql + ', buy_sell_flag'
	END
								
	EXEC spa_print @sql	 
		
	IF @to_select = 'y'
		EXEC(@sql)	
END 
ELSE IF @flag = 'y' -- insert actual volume	
BEGIN 
	BEGIN TRY
		BEGIN TRAN
		CREATE TABLE #actual_vol_xml_data (row_id INT IDENTITY(1, 1), source_deal_detail_id INT, deal_volume_split_id INT
											, actual_volume NUMERIC(38, 10), is_complete INT)
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value
	
		INSERT INTO #actual_vol_xml_data(source_deal_detail_id, deal_volume_split_id, actual_volume, is_complete)
		SELECT source_deal_detail_id, deal_volume_split_id, actual_volume, is_complete
		FROM   OPENXML (@idoc, '/gridXml/GridRow', 2)
				WITH ( 
					source_deal_detail_id INT '@detail_id',						
					actual_volume  NUMERIC(38,10) '@actual_volume',
					deal_volume_split_id INT '@split_id',
					is_complete INT '@is_complete')

		EXEC sp_xml_removedocument @idoc

		MERGE match_group_detail AS T
		USING #actual_vol_xml_data AS S
		ON (T.source_deal_detail_id = S.source_deal_detail_id
			AND T.split_id = S.deal_volume_split_id) 
		WHEN NOT MATCHED BY TARGET 
			THEN INSERT(source_deal_detail_id, split_id, quantity, is_complete) 
			VALUES(s.source_deal_detail_id, s.deal_volume_split_id, s.actual_volume, ISNULL(s.is_complete, 0))
		WHEN MATCHED 
			THEN UPDATE SET T.quantity = S.actual_volume,
							T.is_complete = S.is_complete;


		UPDATE sdd
		SET sdd.deal_volume = a.deal_volume, 
			sdd.deal_volume_frequency = 't'
		FROM source_deal_detail sdd
		INNER JOIN (
		SELECT CASE WHEN MAX(dvsa.is_complete) = 0 THEN SUM(dvs_from.bookout_amt) ELSE SUM(dvsa.actual_volume) END deal_volume, dvs_from.source_deal_detail_id_from  source_deal_detail_id
		FROM  deal_volume_split_actual dvsa 
		INNER JOIN deal_volume_split dvs_from ON dvs_from.deal_volume_split_id = dvsa.deal_volume_split_id
			AND dvs_from.source_deal_detail_id_from = dvsa.source_deal_detail_id 
			WHERE dvsa.source_deal_detail_id IN (SELECT source_deal_detail_id FROM #actual_vol_xml_data)
		GROUP BY dvs_from.source_deal_detail_id_from) a ON sdd.source_deal_detail_id = a.source_deal_detail_id 

		--delivery
		UPDATE sdd
		SET sdd.deal_volume = a.deal_volume, 
			sdd.deal_volume_frequency = 't'
		FROM source_deal_detail sdd
		INNER JOIN (
		SELECT CASE WHEN MAX(dvsa.is_complete) = 0 THEN SUM(dvs_to.bookout_amt) ELSE SUM(dvsa.actual_volume) END deal_volume, dvs_to.source_deal_detail_id_to  source_deal_detail_id
		FROM  deal_volume_split_actual dvsa 
		INNER JOIN deal_volume_split dvs_to ON dvs_to.deal_volume_split_id = dvsa.deal_volume_split_id
			AND dvs_to.source_deal_detail_id_to = dvsa.source_deal_detail_id 
			WHERE dvsa.source_deal_detail_id IN (SELECT source_deal_detail_id FROM #actual_vol_xml_data)
		GROUP BY dvs_to.source_deal_detail_id_to) a ON sdd.source_deal_detail_id = a.source_deal_detail_id 
		
		COMMIT TRAN
		EXEC spa_ErrorHandler 0,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Success',
				'Changes has been saved successfully.',
				''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler @@ERROR,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Fail to Bookout deals.',
				''
	END CATCH
END 
ELSE IF @flag = 'r'--remove shipment
BEGIN 
	SELECT mgd.split_deal_detail_volume_id, mgd.match_group_detail_id, mgh.match_group_header_id, mgs.match_group_shipment_id
		, mg.match_group_id,  sdd.term_start , mgh.source_minor_location_id
		, sdt.deal_type_id, sdh.source_deal_header_id, sdh.contract_id, mgd.source_deal_detail_id, mgd.is_parent
		, mgs.shipment_status, sddv.quantity, 'n' has_storage_child
		INTO #to_delete_ids 
	FROM match_group mg
	INNER JOIN match_group_shipment mgs ON mgs.match_group_id = mg.match_group_id
	INNER JOIN dbo.FNASplit(@match_group_shipment_id, ',') fil ON fil.item = mgs.match_group_shipment_id
	LEFT JOIN match_group_header mgh ON mgh.match_group_shipment_id = mgs.match_group_shipment_id
		AND mgh.match_group_id = mgs.match_group_id
	LEFT JOIN match_group_detail mgd ON mgd.match_group_header_id =  mgh.match_group_header_id 
		AND  mgd.match_group_shipment_id = mgs.match_group_shipment_id
	LEFT JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = mgd.split_deal_detail_volume_id
		AND sddv.source_deal_detail_id = mgd.source_deal_detail_id
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
	LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
	
	IF EXISTS(SELECT 1 FROM #to_delete_ids tdi 
			INNER JOIN ticket_match tm ON tm.match_group_header_id = tdi.match_group_header_id)
	BEGIN 
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'The shipment is already actualized. Please un-actualize the shipment to proceed.',
				''
		RETURN
	END

	IF EXISTS(SELECT 1 FROM #to_delete_ids tdi 
				WHERE shipment_status IN (47007, 47006, 47001, 47004, 47003, 47005, 47002, 47008))
	BEGIN 
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Cannot unmatch shipment that has been live or completed.',
				''
		RETURN
	END
	
	--check for invoice
	IF EXISTS(SELECT 1 FROM dbo.FNASplit(@match_group_shipment_id, ',') ids
			INNER JOIN (
				SELECT 
					   MAX(cit.shipment_id) match_group_shipment_id
				FROM calc_invoice_volume_variance civv
				OUTER APPLY (
					SELECT MAX(civv2.as_of_date) max_as_of_date, cit.shipment_id
					FROM   calc_invoice_volume_variance civv2
					INNER JOIN calc_invoice_ticket cit ON  civv2.calc_id = cit.calc_id
					WHERE  civv.counterparty_id = civv2.counterparty_id
						AND civv.contract_id = civv2.contract_id
						AND civv.prod_date = civv2.prod_date
						AND civv.prod_date_to = civv2.prod_date_to
					GROUP BY cit.shipment_id
				) t
				INNER JOIN calc_invoice_ticket cit ON  civv.calc_id = cit.calc_id 
					AND cit.shipment_id = t.shipment_id
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id
				LEFT JOIN dbo.FNASplit(@match_group_shipment_id, ',') ids ON ids.item = cit.shipment_id
				WHERE  civv.as_of_date = t.max_as_of_date
					--AND cit.shipment_id = ISNULL(@match_group_shipment_id, cit.shipment_id)
				GROUP BY
					   civv.calc_id
					  , civv.counterparty_id
					  , civv.prod_date
					  , civv.prod_date_to) invoice ON invoice.match_group_shipment_id = ids.item)
	BEGIN 
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'The shipment has invoice mapped. Please remove invoice from the shipment to proceed.',
				''
		RETURN
	END 	
	
	DECLARE @to_delete_deal_ids VARCHAR(MAX)
	DECLARE @is_parent CHAR(1)
	--cursor start
	BEGIN TRY
		BEGIN TRAN

		DECLARE @cur_delete_shipment INT
		DECLARE @get_cur_delete_shipment CURSOR
		SET @get_cur_delete_shipment = CURSOR FOR
		SELECT match_group_shipment_id
		FROM #to_delete_ids
		GROUP BY match_group_shipment_id
		OPEN @get_cur_delete_shipment
		FETCH NEXT
		FROM @get_cur_delete_shipment INTO @cur_delete_shipment
		WHILE @@FETCH_STATUS = 0
		BEGIN
		PRINT @cur_delete_shipment

			IF OBJECT_ID('tempdb..#volume_to_add_to_parent_split') IS NOT NULL 
				DROP TABLE #volume_to_add_to_parent_split

			SELECT MAX(sddv.split_deal_detail_volume_id) split_deal_detail_volume_id, sddv.source_deal_detail_id, SUM(sddv.quantity) quantity, MAX(sddv.is_parent) is_parent, MAX(match_group_shipment_id) match_group_shipment_id
				INTO #volume_to_add_to_parent_split 
			FROM #to_delete_ids tdi 
			INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = tdi.split_deal_detail_volume_id
			WHERE tdi.match_group_shipment_id = @cur_delete_shipment
			GROUP BY sddv.source_deal_detail_id 
	
			SELECT TOP 1 @is_parent = is_parent FROM #to_delete_ids 
			WHERE is_parent = 'y'
				AND match_group_shipment_id = @cur_delete_shipment

			IF OBJECT_ID('tempdb..#new_parent_id') IS NOT NULL 
				DROP TABLE #new_parent_id

			SELECT DISTINCT mgs.match_group_shipment_id
				INTO #new_parent_id
			FROM #to_delete_ids ids
			INNER JOIN match_group_shipment mgs ON ids.match_group_shipment_id = mgs.parent_shipment_id
			INNER JOIN match_group_detail mgd ON mgd.match_group_shipment_id = mgs.match_group_shipment_id
			WHERE 1 = 1 AND ids.match_group_shipment_id = @cur_delete_shipment
			ORDER BY mgs.match_group_shipment_id

			IF EXISTS(SELECT 1 FROM #new_parent_id)
			BEGIN 
				UPDATE #to_delete_ids SET has_storage_child = 'y' 
				WHERE 1 = 1 AND match_group_shipment_id = @cur_delete_shipment
 			END

			IF @is_parent = 'y'
			BEGIN				
				--insert to delete amount
				IF EXISTS(SELECT 1 FROM match_group_detail mgd
						INNER JOIN #new_parent_id a ON a.match_group_shipment_id = mgd.match_group_shipment_id
				)
				BEGIN 					
					--select * 
					UPDATE mgs
					SET mgs.parent_shipment_id = NULL 
					FROM #new_parent_id npi
					INNER JOIN  match_group_shipment mgs ON npi.match_group_shipment_id = mgs.match_group_shipment_id
				
					-- set all child as parent 
					UPDATE mgd
					SET mgd.is_parent = 'y'
					FROM match_group_detail mgd
					INNER JOIN #new_parent_id a ON a.match_group_shipment_id = mgd.match_group_shipment_id
				
					--reset old parent as child
					--select * 
					UPDATE mgd
					SET is_parent = 'n'
					FROM match_group_detail mgd
					INNER JOIN #to_delete_ids ids ON ids.match_group_shipment_id = mgd.match_group_shipment_id
					WHERE ids.match_group_shipment_id = @cur_delete_shipment
				 
					--update volume to parent
					--SELECT * 
					UPDATE sddv 
					SET sddv.quantity = sddv.quantity + tdi.quantity
					FROM #to_delete_ids tdi
					INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = tdi.source_deal_detail_id
						AND sddv.is_parent = 'y'
					WHERE tdi.match_group_shipment_id = @cur_delete_shipment
				END
				ELSE
				BEGIN
					UPDATE sddv
					SET sddv.quantity = CASE WHEN tdi.is_parent = 'y' THEN sddv.quantity ELSE sddv.quantity + tdi.quantity END
					--SELECT sddv.quantity + tdi.quantity, sddv.quantity , tdi.quantity
					FROM #volume_to_add_to_parent_split tdi 
					INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = tdi.source_deal_detail_id
						AND sddv.is_parent = 'y'
					WHERE tdi.match_group_shipment_id = @cur_delete_shipment
				END 
			END
			ELSE
			BEGIN
				UPDATE sddv
				SET sddv.quantity = sddv.quantity + tdi.quantity
				--SELECT sddv.quantity + tdi.quantity, sddv.quantity , tdi.quantity
				FROM #volume_to_add_to_parent_split tdi 
				INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = tdi.source_deal_detail_id
					AND sddv.is_parent = 'y' 
				WHERE tdi.match_group_shipment_id = @cur_delete_shipment
			END
							
			--/*			  
			SELECT @to_delete_deal_ids = STUFF((
									SELECT DISTINCT ',' + CAST(sdh.source_deal_header_id AS VARCHAR(1000))
									FROM #to_delete_ids tdi
									INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tdi.source_deal_detail_id
									INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
									WHERE tdi.deal_type_id IN ('Storage', 'Transportation')
													AND has_storage_child = 'n'
													AND tdi.match_group_shipment_id = @cur_delete_shipment
												FOR XML PATH('')), 1, 1, '')



			-- for sale deals only 
			UPDATE sdd
			SET lot = NULL
			FROM #to_delete_ids tdi
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tdi.source_deal_detail_id
			WHERE sdd.buy_sell_flag = 's'
				AND tdi.has_storage_child = 'n'
				AND tdi.match_group_shipment_id = @cur_delete_shipment

			DELETE sds
			FROM source_deal_settlement sds
			INNER JOIN #to_delete_ids tdi ON tdi.source_deal_header_id = sds.source_deal_header_id	
				AND sds.as_of_date = tdi.term_start
				AND tdi.term_start = sds.as_of_date
			WHERE  tdi.deal_type_id = 'Storage'
				AND tdi.has_storage_child = 'n'
				AND tdi.match_group_shipment_id = @cur_delete_shipment
 
			--SELECT * 
			DELETE csw
			FROM calcprocess_storage_wacog csw
			INNER JOIN #to_delete_ids tdi ON tdi.source_minor_location_id = csw.location_id	
				AND csw.contract_id =  tdi.contract_id  
				AND tdi.term_start = csw.term
			WHERE  tdi.deal_type_id = 'Storage'
				AND tdi.has_storage_child = 'n'
				AND tdi.match_group_shipment_id = @cur_delete_shipment
			
			DELETE mgd
			--SELECT * 
			FROM match_group_detail mgd
			INNER JOIN #to_delete_ids tdi ON tdi.match_group_detail_id = mgd.match_group_detail_id
			WHERE tdi.match_group_shipment_id = @cur_delete_shipment

			--select @to_delete_deal_ids
			IF @to_delete_deal_ids IS NOT NULL
			BEGIN 
				IF NOT EXISTS(SELECT 1 FROM #new_parent_id)
				BEGIN 
					EXEC spa_source_deal_header @flag ='d',@deal_ids=@to_delete_deal_ids,@comments='', @call_from = 'scheduling', @call_from_import = 'y'
				END
			END

			--SELECT *
			DELETE sddv
			FROM #to_delete_ids tdi 
			INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = tdi.split_deal_detail_volume_id
				AND sddv.is_parent <> 'y'
			WHERE tdi.match_group_shipment_id = @cur_delete_shipment							

			--select * 
			DELETE sddv
			FROM #to_delete_ids ids
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ids.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
			INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = sdd.source_deal_detail_id
				AND ids.split_deal_detail_volume_id = sddv.split_deal_detail_volume_id
			INNER JOIN source_deal_type main ON main.source_deal_type_id = sdh.source_deal_type_id
			INNER JOIN source_deal_type sub ON sub.source_deal_type_id = sdh.deal_sub_type_type_id
			WHERE main.deal_type_id IN ('Storage', 'Transportation')
				AND ids.match_group_shipment_id = @cur_delete_shipment

			--SELECT *
			DELETE tm 
			FROM ticket_match tm
			INNER JOIN #to_delete_ids tdi ON tdi.match_group_header_id = tm.match_group_header_id
			WHERE tdi.match_group_shipment_id = @cur_delete_shipment
										
			--SELECT * 
			DELETE mgh
			FROM match_group_header mgh
			INNER JOIN #to_delete_ids tdi ON tdi.match_group_header_id = mgh.match_group_header_id
 			WHERE tdi.match_group_shipment_id = @cur_delete_shipment

			--SELECT * 
			DELETE mgs
			FROM match_group_shipment mgs
			INNER JOIN #to_delete_ids tdi ON tdi.match_group_shipment_id = mgs.match_group_shipment_id
			WHERE tdi.match_group_shipment_id = @cur_delete_shipment

 
			--delete this if no shipent is available for the group
			IF NOT EXISTS(SELECT 1 
							FROM match_group mgd
							INNER JOIN #to_delete_ids tdi ON tdi.match_group_id = mgd.match_group_id	
							INNER JOIN match_group_shipment mgs ON mgs.match_group_id = mgd.match_group_id		
							WHERE tdi.match_group_shipment_id = @cur_delete_shipment
	 					
			)
			BEGIN 
				DELETE mgd
				FROM match_group mgd
				INNER JOIN #to_delete_ids tdi ON tdi.match_group_id = mgd.match_group_id
				WHERE tdi.match_group_shipment_id = @cur_delete_shipment
	
			END 

			--remove data if only parent data is available
			IF EXISTS(SELECT MAX(sddv.split_deal_detail_volume_id) 
					FROM #to_delete_ids tdi 
					INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = tdi.source_deal_detail_id
					WHERE tdi.match_group_shipment_id = @cur_delete_shipment
					GROUP BY sddv.source_deal_detail_id
					HAVING COUNT(sddv.source_deal_detail_id) = 1)
			BEGIN 
				DELETE FROM split_deal_detail_volume WHERE split_deal_detail_volume_id IN (SELECT MAX(sddv.split_deal_detail_volume_id) 
																							FROM #to_delete_ids tdi 
																							INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = tdi.source_deal_detail_id
																							WHERE tdi.match_group_shipment_id = @cur_delete_shipment
																							GROUP BY sddv.source_deal_detail_id
																							HAVING COUNT(sddv.source_deal_detail_id) = 1)
			END

		FETCH NEXT
		FROM @get_cur_delete_shipment INTO @cur_delete_shipment
		END
		CLOSE @get_cur_delete_shipment
		DEALLOCATE @get_cur_delete_shipment

		SET @alert_process_table = 'adiha_process.dbo.alert_scheduling_' + @jobs_process_id + '_as'
			
		EXEC ('CREATE TABLE ' + @alert_process_table + '(
					mgs_match_group_shipment_id		INT
				)')
 			   
		SET @sql = 'INSERT INTO ' + @alert_process_table + ' (
 						mgs_match_group_shipment_id
 						)
 					SELECT DISTINCT st.match_group_shipment_id
 					FROM #to_delete_ids st'

		EXEC spa_print @sql		
		EXEC(@sql)
 		
		SET @sql = 'spa_register_event 20611, 20532, ''' + @alert_process_table + ''', 1, ''' + @jobs_process_id + ''''
		
		SET @job_name = 'scheduling_alert_job_delete_' + @jobs_process_id
		EXEC spa_run_sp_as_job @job_name, @sql, 'scheduling_alert_job', @user_name

		COMMIT TRAN
		
		--rollback tran 
		--return
		EXEC spa_ErrorHandler 0,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Success',
				'Changes has been saved successfully.',
				''
	END TRY
	BEGIN CATCH
		--end flag r
		--SELECT  ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Fail to remove Bookout.',
				''
	END CATCH
	--*/
END
ELSE IF @flag = 'm' -- for match grid (match.php)
BEGIN 
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)
	
	IF OBJECT_ID('tempdb..#temp_data_for_purchase') IS NOT NULL
		DROP TABLE #temp_data_for_purchase

	IF OBJECT_ID('tempdb..#pre_detail_data_coll') IS NOT NULL
	BEGIN 
		DROP TABLE #pre_detail_data_coll
	END 
	SET @sql = 'UPDATE ' + @match_properties + ' SET lot = NULL WHERE lot = ''NULL'''
	EXEC(@sql)


	CREATE TABLE #pre_detail_data_coll(purchase_deal_reference_id				VARCHAR(MAX) COLLATE DATABASE_DEFAULT
										 , packaging_type 						VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
										 , deal_counterparty_reference_id 		VARCHAR(MAX) COLLATE DATABASE_DEFAULT
										 , purchase_counterparty_reference_id 	VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
										 , purchase_counterparty				VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
										 , match_group_detail_id				VARCHAR(MAX) COLLATE DATABASE_DEFAULT		
										 , seq_no								VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
										 , match_group_shipment_id				VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
										 , match_group_header_id				VARCHAR(MAX) COLLATE DATABASE_DEFAULT			 
									 )

	SET @sql = 'INSERT INTO #pre_detail_data_coll
				SELECT sdh.deal_id purchase_deal_reference_id
					, su.uom_desc packaging_type
					, a.deal_counterparty_reference_id	
					, sdh.description1 purchase_counterparty_reference_id
					, sc.counterparty_name purchase_counterparty
					, a.match_group_detail_id
					, a.seq_no	
					, a.match_group_shipment_id
					, a.match_group_header_id
								FROM ' + @match_properties + ' a			
								OUTER APPLY dbo.FNASplit(a.lot, '','') lot   
								INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = lot.item
								INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
								LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
				LEFT JOIN source_uom su ON su.source_uom_id = a.packaging_uom_id'

	EXEC spa_print @sql
	EXEC(@sql)	

	CREATE TABLE #temp_data_for_purchase(purchase_deal_reference_id				VARCHAR(MAX) COLLATE DATABASE_DEFAULT
										 , packaging_type 						VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
										 , deal_counterparty_reference_id 		VARCHAR(MAX) COLLATE DATABASE_DEFAULT
										 , purchase_counterparty_reference_id 	VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
										 , purchase_counterparty				VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
										 , match_group_detail_id				VARCHAR(MAX) COLLATE DATABASE_DEFAULT		
										 , seq_no								VARCHAR(MAX) COLLATE DATABASE_DEFAULT	
		
									 ) 
	INSERT INTO #temp_data_for_purchase(purchase_deal_reference_id, packaging_type, deal_counterparty_reference_id , purchase_counterparty_reference_id 	
									, purchase_counterparty, match_group_detail_id, seq_no)
	SELECT STUFF((
				SELECT DISTINCT ',' + ISNULL(purchase_deal_reference_id, '')
				FROM #pre_detail_data_coll 
				WHERE (match_group_detail_id = results.match_group_detail_id) 
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)') ,1,1,'') AS purchase_deal_reference_id
			, MAX(packaging_type)
			, MAX(deal_counterparty_reference_id)

			, STUFF((
				SELECT DISTINCT',' + ISNULL(purchase_counterparty_reference_id, '')
				FROM #pre_detail_data_coll 
				WHERE (match_group_detail_id = results.match_group_detail_id) 
					AND purchase_counterparty_reference_id  IS NOT NULL
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)') ,1,1,'') AS purchase_counterparty_reference_id
			, STUFF((
				SELECT DISTINCT ',' + ISNULL(purchase_counterparty, '')
				FROM #pre_detail_data_coll 
				WHERE (match_group_detail_id = results.match_group_detail_id) 
				FOR XML PATH(''),TYPE).value('(./text())[1]','VARCHAR(MAX)') ,1,1,'') AS purchase_counterparty
			, match_group_detail_id
			, seq_no 
	FROM #pre_detail_data_coll results
	GROUP BY match_group_detail_id, match_group_shipment_id, match_group_header_id, seq_no 		

	SET @sql = 'SELECT CASE WHEN a.buy_sell_flag = ''b'' THEN ''Receipts'' ELSE ''Delivery'' END receipts_delivery
						--, dbo.FNATrmHyperlink(''i'', 10131010, a.deal_id, source_deal_header_id, ''n'', DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT, DEFAULT) deal
						, CASE WHEN a.source_deal_header_id IS NULL OR a.source_deal_header_id = -1 THEN a.deal_id ELSE ''<a href= "javascript:void(0);" onclick="parent.parent.TRMHyperlink(10131010, '' + CAST(a.source_deal_header_id AS VARCHAR(1000)) + '',''''n'''')">'' + a.deal_id +  ''</a>'' END 
						, a.counterparty_name counterparty
						, a.commodity commodity
						, commodity	
							--+ '' '' + CASE WHEN sdv_form.code IS NULL OR sdv_form.value_id < 0 OR sdv_form.code = ''- Not Specified -'' THEN '''' ELSE sdv_form.code END
							--+ '' | '' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.value_id < 0 OR commodity_origin_id.code = ''- Not Specified -'' THEN '''' ELSE commodity_origin_id.code END							
							--+ '' | '' + CASE WHEN a.organic IS NULL OR a.organic = '''' OR a.organic = ''n'' THEN '''' ELSE '' Organic'' END 
							--+ CASE WHEN sdv1.code IS NULL OR sdv1.value_id < 0 OR sdv1.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv1.code END  
							--+ CASE WHEN sdv2.code IS NULL OR sdv2.value_id < 0 OR sdv2.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv2.code END  
							--+ CASE WHEN sdv3.code IS NULL OR sdv3.value_id < 0 OR sdv3.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv3.code END  
							--+ CASE WHEN sdv4.code IS NULL OR sdv4.value_id < 0 OR sdv4.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv4.code END  
							--+ CASE WHEN sdv5.code IS NULL OR sdv5.value_id < 0 OR sdv5.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv5.code END 
							product_description
						, ISNULL(a.location_split, a.location) location						
						, dbo.FNARemoveTrailingZero(bal_quantity) available_qty
						, dbo.FNARemoveTrailingZero(ISNULL(a.bookout_split_volume, bal_quantity)) sch_quantity
						, dbo.FNARemoveTrailingZero(ISNULL(a.bookout_split_total_amt, bal_quantity)) act_volume
						, dbo.FNARemoveTrailingZero(CASE WHEN bookout_match = ''b'' THEN bookout_split_volume ELSE actualized_amt END) quantity
						, a.lineup
						, a.estimated_movement_date movement_date
						, a.estimated_movement_date_to estimated_movement_date_to
											
						, ISNULL(a.scheduling_period, a.estimated_movement_date) sch_period		
						, a.notes  comment
						, CASE WHEN bookout_match = ''b'' THEN 1 ELSE is_complete END is_complete
						, a.source_deal_detail_id
						, a.match_group_detail_id match_group_detail_id
						, a.source_commodity_id
						, a.seq_no
						, a.incoterm
						, a.crop_year
						, a.lot
						, CASE WHEN a.batch_id = ''-1'' THEN '''' ELSE a.batch_id END batch_id
						--, match_order_sequence
						, estimated_no_of_packages_calc.estimated_no_of_packages estimated_no_of_packages
						, b.packaging_type	
						, a.deal_counterparty_reference_id			
						, b.purchase_deal_reference_id purchase_deal_reference_id
						, b.purchase_counterparty_reference_id
						, b.purchase_counterparty										 
						--,  match_order_sequence, ISNULL(a.location_split, a.location), a.commodity, a.buy_sell_flag
						--, conversion_factor 							 
						, a.deal_type			
				FROM ' + @match_properties + ' a
				LEFT JOIN #temp_data_for_purchase b ON b.seq_no	 = a.seq_no	
				LEFT JOIN (SELECT CEILING(bookout_split_total_amt / ISNULL(conversion_factor, 1)) estimated_no_of_packages, seq_no , 1/ISNULL(conversion_factor, 1) conversion_factor
							FROM ' + @match_properties + ' a
							LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = a.packaging_uom_id) estimated_no_of_packages_calc ON estimated_no_of_packages_calc.seq_no = a.seq_no
				/*
				LEFT JOIN commodity_origin co ON co.commodity_origin_id = a.saved_origin
 				LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
					AND type_id = 14000
											 		
				LEFT JOIN commodity_form cf ON cf.commodity_form_id = a.saved_form
				LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
				LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = commodity_form_id.commodity_form_value
				 
				LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = a.saved_commodity_form_attribute1
				LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
					AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
				LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value
				
				LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id =a.saved_commodity_form_attribute2
				LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
					AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
				LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

				LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = a.saved_commodity_form_attribute3
				LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
					AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
				LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

				LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = a.saved_commodity_form_attribute4
				LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
					AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
				LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

				LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = a.saved_commodity_form_attribute5
				LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
					AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
				LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value	
				*/							
				WHERE  1 = 1 '
					--AND a.source_commodity_id = ' + CASE WHEN @commodity_id = '' THEN 'a.source_commodity_id' ELSE CAST(@commodity_id AS VARCHAR(100)) END 

		IF @match_group_header_id <> ''
			SET @sql = @sql + ' AND a.match_group_header_id = ' + CAST(@match_group_header_id AS VARCHAR(1000))

		IF @region IS NULL
			SET @sql = @sql + '	AND ISNULL(a.region, 0) = ' + CASE WHEN @region = '' THEN 'ISNULL(a.region, 0)' ELSE CAST(@region AS VARCHAR(1000)) END  +
						CASE WHEN @location_id IS NOT NULL THEN +' AND ISNULL(a.source_minor_location_id,0) = ' ELSE ' AND 0 =' END + CAST(ISNULL(@location_id,0) AS VARCHAR(1000))
		
		IF @shipment_name IS NOT NULL
			SET @sql = @sql + ' AND match_group_shipment = ''' + @shipment_name + ''''

		IF @match_group_shipment_id IS NOT NULL
			SET @sql = @sql + ' AND match_group_shipment_id = ' + @match_group_shipment_id
		
		SET @sql = @sql + ' ORDER BY match_order_sequence, a.buy_sell_flag, a.commodity, ISNULL(a.location_split, a.location)' 


	EXEC spa_print @sql
	EXEC(@sql)	
END
ELSE IF @flag = 'w'--schedule_match_viewer(match.php)
BEGIN 
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)

	SET @sql = ' SELECT 
							MAX(group_name) group_name
						, match_group_shipment  transportation_grp
						, MAX(match_book_auto_id) bookoutid
						, MAX(source_deal_detail_id) source_deal_detail_id
						, ISNULL(source_minor_location_id_split, source_minor_location_id) source_minor_location_id
						, region
						, MAX(ISNULL(location_split, location)) location
						, MAX(source_commodity_id) source_commodity_id
						, match_group_shipment_id
						, MAX(match_group_header_id) match_group_header_id
						FROM ' + @match_properties + '
				--WHERE sorting_ids = 1
				GROUP BY region					 
					--, source_commodity_id
					, match_group_shipment
					, match_group_shipment_id
					, match_group_header_id
					--, ISNULL(saved_origin, '''')
					--, ISNULL(saved_form, '''')
					--, ISNULL(organic, ''n'')
					--, ISNULL(saved_commodity_form_attribute1, '''')
					--, ISNULL(saved_commodity_form_attribute2, '''')
					--, ISNULL(saved_commodity_form_attribute3, '''')
					--, ISNULL(saved_commodity_form_attribute4, '''')
					--, ISNULL(saved_commodity_form_attribute5, '''')
					, ISNULL(source_minor_location_id_split, source_minor_location_id)
 				ORDER BY 					
					match_group_shipment_id				
					, MIN(match_order_sequence)		 
					, MIN(buy_sell_flag)							
					, MAX(match_group_header_id)					
					--, ISNULL(saved_origin, '''')
					--, ISNULL(saved_form, '''')
					--, ISNULL(organic, ''n'')
					--, ISNULL(saved_commodity_form_attribute1, '''')
					--, ISNULL(saved_commodity_form_attribute2, '''')
					--, ISNULL(saved_commodity_form_attribute3, '''')
					--, ISNULL(saved_commodity_form_attribute4, '''')
					--, ISNULL(saved_commodity_form_attribute5, '''')
					
				'
	EXEC spa_print @sql
	EXEC(@sql)
	
END
ELSE IF @flag = 'f' --get and load form data(match.php)
BEGIN 
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)

	SET @sql = 'UPDATE ' + @match_properties + '
				SET scheduled_from	= CASE WHEN scheduled_from = ''1900-01-01 00:00:00.000'' THEN NULL ELSE scheduled_from END ,
					scheduled_to = CASE WHEN scheduled_to = ''1900-01-01 00:00:00.000'' THEN NULL ELSE scheduled_to END,
					estimated_movement_date = CASE WHEN estimated_movement_date = ''1900-01-01 00:00:00.000'' THEN NULL ELSE estimated_movement_date END'

	EXEC spa_print @sql
	EXEC(@sql)	

	SET @sql = 'SELECT  MAX(mgs.match_number) match_number
						, MAX(mgs.group_name) group_name
						, MIN(CASE WHEN ' + ISNULL(@shipment_name, -1) + '= -1 THEN mgs.bookout_split_total_amt ELSE mgs.bookout_split_volume END) quantity
						, MAX(mgs.source_commodity_id)  source_commodity_id
						, MAX(mgs.commodity)  commodity
						, MAX(ISNULL(mgs.source_minor_location_id_split, source_minor_location_id)) source_minor_location_id
						, MAX(ISNULL(mgs.location_split, location))  split_location
						, MAX(mgs.source_counterparty_id) source_counterparty_id
						, MAX(mgs.counterparty_name) counterparty_name
						, MAX(mgs.last_edited_by) last_edited_by
						, MAX(mgs.last_edited_on)  last_edited_on
						, MAX(mgs.match_group_header_id) match_group_header_id
						, MAX(mgs.scheduler) scheduler
						, MAX(mgs.location) location
						, MAX(CASE WHEN mgs.status = '''' OR mgs.status IS NULL THEN ''p'' ELSE mgs.status END)  status
						, MAX(mgs.scheduled_from) scheduled_from
						, MAX(mgs.scheduled_to) scheduled_to
						, MAX(mgs.match_number) match_number
						, MAX(mgs.comments) comments
						, MAX(ISNULL(mgs.pipeline_cycle, '''')) pipeline_cycle
						, MAX(ISNULL(mgs.consignee, '''')) consignee
						, MAX(ISNULL(sc_consignee.counterparty_name, '''')) label_consignee
						, MAX(mgs.po_number) po_number
						, MAX(ISNULL(mgs.container, '''')) container
						, MAX(ISNULL(mgs.carrier, '''')) carrier
						, MAX(ISNULL(sc_carrier.counterparty_name, '''')) label_carrier
						, MAX(mgs.match_group_id) match_group_id
						, MAX(mgs.lineup) lineup
						, MAX(ISNULL(mgs.frequency, 703)) frequency
						, MAX(mgs.multiple_single_deals) multiple_single_deals
						, NULL commodity_origin_id
						, NULL commodity_form_id
						, NULL commodity_form_attribute1
						, NULL commodity_form_attribute2
						, NULL commodity_form_attribute3
						, NULL commodity_form_attribute4
						, NULL commodity_form_attribute5
						, NULL organic
						, MAX(mgs.match_group_shipment_id) match_group_shipment_id
						, MAX(mgs.match_group_shipment) match_group_shipment
						, MAX(mgs.shipment_status) shipment_status
						, MAX(ISNULL(mgs.shipment_workflow_status, '''')) shipment_workflow_status
						, MAX(mgs.container_number) container_number
						, MAX(ISNULL(mgs.invoice_status, '''')) invoice_status
						-- added fields
						--shipment
						, MAX(mgs.shipment_status_update_date) shipment_status_update_date
						, MAX(ISNULL(mgs.logistics_assignee, '''')) logistics_assignee
						, MAX(mgs.shipment_comments) shipment_comments
						, MAX(mgs.no_of_loads) no_of_loads
						, MAX(ISNULL(mgs.load_type, ''''))  load_type
						, MAX(mgs.no_of_pallets) no_of_pallets
						, MAX(ISNULL(mgs.pallet_type, '''')) pallet_type
						, MAX(ISNULL(mgs.origin_location, '''')) origin_location
						, MAX(mgs.shipment_origin_counterparty_reference_id) shipment_origin_counterparty_reference_id
						, MAX(ISNULL(mgs.destination_location, '''')) destination_location
						, MAX(mgs.shipment_destination_counterparty_reference_id) shipment_destination_counterparty_reference_id
						, MAX(ISNULL(mgs.carrier_counterparty, '''')) carrier_counterparty
						, MAX(ISNULL(sc.counterparty_id, '''')) carrier_counterparty_label
						, MAX(mgs.instructions_term_start) instructions_term_start
						, MAX(mgs.instructions_term_end) instructions_term_end
						, MAX(ISNULL(mgs.instructions_term_option, '''')) instructions_term_option
						, MAX(mgs.instructions_cut_off_date) instructions_cut_off_date
						, MAX(mgs.booking_no) booking_no
						, MAX(mgs.vessel_name_truck_no_plate) vessel_name_truck_no_plate
						, MAX(mgs.voyage_no) voyage_no
						, MAX(mgs.etd) etd
						, MAX(mgs.eta) eta
						, MAX(mgs.seal_no) seal_no
						, MAX(mgs.container_no) container_no
						, MAX(mgs.bill_of_lading_no_cmr_no) bill_of_lading_no_cmr_no
						, MAX(ISNULL(mgs.our_bank, '''')) our_bank
						, MAX(ISNULL(mgs.destination_counterparty_bank,  '''')) destination_counterparty_bank
						, MAX(mgs.courier_reference) courier_reference
						, MAX(mgs.sellers_invoice_no_agency) sellers_invoice_no_agency
						, MAX(mgs.lrd_dispatch_from_plant) lrd_dispatch_from_plant
					FROM ' + @match_properties + ' mgs
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = mgs.carrier_counterparty
					LEFT JOIN source_counterparty sc_consignee ON sc_consignee.source_counterparty_id = mgs.consignee
					LEFT JOIN source_counterparty sc_carrier ON sc_carrier.source_counterparty_id = mgs.carrier
					WHERE 1 = 1
					AND  deal_type <> ''Transportation''
				'
	IF @region <> '' 
		SET @sql = @sql + ' AND mgs.region = ' + CAST(ISNULL(@region, 'NULL') AS VARCHAR(1000))  
	--ELSE 
	--	SET @sql = @sql + ' AND region IS NULL '
	
	IF @match_group_header_id <> '' 
		SET @sql = @sql + ' AND mgs.match_group_header_id = ' + CAST(@match_group_header_id AS VARCHAR(1000))  
 
	IF @commodity_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND mgs.source_commodity_id = ' + CAST(@commodity_id AS VARCHAR(1000))  
	END 

	IF @match_group_shipment_id IS NOT NULL
	BEGIN 
		SET @sql = @sql + ' AND mgs.match_group_shipment_id = ' + CAST(@match_group_shipment_id AS VARCHAR(1000))  
	END 

	SET @sql = @sql + ' GROUP BY mgs.source_commodity_id'
	
	EXEC spa_print @sql
	EXEC(@sql)
END 
ELSE IF @flag = 'p'--save match data in process table(match.php) -- called on every row grid row changed 
BEGIN  
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_form
	
	SELECT SUBSTRING(location_id, CHARINDEX('_', location_id) + 1, LEN(location_id)) location_id, group_name, group_id, commodity, last_edited_by, match_id, bookout_amt, last_edited_on, 
			scheduler, location, status, scheduled_from, scheduled_to, 
			match_number, comments, 
			CASE WHEN pipeline_cycle = 0 THEN NULL ELSE pipeline_cycle END pipeline_cycle, 
			CASE WHEN consignee = 0 THEN NULL ELSE consignee END consignee, 
			CASE WHEN carrier = 0 THEN NULL ELSE carrier END carrier, 
			po_number, 
			CASE WHEN container = 0 THEN NULL ELSE container END container,
			CASE WHEN frequency = 0 THEN NULL ELSE frequency END frequency,
			lineup,
			SUBSTRING(location_id, 1, CHARINDEX('_', location_id) - 1) region,
			commodity_id,
			--CASE WHEN saved_commodity_origin_id = '' THEN NULL ELSE saved_commodity_origin_id END saved_commodity_origin_id,
			--CASE WHEN saved_commodity_form_id = '' THEN NULL ELSE saved_commodity_form_id END saved_commodity_form_id,
			--CASE WHEN saved_commodity_form_attribute1 = '' THEN NULL ELSE saved_commodity_form_attribute1 END saved_commodity_form_attribute1,
			--CASE WHEN saved_commodity_form_attribute2 = '' THEN NULL ELSE saved_commodity_form_attribute2 END saved_commodity_form_attribute2,
			--CASE WHEN saved_commodity_form_attribute3 = '' THEN NULL ELSE saved_commodity_form_attribute3 END saved_commodity_form_attribute3,
			--CASE WHEN saved_commodity_form_attribute4 = '' THEN NULL ELSE saved_commodity_form_attribute4 END saved_commodity_form_attribute4,
			--CASE WHEN saved_commodity_form_attribute5 = '' THEN NULL ELSE saved_commodity_form_attribute5 END saved_commodity_form_attribute5,
			--CASE WHEN organic = '' THEN 'n' ELSE organic END organic,
			CASE WHEN shipment_status = '' THEN NULL ELSE shipment_status END shipment_status,
			CASE WHEN match_group_shipment = '' THEN NULL ELSE match_group_shipment END match_group_shipment,
			CASE WHEN shipment_workflow_status = '' THEN NULL ELSE shipment_workflow_status END shipment_workflow_status,
			CASE WHEN container_number = '' THEN NULL ELSE container_number END container_number,
			match_group_shipment_id,
			quantity_uom,
			CASE WHEN invoice_status = '' THEN NULL ELSE invoice_status END invoice_status,
			CASE WHEN shipment_status_update_date = '' THEN NULL ELSE shipment_status_update_date END shipment_status_update_date,
			CASE WHEN logistics_assignee = '' THEN NULL ELSE logistics_assignee END logistics_assignee,
			CASE WHEN shipment_comments = '' THEN NULL ELSE shipment_comments END shipment_comments,
			CASE WHEN no_of_loads = '' THEN NULL ELSE no_of_loads END no_of_loads,
			CASE WHEN load_type = '' THEN NULL ELSE load_type END load_type,
			CASE WHEN no_of_pallets = '' THEN NULL ELSE no_of_pallets END no_of_pallets,
			CASE WHEN pallet_type = '' THEN NULL ELSE pallet_type END pallet_type,
			CASE WHEN origin_location = '' THEN NULL ELSE origin_location END origin_location,
			CASE WHEN shipment_origin_counterparty_reference_id = '' THEN NULL ELSE shipment_origin_counterparty_reference_id END shipment_origin_counterparty_reference_id,
			CASE WHEN destination_location = '' THEN NULL ELSE destination_location END destination_location,
			CASE WHEN shipment_destination_counterparty_reference_id = '' THEN NULL ELSE shipment_destination_counterparty_reference_id END shipment_destination_counterparty_reference_id,
			CASE WHEN carrier_counterparty = '' THEN NULL ELSE carrier_counterparty END carrier_counterparty,
			CASE WHEN instructions_term_start = '' THEN NULL ELSE instructions_term_start END instructions_term_start,
			CASE WHEN instructions_term_end = '' THEN NULL ELSE instructions_term_end END instructions_term_end,
			CASE WHEN instructions_term_option = '' THEN NULL ELSE instructions_term_option END instructions_term_option,
			CASE WHEN instructions_cut_off_date = '' THEN NULL ELSE instructions_cut_off_date END instructions_cut_off_date,
			CASE WHEN booking_no = '' THEN NULL ELSE booking_no END booking_no,
			CASE WHEN vessel_name_truck_no_plate = '' THEN NULL ELSE vessel_name_truck_no_plate END vessel_name_truck_no_plate,
			CASE WHEN voyage_no = '' THEN NULL ELSE voyage_no END voyage_no,
			CASE WHEN etd = '' THEN NULL ELSE etd END etd,
			CASE WHEN eta = '' THEN NULL ELSE eta END eta,
			CASE WHEN seal_no = '' THEN NULL ELSE seal_no END seal_no,
			CASE WHEN container_no = '' THEN NULL ELSE container_no END container_no,
			CASE WHEN bill_of_lading_no_cmr_no = '' THEN NULL ELSE bill_of_lading_no_cmr_no END bill_of_lading_no_cmr_no,
			CASE WHEN our_bank = '' THEN NULL ELSE our_bank END our_bank,
			CASE WHEN destination_counterparty_bank = '' THEN NULL ELSE destination_counterparty_bank END destination_counterparty_bank,
			CASE WHEN courier_reference = '' THEN NULL ELSE courier_reference END courier_reference,
			CASE WHEN sellers_invoice_no_agency = '' THEN NULL ELSE sellers_invoice_no_agency END sellers_invoice_no_agency,
			CASE WHEN lrd_dispatch_from_plant = '' THEN NULL ELSE lrd_dispatch_from_plant END lrd_dispatch_from_plant
		INTO #temp_tbl_form
	FROM   OPENXML (@idoc, '/Root/FormXML', 2)	
			WITH ( 
			location_id VARCHAR(1000)			'@region',
			group_name VARCHAR(1000)			'@group_name',
			group_id VARCHAR(1000)				'@group_id',
			commodity VARCHAR(1000)				'@commodity',
			last_edited_by VARCHAR(1000)		'@last_edited_by',
			match_id VARCHAR(1000)				'@match_id',
			bookout_amt VARCHAR(1000)			'@quantity',
			last_edited_on VARCHAR(1000)		'@last_edited_on',
			scheduler VARCHAR(1000)				'@scheduler',
			location VARCHAR(1000)				'@location',
			status VARCHAR(1000)				'@status',
			scheduled_from DATETIME				'@scheduled_from',
			scheduled_to DATETIME				'@scheduled_to',
			match_number VARCHAR(1000)			'@match_number',
			comments VARCHAR(1000)				'@comments',
			pipeline_cycle VARCHAR(1000)		'@pipeline_cycle',
			consignee VARCHAR(1000)				'@consignee',
			carrier VARCHAR(1000)				'@carrier',
			po_number VARCHAR(1000)				'@po_number',
			container VARCHAR(1000)				'@container',
			frequency INT						'@frequency',
			lineup VARCHAR(MAX)					'@lineup',
			commodity_id VARCHAR(1000)			'@commodity_id',	
			--saved_commodity_origin_id	INT		'@saved_commodity_origin_id',
			--saved_commodity_form_id INT		    '@saved_commodity_form_id',
			--saved_commodity_form_attribute1 INT '@saved_commodity_form_attribute1',
			--saved_commodity_form_attribute2 INT	'@saved_commodity_form_attribute2',
			--saved_commodity_form_attribute3 INT	'@saved_commodity_form_attribute3',
			--saved_commodity_form_attribute4 INT	'@saved_commodity_form_attribute4',
			--saved_commodity_form_attribute5 INT	'@saved_commodity_form_attribute5',
			--organic CHAR(1)						'@organic',			
			shipment_status VARCHAR(1000)		'@shipment_status',
			match_group_shipment VARCHAR(1000)	'@match_group_shipment',
			shipment_workflow_status INT		'@shipment_workflow_status',
			container_number VARCHAR(MAX)		'@container_number',
			match_group_shipment_id INT			'@match_group_shipment_id',
			quantity_uom INT					'@quantity_uom',
			invoice_status INT					'@invoice_status',
			--added fields
			shipment_status_update_date DATETIME		'@shipment_status_update_date',
			logistics_assignee VARCHAR(1000)			'@logistics_assignee',
			shipment_comments VARCHAR(1000)				'@shipment_comments',
			no_of_loads VARCHAR(1000)					'@no_of_loads',
			load_type VARCHAR(1000)						'@load_type',
			no_of_pallets VARCHAR(1000)					'@no_of_pallets',
			pallet_type VARCHAR(1000)					'@pallet_type',
			origin_location VARCHAR(1000)				'@origin_location',
			shipment_origin_counterparty_reference_id VARCHAR(1000)		'@shipment_origin_counterparty_reference_id',
			destination_location VARCHAR(1000)			'@destination_location',
			shipment_destination_counterparty_reference_id VARCHAR(1000)	'@shipment_destination_counterparty_reference_id',
			carrier_counterparty VARCHAR(1000)			'@carrier_counterparty',
			instructions_term_start DATETIME			'@instructions_term_start',
			instructions_term_end DATETIME				'@instructions_term_end',
			instructions_term_option INT				'@instructions_term_option',
			instructions_cut_off_date DATETIME			'@instructions_cut_off_date',
			booking_no VARCHAR(1000)					'@booking_no',
			vessel_name_truck_no_plate VARCHAR(1000)	'@vessel_name_truck_no_plate',
			voyage_no VARCHAR(1000)						'@voyage_no',
			etd DATETIME								'@etd',
			eta DATETIME								'@eta',
			seal_no VARCHAR(1000)						'@seal_no',
			container_no VARCHAR(1000)					'@container_no',
			bill_of_lading_no_cmr_no VARCHAR(1000)		'@bill_of_lading_no_cmr_no',
			our_bank VARCHAR(1000)						'@our_bank',
			destination_counterparty_bank VARCHAR(1000)	'@destination_counterparty_bank',
			courier_reference VARCHAR(1000)				'@courier_reference',
			sellers_invoice_no_agency VARCHAR(1000)		'@sellers_invoice_no_agency',
			lrd_dispatch_from_plant DATETIME			'@lrd_dispatch_from_plant'					
			)

	EXEC sp_xml_removedocument @idoc
 
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value
	SELECT 	bookout_split_volume 
			, movement_date 
			, sch_period
			, comment  
			, CASE WHEN actualized_amt = 0 THEN NULL ELSE actualized_amt END actualized_amt
			, is_completed  
			, source_deal_detail_id  
			, split_id 
			, seq_no
			, bookout_split_total_amt
			--, CASE WHEN incoterm = '' THEN NULL ELSE incoterm END incoterm
			--, CASE WHEN crop_year = '' THEN NULL ELSE actualized_amt END crop_year
			, lot     
			, batch_id
			, est_movement_date_to
		INTO #temp_tbl_grid
	FROM   OPENXML (@idoc, '/gridXml/GridRow', 2)
			WITH ( 
			bookout_split_volume FLOAT			'@sch_quantity',
			movement_date DATETIME				'@movement_date',
			sch_period VARCHAR(100)				'@sch_period',
			comment VARCHAR(5000)				'@comment',
			actualized_amt FLOAT				'@actual_volume',
			is_completed CHAR(1)				'@is_completed',
			source_deal_detail_id INT			'@source_deal_detail_id', 
			split_id INT						'@split_id',
			seq_no INT							'@seq_no',
			bookout_split_total_amt FLOAT		'@quantity',
			--incoterm INT						'@incoterm',
			--crop_year INT						'@crop_year',
			lot VARCHAR(5000)    				'@lot',
			batch_id VARCHAR(5000)				'@batch_id',
			est_movement_date_to VARCHAR(100)	'@est_movement_date_to'
			)
	EXEC sp_xml_removedocument @idoc
 
 	--update by grid data
	SET @sql = '--SELECT m.* 
				UPDATE m 
				SET m.notes							= t.comment,
					m.actualized_amt				= t.actualized_amt,
					m.estimated_movement_date		= CASE WHEN t.movement_date = '''' THEN NULL ELSE t.movement_date END,
					m.scheduling_period				= t.sch_period,
					m.is_complete					= is_completed,
					m.bookout_split_volume			= t.bookout_split_volume,
					m.bookout_split_total_amt		= t.bookout_split_total_amt,
					--m.inco_terms_id				= t.incoterm,
					--m.crop_year_id				= t.crop_year,
					m.lot     					= t.lot,	
					m.batch_id						= t.batch_id,
					m.estimated_movement_date_to	= CASE WHEN t.est_movement_date_to = '''' THEN NULL ELSE t.est_movement_date_to END					
				FROM #temp_tbl_grid t
				INNER JOIN ' + @match_properties  + ' m ON m.seq_no = t.seq_no
				'

	EXEC spa_print @sql
	EXEC(@sql)

	IF @mode = 'i'
	BEGIN 
 		SET @sql = '
				--SELECT * 
				UPDATE mp 
				SET mp.shipment_status = ttf.shipment_status
					, mp.shipment_workflow_status = ttf.shipment_workflow_status
					, mp.invoice_status = ttf.invoice_status
					, mp.match_group_shipment = ttf.match_group_shipment
					, mp.status = ttf.shipment_status
					-- added fields
					, mp.shipment_status_update_date = ttf.shipment_status_update_date
					, mp.logistics_assignee	= ttf.logistics_assignee
					, mp.shipment_comments= ttf.shipment_comments
					, mp.no_of_loads = ttf.no_of_loads
					, mp.load_type = ttf.load_type
					, mp.no_of_pallets = ttf.no_of_pallets
					, mp.pallet_type = ttf.pallet_type
					, mp.origin_location = ttf.origin_location
					, mp.shipment_origin_counterparty_reference_id = ttf.shipment_origin_counterparty_reference_id
					, mp.destination_location = ttf.destination_location
					, mp.shipment_destination_counterparty_reference_id = ttf.shipment_destination_counterparty_reference_id
					, mp.carrier_counterparty = ttf.carrier_counterparty
					, mp.instructions_term_start = ttf.instructions_term_start
					, mp.instructions_term_end = ttf.instructions_term_end
					, mp.instructions_term_option = ttf.instructions_term_option
					, mp.instructions_cut_off_date = ttf.instructions_cut_off_date
					, mp.booking_no = ttf.booking_no
					, mp.vessel_name_truck_no_plate = ttf.vessel_name_truck_no_plate
					, mp.voyage_no = ttf.voyage_no
					, mp.etd = ttf.etd
					, mp.eta = ttf.eta
					, mp.seal_no = ttf.seal_no
					, mp.container_no = ttf.container_no
					, mp.bill_of_lading_no_cmr_no = ttf.bill_of_lading_no_cmr_no
					, mp.our_bank = ttf.our_bank
					, mp.destination_counterparty_bank = ttf.destination_counterparty_bank
					, mp.courier_reference = ttf.courier_reference
					, mp.sellers_invoice_no_agency = ttf.sellers_invoice_no_agency
					, mp.lrd_dispatch_from_plant = ttf.lrd_dispatch_from_plant
				FROM ' + @match_properties  + ' mp
				INNER JOIN #temp_tbl_form ttf ON ttf.match_group_shipment = mp.match_group_shipment '
 			 		
		EXEC spa_print @sql
		EXEC(@sql)
 	END

	DECLARE @form_location_id VARCHAR(100) 
	DECLARE @match_new_name VARCHAR(1000)
	SELECT @form_location_id = location FROM #temp_tbl_form
	SELECT @region = region FROM #temp_tbl_form
	SELECT @match_new_name = group_name FROM #temp_tbl_form

	IF @match_new_name <> ''
	BEGIN 
		SET @sql = 'UPDATE ' + @match_properties  + '
					SET group_name = ''' + @match_new_name + ''''
		EXEC spa_print @sql
		EXEC(@sql)
	END
  
	--select * from #temp_tbl_form
	--form data
	SET @sql = '--select mp.source_commodity_id, ttm.commodity
				UPDATE mp
				SET 
					--mp.source_commodity_id = ttm.commodity,
					--mp.bookout_amt = ttm.bookout_amt,
					mp.scheduler = ttm.scheduler,
					--mp.source_minor_location_id = ttm.location_id,
					mp.status = ttm.status,
					mp.scheduled_from = ttm.scheduled_from,
					mp.scheduled_to	= ttm.scheduled_to,
					mp.match_number = ttm.match_number,
					mp.comments = ttm.comments,
					mp.pipeline_cycle = ttm.pipeline_cycle,
					mp.consignee = ttm.consignee,
					mp.carrier = ttm.carrier,
					mp.po_number = ttm.po_number,
					mp.container = ttm.container,
					mp.frequency = ttm.frequency,
					mp.lineup = ttm.lineup,
					--mp.saved_origin = ttm.saved_commodity_origin_id,
					--mp.saved_form = ttm.saved_commodity_form_id,
					--mp.saved_commodity_form_attribute1 = ttm.saved_commodity_form_attribute1,
					--mp.saved_commodity_form_attribute2 = ttm.saved_commodity_form_attribute2,
					--mp.saved_commodity_form_attribute3 = ttm.saved_commodity_form_attribute3,
					--mp.saved_commodity_form_attribute4 = ttm.saved_commodity_form_attribute4,
					--mp.saved_commodity_form_attribute5 = ttm.saved_commodity_form_attribute5,
					--mp.organic = ttm.organic,
					mp.container_number = ttm.container_number,
					mp.location = ttm.location,
					mp.location_split = ttm.location,
					mp.quantity_uom = ttm.quantity_uom,
					mp.source_minor_location_id	= ttm.location,
					mp.source_minor_location_id_split = ttm.location

				FROM ' + @match_properties  + ' mp
				INNER JOIN #temp_tbl_form ttm ON mp.match_group_header_id = ' + CAST(@match_group_header_id AS VARCHAR(1000))
								
	EXEC spa_print @sql
	EXEC(@sql)
 
  	SET @sql = '
				--SELECT * 
				UPDATE mp 
				SET mp.shipment_status = ttf.shipment_status
					, mp.shipment_workflow_status = ttf.shipment_workflow_status
					, mp.invoice_status = ttf.invoice_status
					, mp.match_group_shipment = ttf.match_group_shipment
					, mp.status = ttf.shipment_status
					-- added fields
					, mp.shipment_status_update_date = ttf.shipment_status_update_date
					, mp.logistics_assignee	= ttf.logistics_assignee
					, mp.shipment_comments= ttf.shipment_comments
					, mp.no_of_loads = ttf.no_of_loads
					, mp.load_type = ttf.load_type
					, mp.no_of_pallets = ttf.no_of_pallets
					, mp.pallet_type = ttf.pallet_type
					, mp.origin_location = ttf.origin_location
					, mp.shipment_origin_counterparty_reference_id = ttf.shipment_origin_counterparty_reference_id
					, mp.destination_location = ttf.destination_location
					, mp.shipment_destination_counterparty_reference_id = ttf.shipment_destination_counterparty_reference_id
					, mp.carrier_counterparty = CASE WHEN ' + CAST(@is_transport_created AS VARCHAR(1)) + '= 1 THEN mp.carrier_counterparty ELSE ttf.carrier_counterparty END
					, mp.instructions_term_start = ttf.instructions_term_start
					, mp.instructions_term_end = ttf.instructions_term_end
					, mp.instructions_term_option = ttf.instructions_term_option
					, mp.instructions_cut_off_date = ttf.instructions_cut_off_date
					, mp.booking_no = CASE WHEN ' + CAST(@is_transport_created AS VARCHAR(1)) + '= 1 THEN mp.booking_no ELSE ttf.booking_no END
					, mp.vessel_name_truck_no_plate = ttf.vessel_name_truck_no_plate
					, mp.voyage_no = ttf.voyage_no
					, mp.etd = ttf.etd
					, mp.eta = ttf.eta
					, mp.seal_no = ttf.seal_no
					, mp.container_no = ttf.container_no
					, mp.bill_of_lading_no_cmr_no = ttf.bill_of_lading_no_cmr_no
					, mp.our_bank = ttf.our_bank
					, mp.destination_counterparty_bank = ttf.destination_counterparty_bank
					, mp.courier_reference = ttf.courier_reference
					, mp.sellers_invoice_no_agency = ttf.sellers_invoice_no_agency
					, mp.lrd_dispatch_from_plant = ttf.lrd_dispatch_from_plant
				FROM ' + @match_properties  + ' mp
				INNER JOIN #temp_tbl_form ttf ON ttf.match_group_shipment_id = mp.match_group_shipment_id '
 			 		
	EXEC spa_print @sql
	EXEC(@sql)
	--EXEC('select * from ' + @match_properties)
END
ELSE IF @flag = 'q'--populate match grid data(match.php)
BEGIN
	IF @call_from <> 'view_match_deal'
	BEGIN 
	--need to add due to shipments created while alert query.
	EXEC spa_scheduling_workbench @flag = 's'
					, @buy_sell_flag = NULL
					, @process_id = @process_id
					--, @filter_xml = @filter_xml
					, @convert_uom = @convert_uom						  
					, @call_from = 'operation'					  
	END

	IF OBJECT_ID('tempdb..#source_deal_detail_id_pre_2') IS NOT NULL 
		DROP TABLE #source_deal_detail_id_pre_2
	
	CREATE TABLE #source_deal_detail_id_pre_2(source_deal_detail_id INT, split_deal_detail_volume_id INT)

	IF @match_group_id IS NULL
	BEGIN 
		INSERT INTO #source_deal_detail_id_pre_2
		SELECT SUBSTRING(combined_id, 1, CHARINDEX('_', combined_id) - 1) AS source_deal_detail_id,
			SUBSTRING(combined_id, CHARINDEX('_', combined_id) + 1, LEN(combined_id)) AS split_deal_detail_volume_id
		FROM (SELECT item combined_id FROM dbo.FNASplit(@buy_deals, ',') 
			UNION ALL
			SELECT item FROM dbo.FNASplit(@sell_deals, ',')) a
	END
	ELSE
	BEGIN
		INSERT INTO #source_deal_detail_id_pre_2
		SELECT source_deal_detail_id, split_deal_detail_volume_id 
		FROM match_group_detail mgd
		INNER JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id
		INNER JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = mgd.match_group_shipment_id
		INNER JOIN match_group mg ON mg.match_group_id = mgs.match_group_id
		WHERE  mg.match_group_id = @match_group_id 
	END		
	  
	CREATE CLUSTERED INDEX IX_SOURCE_DEAL_DETAIL_ID_PRE_2 ON #source_deal_detail_id_pre_2 (source_deal_detail_id, split_deal_detail_volume_id)
	
	SELECT source_deal_header_id, source_deal_detail_id,  [Package#] packaging, [Packaging UOM] packaging_uom
		INTO #match_udfs
	FROM (
			SELECT udddf.udf_value, sdh.template_id, sdh.source_deal_header_id, sdd.source_deal_detail_id, udft.Field_label 
			FROM #source_deal_detail_id_pre_2 temp
			INNER JOIN user_defined_deal_detail_fields udddf ON temp.source_deal_detail_id = udddf.source_deal_detail_id
			INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN user_defined_deal_fields_template uddft ON udddf.udf_template_id = uddft.udf_template_id 
				AND uddft.template_id = sdh.template_id
			INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
			WHERE  1 = 2 --udf not required
				AND udft.Field_label IN ('Package#', 'Packaging UOM')
		) up
	PIVOT (MAX(udf_value) FOR Field_label IN ([Package#], [Packaging UOM])) AS pvt 

	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)
	SET @all_deal_coll = dbo.FNAProcessTableName('all_deals', @user_name, @process_id)
	SET @lineup_vol_id_tbl = dbo.FNAProcessTableName('lineup_vol_id_tbl', @user_name, @process_id)
	SET @transportation_deals = dbo.FNAProcessTableName('transportation_deals', @user_name, @process_id)

	SET @sql = 'IF OBJECT_ID(''' + @match_properties + ''', ''U'') IS NOT NULL
				BEGIN 
					DELETE FROM ' + @match_properties + '
				END 
				ELSE 
				BEGIN
					CREATE TABLE ' + @match_properties + '(seq_no							INT IDENTITY(1, 1) NOT NULL,

														match_group_id					INT,
														group_name						VARCHAR(MAX),

														match_group_shipment_id			INT,
														match_group_shipment			VARCHAR(MAX),	

														match_group_header_id			INT,
														match_book_auto_id				VARCHAR(1000),
														source_commodity_id				VARCHAR(1000),
														commodity						VARCHAR(1000),
														source_minor_location_id		VARCHAR(1000),
														location						VARCHAR(1000),																									
														last_edited_by					VARCHAR(1000),
														last_edited_on					DATETIME,
														status							VARCHAR(1000),
														scheduler						VARCHAR(1000),
														container						VARCHAR(1000),
														carrier							VARCHAR(1000),
														consignee						VARCHAR(1000),
														pipeline_cycle					VARCHAR(1000),
														scheduling_period				VARCHAR(1000),
														scheduled_to					DATETIME,
														scheduled_from					DATETIME,
														po_number						VARCHAR(1000),
														comments						VARCHAR(1000),
														match_number					VARCHAR(1000),
														lineup							VARCHAR(1000), 
														--saved_origin					INT,
														--saved_form						INT,
														--organic							CHAR(1),
														--saved_commodity_form_attribute1 INT,
														--saved_commodity_form_attribute2 INT,
														--saved_commodity_form_attribute3 INT,
														--saved_commodity_form_attribute4 INT,
														--saved_commodity_form_attribute5 INT,
														bookout_match					CHAR(1),

														match_group_detail_id			INT,
														notes							VARCHAR(1000),
														estimated_movement_date			DATETIME,
														estimated_movement_date_to		DATETIME,
														source_counterparty_id			VARCHAR(1000),
														counterparty_name				VARCHAR(1000),
														
														source_deal_detail_id			VARCHAR(1000),
														bookout_split_total_amt			NUMERIC(38,4),
														bookout_split_volume			NUMERIC(38,4),
														min_vol							NUMERIC(38,4),
														actualized_amt					NUMERIC(38,4), 
														bal_quantity					NUMERIC(38,4),
														is_complete						CHAR(1), 

														deal_id							VARCHAR(1000),
														buy_sell_flag					CHAR(1),														 
														frequency						INT, 
														multiple_single_deals			CHAR(1),
														multiple_single_location		CHAR(1), 
														split_deal_detail_volume_id		INT,														 
														source_major_location_ID		INT,
														deal_type						VARCHAR(MAX),
														region							INT,
														form_location_id				INT,
														source_minor_location_id_split	INT,
														location_split					VARCHAR(1000),
														sorting_ids						INT,														
														base_deal_detail_id				INT,
														shipment_status					INT,
														from_location					INT,
														to_location						INT,
														incoterm						VARCHAR(1000),
														crop_year						VARCHAR(1000),
														inco_terms_id					INT,
														crop_year_id					INT,
														lot     						VARCHAR(1000),
														batch_id						VARCHAR(1000),
														shipment_workflow_status		INT,
														container_number				VARCHAR(MAX),
														source_deal_header_id			INT,
														quantity_uom					INT,
														org_uom_id						INT,
														base_id							INT,														
														match_order_sequence			INT,
														parent_recall_id				INT,
														invoice_status					INT,
														recall_loc_from					INT,
														recall_loc_to					INT,
														-- added fields
															--shipment
														 shipment_status_update_date DATETIME
														, logistics_assignee INT
														, shipment_comments VARCHAR(MAX)
														, no_of_loads VARCHAR(MAX)
														, load_type VARCHAR(MAX)
														, no_of_pallets VARCHAR(MAX)
														, pallet_type VARCHAR(MAX)
														, origin_location VARCHAR(MAX)
														, shipment_origin_counterparty_reference_id VARCHAR(MAX)
														, destination_location VARCHAR(MAX)
														, shipment_destination_counterparty_reference_id VARCHAR(MAX)
														, carrier_counterparty VARCHAR(MAX)
														, instructions_term_start DATETIME
														, instructions_term_end DATETIME
														, instructions_term_option VARCHAR(MAX)
														, instructions_cut_off_date DATETIME
														, booking_no VARCHAR(MAX)
														, vessel_name_truck_no_plate VARCHAR(MAX)
														, voyage_no VARCHAR(MAX)
														, etd DATETIME
														, eta DATETIME
														, seal_no VARCHAR(MAX)
														, container_no VARCHAR(MAX)
														, bill_of_lading_no_cmr_no VARCHAR(MAX)
														, our_bank VARCHAR(MAX)
														, destination_counterparty_bank VARCHAR(MAX)
														, courier_reference VARCHAR(MAX)
														, sellers_invoice_no_agency VARCHAR(MAX)
														, lrd_dispatch_from_plant DATETIME
														, deal_counterparty_reference_id  VARCHAR(1000) 
														, packaging_uom_id INT
														)
				END'
					 
	EXEC spa_print @sql
	EXEC(@sql)
	 
	CREATE TABLE  #application_users(user_login_id VARCHAR(500) COLLATE DATABASE_DEFAULT, [name] VARCHAR(500) COLLATE DATABASE_DEFAULT)
	INSERT INTO #application_users
	EXEC spa_application_users @flag='a'
  
	CREATE NONCLUSTERED INDEX IX_USER_LOGIN_ID_AU ON #application_users (user_login_id)

	SET @sql = '
			 	INSERT INTO ' + @match_properties + '
				SELECT DISTINCT 
						ISNULL(mgh.match_group_id, b.match_group_id) match_group_id
						, ISNULL(mg.group_name, b.group_name) group_name
					
						, ISNULL(mgh.match_group_shipment_id, b.match_group_shipment_id) match_group_shipment_id
						, ISNULL(ms.match_group_shipment, transportation_grp) match_group_shipment

						, ISNULL(mgh.match_group_header_id, b.match_group_header_id) match_group_header_id
						, ISNULL(mgh.match_book_auto_id, b.bookoutid) match_book_auto_id
						, COALESCE(mgd.source_commodity_id, sdd.detail_commodity_id, sdh.commodity_id) source_commodity_id
						, sc.commodity_name commodity
						, sml.source_minor_location_id
						, sml.source_minor_location_id location
						, ISNULL(mgh.last_edited_by, au.user_login_id) last_edited_by
						, ISNULL(mgh.last_edited_on, GETDATE()) last_edited_on 
						, CASE WHEN ''' + @mode + ''' = ''u'' THEN ISNULL(ms.shipment_status, 47000) ELSE 47000 END status
						, ISNULL(mgh.scheduler, sdh.scheduler) scheduler
						, ISNULL(mgh.container, NULL) container
						, ISNULL(mgh.carrier, NULL) carrier
						, ISNULL(mgh.consignee, NULL) consignee
						, ISNULL(mgh.pipeline_cycle, NULL) pipeline_cycle
						, ISNULL(mgd.scheduling_period, CAST(DATEPART(yy,ISNULL(mgh.scheduled_to, sdd.term_end)) AS VARCHAR(100)) + '' - '' + CAST(DATENAME(MM, ISNULL(mgh.scheduled_to, sdd.term_end)) AS VARCHAR(3)))  scheduling_period
						, COALESCE(mgh.scheduled_to, sdd.term_end) scheduled_to
						, COALESCE(mgh.scheduled_from, sdd.term_start) scheduled_from
						, ISNULL(mgh.po_number, NULL) po_number
						, ISNULL(mgh.comments, NULL) comments
						, ISNULL(mgh.match_number, b.bookoutid) match_number
						, ISNULL(mgh.line_up, b.lineup) lineup
						--,  CASE WHEN ''' + @mode + ''' = ''i'' THEN a.saved_origin 					   ELSE mgh.commodity_origin_id		  END saved_origin 					  
						--,  CASE WHEN ''' + @mode + ''' = ''i'' THEN a.saved_form 					   ELSE mgh.commodity_form_id         END saved_form 					  
						--,  CASE WHEN ''' + @mode + ''' = ''i'' THEN a.organic				 		   ELSE mgh.organic				      END organic				 		  
						--,  CASE WHEN ''' + @mode + ''' = ''i'' THEN a.saved_commodity_form_attribute1  ELSE mgh.commodity_form_attribute1 END saved_commodity_form_attribute1 
						--,  CASE WHEN ''' + @mode + ''' = ''i'' THEN a.saved_commodity_form_attribute2  ELSE mgh.commodity_form_attribute2 END saved_commodity_form_attribute2 
						--,  CASE WHEN ''' + @mode + ''' = ''i'' THEN a.saved_commodity_form_attribute3  ELSE mgh.commodity_form_attribute3 END saved_commodity_form_attribute3 
						--,  CASE WHEN ''' + @mode + ''' = ''i'' THEN a.saved_commodity_form_attribute4  ELSE mgh.commodity_form_attribute4 END saved_commodity_form_attribute4 
						--,  CASE WHEN ''' + @mode + ''' = ''i'' THEN a.saved_commodity_form_attribute5  ELSE mgh.commodity_form_attribute5 END saved_commodity_form_attribute5 
						, ISNULL(mgh.match_bookout, ''m'')

						--detail
						, ISNULL(mgd.match_group_detail_id, ABS(CHECKSUM(NEWID())) * -1)
						, CASE WHEN ''' + @mode + ''' = ''u'' THEN mgd.notes ELSE COALESCE(sddv.comments, sdd.deal_detail_description, sdh.description4) END notes
						, COALESCE(sddv.scheduled_from, mgh.estimated_movement_date, NULL) estimated_movement_date
						, COALESCE(sddv.scheduled_to, mgh.est_movement_date_to, NULL) estimated_movement_date_to
						, sdh.counterparty_id source_counterparty_id
						, coun.counterparty_name
						, sdd.source_deal_detail_id 
						
						, ROUND(COALESCE(ISNULL(qc.conversion_factor, 1) * mgd.bookout_split_volume, b.vol), 2) bookout_split_total_amt
						, ROUND(CASE WHEN ''' + @mode + ''' = ''i'' THEN 
									CASE WHEN ISNULL(qc.conversion_factor, 1) * ISNULL(sddv.quantity, sdd.total_volume) < b.vol THEN ISNULL(qc.conversion_factor, 1) * ISNULL(sddv.quantity, sdd.total_volume) ELSE b.vol END
							ELSE COALESCE(ISNULL(qc.conversion_factor, 1) * mgd.bookout_split_volume, ISNULL(qc.conversion_factor, 1) *  sddv.quantity, b.vol) END, 2) bookout_split_volume
						
						, ROUND(ISNULL(ISNULL(qc.conversion_factor, 1) * mgd.bookout_split_volume , b.vol), 2) min_vol 
						, ROUND(ISNULL(mgd.quantity, NULL) * ISNULL(conversion_factor, 1), 2) actualized_amt
						, ROUND(ISNULL(qc.conversion_factor, 1) * ISNULL(sddv.quantity, sdd.total_volume), 2) [Bal Quantity]
						, ISNULL(mgd.is_complete, 0) is_complete
						
						, sdh.deal_id 
						, sdd.buy_sell_flag						
						, 703 frequency
						, '''' multiple_single_deals		
						, '''' multiple_single_location
						, filtered_data.split_deal_detail_volume_id
						 
						, sml.source_major_location_id
						, sdt.source_deal_type_name  deal_type
						, ISNULL(sml.region, sml.source_minor_location_id) region
						, NULL
						, CASE WHEN ''' + @mode + ''' = ''i'' THEN NULL ELSE sml.source_minor_location_id END source_minor_location_id_split
						, CASE WHEN ''' + @mode + ''' = ''i'' THEN NULL ELSE sml.source_minor_location_id END location_split
						, ''1'' sorting_ids
						, NULL base_deal_detail_id		
						, CASE WHEN ''' + @mode + ''' = ''u'' THEN ms.shipment_status ELSE 47000 END shipment_status
						, ms.from_location
						, ms.to_location	
						, detail_inco_terms.code incoterm
						, crop_year.code crop_year
						, detail_inco_terms.value_id inco_terms_id
						, crop_year.value_id crop_year_id
						, ISNULL(mgd.lot, b.lot)  lot
						, CASE WHEN ''' + @mode + ''' = ''i'' THEN sdd.batch_id ELSE CASE WHEN mgd.batch_id = ''-1'' THEN '''' ELSE mgd.batch_id END END batch_id
						, ms.shipment_workflow_status
						, mgh.container_number
						, sdh.source_deal_header_id
						, ' + CAST(@convert_uom AS VARCHAR(1000)) + ' quantity_uom
						, COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id) org_uom_id
						, NULL base_id
						, ISNULL(mgh.seq_no, b.match_order_sequence) match_order_sequence
						, mgd.parent_recall_id
						, ms.invoice_status
						, NULL
						, NULL
						-- added fields
						--shipment
						, ms.shipment_status_update_date
						, ISNULL(ms.logistics_assignee, sdh.scheduler) logistics_assignee
						, ms.shipment_comments
						, CASE WHEN sdd.buy_sell_flag = ''b'' THEN COALESCE(ms.no_of_loads, sdg.quantity) ELSE NULL END no_of_loads
						, CASE WHEN sdd.buy_sell_flag = ''b'' THEN ISNULL(ms.load_type, sdv_load_type.value_id) ELSE NULL END load_type	
						, ms.no_of_pallets
						, ms.pallet_type
						, ms.origin_location origin_location
						, ms.shipment_origin_counterparty_reference_id
						, ms.destination_location destination_location
						, ms.shipment_destination_counterparty_reference_id
						, ms.carrier_counterparty
						, ms.instructions_term_start
						, ms.instructions_term_end
						, ms.instructions_term_option
						, ms.instructions_cut_off_date
						, ms.booking_no
						, ms.vessel_name_truck_no_plate
						, ms.voyage_no
						, ms.etd
						, ms.eta
						, ms.seal_no
						, ms.container_no
						, ms.bill_of_lading_no_cmr_no
						, ms.our_bank
						, ms.destination_counterparty_bank
						, ms.courier_reference
						, ms.sellers_invoice_no_agency
						, ms.lrd_dispatch_from_plant
						, sdh.description1
						, mu.packaging_uom packaging_uom_id  --udf value
						 
				FROM #source_deal_detail_id_pre_2 filtered_data
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = filtered_data.source_deal_detail_id
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id 
						 
				LEFT JOIN #match_udfs mu ON mu.source_deal_detail_id = sdd.source_deal_detail_id '
				+ CASE WHEN @mode = 'u' THEN ' INNER JOIN ' ELSE ' LEFT JOIN ' END + '
					split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = filtered_data.split_deal_detail_volume_id
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = ISNULL(sddv.changed_location, sdd.location_id) ' 
	
		IF @mode = 'u' 
		BEGIN 
		SET @sql = @sql + '	 
							INNER JOIN match_group_detail mgd ON mgd.source_deal_detail_id = filtered_data.source_deal_detail_id
								AND mgd.split_deal_detail_volume_id = filtered_data.split_deal_detail_volume_id
								INNER JOIN match_group_header mgh ON mgh.match_group_header_id = mgd.match_group_header_id
								INNER JOIN match_group_shipment ms ON ms.match_group_shipment_id = mgh.match_group_shipment_id
								INNER JOIN match_group mg ON mg.match_group_id = ms.match_group_id 
							LEFT JOIN ' + @lineup_vol_id_tbl + '  b ON b.location_id = sdd.location_id AND b.buy_sell_flag = sdd.buy_sell_flag
								AND b.commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
								AND b.source_deal_detail_id = sdd.source_deal_detail_id
								AND b.split_deal_detail_volume_id = filtered_data.split_deal_detail_volume_id
								'				
		END 
		ELSE 
		BEGIN 
		SET @sql = @sql + '	 
							LEFT JOIN ' + @lineup_vol_id_tbl + '  b ON b.location_id = ISNULL(sddv.changed_location, sdd.location_id)
								AND b.buy_sell_flag = sdd.buy_sell_flag
								AND b.commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
								AND b.source_deal_detail_id = filtered_data.source_deal_detail_id
								AND ISNULL(b.split_deal_detail_volume_id, -1) = ISNULL(filtered_data.split_deal_detail_volume_id, -1)
								LEFT JOIN match_group_header mgh ON mgh.match_book_auto_id = b.bookoutid
								LEFT JOIN match_group_shipment ms ON ms.match_group_shipment_id = mgh.match_group_shipment_id
								LEFT JOIN match_group mg ON mg.match_group_id = ms.match_group_id
							LEFT JOIN match_group_detail mgd ON mgd.source_deal_detail_id = filtered_data.source_deal_detail_id
									AND mgh.match_group_header_id = mgd.match_group_header_id
								AND mgd.split_deal_detail_volume_id = filtered_data.split_deal_detail_volume_id    '
		END

		 
	SET @sql = @sql + ' --LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id		
						LEFT JOIN static_data_value detail_inco_terms ON detail_inco_terms.value_id = sdd.detail_inco_terms
						LEFT JOIN static_data_value crop_year ON crop_year.value_id = ISNULL(sdd.crop_year, mgd.crop_year)
							LEFT JOIN #application_users au ON au.user_login_id = dbo.FNADBUser()
						LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id 
						LEFT JOIN source_commodity sc ON sc.source_commodity_id = COALESCE(mgd.source_commodity_id, sdd.detail_commodity_id, sdh.commodity_id) 
						LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id) 
						LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
						LEFT JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
							AND sdd.source_deal_group_id = sdg.source_deal_groups_id
						LEFT JOIN static_data_value sdv_load_type ON sdv_load_type.code = sdg.static_group_name
						LEFT JOIN source_counterparty coun ON coun.source_counterparty_id = sdh.counterparty_id
							WHERE 1 = 1 
							'

	--select @sql
 	EXEC spa_print @sql
	EXEC(@sql)	 
		 	
	SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header') + 1
	SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail') + 1

	-- add temp deal for automatic storage deals
	IF @location_contract_commodity IS NOT NULL 
	BEGIN
		--SELECT @commodity_id = source_commodity_id FROM source_commodity WHERE commodity_id = @commodity_name

		SET @injection_withdrawal = CASE WHEN @sell_deals IS NULL THEN 'w' ELSE 'i' END
		SELECT @template_id = clm3_value 
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		WHERE gmh.mapping_name = 'Scheduling Storage Mapping'
			AND clm1_value = @injection_withdrawal
		
		SELECT @deal_pre = ISNULL(prefix, 'ST-') 
		FROM deal_reference_id_prefix drp
		INNER JOIN source_deal_type sdp ON sdp.source_deal_type_id = drp.deal_type
		WHERE deal_type_id = 'Storage'

		IF @deal_pre IS NULL 
			SET @deal_pre = 'ST-'

		--SET @deal_pre  = @deal_pre + CAST(@new_source_deal_header_id AS VARCHAR(100))

		SELECT @product_description = PARSENAME(REPLACE(item,'^','.'), 2) FROM dbo.FNASplit(@location_contract_commodity, ':')
		
		--EXEC('select * from ' + @match_properties)
		--select * from  #to_generate_match_id_storage_deal_temp
		SELECT TOP 1
			--@origin  					= origin  			 
			--, @form  					= form  				 
			--, @organic  				= organic  			 
			--, @attribute1  				= attribute1  		 
			--, @attribute2  				= attribute2  		 
			--, @attribute3  				= attribute3  		 
			--, @attribute4  				= attribute4  		 
			--, @attribute5  				= attribute5  		 
			--, @product_description		= product_description 
			--, 
			@crop_year  				= crop_year  		 
			, @detail_inco_terms		= detail_inco_terms   
			, @organic					= organic 
		FROM source_deal_detail 
		WHERE ISNULL(product_description, detail_commodity_id) IN (@product_description)

		SELECT source_deal_header_id, source_deal_detail_id,  [Package#] packaging, [Packaging UOM] packaging_uom
			INTO #storage_udf_values
		FROM (
				SELECT udddf.udf_value, sdh.template_id, sdh.source_deal_header_id, sdd.source_deal_detail_id, udft.Field_label 
				FROM user_defined_deal_detail_fields udddf
				INNER JOIN #to_generate_match_id_storage_deal_temp tgm ON tgm.lot = udddf.source_deal_detail_id
				INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
				INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN user_defined_deal_fields_template uddft ON udddf.udf_template_id = uddft.udf_template_id 
				INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
				WHERE  1 = 2
					AND udft.Field_label IN ('Package#', 'Packaging UOM')
			) up
		PIVOT (MAX(udf_value) FOR Field_label IN ([Package#], [Packaging UOM])) AS pvt

		SET @sql = '
				INSERT INTO ' + @match_properties + ' ( match_book_auto_id	
													, match_group_id	
													, group_name	
													, match_group_shipment_id
													, bookout_split_total_amt	
													, bookout_split_volume	
													, min_vol		
													, bal_quantity	
													, source_commodity_id	
													, commodity	
													, source_minor_location_id	
													, location	
													, source_counterparty_id	

													, counterparty_name	
													, source_deal_detail_id	
													, match_group_header_id																 		
													, is_complete	
													, deal_id	
													, buy_sell_flag	
													, bookout_match	
													, frequency
													, split_deal_detail_volume_id
													, source_major_location_ID																 	
													, region
													, lineup
													, deal_type
													, scheduling_period
													, scheduled_to
													, scheduled_from
													, status
													, sorting_ids
													, match_group_shipment
													, match_number
													, last_edited_by
													, last_edited_on
													--, saved_origin
													--, saved_form
													--, saved_commodity_form_attribute1
													--, saved_commodity_form_attribute2
													--, saved_commodity_form_attribute3
													--, saved_commodity_form_attribute4
													--, saved_commodity_form_attribute5
													--, organic
													, inco_terms_id
													, crop_year_id
													, lot
													, batch_id
													, shipment_workflow_status
													, org_uom_id
													, quantity_uom
													, base_id
													, shipment_status
													, match_order_sequence
													, source_deal_header_id
													, packaging_uom_id
													, no_of_loads
													, load_type
													, match_group_detail_id
													, crop_year
													, incoterm
													)'
		SET @sql = 
					 @sql + 
					'													 
					SELECT   
						 --1  
						  MAX(lvi.bookoutid) bookoutid
						, MAX(lvi.match_group_id)	
						, MAX(lvi.group_name)	
						, MAX(lvi.match_group_shipment_id)
						, MIN(ROUND(lvi.vol, 2)) bookout_split_total_amt
						, MIN(ROUND(lvi.vol, 2)) bookout_split_volume	
						, MIN(ROUND(lvi.vol, 2)) min_vol	
						, MIN(ROUND(lvi.quantity_total, 2)) bal_quantity	
				
						, sc.source_commodity_id	
						, sc.commodity_name
						, sml.source_minor_location_id
						--, sml.location_id
						--, MAX(CASE WHEN sml.Location_Name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smj.location_name IS NULL THEN '''' ELSE  '' ['' + smj.location_name + '']'' END) location_name
						, sml.source_minor_location_id
						, MAX(scc.source_counterparty_id)	
						, MAX(scc.counterparty_id)

						, -1
						, MAX(lvi.match_group_header_id) 
						, 0
						, CAST(' + CAST(@new_source_deal_header_id -1 AS VARCHAR(100)) + '+ ROW_NUMBER() OVER (ORDER BY MAX(sml.source_minor_location_id), sc.commodity_id) AS VARCHAR(1000)) 
						, ''' + CASE WHEN @sell_deals = '' OR @sell_deals  IS NULL THEN 's' ELSE 'b' END + '''
						, ''' + @bookout_match + '''
						, ' + CAST(ISNULL(@convert_frequency, 703) AS VARCHAR(100)) + ' 
						, -1
						, MAX(smj.source_major_location_ID)
						, MAX(ISNULL(sml.region, sml.source_minor_location_id))  region
						, MAX(lineup)
						, MAX(sdt.deal_type_id)
						, MAX(CAST(DATEPART(yy, ''' + CAST(@term_start_storage AS VARCHAR(100)) + ''') AS VARCHAR(100)) + '' - '' + CAST(DATENAME(MM, ''' + CAST(@term_start_storage AS VARCHAR(100)) + ''') AS VARCHAR(3))) 
						, ''' + CAST(@term_end_storage AS VARCHAR(100)) + '''
						, ''' + CAST(@term_start_storage AS VARCHAR(100)) + '''
						, 47000  
						, 1
						, MAX(lvi.transportation_grp)
						, MAX(lvi.bookoutid)	
						, dbo.FNADBUser()
						, GETDATE()

						--, ISNULL(str_sdd.origin, NULL)  
						--, ISNULL(str_sdd.form, NULL)  
						--, CASE WHEN str_sdd.attribute1 IS NULL OR str_sdd.attribute1 = '''' THEN NULL ELSE str_sdd.attribute1 END attribute1 
						--, CASE WHEN str_sdd.attribute2 IS NULL OR str_sdd.attribute2 = '''' THEN NULL ELSE str_sdd.attribute2 END attribute2 
						--, CASE WHEN str_sdd.attribute3 IS NULL OR str_sdd.attribute3 = '''' THEN NULL ELSE str_sdd.attribute3 END attribute3 
						--, CASE WHEN str_sdd.attribute4 IS NULL OR str_sdd.attribute4 = '''' THEN NULL ELSE str_sdd.attribute4 END attribute4 
						--, CASE WHEN str_sdd.attribute5 IS NULL OR str_sdd.attribute5 = '''' THEN NULL ELSE str_sdd.attribute5 END attribute5 
						--, CASE WHEN str_sdd.organic IS NULL OR str_sdd.organic = '''' OR str_sdd.organic = ''n'' THEN ''n'' ELSE ''y'' END organic
						, NULL detail_inco_terms
						, MAX(ISNULL(lvi.crop_year, NULL)) crop_year_id
						, MAX(lvi.lot) lot
						, MAX(lvi.batch_id) batch_id
						, NULL shipment_workflow_status
						, ' + CAST(@convert_uom AS VARCHAR(1000)) + '
						, ' + CAST(@convert_uom AS VARCHAR(1000)) + '
						, lvi.base_id base_id
						, 47000
						, 1
						, -1
						, MAX(ISNULL(suv.packaging_uom, NULL)) packaging_uom 
						, MAX(str_sdg.quantity) no_of_loads
						, MAX(str_sdv.value_id) load_type 
						, ABS(CHECKSUM(NEWID())) * -1
						, MAX(crop_year.code) crop_year
						, MAX(detail_inco_terms.code) incoterm
						'

		SET @sql = @sql + '
				FROM source_deal_header sdh  
				INNER JOIN (SELECT MAX(term_start) term_start, base_id, lot, source_commodity_id
							, location_id, MAX(storage_deal_id) storage_deal_id, MAX(batch_id) batch_id
							FROM #to_generate_match_id_storage_deal_temp
							GROUP BY base_id, lot, source_commodity_id, location_id) temp ON sdh.source_deal_header_id = temp.base_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
 				INNER JOIN source_deal_header_template sdht ON sdht.template_id = ' + CAST(@template_id AS VARCHAR(1000)) + '
				INNER JOIN ' + @lineup_vol_id_tbl + ' lvi ON lvi.location_id = temp.location_id
					AND lvi.commodity_id = temp.source_commodity_id
					AND lvi.base_id = CASE WHEN lvi.buy_sell_flag = ''s'' THEN lvi.base_id ELSE temp.base_id END 
					AND lvi.lot = CASE WHEN lvi.buy_sell_flag = ''s'' THEN lvi.lot ELSE temp.lot END
				LEFT JOIN source_deal_header str_sdh ON str_sdh.source_deal_header_id = temp.storage_deal_id
				LEFT JOIN source_deal_detail str_sdd ON str_sdd.source_deal_header_id = str_sdh.source_deal_header_id
				--	AND ISNULL(str_sdd.origin, '''')		=  ISNULL(sdd.origin, '''')
				--	AND ISNULL(str_sdd.form, '''')			=  ISNULL(sdd.form, '''')
				--	AND ISNULL(str_sdd.organic, ''n'')		=  ISNULL(sdd.organic, ''n'') 
				--	AND ISNULL(str_sdd.attribute1, '''')	=  ISNULL(sdd.attribute1, '''')
				--	AND ISNULL(str_sdd.attribute2, '''')	=  ISNULL(sdd.attribute2, '''')
				--	AND ISNULL(str_sdd.attribute3, '''')	=  ISNULL(sdd.attribute3, '''')
				--	AND ISNULL(str_sdd.attribute4, '''')	=  ISNULL(sdd.attribute4, '''')
				--	AND ISNULL(str_sdd.attribute5, '''')	=  ISNULL(sdd.attribute5, '''')
				LEFT JOIN source_deal_groups str_sdg ON str_sdg.source_deal_groups_id = str_sdd.source_deal_group_id
					AND str_sdg.source_deal_header_id = str_sdd.source_deal_header_id
				LEFT JOIN static_data_value str_sdv ON str_sdv.code = str_sdg.static_group_name

				INNER JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = temp.location_id
				INNER JOIN source_commodity sc ON sc.source_commodity_id = temp.source_commodity_id
				
				LEFT JOIN (SELECT  MAX(sc.counterparty_name) counterparty_id, temp.base_id
								, MAX(sc.source_counterparty_id) source_counterparty_id, ISNULL(temp.batch_id, '''') batch_id, temp.location_id						
							FROM match_group_detail mgd 
							INNER JOIN #to_generate_match_id_storage_deal_temp temp ON temp.lot = mgd.lot
							INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id 
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id	
							INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
							INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
							WHERE 1 = 1 AND sdd.buy_sell_flag = ''s'' AND sdd.location_id = temp.location_id
								AND ISNULL(temp.batch_id, '''') = ISNULL(mgd.batch_id, '''')		
								AND deal_type_id = ''Storage''
							GROUP BY temp.base_id, temp.batch_id, temp.location_id) scc ON scc.base_id = temp.base_id
					AND ISNULL(scc.batch_id, '''') = ISNULL(temp.batch_id, '''')
					AND scc.location_id = temp.location_id
				LEFT JOIN source_deal_type sdt ON sdht.source_deal_type_id = sdt.source_deal_type_id
				LEFT JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID				
				LEFT JOIN #storage_udf_values suv ON suv.source_deal_detail_id = sdd.source_deal_detail_id				
				LEFT JOIN static_data_value crop_year ON crop_year.value_id = lvi.crop_year
					AND crop_year.type_id = 10092		
				LEFT JOIN static_data_value detail_inco_terms ON detail_inco_terms.value_id = str_sdd.detail_inco_terms

				WHERE lvi.source_deal_detail_id = -1
					--AND sdd.source_deal_detail_id = temp.lot
					'
		SET @sql = @sql + '
				GROUP BY lvi.base_id
						--, ISNULL(str_sdd.origin, NULL)  
						--, ISNULL(str_sdd.form, NULL)  
						--, CASE WHEN str_sdd.attribute1 IS NULL OR str_sdd.attribute1 = '''' THEN NULL ELSE str_sdd.attribute1 END
						--, CASE WHEN str_sdd.attribute2 IS NULL OR str_sdd.attribute2 = '''' THEN NULL ELSE str_sdd.attribute2 END
						--, CASE WHEN str_sdd.attribute3 IS NULL OR str_sdd.attribute3 = '''' THEN NULL ELSE str_sdd.attribute3 END
						--, CASE WHEN str_sdd.attribute4 IS NULL OR str_sdd.attribute4 = '''' THEN NULL ELSE str_sdd.attribute4 END
						--, CASE WHEN str_sdd.attribute5 IS NULL OR str_sdd.attribute5 = '''' THEN NULL ELSE str_sdd.attribute5 END
						, sc.source_commodity_id	
						--, CASE WHEN str_sdd.organic IS NULL OR str_sdd.organic = '''' OR str_sdd.organic = ''n'' THEN ''n'' ELSE ''y'' END 
						, sc.commodity_id
						, sc.commodity_name
						, sml.source_minor_location_id
						, scc.location_id
						, lvi.batch_id
						, lvi.lot
						, lvi.quantity_total
					' 
		
		EXEC spa_print @sql
		EXEC(@sql)		  		    


		SET @sql = 'UPDATE  ' + @match_properties + ' 
					SET deal_id =  CAST(deal_id AS VARCHAR(1000)) + ''[''+''' + @deal_pre + ''' + CAST(deal_id AS VARCHAR(1000)) +' + ''']''
					WHERE source_deal_detail_id = -1'
		EXEC spa_print @sql
		EXEC(@sql)
		--	select * from  #to_generate_match_id_storage_deal_temp 
		--select @template_id, @lineup_vol_id_tbl, @new_source_deal_header_id, @sell_deals, @bookout_match, @convert_frequency, @match_properties, @deal_pre
		
		--EXEC('select * from ' + @lineup_vol_id_tbl)
	END
	  
	IF @mode = 'i'
	BEGIN 
		IF OBJECT_ID('tempdb..#source_destination') IS NOT NULL
			DROP TABLE #source_destination

		CREATE TABLE #source_destination(origin_location VARCHAR(1000) COLLATE DATABASE_DEFAULT, destination_location VARCHAR(1000) COLLATE DATABASE_DEFAULT, match_group_shipment_id INT)
		SET @sql = '
				INSERT INTO #source_destination
				SELECT  DISTINCT  STUFF((SELECT DISTINCT '','' + source_minor_location_id 
							FROM ' + @match_properties + '
							WHERE buy_sell_flag = ''b''
							FOR XML PATH('''')), 1, 1, '''') source
						, STUFF((SELECT DISTINCT '','' + source_minor_location_id 
							FROM ' + @match_properties + '
							WHERE buy_sell_flag = ''s''
							FOR XML PATH('''')), 1, 1, '''') destination									
						, match_group_shipment_id
					FROM ' + @match_properties + '
				GROUP BY match_group_shipment_id
				
				--SELECT * 
				UPDATE a 
				SET a.origin_location = b.origin_location,
					a.destination_location = ISNULL(b.destination_location, b.origin_location)
				FROM ' + @match_properties + ' a
				INNER JOIN #source_destination b ON b.match_group_shipment_id = a.match_group_shipment_id '

		EXEC spa_print @sql
		EXEC(@sql)

		--update logistics assignee 		
		CREATE TABLE #logistic_assignee(logistics_assignee INT, match_group_shipment_id INT)
		SET @sql = 'INSERT INTO #logistic_assignee
					SELECT MAX(ISNULL(a.logistics_assignee,b.logistics_assignee_sell)) logistics_assignee, a.match_group_shipment_id					 
					FROM ' + @match_properties + ' a
					LEFT JOIN (SELECT MAX(logistics_assignee ) logistics_assignee_sell, match_group_shipment_id
						FROM ' + @match_properties + '
						WHERE buy_sell_flag = ''s''
					GROUP BY match_group_shipment_id) b  ON a.match_group_shipment_id = b.match_group_shipment_id
					WHERE buy_sell_flag = ''b''
					GROUP BY a.match_group_shipment_id
					
					UPDATE a 
					SET a.logistics_assignee = b.logistics_assignee 
					FROM ' + @match_properties + ' a
					INNER JOIN #logistic_assignee b ON b.match_group_shipment_id = a.match_group_shipment_id 				
				'
		EXEC spa_print @sql
		EXEC(@sql)		  
	END

	SET @sql = '
				UPDATE b
				SET multiple_single_deals = CASE WHEN counter > 1 THEN 0 ELSE 1 END 
				FROM (
				SELECT MAX(counter) counter 
						FROM  (SELECT COUNT(1) counter from ' + @match_properties + '
								group by buy_sell_flag
				) c ) a
				CROSS APPLY ' + @match_properties + ' b '
	
	EXEC spa_print @sql
	EXEC(@sql)


	CREATE TABLE #check_multiple_location(counter CHAR(1) COLLATE DATABASE_DEFAULT)
	
	--0 multiple  --1 single 
	SET @sql = 'INSERT INTO #check_multiple_location
				SELECT  CASE WHEN counter > 1 THEN 0 ELSE 1 END 
				FROM (
				SELECT COUNT(location) counter
						FROM  (SELECT DISTINCT ISNULL(CAST(region AS VARCHAR(100)), location)  location
						FROM ' + @match_properties + '
								
				) c ) a'
				
				
	EXEC spa_print @sql
	EXEC(@sql)

	SET @sql = 'UPDATE a
				SET a.multiple_single_location = counter
				FROM ' + @match_properties + ' a
				CROSS APPLY #check_multiple_location b
				'
	EXEC spa_print @sql
	EXEC(@sql)			 

	--EXEC('Select * from ' + @match_properties)
	IF @call_from = 'view_match_deal'
	BEGIN
		SET @sql = 'SELECT TOP 1 ''completed'' completed,  ' + CAST(@match_group_header_id AS VARCHAR(100)) + ' match_group_id, ' 
					+ CAST(@match_group_id AS VARCHAR(100)) + ' match_shipment_id,''' + @process_id + ''' process_id, match_group_id document_object_id  
					FROM ' + @lineup_vol_id_tbl
		EXEC(@sql)--, @match_group_id match_shipment_id,@process_id process_id
		END
	ELSE
	SELECT 'completed' completed
END
ELSE IF @flag = 'c' -- final save for match screen(match.php)
BEGIN  
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)		
	SET @same_location_data = dbo.FNAProcessTableName('same_location_data', @user_name, @process_id)			
	  
 	DECLARE @error_msg VARCHAR(8000)

	IF @call_from = 's' 
	BEGIN 
		EXEC spa_scheduling_workbench @flag='p',@process_id=@process_id,@xml_form=@xml_form,@buy_deals=@buy_deals,@sell_deals=@sell_deals,@xml_value=@xml_value,@convert_uom=@convert_uom, @match_group_header_id = @match_group_header_id, @mode = @mode, @is_transport_created = @is_transport_created
	END
	--EXEC('select * from ' + @match_properties)	    
	--return

	CREATE TABLE #error_log([status] CHAR(1) COLLATE DATABASE_DEFAULT, [message] VARCHAR(MAX) COLLATE DATABASE_DEFAULT)	
	CREATE TABLE #update_loc_same_region(location_id INT, value INT)

	IF @recall_flag = ''
		SET @recall_flag = NULL
	  
	/* check for volume start */
	SET @sql = 'INSERT INTO #error_log
				SELECT 
					CASE WHEN COUNT(bookout_split_volume) > 1 THEN ''e'' ELSE ''s'' END status, 
					CASE WHEN COUNT(bookout_split_volume) > 1 THEN ''Receipts and Delivery Quantity does not match'' ELSE ''Receipts and Delivery Quantity match'' END message 
					FROM (
						SELECT bookout_split_volume
						FROM (SELECT SUM(ROUND(bookout_split_volume, 2)) bookout_split_volume 					
								FROM ' + @match_properties + ' 
								GROUP BY buy_sell_flag
							) a GROUP BY bookout_split_volume
				) b '

	EXEC spa_print @sql
	EXEC(@sql)				

	IF EXISTS(SELECT 1 FROM #error_log WHERE status = 'e')
	BEGIN 
		SET @error_msg = STUFF((
								SELECT [message] + '<br>' 
								FROM #error_log WHERE status = 'e'
								FOR XML PATH('')
							), 1, 0, '')
	
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				@error_msg,
				''
		RETURN
	END

	--EXEC('select * from ' + @match_properties)
	--return

	/* check for volume end */
	CREATE TABLE #get_total_amount_after_conversion(seq_no INT
												, org_uom_id INT
												, quantity_uom INT
												, total_bookout_amount_after_conversion FLOAT
												, total_qty_bookout_amount_after_conversion FLOAT
												, split_deal_detail_volume_id INT
												, match_book_auto_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT
												, source_deal_detail_id INT
												, actualized_amt FLOAT
												, conversion_factor NUMERIC(38, 18)
												, notes VARCHAR(MAX) COLLATE DATABASE_DEFAULT
												, parent_recall_id INT)

 
	/* 
	SET @sql = 'INSERT INTO #get_total_amount_after_conversion
				SELECT seq_no, org_uom_id, quantity_uom
					, bookout_split_total_amt * (1/ISNULL(qc.conversion_factor,1 ))  total_bookout_amount_after_conversion
					, bal_quantity * (1/ISNULL(qc.conversion_factor, 1))  total_qty_bookout_amount_after_conversion
					, a.split_deal_detail_volume_id
					, a.match_book_auto_id
					, a.source_deal_detail_id
					, actualized_amt
					, ISNULL(qc.conversion_factor,  1) conversion_factor
				FROM ' + @match_properties + ' a
				LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = a.org_uom_id'

		
		EXEC spa_print @sql	
		EXEC(@sql)

		select * from #get_total_amount_after_conversion
		 return 

   
 	 SET @sql = '
						INSERT INTO split_deal_detail_volume(source_deal_detail_id
															, quantity
															, finalized
															, bookout_id
															, is_parent)
						SELECT source_deal_detail_id, total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion quantity,  ''n'' finilized,  match_book_auto_id, ''y'' is_parent
						FROM #get_total_amount_after_conversion a
						WHERE total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
							AND split_deal_detail_volume_id = -1
						UNION ALL
						SELECT source_deal_detail_id, total_bookout_amount_after_conversion quantity, ''n'' finilized,  match_book_auto_id, ''n'' is_parent 
						FROM #get_total_amount_after_conversion a
						WHERE total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
							AND split_deal_detail_volume_id = -1
						UNION ALL
						SELECT source_deal_detail_id, total_bookout_amount_after_conversion quantity, ''n'' finilized,  match_book_auto_id, ''n'' is_parent 
						FROM #get_total_amount_after_conversion a
						WHERE total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion
							AND split_deal_detail_volume_id = -1
						UNION ALL
						SELECT source_deal_detail_id, 0 quantity, ''n'' finilized,  match_book_auto_id, ''y'' is_parent 
						FROM #get_total_amount_after_conversion a
						WHERE total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion
							AND split_deal_detail_volume_id = -1
						
						'
			EXEC spa_print @sql		
			EXEC(@sql)
			--EXEC('select * from ' + @match_properties)

			--insert 0 volume parent and set parent as child if total parent volume is matched after split.
			IF EXISTS(SELECT 1 FROM  #get_total_amount_after_conversion  a
					INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
					WHERE is_parent = 'y'
						AND total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion)
			BEGIN 	
				INSERT INTO split_deal_detail_volume(source_deal_detail_id
															, quantity
															, finalized
															, bookout_id
															, is_parent)
				SELECT a.source_deal_detail_id, 0 quantity, 'n' finilized,  match_book_auto_id, 'y' is_parent 
				FROM  #get_total_amount_after_conversion  a
				INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
				WHERE is_parent = 'y'
					AND total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion	
								
				UPDATE sddv
				SET is_parent = 'n'
				FROM  #get_total_amount_after_conversion  a
				INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
				WHERE is_parent = 'y'
					AND total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion								
			END
						
			--calc for parent
			--INSERT INTO split_deal_detail_volume(source_deal_detail_id
			--									, quantity
			--									, finalized
			--									, bookout_id
			--									, is_parent)
			SELECT  a.source_deal_detail_id, total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion quantity, 'n' finilized,  a.match_book_auto_id, sddv.is_parent 						
			FROM #get_total_amount_after_conversion  a
			INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
			WHERE total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion

			--UPDATE sddv
			--SET quantity = total_bookout_amount_after_conversion
			--	, is_parent = 'n'
			----SELECT quantity ,bookout_split_volume, bal_quantity, *
			--FROM  #get_total_amount_after_conversion a
			--INNER JOIN split_deal_detail_volume  sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
			--WHERE total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
			--	AND a.split_deal_detail_volume_id <> -1	

			 

			SET @sql = '
						SELECT ROUND(sddv.quantity, 2) , total_bookout_amount_after_conversion,sddv.split_deal_detail_volume_id, * 				 
					--	UPDATE a 
						SET a.split_deal_detail_volume_id = sddv.split_deal_detail_volume_id
						FROM #get_total_amount_after_conversion a
						INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = a.source_deal_detail_id
							AND CAST(sddv.quantity AS NUMERIC(30, 2)) = ROUND(total_bookout_amount_after_conversion, 2)
							AND sddv.split_deal_detail_volume_id NOT IN (SELECT split_deal_detail_volume_id FROM match_group_detail)
							WHERE sddv.is_parent <> ''y''
			
							'
			EXEC spa_print @sql		
			EXEC(@sql)	

 
 
		return
	--*/
	 
	IF @replaced_id = ''
		SET @replaced_id = NULL
	
	BEGIN TRY 
		BEGIN TRAN 

		IF @mode = 'i' AND @is_back_to_back = 'y' AND @sell_deals = ''
		BEGIN 
			IF OBJECT_ID('tempdb..#source_destination_back_to_back') IS NOT NULL
				DROP TABLE #source_destination_back_to_back

			CREATE TABLE #source_destination_back_to_back(origin_location VARCHAR(1000) COLLATE DATABASE_DEFAULT, destination_location VARCHAR(1000) COLLATE DATABASE_DEFAULT, match_group_shipment_id INT)
			SET @sql = '
					INSERT INTO #source_destination_back_to_back
					SELECT  DISTINCT  STUFF((SELECT DISTINCT '','' + origin_location 
								FROM ' + @match_properties + '
								WHERE buy_sell_flag = ''b''
								FOR XML PATH('''')), 1, 1, '''') source
							, STUFF((SELECT DISTINCT '','' + destination_location 
								FROM ' + @match_properties + '
								WHERE buy_sell_flag = ''s''
								FOR XML PATH('''')), 1, 1, '''') destination									
							, match_group_shipment_id
						FROM ' + @match_properties + '
					GROUP BY match_group_shipment_id
		
		
					--SELECT * 
					UPDATE a 
					SET a.origin_location = b.origin_location,
						a.destination_location = ISNULL(b.destination_location, b.origin_location)
					FROM ' + @match_properties + ' a
					INNER JOIN #source_destination_back_to_back b ON b.match_group_shipment_id = a.match_group_shipment_id '

			EXEC spa_print @sql
			EXEC(@sql)
		END

		--EXEC('select * from ' + @match_properties)

		--rollback tran return 

		IF @replaced_id IS NOT NULL 
		BEGIN 	
			IF OBJECT_ID('tempdb..#same_location_data') IS NOT NULL
				DROP TABLE #same_location_data
			
			CREATE TABLE #same_location_data(source_minor_location_id INT, match_group_header_id_pre INT, replaced_match_group_detailed_id INT, match_book_auto_id VARCHAR(1000) COLLATE DATABASE_DEFAULT)
			
			SET @sql = 'INSERT INTO #same_location_data
						SELECT *  from ' +  @same_location_data
			
			EXEC spa_print @sql		
			EXEC(@sql)
					
			SELECT source_deal_detail_id
				, match_group_header_id
				, bookout_split_volume
				, split_deal_detail_volume_id
				INTO #to_delete_data_collection
			FROM match_group_detail where match_group_detail_id IN (@replaced_id)
 
			SELECT @match_group_shipment_id = match_group_shipment_id FROM match_group_detail WHERE match_group_detail_id = @replaced_id

			DELETE mgd 
			FROM match_group_detail mgd
			WHERE match_group_detail_id = @replaced_id

			SET @sql = '
						--SELECT *
						DELETE a
						FROM ' + @match_properties + ' mp 
						RIGHT JOIN match_group_header a ON a.match_group_header_id = mp.match_group_header_id
						WHERE a.match_group_shipment_id = ' + @match_group_shipment_id + '
							AND mp.match_group_header_id IS NULL'
			EXEC spa_print @sql
			EXEC(@sql)	
 
		END

		IF @recall_flag IS NOT NULL
		BEGIN 
			--make opposite leg for deals
			IF OBJECT_ID('tempdb..#opp_deals_ins') IS NOT NULL 
				DROP TABLE #opp_deals_ins

			IF OBJECT_ID('tempdb..#max_legs') IS NOT NULL 
				DROP TABLE #max_legs
			
			SELECT MAX(leg) leg, a.source_deal_header_id, MAX(b.source_deal_detail_id) source_deal_detail_id 
			INTO #max_legs
			FROM source_deal_detail a		
			INNER JOIN (
					SELECT i.item source_deal_detail_id, sdd.source_deal_header_id 
					FROM dbo.FNASplit(@recalled_ids, ',') i
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = i.item) b ON b.source_deal_header_id = a.source_deal_header_id
			GROUP BY a.source_deal_header_id

			CREATE TABLE #opp_deals_ins(source_deal_detail_id INT, source_deal_header_id INT, term_start DATETIME, commodity_id INT)
			SET @sql = '
					INSERT INTO source_deal_detail(source_deal_header_id, term_start, term_end, Leg, contract_expiration_date
												, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, fixed_price_currency_id, option_strike_price, deal_volume
												, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left, settlement_volume, settlement_uom
												, price_adder, price_multiplier, settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked, process_deal_status
												, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2
												, volume_multiplier2, pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category
												, profile_code, pv_party, status, lock_deal_detail, pricing_type, pricing_period, event_defination, apply_to_all_legs
												, contractual_volume, contractual_uom_id, source_deal_group_id, actual_volume, detail_commodity_id, detail_pricing, pricing_start
												, pricing_end, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, cycle, schedule_volume
												, position_uom, batch_id, buyer_seller_option, crop_year, detail_inco_terms, lot, detail_sample_control, product_description)
						OUTPUT INSERTED.source_deal_detail_id, INSERTED.source_deal_header_id, INSERTED.term_start, INSERTED.detail_commodity_id INTO #opp_deals_ins
					SELECT MAX(sdd.source_deal_header_id)
						--, MAX(mp.scheduled_from) term_start
						--, MAX(mp.scheduled_to) term_end
						, MAX(mpz.scheduled_from) term_start
						, MAX(mpz.scheduled_to) term_end
						, MAX(ml.Leg) + ROW_NUMBER() OVER(ORDER BY mddi.item ASC) 
						, MAX(sdd.contract_expiration_date)
						, MAX(fixed_float_leg)
						, ''b'' buy_sell_flag
						, MAX(curve_id)
						, MAX(fixed_price)
						, MAX(sdd.fixed_price_currency_id)
						, MAX(sdd.option_strike_price)
						, MIN(mp.bookout_split_total_amt) deal_volume
						, ''t'' deal_volume_frequency
						, MAX(sdd.deal_volume_uom_id)
						, MAX(sdd.block_description)
						, MAX(deal_detail_description)
						, MAX(sdd.formula_id)
						, MIN(mp.bookout_split_total_amt)
						, MIN(mp.bookout_split_total_amt)
						, MAX(sdd.settlement_uom)
						, MAX(sdd.price_adder)
						, MAX(sdd.price_multiplier)
						, MAX(sdd.settlement_date)
						, MAX(sdd.day_count_id)
						, MAX(sdd.location_id)
						, MAX(sdd.meter_id)
						, MAX(sdd.physical_financial_flag)
						, MAX(sdd.Booked)
						, MAX(sdd.process_deal_status)
						, MAX(sdd.fixed_cost)
						, MAX(sdd.multiplier)
						, MAX(sdd.adder_currency_id)
						, MAX(sdd.fixed_cost_currency_id)
						, MAX(sdd.formula_currency_id)
						, MAX(sdd.price_adder2)
						, MAX(sdd.price_adder_currency2)
						, MAX(sdd.volume_multiplier2)
						, MAX(sdd.pay_opposite)
						, MAX(sdd.capacity)
						, MAX(sdd.settlement_currency)
						, MAX(sdd.standard_yearly_volume)
						, MAX(sdd.formula_curve_id)
						, MAX(sdd.price_uom_id)
						, MAX(sdd.category)
						, MAX(sdd.profile_code)
						, MAX(sdd.pv_party)
						, MAX(sdd.status)
						, MAX(sdd.lock_deal_detail)
						, MAX(sdd.pricing_type)
						, MAX(sdd.pricing_period)
						, MAX(sdd.event_defination)
						, MAX(sdd.apply_to_all_legs)
						, MIN(mp.bookout_split_total_amt) contractual_volume
						, MAX(sdd.contractual_uom_id)
						, MAX(sdd.source_deal_group_id)
						, MAX(sdd.actual_volume)
						, MAX(sdd.detail_commodity_id)
						, MAX(sdd.detail_pricing)
						, MAX(sdd.pricing_start)
						, MAX(sdd.pricing_end)
						, MAX(sdd.origin)
						, MAX(sdd.form)
						, MAX(sdd.organic)
						, MAX(sdd.attribute1)
						, MAX(sdd.attribute2)
						, MAX(sdd.attribute3)
						, MAX(sdd.attribute4)
						, MAX(sdd.attribute5)
						, MAX(sdd.cycle)
						, MAX(sdd.schedule_volume)
						, MAX(sdd.position_uom)
						, MAX(sdd.batch_id)
						, MAX(sdd.buyer_seller_option)
						, MAX(sdd.crop_year)
						, MAX(sdd.detail_inco_terms)
						, MAX(sdd.lot)
						, MAX(sdd.detail_sample_control)
						, MAX(sdd.product_description)
						
					FROM source_deal_detail sdd
					INNER JOIN dbo.FNASplit(''' + @recalled_ids + ''', '','') mddi ON mddi.item = sdd.source_deal_detail_id
					LEFT JOIN ' + @match_properties + ' mp ON mp.source_deal_header_id = sdd.source_deal_header_id	
					LEFT JOIN #max_legs ml ON ml.source_deal_header_id = sdd.source_deal_header_id		
					LEFT JOIN ' + @match_properties + ' mpz ON mpz.source_deal_header_id = sdd.source_deal_header_id	
						AND mpz.parent_recall_id IS NOT NULL		
					GROUP BY mddi.item'

			EXEC spa_print @sql
			EXEC(@sql)		 

			--insert udfs
			INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id
													, udf_template_id
													, udf_value)
			SELECT DISTINCT rc.source_deal_detail_id
				, udddf.udf_template_id
				, udddf.udf_value
			FROM user_defined_deal_detail_fields udddf
			INNER JOIN dbo.FNASplit(@recalled_ids, ',') mddi ON mddi.item = udddf.source_deal_detail_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mddi.item 
			INNER JOIN #opp_deals_ins rc ON rc.source_deal_header_id = sdd.source_deal_header_id
				AND rc.term_start = sdd.term_start
		
			--update detail ids
			SET @sql = ' 
						UPDATE mp 
						SET  mp.source_deal_detail_id = rc.source_deal_detail_id
						--SELECT * ,   rc.term_start , mp.scheduled_from
						FROM ' + @match_properties + ' mp
						INNER JOIN #opp_deals_ins rc ON rc.source_deal_header_id = mp.source_deal_header_id
							AND rc.term_start = mp.scheduled_from
							AND rc.commodity_id = mp.source_commodity_id
							AND mp.buy_sell_flag = ''b''
						'
			EXEC spa_print @sql
			EXEC(@sql)						 
		END 

		--EXEC('select source_deal_detail_id,*  from ' + @match_properties)
		--select * from source_deal_detail order by 1 desc
		--select* from source_deal_header order by 1 desc
		--ROLLBACK TRAN
		--return
		--check for deals with source_deal_detail_id -1 if yes insert new deal
		CREATE TABLE #insert_new_deal(yes_no CHAR(1) COLLATE DATABASE_DEFAULT, deal_type VARCHAR(1000) COLLATE DATABASE_DEFAULT, base_deal_detail_id INT
									, bookout_split_total_amt FLOAT, match_group_header_id INT, source_commodity_id INT)  

		SET @sql = 'INSERT INTO #insert_new_deal
					SELECT ''y'', deal_type, base_deal_detail_id, bookout_split_total_amt, match_group_header_id, source_commodity_id FROM ' + @match_properties + ' WHERE source_deal_detail_id = -1 AND source_deal_header_id = -1
					'
		EXEC spa_print @sql
		EXEC(@sql)
		 
		CREATE TABLE #check_shipment_status(shipment_status CHAR(1) COLLATE DATABASE_DEFAULT, match_group_shipment_id INT)
		
		SET @sql = 'INSERT INTO #check_shipment_status
					SELECT shipment_status, match_group_shipment_id FROM ' + @match_properties  
					 
		EXEC spa_print @sql
		EXEC(@sql)

		DECLARE @check_is_transport_deal_created INT
		DECLARE @sql1 VARCHAR(MAX)

		SET @transportation_deal_collect_tbl = dbo.FNAProcessTableName('transportation_deal_collect', dbo.FNADBUser(), @process_id)
				
		CREATE TABLE #trans_base_deal(base_deal_header_id INT, source_commodity_id INT, bookout_split_total_amt FLOAT, source_deal_detail_id INT, buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT)
		IF @base_transportation_deal IS NOT NULL
		BEGIN
			SET @sql = 'INSERT INTO #trans_base_deal 
						SELECT MAX(source_deal_header_id) base_deal_header_id, commodity_id source_commodity_id, NULL bookout_split_total_amt
							, MAX(source_deal_detail_id) source_deal_detail_id, buy_sell_flag
						FROM ' + @transportation_deal_collect_tbl + ' a
						INNER JOIN dbo.FNASplit(''' + @base_transportation_deal + ''', '','') trans_deal ON trans_deal.item = a.source_deal_header_id
 						GROUP BY  from_location
								, to_location
								, commodity_id 
								, buy_sell_flag'

			EXEC spa_print @sql
			EXEC(@sql)		
		END 

  		SET @sql = '--SELECT * 
					UPDATE  tbd
					SET tbd.bookout_split_total_amt = a.bookout_split_total_amt
					FROM #trans_base_deal tbd
					INNER JOIN (SELECT DISTINCT sdd.location_id, sdd.detail_commodity_id , sdd.buy_sell_flag, b.bookout_split_total_amt, a.base_deal_header_id
								FROM #trans_base_deal a
								INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id= a.base_deal_header_id
								INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id= sdd.source_deal_header_id
								INNER JOIN ' + @match_properties + ' b ON b.source_minor_location_id = sdd.location_id
									--AND b.source_commodity_id = sdd.detail_commodity_id
									AND b.buy_sell_flag <> sdd.buy_sell_flag
					) a ON a.base_deal_header_id = tbd.base_deal_header_id
						AND a. buy_sell_flag = tbd.buy_sell_flag'


		EXEC spa_print @sql
		EXEC(@sql)	
			 			 
		SET @user_login_id = dbo.FNADBUser()	 
		SET @process_id = dbo.FNAGetNewID()

		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
		EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

		IF @base_transportation_deal IS NOT NULL
		BEGIN 
			DECLARE @base_source_deal_header_id INT 
			DECLARE @trans_deal_ins CURSOR
			 
 				-- cursor start 
			SET @trans_deal_ins = CURSOR FOR
			SELECT DISTINCT base_deal_header_id, ind.source_commodity_id 
			FROM #trans_base_deal ind
			OPEN @trans_deal_ins
			FETCH NEXT
			FROM @trans_deal_ins INTO @base_source_deal_header_id, @commodity_id
			WHILE @@FETCH_STATUS = 0
			BEGIN
				---- insert in header
				INSERT INTO source_deal_header(
					deal_id, source_system_id, ext_deal_id, physical_financial_flag
						, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id
						, option_flag, option_type, option_excercise_type, description1, description2, description3, deal_category_value_id, trader_id
						, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id
						, status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source
						, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id, legal_entity
						, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id, block_type
						, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost
						, broker_currency_id, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
						, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, confirm_status_type, deal_rules
						, confirm_rule, sub_book, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, deal_date)
		 		SELECT DISTINCT 'temp_trans_deal_new_' + CAST(ind.source_commodity_id AS VARCHAR(100)) deal_id, sdh.source_system_id, sdh.ext_deal_id, sdh.physical_financial_flag
						, sdh.structured_deal_id, sdh.counterparty_id, sdh.entire_term_start, sdh.entire_term_end, sdh.source_deal_type_id, sdh.deal_sub_type_type_id
						, sdh.option_flag, sdh.option_type, sdh.option_excercise_type, sdh.description1, sdh.description2, sdh.description3, sdh.deal_category_value_id, sdh.trader_id
						, sdh.internal_deal_type_value_id, NULL internal_deal_subtype_value_id, sdh.template_id, sdh.header_buy_sell_flag, sdh.broker_id, sdh.generator_id, sdh.status_value_id
						, sdh.status_date, sdh.assignment_type_value_id, sdh.compliance_year, sdh.state_value_id, sdh.assigned_date, sdh.assigned_by, sdh.generation_source
						, sdh.aggregate_environment, sdh.aggregate_envrionment_comment, sdh.rec_price, sdh.rec_formula_id, sdh.rolling_avg, sdh.contract_id, sdh.legal_entity
						, sdh.internal_desk_id, sdh.product_id, sdh.internal_portfolio_id, ind.source_commodity_id, sdh.reference, sdh.deal_locked, sdh.close_reference_id, sdh.block_type
						, sdh.block_define_id, sdh.granularity_id, sdh.Pricing, sdh.deal_reference_type_id, sdh.unit_fixed_flag, sdh.broker_unit_fees, sdh.broker_fixed_cost
						, sdh.broker_currency_id, sdh.deal_status, sdh.term_frequency, sdh.option_settlement_date, sdh.verified_by, sdh.verified_date, sdh.risk_sign_off_by
						, sdh.risk_sign_off_date, sdh.back_office_sign_off_by, sdh.back_office_sign_off_date, sdh.book_transfer_id, sdh.confirm_status_type, sdh.deal_rules
						, sdh.confirm_rule, sdh.sub_book, sdh.source_system_book_id1, sdh.source_system_book_id2, sdh.source_system_book_id3, sdh.source_system_book_id4, sdh.deal_date 
				FROM #trans_base_deal ind
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @base_source_deal_header_id
				WHERE sdh.source_deal_header_id = @base_source_deal_header_id
					AND ind.source_commodity_id = @commodity_id
					
				--get template id
				SELECT @template_id = sdh.template_id 
				FROM #trans_base_deal ind
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = @base_source_deal_header_id
				WHERE sdh.source_deal_header_id = @base_source_deal_header_id
					AND ind.source_commodity_id = @commodity_id

				SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header')

				SELECT @deal_pre = ISNULL(prefix, 'TN_') 
				FROM deal_reference_id_prefix drp
				INNER JOIN source_deal_type sdp On sdp.source_deal_type_id = drp.deal_type
				WHERE deal_type_id = 'Transportation'

				SET @deal_pre = ISNULL(@deal_pre, 'TN_') 

				UPDATE source_deal_header
				SET deal_id = @deal_pre + CAST(source_deal_header_id AS VARCHAR(100))
				WHERE source_deal_header_id = @new_source_deal_header_id

				----insert in detail
				INSERT INTO source_deal_detail(
							source_deal_header_id, term_start
						, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
						, fixed_price_currency_id, option_strike_price, deal_volume_frequency, deal_volume_uom_id, block_description
						, formula_id, volume_left, settlement_volume, settlement_uom, price_adder
						, price_multiplier, settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked
						, process_deal_status, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id
						, price_adder2, price_adder_currency2, volume_multiplier2, pay_opposite, capacity
						, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code
						, pv_party, status, lock_deal_detail, contractual_volume, contractual_uom_id, actual_volume, deal_volume
						, origin, form, attribute1, attribute2, attribute3, attribute4, attribute5
						, deal_detail_description, detail_commodity_id, detail_inco_terms, crop_year, lot, batch_id, position_uom
						) 
				SELECT DISTINCT @new_source_deal_header_id, sdd.term_start
						, sdd.term_end, sdd.Leg, sdd.contract_expiration_date, sdd.fixed_float_leg, sdd.buy_sell_flag, sdd.curve_id, sdd.fixed_price
						, sdd.fixed_price_currency_id, sdd.option_strike_price, sdd.deal_volume_frequency, @convert_uom, sdd.block_description
						, sdd.formula_id, sdd.volume_left, sdd.settlement_volume, sdd.settlement_uom, sdd.price_adder
						, sdd.price_multiplier, sdd.settlement_date, sdd.day_count_id, sdd.location_id, sdd.meter_id, sdd.physical_financial_flag, sdd.Booked
						, sdd.process_deal_status, sdd.fixed_cost, sdd.multiplier, sdd.adder_currency_id, sdd.fixed_cost_currency_id, sdd.formula_currency_id
						, sdd.price_adder2, sdd.price_adder_currency2, sdd.volume_multiplier2, sdd.pay_opposite, sdd.capacity
						, sdd.settlement_currency, sdd.standard_yearly_volume, sdd.formula_curve_id, @convert_uom, sdd.category, sdd.profile_code
						, sdd.pv_party, sdd.status, sdd.lock_deal_detail, ind.bookout_split_total_amt, @convert_uom
						, ind.bookout_split_total_amt actual_volume, ind.bookout_split_total_amt deal_volume
						, sdd.origin, sdd.form, sdd.attribute1, sdd.attribute2, sdd.attribute3, sdd.attribute4, sdd.attribute5
						, '' deal_detail_description
						, ind.source_commodity_id, detail_inco_terms, crop_year, lot, batch_id, @convert_uom
				FROM #trans_base_deal ind
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ind.source_deal_detail_id
				WHERE sdd.source_deal_header_id = @base_source_deal_header_id
					AND ind.source_commodity_id = @commodity_id
				
				SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail')

				 
				--udf header
				INSERT INTO user_defined_deal_fields(source_deal_header_id
													, udf_template_id
													, udf_value)
				SELECT @new_source_deal_header_id, udf_template_id, default_value 
				FROM user_defined_deal_fields_template   
				WHERE template_id = @template_id AND udf_type = 'h'

				--udf detail
				INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id
																, udf_template_id
																, udf_value)
				SELECT @new_source_deal_detail_id, udf_template_id, default_value 
				FROM user_defined_deal_fields_template   
				WHERE template_id = @template_id AND udf_type = 'd'

				--update header udf
				--SELECT * 
				UPDATE uddf
				SET uddf.udf_value = z.udf_value
				FROM user_defined_deal_fields uddf
				INNER JOIN (
							SELECT  udf_template_id, udf_value, @new_source_deal_header_id source_deal_header_id
							FROM user_defined_deal_fields   
							WHERE source_deal_header_id = @base_source_deal_header_id) z ON z.udf_template_id = uddf.udf_template_id
					AND uddf.source_deal_header_id = z.source_deal_header_id
				  

				----SELECT * 
				UPDATE udddf
				SET udddf.udf_value = pu.udf_value
				FROM user_defined_deal_detail_fields udddf
				INNER JOIN (
					SELECT @new_source_deal_detail_id source_deal_detail_id, uddft.udf_template_id, a.udf_value, uddft.Field_label, @template_id template_id						 
					FROM user_defined_deal_fields_template   uddft 
					INNER JOIN (
								SELECT DISTINCT udddf.udf_value,udddf.udf_template_id, sdh.template_id, udft.Field_label
								FROM user_defined_deal_detail_fields udddf
								INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
								INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
								INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
									AND udddf.udf_template_id = uddft.udf_template_id
								INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
								WHERE 1 = 1								
									AND sdh.source_deal_header_id = @base_source_deal_header_id
									AND udft.Field_label IN ('Packaging UOM')
								) a ON a.Field_label = uddft.Field_label
					WHERE uddft.template_id = @template_id AND udf_type = 'd'
						AND uddft.Field_label IN ('Packaging UOM')
					) pu ON udddf.source_deal_detail_id = pu.source_deal_detail_id
						AND udddf.udf_template_id = pu.udf_template_id
						

				SET @total_vol_sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@new_source_deal_header_id AS VARCHAR) + ',''i'''
				EXEC spa_print @sql
				EXEC(@sql)					
				 

				/* insert into match properties start */			 
 				SET @sql1 = '
							INSERT INTO ' + @match_properties + '(
									match_group_id
									, group_name
									, match_group_shipment_id
									, match_group_shipment
									, match_group_header_id
									, match_book_auto_id
									, source_commodity_id
									, commodity
									, source_minor_location_id
									, location
									, last_edited_by
									, last_edited_on
									, status
									, scheduler
									, container
									, carrier
									, consignee
									, pipeline_cycle
									, scheduling_period
									, scheduled_to
									, scheduled_from
									, po_number
									, comments
									, match_number
									, lineup
									, saved_origin
									, saved_form
									, organic
									, saved_commodity_form_attribute1
									, saved_commodity_form_attribute2
									, saved_commodity_form_attribute3
									, saved_commodity_form_attribute4
									, saved_commodity_form_attribute5
									, bookout_match
									, match_group_detail_id
									, notes
									, estimated_movement_date
									, source_counterparty_id
									, counterparty_name
									, source_deal_detail_id
									, bookout_split_total_amt
									, bookout_split_volume
									, min_vol
									, actualized_amt
									, bal_quantity
									, is_complete
									, split_deal_detail_volume_id
									, shipment_status	
									, from_location
									, to_location
									, region
									, buy_sell_flag
									, incoterm, crop_year, lot, batch_id 
									)
						SELECT temp_tbl.match_group_id
							, temp_tbl.group_name
							, temp_tbl.match_group_shipment_id
							, temp_tbl.match_group_shipment
							, temp_tbl.match_group_header_id
							, temp_tbl.match_book_auto_id
							, temp_tbl.source_commodity_id
							, temp_tbl.commodity
							, temp_tbl.source_minor_location_id
							, temp_tbl.location
							, temp_tbl.last_edited_by
							, temp_tbl.last_edited_on
							, temp_tbl.status
							, temp_tbl.scheduler
							, temp_tbl.container
							, temp_tbl.carrier
							, temp_tbl.consignee
							, temp_tbl.pipeline_cycle
							, temp_tbl.scheduling_period
							, temp_tbl.scheduled_to
							, temp_tbl.scheduled_from
							, temp_tbl.po_number
							, temp_tbl.comments
							, temp_tbl.match_number
							, temp_tbl.lineup
							, temp_tbl.saved_origin
							, temp_tbl.saved_form
							, temp_tbl.organic
							, temp_tbl.saved_commodity_form_attribute1
							, temp_tbl.saved_commodity_form_attribute2
							, temp_tbl.saved_commodity_form_attribute3
							, temp_tbl.saved_commodity_form_attribute4
							, temp_tbl.saved_commodity_form_attribute5
							, temp_tbl.bookout_match
							, -1
							, temp_tbl.notes
							, temp_tbl.estimated_movement_date
							, temp_tbl.source_counterparty_id
							, temp_tbl.counterparty_name
							, sdd.source_deal_detail_id
							, sdd.total_volume bookout_split_total_amt
							, sdd.total_volume bookout_split_volume
							, sdd.total_volume min_vol
							, NULL actualized_amt
							, temp_tbl.bal_quantity
							, temp_tbl.is_complete
							, -1
							, temp_tbl.shipment_status	
							, temp_tbl.from_location
							, temp_tbl.to_location
							, ISNULL(sml.region, sml.source_minor_location_id) region
							, sdd.buy_sell_flag
							, sdd.detail_inco_terms
							, sdd.crop_year
							, sdd.lot
							, sdd.batch_id 
						FROM source_deal_header sdh 
						INNER JOIN source_deal_detail  sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN ' + @match_properties + '  temp_tbl ON temp_tbl.source_commodity_id = sdd.detail_commodity_id
							AND temp_tbl.source_minor_location_id = sdd.location_id
							AND temp_tbl.buy_sell_flag <> sdd.buy_sell_flag
						INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
							AND sdt.source_deal_type_name = ''Transportation''
						INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
						WHERE sdh.source_deal_header_id = ' + CAST(@new_source_deal_header_id AS VARCHAR(1000))
				EXEC spa_print @sql1
				EXEC (@sql1) 

			FETCH NEXT
			FROM @trans_deal_ins INTO @base_source_deal_header_id, @commodity_id
			END
			CLOSE @trans_deal_ins
			DEALLOCATE @trans_deal_ins

			SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id  + ''',0,null,''' +@user_login_id+''',''n'''
			SET @job_name = 'spa_update_deal_total_volume_' + @process_id 

		  	EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id
		END
	 
		
		----for storage deals insert 
		--select * from #to_generate_match_id_storage_deal_temp
		IF  OBJECT_ID('tempdb..#temp_deal_header_detail_str') IS NOT NULL
			DROP TABLE #temp_deal_header_detail_str
		
		IF  OBJECT_ID('tempdb..#storage_deal_ins_coll') IS NOT NULL
			DROP TABLE #storage_deal_ins_coll

 		CREATE TABLE #trader(trader_id INT)
		IF EXISTS(SELECT 1 FROM #insert_new_deal WHERE yes_no = 'y' AND deal_type <> 'Transportation') -- for storage deals 
		BEGIN
			SET @sql = 'INSERT INTO #trader
						SELECT  trader_id
						FROM ' + @match_properties  + '  mp
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mp.source_deal_detail_id
						INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
						WHERE sdd.source_deal_detail_id <> -1
						'
					 
			EXEC spa_print @sql
			EXEC(@sql)

			DECLARE @trader_id INT
			SELECT @trader_id = trader_id FROM #trader

 			SELECT @injection_withdrawal = CASE WHEN @sell_deals = '' OR @sell_deals IS NULL THEN  'i' ELSE 'w' END 
 
 			SELECT @sub_book = clm2_value,	@template_id = clm3_value 
			FROM generic_mapping_header gmh
			INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Scheduling Storage Mapping'
				AND clm1_value = @injection_withdrawal
			
			SELECT @sub_book fas_book_id
					, source_system_book_id1
					, source_system_book_id2
					, source_system_book_id3
					, source_system_book_id4
				INTO #source_system_book_id2
			FROM source_system_book_map ssbm
			WHERE book_deal_type_map_id	= @sub_book

 			/* insert storage deals start */
			DECLARE @total_volume NUMERIC(38,18)
			DECLARE @buy_sell CHAR(1) --COLLATE DATABASE_DEFAULT
			
 			CREATE TABLE #storage_deal_ins_coll(
					term_start				DATETIME
					, source_commodity_id	 INT
					, contract_id			 INT 
					, location_id			 INT 
					, total_volume			 FLOAT
					, wacog					 FLOAT
					, buy_sell			     CHAR(1) COLLATE DATABASE_DEFAULT
					, product_description	 VARCHAR(MAX) COLLATE DATABASE_DEFAULT
					, base_id				 INT		
					, lot					 VARCHAR(MAX) COLLATE DATABASE_DEFAULT
					, counterparty_id		 INT
					, batch_id				 VARCHAR(MAX) COLLATE DATABASE_DEFAULT
					, seq_no				INT
					, storage_deal_id		 INT
					, fixed_price			FLOAT
			)
 					
			-- EXEC('select source_deal_detail_id, * from ' + @match_properties)
			
			SELECT 
					@deal_type			= source_deal_type_id			
				, @sub_type				= deal_sub_type_type_id			
				, @internal_deal_type	= internal_deal_type_value_id 
				, @internal_sub_type	= internal_deal_subtype_value_id
				, @header_buy_sell_flag = header_buy_sell_flag
				, @template_header_inco_term	= inco_terms
				, @template_deal_locked			= deal_locked
			FROM source_deal_header_template sdht
			WHERE template_id = @template_id
			
			SELECT @template_detail_inco_term = detail_inco_terms
			FROM source_deal_detail_template
			WHERE template_id = @template_id
			
 			IF @recall_flag IS NOT NULL 
			BEGIN 				
				DECLARE @new_insert_storage_deals_recall INT
				DECLARE @insert_storage_deals_recall CURSOR
				SET @insert_storage_deals_recall = CURSOR FOR
				SELECT item FROM dbo.FNASplit(@recalled_ids, ',') 
				OPEN @insert_storage_deals_recall
				FETCH NEXT
				FROM @insert_storage_deals_recall INTO  @new_insert_storage_deals_recall
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					SET @sql = '
								INSERT INTO source_deal_header(source_system_id, deal_id, deal_date, ext_deal_id
									, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag
									, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id
									, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year
									, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id
									, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id
									, block_type, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id, deal_status
									, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id
									, confirm_status_type, sub_book, deal_rules, confirm_rule, description4, timezone_id, reference_detail_id, counterparty_trader, internal_counterparty, settlement_vol_type
									, counterparty_id2, trader_id2, governing_law, inco_terms, payment_days, payment_term, sample_control, scheduler, arbitration, counterparty2_trader
									--, rate_schedule
									)
								SELECT 					
									 sdh.source_system_id, ''st_temp'' + CAST(sdd.source_deal_detail_id  AS VARCHAR(1000)) deal_id, sdh.deal_date, sdh.ext_deal_id, sdh.physical_financial_flag, sdh.structured_deal_id, mp.source_counterparty_id
									, mp.scheduled_from entire_term_start, mp.scheduled_to entire_term_end
									, ' + CAST(ISNULL(@deal_type, '') AS VARCHAR(100)) + ' source_deal_type_id, ' + CAST(@sub_type AS VARCHAR(100)) + ' deal_sub_type_type_id, sdh.option_flag, sdh.option_type
									, sdh.option_excercise_type, ssbm.source_system_book_id1, ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4
									, sdh.description1, sdh.description2, sdh.description3, sdh.deal_category_value_id, sdh.trader_id trader_id
									, ' + CAST(ISNULL(@internal_deal_type, '') AS VARCHAR(100)) + '  internal_deal_type_value_id
									, ' + CAST(ISNULL(@internal_sub_type, '') AS VARCHAR(100)) + ' internal_deal_subtype_value_id
									, ' + CAST(ISNULL(@template_id, '') AS VARCHAR(100)) + ' template_id, ''' + CAST(@header_buy_sell_flag AS VARCHAR(100)) + '''  header_buy_sell_flag
									, sdh.broker_id, sdh.generator_id, sdh.status_value_id
									, sdh.status_date, sdh.assignment_type_value_id, sdh.compliance_year, sdh.state_value_id, sdh.assigned_date, sdh.assigned_by, sdh.generation_source, sdh.aggregate_environment
									, sdh.aggregate_envrionment_comment, sdh.rec_price, sdh.rec_formula_id, sdh.rolling_avg, sdh.contract_id, sdh.legal_entity, sdh.internal_desk_id, sdh.product_id, sdh.internal_portfolio_id
									, mp.source_commodity_id commodity_id, sdh.reference, ''' + CAST(ISNULL(@template_deal_locked, 'n') AS VARCHAR(100)) + ''' deal_locked, sdh.close_reference_id, sdh.block_type, sdh.block_define_id, sdh.granularity_id, sdh.Pricing, sdh.deal_reference_type_id, sdh.unit_fixed_flag
									, sdh.broker_unit_fees, sdh.broker_fixed_cost, sdh.broker_currency_id, sdh.deal_status, sdh.term_frequency, sdh.option_settlement_date, sdh.verified_by, sdh.verified_date, sdh.risk_sign_off_by
									, sdh.risk_sign_off_date, sdh.back_office_sign_off_by, sdh.back_office_sign_off_date, sdh.book_transfer_id, sdh.confirm_status_type, ssbm.fas_book_id sub_book, sdh.deal_rules, sdh.confirm_rule
									, sdh.description4, sdh.timezone_id, sdh.reference_detail_id, sdh.counterparty_trader, sdh.internal_counterparty, sdh.settlement_vol_type, sdh.counterparty_id2, sdh.trader_id2
									, sdh.governing_law, ' + CAST(ISNULL(@template_header_inco_term, '') AS VARCHAR(100)) + ' inco_terms, sdh.payment_days, sdh.payment_term, sdh.sample_control, sdh.scheduler, sdh.arbitration, sdh.counterparty2_trader
									--, sdh.rate_schedule
								FROM dbo.FNASplit(' + CAST(@new_insert_storage_deals_recall AS VARCHAR(100)) + ', '','') recalled_ids
								INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = recalled_ids.item
								INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
								INNER JOIN ' + @match_properties + ' mp ON mp.lot =  sdd.lot
									AND mp.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
									AND sdd.location_id = mp.recall_loc_from
								CROSS APPLY #source_system_book_id2 ssbm
								WHERE mp.source_deal_header_id  = -1
									AND deal_type = ''Storage''
									'																																											
					EXEC spa_print @sql
					--select @sql
					EXEC(@sql)

					SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header') 

					SELECT @deal_pre = ISNULL(prefix, 'T_') 
					FROM deal_reference_id_prefix drp
					INNER JOIN source_deal_type sdp On sdp.source_deal_type_id = drp.deal_type
					WHERE deal_type_id = 'Storage'

					IF @deal_pre IS NULL
						SET @deal_pre = 'ST-'

					UPDATE source_deal_header
					SET deal_id = @deal_pre + CAST(source_deal_header_id AS VARCHAR(100))
					WHERE source_deal_header_id = @new_source_deal_header_id		
	 
					INSERT INTO source_deal_groups( source_deal_groups_name
													, source_deal_header_id
													, static_group_name										
													, quantity
													)
					SELECT 1, @new_source_deal_header_id, NULL, 1
					 		 
					SET @new_source_deal_groups = IDENT_CURRENT('source_deal_groups')
					 		 
					SET @sql = '
						INSERT INTO source_deal_detail(source_deal_header_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
								, fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left
								, settlement_volume, settlement_uom, price_adder, price_multiplier, settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked, process_deal_status
								, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, volume_multiplier2
								, pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code, pv_party, status, lock_deal_detail
								, pricing_type, pricing_period, event_defination, apply_to_all_legs, contractual_volume, contractual_uom_id, source_deal_group_id, actual_volume, detail_commodity_id
								, detail_pricing, pricing_start, pricing_end
								--, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5
								, cycle, schedule_volume
								, position_uom, batch_id, buyer_seller_option, crop_year, detail_inco_terms, lot, detail_sample_control, product_description						
								)
							SELECT  ' + CAST(@new_source_deal_header_id AS VARCHAR(100))+ ' source_deal_header_id
								, mp.scheduled_from term_start, mp.scheduled_to term_end, 1 leg
								, mp.scheduled_to contract_expiration_date, sdd.fixed_float_leg
								, ''' + @header_buy_sell_flag + ''' buy_sell_flag, sdd.curve_id, sdd.fixed_price, sdd.fixed_price_currency_id, sdd.option_strike_price, mp.bookout_split_total_amt deal_volume
								,  ''t'' deal_volume_frequency, ' + CAST(@convert_uom AS VARCHAR(100))+ ' deal_volume_uom_id, sdd.block_description, sdd.deal_detail_description, sdd.formula_id, mp.bookout_split_total_amt volume_left
								, sdd.settlement_volume, sdd.settlement_uom, sdd.price_adder, sdd.price_multiplier, sdd.settlement_date, sdd.day_count_id, mp.source_minor_location_id location_id
								, sdd.meter_id, sdd.physical_financial_flag, sdd.Booked, sdd.process_deal_status, sdd.fixed_cost, 1 multiplier, sdd.adder_currency_id
								, sdd.fixed_cost_currency_id, sdd.formula_currency_id, sdd.price_adder2, sdd.price_adder_currency2, sdd.volume_multiplier2, sdd.pay_opposite
								, sdd.capacity, sdd.settlement_currency, sdd.standard_yearly_volume, sdd.formula_curve_id, sdd.price_uom_id, sdd.category, sdd.profile_code, sdd.pv_party, sdd.status
								, sdd.lock_deal_detail, sdd.pricing_type, sdd.pricing_period, sdd.event_defination, sdd.apply_to_all_legs, mp.bookout_split_total_amt contractual_volume, ' + CAST(@convert_uom AS VARCHAR(100))+ ' contractual_uom_id
								, ' + CAST(@new_source_deal_groups AS VARCHAR(1000)) + ', sdd.actual_volume, mp.source_commodity_id detail_commodity_id, sdd.detail_pricing, sdd.pricing_start, sdd.pricing_end
								--, mp.saved_origin origin, mp.saved_form form, mp.organic organic, mp.saved_commodity_form_attribute1 attribute1, mp.saved_commodity_form_attribute2 attribute2
								--, mp.saved_commodity_form_attribute3 attribute3, mp.saved_commodity_form_attribute4 attribute4, mp.saved_commodity_form_attribute5 attribute5
								, sdd.cycle, mp.bookout_split_total_amt schedule_volume
								, ' + CAST(@convert_uom AS VARCHAR(100))+ ' position_uom, sdd.batch_id, sdd.buyer_seller_option, sdd.crop_year
								, ' + CAST(ISNULL(@template_detail_inco_term, '') AS VARCHAR(100)) + ' detail_inco_terms, sdd.lot, sdd.detail_sample_control, sdd.product_description		   
						FROM dbo.FNASplit(''' + CAST(@new_insert_storage_deals_recall AS VARCHAR(100))  + ''', '','') recalled_ids
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = recalled_ids.item
						INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = sdd.source_deal_header_id
						INNER JOIN  ' + @match_properties + ' mp ON mp.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
							AND mp.lot =  sdd.lot
							AND sdd.location_id = mp.recall_loc_from
						CROSS APPLY #source_system_book_id2 ssbm
						WHERE mp.source_deal_header_id  = -1
							AND deal_type = ''Storage'''	
		
						EXEC spa_print @sql
						EXEC(@sql)

						SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail')

						SET @sql = '
									--select *
									UPDATE a 
									SET source_deal_detail_id = ' + CAST(@new_source_deal_detail_id AS VARCHAR(1000)) + '
									FROM ' + @match_properties + ' a 
									WHERE source_deal_detail_id = -1 AND source_deal_header_id = -1											 
										AND base_id = ' + CAST(@new_insert_storage_deals_recall AS VARCHAR(1000)) 
			
						EXEC spa_print @sql
						EXEC(@sql)

						--udf header
						INSERT INTO user_defined_deal_fields(source_deal_header_id
															, udf_template_id
															, udf_value)
						SELECT @new_source_deal_header_id, udf_template_id, default_value 
						FROM user_defined_deal_fields_template   
						WHERE template_id = @template_id AND udf_type = 'h'
		
							--udf detail
						INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id
																		, udf_template_id
																		, udf_value)

						SELECT @new_source_deal_detail_id, udf_template_id, default_value 
						FROM user_defined_deal_fields_template   
						WHERE template_id = @template_id AND udf_type = 'd'
				
						IF OBJECT_ID('tempdb..#packing_uom_str1') IS NOT NULL 
							DROP TABLE #packing_uom_str1	

						--update packaging and package from base deal	 
						SELECT @new_source_deal_detail_id source_deal_detail_id, uddft.udf_template_id, a.udf_value, uddft.Field_label, @template_id template_id
							INTO #packing_uom_str1
						FROM user_defined_deal_fields_template uddft 
						INNER JOIN (
									SELECT udddf.udf_value,udddf.udf_template_id, sdh.template_id, udft.Field_label
									FROM user_defined_deal_detail_fields udddf
									INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
									INNER JOIN dbo.FNASplit(@recalled_ids, ',') i ON i.item = sdd.source_deal_detail_id 
									INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
									INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
										AND udddf.udf_template_id = uddft.udf_template_id
									INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
					
									WHERE 1 = 1
									--sdd.source_deal_header_id = @from_source_deal_header_id
									--AND sdd.source_deal_detail_id = @source_deal_detail_id
										AND udft.Field_label IN ('Packaging UOM', 'Package#')
									) a ON a.Field_label = uddft.Field_label
						WHERE uddft.template_id = @template_id AND udf_type = 'd'
							AND uddft.Field_label IN ('Packaging UOM', 'Package#')
						 
						--SELECT * 
						UPDATE udddf
						SET udddf.udf_value = pu.udf_value
						FROM #packing_uom_str1 pu 
						INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = pu.source_deal_detail_id
							AND udddf.udf_template_id = pu.udf_template_id
					 

						SET @user_login_id = dbo.FNADBUser()	 
						SET @process_id = dbo.FNAGetNewID()

						SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
						EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

						SET @total_vol_sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@new_source_deal_header_id AS VARCHAR) + ',''i'''
				
						EXEC spa_print @total_vol_sql
						EXEC (@total_vol_sql) 
					--	*/
					FETCH NEXT
					FROM @insert_storage_deals_recall INTO  @new_insert_storage_deals_recall
				END
				CLOSE @insert_storage_deals_recall
				DEALLOCATE @insert_storage_deals_recall

				--EXEC('select source_deal_detail_id, * from ' + @match_properties)
				--select  * from source_deal_header order by 1 desc
				--select * from source_deal_detail order by 1 desc
				--	rollback tran 
				--	return 
			END 
			ELSE IF @replace_or_replace_into_storage = 'replaceintostorage'
			BEGIN 				
				SET @sql = 'INSERT INTO source_deal_header(source_system_id, deal_id, deal_date, ext_deal_id
									, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag
									, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id
									, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year
									, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id
									, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id
									, block_type, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id, deal_status
									, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id
									, confirm_status_type, sub_book, deal_rules, confirm_rule, description4, timezone_id, reference_detail_id, counterparty_trader, internal_counterparty, settlement_vol_type
									, counterparty_id2, trader_id2, governing_law, inco_terms, payment_days, payment_term, sample_control, scheduler, arbitration, counterparty2_trader
									--, rate_schedule
									)
							SELECT 					
									 sdh.source_system_id, ''st_temp'' + CAST(sdd.source_deal_detail_id  AS VARCHAR(1000)) deal_id, sdh.deal_date, sdh.ext_deal_id, sdh.physical_financial_flag, sdh.structured_deal_id, mp.source_counterparty_id
									, mp.scheduled_from entire_term_start, mp.scheduled_to entire_term_end
									, ' + CAST(ISNULL(@deal_type, '') AS VARCHAR(100)) + ' source_deal_type_id, ' + CAST(@sub_type AS VARCHAR(100)) + ' deal_sub_type_type_id, sdh.option_flag, sdh.option_type
									, sdh.option_excercise_type, ssbm.source_system_book_id1, ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4
									, sdh.description1, sdh.description2, sdh.description3, sdh.deal_category_value_id, sdh.trader_id trader_id
									, ' + CAST(ISNULL(@internal_deal_type, '') AS VARCHAR(100)) + '  internal_deal_type_value_id
									, ' + CAST(ISNULL(@internal_sub_type, '') AS VARCHAR(100)) + ' internal_deal_subtype_value_id
									, ' + CAST(ISNULL(@template_id, '') AS VARCHAR(100)) + ' template_id, ''' + CAST(@header_buy_sell_flag AS VARCHAR(100)) + '''  header_buy_sell_flag
									, sdh.broker_id, sdh.generator_id, sdh.status_value_id
									, sdh.status_date, sdh.assignment_type_value_id, sdh.compliance_year, sdh.state_value_id, sdh.assigned_date, sdh.assigned_by, sdh.generation_source, sdh.aggregate_environment
									, sdh.aggregate_envrionment_comment, sdh.rec_price, sdh.rec_formula_id, sdh.rolling_avg, sdh.contract_id, sdh.legal_entity, sdh.internal_desk_id, sdh.product_id, sdh.internal_portfolio_id
									, mp.source_commodity_id commodity_id, sdh.reference, ''' + CAST(ISNULL(@template_deal_locked, 'n') AS VARCHAR(100)) + ''' deal_locked, sdh.close_reference_id, sdh.block_type, sdh.block_define_id, sdh.granularity_id, sdh.Pricing, sdh.deal_reference_type_id, sdh.unit_fixed_flag
									, sdh.broker_unit_fees, sdh.broker_fixed_cost, sdh.broker_currency_id, sdh.deal_status, sdh.term_frequency, sdh.option_settlement_date, sdh.verified_by, sdh.verified_date, sdh.risk_sign_off_by
									, sdh.risk_sign_off_date, sdh.back_office_sign_off_by, sdh.back_office_sign_off_date, sdh.book_transfer_id, sdh.confirm_status_type, ssbm.fas_book_id sub_book, sdh.deal_rules, sdh.confirm_rule
									, sdh.description4, sdh.timezone_id, sdh.reference_detail_id, sdh.counterparty_trader, sdh.internal_counterparty, sdh.settlement_vol_type, sdh.counterparty_id2, sdh.trader_id2
									, sdh.governing_law, ' + CAST(ISNULL(@template_header_inco_term, '') AS VARCHAR(100)) + ' inco_terms, sdh.payment_days, sdh.payment_term, sdh.sample_control, sdh.scheduler, sdh.arbitration, sdh.counterparty2_trader
									--, sdh.rate_schedule
								FROM dbo.FNASplit(' + CAST(@match_deal_detail_id AS VARCHAR(100)) + ', '','') recalled_ids
								INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = recalled_ids.item
								INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
								INNER JOIN ' + @match_properties + ' mp ON mp.match_group_detail_id = ' + CAST(@replaced_id AS VARCHAR(100)) + '
								CROSS APPLY #source_system_book_id2 ssbm
								WHERE mp.source_deal_header_id  = -1
									AND deal_type = ''Storage''
									'	
				EXEC spa_print @sql
				EXEC (@sql) 

				SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header') 

				SELECT @deal_pre = ISNULL(prefix, 'T_') 
				FROM deal_reference_id_prefix drp
				INNER JOIN source_deal_type sdp On sdp.source_deal_type_id = drp.deal_type
				WHERE deal_type_id = 'Storage'

				IF @deal_pre IS NULL
					SET @deal_pre = 'ST-'

				UPDATE source_deal_header
				SET deal_id = @deal_pre + CAST(source_deal_header_id AS VARCHAR(100))
				WHERE source_deal_header_id = @new_source_deal_header_id						

				INSERT INTO source_deal_groups( source_deal_groups_name
						, source_deal_header_id
						, static_group_name										
						, quantity
						)
				SELECT 1, @new_source_deal_header_id, NULL, 1
				SET @new_source_deal_groups = IDENT_CURRENT('source_deal_groups')

				SET @sql = '
						INSERT INTO source_deal_detail(source_deal_header_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
								, fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left
								, settlement_volume, settlement_uom, price_adder, price_multiplier, settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked, process_deal_status
								, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, volume_multiplier2
								, pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code, pv_party, status, lock_deal_detail
								, pricing_type, pricing_period, event_defination, apply_to_all_legs, contractual_volume, contractual_uom_id, source_deal_group_id, actual_volume, detail_commodity_id
								, detail_pricing, pricing_start, pricing_end
								--, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5
								, cycle, schedule_volume
								, position_uom, batch_id, buyer_seller_option, crop_year, detail_inco_terms, lot, detail_sample_control, product_description						
								)
						SELECT  ' + CAST(@new_source_deal_header_id AS VARCHAR(100))+ ' source_deal_header_id
								, mp.scheduled_from term_start, mp.scheduled_to term_end, 1 leg
								, mp.scheduled_to contract_expiration_date, sdd.fixed_float_leg
								, ''' + @header_buy_sell_flag + ''' buy_sell_flag, sdd.curve_id, sdd.fixed_price, sdd.fixed_price_currency_id, sdd.option_strike_price, mp.bookout_split_total_amt deal_volume
								, ''t'' deal_volume_frequency, ' + CAST(@convert_uom AS VARCHAR(100))+ ' deal_volume_uom_id, sdd.block_description, sdd.deal_detail_description, sdd.formula_id, mp.bookout_split_total_amt volume_left
								, sdd.settlement_volume, sdd.settlement_uom, sdd.price_adder, sdd.price_multiplier, sdd.settlement_date, sdd.day_count_id, mp.source_minor_location_id location_id
								, sdd.meter_id, sdd.physical_financial_flag, sdd.Booked, sdd.process_deal_status, sdd.fixed_cost, 1 multiplier, sdd.adder_currency_id
								, sdd.fixed_cost_currency_id, sdd.formula_currency_id, sdd.price_adder2, sdd.price_adder_currency2, sdd.volume_multiplier2, sdd.pay_opposite
								, sdd.capacity, sdd.settlement_currency, sdd.standard_yearly_volume, sdd.formula_curve_id, sdd.price_uom_id, sdd.category, sdd.profile_code, sdd.pv_party, sdd.status
								, sdd.lock_deal_detail, sdd.pricing_type, sdd.pricing_period, sdd.event_defination, sdd.apply_to_all_legs, mp.bookout_split_total_amt contractual_volume, ' + CAST(@convert_uom AS VARCHAR(100))+ ' contractual_uom_id
								, ' + CAST(@new_source_deal_groups AS VARCHAR(1000)) + ', sdd.actual_volume, mp.source_commodity_id detail_commodity_id, sdd.detail_pricing, sdd.pricing_start, sdd.pricing_end
								--, mp.saved_origin origin, mp.saved_form form, mp.organic organic, mp.saved_commodity_form_attribute1 attribute1, mp.saved_commodity_form_attribute2 attribute2
								--, mp.saved_commodity_form_attribute3 attribute3, mp.saved_commodity_form_attribute4 attribute4, mp.saved_commodity_form_attribute5 attribute5
								, sdd.cycle, mp.bookout_split_total_amt schedule_volume
								, ' + CAST(@convert_uom AS VARCHAR(100))+ ' position_uom, sdd.batch_id, sdd.buyer_seller_option, sdd.crop_year
								, ' + CAST(ISNULL(@template_detail_inco_term, '') AS VARCHAR(100)) + ' detail_inco_terms, sdd.lot, sdd.detail_sample_control, sdd.product_description		   
						FROM dbo.FNASplit(' + CAST(@match_deal_detail_id AS VARCHAR(100)) + ', '','') recalled_ids
								INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = recalled_ids.item
								INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
								INNER JOIN ' + @match_properties + ' mp ON mp.match_group_detail_id = ' + CAST(@replaced_id AS VARCHAR(100)) + '
								CROSS APPLY #source_system_book_id2 ssbm
								WHERE mp.source_deal_header_id  = -1
									AND deal_type = ''Storage'''	
		
					EXEC spa_print @sql
					EXEC(@sql)

					SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail')

					SET @sql = '
								--select *
								UPDATE a 
								SET source_deal_detail_id = ' + CAST(@new_source_deal_detail_id AS VARCHAR(1000)) + '
									, source_deal_header_id = ' + CAST(@new_source_deal_header_id AS VARCHAR(1000)) + '
								FROM ' + @match_properties + ' a 
								WHERE a.match_group_detail_id = ' + CAST(@replaced_id AS VARCHAR(100)) 
			
					EXEC spa_print @sql
					EXEC(@sql)

					--udf header
					INSERT INTO user_defined_deal_fields(source_deal_header_id
														, udf_template_id
														, udf_value)
					SELECT @new_source_deal_header_id, udf_template_id, default_value 
					FROM user_defined_deal_fields_template   
					WHERE template_id = @template_id AND udf_type = 'h'
		
						--udf detail
					INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id
																	, udf_template_id
																	, udf_value)

					SELECT @new_source_deal_detail_id, udf_template_id, default_value 
					FROM user_defined_deal_fields_template   
					WHERE template_id = @template_id AND udf_type = 'd'
				
					IF OBJECT_ID('tempdb..#packing_uom_str2') IS NOT NULL 
						DROP TABLE #packing_uom_str2	

					--update packaging and package from base deal	 
					SELECT @new_source_deal_detail_id source_deal_detail_id, uddft.udf_template_id, a.udf_value, uddft.Field_label, @template_id template_id
						INTO #packing_uom_str2
					FROM user_defined_deal_fields_template uddft 
					INNER JOIN (
								SELECT udddf.udf_value,udddf.udf_template_id, sdh.template_id, udft.Field_label
								FROM user_defined_deal_detail_fields udddf
								INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
								INNER JOIN dbo.FNASplit(@match_deal_detail_id, ',') i ON i.item = sdd.source_deal_detail_id 
								INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
								INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
									AND udddf.udf_template_id = uddft.udf_template_id
								INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
					
								WHERE 1 = 1
								--sdd.source_deal_header_id = @from_source_deal_header_id
								--AND sdd.source_deal_detail_id = @source_deal_detail_id
									AND udft.Field_label IN ('Packaging UOM', 'Package#')
								) a ON a.Field_label = uddft.Field_label
					WHERE uddft.template_id = @template_id AND udf_type = 'd'
						AND uddft.Field_label IN ('Packaging UOM', 'Package#')
						 
					--SELECT * 
					UPDATE udddf
					SET udddf.udf_value = pu.udf_value
					FROM #packing_uom_str2 pu 
					INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = pu.source_deal_detail_id
						AND udddf.udf_template_id = pu.udf_template_id
					 
					SET @user_login_id = dbo.FNADBUser()	 
					SET @process_id = dbo.FNAGetNewID()

					SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
					EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

					SET @total_vol_sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@new_source_deal_header_id AS VARCHAR) + ',''i'''
				
					EXEC spa_print @total_vol_sql
					EXEC (@total_vol_sql) 
			END 
			ELSE 
			BEGIN 
				SET @sql = '
						INSERT INTO #storage_deal_ins_coll(term_start, source_commodity_id
															, contract_id, location_id, total_volume, wacog, buy_sell, product_description
															, base_id, lot, counterparty_id, batch_id, seq_no, storage_deal_id)
						SELECT  DISTINCT temp.term_start
							, temp.source_commodity_id
							, z.contract_id
							, temp.location_id
							, a.bookout_split_total_amt 
							, temp.wacog
							, temp.buy_sell
							, temp.product_description
							, temp.base_id
							, CASE WHEN temp.buy_sell = ''s'' THEN a.lot ELSE temp.lot END lot
							, z.source_counterparty_id 	
							, ISNULL(z.batch_id, '''') batch_id
							, ROW_NUMBER() OVER(ORDER BY temp.location_id, temp.base_id, ISNULL(temp.batch_id, '''')) seq_no
							, temp.storage_deal_id
						FROM #to_generate_match_id_storage_deal_temp temp
						--INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.lot 
						--INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
						LEFT JOIN ' + @match_properties + ' a ON temp.base_id = a.base_id
							AND temp.location_id = a.source_minor_location_id
							AND ISNULL(temp.batch_id, '''') = ISNULL(a.batch_id, '''')
							AND a.lot = CASE WHEN temp.buy_sell = ''s'' THEN a.lot ELSE temp.lot END 
						-- storage counterparty
						LEFT JOIN (SELECT  MAX(sc.counterparty_id) counterparty_id, temp.base_id
										, MAX(sc.source_counterparty_id) source_counterparty_id	, ISNULL(temp.batch_id, '''') batch_id
										, temp.location_id, MAX(sdh.contract_id) contract_id, temp.lot						
									FROM match_group_detail mgd 
									INNER JOIN #to_generate_match_id_storage_deal_temp temp ON temp.lot = mgd.lot
									INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id 
									INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id	
									INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
									WHERE 1 = 1 AND sdd.buy_sell_flag = ''s'' AND sdd.location_id = temp.location_id																						
										--AND ISNULL(temp.batch_id, '''') = ISNULL(mgd.batch_id, '''')	
									GROUP BY temp.base_id, ISNULL(temp.batch_id, ''''), temp.location_id, temp.lot) z ON z.base_id = temp.base_id
										AND z.lot = temp.lot
							AND ISNULL(z.batch_id, '''') = ISNULL(temp.batch_id, '''')
							AND z.location_id = temp.location_id
						'
				EXEC spa_print @sql
				EXEC(@sql)
				
 				IF @buy_deals IS NULL OR @buy_deals = ''
				BEGIN
					SET @sql = '--select * 
							UPDATE sdi
							SET fixed_price = s.wacog
							FROM #storage_deal_ins_coll sdi
							INNER JOIN ' + @wacog_data_coll + ' s ON s.source_minor_location_id = sdi.location_id 
								AND s.contract_id = sdi.contract_id'

					EXEC spa_print @sql
					EXEC(@sql)
				END
				
 				--/*
				--  select * from #storage_deal_ins_coll
				--EXEC('select * from ' + @wacog_data_coll)
				--EXEC('select * from ' + @wacog_data_coll)
				--select * from #to_generate_match_id_storage_deal_temp
				-- rollback tran return

				DECLARE @today DATE = CAST(GETDATE() AS DATE)

				SELECT DISTINCT sdh.source_system_id, @term_start_storage deal_date, sdh.ext_deal_id, sdh.physical_financial_flag, sdh.structured_deal_id
					, ISNULL(z.counterparty_id, sdh.counterparty_id) counterparty_id, @term_start_storage entire_term_start, @term_end_storage entire_term_end, sdh.option_flag, sdh.option_type, sdh.option_excercise_type
					, CASE WHEN @injection_withdrawal = 'w' THEN NULL ELSE sdh.description1 END description1, sdh.description2
					, sdh.description3, sdh.deal_category_value_id, sdh.trader_id, @internal_deal_type internal_deal_type_value_id, @internal_sub_type internal_deal_subtype_value_id
					, @header_buy_sell_flag header_buy_sell_flag, sdh.broker_id, sdh.generator_id, sdh.status_value_id, sdh.status_date, sdh.assignment_type_value_id, sdh.compliance_year
					, sdh.state_value_id, sdh.assigned_date, sdh.assigned_by, sdh.generation_source, sdh.aggregate_environment
					, sdh.aggregate_envrionment_comment, sdh.rec_price, sdh.rec_formula_id, sdh.rolling_avg, sdh.legal_entity, sdh.internal_desk_id, sdh.product_id
					, sdh.internal_portfolio_id, sdh.commodity_id, sdh.reference, ISNULL(@template_deal_locked, 'n') deal_locked, sdh.close_reference_id, sdh.block_type, sdh.block_define_id, sdh.granularity_id
					, sdh.Pricing, sdh.deal_reference_type_id, sdh.unit_fixed_flag, sdh.broker_unit_fees, sdh.broker_fixed_cost, sdh.broker_currency_id, sdh.deal_status, sdh.term_frequency
					, sdh.option_settlement_date, sdh.verified_by, sdh.verified_date, sdh.risk_sign_off_by, sdh.risk_sign_off_date, sdh.back_office_sign_off_by
					, sdh.back_office_sign_off_date, sdh.book_transfer_id, sdh.confirm_status_type, sdh.sub_book, sdh.deal_rules, sdh.confirm_rule, sdh.description4, sdh.timezone_id
					, sdh.reference_detail_id, sdh.counterparty_trader, sdh.internal_counterparty, sdh.settlement_vol_type, sdh.counterparty_id2, sdh.trader_id2, sdh.governing_law
					, @template_header_inco_term inco_terms, sdh.payment_days, sdh.payment_term, sdh.sample_control, sdh.scheduler, sdh.arbitration, sdh.counterparty2_trader
					--, sdh.pipeline_id
					, 'ST_Temp' deal_id, @deal_type source_deal_type_id, @sub_type deal_sub_type_type_id, ssbm.source_system_book_id1, ssbm.source_system_book_id2
					, ssbm.source_system_book_id3, ssbm.source_system_book_id4, @template_id template_id, z.contract_id			
				
					--detail
					, sdd.source_deal_detail_id, @term_start_storage term_start, @term_end_storage term_end, 1 Leg, @term_end_storage contract_expiration_date, sdd.fixed_float_leg, @header_buy_sell_flag buy_sell_flag
					, sdd.curve_id, ISNULL(z.fixed_price, sdd.fixed_price) fixed_price
					, sdd.fixed_price_currency_id, sdd.option_strike_price, z.total_volume deal_volume, 't' deal_volume_frequency, sdd.block_description, sdd.deal_detail_description, sdd.formula_id
					, z.total_volume volume_left, sdd.settlement_volume, sdd.settlement_uom, sdd.price_adder, sdd.price_multiplier, sdd.settlement_date, sdd.day_count_id, sdd.meter_id
					, sdd.physical_financial_flag  physical_financial_flag_detail
					, sdd.Booked, sdd.process_deal_status, sdd.fixed_cost, 1 multiplier, sdd.adder_currency_id, sdd.fixed_cost_currency_id, sdd.formula_currency_id, sdd.price_adder2, sdd.price_adder_currency2
					, sdd.volume_multiplier2, sdd.pay_opposite, sdd.capacity, sdd.settlement_currency, sdd.standard_yearly_volume, sdd.formula_curve_id, sdd.price_uom_id, sdd.category, sdd.profile_code, sdd.pv_party
					, sdd.status, sdd.lock_deal_detail, sdd.pricing_type, sdd.pricing_period, sdd.event_defination, sdd.apply_to_all_legs, sdd.actual_volume, sdd.detail_commodity_id
					, sdd.detail_pricing, sdd.pricing_start, sdd.pricing_end
					, str_sdd.origin
					, str_sdd.form
					, str_sdd.organic
					, CASE WHEN str_sdd.attribute1 IS NULL OR str_sdd.attribute1 = '' THEN NULL ELSE str_sdd.attribute1 END attribute1
					, CASE WHEN str_sdd.attribute2 IS NULL OR str_sdd.attribute2 = '' THEN NULL ELSE str_sdd.attribute2 END attribute2
					, CASE WHEN str_sdd.attribute3 IS NULL OR str_sdd.attribute3 = '' THEN NULL ELSE str_sdd.attribute3 END attribute3
					, CASE WHEN str_sdd.attribute4 IS NULL OR str_sdd.attribute4 = '' THEN NULL ELSE str_sdd.attribute4 END attribute4
					, CASE WHEN str_sdd.attribute5 IS NULL OR str_sdd.attribute5 = '' THEN NULL ELSE str_sdd.attribute5 END attribute5
					, sdd.cycle
					, z.total_volume schedule_volume, z.batch_id, sdd.buyer_seller_option, sdd.crop_year, @template_detail_inco_term detail_inco_terms, sdd.detail_sample_control, str_sdd.product_description
					--, sdd.pipeline_cycle_calendar_id
					, @convert_uom deal_volume_uom_id
					, NULL location_id
					, z.total_volume total_volume
					, z.total_volume contractual_volume
					, @convert_uom contractual_uom_id
					, NULL source_deal_group_id
					, @convert_uom position_uom
					, z.lot lot
					, base_id
					, ROW_NUMBER() OVER(ORDER BY z.location_id, base_id, z.lot, z.batch_id) seq_no
					INTO #temp_deal_header_detail_str
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN #storage_deal_ins_coll z ON z.base_id = sdh.source_deal_header_id
				LEFT JOIN source_deal_header str_sdh ON str_sdh.source_deal_header_id = z.storage_deal_id
				LEFT JOIN source_deal_detail str_sdd ON str_sdd.source_deal_header_id = str_sdh.source_deal_header_id
				CROSS APPLY #source_system_book_id2 ssbm
				WHERE sdh.source_deal_header_id = z.base_id
				--	AND sdd.product_description = z.product_description
				--	AND CAST(sdd.source_deal_detail_id AS VARCHAR(100)) = CASE WHEN z.buy_sell = 's' THEN CAST(sdd.source_deal_detail_id AS VARCHAR(100)) ELSE z.lot END
 					 
				-- select * from #temp_deal_header_detail_str
 			 	---- EXEC('select * from ' + @wacog_data_coll)
				--select * from #to_generate_match_id_storage_deal_temp t
				--select * from #storage_deal_ins_coll s 
				--rollback tran return 
				--	select * from #temp_deal_heade_detail_str
 				-- EXEC('select * from ' + @wacog_data_coll)
				-- rollback tran return 
				--*/
 				DECLARE @base_id_str INT 
				DECLARE @seq_no INT
				DECLARE @batch_id VARCHAR(1000)
				DECLARE @str_lot VARCHAR(1000)
 
				DECLARE @insert_storage_deals CURSOR
				SET @insert_storage_deals = CURSOR FOR
				SELECT 
						t.term_start				
						, t.source_commodity_id	
						, t.contract_id			
						, t.location_id			
						, s.total_volume			
						, t.wacog					
						, t.buy_sell			    
						, t.product_description	
						, t.base_id					
						, s.seq_no			 
						, t.batch_id		 
						, s.lot	 
				FROM #to_generate_match_id_storage_deal_temp t
				INNER JOIN #storage_deal_ins_coll s ON s.buy_sell= t.buy_sell
					AND s.product_description = t.product_description	
					AND s.base_id = t.base_id
					AND s.seq_no = t.seq_no

				OPEN @insert_storage_deals
				FETCH NEXT
				FROM @insert_storage_deals INTO @term_start, @commodity_id, @contract_id, @location_id, @total_volume
					, @wacog, @buy_sell, @product_description, @base_id_str, @seq_no, @batch_id, @str_lot
				WHILE @@FETCH_STATUS = 0																								
				BEGIN
					INSERT INTO source_deal_header(source_system_id, deal_id, deal_date, ext_deal_id
													, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag
													, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id
													, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year
													, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id
													, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id
													, block_type, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id, deal_status
													, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id
													, confirm_status_type, sub_book, deal_rules, confirm_rule, description4, timezone_id, reference_detail_id, counterparty_trader, internal_counterparty, settlement_vol_type
													, counterparty_id2, trader_id2, governing_law, inco_terms, payment_days, payment_term, sample_control, scheduler, arbitration, counterparty2_trader
													--, pipeline_id
													) 
					SELECT DISTINCT source_system_id, 'st-temp' deal_id, deal_date, ext_deal_id
						, physical_financial_flag, structured_deal_id, counterparty_id, @term_start_storage entire_term_start, @term_end_storage entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag
						, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id
						, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year
						, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id
						, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id
						, block_type, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id, deal_status
						, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id
						, confirm_status_type, sub_book, deal_rules, confirm_rule, description4, timezone_id, reference_detail_id, counterparty_trader, internal_counterparty, settlement_vol_type
						, counterparty_id2, trader_id2, governing_law, inco_terms, payment_days, payment_term, sample_control, scheduler, arbitration, counterparty2_trader
						--, pipeline_id
					FROM #temp_deal_header_detail_str
					WHERE base_id = @base_id_str
						AND seq_no = @seq_no
			
					SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header') 

					SELECT @deal_pre = ISNULL(prefix, 'T_') 
					FROM deal_reference_id_prefix drp
					INNER JOIN source_deal_type sdp On sdp.source_deal_type_id = drp.deal_type
					WHERE deal_type_id = 'Storage'

					IF @deal_pre IS NULL
						SET @deal_pre = 'ST-'

					UPDATE source_deal_header
					SET deal_id = @deal_pre + CAST(source_deal_header_id AS VARCHAR(100))
					WHERE source_deal_header_id = @new_source_deal_header_id				
				 
					INSERT INTO source_deal_groups( source_deal_groups_name
							, source_deal_header_id
							, static_group_name										
							, quantity
							)
					SELECT 1, @new_source_deal_header_id, NULL, 1

					SET @new_source_deal_groups = IDENT_CURRENT('source_deal_groups')

					INSERT INTO source_deal_detail(source_deal_header_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
							, fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left
							, settlement_volume, settlement_uom, price_adder, price_multiplier, settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked, process_deal_status
							, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, volume_multiplier2
							, pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code, pv_party, status, lock_deal_detail
							, pricing_type, pricing_period, event_defination, apply_to_all_legs, contractual_volume, contractual_uom_id, source_deal_group_id, actual_volume, detail_commodity_id
							, detail_pricing, pricing_start, pricing_end, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, cycle, schedule_volume
							, position_uom, batch_id, buyer_seller_option, crop_year, detail_inco_terms, lot, detail_sample_control, product_description
							--, pipeline_cycle_calendar_id
							)
					SELECT DISTINCT @new_source_deal_header_id source_deal_header_id, @term_start_storage term_start, @term_end_storage term_end, 1 Leg, @term_end_storage contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
						, fixed_price_currency_id, option_strike_price, ISNULL(@total_volume, deal_volume) deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left
						, settlement_volume, settlement_uom, price_adder, price_multiplier, settlement_date, day_count_id, @location_id location_id, meter_id, physical_financial_flag, Booked, process_deal_status
						, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, volume_multiplier2
						, pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code, pv_party, status, lock_deal_detail
						, pricing_type, pricing_period, event_defination, apply_to_all_legs, ISNULL(@total_volume, contractual_volume)  contractual_volume, contractual_uom_id, @new_source_deal_groups source_deal_group_id, actual_volume
						, detail_commodity_id
						, detail_pricing, pricing_start, pricing_end, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, cycle, schedule_volume
						, position_uom, batch_id, buyer_seller_option, crop_year, detail_inco_terms, lot, detail_sample_control, product_description
						--, pipeline_cycle_calendar_id
					FROM #temp_deal_header_detail_str
					WHERE base_id = @base_id_str
						AND seq_no = @seq_no

					SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail')

					SET @sql = '
								-- SELECT *   
								UPDATE a 
								SET source_deal_detail_id = ' + CAST(@new_source_deal_detail_id AS VARCHAR(1000)) + '
									, bal_quantity = ' + CAST(@total_volume AS VARCHAR(MAX)) + '
									, min_vol = ' + CAST(@total_volume AS VARCHAR(MAX)) + '
									, source_deal_header_id = ' + CAST(@new_source_deal_header_id AS VARCHAR(1000)) + '
								FROM ' + @match_properties + ' a 
								WHERE source_deal_detail_id = -1 
									AND source_deal_header_id = -1
									AND a.source_commodity_id= ' + CAST(@commodity_id AS VARCHAR(1000)) + '
									AND a.source_minor_location_id= ' + CAST(@location_id AS VARCHAR(1000)) + '
									AND a.base_id = ' + CAST(@base_id_str AS VARCHAR(1000))  +  '								 
									AND ISNULL(a.lot, NULL) = ''' + ISNULL(@str_lot, NULL) + ''''
			
					EXEC spa_print @sql
					EXEC(@sql)

 					--select @sql, @new_source_deal_detail_id, @total_volume,@new_source_deal_header_id , @commodity_id, @location_id, @base_id_str, @batch_id, @str_lot

					--EXEC('select *, source_deal_header_id, source_deal_detail_id from ' + @match_properties)
					--		rollback tran return 

					--udf header
					INSERT INTO user_defined_deal_fields(source_deal_header_id
														, udf_template_id
														, udf_value)
					SELECT @new_source_deal_header_id, udf_template_id, default_value 
					FROM user_defined_deal_fields_template   
					WHERE template_id = @template_id AND udf_type = 'h'
		
					--udf detail
					INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id
																	, udf_template_id
																	, udf_value)

					SELECT @new_source_deal_detail_id, udf_template_id, default_value 
					FROM user_defined_deal_fields_template   
					WHERE template_id = @template_id AND udf_type = 'd'
				
					IF OBJECT_ID('tempdb..#packing_uom_str') IS NOT NULL 
						DROP TABLE #packing_uom_str	

					--update packaging and package from base deal	 
					SELECT @new_source_deal_detail_id source_deal_detail_id, uddft.udf_template_id, a.udf_value, uddft.Field_label, @template_id template_id
						INTO #packing_uom_str
					FROM user_defined_deal_fields_template uddft 
					INNER JOIN (
								SELECT udddf.udf_value,udddf.udf_template_id, sdh.template_id, udft.Field_label
								FROM user_defined_deal_detail_fields udddf
								INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
								INNER JOIN #temp_deal_header_detail_str tdfd ON tdfd.source_deal_detail_id = sdd.source_deal_detail_id 
								INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
								INNER JOIN user_defined_deal_fields_template uddft ON udddf.udf_template_id = uddft.udf_template_id
								INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
								WHERE 1 = 1
									AND CAST(tdfd.lot AS VARCHAR(1000)) = @str_lot								
									AND udft.Field_label IN ('Packaging UOM', 'Package#')
								) a ON a.Field_label = uddft.Field_label
					WHERE uddft.template_id = @template_id AND udf_type = 'd'
						AND uddft.Field_label IN ('Packaging UOM', 'Package#')
						 
					--SELECT * 
					UPDATE udddf
					SET udddf.udf_value = pu.udf_value
					FROM #packing_uom_str pu 
					INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = pu.source_deal_detail_id
						AND udddf.udf_template_id = pu.udf_template_id
					 
					SET @user_login_id = dbo.FNADBUser()	 
					SET @process_id = dbo.FNAGetNewID()

					SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
					EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

					SET @total_vol_sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@new_source_deal_header_id AS VARCHAR) + ',''i'''
				
					EXEC spa_print @sql
					EXEC (@total_vol_sql) 

					-- deal transfer rule call
					EXEC spa_auto_transfer @source_deal_header_id = @new_source_deal_header_id--, @est_movement_date = @term_start_storage -- paramater not used in target SP

					FETCH NEXT
					FROM @insert_storage_deals INTO @term_start, @commodity_id, @contract_id, @location_id, @total_volume
						, @wacog, @buy_sell, @product_description, @base_id_str, @seq_no, @batch_id, @str_lot
				END
				CLOSE @insert_storage_deals
				DEALLOCATE @insert_storage_deals

				/* insert storage deals end */
			END
			
			SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id  + ''',0,null,''' +@user_login_id+''',''n'''
			SET @job_name = 'spa_update_deal_total_volume_' + @process_id 

			EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id
		END 
		
		--select top 5 * from source_deal_header order by 1 desc
		--EXEC('select * from ' + @match_properties)
		----select *, contract_id from #temp_deal_heade_detail_str
		--rollback tran return 

		SET @sql = 'INSERT INTO #update_loc_same_region
					SELECT form_location_id, multiple_single_location
					FROM ' + @match_properties + '
					WHERE form_location_id IS NOT NULL
				
					IF EXISTS(SELECT 1 FROM #update_loc_same_region WHERE value = 1)
					BEGIN 
						UPDATE a
						SET source_minor_location_id = location_id
						FROM ' + @match_properties + ' a
						CROSS APPLY #update_loc_same_region b
					END'
		EXEC spa_print @sql
		EXEC(@sql)

		CREATE TABLE #match_group ( 
							match_book_auto_id VARCHAR(1000) COLLATE DATABASE_DEFAULT,
							group_name  VARCHAR(1000) COLLATE DATABASE_DEFAULT,														 
							match_group_id INT,
							match_group_header_id INT,
							match_group_shipment_id INT,
							match_group_shipment VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							shipment_workflow_status INT,
							shipment_status INT,
							invoice_status INT,
							shipment_status_update_date					    	DATETIME,
							logistics_assignee							    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							shipment_comments							    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							no_of_loads									    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							load_type									    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							no_of_pallets								    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							pallet_type									    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							origin_location								    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							shipment_origin_counterparty_reference_id	    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							destination_location						    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							shipment_destination_counterparty_reference_id  	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							carrier_counterparty						    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							instructions_term_start						    	DATETIME,
							instructions_term_end						    	DATETIME,
							instructions_term_option					    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							instructions_cut_off_date					    	DATETIME,
							booking_no									    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							vessel_name_truck_no_plate					    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							voyage_no									    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							etd											    	DATETIME,
							eta											    	DATETIME,
							seal_no										    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							container_no								    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							bill_of_lading_no_cmr_no					    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							our_bank									    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							destination_counterparty_bank				    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							courier_reference							    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							sellers_invoice_no_agency					    	VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
							lrd_dispatch_from_plant						    	DATETIME
							)

		--EXEC('select * from ' + @match_properties)

		SET @sql = 'UPDATE ' + @match_properties + '
					SET estimated_movement_date_to	= CASE WHEN estimated_movement_date_to = ''1900-01-01 00:00:00.000'' THEN NULL ELSE estimated_movement_date_to END, 
						estimated_movement_date	= CASE WHEN estimated_movement_date = ''1900-01-01 00:00:00.000'' THEN NULL ELSE estimated_movement_date END,
						scheduled_from	= CASE WHEN scheduled_from = ''1900-01-01 00:00:00.000'' THEN NULL ELSE scheduled_from END ,
						scheduled_to = CASE WHEN scheduled_to = ''1900-01-01 00:00:00.000'' THEN NULL ELSE scheduled_to END'
		EXEC spa_print @sql		
		EXEC(@sql)	 
		 
		SET @sql = 'UPDATE sdd
					SET sdd.batch_id = a.batch_id
					FROM ' + @match_properties + ' a
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = a.source_deal_detail_id'
		EXEC spa_print @sql		
		--EXEC(@sql)	 
		
		--EXEC('select * from ' + @match_properties)
		SET @sql = 'INSERT INTO #match_group					 
					SELECT match_book_auto_id,
							MAX(group_name) group_name,
							MAX(match_group_id) match_group_id, 
							MAX(match_group_header_id)  match_group_header_id,
							match_group_shipment_id match_group_shipment_id,
							MAX(match_group_shipment) match_group_shipment,
							MAX(shipment_workflow_status) shipment_workflow_status,
							MAX(shipment_status) shipment_status,
							MAX(invoice_status) invoice_status
							-- added fields
							--shipment
							, MAX(shipment_status_update_date) shipment_status_update_date
							, MAX(logistics_assignee) logistics_assignee
							, MAX(shipment_comments) shipment_comments
							, MAX(no_of_loads) no_of_loads
							, MAX(load_type) load_type
							, MAX(no_of_pallets) no_of_pallets
							, MAX(pallet_type) pallet_type
							, MAX(origin_location) origin_location
							, MAX(shipment_origin_counterparty_reference_id) shipment_origin_counterparty_reference_id
							, MAX(destination_location) destination_location
							, MAX(shipment_destination_counterparty_reference_id) shipment_destination_counterparty_reference_id
							, MAX(carrier_counterparty) carrier_counterparty
							, MAX(instructions_term_start) instructions_term_start
							, MAX(instructions_term_end) instructions_term_end
							, MAX(instructions_term_option) instructions_term_option
							, MAX(instructions_cut_off_date) instructions_cut_off_date
							, MAX(booking_no) booking_no
							, MAX(vessel_name_truck_no_plate) vessel_name_truck_no_plate
							, MAX(voyage_no) voyage_no
							, MAX(etd) etd
							, MAX(eta) eta
							, MAX(seal_no) seal_no
							, MAX(container_no) container_no
							, MAX(bill_of_lading_no_cmr_no) bill_of_lading_no_cmr_no
							, MAX(our_bank) our_bank
							, MAX(destination_counterparty_bank) destination_counterparty_bank
							, MAX(courier_reference) courier_reference
							, MAX(sellers_invoice_no_agency) sellers_invoice_no_agency
							, MAX(lrd_dispatch_from_plant) lrd_dispatch_from_plant
					FROM ' + @match_properties + ' GROUP BY buy_sell_flag, match_book_auto_id, match_group_shipment_id'

		EXEC spa_print @sql		
		EXEC(@sql)	 

		--EXEC('select shipment_status, * from ' +@match_properties )
		-- select * from #match_group
		
		--SELECT DISTINCT group_name, CASE WHEN @mode = 'i' THEN -1 ELSE match_group_id END match_group_id FROM #match_group
		--  rollback tran return
		--/*
		--match_group table
		MERGE match_group AS stm
		USING (SELECT DISTINCT group_name, CASE WHEN @mode = 'i' THEN -1 ELSE match_group_id END match_group_id FROM #match_group) AS sd ON stm.match_group_id = sd.match_group_id
			--AND stm.group_name = CASE WHEN @mode = 'i' THEN stm.group_name ELSE sd.group_name END 
		WHEN MATCHED THEN UPDATE SET stm.group_name = sd.group_name
		WHEN NOT MATCHED THEN
		INSERT(group_name, lock_unlock)
		VALUES(REPLACE(sd.group_name, '[ID]', IDENT_CURRENT('match_group') + 1), 'u');

		--rollback tran return

		DECLARE @group_id_new INT
		IF @mode = 'i'
		BEGIN
			SET @group_id_new = IDENT_CURRENT('match_group') 
			UPDATE #match_group SET match_group_id = @group_id_new

			SET @sql = 'UPDATE a SET match_group_id = ' + CAST(@group_id_new AS VARCHAR(100)) + ' FROM ' + @match_properties + ' a'
			
			EXEC spa_print @sql		
			EXEC(@sql)

			UPDATE #match_group SET match_group_id = @group_id_new

			--UPDATE match_group SET group_name = REPLACE(group_name, '[ID]', @group_id_new)
			--WHERE match_group_id = @group_id_new

			SET @sql = 'UPDATE a SET group_name = REPLACE(group_name, ''[ID]'', ' + CAST(@group_id_new AS VARCHAR(100)) + ')  FROM ' + @match_properties + ' a
						WHERE match_group_id = ' + CAST(@group_id_new AS VARCHAR(100)) 
			EXEC spa_print @sql		
			EXEC(@sql)
		END

		CREATE TABLE #new_shipments(match_group_shipment_id INT, match_group_shipment VARCHAR(MAX) COLLATE DATABASE_DEFAULT, old_shipment_name VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
		--need to check for recall
		MERGE match_group_shipment AS stm 
		USING (SELECT match_group_shipment,
					match_group_id, 
					MAX(CASE WHEN @mode = 'i' OR match_group_shipment_id < 0 THEN -1 ELSE match_group_shipment_id END) match_group_shipment_id, 
					MAX(shipment_workflow_status) shipment_workflow_status, 
					MAX(shipment_status) shipment_status, 
					MAX(invoice_status) invoice_status,
					MAX(shipment_status_update_date) shipment_status_update_date,
					MAX(logistics_assignee) logistics_assignee,
					MAX(shipment_comments) shipment_comments,
					MAX(no_of_loads) no_of_loads,
					MAX(load_type) load_type,
					MAX(no_of_pallets) no_of_pallets,
					MAX(pallet_type) pallet_type,
					MAX(origin_location) origin_location,
					MAX(shipment_origin_counterparty_reference_id) shipment_origin_counterparty_reference_id,
					MAX(destination_location) destination_location,
					MAX(shipment_destination_counterparty_reference_id) shipment_destination_counterparty_reference_id,
					MAX(carrier_counterparty) carrier_counterparty,
					MAX(instructions_term_start) instructions_term_start,
					MAX(instructions_term_end) instructions_term_end,
					MAX(instructions_term_option) instructions_term_option,
					MAX(instructions_cut_off_date) instructions_cut_off_date,
					MAX(booking_no) booking_no,
					MAX(vessel_name_truck_no_plate) vessel_name_truck_no_plate,
					MAX(voyage_no) voyage_no,
					MAX(etd) etd,
					MAX(eta) eta,
					MAX(seal_no) seal_no,
					MAX(container_no) container_no,
					MAX(bill_of_lading_no_cmr_no) bill_of_lading_no_cmr_no,
					MAX(our_bank) our_bank,
					MAX(destination_counterparty_bank) destination_counterparty_bank,
					MAX(courier_reference) courier_reference,
					MAX(sellers_invoice_no_agency) sellers_invoice_no_agency,
					MAX(lrd_dispatch_from_plant) lrd_dispatch_from_plant 
			FROM #match_group
			GROUP BY match_group_shipment,
					match_group_id ) AS sd ON stm.match_group_shipment_id = sd.match_group_shipment_id
		WHEN MATCHED THEN 
			UPDATE SET stm.match_group_shipment = sd.match_group_shipment, stm.shipment_workflow_status = sd.shipment_workflow_status
				, stm.invoice_status = sd.invoice_status 
				, stm.shipment_status = sd.shipment_status
				, stm.is_transport_deal_created = CASE WHEN sd.shipment_status IN (47006,47001,47004,47003,47005,47002,47008) THEN 1 ELSE 0 END
				, stm.shipment_status_update_date = sd.shipment_status_update_date
				, stm.logistics_assignee = sd.logistics_assignee
				, stm.shipment_comments = sd.shipment_comments
				, stm.no_of_loads = sd.no_of_loads
				, stm.load_type = sd.load_type
				, stm.no_of_pallets = sd.no_of_pallets
				, stm.pallet_type = sd.pallet_type
				, stm.origin_location = sd.origin_location
				, stm.shipment_origin_counterparty_reference_id = sd.shipment_origin_counterparty_reference_id
				, stm.destination_location = sd.destination_location
				, stm.shipment_destination_counterparty_reference_id = sd.shipment_destination_counterparty_reference_id
				, stm.carrier_counterparty = sd.carrier_counterparty
				, stm.instructions_term_start = sd.instructions_term_start
				, stm.instructions_term_end = sd.instructions_term_end
				, stm.instructions_term_option = sd.instructions_term_option
				, stm.instructions_cut_off_date = sd.instructions_cut_off_date
				, stm.booking_no = sd.booking_no
				, stm.vessel_name_truck_no_plate = sd.vessel_name_truck_no_plate
				, stm.voyage_no = sd.voyage_no
				, stm.etd = sd.etd
				, stm.eta = sd.eta
				, stm.seal_no = sd.seal_no
				, stm.container_no = sd.container_no
				, stm.bill_of_lading_no_cmr_no = sd.bill_of_lading_no_cmr_no
				, stm.our_bank = sd.our_bank
				, stm.destination_counterparty_bank = sd.destination_counterparty_bank
				, stm.courier_reference = sd.courier_reference
				, stm.sellers_invoice_no_agency = sd.sellers_invoice_no_agency
				, stm.lrd_dispatch_from_plant = sd.lrd_dispatch_from_plant
		WHEN NOT MATCHED THEN
		INSERT(match_group_shipment, match_group_id, shipment_workflow_status, shipment_status, is_transport_deal_created, invoice_status,
				shipment_status_update_date,
				logistics_assignee,
				shipment_comments,
				no_of_loads,
				load_type,
				no_of_pallets,
				pallet_type,
				origin_location,
				shipment_origin_counterparty_reference_id,
				destination_location,
				shipment_destination_counterparty_reference_id,
				carrier_counterparty,
				instructions_term_start,
				instructions_term_end,
				instructions_term_option,
				instructions_cut_off_date,
				booking_no,
				vessel_name_truck_no_plate,
				voyage_no,
				etd,
				eta,
				seal_no,
				container_no,
				bill_of_lading_no_cmr_no,
				our_bank,
				destination_counterparty_bank,
				courier_reference,
				sellers_invoice_no_agency,
				lrd_dispatch_from_plant)
		VALUES(REPLACE(sd.match_group_shipment, '[ID]', IDENT_CURRENT('match_group_shipment') + 1) , sd.match_group_id, sd.shipment_workflow_status, sd.shipment_status, CASE WHEN @base_transportation_deal IS NOT NULL OR @is_transport_created = 1 THEN 1 ELSE 0 END, sd.invoice_status,
				sd.shipment_status_update_date,
				sd.logistics_assignee,
				sd.shipment_comments,
				sd.no_of_loads,
				sd.load_type,
				sd.no_of_pallets,
				sd.pallet_type,
				sd.origin_location,
				sd.shipment_origin_counterparty_reference_id,
				sd.destination_location,
				sd.shipment_destination_counterparty_reference_id,
				sd.carrier_counterparty,
				sd.instructions_term_start,
				sd.instructions_term_end,
				sd.instructions_term_option,
				sd.instructions_cut_off_date,
				sd.booking_no,
				sd.vessel_name_truck_no_plate,
				sd.voyage_no,
				sd.etd,
				sd.eta,
				sd.seal_no,
				sd.container_no,
				sd.bill_of_lading_no_cmr_no,
				sd.our_bank,
				sd.destination_counterparty_bank,
				sd.courier_reference,
				sd.sellers_invoice_no_agency,
				sd.lrd_dispatch_from_plant)
		OUTPUT INSERTED.match_group_shipment_id, INSERTED.match_group_shipment, sd.match_group_shipment old_shipment_name INTO #new_shipments;
		
		IF EXISTS(SELECT 1 FROM #new_shipments)
		BEGIN
			SET @sql = 'UPDATE a 
						SET a.match_group_shipment_id = ns.match_group_shipment_id
						FROM ' + @match_properties + ' a
						INNER JOIN #new_shipments ns ON ns.old_shipment_name = a.match_group_shipment'
			
			EXEC spa_print @sql		
			EXEC(@sql)
		END

 		--	UPDATE mgs 
		--SET mgs.match_group_shipment = REPLACE(mgs.match_group_shipment, '[ID]', mgs.match_group_shipment_id)
		--FROM #new_shipments ns
		--INNER JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = ns.match_group_shipment_id
	
		IF EXISTS(SELECT 1 FROM #new_shipments)
		BEGIN
			SET @sql = 'UPDATE a 
						SET a.match_group_shipment = ns.match_group_shipment
						FROM ' + @match_properties + ' a
						INNER JOIN #new_shipments ns ON ns.match_group_shipment_id = a.match_group_shipment_id
						INNER JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = ns.match_group_shipment_id'
			
			EXEC spa_print @sql		
			EXEC(@sql)
		END

		IF @is_pipeline = 'pipeline'
		BEGIN
			UPDATE mgs 
			SET is_transport_deal_created = 1
			FROM #new_shipments ns 
			INNER JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = ns.match_group_shipment_id
		END


 		--EXEC('select * from ' + @match_properties)
		--select * from #new_shipments 
		--select * from match_group_shipment order by 1 desc
		--	rollback tran return
	
		IF OBJECT_ID('tempdb..#source_deal_detail_id_pre_3') IS NOT NULL 
			DROP TABLE #source_deal_detail_id_pre_3

		CREATE TABLE #source_deal_detail_id_pre_3(source_deal_detail_id INT, split_deal_detail_volume_id INT, buy_sell CHAR(1) COLLATE DATABASE_DEFAULT)

		IF @match_group_shipment_id = 'NULL' OR @shipment_name IS NULL -- insert mode
		BEGIN 
			INSERT INTO #source_deal_detail_id_pre_3
			SELECT SUBSTRING(combined_id, 1, CHARINDEX('_', combined_id) - 1) AS source_deal_detail_id,
				SUBSTRING(combined_id, CHARINDEX('_', combined_id) + 1, LEN(combined_id)) AS split_deal_detail_volume_id,
				buy_sell
			FROM (SELECT item combined_id, 'b' buy_sell FROM dbo.FNASplit(@buy_deals, ',')
				UNION ALL
				SELECT item, 's' buy_sell FROM dbo.FNASplit(@sell_deals, ',')) a
		END
		ELSE
		BEGIN
			--check for update mode
			INSERT INTO #source_deal_detail_id_pre_3
			SELECT mgd.source_deal_detail_id, mgd.split_deal_detail_volume_id, sdd.buy_sell_flag
			FROM match_group_detail mgd
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
			--WHERE shipment_name = @shipment_name 
		END  
		  
		SELECT @buy_deals_final = STUFF((
									SELECT DISTINCT ',' + CAST(source_deal_detail_id AS VARCHAR(1000))
									FROM #source_deal_detail_id_pre_3 WHERE buy_sell = 'b'
									FOR XML PATH('')
								), 1, 1, '')

		SELECT @sell_deals_final = STUFF((
								SELECT DISTINCT ',' + CAST(source_deal_detail_id AS VARCHAR(1000))
								FROM #source_deal_detail_id_pre_3 WHERE buy_sell = 's'
								FOR XML PATH('')
			
							), 1, 1, '')	

		
		CREATE TABLE #new_match_group_header(match_group_id INT, match_group_shipment_id INT, match_group_header_id INT, match_book_auto_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT, source_minor_location_id INT)
		
		SET @sql = 'SELECT match_group_header_id  match_group_header_id
								, MAX(match_group_id) match_group_id
								, match_group_shipment_id match_group_shipment_id
								, MAX(match_book_auto_id) match_book_auto_id
								, MAX(bookout_split_total_amt) bookout_match_total_amount
								, MAX(bookout_match) match_bookout
								, MAX(mp.source_minor_location_id) source_minor_location_id
								, MAX(last_edited_by) last_edited_by
								, MAX(last_edited_on) last_edited_on
								, MAX(scheduler) scheduler
								, MAX(mp.source_minor_location_id) location
								, MAX(status) status
								, MAX(scheduled_from) scheduled_from
								, MAX(scheduled_to) scheduled_to
								, MAX(match_number) match_number
								, MAX(comments) comments
								, MAX(pipeline_cycle) pipeline_cycle
								, MAX(consignee) consignee
								, MAX(carrier) carrier
								, MAX(po_number) po_number
								, MAX(container) container
								, MAX(lineup) line_up
								--, MAX(saved_origin) commodity_origin_id
								--, MAX(saved_form) commodity_form_id
								--, MAX(ISNULL(organic, ''n'')) organic
								--, MAX(saved_commodity_form_attribute1) commodity_form_attribute1
								--, MAX(saved_commodity_form_attribute2) commodity_form_attribute2
								--, MAX(saved_commodity_form_attribute3) commodity_form_attribute3
								--, MAX(saved_commodity_form_attribute4) commodity_form_attribute4
								--, MAX(saved_commodity_form_attribute5) commodity_form_attribute5
								, MAX(estimated_movement_date) estimated_movement_date
								, MAX(container_number) container_number
								, MAX(estimated_movement_date_to) est_movement_date_to
								, MAX(match_order_sequence) seq_no
								--, MAX(quantity_uom) matched_uom
								 ,source_commodity_id
									, mp.region
									, match_group_shipment_id
									--, saved_origin	
									--, saved_form	
									--, ISNULL(organic, ''n'')	
									--, saved_commodity_form_attribute1	
									--, saved_commodity_form_attribute2	
									--, saved_commodity_form_attribute3	
									--, saved_commodity_form_attribute4	
									--, saved_commodity_form_attribute5
									, match_group_header_id
							FROM ' + @match_properties + ' mp
							--INNER JOIN source_minor_location sml ON mp.source_minor_location_id = sml.source_minor_location_id
							GROUP BY source_commodity_id
									, mp.region
									, match_group_shipment_id
									--, saved_origin	
									--, saved_form	
									--, ISNULL(organic, ''n'')	
									--, saved_commodity_form_attribute1	
									--, saved_commodity_form_attribute2	
									--, saved_commodity_form_attribute3	
									--, saved_commodity_form_attribute4	
									--, saved_commodity_form_attribute5
									, match_group_header_id'

									
		EXEC spa_print @sql	
		--EXEC(@sql)

  
		--match_group_header table 
		SET @sql = 'MERGE match_group_header AS stm 
					USING (SELECT match_group_header_id  match_group_header_id
								, MAX(match_group_id) match_group_id
								, match_group_shipment_id match_group_shipment_id
								, MAX(match_number) match_book_auto_id
								, MAX(bookout_split_total_amt) bookout_match_total_amount
								, MAX(bookout_match) match_bookout
								, MAX(mp.source_minor_location_id) source_minor_location_id
								, MAX(last_edited_by) last_edited_by
								, MAX(last_edited_on) last_edited_on
								, MAX(scheduler) scheduler
								, MAX(mp.source_minor_location_id) location
								, MAX(status) status
								, MAX(scheduled_from) scheduled_from
								, MAX(scheduled_to) scheduled_to
								, MAX(match_number) match_number
								, MAX(comments) comments
								, MAX(pipeline_cycle) pipeline_cycle
								, MAX(consignee) consignee
								, MAX(carrier) carrier
								, MAX(po_number) po_number
								, MAX(container) container
								, MAX(lineup) line_up
								--, MAX(saved_origin) commodity_origin_id
								--, MAX(saved_form) commodity_form_id
								--, MAX(ISNULL(organic, ''n'')) organic
								--, MAX(saved_commodity_form_attribute1) commodity_form_attribute1
								--, MAX(saved_commodity_form_attribute2) commodity_form_attribute2
								--, MAX(saved_commodity_form_attribute3) commodity_form_attribute3
								--, MAX(saved_commodity_form_attribute4) commodity_form_attribute4
								--, MAX(saved_commodity_form_attribute5) commodity_form_attribute5
								, MAX(estimated_movement_date) estimated_movement_date
								, MAX(container_number) container_number
								, MAX(estimated_movement_date_to) est_movement_date_to
								, MAX(match_order_sequence) seq_no
								--, MAX(quantity_uom) matched_uom
							FROM ' + @match_properties + ' mp
							--INNER JOIN source_minor_location sml ON mp.source_minor_location_id = sml.source_minor_location_id
							GROUP BY 
									--source_commodity_id
									--, 
									mp.region
									, match_group_shipment_id
									--, saved_origin	
									--, saved_form	
									--, ISNULL(organic, ''n'')	
									--, saved_commodity_form_attribute1	
									--, saved_commodity_form_attribute2	
									--, saved_commodity_form_attribute3	
									--, saved_commodity_form_attribute4	
									--, saved_commodity_form_attribute5
									, match_group_header_id
							) AS sd
							ON stm.match_group_id = sd.match_group_id
								AND stm.match_group_shipment_id = sd.match_group_shipment_id
								AND stm.match_group_header_id = CASE WHEN  ''' + @mode + ''' = ''i'' OR stm.match_group_header_id < 0 THEN -1 ELSE ISNULL(sd.match_group_header_id, -1) END 
					WHEN MATCHED THEN UPDATE 
					SET stm.match_group_id               = sd.match_group_id
						, stm.match_group_shipment_id    = sd.match_group_shipment_id
						, stm.match_book_auto_id         = sd.match_book_auto_id
						, stm.bookout_match_total_amount = sd.bookout_match_total_amount
						, stm.match_bookout              = sd.match_bookout
						, stm.source_minor_location_id   = sd.location
						, stm.last_edited_by             = sd.last_edited_by
						, stm.last_edited_on             = sd.last_edited_on
						, stm.scheduler                  = sd.scheduler
						, stm.status                     = sd.status
						, stm.scheduled_from             = sd.scheduled_from
						, stm.scheduled_to               = sd.scheduled_to
						, stm.match_number               = sd.match_number
						, stm.comments                   = sd.comments
						, stm.pipeline_cycle             = sd.pipeline_cycle
						, stm.consignee                  = sd.consignee
						, stm.carrier                    = sd.carrier
						, stm.po_number                  = sd.po_number
						, stm.container                  = sd.container
						, stm.line_up                    = sd.line_up
						--, stm.commodity_origin_id        = sd.commodity_origin_id
						--, stm.commodity_form_id          = sd.commodity_form_id
						--, stm.organic                    = sd.organic
						--, stm.commodity_form_attribute1  = sd.commodity_form_attribute1
						--, stm.commodity_form_attribute2  = sd.commodity_form_attribute2
						--, stm.commodity_form_attribute3  = sd.commodity_form_attribute3
						--, stm.commodity_form_attribute4  = sd.commodity_form_attribute4
						--, stm.commodity_form_attribute5  = sd.commodity_form_attribute5
						, stm.estimated_movement_date	 = sd.estimated_movement_date
						, stm.container_number			 = sd.container_number
						, stm.est_movement_date_to		 = sd.est_movement_date_to
						, stm.location                   = sd.location	 
						, stm.seq_no					 = sd.seq_no
						--, stm.matched_uom				 = sd.matched_uom
					WHEN NOT MATCHED THEN
					INSERT(match_group_id
							, match_group_shipment_id
							, match_book_auto_id
							, bookout_match_total_amount
							, match_bookout
							, source_minor_location_id
							, last_edited_by
							, last_edited_on
							, scheduler				
							, status
							, scheduled_from
							, scheduled_to
							, match_number
							, comments
							, pipeline_cycle
							, consignee
							, carrier
							, po_number
							, container
							, line_up
							--, commodity_origin_id
							--, commodity_form_id
							--, organic
							--, commodity_form_attribute1
							--, commodity_form_attribute2
							--, commodity_form_attribute3
							--, commodity_form_attribute4
							--, commodity_form_attribute5
							, estimated_movement_date
							, container_number
							, est_movement_date_to
							, location
							, seq_no
							--, matched_uom
							)
					VALUES(sd.match_group_id
							, sd.match_group_shipment_id
							, sd.match_book_auto_id
							, sd.bookout_match_total_amount
							, sd.match_bookout
							, sd.location
							, sd.last_edited_by
							, sd.last_edited_on
							, sd.scheduler
							, sd.status
							, sd.scheduled_from
							, sd.scheduled_to
							, sd.match_number
							, sd.comments
							, sd.pipeline_cycle
							, sd.consignee
							, sd.carrier
							, sd.po_number
							, sd.container
							, sd.line_up
							--, sd.commodity_origin_id
							--, sd.commodity_form_id
							--, sd.organic
							--, sd.commodity_form_attribute1
							--, sd.commodity_form_attribute2
							--, sd.commodity_form_attribute3
							--, sd.commodity_form_attribute4
							--, sd.commodity_form_attribute5
							, estimated_movement_date
							, container_number
							, est_movement_date_to
							, sd.location
							, sd.seq_no
							--, matched_uom
							)
				OUTPUT INSERTED.match_group_id, INSERTED.match_group_shipment_id, INSERTED.match_group_header_id
					, INSERTED.match_book_auto_id, INSERTED.source_minor_location_id INTO #new_match_group_header;'

		EXEC spa_print @sql	
		EXEC(@sql)

		--EXEC('select * from ' + @match_properties)
		--select* from #new_match_group_header
		--select * from match_group_header
		-- 		rollback tran return 

		IF EXISTS(SELECT 1 FROM #new_match_group_header)
		BEGIN			 		 
			SET @sql = 'UPDATE a 
						SET a.match_group_header_id = mgd.match_group_header_id
						FROM  ' + @match_properties + ' a
						INNER JOIN #new_match_group_header mgd ON mgd.match_group_id = a.match_group_id
							AND mgd.match_group_shipment_id = a.match_group_shipment_id
							AND mgd.match_book_auto_id = a.match_book_auto_id'
			EXEC spa_print @sql		
			EXEC(@sql)

			--update match name with new id
			SET @sql = 'UPDATE mgh 
						SET mgh.match_book_auto_id = REPLACE(mgh.match_book_auto_id, ''[ID]'', mgh.match_group_header_id)
							, mgh.match_number = CASE WHEN  ''' + @mode + ''' = ''i'' THEN REPLACE(mgh.match_book_auto_id, ''[ID]'', mgh.match_group_header_id) ELSE mgh.match_number END
						FROM  ' + @match_properties + ' a
						INNER JOIN match_group_header mgh ON mgh.match_group_id = a.match_group_id
								AND mgh.match_group_shipment_id = a.match_group_shipment_id
								AND mgh.match_book_auto_id = a.match_book_auto_id'
			EXEC spa_print @sql		
			EXEC(@sql)	

			--update match name with match name
			SET @sql = '
						UPDATE a
						SET a.match_book_auto_id = REPLACE(mgh.match_book_auto_id, ''[ID]'', mgh.match_group_header_id)
							, a.match_number = CASE WHEN  ''' + @mode + ''' = ''i'' THEN REPLACE(mgh.match_number, ''[ID]'', mgh.match_number) ELSE mgh.match_number END
						--select * 
						FROM  ' + @match_properties + ' a
						INNER JOIN match_group_header mgh ON mgh.match_group_id = a.match_group_id
								AND mgh.match_group_shipment_id = a.match_group_shipment_id
								AND mgh.match_group_header_id = a.match_group_header_id
								'
			EXEC spa_print @sql		
			EXEC(@sql)	
		END


		--select* from #new_match_group_header				
		--EXEC('select * from ' + @match_properties)

		 --rollback tran return 
		
		SET @sql = 'INSERT INTO #get_total_amount_after_conversion
					SELECT seq_no, org_uom_id, quantity_uom
						, bookout_split_total_amt * (1 / ISNULL(qc.conversion_factor, 1)) total_bookout_amount_after_conversion
						, bal_quantity * (1 / ISNULL(qc.conversion_factor, 1)) total_qty_bookout_amount_after_conversion
						, a.split_deal_detail_volume_id
						, a.match_book_auto_id
						, a.source_deal_detail_id
						, actualized_amt * (1 / ISNULL(qc.conversion_factor, 1)) actualized_amt
						, ISNULL(qc.conversion_factor, 1)
						, sddv.comments
						, a.parent_recall_id
					FROM ' + @match_properties + ' a
					LEFT JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
					LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = a.org_uom_id'

		
		EXEC spa_print @sql	
		EXEC(@sql)

		--select * from #get_total_amount_after_conversion
		-- rollback tran return 

		IF @mode = 'i'
		BEGIN 
			--split deals for unsplit deals 
			SET @sql = '
						INSERT INTO split_deal_detail_volume(source_deal_detail_id
															, quantity
															, finalized
															, bookout_id
															, is_parent
															, comments)
						SELECT source_deal_detail_id, total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion quantity,  ''n'' finilized,  match_book_auto_id, ''y'' is_parent, a.notes
						FROM #get_total_amount_after_conversion a
						WHERE total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
							AND split_deal_detail_volume_id = -1
						UNION ALL
						SELECT source_deal_detail_id, total_bookout_amount_after_conversion quantity, ''n'' finilized,  match_book_auto_id, ''n'' is_parent, a.notes
						FROM #get_total_amount_after_conversion a
						WHERE total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
							AND split_deal_detail_volume_id = -1
						UNION ALL
						SELECT source_deal_detail_id, total_bookout_amount_after_conversion quantity, ''n'' finilized,  match_book_auto_id, ''n'' is_parent, a.notes 
						FROM #get_total_amount_after_conversion a
						WHERE total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion
							AND split_deal_detail_volume_id = -1
						UNION ALL
						SELECT source_deal_detail_id, 0 quantity, ''n'' finilized,  match_book_auto_id, ''y'' is_parent, a.notes 
						FROM #get_total_amount_after_conversion a
						WHERE total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion
							AND split_deal_detail_volume_id = -1
						
						'
			EXEC spa_print @sql		
			EXEC(@sql)
			--EXEC('select * from ' + @match_properties)

			--insert 0 volume parent and set parent as child if total parent volume is matched after split.
			IF EXISTS(SELECT 1 FROM  #get_total_amount_after_conversion  a
					INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
					WHERE is_parent = 'y'
						AND total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion)
			BEGIN 	
				INSERT INTO split_deal_detail_volume(source_deal_detail_id
															, quantity
															, finalized
															, bookout_id
															, is_parent
															, comments)
				SELECT a.source_deal_detail_id, 0 quantity, 'n' finilized,  match_book_auto_id, 'y' is_parent, a.notes 
				FROM  #get_total_amount_after_conversion  a
				INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
				WHERE is_parent = 'y'
					AND total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion	
								
				UPDATE sddv
				SET is_parent = 'n'
				FROM  #get_total_amount_after_conversion  a
				INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
				WHERE is_parent = 'y'
					AND total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion								
			END
						
			--calc for parent
			INSERT INTO split_deal_detail_volume(source_deal_detail_id
												, quantity
												, finalized
												, bookout_id
												, is_parent
												, comments)
			SELECT  a.source_deal_detail_id, total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion quantity, 'n' finilized,  a.match_book_auto_id, sddv.is_parent, a.notes 						
			FROM #get_total_amount_after_conversion  a
			INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
			WHERE total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion

			UPDATE sddv
			SET quantity = total_bookout_amount_after_conversion
				, is_parent = 'n'
			--SELECT quantity ,bookout_split_volume, bal_quantity, *
			FROM  #get_total_amount_after_conversion a
			INNER JOIN split_deal_detail_volume  sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
			WHERE total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
				AND a.split_deal_detail_volume_id <> -1				 

			SET @sql = '
						--SELECT ROUND(sddv.quantity, 2) , total_bookout_amount_after_conversion,sddv.split_deal_detail_volume_id, * 				 
						UPDATE a 
						SET a.split_deal_detail_volume_id = CASE WHEN a.split_deal_detail_volume_id = -1 THEN sddv.split_deal_detail_volume_id ELSE a.split_deal_detail_volume_id END
						FROM #get_total_amount_after_conversion a
						INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = a.source_deal_detail_id
							AND CAST(sddv.quantity AS NUMERIC(30, 2)) = ROUND(total_bookout_amount_after_conversion, 2)
							AND sddv.split_deal_detail_volume_id NOT IN (SELECT split_deal_detail_volume_id FROM match_group_detail)
							WHERE sddv.is_parent <> ''y''
			
							'
			EXEC spa_print @sql		
			EXEC(@sql)			 
		END 
		ELSE 
		BEGIN 
			IF @recall_flag IS NOT NULL 
			BEGIN 
				UPDATE a
				SET total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion
				FROM #get_total_amount_after_conversion a
				WHERE 1 = 1
					AND split_deal_detail_volume_id = -1
					AND source_deal_detail_id = - 1
			END 


 			--for replace deals
			IF @replaced_id IS NOT NULL
			BEGIN 
				--new amount insert
				--insert and update split deal detail volume 
				INSERT INTO split_deal_detail_volume(source_deal_detail_id
																, quantity
																, finalized
																, bookout_id
																, is_parent
																, comments)
				SELECT source_deal_detail_id, total_bookout_amount_after_conversion quantity, 'n' finilized,  match_book_auto_id, 'n' is_parent, a.notes 
				FROM #get_total_amount_after_conversion a
				WHERE 1 = 1 
					--AND total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
					AND split_deal_detail_volume_id = -1

				DECLARE @lastest_split_deal_detail_volume_id INT 
				SET @lastest_split_deal_detail_volume_id = IDENT_CURRENT('split_deal_detail_volume')
				
				--update id for newly inserted
				SET @sql = 'UPDATE '  + @match_properties + ' 
							SET split_deal_detail_volume_id =' + CAST(@lastest_split_deal_detail_volume_id AS VARCHAR(1000))
							+ ' WHERE split_deal_detail_volume_id = -1 '
				EXEC spa_print @sql		
				EXEC(@sql)	
						 
				--check if already split deal 
				IF EXISTS (SELECT 1 FROM split_deal_detail_volume sddv
							INNER JOIN #to_delete_data_collection tddc ON tddc.source_deal_detail_id = sddv.source_deal_detail_id
							WHERE sddv.is_parent = 'y')
				BEGIN 
					--update parent volume if exists
 					--SELECT sddv.source_deal_detail_id, sddv.quantity + bookout_split_volume
						--	, 'n' finilized,  NULL, 'y' is_parent 
					UPDATE sddv 
					SET sddv.quantity = sddv.quantity + bookout_split_volume
					FROM  split_deal_detail_volume sddv
					INNER JOIN #to_delete_data_collection tddc ON tddc.source_deal_detail_id = sddv.source_deal_detail_id
					WHERE sddv.is_parent = 'y'
				END 
				
				IF EXISTS(SELECT 1
						FROM #get_total_amount_after_conversion a 
						WHERE  1 = 1 
							AND split_deal_detail_volume_id = -1)
				BEGIN	
					--insert new parent split id if not exists
					INSERT INTO split_deal_detail_volume(source_deal_detail_id
																, quantity
																, finalized
																, bookout_id
																, is_parent
																, comments)
					SELECT source_deal_detail_id, total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion quantity
							, 'n' finilized,  NULL, 'y' is_parent, a.notes
					FROM #get_total_amount_after_conversion a 
					WHERE  1 = 1 
					--	AND total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
						AND split_deal_detail_volume_id = -1
					UPDATE #get_total_amount_after_conversion SET split_deal_detail_volume_id = @lastest_split_deal_detail_volume_id WHERE split_deal_detail_volume_id = -1

				END 
			END

 			--check split volume for update mode
			SET @sql = '
						IF EXISTS (SELECT 1 FROM ' + @match_properties + ' WHERE split_deal_detail_volume_id = -1)
						BEGIN 
							INSERT INTO split_deal_detail_volume(source_deal_detail_id
																, quantity
																, finalized
																, bookout_id
																, is_parent
																, comments)
							SELECT source_deal_detail_id, total_bookout_amount_after_conversion quantity, ''n'' finilized,  match_book_auto_id, ''n'' is_parent, a.notes 
							FROM #get_total_amount_after_conversion a
							WHERE total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion
								AND split_deal_detail_volume_id = -1
							UNION ALL
							SELECT source_deal_detail_id, 0 quantity, ''n'' finilized,  match_book_auto_id, ''y'' is_parent, a.notes 
							FROM #get_total_amount_after_conversion a
							WHERE total_qty_bookout_amount_after_conversion = total_bookout_amount_after_conversion
								AND split_deal_detail_volume_id = -1
			
							UPDATE sddv
							SET quantity =  quantity + (total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion)
							FROM #get_total_amount_after_conversion a
							INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = a.source_deal_detail_id
								AND sddv.quantity <> total_bookout_amount_after_conversion
								AND sddv.is_parent = ''y''
								AND a.split_deal_detail_volume_id = -1 
							 
							UPDATE a 
							SET a.split_deal_detail_volume_id = sddv.split_deal_detail_volume_id
							FROM #get_total_amount_after_conversion a
							INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = a.source_deal_detail_id
								AND CAST(sddv.quantity AS NUMERIC(30, 2)) = ROUND(total_bookout_amount_after_conversion, 2)
								AND sddv.split_deal_detail_volume_id NOT IN (SELECT split_deal_detail_volume_id FROM match_group_detail)
								--AND sddv.quantity = total_bookout_amount_after_conversion
								AND a.split_deal_detail_volume_id = -1
			 
						END

						--select quantity , total_bookout_amount_after_conversion
						UPDATE sddv
						SET quantity = total_bookout_amount_after_conversion
						FROM #get_total_amount_after_conversion a
						INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id

						--add excess amt to parent 
						UPDATE sddv
						SET quantity = quantity + (total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion)
						--select quantity,(total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion),sddv.source_deal_detail_id 
						FROM #get_total_amount_after_conversion a
						INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = a.source_deal_detail_id
							AND sddv.quantity <> total_bookout_amount_after_conversion
							AND sddv.is_parent = ''y''
						'
			EXEC spa_print @sql		
			EXEC(@sql)					 

			IF @recall_flag IS NOT NULL 
			BEGIN 		
				INSERT INTO split_deal_detail_volume(source_deal_detail_id
																, quantity
																, finalized
																, bookout_id
																, is_parent
																, comments)
				SELECT source_deal_detail_id, total_bookout_amount_after_conversion quantity, 'n' finilized,  match_book_auto_id, 'n' is_parent, a.notes 
				FROM #get_total_amount_after_conversion a
				WHERE 1 = 1 
					--AND total_qty_bookout_amount_after_conversion <> total_bookout_amount_after_conversion
					AND split_deal_detail_volume_id = -1
				UNION ALL --get partail volumes left for recall deals and mark it as parent
				SELECT source_deal_detail_id, total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion quantity, 'n' finilized,  match_book_auto_id, 'y' is_parent, a.notes 
				FROM #get_total_amount_after_conversion a
				WHERE 1 = 1 
					AND (total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion) > 0
					AND split_deal_detail_volume_id = -1
					AND parent_recall_id IS NULL 

				SET @sql = '	
							--select * 
							UPDATE mp 
							SET mp.split_deal_detail_volume_id = sddv.split_deal_detail_volume_id
							FROM #get_total_amount_after_conversion mp 
							INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = mp.source_deal_detail_id
							WHERE mp.split_deal_detail_volume_id = -1 
								AND CAST(mp.total_bookout_amount_after_conversion AS NUMERIC(30, 2)) = CAST(sddv.quantity AS NUMERIC(30, 2))								
								AND sddv.split_deal_detail_volume_id NOT IN (SELECT split_deal_detail_volume_id FROM match_group_detail)
								AND is_parent = ''n'''
				EXEC spa_print @sql		
				EXEC(@sql)				
				
				IF @recall_flag IS NOT NULL 
				BEGIN	
					INSERT INTO split_deal_detail_volume(source_deal_detail_id
																, quantity
																, finalized
																, bookout_id
																, is_parent
																, comments)
					--select quantity,(total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion),sddv.source_deal_detail_id, * 
					SELECT sddv.source_deal_detail_id, total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion
							, 'n', NULL
							, 'n'
							, sddv.comments
					FROM #get_total_amount_after_conversion a
					INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = a.source_deal_detail_id
						AND (total_qty_bookout_amount_after_conversion - total_bookout_amount_after_conversion) > 0
						AND sddv.split_deal_detail_volume_id = a.split_deal_detail_volume_id
						AND sddv.is_parent = 'y'

						 
				END	
			END 
		END 	
		--exec('select split_deal_detail_volume_id, source_deal_detail_id, *  from ' + @match_properties)
		----select top 5 * from split_deal_detail_volume order by 1 desc

		--select * from #get_total_amount_after_conversion
		--rollback tran return 			 
		/*
		IF @replaced_id IS NOT NULL 
		BEGIN 
			DECLARE @latest_match_group_header_id INT 
			SET @latest_match_group_header_id = IDENT_CURRENT('match_group_header')						
			
			IF NOT EXISTS(SELECT 1 FROM #same_location_data)
			BEGIN 
				SET @sql = 'UPDATE a 
						SET a.match_group_header_id = ' + CAST(@latest_match_group_header_id AS VARCHAR(1000))+ '
						FROM  ' + @match_properties + ' a
						WHERE split_deal_detail_volume_id=' + CAST(@lastest_split_deal_detail_volume_id AS VARCHAR(1000))
				EXEC spa_print @sql		
				EXEC(@sql)
			END			 			

			UPDATE #get_total_amount_after_conversion
			SET split_deal_detail_volume_id = @lastest_split_deal_detail_volume_id
			WHERE split_deal_detail_volume_id = -1
		END 
		*/
 

		IF OBJECT_ID('tempdb..#new_match_group_detail') IS NOT NULL
			DROP TABLE #new_match_group_detail
 
		CREATE TABLE #new_match_group_detail(match_group_header_id INT, match_group_shipment_id INT, source_deal_detail_id INT, match_group_detail_id INT, split_deal_detail_volume_id INT)
 
		SET @sql = 'MERGE match_group_detail AS stm
					USING (SELECT match_group_detail_id
								, gta.actualized_amt quantity
								, source_commodity_id
								, scheduling_period
								, a.notes
								, a.source_deal_detail_id
								, is_complete
								, total_bookout_amount_after_conversion bookout_split_volume
								, gta.split_deal_detail_volume_id
								, frequency
								, match_group_header_id
								, match_group_shipment_id
								, inco_terms_id
								, crop_year_id
								, lot
								, batch_id
								, shipment_status
								, a.parent_recall_id
								
							FROM ' + @match_properties + ' a 
							INNER JOIN #get_total_amount_after_conversion gta ON gta.seq_no = a.seq_no) AS sd ON stm.match_group_detail_id = sd.match_group_detail_id
					WHEN MATCHED THEN UPDATE 
						SET   stm.quantity                      = sd.quantity                     
							, stm.source_commodity_id           = sd.source_commodity_id          
							, stm.scheduling_period             = sd.scheduling_period            
							, stm.notes                         = sd.notes                        
							, stm.source_deal_detail_id         = sd.source_deal_detail_id        
							, stm.is_complete                   = CASE WHEN shipment_status = 47007 THEN 1 ELSE sd.is_complete END
							, stm.bookout_split_volume          = sd.bookout_split_volume         
							, stm.split_deal_detail_volume_id   = sd.split_deal_detail_volume_id  
							, stm.frequency                     = sd.frequency                    
							, stm.match_group_header_id         = sd.match_group_header_id        
							, stm.match_group_shipment_id       = sd.match_group_shipment_id   
							, stm.lot							= sd.lot
							, stm.batch_id   					= NULLIF(sd.batch_id, '''') 
							, stm.inco_terms					= sd.inco_terms_id
							, stm.crop_year					    = sd.crop_year_id
					WHEN NOT MATCHED THEN
					INSERT(					
							quantity                    
						, source_commodity_id         
						, scheduling_period           
						, notes                       
						, source_deal_detail_id       
						, is_complete                 
						, bookout_split_volume        
						, split_deal_detail_volume_id 
						, frequency                   
						, match_group_header_id       
						, match_group_shipment_id   
						, inco_terms
						, crop_year  
						, lot
						, batch_id
						, is_parent
						, parent_recall_id
					)
					VALUES(
						sd.quantity                   
						, sd.source_commodity_id        
						, sd.scheduling_period          
						, sd.notes                      
						, sd.source_deal_detail_id      
						, CASE WHEN shipment_status = 47007 THEN 1 ELSE sd.is_complete END               
						, sd.bookout_split_volume       
						, sd.split_deal_detail_volume_id
						, sd.frequency                  
						, sd.match_group_header_id      
						, sd.match_group_shipment_id
						, sd.inco_terms_id
						, sd.crop_year_id
						, sd.lot
						, NULLIF(sd.batch_id, '''') 
						, ''y''
						, sd.parent_recall_id 
					)
			OUTPUT INSERTED.match_group_header_id, INSERTED.match_group_shipment_id, INSERTED.source_deal_detail_id, INSERTED.match_group_detail_id, INSERTED.split_deal_detail_volume_id 
				INTO #new_match_group_detail;'	
		EXEC spa_print @sql		
		EXEC(@sql)
   		
		--update split_deal_detail_volume_id for process table
		SET @sql = '
					UPDATE a
					SET a.split_deal_detail_volume_id = gta.split_deal_detail_volume_id																
					FROM ' + @match_properties + ' a 
					INNER JOIN #get_total_amount_after_conversion gta ON gta.seq_no = a.seq_no'
		EXEC spa_print @sql		
		EXEC(@sql)

		SET @sql = '
					UPDATE	a 
					SET a.match_group_detail_id = nmgd.match_group_detail_id
					--SELECT * 
					FROM #new_match_group_detail nmgd
					INNER JOIN ' + @match_properties + ' a ON a.match_group_header_id = nmgd.match_group_header_id
						AND a.match_group_shipment_id = nmgd.match_group_shipment_id
						AND a.source_deal_detail_id = nmgd.source_deal_detail_id
						AND a.split_deal_detail_volume_id = nmgd.split_deal_detail_volume_id
		 '
		EXEC spa_print @sql		
		EXEC(@sql)

		SET @sql = ' 
					UPDATE a
					SET a.split_deal_detail_volume_id = gta.split_deal_detail_volume_id																
					FROM ' + @match_properties + ' a 
					INNER JOIN match_group_detail gta ON gta.match_group_detail_id = a.match_group_detail_id'
		EXEC spa_print @sql		
		EXEC(@sql)

		-- update lot for deals 
		SET @sql = ' 
				--SELECT source_deal_detail_id  
				UPDATE sdd
				SET lot = a.lot
				FROM ' + @match_properties + ' a
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = a.source_deal_detail_id
				WHERE sdd.buy_sell_flag = ''s'''
		
		EXEC spa_print @sql		
		EXEC(@sql)
		
		IF @recall_flag IS NOT NULL
		BEGIN 
			--update split_deal_detail_volume_id for process table
			SET @sql = ' 
						UPDATE a
						SET a.split_deal_detail_volume_id = gta.split_deal_detail_volume_id																
						FROM ' + @match_properties + ' a 
						INNER JOIN #get_total_amount_after_conversion gta ON gta.seq_no = a.seq_no'
			EXEC spa_print @sql		
			EXEC(@sql)
		END
		 	
			--select top 5 * from split_deal_detail_volume order by 1 desc
 
		SET @sql = 'UPDATE ' +  @match_properties 
					+ ' SET min_vol = bookout_split_total_amt
						, bal_quantity = bookout_split_total_amt'
		EXEC spa_print @sql		
		EXEC(@sql)

				--exec('select split_deal_detail_volume_id, source_deal_detail_id, *  from ' + @match_properties)

			 --rollback tran return 			 

		/* update storage deal start */
		DECLARE @storage_source_deal_detail_id INT
		CREATE TABLE #storage_source_deal_detail_id(source_deal_detail_id INT)
		
		SET @sql = 'INSERT INTO #storage_source_deal_detail_id
					SELECT source_deal_detail_id  
					FROM ' + @match_properties + '
					WHERE deal_type = ''Storage'' AND buy_sell_flag = ''s'''
		
		EXEC spa_print @sql		
		EXEC(@sql)

		SELECT @storage_source_deal_detail_id = source_deal_detail_id FROM #storage_source_deal_detail_id

		DECLARE @storage_source_deal_header_id INT
		SELECT @storage_source_deal_header_id = source_deal_header_id 
		FROM source_deal_detail WHERE source_deal_detail_id = @storage_source_deal_detail_id
	 
		/*
		IF @storage_source_deal_detail_id IS NOT NULL 
		BEGIN 
			CREATE TABLE #to_update_price (fixed_price FLOAT, formula_curve_id INT, formula_id INT, source_deal_detail_id INT)

			SET @sql = 'INSERT INTO #to_update_price
						SELECT fixed_price, formula_curve_id, formula_id, ' + CAST(@storage_source_deal_detail_id AS VARCHAR(100)) + '
						FROM source_deal_header sdh
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN ' + @match_properties + ' a ON a.source_deal_detail_id = sdd.source_deal_detail_id
							AND a. buy_sell_flag = ''b'''
			EXEC spa_print @sql		
			EXEC(@sql)

			SET @sql = 'UPDATE source_deal_detail
						SET fixed_price = a.fixed_price, formula_curve_id = a.formula_curve_id, formula_id = a.formula_id
						FROM source_deal_detail sdd
						INNER JOIN #to_update_price a ON a.source_deal_detail_id = sdd.source_deal_detail_id
						WHERE sdd.source_deal_detail_id = ' + CAST(@storage_source_deal_detail_id AS VARCHAR(100))
			--EXEC spa_print @sql		
			--EXEC(@sql)
 
			SELECT @location_id = location_id, @term_start = dbo.FNAGetSQLStandardDate(term_start) FROM source_deal_detail WHERE source_deal_detail_id = @storage_source_deal_detail_id
 
			DECLARE @term_start_date DATE
			SET @term_start_date = @term_start
 
			--EXEC spa_calc_mtm_job NULL,NULL, NULL, NULL, @storage_source_deal_header_id, @term_start_date, 4500, NULL, 'b', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
			--		, 'n', @term_start_date, @term_start_date, 's', NULL, NULL, '', NULL, '', '', NULL
			 

			--EXEC spa_calc_storage_wacog @location_id = @location_id,@flag = 's', @as_of_date = @term_start, @term_start = @term_start, @term_end = @term_start

			--update udf
			CREATE TABLE #pricing_index(pricing_index INT)
			DECLARE @pricing_index INT
			
			SET @sql = 'INSERT INTO #pricing_index
						SELECT udddf.udf_value
						FROM user_defined_deal_fields_template uddft
						INNER JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
						INNER JOIN ' + @match_properties + ' a ON udddf.source_deal_detail_id = a.source_deal_detail_id
						WHERE Field_label = ''Pricing Index'' AND  a.buy_sell_flag = ''b'''
			EXEC spa_print @sql		
			EXEC(@sql)

			SELECT @pricing_index = pricing_index FROM #pricing_index
			
			SET @sql = '
						UPDATE udddf
						SET udf_value = ' + CAST(@pricing_index AS VARCHAR(1000)) + '
						from user_defined_deal_fields_template uddft
						INNER JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
						INNER JOIN ' + @match_properties + ' a ON udddf.source_deal_detail_id = a.source_deal_detail_id
						where Field_label = ''Pricing Index'' AND  a.buy_sell_flag = ''s'''

			EXEC spa_print @sql		
			EXEC(@sql)
		END	
		*/	
		
		-- recipet deals
		DECLARE @storage_source_deal_detail_id_rec INT
		CREATE TABLE #storage_source_deal_detail_id_rec(source_deal_detail_id INT)
		
		SET @SQL = 'INSERT INTO #storage_source_deal_detail_id_rec
					SELECT source_deal_detail_id  
					FROM ' + @match_properties + '
					WHERE deal_type = ''Storage'' 
					--AND buy_sell_flag = ''b''
					'
		
		EXEC spa_print @sql		
		EXEC(@sql)
		
		DECLARE @storage_source_deal_header_id_calc INT
		DECLARE @storage_location_id_calc INT
		DECLARE @term_start_date_rec DATE
		DECLARE @term_end_date_rec DATE
		
		SET  @jobs_process_id  = dbo.FNAGETNewID()
		--DECLARE @alert_process_table VARCHAR(300)
		SET @alert_process_table = 'adiha_process.dbo.alert_scheduling_' + @jobs_process_id + '_as'
			
		EXEC ('CREATE TABLE ' + @alert_process_table + '(
					match_group_id		INT,
					mgs_match_group_shipment_id INT,
					source_deal_header_id INT,
					trader_id VARCHAR(100)
				)')
 			   
		SET @sql = 'INSERT INTO ' + @alert_process_table + ' (
 						match_group_id,
						mgs_match_group_shipment_id,
						source_deal_header_id,
						trader_id
 						)
 					SELECT DISTINCT st.match_group_id, st.match_group_shipment_id, sdd.source_deal_header_id, st2.user_login_id
 					FROM #match_group st
					INNER JOIN match_group_header mgh ON mgh.match_group_id = st.match_group_id 
					INNER JOIN  match_group_detail mgd ON mgh.match_group_header_id = mgd.match_group_header_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_traders st2 ON sdh.trader_id = st2.source_trader_id
					'

		EXEC spa_print @sql		
		EXEC(@sql)
 		
		SET @sql = 'spa_register_event 20611, 20527, ''' + @alert_process_table + ''', 1, ''' + @jobs_process_id + ''''
		
		SET @job_name = 'scheduling_alert_job_' + @jobs_process_id
		EXEC spa_run_sp_as_job @job_name, @sql, 'scheduling_alert_job', @user_name

		--EXEC('select split_deal_detail_volume_id, source_deal_detail_id, * from ' +@match_properties )
		--select * from source_deal_header order by 1 desc
		--select * from source_deal_detail order by 1 desc
		--select * from match_group_header order by 1 desc
		--select * from match_group_detail order by 1 desc
		--select * from split_deal_detail_volume order by 1 desc 
		--EXEC('select split_deal_detail_volume_id, * from ' + @match_properties)
		--ROLLBACK TRAN
		--return
		 
	--/*	
		COMMIT TRAN
		EXEC spa_ErrorHandler 0,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Success',
				'Changes has been saved successfully.',
				''
	END TRY
	BEGIN CATCH
 		--end flag c
		 SELECT ERROR_MESSAGE()
		ROLLBACK TRAN

		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Failed to Match.',
				''
		RETURN
	END CATCH
	--*/
END 
ELSE IF @flag = 't' --- call from actualize_schedule
BEGIN
	CREATE TABLE #process_id (
		process_id VARCHAR(100) COLLATE DATABASE_DEFAULT,
		return_match_group_id  INT
	)

	INSERT INTO #process_id
	EXEC spa_scheduling_workbench 's'

	SELECT @process_id = process_id 
	FROM #process_id

	EXEC spa_scheduling_workbench @flag='z', @process_id= @process_id, @filter_xml = @filter_xml, @to_select = 'n'
 
	SET @all_deal_coll_b_m = dbo.FNAProcessTableName('all_deals_b_m', @user_name, @process_id)
	
	SET @sql = ' SELECT from_source_uom_id, to_source_uom_id, conversion_factor 	
					INTO #calculated_unit_conversion
				FROM rec_volume_unit_conversion 
				WHERE to_source_uom_id = ' + CAST(ISNULL(@quantity_uom, -1) AS VARCHAR(10)) +'
				UNION   
				SELECT to_source_uom_id, from_source_uom_id, 1/conversion_factor 
				FROM rec_volume_unit_conversion 
				WHERE from_source_uom_id = ' + CAST(ISNULL(@quantity_uom, -1) AS VARCHAR(10)) +'	
	
					SELECT MAX(adc.match_group_header_id) match_group_header_id
						, adc.match_book_auto_id	
						, MAX(adc.shipment_name) shipment_name 
						, MAX(Location_Name) Location_Name	
						, MAX(commodity_name) commodity_name	
						, dbo.FNADateFormat(MIN(CAST(adc.scheduled_from AS DATETIME))) term_start	 			
						, dbo.FNADateFormat(MAX(CAST(adc.scheduled_to AS DATETIME))) term_end
						, MAX(line_up)	lineup '
	
	IF @frequency = 700
	BEGIN
		SET @sql =	@sql +  ', MAX(dbo.FNARemoveTrailingZeroes(ROUND((deal_volume) * CASE WHEN buy_sell_flag = ''s'' THEN -1 ELSE 1 END))  deal_volume
							, MAX(dbo.FNARemoveTrailingZeroes(ROUND((bookout_split_volume) * CASE WHEN buy_sell_flag = ''s'' THEN -1 ELSE 1 END)) bookout_amt						
							'

	END 
	ELSE 
	BEGIN
		SET @sql =	@sql +  ' , MAX(dbo.FNARemoveTrailingZeroes(deal_volume  * CASE WHEN buy_sell_flag = ''s'' THEN -1 ELSE 1 END))  deal_volume
							, MAX(dbo.FNARemoveTrailingZeroes(bookout_split_volume * CASE WHEN buy_sell_flag = ''s'' THEN -1 ELSE 1 END)) bookout_amt
							'
	END 
	
 	SET @sql =	@sql +  ' 
						, MAX(dbo.FNARemoveTrailingZeroes(ROUND(fixed_price, 4))) fixed_price
						, MAX(CASE WHEN cuc.conversion_factor IS NULL THEN adc.uom_name ELSE ''' + @quantity_uom_name + ''' END) uom_name
						, CASE MAX(ISNULL(is_complete, ''No'')) WHEN ''Yes'' THEN ''Yes'' ELSE ''No'' END is_finalize	
						, MAX(adc.source_minor_location_id) location_id							
						, MAX(adc.match_group_id) match_group_id
						, MAX(adc.create_user) create_user
					FROM ' + @all_deal_coll_b_m + ' adc ' + 
					CASE WHEN @actualized_match = 'y' THEN '
					INNER JOIN ticket_match tm_act ON tm_act.match_group_detail_id = adc.match_group_detail_id '
						WHEN @actualized_match = 'n' THEN '
					LEFT JOIN ticket_match tm_act ON tm_act.match_group_detail_id = adc.match_group_detail_id '
						ELSE ''
					END + '
					LEFT JOIN source_uom su ON su.uom_name = adc.uom_name
					LEFT JOIN #calculated_unit_conversion cuc ON cuc.from_source_uom_id = su.source_uom_id '
					+ CASE WHEN @ticket_number IS NOT NULL THEN 
					' INNER JOIN ticket_match tm ON tm.match_group_detail_id = adc.match_group_detail_id
					  INNER JOIN ticket_detail td ON td.ticket_detail_id = tm.ticket_detail_id
					  INNER JOIN ticket_header th ON th.ticket_header_id = td.ticket_header_id '
					ELSE '' END					
		
			+ CASE WHEN @location IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @location + ''', '','')) location ON location.item = adc.source_minor_location_id ' ELSE '' END 

			+ CASE WHEN @ticket_number IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @ticket_number + ''', '','')) ticno ON ticno.item = th.ticket_header_id ' ELSE '' END 

			+ CASE WHEN @loc_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @loc_group + ''', '','')) loc_group ON loc_group.item = adc.region ' ELSE '' END 
			+ CASE WHEN @incoterm IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @incoterm + ''', '','')) incoterm ON incoterm.item = adc.incoterm_id ' ELSE '' END 
				
			--+ CASE WHEN @quantity_uom IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @quantity_uom + ''', '','')) quantity_uom ON quantity_uom.item = adc.deal_volume_uom_id ' ELSE '' END 
			--+ CASE WHEN @price_uom IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @price_uom + ''', '','')) price_uom ON price_uom.item = adc.price_uom_id ' ELSE '' END 
			+ CASE WHEN @commodity IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity + ''', '','')) commodity ON commodity.item = adc.source_commodity_id '  ELSE '' END 
				--+ CASE WHEN @deal_type IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @deal_type + ''', '','')) deal_type ON deal_type.item = adc.source_deal_type_id '  ELSE '' END 
			+ CASE WHEN @commodity_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_group + ''', '','')) commodity_group ON commodity_group.item = adc.commodity_group1 '  ELSE '' END 
			-- [Change of requirement on : July 25, 2019] (Filter ticket number with @ticket_number not with @label_ticket_number).
			-- + CASE WHEN @label_ticket_number IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + CAST(@label_ticket_number AS VARCHAR(1000)) + ''', '','')) ltn ON th.ticket_number like ''%''+ ltn.item +''%'' '  ELSE '' END
			
			+ ' WHERE 1 = 1 
				AND source_deal_type_name <> ''Transportation''
				AND match_bookout = ''match'' 
				AND shipment_status <> ''Voided'' '
			+ CASE WHEN @actualized_match = 'n' THEN ' AND tm_act.ticket_match_id IS NULL ' ELSE '' END
				--check for is_complete of match_group_detail				
			+ '	AND adc.is_complete = ' + CASE WHEN @match_status = 'a' THEN '''No'''
										WHEN @match_status = 'b' THEN 'adc.is_complete'
					ELSE '''Yes''' END
			+ CASE WHEN @period_from IS NOT NULL THEN  ' AND adc.scheduled_from >= ''' + CAST(@period_from AS VARCHAR(12)) + '''' ELSE '' END
			+ CASE WHEN @period_to IS NOT NULL THEN  ' AND adc.scheduled_to <= ''' + CAST(@period_to AS VARCHAR(12)) + '''' ELSE '' END
			--+ CASE WHEN @label_ticket_number IS NOT NULL THEN ' AND th.ticket_number LIKE ''%' + @label_ticket_number + '%''' ELSE '' END
					 
		IF @match_number IS NOT NULL 
			SET @sql = @sql + ' AND adc.match_group_header_id IN (' + CAST(@match_number AS VARCHAR(100)) + ')'		
		
		IF @shipment_id IS NOT NULL 
			SET @sql = @sql + ' AND adc.match_group_shipment_id IN (' + CAST(@shipment_id AS VARCHAR(100)) + ')'		
					
		SET @sql =	@sql 
					+ ' GROUP BY match_book_auto_id 
						ORDER BY  MAX(match_group_shipment_id)		
								, MIN(match_order_sequence)		 											
								, match_group_header_id'
	
	--SET @sql = @sql + ' ORDER BY recipt_delivery DESC, bookout_id_show, deal_id'
	EXEC spa_print @sql		
	EXEC(@sql)	

	DROP TABLE #process_id
END  
ELSE IF @flag = 'l' --- get default uom
BEGIN 
	SELECT source_uom_id, uom_id 
	FROM source_uom WHERE uom_id = 'lbs'
END 
ELSE IF @flag = 'check_split_volume' --load split deal detail volume split grids
BEGIN 
	IF (CAST(@total_quantity / @split_quantity AS INT) < @no_of_rows)
	BEGIN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'DB Error',
			'Volume exceeds while creating split(s). Please check No of split(s) or Split quantity.',
			''
	END 
	ELSE
	BEGIN 
		EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Success',
			'Valid Data.',
			'' 
	END
END 
ELSE IF @flag = 'n' --load split deal detail volume split grids
BEGIN 
	DECLARE @total_retun_rows FLOAT 
	DECLARE @check_parent CHAR(1)

	SELECT @check_parent = is_parent 
	FROM split_deal_detail_volume
	WHERE split_deal_detail_volume_id = @split_deal_detail_volume_id
	
	SET @check_parent = ISNULL(@check_parent, 'y')

	CREATE TABLE #break_deal_volume (id INT, quantity NUMERIC(38, 18), finilized BIT, is_parent CHAR(1) COLLATE DATABASE_DEFAULT)
	IF @no_of_rows <> ''
	BEGIN 
		INSERT INTO #break_deal_volume(id, quantity, finilized, is_parent)
		SELECT id, Quantity,  CASE WHEN finilized = 'n' THEN 0 ELSE 1 END finilized, is_parent
		FROM (
			SELECT n id, @split_quantity Quantity, 'n' finilized, 'n' is_parent
			FROM dbo.seq
			WHERE n <= @no_of_rows
			UNION ALL 
			SELECT n id, @total_quantity - (CAST(@split_quantity AS NUMERIC(38, 18)) * CAST(@no_of_rows AS INT)) by_qty, 'n' finilized, @check_parent 
			FROM dbo.seq
			WHERE n = @no_of_rows + 1
		) a		
	END 
	ELSE 
	BEGIN 
		SELECT @total_retun_rows = @total_quantity/ (@total_quantity * @percentage/100)

		INSERT INTO #break_deal_volume(id, quantity, finilized, is_parent)
		SELECT id, Quantity,  CASE WHEN finilized = 'n' THEN 0 ELSE 1 END finilized, is_parent
		FROM (SELECT n id, @total_quantity * @percentage/100 Quantity, 'n' finilized, 'n' is_parent
			FROM dbo.seq
			WHERE n <= @total_retun_rows
			UNION ALL 
			SELECT n id, @total_quantity - ((@total_quantity * @percentage/100) * CAST(@total_retun_rows AS INT)) by_qty, 'n' finilized, @check_parent 
			FROM dbo.seq
			WHERE n = CAST(@total_retun_rows AS INT) + 1) a
	END

	IF EXISTS(SELECT 1 FROM #break_deal_volume 
				WHERE  is_parent = 'y' AND quantity = 0)
	BEGIN 
		UPDATE #break_deal_volume SET is_parent = 'y' WHERE id = 1

		DELETE FROM #break_deal_volume 
		WHERE is_parent = 'y' AND quantity = 0	
	END

	DELETE FROM #break_deal_volume WHERE quantity = 0	
	SELECT id, dbo.FNARemoveTrailingZero(quantity), finilized, is_parent FROM #break_deal_volume
END 
ELSE IF @flag = 'g' --save split deal detail volume split grids
BEGIN 
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value
	
		IF OBJECT_ID('tempdb..#split_deal_detail_volume') IS NOT NULL
		BEGIN 
			DROP TABLE #split_deal_detail_volume
		END

		CREATE TABLE #split_deal_detail_volume(id			INT		
												, quantity	FLOAT	
												, finalized	CHAR(1) COLLATE DATABASE_DEFAULT	
												, split_deal_detail_id INT
												, is_parent	CHAR(1) COLLATE DATABASE_DEFAULT	
												)

		INSERT INTO #split_deal_detail_volume(id, quantity, finalized, split_deal_detail_id, is_parent)
		SELECT id, quantity, CASE WHEN finalized = 1 THEN 'y' ELSE 'n' END finalized, @spilt_deal_detail_id split_deal_detail_id, is_parent
		FROM   OPENXML (@idoc, '/gridXml/GridRow', 2)
				WITH ( 
					id					INT			'@sequence',						
					quantity			NUMERIC(38,18)		'@quantity', 
					finalized			CHAR(1)		'@finilized',
					is_parent			CHAR(1)		'@is_parent')
		EXEC sp_xml_removedocument @idoc

		--select id, quantity / ISNULL(qc.conversion_factor, 1), split_deal_detail_id, is_parent, comm.comments  
		UPDATE sddv
		SET quantity = quantity / ISNULL(qc.conversion_factor, 1)
		FROM #split_deal_detail_volume sddv
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddv.split_deal_detail_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)

		/*
		IF @split_deal_detail_volume_id IS NOT NULL
		BEGIN
			IF EXISTS(SELECT 1 FROM split_deal_detail_volume 
					WHERE split_deal_detail_volume_id = @split_deal_detail_volume_id 
						AND is_parent = 'y')
			BEGIN 
				DECLARE @count_data INT
				SELECT @count_data = COUNT(1) FROM #split_deal_detail_volume
				
				UPDATE #split_deal_detail_volume
				SET is_parent = 'y'
				WHERE id = @count_data
			END
		END
		*/

		IF @split_deal_detail_volume_id = ''
			SET @split_deal_detail_volume_id = NULL
			
		INSERT INTO split_deal_detail_volume(quantity, finalized, source_deal_detail_id, is_parent, est_movement_date
											, est_movement_date_to, changed_location, scheduled_from, scheduled_to, comments, ignored_amount)
		SELECT sddv.quantity, sddv.finalized, sddv.split_deal_detail_id, sddv.is_parent, comm.est_movement_date_to
				, est_movement_date_to, comm.changed_location, comm.scheduled_from, comm.scheduled_to, comm.comments, 'n'
		FROM #split_deal_detail_volume sddv
		OUTER APPLY (SELECT est_movement_date
							, est_movement_date_to
							, changed_location
							, scheduled_from
							, scheduled_to
							, comments FROM split_deal_detail_volume WHERE split_deal_detail_volume_id = @split_deal_detail_volume_id) comm
		--rollback tran return 

		--DELETE FROM split_deal_detail_volume WHERE is_parent = 'n' AND quantity = 0
		DELETE FROM split_deal_detail_volume WHERE split_deal_detail_volume_id = @split_deal_detail_volume_id

		COMMIT TRAN
				 
		EXEC spa_ErrorHandler 0,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Success',
				'Changes has been saved successfully.',
				''
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Failed to Split.',
				''
	END CATCH
END 
ELSE IF @flag = 'u' --unsplit
BEGIN
	IF EXISTS(SELECT 1 FROM split_deal_detail_volume 
				WHERE split_deal_detail_volume_id = SUBSTRING(@deal_detail_id_split_deal_detail_volume_id, CHARINDEX('_', @deal_detail_id_split_deal_detail_volume_id) + 1, LEN(@deal_detail_id_split_deal_detail_volume_id))
					AND is_parent = 'y')
	BEGIN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'DB Error',
			'Cannot Unsplit Parent.',
			''
			RETURN
	END

	BEGIN TRY 
		BEGIN TRAN

		
		IF NOT EXISTS(SELECT 1 FROM split_deal_detail_volume 
					WHERE source_deal_detail_id = SUBSTRING(@deal_detail_id_split_deal_detail_volume_id, 1, CHARINDEX('_', @deal_detail_id_split_deal_detail_volume_id) - 1))
		BEGIN 
			EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'No Split found for Deal Detail.',
				''
				RETURN
		END


		--SELECT * 
		UPDATE sddv
		SET quantity = quantity + (@merge_quantity / ISNULL(qc.conversion_factor, 1))
		FROM split_deal_detail_volume sddv
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = sddv.source_deal_detail_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)
		WHERE sddv.source_deal_detail_id = SUBSTRING(@deal_detail_id_split_deal_detail_volume_id, 1, CHARINDEX('_', @deal_detail_id_split_deal_detail_volume_id) - 1)
			AND is_parent = 'y'


		--SELECT * 
		DELETE sddv
		FROM   split_deal_detail_volume sddv
		WHERE split_deal_detail_volume_id = SUBSTRING(@deal_detail_id_split_deal_detail_volume_id, CHARINDEX('_', @deal_detail_id_split_deal_detail_volume_id) + 1, LEN(@deal_detail_id_split_deal_detail_volume_id))

		COMMIT TRAN
			 
		EXEC spa_ErrorHandler 0,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Success',
				'Changes has been saved successfully.',
				'' 
	END TRY
	BEGIN CATCH
		--select error_message()
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Failed to Unsplit.',
				''
	END CATCH
END
ELSE IF @flag = 'j'  -- storage report grid
BEGIN
	CREATE TABLE #location_total_volume(total_volume NUMERIC(38,18), location_id INT, contract_id INT)
	SET @all_deal_coll = dbo.FNAProcessTableName('all_deals', @user_name, @process_id)

	
	SET @sql = 'INSERT INTO #location_total_volume
				SELECT  SUM(CASE WHEN sub_deal_type_id = ''Injection'' THEN 1  ELSE -1 END * [Bal Quantity]) total_volume,
						source_minor_location_id,  contract_id 
				FROM ' + @all_deal_coll + ' a
				WHERE a.deal_type = ''storage''
					AND DATEPART(yyyy, a.term_end) <= ''' + CAST(DATEPART(yyyy, @period_to) AS VARCHAR(4)) + '''
					AND DATEPART(mm, a.term_end) <= ''' + CAST(DATEPART(mm, @period_to) AS VARCHAR(2)) + '''
				GROUP BY source_minor_location_id,  contract_id
			'
	EXEC spa_print @sql		
	EXEC(@sql)
 
	SET @sql = 'SELECT 
						a.location_id
					, sml.location_name
					, a.contract_id
					, sc.contract_name
					, counterparty.counterparty_name counterparty_id
					, commodity.commodity_id
					, dbo.FNADATEFormat(a.term) term
					, ROUND(wacog, 4) wacog
					, ROUND(a.total_inventory_vol, 4) total_inventory_vol
					, ROUND(a.total_inventory_amt, 4) total_inventory_amt
					, ROUND(a.total_inventory_vol + ISNULL(ltv.total_volume, 0), 4) exp_inventory_balance
					, ltv.total_volume
					
				FROM (
					SELECT ROW_NUMBER() OVER(PARTITION  BY location_id, contract_id ORDER BY term DESC) seq_no
						, e.wacog
						, e.total_inventory_amt
						, e.total_inventory_vol
						, e.location_id
						, e.contract_id
						, e.term
					FROM calcprocess_storage_wacog e
					WHERE term <= ''' + CAST(ISNULL(@period_to, @period_from)  AS VARCHAR(100)) + '''
						) a
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = a.location_id
				INNER JOIN contract_group sc ON sc.contract_id = ISNULL(a.contract_id, sc.contract_id)
				LEFT JOIN general_assest_info_virtual_storage gaivs ON gaivs.storage_location = a.location_id
					AND gaivs.agreement = a.contract_id
				LEFT JOIN source_commodity commodity ON commodity.source_commodity_id = gaivs.commodity_id	
				LEFT JOIN source_counterparty counterparty ON counterparty.source_counterparty_id = gaivs.source_counterparty_id
				LEFT JOIN #location_total_volume ltv ON ltv.location_id = a.location_id
					AND ltv.contract_id = a.contract_id '
				+ CASE WHEN @location IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @location + ''', '','')) location ON location.item = sml.source_minor_location_id ' ELSE '' END 
				+ CASE WHEN @loc_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @loc_group + ''', '','')) loc_group ON loc_group.item = sml.region ' ELSE '' END 
				+ CASE WHEN @commodity IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity + ''', '','')) c ON c.item = commodity.source_commodity_id '  ELSE '' END 
				+ CASE WHEN @commodity_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_group + ''', '','')) commodity_group ON commodity_group.item = commodity.commodity_group1 '  ELSE '' END 
				+ ' WHERE 1 = 1 
					AND a.seq_no = 1'
	EXEC spa_print @sql		
	EXEC(@sql)
END 
ELSE IF @flag = 'k'  -- create storage deal 
BEGIN	
	SET @final_storage_inventory_grouped = dbo.FNAProcessTableName('final_storage_inventory_grouped', @user_name, @process_id)
	IF OBJECT_ID('tempdb..#storage_details') IS NOT NULL 
		DROP TABLE #storage_details

	CREATE TABLE #storage_details(source_counterparty_id INT, contract_id INT, source_deal_header_id INT)

	SET @sql = 'INSERT INTO  #storage_details(source_counterparty_id, contract_id, source_deal_header_id)
				SELECT sc.source_counterparty_id, contract_id
				,  dbo.FNAStripHTML(parent_source_deal_header_id) deal_id
				FROM ' + @final_storage_inventory_grouped + ' st
				LEFT JOIN source_counterparty sc ON sc.counterparty_id = st.operator
				LEFT  JOIN contract_group  cg ON cg.[contract_name] = st.[contract]
				WHERE st.seq_no = ' + @location_contract_commodity

	EXEC spa_print @sql		
	EXEC(@sql)
 

	--SELECT TOP 1 @storage_operator = sdh.counterparty_id 
	--FROM match_group_detail mgd 
	--INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id 
	--INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id	
	--WHERE mgd.lot = @lot AND sdd.buy_sell_flag = 's'
  
	SELECT @sub_book = clm2_value,	@template_id = clm3_value 
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Scheduling Storage Mapping'
		AND clm1_value = @injection_withdrawal

	--@injection_withdrawal
	SELECT @sub_book fas_book_id
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4
		INTO #source_system_book_id
	FROM source_system_book_map ssbm
	WHERE book_deal_type_map_id	= @sub_book

	DECLARE @description1	VARCHAR(1000)			
	--DECLARE @internal_deal_type VARCHAR(100)	
	--DECLARE @internal_sub_type VARCHAR(100)	
	--DECLARE @header_buy_sell_flag VARCHAR(100)
	SELECT 
			@deal_type			= source_deal_type_id			
		, @sub_type				= deal_sub_type_type_id			
		, @internal_deal_type	= internal_deal_type_value_id 
		, @internal_sub_type	= internal_deal_subtype_value_id
		, @header_buy_sell_flag = header_buy_sell_flag
		, @contract_id = contract_id
		, @template_header_inco_term	= inco_terms
		, @template_deal_locked			= deal_locked
	FROM source_deal_header_template sdht
	WHERE template_id = @template_id

	SELECT @template_detail_inco_term = detail_inco_terms
	FROM source_deal_detail_template
	WHERE template_id = @template_id


	DECLARE @storage_contract INT, @storage_counterparty_id INT
	 
	SELECT @storage_contract			= contract_id
		, @storage_counterparty_id		= source_counterparty_id
		, @storage_operator				= source_counterparty_id 
		, @purchase_deal_id				= source_deal_header_id
	FROM #storage_details

 

	--SELECT 
	----	sdh.deal_id, 
	--	@storage_contract = sdh.contract_id, @storage_counterparty_id = sdh.counterparty_id
	--FROM source_deal_header sdh -- storage deals
	--INNER JOIN (SELECT source_deal_header_id, source_deal_detail_id, a.item lot
	--					, x.location_id
	--					, x.detail_commodity_id
	--					, x.crop_year
	--					, x.position_uom 
	--					, x.batch_id
	--					, x.product_description
	--					, x.buy_sell_flag   	 
	--					, x.total_volume
	--			FROM source_deal_detail x 
	--			OUTER APPLY dbo.FNAsplit(x.lot, ',') 
	--				a)  sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	----INNER JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
	--INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	--INNER JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id				 				
	--WHERE sdt.deal_type_id = 'Storage'
	--	AND sdd.location_id = @location_id
	--	AND lot = @lot
	--	AND sdd.product_description = @product_description

	SELECT TOP 1 @description1 = sdh.description1 
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	WHERE 1 = 1
		AND sdd.product_description = @product_description
		AND sdh.header_buy_sell_flag = 's'
		AND sdh.description1 IS NOT NULL
		AND sdt.source_deal_type_name = 'Storage'
 
 
	IF OBJECT_ID('tempdb..#temp_deal_heade_detail') IS NOT NULL 
		DROP TABLE #temp_deal_heade_detail

	SELECT DISTINCT sdh.source_system_id, GETDATE() deal_date, sdh.ext_deal_id, sdh.physical_financial_flag, sdh.structured_deal_id
		, ISNULL(@storage_counterparty_id, sdh.counterparty_id) counterparty_id, @term_start entire_term_start,  @term_start entire_term_end, sdh.option_flag, sdh.option_type, sdh.option_excercise_type
		, CASE WHEN @injection_withdrawal = 'i' THEN NULL ELSE @description1 END description1, sdh.description2
		, sdh.description3, sdh.deal_category_value_id, sdh.trader_id, @internal_deal_type internal_deal_type_value_id, @internal_sub_type internal_deal_subtype_value_id
		, @header_buy_sell_flag header_buy_sell_flag, sdh.broker_id, sdh.generator_id, sdh.status_value_id, sdh.status_date, sdh.assignment_type_value_id, sdh.compliance_year
		, sdh.state_value_id, sdh.assigned_date, sdh.assigned_by, sdh.generation_source, sdh.aggregate_environment
		, sdh.aggregate_envrionment_comment, sdh.rec_price, sdh.rec_formula_id, sdh.rolling_avg, sdh.legal_entity, sdh.internal_desk_id, sdh.product_id
		, sdh.internal_portfolio_id, sdh.commodity_id, sdh.reference, ISNULL(@template_deal_locked, 'n') deal_locked, sdh.close_reference_id, sdh.block_type, sdh.block_define_id, sdh.granularity_id
		, sdh.Pricing, sdh.deal_reference_type_id, sdh.unit_fixed_flag, sdh.broker_unit_fees, sdh.broker_fixed_cost, sdh.broker_currency_id, sdh.deal_status, sdh.term_frequency
		, sdh.option_settlement_date, sdh.verified_by, sdh.verified_date, sdh.risk_sign_off_by, sdh.risk_sign_off_date, sdh.back_office_sign_off_by
		, sdh.back_office_sign_off_date, sdh.book_transfer_id, sdh.confirm_status_type, sdh.sub_book, sdh.deal_rules, sdh.confirm_rule, sdh.description4, sdh.timezone_id
		, sdh.reference_detail_id, sdh.counterparty_trader, sdh.internal_counterparty, sdh.settlement_vol_type, sdh.counterparty_id2, sdh.trader_id2, sdh.governing_law
		, @template_header_inco_term inco_terms, sdh.payment_days, sdh.payment_term, sdh.sample_control, sdh.scheduler, sdh.arbitration, sdh.counterparty2_trader
		--, sdh.pipeline_id
		, 'ST_Temp' deal_id, @deal_type source_deal_type_id, @sub_type deal_sub_type_type_id, ssbm.source_system_book_id1, ssbm.source_system_book_id2
		, ssbm.source_system_book_id3, ssbm.source_system_book_id4, @template_id template_id, ISNULL(@storage_contract, @contract_id) contract_id		
		--source_deal_groups
		, sdg.source_deal_groups_name
		, sdg.static_group_name
		--detail
		, sdd.source_deal_detail_id, @term_start term_start, @term_start term_end, 1 Leg, sdd.contract_expiration_date, sdd.fixed_float_leg, @header_buy_sell_flag buy_sell_flag, sdd.curve_id, sdd.fixed_price
		, sdd.fixed_price_currency_id, sdd.option_strike_price, @merge_quantity deal_volume, sdd.deal_volume_frequency, sdd.block_description, sdd.deal_detail_description, sdd.formula_id
		, sdd.volume_left, sdd.settlement_volume, sdd.settlement_uom, sdd.price_adder, sdd.price_multiplier, sdd.settlement_date, sdd.day_count_id, sdd.meter_id, sdd.physical_financial_flag  physical_financial_flag_detail
		, sdd.Booked, sdd.process_deal_status, sdd.fixed_cost, 1 multiplier, sdd.adder_currency_id, sdd.fixed_cost_currency_id, sdd.formula_currency_id, sdd.price_adder2, sdd.price_adder_currency2
		, sdd.volume_multiplier2, sdd.pay_opposite, sdd.capacity, sdd.settlement_currency, sdd.standard_yearly_volume, sdd.formula_curve_id, sdd.price_uom_id, sdd.category, sdd.profile_code, sdd.pv_party
		, sdd.status, sdd.lock_deal_detail, sdd.pricing_type, sdd.pricing_period, sdd.event_defination, sdd.apply_to_all_legs, sdd.actual_volume, sdd.detail_commodity_id
		, sdd.detail_pricing, sdd.pricing_start, sdd.pricing_end, sdd.origin, sdd.form, sdd.organic, sdd.attribute1, sdd.attribute2, sdd.attribute3, sdd.attribute4, sdd.attribute5, sdd.cycle
		, sdd.schedule_volume, sdd.batch_id, sdd.buyer_seller_option, sdd.crop_year, @template_detail_inco_term detail_inco_terms, sdd.detail_sample_control, sdd.product_description
		--, sdd.pipeline_cycle_calendar_id
		, @convert_uom deal_volume_uom_id
		, @location_id location_id
		, @merge_quantity total_volume
		, @merge_quantity contractual_volume
		, @convert_uom contractual_uom_id
		, NULL source_deal_group_id
		, @convert_uom position_uom
		, @lot lot
		INTO #temp_deal_heade_detail
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
	CROSS APPLY #source_system_book_id ssbm
	WHERE sdh.source_deal_header_id = @purchase_deal_id
		--AND product_description = @product_description --

	BEGIN TRY 
		BEGIN TRAN 
	 
		INSERT INTO source_deal_header(source_system_id, deal_id, deal_date, ext_deal_id
										, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag
										, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id
										, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year
										, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id
										, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id
										, block_type, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id, deal_status
										, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id
										, confirm_status_type, sub_book, deal_rules, confirm_rule, description4, timezone_id, reference_detail_id, counterparty_trader, internal_counterparty, settlement_vol_type
										, counterparty_id2, trader_id2, governing_law, inco_terms, payment_days, payment_term, sample_control, scheduler, arbitration, counterparty2_trader
										--, pipeline_id
										) 
		SELECT source_system_id, deal_id, deal_date, ext_deal_id
			, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id, option_flag
			, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id
			, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id, status_date, assignment_type_value_id, compliance_year
			, state_value_id, assigned_date, assigned_by, generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id
			, legal_entity, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id
			, block_type, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost, broker_currency_id, deal_status
			, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id
			, confirm_status_type, sub_book, deal_rules, confirm_rule, description4, timezone_id, reference_detail_id, counterparty_trader, internal_counterparty, settlement_vol_type
			, counterparty_id2, trader_id2, governing_law, inco_terms, payment_days, payment_term, sample_control, scheduler, arbitration, counterparty2_trader
			--, pipeline_id
		FROM #temp_deal_heade_detail
			
		SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header')

		SELECT @deal_pre = ISNULL(prefix, 'ST_') 
		FROM deal_reference_id_prefix drp
		INNER JOIN source_deal_type sdp On sdp.source_deal_type_id = drp.deal_type
		WHERE deal_type_id = 'Storage'

		IF @deal_pre IS NULL 
			SET @deal_pre = 'ST_'

		UPDATE source_deal_header
		SET deal_id = ISNULL(@deal_pre, 'ST_') + CAST(source_deal_header_id AS VARCHAR(100))
		WHERE source_deal_header_id = @new_source_deal_header_id

		INSERT INTO source_deal_groups( source_deal_groups_name
										, source_deal_header_id
										, static_group_name										
										, quantity
					) 
		SELECT source_deal_groups_name, @new_source_deal_header_id, static_group_name, 1
		FROM #temp_deal_heade_detail

		SET @new_source_deal_groups = IDENT_CURRENT('source_deal_groups')

		INSERT INTO source_deal_detail(source_deal_header_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
				, fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left
				, settlement_volume, settlement_uom, price_adder, price_multiplier, settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked, process_deal_status
				, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, volume_multiplier2
				, pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code, pv_party, status, lock_deal_detail
				, pricing_type, pricing_period, event_defination, apply_to_all_legs, contractual_volume, contractual_uom_id, source_deal_group_id, actual_volume, detail_commodity_id
				, detail_pricing, pricing_start, pricing_end, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, cycle, schedule_volume
				, position_uom, batch_id, buyer_seller_option, crop_year, detail_inco_terms, lot, detail_sample_control, product_description
				--, pipeline_cycle_calendar_id
				)

		SELECT @new_source_deal_header_id source_deal_header_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
			, fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left
			, settlement_volume, settlement_uom, price_adder, price_multiplier, settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked, process_deal_status
			, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id, price_adder2, price_adder_currency2, volume_multiplier2
			, pay_opposite, capacity, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code, pv_party, status, lock_deal_detail
			, pricing_type, pricing_period, event_defination, apply_to_all_legs, contractual_volume, contractual_uom_id, @new_source_deal_groups source_deal_group_id, actual_volume, detail_commodity_id
			, detail_pricing, pricing_start, pricing_end, origin, form, organic, attribute1, attribute2, attribute3, attribute4, attribute5, cycle, schedule_volume
			, position_uom, batch_id, buyer_seller_option, crop_year, detail_inco_terms, lot, detail_sample_control, product_description
			--, pipeline_cycle_calendar_id
		FROM #temp_deal_heade_detail
 
		SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail')

		--udf header
		INSERT INTO user_defined_deal_fields(source_deal_header_id
											, udf_template_id
											, udf_value)
		SELECT @new_source_deal_header_id, udf_template_id, default_value 
		FROM user_defined_deal_fields_template   
		WHERE template_id = @template_id AND udf_type = 'h'

		--udf detail
		INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id
													, udf_template_id
													, udf_value)
		SELECT @new_source_deal_detail_id, udf_template_id, default_value 
		FROM user_defined_deal_fields_template   
		WHERE template_id = @template_id AND udf_type = 'd'

		DECLARE @from_source_deal_detail_id INT
		SELECT @from_source_deal_detail_id = source_deal_detail_id 
		FROM #temp_deal_heade_detail 
			
			--update packaging and package from base deal	 
		SELECT @new_source_deal_detail_id source_deal_detail_id, uddft.udf_template_id, a.udf_value, uddft.Field_label, @template_id template_id
			INTO #packing_uom
		FROM user_defined_deal_fields_template uddft 
		INNER JOIN (
					SELECT udddf.udf_value,udddf.udf_template_id, sdh.template_id, udft.Field_label
					FROM user_defined_deal_detail_fields udddf
					INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
					INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
						AND udddf.udf_template_id = uddft.udf_template_id
					INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
					WHERE 1 = 1
						AND sdd.source_deal_detail_id = @from_source_deal_detail_id
						AND udft.Field_label IN ('Packaging UOM', 'Package#')
					) a ON a.Field_label = uddft.Field_label
		WHERE uddft.template_id = @template_id AND udf_type = 'd'
			AND uddft.Field_label IN ('Packaging UOM', 'Package#')					 

		--SELECT * 
		UPDATE udddf
		SET udddf.udf_value = pu.udf_value
		FROM #packing_uom pu 
		INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = pu.source_deal_detail_id
			AND udddf.udf_template_id = pu.udf_template_id

		DECLARE @to_uom INT 
		SELECT @to_uom = udf_value from #packing_uom where Field_label IN ('Packaging UOM')

		--calulate packages..
		--SELECT *  
		UPDATE udddf
		SET udddf.udf_value = CEILING(@merge_quantity/conversion_factor)
		FROM #packing_uom pu 
		INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = pu.source_deal_detail_id
		LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = @to_uom
			WHERE 1 =1 
			AND to_source_uom_id =  @convert_uom 
			AND udddf.udf_template_id = pu.udf_template_id
			AND pu.Field_label = 'Package#'
	
		--/*
		SET @user_login_id=dbo.FNADBUser()	 
		SET @process_id = dbo.FNAGetNewID()

		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
		EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

		SET @total_vol_sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@new_source_deal_header_id AS VARCHAR) + ',''i'''
		
		EXEC spa_print @sql		
		EXEC (@total_vol_sql) 

		SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id  + ''',0,null,''' +@user_login_id+''',''n'''
		SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
		EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id

		--rollback tran 
		--return
		COMMIT TRAN
		--*/

		EXEC spa_ErrorHandler 0,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Success',
				'Changes has been saved successfully.',
				'' 
	END TRY
	BEGIN CATCH
	--select error_message()
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Failed to create deal.',
				''
	END CATCH
END
ELSE IF @flag = 'x' --create match if deal grid and storage grid is selected..
BEGIN 
	SELECT SUBSTRING(combined_id, 1, CHARINDEX('_', combined_id) - 1) AS source_deal_detail_id,
			SUBSTRING(combined_id, CHARINDEX('_', combined_id) + 1, LEN(combined_id)) AS split_deal_detail_volume_id, 
			injection_withdrawal
		INTO #source_deal_detail_id_pre_4
	FROM (SELECT item combined_id, 'i'  injection_withdrawal FROM dbo.FNASplit(@buy_deals, ',') 
		UNION ALL
		SELECT item, 'w' FROM dbo.FNASplit(@sell_deals, ',')) a

	SELECT @injection_withdrawal = MAX(injection_withdrawal) FROM #source_deal_detail_id_pre_4

	SELECT @sub_book = clm2_value,	@template_id = clm3_value 
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Scheduling Storage Mapping'
		AND clm1_value = @injection_withdrawal

	--@injection_withdrawal
	SELECT fas_book_id
		, source_system_book_id1
		, source_system_book_id2
		, source_system_book_id3
		, source_system_book_id4
		INTO #source_system_book_id1
	FROM source_system_book_map ssbm
	WHERE book_deal_type_map_id	= @sub_book


	SELECT @term_start = MAX(term_start), @merge_quantity = SUM(ISNULL(sddv.quantity, sdd.total_volume))
	--select -- SUM(ISNULL(sddv.quantity, sdd.deal_volume))
	--	ISNULL(sddv.quantity, sdd.deal_volume), sdd.source_deal_detail_id,sddv.quantity, sdd.deal_volume, total_volume
	FROM  #source_deal_detail_id_pre_4 temp 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.source_deal_detail_id
	LEFT JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = temp.split_deal_detail_volume_id

	--get wacog
	SELECT  ROW_NUMBER() OVER(PARTITION  BY location_id, contract_id ORDER BY term DESC) seq_no
		, e.wacog
		INTO #wacog_calc1
	FROM calcprocess_storage_wacog e
	WHERE e.location_id = @location_id
		AND e.contract_id = @contract_id
		AND e.term <= @term_start

	--get  term_start
	SELECT @term_start = dbo.FNAGetSQLStandardDate(term_start)
	FROM (SELECT  ROW_NUMBER() OVER(PARTITION  BY location_id, contract_id ORDER BY term DESC) seq_no
			, e.wacog
		,   DATEADD(DD,1, term) term_start
	FROM calcprocess_storage_wacog e
	WHERE e.location_id = @location_id
		AND e.contract_id = @contract_id) a
		 

	SELECT @wacog = wacog FROM #wacog_calc1 WHERE seq_no = 1

	BEGIN TRY 
		BEGIN TRAN 
		/*deal creation start*/
		INSERT INTO source_deal_header(
					deal_id, source_system_id, ext_deal_id, physical_financial_flag
					, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, source_deal_type_id, deal_sub_type_type_id
					, option_flag, option_type, option_excercise_type, description1, description2, description3, deal_category_value_id, trader_id
					, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id
					, status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source
					, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id, legal_entity
					, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id, block_type
					, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost
					, broker_currency_id, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
					, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, confirm_status_type, deal_rules
					, confirm_rule, sub_book, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, deal_date)
		SELECT 'temp_deal_detail_id1', source_system_id, ext_deal_id, physical_financial_flag
					, structured_deal_id, counterparty_id, @term_start, @term_start, source_deal_type_id, deal_sub_type_type_id
					, option_flag, option_type, option_excercise_type, description1, description2, description3, deal_category_value_id, trader_id
					, internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, generator_id, status_value_id
					, status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, generation_source
					, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, rolling_avg, contract_id, legal_entity
					, internal_desk_id, product_id, internal_portfolio_id, commodity_id, reference, deal_locked, close_reference_id, block_type
					, block_define_id, granularity_id, Pricing, deal_reference_type_id, unit_fixed_flag, broker_unit_fees, broker_fixed_cost
					, broker_currency_id, deal_status, term_frequency, option_settlement_date, verified_by, verified_date, risk_sign_off_by
					, risk_sign_off_date, back_office_sign_off_by, back_office_sign_off_date, book_transfer_id, confirm_status_type, deal_rules
					, confirm_rule, fas_book_id sub_book, source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4, @term_start
			FROM source_deal_header_template sdht
			CROSS APPLY #source_system_book_id1 ssbi
		WHERE template_id = @template_id

		SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header')

		SELECT @deal_pre = ISNULL(prefix, 'T_') 
		FROM deal_reference_id_prefix drp
		INNER JOIN source_deal_type sdp On sdp.source_deal_type_id = drp.deal_type
		WHERE deal_type_id = 'Storage'

		UPDATE source_deal_header
		SET deal_id = @deal_pre + CAST(source_deal_header_id AS VARCHAR(100))
		WHERE source_deal_header_id = @new_source_deal_header_id

		INSERT INTO source_deal_detail(
						source_deal_header_id, term_start
					, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price
					, fixed_price_currency_id, option_strike_price, deal_volume_frequency, deal_volume_uom_id, block_description
					, deal_detail_description, formula_id, volume_left, settlement_volume, settlement_uom, price_adder
					, price_multiplier, settlement_date, day_count_id, location_id, meter_id, physical_financial_flag, Booked
					, process_deal_status, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id
					, price_adder2, price_adder_currency2, volume_multiplier2, pay_opposite, capacity
					, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code
					, pv_party, status, lock_deal_detail, contractual_volume, contractual_uom_id, actual_volume, deal_volume) 
		SELECT @new_source_deal_header_id, @term_start
			, @term_start, Leg, @term_start, fixed_float_leg, buy_sell_flag, curve_id, CASE WHEN @injection_withdrawal = 'w' THEN @wacog ELSE fixed_price END
			, fixed_price_currency_id, option_strike_price, deal_volume_frequency, deal_volume_uom_id, block_description
			, deal_detail_description, formula_id, volume_left, settlement_volume, settlement_uom, price_adder
			, price_multiplier, @term_start, day_count_id, @location_id, meter_id, physical_financial_flag, Booked
			, process_deal_status, fixed_cost, multiplier, adder_currency_id, fixed_cost_currency_id, formula_currency_id
			, price_adder2, price_adder_currency2, volume_multiplier2, pay_opposite, capacity
			, settlement_currency, standard_yearly_volume, formula_curve_id, price_uom_id, category, profile_code
			, pv_party, status, lock_deal_detail, @merge_quantity, contractual_uom_id, @merge_quantity, @merge_quantity
		FROM source_deal_detail_template
		WHERE template_id = @template_id


		SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail')
		
		INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id
													, udf_template_id
													, udf_value)

		SELECT @new_source_deal_detail_id, udf_template_id, default_value FROM user_defined_deal_fields_template 
		WHERE template_id = @template_id
		
		SET @user_login_id = dbo.FNADBUser()	 
		SET @process_id = dbo.FNAGetNewID()

		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id,@process_id)
		EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

		SET @total_vol_sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) SELECT ' + CAST(@new_source_deal_header_id AS VARCHAR) + ',''i'''
		
		EXEC spa_print @sql		
		EXEC (@total_vol_sql) 

		SET @spa = 'spa_update_deal_total_volume NULL,''' + @process_id  + ''',0,null,''' +@user_login_id+''',''n'''
		SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
		EXEC spa_run_sp_as_job @job_name, @spa, 'spa_update_deal_total_volume', @user_login_id
		/*deal creation end */

		/* create match start */

		INSERT INTO #source_deal_detail_id_pre_4
		SELECT @new_source_deal_detail_id, -1, CASE WHEN @injection_withdrawal = 'i' THEN 'w' ELSE 'i' END

		IF @bookout_match IS NULL 
			SET @bookout_match = 'b'
	
	
		SELECT @parent_line = sc.counterparty_id 
		FROM portfolio_hierarchy pf 
		INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = pf.entity_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id
			AND pf.entity_id = -1

	
		SELECT @row_count = COUNT(deal_volume_split_id) FROM deal_volume_split
		SELECT @row_count_group = COUNT(match_group_id) FROM match_group

		SELECT
				@ini_book_out_value = MAX(UPPER(@bookout_match) + '-' + CAST(MONTH(sdd.term_start) AS VARCHAR(100)) + '-'+ CAST(YEAR(sdd.term_start)  AS VARCHAR(100)) + '-' + ISNULL(sml.location_id, 'NOL') + '-' + ISNULL(commodity_name, 'NOC') + '-' + CASE WHEN @row_count = 0 THEN '1' ELSE CAST(IDENT_CURRENT( 'deal_volume_split' ) + 1 AS VARCHAR(100))END) 
				, 
				@ini_group_name = MAX('GRP-' + CAST(MONTH(sdd.term_start) AS VARCHAR(100)) + '-'+ CAST(YEAR(sdd.term_start)  AS VARCHAR(100)) + '-' + ISNULL(sml.location_id, 'NOL') + '-'+ ISNULL(commodity_name, 'NOC') + '-' + CASE WHEN  @row_count = 0  THEN '1' ELSE CAST(IDENT_CURRENT( 'match_group' ) + 1 AS VARCHAR(100))END) 
				--, @deal_split_id_check =  CASE WHEN  @row_count = 0  THEN '1' ELSE CAST(IDENT_CURRENT( 'deal_volume_split' ) + 1 AS VARCHAR(100)) END
				--, @match_group_id_check =  CASE WHEN  @row_count_group = 0  THEN '1' ELSE CAST(IDENT_CURRENT( 'match_group' ) + 1 AS VARCHAR(100)) END
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN #source_deal_detail_id_pre_4 temp ON temp.source_deal_detail_id = sdd.source_deal_detail_id
		LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN source_commodity commodity ON commodity.source_commodity_id = spcd.commodity_id
		GROUP BY MONTH(sdd.term_start)
 
	
		SELECT MAX(sc.counterparty_id) rec, MAX(sc1.counterparty_id) del
			INTO #max_rec_del_counterparty1
		FROM #source_deal_detail_id_pre_4 temp
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
			AND sdd.buy_sell_flag ='b'
		LEFT JOIN source_counterparty sc1 ON sc1.source_counterparty_id = sdh.counterparty_id
			AND sdd.buy_sell_flag ='s'
		GROUP BY sdd.buy_sell_flag
	

		SELECT @ini_lineup = MAX(rec) + ' - ' + @parent_line + ' - ' + MAX(del) 
		FROM  #max_rec_del_counterparty1


		INSERT INTO split_deal_detail_volume(source_deal_detail_id
											, quantity
											, finalized
											, bookout_id
											, is_parent)
		

		SELECT temp.source_deal_detail_id, sdd.deal_volume, 'n',  @ini_book_out_value, 'y'
		FROM #source_deal_detail_id_pre_4 temp 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.source_deal_detail_id
		WHERE split_deal_detail_volume_id = -1

		UPDATE temp 
		SET temp.split_deal_detail_volume_id = sddv.split_deal_detail_volume_id
		FROM #source_deal_detail_id_pre_4 temp 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.source_deal_detail_id
		INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE temp.split_deal_detail_volume_id = -1

		INSERT INTO match_group(group_name)
		SELECT @ini_group_name 

		DECLARE @match_group_id_new INT
		SET @match_group_id_new = IDENT_CURRENT('match_group')
	
		SELECT @buy_deals_final = STUFF((
									SELECT DISTINCT ',' + CAST(source_deal_detail_id AS VARCHAR(1000))
									FROM #source_deal_detail_id_pre_4 WHERE injection_withdrawal = 'i'
									FOR XML PATH('')
								), 1, 1, '')

		SELECT @sell_deals_final = STUFF((
									SELECT DISTINCT ',' + CAST(source_deal_detail_id AS VARCHAR(1000))
									FROM #source_deal_detail_id_pre_4 WHERE injection_withdrawal = 'w'
									FOR XML PATH('')
								), 1, 1, '')

		INSERT INTO deal_volume_split(source_deal_detail_id_from
									, source_deal_detail_id_to
									, bookout_id
									, bookout_date
									, bookout_amt
									, lineup
									, is_finalized
									, bookout_match
									, match_group_id)
		SELECT @buy_deals_final, @sell_deals_final, @ini_book_out_value, @term_start, @merge_quantity, @ini_lineup, 'n', @bookout_match, @match_group_id_new

		
		DECLARE @deal_volume_split_id_new INT
		SET @deal_volume_split_id_new = IDENT_CURRENT('deal_volume_split')

		IF OBJECT_ID('tempdb..#application_users1') IS NOT NULL 
			DROP TABLE #application_users1

		CREATE TABLE  #application_users1(user_login_id VARCHAR(500) COLLATE DATABASE_DEFAULT, name VARCHAR(500) COLLATE DATABASE_DEFAULT)
		INSERT INTO #application_users1
		EXEC spa_application_users @flag='a'

		SELECT @shipment_name =  'SHP - ' +  STUFF((
									SELECT DISTINCT ' - ' +  sml.location_id + '-' + CAST(@match_group_id_new AS VARCHAR(100))
									FROM #source_deal_detail_id_pre_4 temp
									INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.source_deal_detail_id
									INNER JOIN source_minor_location sml  ON sml.source_minor_location_id = sdd.location_id
									FOR XML PATH('')), 1, 2, '')
		
		INSERT INTO  match_group_detail(match_group_id
										, split_id
										, source_commodity_id
										, last_edited_by
										, last_edited_on
										, location
										, scheduled_from
										, scheduled_to
										, match_number
										, estimated_movement_date
										, scheduling_period
										, source_deal_detail_id
										, bookout_match
										, is_complete
										, line_up
										, bookout_split_volume
										, split_deal_detail_volume_id
										, shipment_name)
		SELECT @match_group_id_new 
				, @deal_volume_split_id_new
				, ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
				, au.user_login_id
				, GETDATE()
				, sdd.location_id
				, term_start
				, term_end
				, @ini_book_out_value
				, @term_start
				, CAST(DATEPART(yy, sdd.term_end) AS VARCHAR(100)) + ' - ' + CAST(DATENAME(MM, sdd.term_end) AS VARCHAR(3))
				, temp.source_deal_detail_id
				, @bookout_match
				, 0
				, @ini_lineup
				, ISNULL(sddv.quantity, sdd.total_volume)
				, temp.split_deal_detail_volume_id
				, @shipment_name
		FROM  #source_deal_detail_id_pre_4 temp
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = temp.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = temp.split_deal_detail_volume_id
		LEFT JOIN #application_users1 au ON au.user_login_id = dbo.FNADBUser()


		DECLARE @term_start_date1 DATE
			SET @term_start_date1 = @term_start
		--EXEC spa_calc_mtm_job NULL,NULL, NULL, NULL, @new_source_deal_header_id, @term_start_date1, 4500, NULL, 'b', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
		--			, 'n', @term_start_date1, @term_start_date1, 's', NULL, NULL, '', NULL, '', '', NULL

		--EXEC spa_calc_storage_wacog @location_id = @location_id, @flag = 's', @as_of_date = @term_start


		COMMIT TRAN

		EXEC spa_ErrorHandler 0,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Success',
				'Changes has been saved successfully.',
				'' 
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Failed to create deal.',
				''
	END CATCH

END
ELSE IF @flag = 'h' -- check if counterparty is valid and commodity are same
BEGIN	 

	EXEC spa_ErrorHandler 0,
		'Matching/Bookout Deals',
		'spa_scheduling_workbench',
		'Success',
		'Changes has been saved successfully.',
		@bookout_match
	RETURN 

	CREATE TABLE #source_deal_detail_id_pre_5(source_deal_detail_id INT, split_deal_detail_volume_id INT, buy_sell CHAR(1) COLLATE DATABASE_DEFAULT, location_id INT
											, total_volume FLOAT, term_start DATETIME, term_end DATETIME, commodity_id INT, region INT, counterparty_id INT
											, source_deal_header_id INT, sub_deal_name VARCHAR(1000) COLLATE DATABASE_DEFAULT)
	 
	INSERT INTO #source_deal_detail_id_pre_5(source_deal_detail_id, split_deal_detail_volume_id, buy_sell, location_id
											, total_volume, term_start, term_end, commodity_id, counterparty_id
											, source_deal_header_id, sub_deal_name)
	SELECT z.source_deal_detail_id, z.split_deal_detail_volume_id, z.buy_sell , sdd.location_id, ISNULL(sddv.quantity, sdd.total_volume)
			, sdd.term_start, sdd.term_end, ISNULL(sdd.detail_commodity_id, sdh.commodity_id) commodity_id, sdh.counterparty_id
			, sdh.source_deal_header_id, sdt.source_deal_type_name
	FROM (SELECT SUBSTRING(combined_id, 1, CHARINDEX('_', combined_id) - 1) AS source_deal_detail_id,
				SUBSTRING(combined_id, CHARINDEX('_', combined_id) + 1, LEN(combined_id)) AS split_deal_detail_volume_id, buy_sell
			FROM (SELECT item combined_id, 'b' buy_sell FROM dbo.FNASplit(@buy_deals, ',')
				UNION ALL
				SELECT item, 's' buy_sell FROM dbo.FNASplit(@sell_deals, ',')) a
		) z
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = z.source_deal_detail_id
	INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = z.source_deal_detail_id AND sddv.split_deal_detail_volume_id = z.split_deal_detail_volume_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.deal_sub_type_type_id

	  
	IF @location_contract_commodity IS NOT NULL 
	BEGIN
		DECLARE @counterparty_id INT

		SELECT @template_id = clm3_value 
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		WHERE gmh.mapping_name = 'Scheduling Storage Mapping'
			AND clm1_value = CASE WHEN @buy_deals = '' THEN 'i' ELSE 'w' END

		SELECT @counterparty_id = counterparty_id FROM source_deal_header_template where template_id = @template_id

		INSERT INTO #source_deal_detail_id_pre_5(source_deal_detail_id, split_deal_detail_volume_id, buy_sell, location_id, total_volume, term_start, term_end, commodity_id, counterparty_id)
		SELECT -1, -1, CASE WHEN @buy_deals = '' THEN 'b' ELSE 's' END, location_id, NULL total_volume, @term_start term_start, @term_start term_end, source_commodity_id, @counterparty_id
		FROM #to_generate_match_id_storage_deal_temp
	END

	CREATE TABLE #check_commodity(single_match INT, combined_match INT)
	IF (SELECT COUNT(1) FROM #source_deal_detail_id_pre_5  WHERE ISNULL(sub_deal_name, 1) <> 'Agency') > 0
	BEGIN 
		-- check commodity 
		IF EXISTS (SELECT commodity_id FROM #source_deal_detail_id_pre_5
					WHERE commodity_id NOT IN  (SELECT commodity_id FROM #source_deal_detail_id_pre_5 WHERE buy_sell = 's')
						AND buy_sell = 'b'
					UNION ALL 
					SELECT commodity_id  from #source_deal_detail_id_pre_5
					WHERE commodity_id NOT IN  (SELECT commodity_id FROM #source_deal_detail_id_pre_5 WHERE buy_sell = 'b')
						AND buy_sell = 's')
		BEGIN 
			INSERT INTO #check_commodity(single_match, combined_match)
			SELECT 0, 1
		END 

		IF @product_type = 1
		BEGIN 
 			IF EXISTS(SELECT  1
					FROM commodity_recipe_product_mix cepm
					LEFT JOIN #source_deal_detail_id_pre_5 sddid ON sddid.buy_sell = 'b' AND  sddid.commodity_id = cepm.recipe_commodity_id
						AND cepm.source_commodity_id IN (SELECT commodity_id FROM #source_deal_detail_id_pre_5 WHERE buy_sell = 's')
					WHERE sddid.source_deal_detail_id IS NULL)
			BEGIN 
				UPDATE #check_commodity SET combined_match = 0
			END		
		END

		IF EXISTS(SELECT * FROM #check_commodity WHERE single_match = 0 AND combined_match = 0)
		BEGIN
			EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Error',
				'Selected commodity(s) in grids does not match.',
				''
			RETURN
		END 
	END 
	
	IF EXISTS(SELECT 1 FROM #source_deal_detail_id_pre_5 sddip 
				LEFT JOIN counterparty_credit_info cci ON cci.Counterparty_id = sddip.counterparty_id
				WHERE account_status = 10085 ) --   'No Trade' deals
	BEGIN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Counterparty status is No Trade.',
			@bookout_match		
			 
		RETURN
	END
	 	  
	 
	 
END  
ELSE IF @flag = 'e' -- update editable fields for receipt and delivery grid(sc)
BEGIN  
	BEGIN TRY
		BEGIN TRAN

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_value
	
		SELECT  source_deal_detail_id
				, CASE WHEN est_movement_date = '' THEN NULL ELSE est_movement_date END est_movement_date
				, CASE WHEN est_movement_date_to = '' THEN NULL ELSE est_movement_date_to END est_movement_date_to
				, CASE WHEN split_deal_detail_volume_id = 0 THEN NULL ELSE split_deal_detail_volume_id END split_deal_detail_volume_id
				, changed_quantity
				, location changed_location
				, CASE WHEN scheduled_from = '' THEN NULL ELSE scheduled_from END scheduled_from 	
				, CASE WHEN scheduled_to = '' THEN NULL ELSE scheduled_to END scheduled_to					
				, comments		
				, split_finilized_status
			INTO #deal_est_movement_date
		FROM   OPENXML (@idoc, '/gridXml/GridRow', 1)
				WITH ( 
					source_deal_detail_id INT			'@source_deal_detail_id',						
					est_movement_date VARCHAR(1000)		'@est_movement_date', 
					est_movement_date_to VARCHAR(1000)	'@est_movement_date_to', 
					split_deal_detail_volume_id INT		'@split_deal_detail_volume_id',
					changed_quantity FLOAT				'@changed_quantity',
					location INT						'@location',
					scheduled_from 	VARCHAR(1000)		'@scheduled_from',
					scheduled_to	VARCHAR(1000)		'@scheduled_to',
					split_finilized_status	VARCHAR(1000)	'@split_finilized_status',
					comments		VARCHAR(MAX)		'@comments'
					)
		EXEC sp_xml_removedocument @idoc
		
		UPDATE ded
		SET ded.changed_quantity = changed_quantity * (1/ISNULL(qc.conversion_factor, 1)) 
		--SELECT changed_quantity * (1/ISNULL(qc.conversion_factor, 1)) 
		FROM #deal_est_movement_date ded
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ded.source_deal_detail_id
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
		LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)

		  
		IF EXISTS(SELECT 1 FROM #deal_est_movement_date demd 
				INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = demd.source_deal_detail_id
				WHERE demd.split_deal_detail_volume_id IS NULL)
		BEGIN 
			--SELECT * 
			UPDATE demd
			SET demd.split_deal_detail_volume_id = sddv.split_deal_detail_volume_id
			FROM #deal_est_movement_date demd 
			INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = demd.source_deal_detail_id
			WHERE demd.split_deal_detail_volume_id IS NULL			 
		END
		   
		MERGE split_deal_detail_volume AS T
		USING #deal_est_movement_date AS S
		ON (T.split_deal_detail_volume_id = S.split_deal_detail_volume_id
			AND T.source_deal_detail_id = S.source_deal_detail_id) 
		WHEN NOT MATCHED BY TARGET 
			THEN INSERT(source_deal_detail_id
											, quantity
											, finalized
											, is_parent
											, est_movement_date
											, est_movement_date_to
											, changed_location
											, scheduled_from 	
											, scheduled_to	
											, comments
											) 
			VALUES(s.source_deal_detail_id
				, s.changed_quantity
				, s.split_finilized_status	
				, 'y' 
				, s.est_movement_date
				, s.est_movement_date_to
				, s.changed_location
				, s.scheduled_from 	
				, s.scheduled_to	
				, s.comments				
				)
		WHEN MATCHED 
			THEN UPDATE SET T.quantity = S.changed_quantity,
							T.est_movement_date = S.est_movement_date,
							T.est_movement_date_to = S.est_movement_date_to,
							T.changed_location = S.changed_location,
							T.scheduled_from	= S.scheduled_from,	
							T.scheduled_to		= S.scheduled_to,		
							T.comments			= S.comments, 
							T.finalized			= S.split_finilized_status;
	
		--rollback tran return
		 
		EXEC spa_ErrorHandler 0,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Success',
				'Changes has been saved successfully.',
				'' 
		COMMIT TRAN 
	END TRY
	BEGIN CATCH
		--select ERROR_MESSAGE()
		ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				'Failed to add estimated movement date.',
				''
	END CATCH
END
ELSE IF @flag = '1' --get default value for dependent columnss
BEGIN
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)

	SET @sql = 'SELECT ' + CASE WHEN @column_name  = 'saved_commodity_origin_id' THEN 'MAX(saved_origin)' 
								WHEN @column_name  = 'saved_commodity_form_id' THEN 'MAX(saved_form)'  
								WHEN @column_name  = 'saved_commodity_form_attribute1' THEN 'MAX(saved_commodity_form_attribute1)'  
								WHEN @column_name  = 'saved_commodity_form_attribute2' THEN 'MAX(saved_commodity_form_attribute2)'  
								WHEN @column_name  = 'saved_commodity_form_attribute3' THEN 'MAX(saved_commodity_form_attribute3)'  
								WHEN @column_name  = 'saved_commodity_form_attribute4' THEN 'MAX(saved_commodity_form_attribute4)'  
								WHEN @column_name  = 'saved_commodity_form_attribute5' THEN 'MAX(saved_commodity_form_attribute5)'  
								
					ELSE  '1' END   
				+ ' id , ''' + @column_name + ''' column_name
				FROM ' + @match_properties + '  
				WHERE 1 = 1
					--AND buy_sell_flag = ''b''
					AND deal_type <> ''Transportation''
					AND region = '  + CAST(@region AS VARCHAR(1000)) + '
					AND source_commodity_id = ' + CAST(@commodity_id AS VARCHAR(1000)) +  '
					AND match_group_header_id =  ' + CAST(@match_group_header_id AS VARCHAR(1000))

	EXEC spa_print @sql
	EXEC(@sql)
END 
ELSE IF @flag = '2' --get shipment details
BEGIN
	SELECT 
		match_group_shipment_id
		, match_group_shipment
		, shipment_status
		, shipment_workflow_status
	FROM match_group_shipment
END
ELSE IF @flag = '3' --Get Match Group ID of Shipment ID
BEGIN
	SELECT match_group_id
	FROM match_group_shipment WHERE match_group_shipment_id = @match_group_shipment_id
END
ELSE IF @flag = 'transbasedeal' --not in use 
BEGIN
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)
	--Select  @match_properties  


	CREATE TABLE #is_trans_deal_created_check(
											[ErrorCode]		   VARCHAR(MAX) COLLATE DATABASE_DEFAULT
											, [Module]		   VARCHAR(MAX) COLLATE DATABASE_DEFAULT
											, [Area]		   VARCHAR(MAX) COLLATE DATABASE_DEFAULT
											, [Status]		   VARCHAR(MAX) COLLATE DATABASE_DEFAULT
											, [Message]		   VARCHAR(MAX) COLLATE DATABASE_DEFAULT
											, [Recommendation] VARCHAR(MAX) COLLATE DATABASE_DEFAULT
											)
 		
	INSERT INTO #is_trans_deal_created_check
	EXEC spa_scheduling_workbench @flag = 'iscreatedtransdeal', @process_id = @process_id, @match_group_shipment_id= @match_group_shipment_id
		
	IF EXISTS(SELECT 1 FROM #is_trans_deal_created_check WHERE [ErrorCode] = 'Error')
	BEGIN 
	EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Transportation deal already created.',
			@bookout_match
			RETURN
	END

		 
	CREATE TABLE #error_log1(status CHAR(1) COLLATE DATABASE_DEFAULT, [message] VARCHAR(MAX) COLLATE DATABASE_DEFAULT)
	
	SET @sql = 'INSERT INTO #error_log1
				SELECT 
					CASE WHEN COUNT(bookout_split_volume) > 1 THEN ''e'' ELSE ''s'' END status, 
					CASE WHEN COUNT(bookout_split_volume) > 1 THEN ''Receipts and Delivery Quantity does not match'' ELSE ''Receipts and Delivery Quantity match'' END message 
					FROM (
						SELECT bookout_split_volume
						FROM (SELECT SUM(bookout_split_volume)	bookout_split_volume 					
								FROM ' + @match_properties + ' 
								GROUP BY buy_sell_flag
							) a GROUP BY bookout_split_volume
				)b'
					
	EXEC spa_print @sql
	EXEC(@sql)	


	SET @sql = 'INSERT INTO #error_log1
				SELECT 
					''e'' status, 
					''Transport Deal not required'' message 
					FROM  ' + @match_properties + ' 
				WHERE multiple_single_location = 1'
					
	EXEC spa_print @sql
	EXEC(@sql)	
		
				
	IF EXISTS(SELECT 1 FROM #error_log1 WHERE status = 'e')
	BEGIN 
		SELECT @error_msg = [message] FROM #error_log1 WHERE status = 'e'
									 
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'DB Error',
				@error_msg,
				''
			RETURN
	END

	IF @call_from <> 'c'
	BEGIN 
		IF EXISTS(SELECT 1 FROM #error_log1 WHERE status = 's')
		BEGIN 
			SELECT @error_msg = [message] FROM #error_log1 WHERE status = 's'
									 
			EXEC spa_ErrorHandler 0,
					'Matching/Bookout Deals',
					'spa_scheduling_workbench',
					'Proceed',
					@error_msg,
					''
				RETURN
		END
	END 
		

	CREATE TABLE #collect_location_require_trans_deal(rec_source_deal_detail_id INT
													, del_source_deal_detail_id INT
													, rec_location_id INT
													, del_location_id INT
													, has_deal INT
													, buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT
													, bookout_split_total_amt FLOAT
													, commodity_id INT
													, r_term_start DATETIME
													, d_term_start DATETIME)

	SET @sql = 'INSERT INTO #collect_location_require_trans_deal
				SELECT rec.source_deal_detail_id rec_source_deal_detail_id 
					, del.source_deal_detail_id  del_source_deal_detail_id 
					, rec.source_minor_location_id rec_location_id
					, del.source_minor_location_id del_location_id
					, '''' has_deal
					, rec.buy_sell_flag
					, bookout_split_total_amt 			
					, rec.source_commodity_id commodity_id
					, rec.scheduled_from r_term_start
					, del.scheduled_from d_term_start
				FROM ' + @match_properties + ' rec
				CROSS APPLY (
							SELECT source_deal_detail_id, source_minor_location_id, source_commodity_id, region, scheduled_from
							FROM ' + @match_properties + '
							WHERE buy_sell_flag = ''s'') del
				WHERE rec.buy_sell_flag = ''b''
					AND rec.region <> del.region
					--AND rec.source_commodity_id = del.source_commodity_id 
					'

	EXEC spa_print @sql
	EXEC(@sql)

	SET @transportation_deal_collect_tbl = dbo.FNAProcessTableName('transportation_deal_collect', dbo.FNADBUser(), @process_id)
	SET @sql = ' IF OBJECT_ID(''' + @transportation_deal_collect_tbl + ''', ''U'') IS NOT NULL
						DROP TABLE ' + @transportation_deal_collect_tbl 
	
	EXEC (@sql)
	
	SET @sql = ' CREATE TABLE ' + @transportation_deal_collect_tbl + ' (source_deal_header_id INT, from_location INT, to_location INT, term_start DATETIME,
																		total_volume NUMERIC(38,10), commodity_id INT, source_deal_detail_id INT, buy_sell_flag CHAR(1)
																		, trader VARCHAR(1000), counterparty VARCHAR(1000)
																		, deal_id VARCHAR(1000))'			
	EXEC(@sql)
 
	DECLARE @rec_location_id INT
	DECLARE @del_location_id INT
	DECLARE @bookout_split_total_amt FLOAT
	DECLARE @r_term_start DATETIME
	DECLARE @d_term_start DATETIME
	DECLARE @transportaion_deal_check CURSOR
 
	SET @transportaion_deal_check = CURSOR FOR
	SELECT rec_location_id, del_location_id, bookout_split_total_amt, r_term_start, d_term_start, commodity_id
	FROM #collect_location_require_trans_deal
	OPEN @transportaion_deal_check
	FETCH NEXT
	FROM @transportaion_deal_check INTO @rec_location_id, @del_location_id, @bookout_split_total_amt, @r_term_start, @d_term_start, @commodity_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
  		IF EXISTS(SELECT source_deal_header_id 
					FROM (SELECT sdd.source_deal_header_id, sdd.term_start
						FROM source_deal_header sdh 
						INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
						INNER JOIN internal_deal_type_subtype_types main ON main.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id							
						INNER JOIN internal_deal_type_subtype_types sub ON sub.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
							AND sub.type_subtype_flag = 'y'
						WHERE sdd.location_id IN (@rec_location_id)
							AND sdd.buy_sell_flag = 's'
							AND DATEPART(yyyy, @r_term_start) BETWEEN DATEPART(yyyy,sdd.term_start) AND DATEPART(yyyy,sdd.term_end)
							AND  DATEPART(mm, @r_term_start) BETWEEN DATEPART(mm, sdd.term_start) AND DATEPART(mm, sdd.term_end) 
							--AND CASE WHEN sdd.detail_commodity_id = 0 THEN sdh.commodity_id ELSE ISNULL(sdd.detail_commodity_id, sdh.commodity_id) END = @commodity_id
							AND sdt.deal_type_id = 'Transportation'
							AND deal_volume <> 0
							AND main.internal_deal_type_subtype_type = 'Transportation'
							AND sub.internal_deal_type_subtype_type = 'Base'
						UNION ALL
						SELECT sdd.source_deal_header_id, sdd.term_start
						FROM source_deal_header sdh 
						INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
						INNER JOIN internal_deal_type_subtype_types main ON main.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
						INNER JOIN internal_deal_type_subtype_types sub ON sub.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
							AND sub.type_subtype_flag = 'y'
						WHERE location_id IN (@del_location_id)
							AND buy_sell_flag = 'b'
							AND sdt.deal_type_id = 'Transportation'
							--AND deal_volume <> 0
							AND DATEPART(yyyy, @d_term_start) BETWEEN DATEPART(yyyy,sdd.term_start) AND DATEPART(yyyy,sdd.term_end)
							AND  DATEPART(mm, @d_term_start) BETWEEN DATEPART(mm, sdd.term_start) AND DATEPART(mm, sdd.term_end) 
							--AND CASE WHEN sdd.detail_commodity_id = 0 THEN sdh.commodity_id ELSE ISNULL(sdd.detail_commodity_id, sdh.commodity_id) END =  @commodity_id
							AND main.internal_deal_type_subtype_type = 'Transportation'
							AND sub.internal_deal_type_subtype_type = 'Base'
					) a
					GROUP BY source_deal_header_id HAVING COUNT(source_deal_header_id) > 1)
		BEGIN 
			UPDATE #collect_location_require_trans_deal
			SET has_deal = 1
			WHERE rec_location_id = @rec_location_id
				AND del_location_id = @del_location_id

			SET @sql = '  	
						SELECT source_deal_header_id
						INTO #temp_trans_tbl
						FROM (SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.term_start
							FROM source_deal_header sdh 
							INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
							INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
							INNER JOIN internal_deal_type_subtype_types main ON main.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
							INNER JOIN internal_deal_type_subtype_types sub ON sub.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
								AND sub.type_subtype_flag = ''y''
							WHERE sdd.location_id IN (' + CAST(@rec_location_id AS VARCHAR(100)) + ')
								AND sdd.buy_sell_flag = ''s''
								AND DATEPART(yyyy, ''' + CAST(@r_term_start AS VARCHAR(100)) + ''') BETWEEN DATEPART(yyyy, sdd.term_start) AND DATEPART(yyyy, sdd.term_end) 
								AND DATEPART(mm, ''' + CAST(@r_term_start AS VARCHAR(100)) + ''') BETWEEN DATEPART(mm, sdd.term_start) AND DATEPART(mm, sdd.term_end) 
								--AND DATEPART(yyyy, sdd.term_start) = DATEPART(yyyy, ''' + CAST(@r_term_start AS VARCHAR(100)) + ''')
								--AND DATEPART(mm, sdd.term_start) = DATEPART(mm, ''' + CAST(@r_term_start AS VARCHAR(100)) + ''')
							--	AND CASE WHEN sdd.detail_commodity_id = 0 THEN sdh.commodity_id ELSE ISNULL(sdd.detail_commodity_id, sdh.commodity_id) END =  ' + CAST(@commodity_id AS VARCHAR(100)) + '
								AND sdt.deal_type_id = ''Transportation''
								AND deal_volume <> 0
								AND main.internal_deal_type_subtype_type = ''Transportation''
								AND sub.internal_deal_type_subtype_type = ''Base''
							UNION ALL
							SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.term_start
							FROM source_deal_header sdh 
							INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
							INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
							INNER JOIN internal_deal_type_subtype_types main ON main.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
							INNER JOIN internal_deal_type_subtype_types sub ON sub.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
								AND sub.type_subtype_flag = ''y''
							WHERE location_id IN (' + CAST(@del_location_id AS VARCHAR(100)) + ')
								AND buy_sell_flag = ''b''
								AND sdt.deal_type_id = ''Transportation''
								AND deal_volume <> 0
								--AND CASE WHEN sdd.detail_commodity_id = 0 THEN sdh.commodity_id ELSE ISNULL(sdd.detail_commodity_id, sdh.commodity_id) END =  ' + CAST(@commodity_id AS VARCHAR(100)) + '
								AND DATEPART(yyyy, ''' + CAST(@d_term_start AS VARCHAR(100)) + ''') BETWEEN DATEPART(yyyy, sdd.term_start) AND DATEPART(yyyy, sdd.term_end) 
								AND DATEPART(mm, ''' + CAST(@d_term_start AS VARCHAR(100)) + ''') BETWEEN DATEPART(mm, sdd.term_start) AND DATEPART(mm, sdd.term_end) 
								AND main.internal_deal_type_subtype_type = ''Transportation''
								AND sub.internal_deal_type_subtype_type = ''Base''
								) a
						GROUP BY source_deal_header_id HAVING COUNT(source_deal_header_id) > 1
						
						INSERT INTO ' + @transportation_deal_collect_tbl + '
						SELECT source_deal_header_id, ' + CAST(@rec_location_id AS VARCHAR(100)) + ',' + CAST(@del_location_id AS VARCHAR(100)) + '
								, term_start, ' + CAST(@bookout_split_total_amt AS VARCHAR(100)) + ', commodity_id, source_deal_detail_id, buy_sell_flag
								, trader_id, counterparty_id, deal_id 
						FROM (SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.term_start
								, ' + CAST(@commodity_id AS VARCHAR(100)) + ' commodity_id
								, sdd.buy_sell_flag, st.trader_name trader_id, sc.counterparty_id, sdh.deal_id 
							FROM #temp_trans_tbl ttt
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ttt.source_deal_header_id
							INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
							INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
							INNER JOIN internal_deal_type_subtype_types main ON main.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
							INNER JOIN internal_deal_type_subtype_types sub ON sub.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id							
							LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id 
							LEFT JOIN source_traders st ON st.source_trader_id = sdh.trader_id  
								AND sub.type_subtype_flag = ''y''
							WHERE sdd.location_id IN (' + CAST(@rec_location_id AS VARCHAR(100)) + ')
								AND sdd.buy_sell_flag = ''s''
								AND DATEPART(yyyy, ''' + CAST(@r_term_start AS VARCHAR(100)) + ''') BETWEEN DATEPART(yyyy, sdd.term_start) AND DATEPART(yyyy, sdd.term_end) 
								AND DATEPART(mm, ''' + CAST(@r_term_start AS VARCHAR(100)) + ''') BETWEEN DATEPART(mm, sdd.term_start) AND DATEPART(mm, sdd.term_end) 
								--AND DATEPART(yyyy, sdd.term_start) = DATEPART(yyyy, ''' + CAST(@r_term_start AS VARCHAR(100)) + ''')
								--AND DATEPART(mm, sdd.term_start) = DATEPART(mm, ''' + CAST(@r_term_start AS VARCHAR(100)) + ''')
								--AND CASE WHEN sdd.detail_commodity_id = 0 THEN sdh.commodity_id ELSE ISNULL(sdd.detail_commodity_id, sdh.commodity_id) END =  ' + CAST(@commodity_id AS VARCHAR(100)) + '
								AND sdt.deal_type_id = ''Transportation''
								AND deal_volume <> 0
								AND main.internal_deal_type_subtype_type = ''Transportation''
								AND sub.internal_deal_type_subtype_type = ''Base''
							UNION ALL
							SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.term_start
								, ' + CAST(@commodity_id AS VARCHAR(100)) + ' commodity_id
								, sdd.buy_sell_flag, st.trader_name trader_id, sc.counterparty_id, sdh.deal_id 
							FROM #temp_trans_tbl ttt
							INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ttt.source_deal_header_id
							INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
							INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
							INNER JOIN internal_deal_type_subtype_types main ON main.internal_deal_type_subtype_id = sdh.internal_deal_type_value_id
							INNER JOIN internal_deal_type_subtype_types sub ON sub.internal_deal_type_subtype_id = sdh.internal_deal_subtype_value_id
							LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id 
							LEFT JOIN source_traders st ON st.source_trader_id = sdh.trader_id  
								AND sub.type_subtype_flag = ''y''
							WHERE sdd.location_id IN (' + CAST(@del_location_id AS VARCHAR(100)) + ')
								AND buy_sell_flag = ''b''
								--AND CASE WHEN sdd.detail_commodity_id = 0 THEN sdh.commodity_id ELSE ISNULL(sdd.detail_commodity_id, sdh.commodity_id) END =  ' + CAST(@commodity_id AS VARCHAR(100)) + '
								AND sdt.deal_type_id = ''Transportation''
								AND deal_volume <> 0
								AND DATEPART(yyyy, ''' + CAST(@d_term_start AS VARCHAR(100)) + ''') BETWEEN DATEPART(yyyy, sdd.term_start) AND DATEPART(yyyy, sdd.term_end) 
								AND DATEPART(mm, ''' + CAST(@d_term_start AS VARCHAR(100)) + ''') BETWEEN DATEPART(mm, sdd.term_start) AND DATEPART(mm, sdd.term_end) 
								--AND DATEPART(yyyy, sdd.term_start) = DATEPART(yyyy, ''' + CAST(@d_term_start AS VARCHAR(100)) + ''')
								--AND DATEPART(mm, sdd.term_start) = DATEPART(mm, ''' + CAST(@d_term_start AS VARCHAR(100)) + ''')
								AND main.internal_deal_type_subtype_type = ''Transportation''
								AND sub.internal_deal_type_subtype_type = ''Base''
								) a'
			EXEC spa_print @sql
			EXEC(@sql)		
		END
		ELSE
		BEGIN 
			UPDATE #collect_location_require_trans_deal
			SET has_deal = 0
			WHERE rec_location_id = @rec_location_id
				AND del_location_id = @del_location_id
		END
	FETCH NEXT
	FROM @transportaion_deal_check INTO @rec_location_id, @del_location_id, @bookout_split_total_amt, @r_term_start, @d_term_start, @commodity_id
	END
	CLOSE @transportaion_deal_check
	DEALLOCATE @transportaion_deal_check


	IF EXISTS(SELECT 1 FROM #collect_location_require_trans_deal
						WHERE has_deal = 0)
	BEGIN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Transportation base deal not found.',
			@bookout_match
			RETURN
	END
	ELSE 
	BEGIN 
		SET @sql = 'SELECT MAX(rec.location_id + '' -> '' + del.location_id) [path]
						, deal_id
						, source_deal_header_id
							
						, MAX(trader) trader
						, MAX(counterparty) counterparty							
					FROM ' + @transportation_deal_collect_tbl + ' a
					INNER JOIN source_minor_location rec On rec.source_minor_location_id = a.from_location
					INNER JOIN source_minor_location del On del.source_minor_location_id = a.to_location
					GROUP BY source_deal_header_id, deal_id
					ORDER BY source_deal_header_id'
		EXEC spa_print @sql
		EXEC(@sql)	

	END 
END
ELSE IF @flag = 'iscreatedtransdeal'--check if transportation deal has alrady been created for the shipment.
BEGIN 
	--select 'check if trans deal is created'
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)
	--EXEC('select * from ' + @match_properties)
	CREATE TABLE #is_transport_deal_created(yes_no INT)
	SET @sql = '
			INSERT INTO #is_transport_deal_created
			SELECT is_transport_deal_created
					FROM (
					SELECT MAX(ISNULL(is_transport_deal_created, 0))  is_transport_deal_created
						FROM match_group_shipment mgs
						INNER JOIN ' + @match_properties + ' temp_tbl ON temp_tbl.match_group_shipment_id = mgs.match_group_shipment_id
						WHERE 1 = 1 AND mgs.match_group_shipment_id = ' + CASE WHEN @match_group_shipment_id IS NULL OR @match_group_shipment_id = 'mgs.match_group_shipment_id' THEN' mgs.match_group_shipment_id' ELSE @match_group_shipment_id END + ' 
						GROUP BY mgs.match_group_shipment_id
					
						) a'
	EXEC spa_print @sql
	EXEC(@sql)	
			 
	SET @sql = 'IF EXISTS(SELECT 1						 
					FROM  ' + @match_properties + ' 
				WHERE multiple_single_location = 1)
				BEGIN 
					UPDATE #is_transport_deal_created SET yes_no = 1
				END 
				'
	EXEC spa_print @sql
	EXEC(@sql)	


	IF EXISTS (SELECT 1 FROM #is_transport_deal_created WHERE yes_no = 1)
	BEGIN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Already Created.',
			@bookout_match
	END 
	ELSE 
	BEGIN 
		EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Success',
			'Not Created.',
			''
	END
END
ELSE IF @flag = 'remove_trans_deal' --remove transportation deals.(match.php)
BEGIN 
	SELECT mgd.source_deal_detail_id, sdh.source_deal_header_id, mgs.match_group_shipment_id, sddv.split_deal_detail_volume_id, mgd.match_group_detail_id
		INTO #deals_collect_to_delete
	FROM match_group_shipment  mgs
	INNER JOIN match_group_header mgh ON mgh.match_group_shipment_id = mgs.match_group_shipment_id
	INNER JOIN match_group_detail mgd ON mgd.match_group_header_id = mgh.match_group_header_id
	INNER JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = mgd.source_deal_detail_id
		AND mgd.split_deal_detail_volume_id = sddv.split_deal_detail_volume_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
	WHERE mgs.match_group_shipment_id = @match_shipment_id
		AND sdt.deal_type_id = 'Transportation'
	
	IF (SELECT COUNT(source_deal_detail_id) FROM #deals_collect_to_delete) < 1
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Transportation deal not found.',
			'' 
		RETURN 
	END	
				
	BEGIN TRY
		BEGIN TRAN 			
		DECLARE @delete_trans_deals	VARCHAR(MAX)	
	   
		SELECT @delete_trans_deals = STUFF((
									SELECT DISTINCT ',' + CAST(source_deal_header_id AS VARCHAR(1000))
									FROM #deals_collect_to_delete tdi					
									FOR XML PATH('')
								), 1, 1, '')

		--SELECT * 
		DELETE mgd
		FROM #deals_collect_to_delete dctd
		INNER JOIN match_group_detail mgd ON mgd.match_group_detail_id = dctd.match_group_detail_id

		--SELECT * 
		DELETE mgd
		FROM #deals_collect_to_delete dctd
		INNER JOIN split_deal_detail_volume mgd ON mgd.source_deal_detail_id = dctd.source_deal_detail_id

		EXEC spa_source_deal_header  @flag ='d', @deal_ids = @delete_trans_deals, @comments = '', @call_from = 'scheduling', @call_from_import = 'y'

		--SELECT * 
		UPDATE mgd
		SET	shipment_status = 47000,
			is_transport_deal_created = 0
		FROM #deals_collect_to_delete dctd
		INNER JOIN match_group_shipment mgd ON mgd.match_group_shipment_id = dctd.match_group_shipment_id

		SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)

		SET @sql = 'UPDATE a
					SET shipment_status = 47000
					FROM ' + @match_properties +  ' a 
					INNER JOIN #deals_collect_to_delete dctd ON a.match_group_shipment_id = dctd.match_group_shipment_id'
		
		EXEC spa_print @sql
		EXEC(@sql)

		COMMIT TRAN 
		--rollback tran
		EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Success',
			'Data Successfully Updated.',
			''
	END TRY 
	BEGIN CATCH		
		--SELECT ERROR_MESSAGE()
		ROLLBACK  TRAN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Error updating data.',
			''
	END CATCH
END
ELSE IF @flag = 'replace'--replace shipment line items (match.php)
BEGIN  
 
 	SET @lineup_vol_id_tbl = dbo.FNAProcessTableName('lineup_vol_id_tbl', @user_name, @process_id) 
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)

	SELECT DISTINCT @match_group_shipment_id = match_group_shipment_id 
	FROM match_group_detail mgd
	INNER JOIN dbo.FNASPlit(@match_group_detail_id, ',') a ON a.item = mgd.match_group_detail_id
 
	--EXEC('select * from ' + @lineup_vol_id_tbl)
	CREATE TABLE #data_collection_for_tbl(match_group_id INT
										, group_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, match_group_shipment_id INT
										, match_group_shipment VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, source_commodity_id INT
										, bookout_split_total_amt FLOAT
										, bookout_split_volume FLOAT
										, min_vol FLOAT
										, bal_quantity FLOAT
										, match_book_auto_id VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, lineup VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, shipment_status INT
										, shipment_workflow_status VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, match_group_header_id INT
										, match_order_sequence  INT
										, match_group_detail_id INT)
	
	SET @sql = 	'INSERT INTO #data_collection_for_tbl
				 SELECT match_group_id
					, group_name
					, match_group_shipment_id
					, match_group_shipment
					, source_commodity_id
					, bookout_split_total_amt
					, bookout_split_volume
					, min_vol
					, bal_quantity 
					, match_book_auto_id
					, lineup
					, shipment_status
					, shipment_workflow_status
					, match_group_header_id
					, match_order_sequence
					, match_group_detail_id
				FROM ' + @match_properties + ' mp 
				INNER JOIN dbo.FNASplit(''' + @match_group_detail_id + ''', '','') mgdi ON mgdi.item = mp.match_group_detail_id
				INNER JOIN dbo.FNASplit(''' + @match_deal_detail_id + ''', '','') mddi ON mddi.item = mp.source_deal_detail_id

					'
	EXEC spa_print @sql
	EXEC(@sql)

	SELECT SUBSTRING(combined_id, 1, CHARINDEX('_', combined_id) - 1) AS source_deal_detail_id,
			SUBSTRING(combined_id, CHARINDEX('_', combined_id) + 1, LEN(combined_id)) AS split_deal_detail_volume_id				 
		INTO #replacing_ids
	FROM (
		SELECT item combined_id FROM dbo.FNASplit(@buy_deals, ',') 
		UNION ALL
		SELECT item FROM dbo.FNASplit(@sell_deals, ',')
	) a
	
	DECLARE @old_location INT
	DECLARE @new_location INT

	SELECT @old_location = ISNULL(sddv.changed_location, sdd.location_id) 
	FROM  match_group_detail mgd  
	INNER JOIN split_deal_detail_volume sddv ON sddv.split_deal_detail_volume_id = mgd.split_deal_detail_volume_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
	WHERE match_group_detail_id = @match_group_detail_id

	SELECT @new_location = sdd.location_id 
	FROM source_deal_detail sdd
	INNER JOIN #replacing_ids ri ON ri.source_deal_detail_id = sdd.source_deal_detail_id
  
	IF @location_id = ''
		SET @location_id = NULL

 	IF @location_id IS NOT NULL  --storage commodity check
	BEGIN 
 		SELECT @commodity_name = source_commodity_id FROM #to_generate_match_id_storage_deal_temp
		SELECT @new_location = location_id FROM #to_generate_match_id_storage_deal_temp

		IF NOT EXISTS(SELECT 1 FROM #data_collection_for_tbl where source_commodity_id = @commodity_name)
		BEGIN 
			EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Error',
				'Selected commodity(s) in grids does not match.',
				''
			RETURN
		END
	END
	ELSE
	BEGIN 
		--check commodity
		IF NOT EXISTS(SELECT ISNULL(sdd.detail_commodity_id, sdh.commodity_id) commodity_id
					FROM #replacing_ids ri
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ri.source_deal_detail_id 
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN #data_collection_for_tbl dct ON dct.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id))
		BEGIN 
			EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_scheduling_workbench',
				'Error',
				'Selected commodity(s) in grids does not match.',
				''
			RETURN
		END
	END 	  

	BEGIN TRY  
		BEGIN TRAN
		
		SET @sql = '
					--SELECT *  
					DELETE mp 
					FROM ' + @match_properties + ' mp 
					INNER JOIN dbo.FNASplit(''' + @match_group_detail_id + ''', '','') mgdi ON mgdi.item = mp.match_group_detail_id
					INNER JOIN dbo.FNASplit(''' + @match_deal_detail_id + ''', '','') mddi ON mddi.item = mp.source_deal_detail_id'
		EXEC spa_print @sql
		EXEC(@sql)	

		SET @sql = '
					INSERT INTO ' + @match_properties + ' ( match_book_auto_id	
													, match_group_id	
													, group_name	
													, match_group_shipment_id
													, bookout_split_total_amt	
													, bookout_split_volume	
													, min_vol		
													, bal_quantity	
													, source_commodity_id	
													, commodity	
													, source_minor_location_id	
													, location	
													, source_counterparty_id	
													, counterparty_name	
													, source_deal_detail_id	
													, match_group_header_id																 		
													, is_complete	
													, deal_id	
													, buy_sell_flag	
													, bookout_match	
													, frequency
													, split_deal_detail_volume_id
													, source_major_location_ID																 	
													, region
													, lineup
													, deal_type
													, scheduling_period
													, scheduled_to
													, scheduled_from
													, status
													, sorting_ids
													, match_group_shipment
													, match_number
													, last_edited_by
													, last_edited_on
													--, saved_origin
													--, saved_form
													--, saved_commodity_form_attribute1
													--, saved_commodity_form_attribute2
													--, saved_commodity_form_attribute3
													--, saved_commodity_form_attribute4
													--, saved_commodity_form_attribute5
													, inco_terms_id
													, crop_year_id
													, lot
													, batch_id
													, shipment_workflow_status
													, shipment_status
													, source_minor_location_id_split	
													, location_split
													, source_deal_header_id
													, quantity_uom
													, org_uom_id
													, match_order_sequence
													, match_group_detail_id
													--, organic
													, origin_location
													, destination_location
													) 
													'

		IF @location_id IS NOT NULL 
		BEGIN  			
			SELECT @template_id = clm3_value 
			FROM generic_mapping_header gmh
			INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
			WHERE gmh.mapping_name = 'Scheduling Storage Mapping'
				AND clm1_value = @injection_withdrawal
		
			SELECT @deal_pre = ISNULL(prefix, 'ST-') 
			FROM deal_reference_id_prefix drp
			INNER JOIN source_deal_type sdp ON sdp.source_deal_type_id = drp.deal_type
			WHERE deal_type_id = 'Storage'

			IF @deal_pre IS NULL 
				SET @deal_pre = 'ST-'

			SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header') + 1
			SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail') + 1

			SET @deal_pre = @deal_pre + CAST(@new_source_deal_header_id AS VARCHAR(100))

			-- todo
			SELECT @product_description = PARSENAME(REPLACE(item,'^','.'), 2) FROM dbo.FNASplit(@location_contract_commodity, ':')
		
			SELECT TOP 1
				@origin  					= origin  			 
				, @form  					= form  				 
				, @organic  				= organic  			 
				, @attribute1  				= attribute1  		 
				, @attribute2  				= attribute2  		 
				, @attribute3  				= attribute3  		 
				, @attribute4  				= attribute4  		 
				, @attribute5  				= attribute5  		 
				--, @product_description		= product_description 
				, @crop_year  				= crop_year  		 
				, @detail_inco_terms		= detail_inco_terms   
				, @organic					= organic
			FROM source_deal_detail 
			WHERE ISNULL(product_description, detail_commodity_id) IN (@product_description)
 
 			SET @sql =   
						@sql +
						' SELECT 
								dct.match_book_auto_id  + ''-ST'' match_book_auto_id
							, dct.match_group_id	
							, dct.group_name	
							, dct.match_group_shipment_id 
							, dct.bookout_split_total_amt	
							, dct.bookout_split_volume	
							, dct.bookout_split_total_amt min_vol	
							, bookout_split_total_amt bal_quantity	
							, lcc.source_commodity_id source_commodity_id
							, sc.commodity_name
							, sml.source_minor_location_id
							--, CASE WHEN sml.location_name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smajor.location_name IS NULL THEN '''' ELSE  '' ['' + smajor.location_name + '']'' END location_split
							, sml.source_minor_location_id
							, sco.source_counterparty_id
							, sco.counterparty_id
							, -1
							, CASE WHEN ' + CAST(@old_location AS VARCHAR(1000)) + ' <> ' + CAST(@new_location AS VARCHAR(1000)) + ' THEN -1 ELSE dct.match_group_header_id END match_group_header_id
							, 0
							, ''' + CAST(@new_source_deal_header_id AS VARCHAR(100)) +  ' [' + @deal_pre + ']''' + ' 
							, ''' + CASE WHEN @injection_withdrawal = 'w' THEN 's' ELSE 'b' END + '''
							, ''' + @bookout_match + '''
							, ' + CAST(ISNULL(@convert_frequency, 703) AS VARCHAR(100)) + ' 
							, -1
							, smajor.source_major_location_ID
							, ISNULL(sml.region, sml.source_minor_location_id)  region
							, lineup
							, sdt.deal_type_id
							, CAST(DATEPART(yy, lcc.term_start) AS VARCHAR(100)) + '' - '' + CAST(DATENAME(MM, lcc.term_start) AS VARCHAR(3)) 
							, lcc.term_start
							, lcc.term_start
							, 47000   
							, 1
							, dct.match_group_shipment
							, dct.match_book_auto_id	
							, dbo.FNADBUser()
							, GETDATE()
							--, ' + ISNULL(@origin, 'NULL') + ' origin
							--, ' + ISNULL(@form, 'NULL')  + ' form
							--, ' + ISNULL(@attribute1, 'NULL') + ' attribute1
							--, ' + ISNULL(@attribute2, 'NULL') + ' attribute2
							--, ' + ISNULL(@attribute3, 'NULL') + ' attribute3
							--, ' + ISNULL(@attribute4, 'NULL') + ' attribute4
							--, ' + ISNULL(@attribute5, 'NULL') + ' attribute5
							, ' + ISNULL(@detail_inco_terms, 'NULL') + ' detail_inco_terms
							, ' + ISNULL(@crop_year, 'NULL') + ' crop_year
							, ' + CAST(@new_source_deal_detail_id AS VARCHAR(1000)) + ' source_deal_detail_id
							, NULL batch_id							
							, dct.shipment_workflow_status
							, dct.shipment_status
							, sml.source_minor_location_id
							, sml.source_minor_location_id
							--, CASE WHEN sml.location_name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smajor.location_name IS NULL THEN '''' ELSE  '' ['' + smajor.location_name + '']'' END location_split
							, -1 source_deal_header_id
							, ' + CAST(@convert_uom AS VARCHAR(100)) + '
							, ' + CAST(@convert_uom AS VARCHAR(100)) + ' position_uom
							, dct.match_order_sequence
							, dct.match_group_detail_id
							--, ''' + ISNULL(@organic, 'n') + '''
							, CASE WHEN ''' +  @injection_withdrawal + ''' = ''i'' THEN sml.source_minor_location_id ELSE NULL END 
							, CASE WHEN ''' +  @injection_withdrawal + ''' = ''w'' THEN sml.source_minor_location_id ELSE NULL END 
					FROM source_deal_header_template sdht
					INNER JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id
						AND sdht.template_id = ' + CAST(@template_id AS VARCHAR(1000)) + '
					CROSS APPLY #to_generate_match_id_storage_deal_temp lcc
					INNER JOIN source_minor_location sml ON sml.source_minor_location_id = lcc.location_id
					LEFT JOIN source_major_location smajor ON smajor.source_major_location_ID = sml.source_major_location_ID
					LEFT JOIN source_commodity sc ON sc.source_commodity_id = lcc.source_commodity_id
					LEFT JOIN source_counterparty sco ON sco.source_counterparty_id = lcc.counterparty_id
					LEFT JOIN source_deal_type sdt ON sdht.source_deal_type_id = sdt.source_deal_type_id
					CROSS APPLY #data_collection_for_tbl dct
					'
		END 
		ELSE 
		BEGIN	
			SET @sql = 
					@sql + 
					'						
				SELECT dct.match_book_auto_id  
					, dct.match_group_id	
					, dct.group_name	
					, dct.match_group_shipment_id 
					, dct.bookout_split_total_amt	
					, dct.bookout_split_volume	
					, dct.bookout_split_total_amt min_vol		
					, sdd.deal_volume * ISNULL(qc.conversion_factor, 1) bal_quantity	
					, sc.source_commodity_id source_commodity_id
					, sc.commodity_name
					, sml.source_minor_location_id
					--,  CASE WHEN sml.location_name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smajor.location_name IS NULL THEN '''' ELSE  '' ['' + smajor.location_name + '']'' END
					, sml.source_minor_location_id
					, sco.source_counterparty_id
					, sco.counterparty_id
					, sdd.source_deal_detail_id 
					, CASE WHEN ' + CAST(@old_location AS VARCHAR(1000)) + ' <> ' + CAST(@new_location AS VARCHAR(1000)) + ' THEN -1 ELSE dct.match_group_header_id END match_group_header_id
					, 0
					, CAST(sdh.source_deal_header_id AS VARCHAR(100)) +  '' ['' + sdh.deal_id + '']'' 
					, sdd.buy_sell_flag
					, ''m''
					, ' + CAST(ISNULL(@convert_frequency, 703) AS VARCHAR(100)) + '  
					, -1
					, smajor.source_major_location_ID
					, ISNULL(sml.region, sml.source_minor_location_id)  region
					, dct.lineup
					, sdt.deal_type_id
					, CAST(DATEPART(yy, sdd.term_start) AS VARCHAR(100)) + '' - '' + CAST(DATENAME(MM, sdd.term_start) AS VARCHAR(3)) 
					, sdd.term_start
					, sdd.term_start
					, 47000
					, 1
					, dct.match_group_shipment
					, dct.match_book_auto_id	
					, dbo.FNADBUser()
					, GETDATE()
					--, CASE WHEN sdd.origin IS NULL OR  sdd.origin = '''' THEN NULL ELSE sdd.origin END 
					--, CASE WHEN sdd.form IS NULL OR sdd.form = '''' THEN NULL ELSE sdd.form END 
					--, CASE WHEN sdd.attribute1 IS NULL OR sdd.attribute1 = '''' THEN NULL ELSE sdd.attribute1 END attribute1 
					--, CASE WHEN sdd.attribute2 IS NULL OR sdd.attribute2 = '''' THEN NULL ELSE sdd.attribute2 END attribute2 
					--, CASE WHEN sdd.attribute3 IS NULL OR sdd.attribute3 = '''' THEN NULL ELSE sdd.attribute3 END attribute3 
					--, CASE WHEN sdd.attribute4 IS NULL OR sdd.attribute4 = '''' THEN NULL ELSE sdd.attribute4 END attribute4 
					--, CASE WHEN sdd.attribute5 IS NULL OR sdd.attribute5 = '''' THEN NULL ELSE sdd.attribute5 END attribute5 
					, ISNULL(sdd.detail_inco_terms, NULL)  
					, ISNULL(sdd.crop_year, NULL)  
					, sdd.source_deal_detail_id 
					, NULL batch_id
					, dct.shipment_workflow_status
					, dct.shipment_status
					, source_minor_location_id
					, source_minor_location_id
					--CASE WHEN sml.location_name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smajor.location_name IS NULL THEN '''' ELSE  '' ['' + smajor.location_name + '']'' END
					, sdh.source_deal_header_id
					, ' + CAST(@convert_uom AS VARCHAR(100)) + '
					, COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id) position_uom
					, dct.match_order_sequence
					, dct.match_group_detail_id
					--, ISNULL(sdd.organic, ''n'')
					, CASE WHEN sdd.buy_sell_flag = ''b'' THEN sdd.location_id ELSE NULL END
					, CASE WHEN sdd.buy_sell_flag = ''s'' THEN sdd.location_id ELSE NULL END
			FROM #replacing_ids ri 
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ri.source_deal_detail_id
			INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id				 
			LEFT JOIN source_major_location smajor ON smajor.source_major_location_ID = sml.source_major_location_ID
			LEFT JOIN source_commodity sc ON sc.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
			LEFT JOIN source_counterparty sco ON sco.source_counterparty_id = sdh.counterparty_id
			LEFT JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
			LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
			LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)
			CROSS APPLY #data_collection_for_tbl dct'
			
		END		

		EXEC spa_print @sql
		EXEC(@sql)		

		SELECT @parent_line = sc.counterparty_id 
		FROM portfolio_hierarchy pf 
		INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = pf.entity_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id
			AND pf.entity_id = -1
		
		/*check for same location start*/
		IF OBJECT_ID('tempdb..#check_same_location') IS NOT NULL 
			DROP TABLE #check_same_location

		CREATE TABLE #check_same_location(source_minor_location_id INT, match_group_header_id_pre INT, replaced_match_group_detailed_id INT, match_book_auto_id VARCHAR(1000) COLLATE DATABASE_DEFAULT)

		SELECT @match_group_shipment_id = match_group_shipment_id FROM match_group_detail WHERE match_group_detail_id = @match_group_detail_id

		--EXEC('select * from '+ @match_properties + ' WHERE match_group_shipment_id = ' + @match_group_shipment_id )
		SET @sql = '
					INSERT INTO #check_same_location(source_minor_location_id, match_group_header_id_pre, replaced_match_group_detailed_id)
					SELECT source_minor_location_id, MAX(match_group_header_id) match_group_header_id_pre, ' + @match_group_detail_id + ' replaced_match_group_detailed_id
					FROM ' + @match_properties + ' WHERE match_group_shipment_id = ' + @match_group_shipment_id + ' GROUP BY source_minor_location_id
					HAVING COUNT(source_minor_location_id) > 1 '

		EXEC spa_print @sql
		EXEC(@sql)

 		SET @same_location_data = dbo.FNAProcessTableName('same_location_data', @user_name, @process_id) 

		SET @sql = 'IF OBJECT_ID(''' + @same_location_data + ''', ''U'') IS NOT NULL
					DROP TABLE ' + @same_location_data 
		EXEC spa_print @sql
		EXEC(@sql)

		SET @sql = 'SELECT *
					INTO ' + @same_location_data + ' FROM #check_same_location 
					 '

		EXEC spa_print @sql
		EXEC(@sql)

 		IF @old_location <> @new_location 
		BEGIN 
			SET @sql = 'INSERT INTO ' + @same_location_data + ' 
						SELECT source_minor_location_id, match_group_header_id  match_group_header_id_pre, ' + @match_group_detail_id + ' replaced_match_group_detailed_id, NULL
						FROM ' + @match_properties + ' WHERE match_group_detail_id = ' + CAST(@match_group_detail_id AS VARCHAR(1000))
					  
			EXEC spa_print @sql
			EXEC(@sql)

		END 

		--select * from #check_same_location
		--EXEC('select deal_id, source_deal_detail_id, lineup,  match_group_header_id, * from ' + @match_properties)

		IF EXISTS(SELECT 1 FROM #check_same_location)
		BEGIN 
			SET @sql = '
					
					--SELECT *  
					UPDATE mp 
					SET mp.match_group_header_id =  b.match_group_header_id_pre
					FROM ' + @match_properties + ' mp
					OUTER APPLY #check_same_location b  
					WHERE mp.match_group_shipment_id = ' + @match_group_shipment_id + ' 
						AND b.source_minor_location_id = mp.source_minor_location_id' 						

			EXEC spa_print @sql
			EXEC(@sql)
		END		 

		--update shipment and match names
		SET @sql = 'UPDATE a
					SET match_group_shipment =  ''SHP -'' + CAST(match_group_shipment_id AS VARCHAR(MAX)) + 
												+ '' | '' 
												+ ISNULL(STUFF((SELECT DISTINCT '' , '' + a.deal_id + '' - '' + ISNULL(sdg.source_deal_groups_name, '''')
																FROM ' + @match_properties + ' a
																LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
																LEFT JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = sdd.source_deal_group_id
																WHERE a.match_group_shipment_id = ' + @match_group_shipment_id + ' AND a.buy_sell_flag = ''b''							
														FOR XML PATH('''')), 1, 3, '''') , '''')						 		
												+ '' - ''
												+ STUFF(( SELECT DISTINCT '' , '' + counterparty_name  
													FROM ' + @match_properties + ' WHERE buy_sell_flag = ''b''
														AND match_group_shipment_id = ' + @match_group_shipment_id + ' 
													FOR XML PATH('''')), 1, 3, '''') 	
												+ '' | '' +			
												+ ISNULL(STUFF((SELECT DISTINCT '' , '' + a.deal_id + '' - '' + ISNULL(sdg.source_deal_groups_name, '''')
																FROM ' + @match_properties + ' a
																INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
																INNER JOIN source_deal_groups sdg ON sdg.source_deal_groups_id = sdd.source_deal_group_id
																WHERE a.match_group_shipment_id = ' + @match_group_shipment_id + ' AND a.buy_sell_flag = ''s''							
															FOR XML PATH('''')), 1, 3, '''') , '''')						 														
												+ '' - ''
												+ ISNULL(STUFF(( SELECT DISTINCT '' , '' + counterparty_name
														FROM ' + @match_properties + ' WHERE buy_sell_flag = ''s''
															AND match_group_shipment_id = ' + @match_group_shipment_id + ' 
														FOR XML PATH('''')), 1, 3, ''''), '''')	
				
					 , match_book_auto_id = ''MTC -'' + CASE WHEN match_group_header_id = -1 THEN '' [ID]'' ELSE CAST(match_group_header_id AS VARCHAR(100)) END + '' - '' + sml.location_id + '' - '' 
											+ commodity	
											--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.code = ''- Not Specified -'' OR sdv_form.value_id < 0 THEN '''' ELSE '' | '' + sdv_form.code END 
											--+ '' |'' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = ''- Not Specified -'' OR commodity_origin_id.value_id < 0 THEN '''' ELSE commodity_origin_id.code END											
											--+ CASE WHEN a.organic IS NULL OR a.organic = ''n'' THEN '''' ELSE '' | Organic '' END
											--+ CASE WHEN sdv1.code IS NULL OR sdv1.code = ''- Not Specified -'' OR sdv1.value_id < 0 THEN '''' ELSE '' '' + sdv1.code END  
											--+ CASE WHEN sdv2.code IS NULL OR sdv2.code = ''- Not Specified -'' OR sdv2.value_id < 0 THEN '''' ELSE '' '' + sdv2.code END  
											--+ CASE WHEN sdv3.code IS NULL OR sdv3.code = ''- Not Specified -'' OR sdv3.value_id < 0 THEN '''' ELSE '' '' + sdv3.code END  
											--+ CASE WHEN sdv4.code IS NULL OR sdv4.code = ''- Not Specified -'' OR sdv4.value_id < 0 THEN '''' ELSE '' '' + sdv4.code END  
											--+ CASE WHEN sdv5.code IS NULL OR sdv5.code = ''- Not Specified -'' OR sdv5.value_id < 0 THEN '''' ELSE '' '' + sdv5.code END  	
					, match_number = ''MTC -'' + CASE WHEN match_group_header_id = -1 THEN '' [ID]'' ELSE CAST(match_group_header_id AS VARCHAR(100)) END + '' - '' + sml.location_id + '' - '' 
									+ commodity										
									--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.code = ''- Not Specified -'' OR sdv_form.value_id < 0 THEN '''' ELSE '' | '' + sdv_form.code END 
									--+ '' |'' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = ''- Not Specified -'' OR commodity_origin_id.value_id < 0 THEN '''' ELSE commodity_origin_id.code END											
									--+ CASE WHEN a.organic IS NULL OR a.organic = ''n'' THEN '''' ELSE '' | Organic '' END
									--+ CASE WHEN sdv1.code IS NULL OR sdv1.code = ''- Not Specified -'' OR sdv1.value_id < 0 THEN '''' ELSE '' '' + sdv1.code END  
									--+ CASE WHEN sdv2.code IS NULL OR sdv2.code = ''- Not Specified -'' OR sdv2.value_id < 0 THEN '''' ELSE '' '' + sdv2.code END  
									--+ CASE WHEN sdv3.code IS NULL OR sdv3.code = ''- Not Specified -'' OR sdv3.value_id < 0 THEN '''' ELSE '' '' + sdv3.code END  
									--+ CASE WHEN sdv4.code IS NULL OR sdv4.code = ''- Not Specified -'' OR sdv4.value_id < 0 THEN '''' ELSE '' '' + sdv4.code END  
									--+ CASE WHEN sdv5.code IS NULL OR sdv5.code = ''- Not Specified -'' OR sdv5.value_id < 0 THEN '''' ELSE '' '' + sdv5.code END  	
					, lineup =  STUFF((
									SELECT '','' + counterparty_name
									FROM ' + @match_properties + '
									where buy_sell_flag = ''b'' AND match_group_shipment_id = ' + @match_group_shipment_id + ' 
									FOR XML PATH('''')), 1, 1, '''')
									+ '' - '' 
									+  ''' + @parent_line + ''' + '' - '' 
									+ STUFF((SELECT '','' + counterparty_name
										FROM ' + @match_properties + '
										where buy_sell_flag = ''s'' AND match_group_shipment_id = ' + @match_group_shipment_id + ' 
										FOR XML PATH('''')), 1, 1, '''')								 
			 			
				FROM ' + @match_properties + ' a
				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = a.location

				--LEFT JOIN commodity_origin co ON co.commodity_origin_id = a.saved_origin
 			--	LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
				--	AND type_id = 14000			
				--LEFT JOIN commodity_form cf ON cf.commodity_form_id = a.saved_form
				--LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
				--LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = commodity_form_id.commodity_form_value
				 
				--LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = a.saved_commodity_form_attribute1
				--LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
				--	AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
				--LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value
				
				--LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id =a.saved_commodity_form_attribute2
				--LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
				--	AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
				--LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = a.saved_commodity_form_attribute3
				--LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
				--	AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
				--LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = a.saved_commodity_form_attribute4
				--LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
				--	AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
				--LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = a.saved_commodity_form_attribute5
				--LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
				--	AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
				--LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value
				WHERE match_group_shipment_id = ' + @match_group_shipment_id

		EXEC spa_print @sql
		EXEC(@sql)
		
		SET @sql = '
			UPDATE a
			SET a.packaging_uom_id = udddf.udf_value 
			--select  source_deal_detail_id, lineup,  match_group_header_id, * 
			FROM ' + @match_properties + ' a
			INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = a.source_deal_detail_id
			INNER JOIN user_defined_deal_fields_template uddft ON udddf.udf_template_id = uddft.udf_template_id 
			INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
			WHERE  1 = 1 AND udft.Field_label IN (''Packaging UOM'')'

		EXEC spa_print @sql
		EXEC(@sql)
		--EXEC('select *, packaging_uom_id from ' + @match_properties)
		--rollback tran return 

		SET @return_str = CAST(@match_group_detail_id AS VARCHAR(100)) + '_' + ISNULL(@location_id, '') + '_' + ISNULL(@location_contract_commodity, '') + '_' + @storage_location_volume + '_' + 'replace' + CAST(@match_deal_detail_id AS VARCHAR(100))	 

		COMMIT TRAN
		EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Success',
			'Data Successfully Updated.',
			@return_str
	END TRY 
	BEGIN CATCH
		--SELECT ERROR_MESSAGE()
		ROLLBACK TRAN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Error updating data.',
			''
	END CATCH
END
ELSE IF @flag = 'recall'--recall shipment line items (match.php)
BEGIN 
 	DECLARE @recall_temp_data VARCHAR(1000)
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)
	SET @recall_temp_data = dbo.FNAProcessTableName('recall_temp_data', @user_name, @process_id)

	CREATE TABLE #recall_deals(source_deal_detail_id INT, source_deal_header_id INT, recalled_id INT)

	SET @sql = 'IF OBJECT_ID(''' + @recall_temp_data + ''', ''U'') IS NOT NULL
					DROP TABLE ' + @recall_temp_data 
	EXEC spa_print @sql
	EXEC(@sql)

	IF OBJECT_ID('tempdb..#collect_previous_data') IS NOT NULL
		DROP TABLE #collect_previous_data

	CREATE TABLE #collect_previous_data(match_group_id INT, group_name VARCHAR(MAX) COLLATE DATABASE_DEFAULT
									, match_order_sequence INT, quantity FLOAT, commodity_id INT, buy_sell_flag CHAR(1) COLLATE DATABASE_DEFAULT
									, match_group_shipment VARCHAR(MAX) COLLATE DATABASE_DEFAULT
									, source_deal_detail_id INT,match_group_shipment_id INT)

	SET @sql = 'INSERT INTO #collect_previous_data
				SELECT match_group_id,  group_name, match_order_sequence, bookout_split_total_amt, source_commodity_id, buy_sell_flag, match_group_shipment, source_deal_detail_id, match_group_shipment_id
				FROM ' + @match_properties + ' 
				WHERE match_group_detail_id IN (' + @match_group_detail_id + ') '
	
	EXEC spa_print @sql
	EXEC(@sql)
 
	SELECT SUBSTRING(a.combined_id, 1, CHARINDEX('_', a.combined_id) - 1) AS source_deal_detail_id,
			SUBSTRING(a.combined_id, CHARINDEX('_', a.combined_id) + 1, LEN(a.combined_id)) AS split_deal_detail_volume_id,
			ISNULL(sdd.detail_commodity_id, sdh.commodity_id) commodity_id,
			ISNULL(sdd.buy_sell_flag, sdh.header_buy_sell_flag) buy_sell_flag
		INTO #recall_ids
	FROM (		
		SELECT item combined_id FROM dbo.FNASplit(@sell_deals, ',')
	) a
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = SUBSTRING(a.combined_id, 1, CHARINDEX('_', a.combined_id) - 1)
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id  = sdd.source_deal_header_id

	IF @location_contract_commodity IS NOT NULL
	BEGIN 
		INSERT INTO #recall_ids(source_deal_detail_id, split_deal_detail_volume_id, commodity_id, buy_sell_flag)
		SELECT -1, -1, source_commodity_id, 's' buy_sell  from #to_generate_match_id_storage_deal_temp
	END 
 
	-- commodity check 
	IF EXISTS(SELECT commodity_id FROM #recall_ids
				WHERE commodity_id NOT IN  (SELECT commodity_id FROM #collect_previous_data WHERE buy_sell_flag = 's')
					AND buy_sell_flag = 's'
			UNION ALL
			SELECT commodity_id  
			FROM #collect_previous_data
			WHERE commodity_id NOT IN  (SELECT commodity_id FROM #recall_ids WHERE buy_sell_flag = 's')
				AND buy_sell_flag = 's')
	BEGIN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Selected commodity(s) in grids does not match.',
			''
		RETURN
	END 
	
	SET @sql = 'CREATE TABLE ' + @recall_temp_data + ' (match_group_id VARCHAR(1000), group_name VARCHAR(1000), match_group_shipment_id VARCHAR(1000), match_group_shipment VARCHAR(1000), match_group_header_id VARCHAR(1000)
														, match_book_auto_id VARCHAR(1000), source_commodity_id VARCHAR(1000), commodity VARCHAR(1000), source_minor_location_id VARCHAR(1000), location VARCHAR(1000)
														, last_edited_by VARCHAR(1000), last_edited_on VARCHAR(1000), status VARCHAR(1000), scheduler VARCHAR(1000), container VARCHAR(1000), carrier VARCHAR(1000)
														, consignee VARCHAR(1000), pipeline_cycle VARCHAR(1000), scheduling_period VARCHAR(1000), scheduled_to VARCHAR(1000), scheduled_from VARCHAR(1000), po_number VARCHAR(1000)
														, comments VARCHAR(1000), match_number VARCHAR(1000), lineup VARCHAR(1000)
														--, saved_origin VARCHAR(1000), saved_form VARCHAR(1000), organic VARCHAR(1000)
														--, saved_commodity_form_attribute1 VARCHAR(1000), saved_commodity_form_attribute2 VARCHAR(1000), saved_commodity_form_attribute3 VARCHAR(1000), saved_commodity_form_attribute4 VARCHAR(1000), saved_commodity_form_attribute5 VARCHAR(1000)
														, bookout_match VARCHAR(1000), match_group_detail_id VARCHAR(1000), notes VARCHAR(1000)
														, estimated_movement_date VARCHAR(1000), estimated_movement_date_to VARCHAR(1000), source_counterparty_id VARCHAR(1000), counterparty_name VARCHAR(1000), source_deal_detail_id VARCHAR(1000)
														, bookout_split_total_amt VARCHAR(1000), bookout_split_volume VARCHAR(1000), min_vol VARCHAR(1000), actualized_amt VARCHAR(1000), bal_quantity VARCHAR(1000), is_complete VARCHAR(1000)
														, deal_id VARCHAR(1000), buy_sell_flag VARCHAR(1000), frequency VARCHAR(1000), multiple_single_deals VARCHAR(1000), multiple_single_location VARCHAR(1000)
														, split_deal_detail_volume_id VARCHAR(1000), source_major_location_ID VARCHAR(1000), deal_type VARCHAR(1000), region VARCHAR(1000), form_location_id VARCHAR(1000)
														, source_minor_location_id_split VARCHAR(1000), location_split VARCHAR(1000), sorting_ids VARCHAR(1000), base_deal_detail_id VARCHAR(1000), shipment_status VARCHAR(1000)
														, from_location VARCHAR(1000), to_location VARCHAR(1000), incoterm VARCHAR(1000), crop_year VARCHAR(1000), inco_terms_id VARCHAR(1000), crop_year_id VARCHAR(1000)
														, lot VARCHAR(1000), batch_id VARCHAR(1000), shipment_workflow_status VARCHAR(1000), container_number VARCHAR(1000), source_deal_header_id VARCHAR(1000)
														, quantity_uom VARCHAR(1000), org_uom_id VARCHAR(1000), base_id VARCHAR(1000), match_order_sequence VARCHAR(1000), source_deal_groups_name VARCHAR(1000), parent_recall_id INT
														, origin_location VARCHAR(1000), destination_location VARCHAR(1000)
														)'
	EXEC spa_print @sql
	EXEC(@sql)
  
	BEGIN TRAN 		
		-- insert into processs table 
		--newly added legs and selected deals
		SET @sql = '
					INSERT INTO ' + @recall_temp_data + '
					SELECT 
						match_group_id, group_name, (IDENT_CURRENT(''match_group_shipment'') + 1) * -1 match_group_shipment_id
						, ''Recall - [ID] - '' + match_group_shipment match_group_shipment
						, (IDENT_CURRENT(''match_group_header'') + 1 + (DENSE_RANK() OVER (ORDER BY a.source_minor_location_id
																							--, a.saved_origin
																							--, a.saved_form
																							--, a.saved_commodity_form_attribute1
																							--, a.saved_commodity_form_attribute2
																							--, a.saved_commodity_form_attribute3
																							--, a.saved_commodity_form_attribute4
																							--, a.saved_commodity_form_attribute5
																							--, a.organic
																							)
																		)) * -1 match_group_header_id 
						, ''MTC - '' match_book_auto_id
						, source_commodity_id, commodity
						, source_minor_location_id
						, location, last_edited_by, last_edited_on, status, scheduler, container, carrier, consignee, pipeline_cycle, scheduling_period, scheduled_to, scheduled_from, po_number, comments, match_number, lineup
						--, saved_origin, saved_form, organic, saved_commodity_form_attribute1, saved_commodity_form_attribute2, saved_commodity_form_attribute3, saved_commodity_form_attribute4, saved_commodity_form_attribute5
						, bookout_match, match_group_detail_id, notes, estimated_movement_date, estimated_movement_date_to, source_counterparty_id, counterparty_name, source_deal_detail_id, bookout_split_total_amt, bookout_split_volume, min_vol, actualized_amt, bal_quantity
						, is_complete, deal_id, buy_sell_flag, frequency, multiple_single_deals, multiple_single_location, split_deal_detail_volume_id, source_major_location_ID, deal_type, region, form_location_id
						, source_minor_location_id_split, location_split, sorting_ids, base_deal_detail_id, shipment_status, from_location, to_location, incoterm, crop_year, inco_terms_id, crop_year_id
						, lot, batch_id, shipment_workflow_status, container_number, source_deal_header_id, quantity_uom, org_uom_id, base_id
						, match_order_sequence + ROW_NUMBER() OVER(ORDER BY a.buy_sell_flag, a.match_group_header_id ASC) match_order_sequence
						, source_deal_groups_name, parent_recall_id, NULL origin_location, NULL destination_location						
					FROM 
						( 
					--opposite legs
					SELECT  
						  mp.match_group_id, mp.group_name, NULL match_group_shipment_id, cpd.match_group_shipment, NULL match_group_header_id, NULL match_book_auto_id, mp.source_commodity_id, mp.commodity	
						, mp.source_minor_location_id, mp.location, mp.last_edited_by, mp.last_edited_on, 47000 status, mp.scheduler, mp.container, mp.carrier, mp.consignee, mp.pipeline_cycle, mp.scheduling_period	
						, ISNULL(mp.estimated_movement_date_to, sdd.term_end) scheduled_to, ISNULL(sdd.term_start, mp.estimated_movement_date) scheduled_from, mp.po_number, mp.comments, mp.match_number, mp.lineup
						--, mp.saved_origin, mp.saved_form, CASE WHEN mp.organic IS NULL OR mp.organic = '''' OR mp.organic = ''n'' THEN ''n'' ELSE ''y'' END organic
						--, mp.saved_commodity_form_attribute1, mp.saved_commodity_form_attribute2, mp.saved_commodity_form_attribute3, mp.saved_commodity_form_attribute4, mp.saved_commodity_form_attribute5	
						, mp.bookout_match, -1 match_group_detail_id, mp.notes, mp.estimated_movement_date, mp.estimated_movement_date_to, mp.source_counterparty_id, mp.counterparty_name					
						, -1 source_deal_detail_id, mp.bookout_split_total_amt, mp.bookout_split_volume, mp.min_vol, mp.actualized_amt, mp.bal_quantity, 0 is_complete, mp.deal_id	
						, ''b'' buy_sell_flag, mp.frequency, mp.multiple_single_deals, mp.multiple_single_location, -1 split_deal_detail_volume_id, mp.source_major_location_ID	
						, mp.deal_type, mp.region, mp.form_location_id, mp.source_minor_location_id_split, mp.location_split, mp.sorting_ids, mp.base_deal_detail_id	
						, 47000 shipment_status, mp.from_location, mp.to_location, mp.incoterm, mp.crop_year, mp.inco_terms_id, mp.crop_year_id, mp.lot, mp.batch_id	
						, NULL shipment_workflow_status, mp.container_number, mp.source_deal_header_id, mp.quantity_uom, mp.org_uom_id, mp.base_id, cpd.match_order_sequence
						, sdg.source_deal_groups_name, mgdi.item parent_recall_id		 									 											 					
					FROM ' + @match_properties + ' mp 
					INNER JOIN dbo.FNASplit(''' + @match_group_detail_id + ''', '','') mgdi ON mgdi.item = mp.match_group_detail_id
					INNER JOIN #collect_previous_data rc ON rc.source_deal_detail_id = mp.source_deal_detail_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mp.source_deal_detail_id	
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id			
					LEFT JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
						AND sdd.source_deal_group_id = sdg.source_deal_groups_id
					CROSS APPLY #collect_previous_data cpd
					WHERE cpd.commodity_id = mp.source_commodity_id

					UNION ALL
					-- new selected deals
					SELECT 
						  ' + CAST(@match_group_id AS VARCHAR(MAX)) + ' match_group_id	, cpd.group_name group_name
						, NULL match_group_shipment_id , cpd.match_group_shipment, NULL match_group_header_id, NULL match_book_auto_id, sc.source_commodity_id source_commodity_id
						, sc.commodity_name, sml.source_minor_location_id
						, sml.source_minor_location_id
						--, CASE WHEN sml.location_name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smajor.location_name IS NULL THEN '''' ELSE  '' ['' + smajor.location_name + '']'' END location
						, dbo.FNADBUser() last_edited_by, GETDATE() last_edited_on
						, 47000, NULL scheduler, NULL container, NULL carrier, NULL consignee, NULL pipeline_cycle
						, CAST(DATEPART(yy, sdd.term_start) AS VARCHAR(100)) + '' - '' + CAST(DATENAME(MM, sdd.term_start) AS VARCHAR(3)) scheduling_period	
						, sdd.term_start scheduled_to, sdd.term_end scheduled_from, NULL po_number, NULL comments, NULL match_number, NULL lineup
						--, CASE WHEN sdd.origin IS NULL OR  sdd.origin = '''' THEN NULL ELSE sdd.origin END 
						--, CASE WHEN sdd.form IS NULL OR sdd.form = '''' THEN NULL ELSE sdd.form END 
						--, CASE WHEN sdd.organic IS NULL OR sdd.organic = '''' OR sdd.organic = ''n'' THEN ''n'' ELSE ''y'' END 
						--, CASE WHEN sdd.attribute1 IS NULL OR sdd.attribute1 = '''' THEN NULL ELSE sdd.attribute1 END attribute1 
						--, CASE WHEN sdd.attribute2 IS NULL OR sdd.attribute2 = '''' THEN NULL ELSE sdd.attribute2 END attribute2 
						--, CASE WHEN sdd.attribute3 IS NULL OR sdd.attribute3 = '''' THEN NULL ELSE sdd.attribute3 END attribute3 
						--, CASE WHEN sdd.attribute4 IS NULL OR sdd.attribute4 = '''' THEN NULL ELSE sdd.attribute4 END attribute4 
						--, CASE WHEN sdd.attribute5 IS NULL OR sdd.attribute5 = '''' THEN NULL ELSE sdd.attribute5 END attribute5 
						, ''m'', -1 match_group_detail_id
						, NULL notes, NULL estimated_movement_date, NULL estimated_movement_date_to, sco.source_counterparty_id, sco.counterparty_id, ri.source_deal_detail_id
						, CASE WHEN cpd.quantity < (ISNULL(sddv.quantity, sdd.deal_volume) * ISNULL(qc.conversion_factor, 1)) THEN cpd.quantity ELSE ISNULL(sddv.quantity, sdd.deal_volume) * ISNULL(qc.conversion_factor, 1) END bookout_split_total_amt
						, CASE WHEN cpd.quantity < (ISNULL(sddv.quantity, sdd.deal_volume) * ISNULL(qc.conversion_factor, 1)) THEN cpd.quantity ELSE ISNULL(sddv.quantity, sdd.deal_volume) * ISNULL(qc.conversion_factor, 1) END bookout_split_volume
						, CASE WHEN cpd.quantity < (ISNULL(sddv.quantity, sdd.deal_volume) * ISNULL(qc.conversion_factor, 1)) THEN cpd.quantity ELSE ISNULL(sddv.quantity, sdd.deal_volume) * ISNULL(qc.conversion_factor, 1) END min_vol
						, NULL actualized_amt, ISNULL(sddv.quantity, sdd.deal_volume) * ISNULL(qc.conversion_factor, 1) bal_quantity, 0 is_complete
						, CAST(sdh.source_deal_header_id AS VARCHAR(100)) +  '' ['' + sdh.deal_id + '']'' , sdd.buy_sell_flag, ' + CAST(ISNULL(@convert_frequency, 703) AS VARCHAR(100)) + ' , 0 multiple_single_deals
						, 0 multiple_single_location, ri.split_deal_detail_volume_id, smajor.source_major_location_ID, sdt.deal_type_id
						, ISNULL(sml.region, sml.source_minor_location_id), sml.source_minor_location_id form_location_id, sml.source_minor_location_id source_minor_location_id_split
						, sml.source_minor_location_id
						--, CASE WHEN sml.location_name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smajor.location_name IS NULL THEN '''' ELSE  '' ['' + smajor.location_name + '']'' END location_split
						, 2 sorting_ids, sdd.lot base_deal_detail_id, 47000 shipment_status , NULL from_location, NULL to_location, NULL incoterm
						, NULL crop_year, ISNULL(sdd.detail_inco_terms, NULL) inco_terms_id, ISNULL(sdd.crop_year, NULL) crop_year_id
						, sdd.lot, sdd.batch_id, NULL shipment_workflow_status, NULL container_number
						, -1 source_deal_header_id, ' + CAST(@convert_uom AS VARCHAR(100)) + ' quantity_uom
						, COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id) org_uom_id
						, NULL base_id, cpd.match_order_sequence match_order_sequence, sdg.source_deal_groups_name
						, NULL parent_recall_id 									 											 					
					FROM #recall_ids ri 
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = ri.source_deal_detail_id
					INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id	
					LEFT JOIN source_deal_groups sdg ON sdg.source_deal_header_id = sdh.source_deal_header_id
						AND sdd.source_deal_group_id = sdg.source_deal_groups_id
					LEFT JOIN source_major_location smajor ON smajor.source_major_location_ID = sml.source_major_location_ID
					LEFT JOIN source_commodity sc ON sc.source_commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id)
					LEFT JOIN source_counterparty sco ON sco.source_counterparty_id = sdh.counterparty_id
					LEFT JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
					LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, sdd.deal_volume_uom_id)
					LEFT JOIN split_deal_detail_volume sddv ON sddv.source_deal_detail_id = ri.source_deal_detail_id
						AND sddv.split_deal_detail_volume_id = ri.split_deal_detail_volume_id
					CROSS APPLY #collect_previous_data cpd
					WHERE cpd.commodity_id = ISNULL(sdd.detail_commodity_id, sdh.commodity_id) '
	
		SET @sql = @sql + '	) a '
		EXEC spa_print @sql
		EXEC(@sql)


		--ROLLBACK TRAN 
		--RETURN
		--	select * FROM #to_generate_match_id_storage_deal_temp
		--parent counterparty
		SELECT @parent_line = sc.counterparty_id 
		FROM portfolio_hierarchy pf 
		INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = pf.entity_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id
			AND pf.entity_id = -1

		--update shipment and match names
		SET @sql = 'UPDATE a
					SET 
						--match_group_shipment =  match_group_shipment + STUFF((SELECT '','' + deal_id
						--												FROM ' + @recall_temp_data + '
						--												where buy_sell_flag = ''b''
						--												FOR XML PATH('''')), 1, 1, '''')
						--											+ '' - ''																	
						--											+ STUFF((SELECT '','' + ISNULL(source_deal_groups_name, '''')
						--												FROM ' + @recall_temp_data + '
						--												where buy_sell_flag = ''b''
						--												FOR XML PATH('''')), 1, 1, '''')	
						--											+ '' - ''  			
						--											+ STUFF((SELECT '','' + counterparty_name
						--												FROM ' + @recall_temp_data + '
						--												where buy_sell_flag = ''b''
						--												FOR XML PATH('''')), 1, 1, '''')																														
						--											+ '' | '' 
						--											+ STUFF((SELECT '','' + deal_id
						--												FROM ' + @recall_temp_data + '
						--												where buy_sell_flag = ''s''
						--												FOR XML PATH('''')), 1, 1, '''')  
						--											+ '' - '' 																	
						--											+ STUFF((SELECT '','' + ISNULL(source_deal_groups_name, '''')
						--												FROM ' + @recall_temp_data + '
						--												where buy_sell_flag = ''s''
						--												FOR XML PATH('''')), 1, 1, '''')
						--											+ '' - '' 
						--											+ STUFF((SELECT '','' + counterparty_name
						--												FROM ' + @recall_temp_data + '
						--												where buy_sell_flag = ''s''
						--												FOR XML PATH('''')), 1, 1, '''')																																																							
					 --, 
					 match_book_auto_id = match_book_auto_id + '' [ID] - '' + sml.location_id + '' - '' 
											+ commodity	
											--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.code = ''- Not Specified -'' OR sdv_form.value_id < 0 THEN '''' ELSE '' | '' + sdv_form.code END 
											--+ '' |'' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = ''- Not Specified -'' OR commodity_origin_id.value_id < 0 THEN '''' ELSE commodity_origin_id.code END											
											--+ CASE WHEN a.organic IS NULL OR a.organic = ''n'' THEN '''' ELSE '' | Organic '' END
											--+ CASE WHEN sdv1.code IS NULL OR sdv1.code = ''- Not Specified -'' OR sdv1.value_id < 0 THEN '''' ELSE '' '' + sdv1.code END  
											--+ CASE WHEN sdv2.code IS NULL OR sdv2.code = ''- Not Specified -'' OR sdv2.value_id < 0 THEN '''' ELSE '' '' + sdv2.code END  
											--+ CASE WHEN sdv3.code IS NULL OR sdv3.code = ''- Not Specified -'' OR sdv3.value_id < 0 THEN '''' ELSE '' '' + sdv3.code END  
											--+ CASE WHEN sdv4.code IS NULL OR sdv4.code = ''- Not Specified -'' OR sdv4.value_id < 0 THEN '''' ELSE '' '' + sdv4.code END  
											--+ CASE WHEN sdv5.code IS NULL OR sdv5.code = ''- Not Specified -'' OR sdv5.value_id < 0 THEN '''' ELSE '' '' + sdv5.code END  	
					, match_number = match_book_auto_id + '' [ID] - '' + sml.location_id + '' - '' 
									+ commodity	
									--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.code = ''- Not Specified -'' OR sdv_form.value_id < 0 THEN '''' ELSE '' | '' + sdv_form.code END 
									--+ '' |'' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = ''- Not Specified -'' OR commodity_origin_id.value_id < 0 THEN '''' ELSE commodity_origin_id.code END											
									--+ CASE WHEN a.organic IS NULL OR a.organic = ''n'' THEN '''' ELSE '' | Organic '' END
									--+ CASE WHEN sdv1.code IS NULL OR sdv1.code = ''- Not Specified -'' OR sdv1.value_id < 0 THEN '''' ELSE '' '' + sdv1.code END  
									--+ CASE WHEN sdv2.code IS NULL OR sdv2.code = ''- Not Specified -'' OR sdv2.value_id < 0 THEN '''' ELSE '' '' + sdv2.code END  
									--+ CASE WHEN sdv3.code IS NULL OR sdv3.code = ''- Not Specified -'' OR sdv3.value_id < 0 THEN '''' ELSE '' '' + sdv3.code END  
									--+ CASE WHEN sdv4.code IS NULL OR sdv4.code = ''- Not Specified -'' OR sdv4.value_id < 0 THEN '''' ELSE '' '' + sdv4.code END  
									--+ CASE WHEN sdv5.code IS NULL OR sdv5.code = ''- Not Specified -'' OR sdv5.value_id < 0 THEN '''' ELSE '' '' + sdv5.code END  	
					, lineup =  STUFF((
									SELECT '','' + counterparty_name
									FROM ' + @recall_temp_data + '
									where buy_sell_flag = ''b''
									FOR XML PATH('''')), 1, 1, '''')
									+ '' - '' 
									+  ''' + ISNULL(@parent_line, 'NULL') + ''' + '' - '' 
									+ STUFF((SELECT '','' + counterparty_name
										FROM ' + @recall_temp_data + '
										WHERE buy_sell_flag = ''s''
										FOR XML PATH('''')), 1, 1, '''')								 
			 			
				FROM ' + @recall_temp_data + ' a
				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = a.location
			
				--LEFT JOIN commodity_origin co ON co.commodity_origin_id = a.saved_origin
 			--	LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
				--	AND type_id = 14000
			
				--LEFT JOIN commodity_form cf ON cf.commodity_form_id = a.saved_form
				--LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
				--LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = commodity_form_id.commodity_form_value
				 
				--LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = a.saved_commodity_form_attribute1
				--LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
				--	AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
				--LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value
				
				--LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id =a.saved_commodity_form_attribute2
				--LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
				--	AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
				--LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = a.saved_commodity_form_attribute3
				--LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
				--	AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
				--LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = a.saved_commodity_form_attribute4
				--LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
				--	AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
				--LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = a.saved_commodity_form_attribute5
				--LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
				--	AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
				--LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value'

		EXEC spa_print @sql
		EXEC(@sql)

		SET @sql = '				 								
				--SELECT * 
				UPDATE a 
				SET a.origin_location = b.origin_location,
					a.destination_location = b.destination_location
				FROM ' + @recall_temp_data + ' a
				INNER JOIN (SELECT  DISTINCT  STUFF((SELECT DISTINCT '','' + source_minor_location_id 
									FROM ' + @recall_temp_data + '
									WHERE buy_sell_flag = ''b''
									FOR XML PATH('''')), 1, 1, '''') origin_location
								, STUFF((SELECT DISTINCT '','' + source_minor_location_id 
									FROM ' + @recall_temp_data + '
									WHERE buy_sell_flag = ''s''
									FOR XML PATH('''')), 1, 1, '''') destination_location									
								, match_group_shipment_id
							FROM ' + @recall_temp_data + '
						GROUP BY match_group_shipment_id) b ON b.match_group_shipment_id = a.match_group_shipment_id '

		EXEC spa_print @sql
		--EXEC(@sql)
					
		--EXEC('select * from ' + @recall_temp_data)
		--ROLLBACK TRAN 
		--RETURN
			  		
		SET @sql = '
					INSERT INTO ' + @match_properties + '(match_group_id, group_name, match_group_shipment_id, match_group_shipment, match_group_header_id, match_book_auto_id, source_commodity_id
													, commodity, source_minor_location_id, location, last_edited_by, last_edited_on, status, scheduler, container, carrier
													, consignee, pipeline_cycle, scheduling_period, scheduled_to, scheduled_from, po_number, comments, match_number, lineup
													--, saved_origin, saved_form, organic
													--, saved_commodity_form_attribute1, saved_commodity_form_attribute2, saved_commodity_form_attribute3, saved_commodity_form_attribute4, saved_commodity_form_attribute5
													, bookout_match, match_group_detail_id, notes, estimated_movement_date, estimated_movement_date_to, source_counterparty_id
													, counterparty_name, source_deal_detail_id, bookout_split_total_amt, bookout_split_volume, min_vol, actualized_amt, bal_quantity, is_complete, deal_id, buy_sell_flag
													, frequency, multiple_single_deals, multiple_single_location, split_deal_detail_volume_id, source_major_location_ID, deal_type, region, form_location_id
													, source_minor_location_id_split, location_split, sorting_ids, base_deal_detail_id, shipment_status, from_location, to_location, incoterm, crop_year, inco_terms_id
													, crop_year_id, lot, batch_id, shipment_workflow_status, container_number, source_deal_header_id, quantity_uom, org_uom_id, base_id, match_order_sequence, parent_recall_id, origin_location, destination_location										
										) 
					SELECT match_group_id, group_name, match_group_shipment_id, match_group_shipment, match_group_header_id, match_book_auto_id, source_commodity_id
							, commodity, source_minor_location_id, location, last_edited_by, last_edited_on, status, scheduler, container, carrier
							, consignee, pipeline_cycle, scheduling_period, scheduled_to, scheduled_from, po_number, comments, match_number, lineup
							--, saved_origin, saved_form, organic
							--, saved_commodity_form_attribute1, saved_commodity_form_attribute2, saved_commodity_form_attribute3, saved_commodity_form_attribute4, saved_commodity_form_attribute5
							, bookout_match, match_group_detail_id, notes, estimated_movement_date, estimated_movement_date_to, source_counterparty_id
							, counterparty_name, source_deal_detail_id, bookout_split_total_amt, bookout_split_volume, min_vol, actualized_amt, bal_quantity, is_complete, deal_id, buy_sell_flag
							, frequency, multiple_single_deals, multiple_single_location, split_deal_detail_volume_id, source_major_location_ID, deal_type, region, form_location_id
							, source_minor_location_id_split, location_split, sorting_ids, base_deal_detail_id, shipment_status, from_location, to_location, incoterm, crop_year, inco_terms_id
							, crop_year_id, lot, batch_id, shipment_workflow_status, container_number, source_deal_header_id, quantity_uom, org_uom_id, base_id, match_order_sequence, parent_recall_id
							, origin_location, destination_location		
					FROM ' + @recall_temp_data

		EXEC spa_print @sql
		EXEC(@sql)

	--EXEC('select * from ' + @match_properties)
	--ROLLBACK TRAN
	--todo
	SELECT DISTINCT TOP 1 match_group_shipment_id, @location_contract_commodity, @storage_location_volume FROM #collect_previous_data
	COMMIT TRAN
END
ELSE IF @flag = 'get_prod_desc_of_match_header' -- get PGS full name
BEGIN 
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)
	SET @sql = 'SELECT  commodity	
					--+ CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.value_id < 0 OR commodity_origin_id.code = ''- Not Specified -'' THEN '''' ELSE '' | '' + commodity_origin_id.code END
					--+  '' |'' + CASE WHEN sdv_form.code IS NULL OR sdv_form.value_id < 0 OR sdv_form.code = ''- Not Specified -'' THEN '''' ELSE sdv_form.code END
					--+ CASE WHEN a.organic IS NULL OR a.organic = '''' OR a.organic = ''n'' THEN '''' ELSE '' | Organic'' END 
					--+ CASE WHEN sdv1.code IS NULL OR sdv1.value_id < 0 OR sdv1.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv1.code END  
					--+ CASE WHEN sdv2.code IS NULL OR sdv2.value_id < 0 OR sdv2.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv2.code END  
					--+ CASE WHEN sdv3.code IS NULL OR sdv3.value_id < 0 OR sdv3.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv3.code END  
					--+ CASE WHEN sdv4.code IS NULL OR sdv4.value_id < 0 OR sdv4.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv4.code END  
					--+ CASE WHEN sdv5.code IS NULL OR sdv5.value_id < 0 OR sdv5.code = ''- Not Specified -'' THEN '''' ELSE '' '' + sdv5.code END product_description
				FROM ' + @match_properties + ' a
				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = a.location

				--LEFT JOIN commodity_origin co ON co.commodity_origin_id = a.saved_origin
 			--	LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
				--	AND type_id = 14000
											 		
				--LEFT JOIN commodity_form cf ON cf.commodity_form_id = a.saved_form
				--LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
				--LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = commodity_form_id.commodity_form_value
				 
				--LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = a.saved_commodity_form_attribute1
				--LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
				--	AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
				--LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value
				
				--LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id =a.saved_commodity_form_attribute2
				--LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
				--	AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
				--LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = a.saved_commodity_form_attribute3
				--LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
				--	AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
				--LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = a.saved_commodity_form_attribute4
				--LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
				--	AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
				--LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

				--LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = a.saved_commodity_form_attribute5
				--LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
				--	AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
				--LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value
				WHERE a.match_group_detail_id = ' + @match_group_detail_id
		EXEC spa_print @sql
		EXEC(@sql)
END
ELSE If @flag = 'replace_into_storage'--replace_into_storage shipment line items (match.php)
BEGIN  	 	
	SET @lineup_vol_id_tbl = dbo.FNAProcessTableName('lineup_vol_id_tbl', @user_name, @process_id) 
	SET @match_properties = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)

	SELECT @match_group_shipment_id = match_group_shipment_id 
	FROM match_group_detail mgd
	INNER JOIN dbo.FNASPlit(@match_group_detail_id, ',') a ON a.item = mgd.match_group_detail_id
	GROUP BY match_group_shipment_id

	CREATE TABLE #data_collection_for_ris(match_group_id INT
										, group_name VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, match_group_shipment_id INT
										, match_group_shipment VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, source_commodity_id INT
										, bookout_split_total_amt FLOAT
										, bookout_split_volume FLOAT
										, min_vol FLOAT
										, bal_quantity FLOAT
										, match_book_auto_id VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, lineup VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, shipment_status INT
										, shipment_workflow_status VARCHAR(1000) COLLATE DATABASE_DEFAULT
										, match_group_header_id INT
										, match_order_sequence  INT
										, match_group_detail_id INT										
										--, origin  				INT 		 
										--, form  				INT 
										--, organic  			 	CHAR(1) COLLATE DATABASE_DEFAULT 
										--, attribute1  		 	INT 
										--, attribute2  		 	INT 
										--, attribute3  		 	INT 
										--, attribute4  		 	INT 
										--, attribute5  		 	INT 
										, crop_year  		 	INT 
										, detail_inco_terms   	INT 																					  																				
										)		
									
	SET @sql = 	'INSERT INTO #data_collection_for_ris
				SELECT match_group_id
					, group_name
					, match_group_shipment_id
					, match_group_shipment
					, source_commodity_id
					, ' + @split_quantity + ' bookout_split_total_amt
					, ' + @split_quantity + ' bookout_split_volume
					, ' + @split_quantity + ' min_vol
					, ' + @split_quantity + ' bal_quantity 
					, match_book_auto_id
					, lineup
					, shipment_status
					, shipment_workflow_status
					, match_group_header_id
					, match_order_sequence
					, match_group_detail_id
					--, saved_origin
					--, saved_form
					--, organic
					--, saved_commodity_form_attribute1
					--, saved_commodity_form_attribute2
					--, saved_commodity_form_attribute3
					--, saved_commodity_form_attribute4
					--, saved_commodity_form_attribute5						
					, crop_year_id
					, inco_terms_id
				FROM ' + @match_properties + ' mp 
				INNER JOIN dbo.FNASplit(''' + @match_group_detail_id + ''', '','') mgdi ON mgdi.item = mp.match_group_detail_id
				INNER JOIN dbo.FNASplit(''' + @match_deal_detail_id + ''', '','') mddi ON mddi.item = mp.source_deal_detail_id	'								
	EXEC spa_print @sql
	EXEC(@sql)		
			
	----select * from  #data_collection_for_ris
	--EXEC('select match_group_header_id, count(match_group_header_id) from ' + @match_properties + ' where match_group_shipment_id = ' + @match_group_shipment_id + 'Group by match_group_header_id')

	--return 

	SELECT @template_id = clm3_value 
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE gmh.mapping_name = 'Scheduling Storage Mapping'
		AND clm1_value = @injection_withdrawal
		
	SELECT @deal_pre = ISNULL(prefix, 'ST-') 
	FROM deal_reference_id_prefix drp
	INNER JOIN source_deal_type sdp ON sdp.source_deal_type_id = drp.deal_type
	WHERE deal_type_id = 'Storage'

	IF @deal_pre IS NULL 
		SET @deal_pre = 'ST-'

	SET @new_source_deal_header_id = IDENT_CURRENT('source_deal_header') + 1
	SET @new_source_deal_detail_id = IDENT_CURRENT('source_deal_detail') + 1

	SET @deal_pre  = @deal_pre + CAST(@new_source_deal_header_id AS VARCHAR(100))
		
	SELECT TOP 1
		--@origin  					= origin  			 
		--, @form  					= form  				 	 
		--, @attribute1  				= attribute1  		 
		--, @attribute2  				= attribute2  		 
		--, @attribute3  				= attribute3  		 
		--, @attribute4  				= attribute4  		 
		--, @attribute5  				= attribute5  		
		--,
		 @crop_year  				= crop_year  		 
		, @detail_inco_terms		= detail_inco_terms   
		--, @organic					= ISNULL(organic, 'n')
		, @match_group_shipment_id  = match_group_shipment_id
	FROM #data_collection_for_ris

	BEGIN TRY 
		BEGIN TRAN 
		SET @sql = '
				INSERT INTO ' + @match_properties + ' ( match_book_auto_id	
												, match_group_id	
												, group_name	
												, match_group_shipment_id
												, bookout_split_total_amt	
												, bookout_split_volume	
												, min_vol		
												, bal_quantity	
												, source_commodity_id	
												, commodity	
												, source_minor_location_id	
												, location	
												, source_counterparty_id	
												, counterparty_name	
												, source_deal_detail_id	
												, match_group_header_id																 		
												, is_complete	
												, deal_id	
												, buy_sell_flag	
												, bookout_match	
												, frequency
												, split_deal_detail_volume_id
												, source_major_location_ID																 	
												, region
												, lineup
												, deal_type
												, scheduling_period
												, scheduled_to
												, scheduled_from
												, status
												, sorting_ids
												, match_group_shipment
												, match_number
												, last_edited_by
												, last_edited_on
												 
												, inco_terms_id
												, crop_year_id
												, lot
												, batch_id
												, shipment_workflow_status
												, shipment_status
												, source_minor_location_id_split	
												, location_split
												, source_deal_header_id
												, quantity_uom
												, org_uom_id
												, match_order_sequence
												, match_group_detail_id
 												, destination_location
												) 
												'
			SET @sql =   
					@sql + 
					' SELECT DISTINCT
						--*
							dct.match_book_auto_id match_book_auto_id
						, dct.match_group_id	
						, dct.group_name	
						, dct.match_group_shipment_id 
						, dct.bookout_split_total_amt	
						, dct.bookout_split_volume	
						, dct.bookout_split_total_amt min_vol	
						, bookout_split_total_amt bal_quantity	
						, dct.source_commodity_id source_commodity_id
						, sc.commodity_name
						, sml.source_minor_location_id
						--, CASE WHEN sml.location_name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smajor.location_name IS NULL THEN '''' ELSE  '' ['' + smajor.location_name + '']'' END location_split
						, sml.source_minor_location_id
						, sco.source_counterparty_id
						, sco.counterparty_id
						, -1
						, dct.match_group_header_id
						, 0
						, ''' + CAST(@new_source_deal_header_id AS VARCHAR(100)) +  ' [' + @deal_pre + ']''' + ' 
						, ''s''
						, ''m''
						, ' + CAST(ISNULL(@convert_frequency, 703) AS VARCHAR(100)) + ' 
						, -1
						, smajor.source_major_location_ID
						, ISNULL(sml.region, sml.source_minor_location_id)  region
						, lineup
						, sdt.deal_type_id
						, CAST(DATEPART(yy, ''' + CAST(@term_start AS VARCHAR(100)) + ''') AS VARCHAR(100)) + '' - '' + CAST(DATENAME(MM, ''' + CAST(@term_start AS VARCHAR(100)) + ''') AS VARCHAR(3)) 
						, ''' + CAST(@term_start AS VARCHAR(100)) + ''' term_start
						, ''' + CAST(@term_start AS VARCHAR(100)) + ''' term_end
						, 47000   
						, 1
						, dct.match_group_shipment
						, dct.match_book_auto_id	
						, dbo.FNADBUser()
						, GETDATE()
						 
						, ' + ISNULL(@detail_inco_terms, 'NULL') + ' detail_inco_terms
						, ' + ISNULL(@crop_year, 'NULL') + ' crop_year
						, ' + CAST(@new_source_deal_detail_id AS VARCHAR(1000)) + ' lot
						, NULL batch_id							
						, dct.shipment_workflow_status
						, dct.shipment_status
						, sml.source_minor_location_id
						, sml.source_minor_location_id
						--, CASE WHEN sml.location_name <> sml.location_id THEN sml.location_id + '' - '' + sml.Location_Name ELSE sml.Location_Name END + CASE WHEN smajor.location_name IS NULL THEN '''' ELSE  '' ['' + smajor.location_name + '']'' END location_split
						, -1 source_deal_header_id
						, ' + CAST(@convert_uom AS VARCHAR(100)) + '
						, ' + CAST(@convert_uom AS VARCHAR(100)) + ' position_uom
						, dct.match_order_sequence
						, dct.match_group_detail_id
 						, sml.source_minor_location_id
				FROM source_deal_header_template sdht
				INNER JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id
					AND sdht.template_id = ' + CAST(@template_id AS VARCHAR(1000)) + '
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = ' + CAST(@location_to AS VARCHAR(100)) + '
				LEFT JOIN source_major_location smajor ON smajor.source_major_location_ID = sml.source_major_location_ID					
				LEFT JOIN source_counterparty sco ON sco.source_counterparty_id =  ' + CAST(@storage_operator AS VARCHAR(100)) + '
				LEFT JOIN source_deal_type sdt ON sdht.source_deal_type_id = sdt.source_deal_type_id
				CROSS APPLY #data_collection_for_ris dct
				LEFT JOIN source_commodity sc ON sc.source_commodity_id = dct.source_commodity_id
				'																	
		EXEC spa_print @sql
		EXEC(@sql)	

		 
		SET @sql = '
					--SELECT *  
					DELETE mp 
					FROM ' + @match_properties + ' mp 
					INNER JOIN dbo.FNASplit(''' + @match_group_detail_id + ''', '','') mgdi ON mgdi.item = mp.match_group_detail_id
					INNER JOIN dbo.FNASplit(''' + @match_deal_detail_id + ''', '','') mddi ON mddi.item = mp.source_deal_detail_id'
		EXEC spa_print @sql
		EXEC(@sql)	
		

		/*check fpr same location start*/
		IF OBJECT_ID('tempdb..#check_same_location_replace') IS NOT NULL 
			DROP TABLE #check_same_location_replace

		CREATE TABLE #check_same_location_replace(source_minor_location_id INT, match_group_header_id_pre INT, replaced_match_group_detailed_id INT, match_book_auto_id VARCHAR(1000) COLLATE DATABASE_DEFAULT)
		--EXEC('select * from ' + @match_properties)
		SET @sql = '
					INSERT INTO #check_same_location_replace(source_minor_location_id, match_group_header_id_pre, replaced_match_group_detailed_id, match_book_auto_id)
					SELECT a.source_minor_location_id, a.match_group_header_id match_group_header_id_pre, ' + @match_group_detail_id + ' replaced_match_group_detailed_id, a.match_book_auto_id
					FROM ' + @match_properties + ' a 
					INNER JOIN (
						SELECT source_minor_location_id
						FROM ' + @match_properties 
						+ ' WHERE match_group_shipment_id = ' + @match_group_shipment_id 
						+ ' GROUP BY source_minor_location_id
						--, match_group_header_id
						, source_commodity_id
						--, saved_origin
						--, saved_form
						--, ISNULL(organic, '''')
						--, saved_commodity_form_attribute1
						--, saved_commodity_form_attribute2
						--, saved_commodity_form_attribute3	
						--, saved_commodity_form_attribute4	
						--, saved_commodity_form_attribute5
						HAVING COUNT(source_minor_location_id) > 1) b ON b.source_minor_location_id = a.source_minor_location_id 
					WHERE a.match_group_detail_id NOT IN( ' + @match_group_detail_id + ')
						AND match_group_shipment_id = ' + @match_group_shipment_id  

		EXEC spa_print @sql
		EXEC(@sql)
		 
		SET @same_location_data = dbo.FNAProcessTableName('same_location_data', @user_name, @process_id) 

		SET @sql = 'IF OBJECT_ID(''' + @same_location_data + ''', ''U'') IS NOT NULL
					DROP TABLE ' + @same_location_data 
		EXEC spa_print @sql
		EXEC(@sql)

		SET @sql = 'SELECT *
					INTO ' + @same_location_data + ' FROM #check_same_location_replace 
						'

		EXEC spa_print @sql
		EXEC(@sql)

  		IF EXISTS(SELECT 1 FROM #check_same_location_replace)
		BEGIN 
			SET @sql = '					
					--SELECT *  
					UPDATE mp 
					SET mp.match_group_header_id =  b.match_group_header_id_pre
						, mp.match_book_auto_id = b.match_book_auto_id
						, mp.match_number = b.match_book_auto_id
					FROM ' + @match_properties + ' mp
					--INNER JOIN #check_same_location_replace b ON b.replaced_match_group_detailed_id = mp.match_group_detail_id
					OUTER APPLY #check_same_location_replace  b  
					WHERE match_group_shipment_id = ' + @match_group_shipment_id  
			EXEC spa_print @sql
			EXEC(@sql)			
		END
		ELSE 
		BEGIN 
			SELECT @parent_line = sc.counterparty_id 
			FROM portfolio_hierarchy pf 
			INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = pf.entity_id
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id
				AND pf.entity_id = -1

			SET @sql = '					
					--SELECT *  
					UPDATE a 
					SET a.match_group_header_id =  (IDENT_CURRENT(''match_group_header'')+ 1) * -1
					, match_book_auto_id =  ''MTC - [ID] - '' + sml.location_id + '' - '' 
											+ commodity	
											--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.code = ''- Not Specified -'' OR sdv_form.value_id < 0 THEN '''' ELSE '' | '' + sdv_form.code END 
											--+ '' |'' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = ''- Not Specified -'' OR commodity_origin_id.value_id < 0 THEN '''' ELSE commodity_origin_id.code END											
											--+ CASE WHEN a.organic IS NULL OR a.organic = ''n'' THEN '''' ELSE '' | Organic '' END
											--+ CASE WHEN sdv1.code IS NULL OR sdv1.code = ''- Not Specified -'' OR sdv1.value_id < 0 THEN '''' ELSE '' '' + sdv1.code END  
											--+ CASE WHEN sdv2.code IS NULL OR sdv2.code = ''- Not Specified -'' OR sdv2.value_id < 0 THEN '''' ELSE '' '' + sdv2.code END  
											--+ CASE WHEN sdv3.code IS NULL OR sdv3.code = ''- Not Specified -'' OR sdv3.value_id < 0 THEN '''' ELSE '' '' + sdv3.code END  
											--+ CASE WHEN sdv4.code IS NULL OR sdv4.code = ''- Not Specified -'' OR sdv4.value_id < 0 THEN '''' ELSE '' '' + sdv4.code END  
											--+ CASE WHEN sdv5.code IS NULL OR sdv5.code = ''- Not Specified -'' OR sdv5.value_id < 0 THEN '''' ELSE '' '' + sdv5.code END  											  	
					, match_number = ''MTC - [ID] - '' + sml.location_id + '' - '' 
									+ commodity	
									--+ CASE WHEN sdv_form.code IS NULL OR sdv_form.code = ''- Not Specified -'' OR sdv_form.value_id < 0 THEN '''' ELSE '' | '' + sdv_form.code END 
									--+ '' |'' + CASE WHEN commodity_origin_id.code IS NULL OR commodity_origin_id.code = ''- Not Specified -'' OR commodity_origin_id.value_id < 0 THEN '''' ELSE commodity_origin_id.code END											
									--+ CASE WHEN a.organic IS NULL OR a.organic = ''n'' THEN '''' ELSE '' | Organic '' END
									--+ CASE WHEN sdv1.code IS NULL OR sdv1.code = ''- Not Specified -'' OR sdv1.value_id < 0 THEN '''' ELSE '' '' + sdv1.code END  
									--+ CASE WHEN sdv2.code IS NULL OR sdv2.code = ''- Not Specified -'' OR sdv2.value_id < 0 THEN '''' ELSE '' '' + sdv2.code END  
									--+ CASE WHEN sdv3.code IS NULL OR sdv3.code = ''- Not Specified -'' OR sdv3.value_id < 0 THEN '''' ELSE '' '' + sdv3.code END  
									--+ CASE WHEN sdv4.code IS NULL OR sdv4.code = ''- Not Specified -'' OR sdv4.value_id < 0 THEN '''' ELSE '' '' + sdv4.code END  
									--+ CASE WHEN sdv5.code IS NULL OR sdv5.code = ''- Not Specified -'' OR sdv5.value_id < 0 THEN '''' ELSE '' '' + sdv5.code END   	
					, lineup =  STUFF((
									SELECT '','' + counterparty_name
									FROM ' + @match_properties + '
									where buy_sell_flag = ''b''
									FOR XML PATH('''')), 1, 1, '''')
									+ '' - '' 
									+  ''' + @parent_line + ''' + '' - '' 
									+ STUFF((SELECT '','' + counterparty_name
										FROM ' + @match_properties + '
										WHERE buy_sell_flag = ''s''
										FOR XML PATH('''')), 1, 1, '''')
					FROM ' + @match_properties + ' a
					LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = a.location

					--LEFT JOIN commodity_origin co ON co.commodity_origin_id = a.saved_origin
 				--	LEFT JOIN static_data_value commodity_origin_id ON commodity_origin_id.value_id = co.origin
					--	AND type_id = 14000
											 		
					--LEFT JOIN commodity_form cf ON cf.commodity_form_id = a.saved_form
					--LEFT JOIN commodity_type_form commodity_form_id ON commodity_form_id.commodity_type_form_id = cf.form
					--LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = commodity_form_id.commodity_form_value
				 
					--LEFT JOIN commodity_form_attribute1 cfa1 ON cfa1.commodity_form_attribute1_id = a.saved_commodity_form_attribute1
					--LEFT JOIN #commodity_attribute_form_detail cafd1 ON cafd1.commodity_attribute_id = cfa1.attribute_id
					--	AND cafd1.commodity_attribute_form_id = cfa1.attribute_form_id
					--LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cafd1.commodity_attribute_value
				
					--LEFT JOIN commodity_form_attribute2 cfa2 ON cfa2.commodity_form_attribute2_id =a.saved_commodity_form_attribute2
					--LEFT JOIN #commodity_attribute_form_detail cafd2 ON cafd2.commodity_attribute_id = cfa2.attribute_id
					--	AND cafd2.commodity_attribute_form_id = cfa2.attribute_form_id
					--LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cafd2.commodity_attribute_value

					--LEFT JOIN commodity_form_attribute3 cfa3 ON cfa3.commodity_form_attribute3_id = a.saved_commodity_form_attribute3
					--LEFT JOIN #commodity_attribute_form_detail cafd3 ON cafd3.commodity_attribute_id = cfa3.attribute_id
					--	AND cafd3.commodity_attribute_form_id = cfa3.attribute_form_id
					--LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cafd3.commodity_attribute_value

					--LEFT JOIN commodity_form_attribute4 cfa4 ON cfa4.commodity_form_attribute4_id = a.saved_commodity_form_attribute4
					--LEFT JOIN #commodity_attribute_form_detail cafd4 ON cafd4.commodity_attribute_id = cfa4.attribute_id
					--	AND cafd4.commodity_attribute_form_id = cfa4.attribute_form_id
					--LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cafd4.commodity_attribute_value

					--LEFT JOIN commodity_form_attribute5 cfa5 ON cfa5.commodity_form_attribute5_id = a.saved_commodity_form_attribute5
					--LEFT JOIN #commodity_attribute_form_detail cafd5 ON cafd5.commodity_attribute_id = cfa5.attribute_id
					--	AND cafd5.commodity_attribute_form_id = cfa5.attribute_form_id
					--LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cafd5.commodity_attribute_value
				 
					WHERE a.match_group_shipment_id = ' + @match_group_shipment_id + ' 
						AND a.match_group_detail_id = ' +  @match_group_detail_id
			EXEC spa_print @sql
			EXEC(@sql)		
		END
		/*check fpr same location end*/
		SET @return_str = CAST(@match_group_detail_id AS VARCHAR(100)) + '_' + CAST(@location_to AS VARCHAR(100)) + '_NULL_NULL_replaceintostorage' + '_' + CAST(@match_deal_detail_id AS VARCHAR(100))	 
			
		--EXEC('select * from ' + @match_properties)		
		--	ROLLBACK TRAN
		COMMIT TRAN
	
		EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Success',
			'Data Successfully Updated.',
			@return_str
	END TRY 
	BEGIN CATCH
		--SELECT ERROR_MESSAGE()
		ROLLBACK TRAN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Error updating data.',
			''
	END CATCH											
END
ELSE IF @flag = 'complete' --mark shipment as complete
BEGIN 
	BEGIN TRY
		BEGIN TRAN
		--select * from 
		UPDATE mgd
		SET mgd.is_complete = 1
		FROM match_group_detail mgd 
		INNER JOIN dbo.FNASplit(@match_id, ',') i ON i.item = mgd.match_group_header_id
	
		COMMIT TRAN
		EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Success',
			'Data Successfully Updated.',
			@return_str
	END TRY 
	BEGIN CATCH
		--SELECT ERROR_MESSAGE()
		ROLLBACK TRAN 
		EXEC spa_ErrorHandler -1,
			'Matching/Bookout Deals',
			'spa_scheduling_workbench',
			'Error',
			'Error updating data.',
			''
	END CATCH
END

GO


