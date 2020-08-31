IF OBJECT_ID(N'[dbo].[spa_scheduling_workbench_delivery_details]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_scheduling_workbench_delivery_details]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2017-01-31
-- Description: Create a deal using delivery details
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_scheduling_workbench_delivery_details]
	@flag CHAR(1),
	@process_id VARCHAR(200) = NULL,
    @grid_xml XML = NULL,
    @term_start DATETIME = NULL,
    @term_end DATETIME = NULL,
    @reciept_volume NUMERIC(38, 20) = NULL,
    @delivery_volume NUMERIC(38, 20) = NULL,
	@shipment_id INT = NULL,
	@shipment_status INT = NULL,
	@convert_uom INT = NULL

AS

 
SET NOCOUNT ON
--RETURN
DECLARE @sql VARCHAR(MAX)
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()

DECLARE @desc VARCHAR(500)
DECLARE @err_no INT

IF @process_id IS NULL	
	SET @process_id = dbo.FNAGetNewID()
	
DECLARE @match_propertes VARCHAR(5000)
SET @match_propertes = dbo.FNAProcessTableName('match_propertes', @user_name, @process_id)

CREATE TABLE #temp_tbl_form (
   	seq_no                          INT IDENTITY(1, 1) NOT NULL,
   	match_group_id                  INT,
   	group_name                      VARCHAR(1000),
   	match_group_shipment_id         INT,
   	match_group_shipment            VARCHAR(MAX),
   	match_group_header_id           INT,
   	match_book_auto_id              VARCHAR(1000),
   	source_commodity_id             VARCHAR(1000),
   	commodity                       VARCHAR(1000),
   	source_minor_location_id        VARCHAR(1000),
   	location                        VARCHAR(1000),
   	last_edited_by                  VARCHAR(1000),
   	last_edited_on                  DATETIME,
   	[status]                        VARCHAR(1000),
   	scheduler                       VARCHAR(1000),
   	container                       VARCHAR(1000),
   	carrier                         VARCHAR(1000),
   	consignee                       VARCHAR(1000),
   	pipeline_cycle                  VARCHAR(1000),
   	scheduling_period               VARCHAR(1000),
   	scheduled_to                    DATETIME,
   	scheduled_from                  DATETIME,
   	po_number                       VARCHAR(1000),
   	comments                        VARCHAR(1000),
   	match_number                    VARCHAR(1000),
   	lineup                          VARCHAR(1000),
   	saved_origin                    INT,
   	saved_form                      INT,
   	organic                         CHAR(1),
   	saved_commodity_form_attribute1 INT,
   	saved_commodity_form_attribute2 INT,
   	saved_commodity_form_attribute3 INT,
   	saved_commodity_form_attribute4 INT,
   	saved_commodity_form_attribute5 INT,
   	bookout_match                   CHAR(1),
   	match_group_detail_id           INT,
   	notes                           VARCHAR(1000),
   	estimated_movement_date         DATETIME,
   	estimated_movement_date_to      DATETIME,
   	source_counterparty_id          VARCHAR(1000),
   	counterparty_name               VARCHAR(1000),
   	source_deal_detail_id           VARCHAR(1000),
   	bookout_split_total_amt         NUMERIC(38, 4),
   	bookout_split_volume            NUMERIC(38, 4),
   	min_vol                         NUMERIC(38, 4),
   	actualized_amt                  NUMERIC(38, 4),
   	bal_quantity                    NUMERIC(38, 4),
   	is_complete                     CHAR(1),
   	deal_id                         VARCHAR(1000),
   	buy_sell_flag                   CHAR(1),
   	frequency                       INT,
   	multiple_single_deals           CHAR(1),
   	multiple_single_location        CHAR(1),
   	split_deal_detail_volume_id     INT,
   	source_major_location_ID        INT,
   	deal_type                       VARCHAR(MAX),
   	region                          INT,
   	form_location_id                INT,
   	source_minor_location_id_split INT,
   	location_split                  VARCHAR(1000),
   	sorting_ids                     INT,
   	base_deal_detail_id             INT,
   	shipment_status                 INT,
   	from_location                   INT,
   	to_location                     INT,
   	incoterm                        VARCHAR(1000),
   	crop_year                       VARCHAR(1000),
   	inco_terms_id                   INT,
   	crop_year_id                    INT,
   	lot                             VARCHAR(1000),
   	batch_id                        VARCHAR(1000),
   	shipment_workflow_status        INT,
   	container_number                VARCHAR(MAX),
   	source_deal_header_id           INT,
   	quantity_uom                    INT,
   	org_uom_id                      INT,
	match_order_sequence			INT
)
	
IF OBJECT_ID(@match_propertes) IS NOT NULL
BEGIN
   	SET @sql = 'INSERT INTO #temp_tbl_form(
   					match_group_id, group_name, match_group_shipment_id, match_group_shipment, match_group_header_id, match_book_auto_id, source_commodity_id, 
					commodity, source_minor_location_id, location, last_edited_by, last_edited_on, status, scheduler, container, carrier, consignee, pipeline_cycle, 
					scheduling_period, scheduled_to, scheduled_from, po_number, comments, match_number, lineup, saved_origin, saved_form, organic, 
					saved_commodity_form_attribute1, saved_commodity_form_attribute2, saved_commodity_form_attribute3, saved_commodity_form_attribute4, saved_commodity_form_attribute5, 
					bookout_match, match_group_detail_id, notes, estimated_movement_date, estimated_movement_date_to, source_counterparty_id, counterparty_name, 
					source_deal_detail_id, bookout_split_total_amt, bookout_split_volume, min_vol, actualized_amt, bal_quantity, is_complete, deal_id, buy_sell_flag, 
					frequency, multiple_single_deals, multiple_single_location, split_deal_detail_volume_id, source_major_location_ID, deal_type, region, 
					form_location_id, source_minor_location_id_split, location_split, sorting_ids, base_deal_detail_id, shipment_status, from_location, to_location, incoterm, 
					crop_year, inco_terms_id, crop_year_id, lot, batch_id, shipment_workflow_status, container_number, source_deal_header_id, quantity_uom, org_uom_id, match_order_sequence
   				)
   				SELECT  match_group_id, group_name, match_group_shipment_id, match_group_shipment, match_group_header_id, match_book_auto_id, source_commodity_id, 
						commodity, source_minor_location_id, location, last_edited_by, last_edited_on, status, scheduler, container, carrier, consignee, pipeline_cycle, 
						scheduling_period, scheduled_to, scheduled_from, po_number, comments, match_number, lineup, saved_origin, saved_form, organic, 
						saved_commodity_form_attribute1, saved_commodity_form_attribute2, saved_commodity_form_attribute3, saved_commodity_form_attribute4, saved_commodity_form_attribute5, 
						bookout_match, match_group_detail_id, notes, estimated_movement_date, estimated_movement_date_to, source_counterparty_id, counterparty_name, 
						source_deal_detail_id, bookout_split_total_amt, bookout_split_volume, min_vol, actualized_amt, bal_quantity, is_complete, deal_id, buy_sell_flag, 
						frequency, multiple_single_deals, multiple_single_location, split_deal_detail_volume_id, source_major_location_ID, deal_type, region, 
						form_location_id, source_minor_location_id_split, location_split, sorting_ids, base_deal_detail_id, shipment_status, from_location, to_location, incoterm, 
						crop_year, inco_terms_id, crop_year_id, lot, batch_id, shipment_workflow_status, container_number, source_deal_header_id, quantity_uom, org_uom_id, match_order_sequence 
   				FROM ' + @match_propertes  + '  
				WHERE match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20))
	
	EXEC spa_print @sql
   	EXEC(@sql)
END

IF @flag = 's'
BEGIN
    IF @grid_xml IS NOT NULL
   	BEGIN
   		DECLARE @delivery_details_table VARCHAR(300)  
   		DECLARE @idoc INT
   		 	
   		SET @delivery_details_table = dbo.FNAProcessTableName('delivery_details', @user_name, @process_id)	   			
   		EXEC spa_parse_xml_file 'b', NULL, @grid_xml, @delivery_details_table
   		

   		IF NOT EXISTS (SELECT 1 FROM #temp_tbl_form)
   		BEGIN
   			EXEC spa_ErrorHandler -1
				, 'spa_scheduling_workbench_delivery_details'
				, 'spa_scheduling_workbench_delivery_details'
				, 'Error'
				, 'No data found to process.'
				, ''
			RETURN
   		END
   		
   		IF EXISTS(
   			SELECT SUM(bookout_split_volume)
			FROM (
   				SELECT SUM(CASE WHEN buy_sell_flag = 's' THEN -1*bookout_split_volume ELSE bookout_split_volume END)	bookout_split_volume 					
				FROM #temp_tbl_form
				GROUP BY buy_sell_flag
			) a 
   			HAVING SUM(bookout_split_volume) > 1
   		)
   		BEGIN
   			EXEC spa_ErrorHandler -1
				, 'spa_scheduling_workbench_delivery_details'
				, 'spa_scheduling_workbench_delivery_details'
				, 'Error'
				, 'Receipts and Delivery Quantity does not match.'
				, ''
			RETURN			
   		END
   		
   		IF EXISTS(
   			SELECT 1 
   			FROM #temp_tbl_form t1
   			INNER JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = t1.match_group_shipment_id
   			WHERE mgs.is_transport_deal_created = 1
   		)
   		BEGIN
   			EXEC spa_ErrorHandler -1
				, 'spa_scheduling_workbench_delivery_details'
				, 'spa_scheduling_workbench_delivery_details'
				, 'Error'
				, 'Transport deals already created for some shipment.'
				, ''
			RETURN			
   		END
   		
   		
   		DECLARE @deal_type       INT,
   				@header_id		 VARCHAR(200),
   		        @template_id     INT,
   		        @sub_book		 INT,
   		        @deal_detail_id  VARCHAR(200),
   		        @trader_id		INT,
				@contract_id	INT
   		
   		SELECT @header_id = COALESCE(@header_id + ',', '') + CAST(source_deal_header_id AS VARCHAR(10))
   		FROM #temp_tbl_form
   		WHERE buy_sell_flag = 'b'   		
   		
   		IF OBJECT_ID('tempdb..#temp_xml_data') IS NOT NULL
   			DROP TABLE #temp_xml_data
   		
   		CREATE TABLE #temp_xml_data(
   			id                       INT IDENTITY(1, 1) NOT NULL,
   			group_path_id            INT,
   			path_id                  INT,
   			rec_loc_id               INT,
   			del_loc_id               INT,
   			mode_of_transport_id     INT,
   			booking_counterparty     INT,
   			carrier_counterparty     INT,
   			contract_id              INT,
   			rate_schedule            INT,
   			no_of_days               INT NULL,
   			no_of_hours              INT NULL,
			is_group_path			 CHAR(1)
   		)
   		
   		SET @sql = 'INSERT INTO #temp_xml_data(group_path_id, path_id, rec_loc_id, del_loc_id, mode_of_transport_id, booking_counterparty, carrier_counterparty, contract_id, rate_schedule, no_of_days, no_of_hours, is_group_path)
   					SELECT delivery_path_id, path_id, rec_loc_id, del_loc_id, mode_of_transport_id, booking_counterparty, carrier_counterparty, contract_id, rate_schedule, [day], [hour], CASE WHEN delivery_path_id = path_id THEN ''n'' ELSE ''y'' END
   					FROM ' + @delivery_details_table + '
   		'
   		EXEC(@sql)
		DECLARE @mode_of_transport INT

   		SELECT TOP(1) @deal_type = sdh.source_deal_type_id,
   					  @trader_id = ISNULL(@trader_id, sdh.trader_id)
   		FROM source_deal_header sdh 
   		INNER JOIN dbo.SplitCommaSeperatedValues(@header_id) scsv ON sdh.source_deal_header_id = scsv.item
   		
		SELECT TOP(1) @mode_of_transport = mode_of_transport_id
		FROM #temp_xml_data

		-- TODO: GET template id using deal type from generic mapping
   		SELECT  @template_id = clm3_value, 
			    @sub_book = clm4_value
		FROM generic_mapping_header gmh
		INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
		WHERE gmh.mapping_name = 'Scheduling Transportation Mapping'
		--AND clm1_value = CAST(@deal_type AS VARCHAR(20)) --AND clm2_value = CAST(@mode_of_transport AS VARCHAR(20))
		AND clm1_value IN (SELECT CAST(source_deal_type_id AS VARCHAR(1000)) FROM source_deal_type WHERE deal_type_id = 'Transportation')
		--select @deal_type, @template_id

		--select * from source_deal_header_template where template_id = @template_id
		--return 


   		-- TODO: GET template id using deal type from generic mapping   	
		SELECT @template_id = sdht.template_id
   		FROM source_deal_header_template sdht 
   		WHERE sdht.template_name = 'Transportation'  
			AND NULLIF(@template_id, '') IS NULL 

		SELECT @trader_id = ISNULL(trader_id, @trader_id), @contract_id = sdht.contract_id
   		FROM source_deal_header_template sdht 
   		WHERE sdht.template_id = @template_id 
		
   		IF OBJECT_ID('tempdb..#temp_detail_template') IS NOT NULL
			DROP TABLE #temp_detail_template

		CREATE TABLE #temp_detail_template (
			template_detail_id INT IDENTITY(1,1),
			buy_sell_flag CHAR(1),
			leg INT,
			fixed_price_currency_id INT,
			source_commodity_id INT,
			origin INT,
			form INT,
			organic CHAR(1),
			attribute1 INT,
			attribute2 INT,
			attribute3 INT,
			attribute4 INT,
			attribute5 INT,
			match_group_detail_id INT,
			lot VARCHAR(MAX)
		)

		INSERT INTO #temp_detail_template(
			buy_sell_flag, leg, fixed_price_currency_id, source_commodity_id, origin, form,
		    organic, attribute1, attribute2, attribute3, attribute4, attribute5, match_group_detail_id, lot
		)
		SELECT 
			sddt.buy_sell_flag,
			sddt.leg,
			sddt.fixed_price_currency_id,
			a.source_commodity_id, 
			NULL,--a.saved_origin,
			NULL,--a.saved_form,
			NULL,--a.organic,
			NULL,--a.saved_commodity_form_attribute1,
			NULL,--a.saved_commodity_form_attribute2,
			NULL,--a.saved_commodity_form_attribute3,
			NULL,--a.saved_commodity_form_attribute4,
			NULL,--a.saved_commodity_form_attribute5	
			match_group_detail_id,
			a.lot
		FROM (
			SELECT source_commodity_id,
			    --   saved_origin,
			    --   saved_form,
			    --   ISNULL(organic, 'n') organic,
			    --   saved_commodity_form_attribute1,
			    --   saved_commodity_form_attribute2,
			    --   saved_commodity_form_attribute3,
			    --   saved_commodity_form_attribute4,
			    --   saved_commodity_form_attribute5,
				   match_group_detail_id,
				   buy_sell_flag, 
				   lot
			FROM #temp_tbl_form
			GROUP BY source_commodity_id, match_group_detail_id,buy_sell_flag, lot
			       --saved_origin,
			       --saved_form,
			       --ISNULL(organic, 'n'),
			       --saved_commodity_form_attribute1,
			       --saved_commodity_form_attribute2,
			       --saved_commodity_form_attribute3,
			       --saved_commodity_form_attribute4,
			       --saved_commodity_form_attribute5
		) a 
		OUTER APPLY (SELECT * FROM source_deal_detail_template WHERE template_id = @template_id) sddt
		WHERE a.buy_sell_flag <> sddt.buy_sell_flag
			AND match_group_detail_id IS NOT NULL


	--	select * 
		UPDATE tdt
		SET 
			origin		=  ttf.saved_origin,
			form		=  ttf.saved_form,
			organic 	= ISNULL(ttf.organic, 'n'),
			attribute1  =  ttf.saved_commodity_form_attribute1,
			attribute2  =  ttf.saved_commodity_form_attribute2,
			attribute3  =  ttf.saved_commodity_form_attribute3,
			attribute4  =  ttf.saved_commodity_form_attribute4,
			attribute5  =  ttf.saved_commodity_form_attribute5
		FROM #temp_detail_template tdt
		INNER JOIN #temp_tbl_form ttf ON ISNULL(ttf.match_group_detail_id, '') = ISNULL(tdt.match_group_detail_id, '')


		UPDATE #temp_detail_template
		SET leg = template_detail_id
   		
		/*added for storage deals*/
		IF OBJECT_ID('tempdb..#temp_detail_template_str') IS NOT NULL
			DROP TABLE #temp_detail_template_str

		CREATE TABLE #temp_detail_template_str (
			template_detail_id INT IDENTITY(1,1),
			buy_sell_flag CHAR(1),
			leg INT,
			fixed_price_currency_id INT,
			source_commodity_id INT,
			origin INT,
			form INT,
			organic CHAR(1),
			attribute1 INT,
			attribute2 INT,
			attribute3 INT,
			attribute4 INT,
			attribute5 INT,
			match_group_detail_id INT,
			lot VARCHAR(MAX)
		)

		INSERT INTO #temp_detail_template_str(
			buy_sell_flag, leg, fixed_price_currency_id, source_commodity_id, origin, form,
		    organic, attribute1, attribute2, attribute3, attribute4, attribute5, match_group_detail_id, lot
		)
		SELECT 
			sddt.buy_sell_flag,
			sddt.leg,
			sddt.fixed_price_currency_id,
			a.source_commodity_id, 
			NULL,--a.saved_origin,
			NULL,--a.saved_form,
			NULL,--a.organic,
			NULL,--a.saved_commodity_form_attribute1,
			NULL,--a.saved_commodity_form_attribute2,
			NULL,--a.saved_commodity_form_attribute3,
			NULL,--a.saved_commodity_form_attribute4,
			NULL,--a.saved_commodity_form_attribute5	
			match_group_detail_id,
			a.lot
		FROM (
			SELECT source_commodity_id,
			    --   saved_origin,
			    --   saved_form,
			    --   ISNULL(organic, 'n') organic,
			    --   saved_commodity_form_attribute1,
			    --   saved_commodity_form_attribute2,
			    --   saved_commodity_form_attribute3,
			    --   saved_commodity_form_attribute4,
			    --   saved_commodity_form_attribute5,
				   match_group_detail_id,
				   buy_sell_flag, 
				   lot
			FROM #temp_tbl_form
			GROUP BY
			       source_commodity_id, match_group_detail_id, buy_sell_flag, lot
			       --saved_origin,
			       --saved_form,
			       --ISNULL(organic, 'n'),
			       --saved_commodity_form_attribute1,
			       --saved_commodity_form_attribute2,
			       --saved_commodity_form_attribute3,
			       --saved_commodity_form_attribute4,
			       --saved_commodity_form_attribute5
		) a 
		OUTER APPLY (SELECT * FROM source_deal_detail_template WHERE template_id = @template_id) sddt
		WHERE a.buy_sell_flag = sddt.buy_sell_flag
			AND match_group_detail_id IS NOT NULL

	--	select * 
		UPDATE tdt
		SET 
			origin		=  ttf.saved_origin,
			form		=  ttf.saved_form,
			organic 	= ISNULL(ttf.organic, 'n'),
			attribute1  =  ttf.saved_commodity_form_attribute1,
			attribute2  =  ttf.saved_commodity_form_attribute2,
			attribute3  =  ttf.saved_commodity_form_attribute3,
			attribute4  =  ttf.saved_commodity_form_attribute4,
			attribute5  =  ttf.saved_commodity_form_attribute5
		FROM #temp_detail_template_str tdt
		INNER JOIN #temp_tbl_form ttf ON ISNULL(ttf.match_group_detail_id, '') = ISNULL(tdt.match_group_detail_id, '')


		UPDATE #temp_detail_template_str
		SET leg = template_detail_id
		
		/*added for storage deals end*/
		--select * from #temp_tbl_form
		--select * from #temp_detail_template
		--select * from #temp_detail_template_str
		--return 


   		SELECT TOP(1) @sub_book = ssbm.book_deal_type_map_id
   		FROM source_deal_header sdh
   		INNER JOIN source_system_book_map ssbm
   			ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
   			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
   			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
   			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
   		INNER JOIN dbo.SplitCommaSeperatedValues(@header_id) scsv ON sdh.source_deal_header_id = scsv.item
		WHERE NULLIF(@sub_book, '') IS NULL

   		DECLARE @header_xml           VARCHAR(MAX),
   		        @counterparty_id      INT,
   		        @counterparty_id2     INT,
   		        @rec_loc_id           INT,
   		        @del_loc_id           INT,
   		        --@contract_id          INT,
   		        @rate_schedule        INT,
   		        @no_of_days           INT,
   		        @no_of_hours          INT,
   		        @detail_commodity_id  VARCHAR(10),
   		        @origin				  VARCHAR(10),
   		        @form_id			  VARCHAR(10),
   		        @organic			  VARCHAR(10),
   		        @attribute1			  VARCHAR(10),
   		        @attribute2			  VARCHAR(10),
   		        @attribute3			  VARCHAR(10),
   		        @attribute4			  VARCHAR(10),
   		        @attribute5			  VARCHAR(10),
   		        @scheduler_id		  VARCHAR(10),
   		        @storage_location	  INT,
				@position_uom		  INT,
				@pack_uom_label		  VARCHAR(100),
				@trans_path_label	  VARCHAR(100),
				@trans_path_detail_id_label		  VARCHAR(100),
				@detail_id			  INT,
				@pack_uom_val		  VARCHAR(100),
				@product_desc		  VARCHAR(MAX)

		SELECT @pack_uom_label = 'UDF___' + CAST(udf_template_id AS VARCHAR(20))
		FROM user_defined_fields_template udft
		WHERE field_name = -5733
   		        
		SELECT @trans_path_label = 'UDF___' + CAST(udf_template_id AS VARCHAR(20))
		FROM user_defined_fields_template udft
		WHERE field_name = -5587

		SELECT @trans_path_detail_id_label = 'UDF___' + CAST(udf_template_id AS VARCHAR(20))
		FROM user_defined_fields_template udft
		WHERE field_name = -5606
   		        
   		DECLARE @detail_xml VARCHAR(MAX)
			
		SET @detail_xml = '<GridXML>'		
   		SET @header_xml = '<GridXML>'
   		
   		DECLARE @id          INT,
   		        @counter     INT = 1
   		        
   		IF OBJECT_ID('tempdb..#temp_location_ordering') IS NOT NULL
   			DROP TABLE #temp_location_ordering
   		
   		CREATE TABLE #temp_location_ordering (order_id INT IDENTITY(1,1), location_id INT, is_group_path CHAR(1), is_storage BIT)
   		        
		DECLARE sdh_cursor CURSOR FORWARD_ONLY READ_ONLY LOCAL 
		FOR
			SELECT id
			FROM #temp_xml_data
			ORDER BY id
		OPEN sdh_cursor
		FETCH NEXT FROM sdh_cursor INTO @id
		WHILE @@FETCH_STATUS = 0   
		BEGIN
			INSERT INTO #temp_location_ordering (location_id, is_group_path, is_storage)
			SELECT a.[location_id], a.is_group_path, CASE WHEN smj.location_type = 11130 THEN 1 ELSE 0 END
			FROM (
				SELECT rec_loc_id [location_id], @id [order_id], is_group_path
				FROM #temp_xml_data t1
				WHERE id = @id
				UNION ALL
				SELECT txd.del_loc_id, @id+1, is_group_path
				FROM #temp_xml_data txd
				WHERE id = @id
			) a
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = a.[location_id]
			LEFT JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID
			LEFT JOIN #temp_location_ordering t1 ON t1.location_id = a.[location_id]
			WHERE t1.order_id IS NULL
			ORDER BY a.order_id
			
			SELECT  @counterparty_id = booking_counterparty,
					@counterparty_id2 = NULLIF(carrier_counterparty, 0),
					@contract_id = CASE WHEN NULLIF(contract_id, 0) IS NULL THEN @contract_id ELSE NULLIF(contract_id, 0)  END ,
					@rec_loc_id = rec_loc_id,
					@del_loc_id = del_loc_id,
					@rate_schedule = NULLIF(rate_schedule, 0),
					@no_of_days = no_of_days,
					@no_of_hours = no_of_hours					
			FROM #temp_xml_data
			WHERE id = @id

			DECLARE @trans_path_value VARCHAR(1000),
					@trans_path_detail_id_value VARCHAR(1000)

			SELECT  @trans_path_value = ISNULL(path_id, ''),
					@trans_path_detail_id_value = ISNULL(group_path_id, '')
			FROM #temp_xml_data
			WHERE id = @id
			        
			SELECT @scheduler_id = ISNULL(MAX(scheduler), ''), @position_uom = MAX(quantity_uom)
			FROM #temp_tbl_form
							
   			SET @header_xml += '<GridRow row_id="' + CAST(@counter AS VARCHAR(10)) + '"'
			SET @header_xml += ' sub_book="' + CAST(@sub_book AS VARCHAR(20)) + '"' + 
							   ' deal_date="' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"' + 
							   ' counterparty_id="' + CAST(@counterparty_id AS VARCHAR(20)) + '"' + 
							   ' counterparty_id2="' + ISNULL(CAST(@counterparty_id2 AS VARCHAR(20)), '') + '"' + 
							   ' contract_id="' + ISNULL(CAST(@contract_id AS VARCHAR(20)), '') + '"' +
							   ' scheduler="' + CAST(@scheduler_id AS VARCHAR(20)) + '"' +
							   ' trader_id="' + CAST(@trader_id AS VARCHAR(20)) + '"' + 						   
							   ' rate_schedule="' + ISNULL(CAST(@rate_schedule AS VARCHAR(20)), '') + '"'
							   
			IF @trans_path_label IS NOT NULL  
			BEGIN
				SET @header_xml += '  ' + @trans_path_label + '="' + CAST(@trans_path_value AS VARCHAR(20)) + '" '
			END

			IF @trans_path_detail_id_label IS NOT NULL 
			BEGIN
				SET @header_xml += '  ' + @trans_path_detail_id_label + '="' + CAST(@trans_path_detail_id_value AS VARCHAR(20)) + '" '
			END
							   
			SET @header_xml += '></GridRow>'


	 

 			DECLARE @template_detail_id     INT = NULL,
			        @detail_counter			INT = 1,
			        @location_id			INT = NULL,
			        @buy_sell				CHAR(1) = NULL,
			        @leg					INT,
			        @volume					NUMERIC(38, 20),
			        @fixed_price_currency   INT
			        
			DECLARE sdd_cursor CURSOR FORWARD_ONLY READ_ONLY LOCAL
			FOR
				SELECT sddt.template_detail_id, sddt.buy_sell_flag, sddt.leg, sddt.fixed_price_currency_id
				FROM #temp_detail_template sddt
				ORDER BY sddt.leg
			OPEN sdd_cursor
			FETCH NEXT FROM sdd_cursor INTO @template_detail_id, @buy_sell, @leg, @fixed_price_currency
			WHILE @@FETCH_STATUS = 0   
			BEGIN
				SET @pack_uom_val = NULL
				SET @detail_xml += '<GridRow row_id="' + CAST(@counter AS VARCHAR(10)) + '" deal_group="" group_id="1" detail_flag="0" '
				
				SELECT  @detail_commodity_id  = ISNULL(MAX(t1.source_commodity_id), ''),
						@origin				  = ISNULL(MAX(t1.saved_origin), ''),
						@form_id			  = ISNULL(MAX(t1.saved_form), ''),
						@organic			  = ISNULL(MAX(t1.organic), 'n'),
						@attribute1			  = ISNULL(MAX(t1.saved_commodity_form_attribute1), ''),
						@attribute2			  = ISNULL(MAX(t1.saved_commodity_form_attribute2), ''),
						@attribute3			  = ISNULL(MAX(t1.saved_commodity_form_attribute3), ''),
						@attribute4			  = ISNULL(MAX(t1.saved_commodity_form_attribute4), ''),
						@attribute5			  = ISNULL(MAX(t1.saved_commodity_form_attribute5), ''),
						@term_start			  = ISNULL(@term_start, MIN(t1.scheduled_from)),
						@term_end			  = ISNULL(@term_end, MAX(t1.scheduled_to)),
						@volume				  = ISNULL(MAX(bookout_split_total_amt), 0),
						@detail_id			  = ISNULL(MAX(t1.source_deal_detail_id), @detail_id)
				FROM #temp_tbl_form t1
				INNER JOIN (
					SELECT t2.source_commodity_id, t2.origin, t2.form, ISNULL(t2.organic, 'n') organic,
					       t2.attribute1, t2.attribute2, t2.attribute3,
					       t2.attribute4, t2.attribute5, t2.template_detail_id, t2.lot
					FROM #temp_detail_template t2
					WHERE t2.template_detail_id = @template_detail_id
				) t2 ON t1.source_commodity_id =  t2.source_commodity_id 
					AND ISNULL(t1.saved_origin, -1) = ISNULL(t2.origin, -1)
					AND ISNULL(t1.saved_form, -1) = ISNULL(t2.form, -1)
					AND ISNULL(t1.organic, 'n') = ISNULL(t2.organic, 'n')
					AND ISNULL(t1.saved_commodity_form_attribute1, -1) = ISNULL(t2.attribute1, -1)
					AND ISNULL(t1.saved_commodity_form_attribute2, -1) = ISNULL(t2.attribute2, -1)
					AND ISNULL(t1.saved_commodity_form_attribute3, -1) = ISNULL(t2.attribute3, -1)
					AND ISNULL(t1.saved_commodity_form_attribute4, -1) = ISNULL(t2.attribute4, -1)
					AND ISNULL(t1.saved_commodity_form_attribute5, -1) = ISNULL(t2.attribute5, -1)				
				WHERE t1.buy_sell_flag = CASE WHEN @buy_sell = 'b' THEN 's' ELSE 'b' END
					 AND ISNULL(t1.lot, '') = ISNULL(t2.lot, '')
				
				SELECT @pack_uom_val = NULLIF(udddf.udf_value, '')
				FROM source_deal_header sdh
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.source_deal_detail_id = @detail_id
				INNER JOIN user_defined_deal_fields_template uddft
					ON  field_name = -5733	
					AND uddft.template_id = sdh.template_id
				INNER JOIN user_defined_deal_detail_fields udddf 
					ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
					AND udddf.udf_template_id = uddft.udf_template_id

				IF @fixed_price_currency IS NULL
				BEGIN
					SELECT @fixed_price_currency = sc.source_currency_id
					FROM source_currency sc WHERE sc.currency_name = 'USD'
				END
				
				IF @buy_sell = 'b'
				BEGIN					
					SET @location_id = @del_loc_id
					SET @reciept_volume = @volume					
				END
				ELSE 
				BEGIN
					SET @location_id = @rec_loc_id
					SET @delivery_volume = @volume
					
					-- in case of group path, if buyer location is storage
					/*IF @counter = 2
					BEGIN
						SELECT @storage_location = sml.source_minor_location_id
						FROM source_minor_location sml
						INNER JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID
						WHERE sml.source_minor_location_id = @location_id 
						AND smj.location_type = 11130
					END*/
				END

				SET @product_desc = NULL
				SELECT @product_desc = ISNULL(sco.commodity_name, '') + ' ' + ISNULL(sdv_form.code, '') + ' | ' + ISNULL(sdv_origin.code, '') + ' | ' + CASE WHEN @organic = 'y' THEN 'Organic' ELSE '' END + ' ' +ISNULL(sdv_att1.code, '') + ' ' +  ISNULL(sdv_att2.code, '') + ' ' +  ISNULL(sdv_att3.code, '') + ' ' +  ISNULL(sdv_att4.code, '') + ' ' +  ISNULL(sdv_att5.code, '')
				FROM source_commodity sco
				OUTER APPLY (
					SELECT sdv_form.code
					FROM commodity_form cf 
				    LEFT JOIN commodity_type_form ct_form ON ct_form.commodity_type_form_id = cf.form
					LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = ct_form.commodity_form_value AND sdv_form.value_id > 0 
					WHERE cf.commodity_form_id = @form_id
				) sdv_form
				OUTER APPLY (
					SELECT sdv_origin.code
					FROM commodity_origin co 
				    LEFT JOIN static_data_value sdv_origin ON sdv_origin.value_id = co.origin AND sdv_origin.value_id > 0 
					WHERE co.commodity_origin_id = @origin
				) sdv_origin
				OUTER APPLY (
					SELECT sdv_att1.code
					FROM commodity_form_attribute1 cfa1 
				    LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
					LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
					WHERE cfa1.commodity_form_attribute1_id = NULLIF(@attribute1, '')
				) sdv_att1
				OUTER APPLY (
					SELECT sdv_att1.code
					FROM commodity_form_attribute2 cfa1 
				    LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
					LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
					WHERE cfa1.commodity_form_attribute2_id = NULLIF(@attribute2, '')
				) sdv_att2
				OUTER APPLY (
					SELECT sdv_att1.code
					FROM commodity_form_attribute3 cfa1 
				    LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
					LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
					WHERE cfa1.commodity_form_attribute3_id = NULLIF(@attribute3, '')
				) sdv_att3
				OUTER APPLY (
					SELECT sdv_att1.code
					FROM commodity_form_attribute4 cfa1 
				    LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
					LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
					WHERE cfa1.commodity_form_attribute4_id = NULLIF(@attribute4, '')
				) sdv_att4
				OUTER APPLY (
					SELECT sdv_att1.code
					FROM commodity_form_attribute5 cfa1 
				    LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
					LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
					WHERE cfa1.commodity_form_attribute5_id = NULLIF(@attribute5, '')
				) sdv_att5
				WHERE sco.source_commodity_id = @detail_commodity_id

					
				SET @detail_xml += ' term_start="' + CONVERT(VARCHAR(10), @term_start, 120) + '" ' + 
								   ' term_end="' + CONVERT(VARCHAR(10), @term_end, 120) + '" ' +
								   ' blotterleg="' + CONVERT(VARCHAR(10), @leg, 120) + '" ' + 
								   ' buy_sell_flag="' + @buy_sell + '" ' + 
								   ' location_id="' + CAST(@location_id AS VARCHAR(20)) + '" ' + 
								   ' deal_volume="' + CAST(@volume AS VARCHAR(200)) + '" ' + 
								   ' contractual_volume="' + CAST(@volume AS VARCHAR(200)) + '" ' + 
								   ' detail_commodity_id="' + @detail_commodity_id + '" ' + 
								   ' origin="' + @origin + '" ' +
								   ' form="' + @form_id + '" ' +
								   ' organic="' + @organic + '" ' +
								   ' attribute1="' + @attribute1 + '" ' +
								   ' attribute2="' + @attribute2 + '" ' +
								   ' attribute3="' + @attribute3 + '" ' +
								   ' attribute4="' + @attribute4 + '" ' +
								   ' attribute5="' + @attribute5 + '" ' +
								   ' fixed_price_currency_id="' + CAST(@fixed_price_currency AS VARCHAR(20)) + '" ' + 
								   ' position_uom="' + CAST(@convert_uom AS VARCHAR(20)) + '" ' + 
								   ' deal_volume_uom_id="' + CAST(@convert_uom AS VARCHAR(20)) + '" '


				IF @pack_uom_label IS NOT NULL AND @pack_uom_val IS NOT NULL
				BEGIN
					SET @detail_xml += '  ' + @pack_uom_label + '="' + CAST(@pack_uom_val AS VARCHAR(20)) + '" '
				END
				
				--IF @position_uom IS NOT NULL
				--	SET @detail_xml += ' position_uom="' + CAST(@position_uom AS VARCHAR(20)) +'" '

				IF @product_desc IS NOT NULL
					SET @detail_xml += ' product_description="' + @product_desc +'" '

				SET @detail_xml += '></GridRow>'
				
				FETCH NEXT FROM sdd_cursor INTO @template_detail_id, @buy_sell, @leg, @fixed_price_currency
			END
			CLOSE sdd_cursor
			DEALLOCATE sdd_cursor 
			
			SET @counter = @counter + 1
			FETCH NEXT FROM sdh_cursor INTO @id	
		END
		CLOSE sdh_cursor
		DEALLOCATE sdh_cursor 
		
   		SET @header_xml += '</GridXML>'   		
		SET @detail_xml += '</GridXML>'

   		DECLARE @return_output VARCHAR(200)   
   		DECLARE @storage_inj_deal VARCHAR(200)
   		DECLARE @storage_with_deal VARCHAR(200)
   		
		IF OBJECT_ID('tempdb..#temp_inserted_sch_deals') IS NOT NULL
			DROP TABLE #temp_inserted_sch_deals
		CREATE TABLE #temp_inserted_sch_deals (source_deal_header_id INT, [type] CHAR(1))

		IF OBJECT_ID('tempdb..#temp_storage_locations') IS NOT NULL
			DROP TABLE #temp_storage_locations

		CREATE TABLE #temp_storage_locations (location_id INT, order_id INT)

		DECLARE @total_rows INT
		SELECT @total_rows = COUNT(1) FROM #temp_location_ordering

		INSERT INTO #temp_storage_locations
		SELECT location_id, order_id
		FROM #temp_location_ordering 
		WHERE is_storage = 1 AND order_id > 1 AND order_id < @total_rows

   		IF EXISTS(SELECT 1 FROM #temp_storage_locations)
   		BEGIN		
   			DECLARE @header_xml_inj VARCHAR(MAX) = '<GridXML>'
   			DECLARE @header_xml_with VARCHAR(MAX) = '<GridXML>'
   			
   			DECLARE @detail_xml_inj VARCHAR(MAX) = '<GridXML>'
   			DECLARE @detail_xml_with VARCHAR(MAX) = '<GridXML>'

			DECLARE @sto_cnt INT = 1
			DECLARE sdd_storage_cursor CURSOR FORWARD_ONLY READ_ONLY LOCAL
			FOR
				SELECT location_id
				FROM #temp_storage_locations
				ORDER BY order_id
			OPEN sdd_storage_cursor
			FETCH NEXT FROM sdd_storage_cursor INTO @storage_location
			WHILE @@FETCH_STATUS = 0   
			BEGIN
				SET @storage_inj_deal = NULL
				SET @storage_with_deal = NULL
				SET @return_output = NULL

   				DECLARE @storage_inj_template INT
   				DECLARE @storage_with_template INT
   			
   				SELECT @storage_inj_template = clm3_value, @sub_book = clm2_value 
				FROM generic_mapping_header gmh
				INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
				WHERE gmh.mapping_name = 'Scheduling Storage Mapping' AND clm1_value = 'i'
			
				SELECT @scheduler_id = ISNULL(MAX(scheduler), '')
				FROM #temp_tbl_form
				WHERE buy_sell_flag = 's'
   			
   				-- #1 create storage injection deal	
   				SET @header_xml_inj += '<GridRow row_id="' + CAST(@sto_cnt AS VARCHAR(20)) + '"'
				SET @header_xml_inj += ' sub_book="' + CAST(@sub_book AS VARCHAR(20)) + '"' + 
										' deal_date="' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"' + 
										' counterparty_id="' + CAST(@counterparty_id AS VARCHAR(20)) + '"' + 
										' counterparty_id2="' + ISNULL(CAST(@counterparty_id2 AS VARCHAR(20)), '') + '"' + 
										' contract_id="' + ISNULL(CAST(@contract_id AS VARCHAR(20)), '') + '"' +
										' scheduler="' + CAST(@scheduler_id AS VARCHAR(20)) + '"' +
										' trader_id="' + CAST(@trader_id AS VARCHAR(20)) + '"' +
										' rate_schedule="' + ISNULL(CAST(@rate_schedule AS VARCHAR(20)), '') + '"'
			
				SET @header_xml_inj += '></GridRow>'
   			
   				DECLARE @leg_cnt INT = 1
   			
   				DECLARE sdd_inj_cursor CURSOR FORWARD_ONLY READ_ONLY LOCAL
				FOR
					SELECT sddt.template_detail_id, sddt.buy_sell_flag, sddt.leg, sddt.fixed_price_currency_id
					FROM #temp_detail_template_str sddt
					WHERE buy_sell_flag = 's'
					ORDER BY sddt.leg
				OPEN sdd_inj_cursor
				FETCH NEXT FROM sdd_inj_cursor INTO @template_detail_id, @buy_sell, @leg, @fixed_price_currency
				WHILE @@FETCH_STATUS = 0   
				BEGIN				
					SET @detail_xml_inj += '<GridRow row_id="' + CAST(@sto_cnt AS VARCHAR(20)) + '" deal_group="" group_id="1" detail_flag="0" blotterleg="' + CAST(@leg_cnt AS VARCHAR(20)) + '" '
						
					SELECT  @detail_commodity_id  = ISNULL(MAX(t1.source_commodity_id), ''),
							@origin				  = ISNULL(MAX(t1.saved_origin), ''),
							@form_id			  = ISNULL(MAX(t1.saved_form), ''),
							@organic			  = ISNULL(MAX(t1.organic), 'n'),
							@attribute1			  = ISNULL(MAX(t1.saved_commodity_form_attribute1), ''),
							@attribute2			  = ISNULL(MAX(t1.saved_commodity_form_attribute2), ''),
							@attribute3			  = ISNULL(MAX(t1.saved_commodity_form_attribute3), ''),
							@attribute4			  = ISNULL(MAX(t1.saved_commodity_form_attribute4), ''),
							@attribute5			  = ISNULL(MAX(t1.saved_commodity_form_attribute5), ''),
							@term_start			  = ISNULL(@term_start, MIN(t1.scheduled_from)),
							@term_end			  = ISNULL(@term_end, MAX(t1.scheduled_to)),
							@delivery_volume	  = ISNULL(MAX(bookout_split_total_amt), 0),
							@detail_id			  = ISNULL(MAX(t1.source_deal_detail_id), @detail_id)
   					FROM #temp_tbl_form t1
					INNER JOIN (
						SELECT t2.source_commodity_id, t2.origin, t2.form, ISNULL(t2.organic, 'n') organic,
								t2.attribute1, t2.attribute2, t2.attribute3,
								t2.attribute4, t2.attribute5 
						FROM #temp_detail_template_str t2
						WHERE t2.template_detail_id = @template_detail_id
					) t2 ON t1.source_commodity_id =  t2.source_commodity_id 
						AND ISNULL(t1.saved_origin, -1) = ISNULL(t2.origin, -1)
						AND ISNULL(t1.saved_form, -1) = ISNULL(t2.form, -1)
						AND ISNULL(t1.organic, 'n') = ISNULL(t2.organic, 'n')
						AND ISNULL(t1.saved_commodity_form_attribute1, -1) = ISNULL(t2.attribute1, -1)
						AND ISNULL(t1.saved_commodity_form_attribute2, -1) = ISNULL(t2.attribute2, -1)
						AND ISNULL(t1.saved_commodity_form_attribute3, -1) = ISNULL(t2.attribute3, -1)
						AND ISNULL(t1.saved_commodity_form_attribute4, -1) = ISNULL(t2.attribute4, -1)
						AND ISNULL(t1.saved_commodity_form_attribute5, -1) = ISNULL(t2.attribute5, -1)				
					WHERE t1.buy_sell_flag = 's'

					SET @pack_uom_val = NULL
					SELECT @pack_uom_val = NULLIF(udddf.udf_value, '')
					FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.source_deal_detail_id = @detail_id
					INNER JOIN user_defined_deal_fields_template uddft
						ON  field_name = -5733	
						AND uddft.template_id = sdh.template_id
					INNER JOIN user_defined_deal_detail_fields udddf 
						ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
						AND udddf.udf_template_id = uddft.udf_template_id
			
					SELECT @fixed_price_currency = fixed_price_currency_id FROM source_deal_detail_template sddt WHERE sddt.template_id = @storage_inj_template
					IF @fixed_price_currency IS NULL
					BEGIN
						SELECT @fixed_price_currency = sc.source_currency_id
						FROM source_currency sc WHERE sc.currency_name = 'USD'
					END
			
					SET @volume = @delivery_volume

					SET @product_desc = NULL
					SELECT @product_desc = ISNULL(sco.commodity_name, '') + ' ' + ISNULL(sdv_form.code, '') + ' | ' + ISNULL(sdv_origin.code, '') + ' | ' + CASE WHEN @organic = 'y' THEN 'Organic' ELSE '' END + ' ' +ISNULL(sdv_att1.code, '') + ' ' +  ISNULL(sdv_att2.code, '') + ' ' +  ISNULL(sdv_att3.code, '') + ' ' +  ISNULL(sdv_att4.code, '') + ' ' +  ISNULL(sdv_att5.code, '')
					FROM source_commodity sco
					OUTER APPLY (
						SELECT sdv_form.code
						FROM commodity_form cf 
						LEFT JOIN commodity_type_form ct_form ON ct_form.commodity_type_form_id = cf.form
						LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = ct_form.commodity_form_value AND sdv_form.value_id > 0 
						WHERE cf.commodity_form_id = @form_id
					) sdv_form
					OUTER APPLY (
						SELECT sdv_origin.code
						FROM commodity_origin co 
						LEFT JOIN static_data_value sdv_origin ON sdv_origin.value_id = co.origin AND sdv_origin.value_id > 0 
						WHERE co.commodity_origin_id = @origin
					) sdv_origin
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute1 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute1_id = NULLIF(@attribute1, '')
					) sdv_att1
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute2 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute2_id = NULLIF(@attribute2, '')
					) sdv_att2
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute3 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute3_id = NULLIF(@attribute3, '')
					) sdv_att3
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute4 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute4_id = NULLIF(@attribute4, '')
					) sdv_att4
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute5 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute5_id = NULLIF(@attribute5, '')
					) sdv_att5
					WHERE sco.source_commodity_id = @detail_commodity_id
								
					SET @detail_xml_inj += ' term_start="' + CONVERT(VARCHAR(10), @term_start, 120) + '" ' + 
										' term_end="' + CONVERT(VARCHAR(10), @term_end, 120) + '" ' +
										' location_id="' + CAST(@storage_location AS VARCHAR(20)) + '" ' + 
										' deal_volume="' + CAST(@volume AS VARCHAR(200)) + '" ' + 
										' contractual_volume="' + CAST(@volume AS VARCHAR(200)) + '" ' + 
										' detail_commodity_id="' + @detail_commodity_id + '" ' + 
										' origin="' + @origin + '" ' +
										' form="' + @form_id + '" ' +
										' organic="' + @organic + '" ' +
										' attribute1="' + @attribute1 + '" ' +
										' attribute2="' + @attribute2 + '" ' +
										' attribute3="' + @attribute3 + '" ' +
										' attribute4="' + @attribute4 + '" ' +
										' attribute5="' + @attribute5 + '" ' +
										' fixed_price_currency_id="' + CAST(@fixed_price_currency AS VARCHAR(20)) + '" '	
								
					IF @pack_uom_label IS NOT NULL AND @pack_uom_val IS NOT NULL
						SET @detail_xml_inj += '  ' + @pack_uom_label + '="' +  CAST(@pack_uom_val AS VARCHAR(20)) + '" '
				
					
					IF @position_uom IS NOT NULL
						SET @detail_xml_inj += ' position_uom="' + CAST(@position_uom AS VARCHAR(20)) +'" '	
				
					IF @product_desc IS NOT NULL
						SET @detail_xml_inj += ' product_description="' + @product_desc +'" '	
															
					SET @detail_xml_inj += '></GridRow>' 
				
					SET @leg_cnt = @leg_cnt + 1
				 
				FETCH NEXT FROM sdd_inj_cursor INTO @template_detail_id, @buy_sell, @leg, @fixed_price_currency
				END
				CLOSE sdd_inj_cursor
				DEALLOCATE sdd_inj_cursor 
				
   				-- #2 create storage withdrawal deal   			
   				SELECT @storage_with_template = clm3_value, @sub_book = clm2_value  
				FROM generic_mapping_header gmh
				INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
				WHERE gmh.mapping_name = 'Scheduling Storage Mapping' AND clm1_value = 'w'
			
				SELECT @scheduler_id = ISNULL(MAX(scheduler), '')
				FROM #temp_tbl_form
				WHERE buy_sell_flag = 'b'
				
   				SET @header_xml_with += '<GridRow row_id="' + CAST(@sto_cnt AS VARCHAR(20)) + '"'
				SET @header_xml_with += ' sub_book="' + CAST(@sub_book AS VARCHAR(20)) + '"' + 
										' deal_date="' + CONVERT(VARCHAR(10), GETDATE(), 120) + '"' + 
										' counterparty_id="' + CAST(@counterparty_id AS VARCHAR(20)) + '"' + 
										' counterparty_id2="' + ISNULL(CAST(@counterparty_id2 AS VARCHAR(20)), '') + '"' + 
										' contract_id="' + ISNULL(CAST(@contract_id AS VARCHAR(20)), '') + '"' +
										' scheduler="' + CAST(@scheduler_id AS VARCHAR(20)) + '"' +
										' trader_id="' + CAST(@trader_id AS VARCHAR(20)) + '"' + 
										' rate_schedule="' + ISNULL(CAST(@rate_schedule AS VARCHAR(20)), '') + '"'
								   
				SET @header_xml_with += '></GridRow>'   			
   			
   				SET @leg_cnt = 1
   				DECLARE @storage_leg_count INT = 0
   				DECLARE sdd_with_cursor CURSOR FORWARD_ONLY READ_ONLY LOCAL
				FOR
					SELECT sddt.template_detail_id, sddt.buy_sell_flag, sddt.leg, sddt.fixed_price_currency_id
					FROM #temp_detail_template_str sddt
					WHERE buy_sell_flag = 'b'
					ORDER BY sddt.leg
				OPEN sdd_with_cursor
				FETCH NEXT FROM sdd_with_cursor INTO @template_detail_id, @buy_sell, @leg, @fixed_price_currency
				WHILE @@FETCH_STATUS = 0   
				BEGIN	
					SET @storage_leg_count = @storage_leg_count + 1
					SET @detail_xml_with += '<GridRow row_id="' + CAST(@sto_cnt AS VARCHAR(20)) + '" deal_group="" group_id="1" detail_flag="0" blotterleg="' + CAST(@leg_cnt AS VARCHAR(20)) + '" '
				
					SELECT  @detail_commodity_id  = ISNULL(MAX(t1.source_commodity_id), ''),
							@origin				  = ISNULL(MAX(t1.saved_origin), ''),
							@form_id			  = ISNULL(MAX(t1.saved_form), ''),
							@organic			  = ISNULL(MAX(t1.organic), 'n'),
							@attribute1			  = ISNULL(MAX(t1.saved_commodity_form_attribute1), ''),
							@attribute2			  = ISNULL(MAX(t1.saved_commodity_form_attribute2), ''),
							@attribute3			  = ISNULL(MAX(t1.saved_commodity_form_attribute3), ''),
							@attribute4			  = ISNULL(MAX(t1.saved_commodity_form_attribute4), ''),
							@attribute5			  = ISNULL(MAX(t1.saved_commodity_form_attribute5), ''),
							@term_start			  = ISNULL(@term_start, MIN(t1.scheduled_from)),
							@term_end			  = ISNULL(@term_end, MAX(t1.scheduled_to)),
							@delivery_volume	  = ISNULL(MAX(bookout_split_total_amt), 0),
							@detail_id			  = ISNULL(MAX(t1.source_deal_detail_id), @detail_id)
   					FROM #temp_tbl_form t1
					INNER JOIN (
						SELECT t2.source_commodity_id, t2.origin, t2.form, ISNULL(t2.organic, 'n') organic,
								t2.attribute1, t2.attribute2, t2.attribute3,
								t2.attribute4, t2.attribute5 
						FROM #temp_detail_template_str t2
						WHERE t2.template_detail_id = @template_detail_id
					) t2 ON t1.source_commodity_id =  t2.source_commodity_id 
						AND ISNULL(t1.saved_origin, -1) = ISNULL(t2.origin, -1)
						AND ISNULL(t1.saved_form, -1) = ISNULL(t2.form, -1)
						AND ISNULL(t1.organic, 'n') = ISNULL(t2.organic, 'n')
						AND ISNULL(t1.saved_commodity_form_attribute1, -1) = ISNULL(t2.attribute1, -1)
						AND ISNULL(t1.saved_commodity_form_attribute2, -1) = ISNULL(t2.attribute2, -1)
						AND ISNULL(t1.saved_commodity_form_attribute3, -1) = ISNULL(t2.attribute3, -1)
						AND ISNULL(t1.saved_commodity_form_attribute4, -1) = ISNULL(t2.attribute4, -1)
						AND ISNULL(t1.saved_commodity_form_attribute5, -1) = ISNULL(t2.attribute5, -1)				
					WHERE t1.buy_sell_flag = 'b'

					SET @pack_uom_val = NULL
					SELECT @pack_uom_val = NULLIF(udddf.udf_value, '')
					FROM source_deal_header sdh
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.source_deal_detail_id = @detail_id
					INNER JOIN user_defined_deal_fields_template uddft
						ON  field_name = -5733	
						AND uddft.template_id = sdh.template_id
					INNER JOIN user_defined_deal_detail_fields udddf 
						ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
						AND udddf.udf_template_id = uddft.udf_template_id
			
					SELECT @fixed_price_currency = sddt.fixed_price_currency_id FROM source_deal_detail_template sddt WHERE sddt.template_id = @storage_with_template
					IF @fixed_price_currency IS NULL
					BEGIN
						SELECT @fixed_price_currency = sc.source_currency_id
						FROM source_currency sc WHERE sc.currency_name = 'USD'
					END
			
					SET @volume = @delivery_volume

					SET @product_desc = NULL
					SELECT @product_desc = ISNULL(sco.commodity_name, '') + ' ' + ISNULL(sdv_form.code, '') + ' | ' + ISNULL(sdv_origin.code, '') + ' | ' + CASE WHEN @organic = 'y' THEN 'Organic' ELSE '' END + ' ' +ISNULL(sdv_att1.code, '') + ' ' +  ISNULL(sdv_att2.code, '') + ' ' +  ISNULL(sdv_att3.code, '') + ' ' +  ISNULL(sdv_att4.code, '') + ' ' +  ISNULL(sdv_att5.code, '')
					FROM source_commodity sco
					OUTER APPLY (
						SELECT sdv_form.code
						FROM commodity_form cf 
						LEFT JOIN commodity_type_form ct_form ON ct_form.commodity_type_form_id = cf.form
						LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = ct_form.commodity_form_value AND sdv_form.value_id > 0 
						WHERE cf.commodity_form_id = @form_id
					) sdv_form
					OUTER APPLY (
						SELECT sdv_origin.code
						FROM commodity_origin co 
						LEFT JOIN static_data_value sdv_origin ON sdv_origin.value_id = co.origin AND sdv_origin.value_id > 0 
						WHERE co.commodity_origin_id = @origin
					) sdv_origin
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute1 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute1_id = NULLIF(@attribute1, '')
					) sdv_att1
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute2 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute2_id = NULLIF(@attribute2, '')
					) sdv_att2
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute3 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute3_id = NULLIF(@attribute3, '')
					) sdv_att3
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute4 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute4_id = NULLIF(@attribute4, '')
					) sdv_att4
					OUTER APPLY (
						SELECT sdv_att1.code
						FROM commodity_form_attribute5 cfa1 
						LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
						LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
						WHERE cfa1.commodity_form_attribute5_id = NULLIF(@attribute5, '')
					) sdv_att5
					WHERE sco.source_commodity_id = @detail_commodity_id
								
					SET @detail_xml_with += ' term_start="' + CONVERT(VARCHAR(10), @term_start, 120) + '" ' + 
											' term_end="' + CONVERT(VARCHAR(10), @term_end, 120) + '" ' +
											' location_id="' + CAST(@storage_location AS VARCHAR(20)) + '" ' + 
											' deal_volume="' + CAST(@volume AS VARCHAR(200)) + '" ' + 
											' contractual_volume="' + CAST(@volume AS VARCHAR(200)) + '" ' + 
											' detail_commodity_id="' + @detail_commodity_id + '" ' + 
											' origin="' + @origin + '" ' +
											' form="' + @form_id + '" ' +
											' organic="' + @organic + '" ' +
											' attribute1="' + @attribute1 + '" ' +
											' attribute2="' + @attribute2 + '" ' +
											' attribute3="' + @attribute3 + '" ' +
											' attribute4="' + @attribute4 + '" ' +
											' attribute5="' + @attribute5 + '" ' +
											' fixed_price_currency_id="' + CAST(@fixed_price_currency AS VARCHAR(20)) + '" '
										
					IF @pack_uom_label IS NOT NULL AND @pack_uom_val IS NOT NULL
						SET @detail_xml_with += '  ' + @pack_uom_label + '="' +  CAST(@pack_uom_val AS VARCHAR(20)) + '" '
				
					 
					IF @position_uom IS NOT NULL
						SET @detail_xml_with += ' position_uom="' + CAST(@position_uom AS VARCHAR(20)) +'" '

					IF @product_desc IS NOT NULL
						SET @detail_xml_with += ' product_description="' + @product_desc +'" '					
							
					SET @detail_xml_with += '></GridRow>' 					
					
					SET @leg_cnt = @leg_cnt + 1				 
				FETCH NEXT FROM sdd_with_cursor INTO @template_detail_id, @buy_sell, @leg, @fixed_price_currency
				END
				CLOSE sdd_with_cursor
				DEALLOCATE sdd_with_cursor 

				SET @sto_cnt = @sto_cnt + 1
			FETCH NEXT FROM sdd_storage_cursor INTO @storage_location
			END
			CLOSE sdd_storage_cursor
			DEALLOCATE sdd_storage_cursor 				

			SET @header_xml_inj += '</GridXML>'
			SET @header_xml_with += '</GridXML>'
			SET @detail_xml_inj += '</GridXML>'
			SET @detail_xml_with += '</GridXML>'
			
			
			--select @header_xml header_xml, @detail_xml detail_xml, @template_id template_id1, @header_xml_inj  header_xml_inj, @detail_xml_inj detail_xml_inj
			--, @storage_inj_template storage_inj_template, @header_xml_with header_xml_with, @detail_xml_with detail_xml_with, @storage_with_template storage_with_template 

			BEGIN TRY				 
				EXEC [spa_insert_blotter_deal]
					@flag = 'i',
					@header_xml = @header_xml_inj,
					@detail_xml = @detail_xml_inj,
					@template_id = @storage_inj_template,
					@call_from = 'scheduler',
					@return_output = @storage_inj_deal OUTPUT
				
				IF @storage_inj_deal IS NULL RETURN
				ELSE 
				BEGIN
					INSERT INTO #temp_inserted_sch_deals
					SELECT scsv.item, 'i'	
					FROM dbo.SplitCommaSeperatedValues(@storage_inj_deal) scsv						
				END
				
				EXEC [spa_insert_blotter_deal]
					@flag = 'i',
					@header_xml = @header_xml_with,
					@detail_xml = @detail_xml_with,
					@template_id = @storage_with_template,
					@call_from = 'scheduler',
					@return_output = @storage_with_deal OUTPUT
				
				IF @storage_with_deal IS NULL RETURN
				ELSE 
				BEGIN
					INSERT INTO #temp_inserted_sch_deals
					SELECT scsv.item, 'w'	
					FROM dbo.SplitCommaSeperatedValues(@storage_with_deal) scsv				
				END
			END TRY
			BEGIN CATCH 
				IF @@TRANCOUNT > 0
					ROLLBACK 
				SET @desc = 'Fail to create storage deal. ( Errr Description:' + ERROR_MESSAGE() + ').' 
				SELECT @err_no = ERROR_NUMBER()
 
				EXEC spa_ErrorHandler @err_no
					, 'Deal'
					, 'spa_insert_blotter_deal'
					, 'Error'
					, @desc
					, ''
					RETURN
			END CATCH
   		END
		
		BEGIN TRY
			--print 1
			--SELECT @header_xml, @detail_xml, @template_id
			EXEC [spa_insert_blotter_deal]
				@flag = 'i',
				@header_xml = @header_xml,
				@detail_xml = @detail_xml,
				@template_id = @template_id,
				@call_from = 'scheduler',
				@return_output = @return_output OUTPUT
		END TRY
		BEGIN CATCH 
			IF @@TRANCOUNT > 0
			   ROLLBACK 
			SET @desc = 'Fail to create transportation deal. ( Errr Description:' + ERROR_MESSAGE() + ').' 
			SELECT @err_no = ERROR_NUMBER()
 
			EXEC spa_ErrorHandler @err_no
			   , 'Deal'
			   , 'spa_insert_blotter_deal'
			   , 'Error'
			   , @desc
			   , ''
			   RETURN
		END CATCH 

		IF @return_output IS NOT NULL
		BEGIN					
			CREATE TABLE #to_update_commodity(source_commodity_id INT)

			INSERT INTO #temp_inserted_sch_deals(source_deal_header_id, [type])
			SELECT scsv.item, 't'  
			FROM dbo.SplitCommaSeperatedValues(@return_output) scsv

			--update commodity id start
			SET @sql = 'INSERT INTO #to_update_commodity
						SELECT TOP 1 source_commodity_id 
						FROM ' + @match_propertes + '
						WHERE match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) 
			EXEC(@sql) 

			DECLARE @to_update_commodity INT 
			SELECT @to_update_commodity = source_commodity_id FROM #to_update_commodity

			--select * 
			UPDATE sdh
			SET commodity_id = @to_update_commodity
			FROM #temp_inserted_sch_deals ti 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ti.source_deal_header_id

			UPDATE sdd
			SET detail_commodity_id = @to_update_commodity
			FROM #temp_inserted_sch_deals ti 
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = ti.source_deal_header_id
			--update commodity id end

			DECLARE @min_storage_seq INT
			DECLARE @max_storage_seq INT

			SELECT @min_storage_seq = MIN(order_id)
			FROM #temp_storage_locations

			SELECT @max_storage_seq = MAX(order_id)
			FROM #temp_storage_locations

			IF OBJECT_ID('tempdb..#temp_shipping_name') IS NOT NULL
				DROP TABLE #temp_shipping_name
				
			CREATE TABLE #temp_shipping_name (deal_detail_id INT, location_id INT, shipping_name_initial VARCHAR(1000), shipping_name_final VARCHAR(1000))
			/*
			 SELECT sdd.source_deal_detail_id, sdd.location_id,
					    CASE WHEN ISNULL(sdh.internal_deal_type_value_id, -1) = 15 AND t2.order_id = @min_storage_seq THEN 'original'
							WHEN ISNULL(sdh.internal_deal_type_value_id, -1) = 15 AND t2.order_id <> @min_storage_seq THEN CAST(t3.order_id AS VARCHAR(10))
							WHEN ISNULL(sdh.internal_deal_type_value_id, -1) = 16 THEN CAST(t2.order_id AS VARCHAR(10))
							WHEN t2.location_id IS NOT NULL AND t2.order_id = @min_storage_seq AND sdd.buy_sell_flag = 's' THEN CAST(t2.order_id AS VARCHAR(10))
							WHEN t2.location_id IS NOT NULL AND t2.order_id = @min_storage_seq AND sdd.buy_sell_flag = 'b' THEN 'original'
							WHEN t2.location_id IS NOT NULL AND t2.order_id <> @min_storage_seq AND sdd.buy_sell_flag = 's' THEN CAST(t2.order_id AS VARCHAR(10))
							WHEN t2.location_id IS NOT NULL AND t2.order_id <> @min_storage_seq AND sdd.buy_sell_flag = 'b' THEN CAST(t3.order_id AS VARCHAR(10))
							WHEN t2.location_id IS NULL AND sdd.buy_sell_flag = 's' AND leg2.is_stogare IS NULL THEN 'original'
							WHEN t2.location_id IS NULL AND sdd.buy_sell_flag = 'b' AND leg1.is_stogare IS NOT NULL THEN CAST(@max_storage_seq AS VARCHAR(10))
							WHEN t2.location_id IS NULL AND sdd.buy_sell_flag = 'b' AND leg1.is_stogare IS NULL THEN CAST(@max_storage_seq AS VARCHAR(10)) 
							WHEN t2.location_id IS NULL AND sdd.buy_sell_flag = 's' AND leg2.is_stogare IS NULL THEN CAST(@max_storage_seq AS VARCHAR(10))
						END
						, sdh.internal_deal_type_value_id
						, t2.order_id , @min_storage_seq mis_str, t2.location_id t2_loc, leg2.is_stogare leg2_is_stogare, sdd.buy_sell_flag , leg1.is_stogare
				FROM #temp_inserted_sch_deals t1
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t1.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				LEFT JOIN #temp_storage_locations t2 ON sdd.location_id = t2.location_id
				OUTER APPLY (
					SELECT TOP(1) * 
					FROM #temp_storage_locations tt
					WHERE tt.order_id < t2.order_id 
					ORDER BY tt.order_id DESC
				) t3
				OUTER APPLY (
					SELECT 1 [is_stogare]
					FROM source_deal_detail sddi 
					INNER JOIN #temp_storage_locations temp ON temp.location_id = sddi.location_id
					WHERE sddi.source_deal_header_id = sdd.source_deal_header_id AND sddi.leg = 2 
				) leg2
				OUTER APPLY (
					SELECT 1 [is_stogare]
					FROM source_deal_detail sddi 
					INNER JOIN #temp_storage_locations temp ON temp.location_id = sddi.location_id
					WHERE sddi.source_deal_header_id = sdd.source_deal_header_id AND sddi.leg = 1 
				) leg1


				return 

			--	*/
			IF EXISTS(SELECT 1 FROM #temp_storage_locations)
			BEGIN
				INSERT INTO #temp_shipping_name (deal_detail_id, location_id, shipping_name_initial)
				SELECT sdd.source_deal_detail_id, sdd.location_id,
					  CASE WHEN ISNULL(sdh.internal_deal_type_value_id, -1) = 15 AND t2.order_id = @min_storage_seq THEN 'original'
							WHEN ISNULL(sdh.internal_deal_type_value_id, -1) = 15 AND t2.order_id <> @min_storage_seq THEN CAST(t3.order_id AS VARCHAR(10))
							WHEN ISNULL(sdh.internal_deal_type_value_id, -1) = 16 THEN CAST(t2.order_id AS VARCHAR(10))
							WHEN t2.location_id IS NOT NULL AND t2.order_id = @min_storage_seq AND sdd.buy_sell_flag = 's' THEN CAST(t2.order_id AS VARCHAR(10))
							WHEN t2.location_id IS NOT NULL AND t2.order_id = @min_storage_seq AND sdd.buy_sell_flag = 'b' THEN 'original'
							WHEN t2.location_id IS NOT NULL AND t2.order_id <> @min_storage_seq AND sdd.buy_sell_flag = 's' THEN CAST(t2.order_id AS VARCHAR(10))
							WHEN t2.location_id IS NOT NULL AND t2.order_id <> @min_storage_seq AND sdd.buy_sell_flag = 'b' THEN CAST(t3.order_id AS VARCHAR(10))
							WHEN t2.location_id IS NULL AND sdd.buy_sell_flag = 's' AND leg2.is_stogare IS NULL THEN 'original'
							WHEN t2.location_id IS NULL AND sdd.buy_sell_flag = 'b' AND leg1.is_stogare IS NOT NULL THEN CAST(@max_storage_seq AS VARCHAR(10))
							WHEN t2.location_id IS NULL AND sdd.buy_sell_flag = 'b' AND leg1.is_stogare IS NULL THEN CAST(@max_storage_seq AS VARCHAR(10)) 
							WHEN t2.location_id IS NULL AND sdd.buy_sell_flag = 's' AND leg2.is_stogare IS NULL THEN CAST(@max_storage_seq AS VARCHAR(10))
						END
				FROM #temp_inserted_sch_deals t1
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t1.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				LEFT JOIN #temp_storage_locations t2 ON sdd.location_id = t2.location_id
				OUTER APPLY (
					SELECT TOP(1) * 
					FROM #temp_storage_locations tt
					WHERE tt.order_id < t2.order_id 
					ORDER BY tt.order_id DESC
				) t3
				OUTER APPLY (
					SELECT 1 [is_stogare]
					FROM source_deal_detail sddi 
					INNER JOIN #temp_storage_locations temp ON temp.location_id = sddi.location_id
					WHERE sddi.source_deal_header_id = sdd.source_deal_header_id AND sddi.leg = 2 
				) leg2
				OUTER APPLY (
					SELECT 1 [is_stogare]
					FROM source_deal_detail sddi 
					INNER JOIN #temp_storage_locations temp ON temp.location_id = sddi.location_id
					WHERE sddi.source_deal_header_id = sdd.source_deal_header_id AND sddi.leg = 1 
				) leg1
			END
			ELSE
			BEGIN
				INSERT INTO #temp_shipping_name (deal_detail_id, location_id, shipping_name_initial)
				SELECT sdd.source_deal_detail_id, sdd.location_id, 'original'
				FROM #temp_inserted_sch_deals t1
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t1.source_deal_header_id
				INNER JOIN source_Deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			END

			UPDATE #temp_shipping_name
			SET shipping_name_final = shipping_name_initial
			WHERE shipping_name_initial = 'original'

			IF OBJECT_ID('tempdb..#temp_shipping_rank') IS NOT NULL
				DROP TABLE #temp_shipping_rank

			SELECT DENSE_RANK() OVER (ORDER BY shipping_name_initial) [rank], deal_detail_id
			INTO #temp_shipping_rank
			FROM #temp_shipping_name t
			WHERE t.shipping_name_initial <> 'original'

			UPDATE t1
			SET shipping_name_final = t2.[rank]
			FROM #temp_shipping_name t1
			INNER JOIN #temp_shipping_rank t2 ON t1.deal_detail_id = t2.deal_detail_id
			WHERE t1.shipping_name_initial <> 'original'


			--select * from #temp_shipping_name
			--rollback tran
			-- return 

			IF EXISTS(SELECT 1 FROM #temp_inserted_sch_deals) 
			BEGIN
				DECLARE @sql_from VARCHAR(MAX)
				DECLARE @sql_select VARCHAR(MAX)
				SET @sql = '
							INSERT INTO ' + @match_propertes + '(
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
								, deal_id, source_deal_header_id 
								, estimated_movement_date_to
								, frequency
								, multiple_single_deals
								, multiple_single_location
								, source_major_location_ID
								, deal_type
								, form_location_id
								, source_minor_location_id_split
								, location_split
								, sorting_ids
								, base_deal_detail_id
								, inco_terms_id
								, crop_year_id
								, shipment_workflow_status
								, container_number
								, quantity_uom
								, org_uom_id
								, base_id
						)'

						SET @sql_select = '
							SELECT DISTINCT

							ISNULL(temp_tbl.match_group_id, temp_tbl2.match_group_id)
							, ISNULL(temp_tbl.group_name, temp_tbl2.group_name)
							, CASE WHEN tshp.shipping_name_final = ''original'' THEN ISNULL(temp_tbl.match_group_shipment_id, temp_tbl2.match_group_shipment_id) ELSE NULL END
							, CASE WHEN tshp.shipping_name_final = ''original'' THEN ISNULL(temp_tbl.match_group_shipment, temp_tbl2.match_group_shipment) ELSE ISNULL(temp_tbl.match_group_shipment, temp_tbl2.match_group_shipment) + '' - '' + tshp.shipping_name_final END
							, CASE WHEN temp_tbl.match_group_header_id IS NULL AND ISNULL(temp_tbl3.is_group_path, ''y'') = ''n'' THEN temp_tbl2.match_group_header_id ELSE temp_tbl.match_group_header_id END
							, CASE WHEN temp_tbl.match_group_header_id IS NULL AND ISNULL(temp_tbl3.is_group_path, ''y'') = ''n'' THEN temp_tbl2.match_book_auto_id ELSE ISNULL(temp_tbl.match_book_auto_id, ''MTC - [ID] - '' + ISNULL(sml.Location_Name, '''') + ''-'' + LTRIM(RTRIM(ISNULL(sco.commodity_name, '''') + '' '' + ISNULL(sdv_form.code, '''') + '' | '' + ISNULL(sdv_origin.code, '''') + '' | '' + CASE WHEN ISNULL(temp_tbl.organic, temp_tbl2.organic) = ''y'' THEN ''Organic'' ELSE '''' END + '' '' + ISNULL(sdv_att1.code, '''') + '' '' +  ISNULL(sdv_att2.code, '''') + '' '' +  ISNULL(sdv_att3.code, '''') + '' '' +  ISNULL(sdv_att4.code, '''') + '' '' +  ISNULL(sdv_att5.code, '''')))) END
							, ISNULL(temp_tbl.source_commodity_id, sco.source_commodity_id)
							, ISNULL(temp_tbl.commodity, sco.commodity_name)
							, ISNULL(sdd.location_id, temp_tbl.source_minor_location_id)
							, ISNULL(sdd.location_id, temp_tbl.source_minor_location_id)
							, ISNULL(temp_tbl.last_edited_by, dbo.FNADBUser())
							, ISNULL(temp_tbl.last_edited_on, GETDATE())
							, 47006
							, ISNULL(temp_tbl.scheduler, temp_tbl2.scheduler)
							, ISNULL(temp_tbl.container, temp_tbl2.container)
							, ISNULL(temp_tbl.carrier, temp_tbl2.carrier)
							, ISNULL(temp_tbl.consignee, temp_tbl2.consignee)
							, ISNULL(temp_tbl.pipeline_cycle, temp_tbl2.pipeline_cycle)
							, ISNULL(temp_tbl.scheduling_period, temp_tbl2.scheduling_period)
							, ISNULL(temp_tbl.scheduled_to, temp_tbl2.scheduled_to)
							, ISNULL(temp_tbl.scheduled_from, temp_tbl2.scheduled_from)
							, ISNULL(temp_tbl.po_number, temp_tbl2.po_number)
							, ISNULL(temp_tbl.comments, temp_tbl2.comments)
							, ISNULL(temp_tbl.match_number, temp_tbl2.match_number)
							, ISNULL(temp_tbl.lineup, temp_tbl2.lineup)
							, ISNULL(temp_tbl.saved_origin, temp_tbl2.saved_origin)
							, ISNULL(temp_tbl.saved_form, temp_tbl2.saved_form)
							, ISNULL(temp_tbl.organic, temp_tbl2.organic)
							, ISNULL(temp_tbl.saved_commodity_form_attribute1, temp_tbl2.saved_commodity_form_attribute1)
							, ISNULL(temp_tbl.saved_commodity_form_attribute2, temp_tbl2.saved_commodity_form_attribute2)
							, ISNULL(temp_tbl.saved_commodity_form_attribute3, temp_tbl2.saved_commodity_form_attribute3)
							, ISNULL(temp_tbl.saved_commodity_form_attribute4, temp_tbl2.saved_commodity_form_attribute4)
							, ISNULL(temp_tbl.saved_commodity_form_attribute5, temp_tbl2.saved_commodity_form_attribute5)
							, ISNULL(temp_tbl.bookout_match, temp_tbl2.bookout_match)
							, NULL
							, ISNULL(temp_tbl.notes, temp_tbl2.notes)
							, ISNULL(temp_tbl.estimated_movement_date, temp_tbl2.estimated_movement_date)
							, ISNULL(sc.source_counterparty_id, temp_tbl.source_counterparty_id)
							, ISNULL(sc.counterparty_name, temp_tbl.counterparty_name)
							, sdd.source_deal_detail_id
							, sdd.deal_volume bookout_split_total_amt
							, sdd.deal_volume bookout_split_volume
							, sdd.deal_volume min_vol
							, NULL actualized_amt
							, sdd.deal_volume bal_quantity
							, ISNULL(temp_tbl.is_complete, temp_tbl2.is_complete)
							, -1
							, ' + CAST(@shipment_status AS VARCHAR(MAX)) + '
							, ISNULL(temp_tbl.from_location, temp_tbl2.from_location)
							, ISNULL(temp_tbl.to_location, temp_tbl2.to_location)
							, ISNULL(sml.region, sml.source_minor_location_id) region
							, sdd.buy_sell_flag
							, ISNULL(temp_tbl.incoterm, temp_tbl2.incoterm)
							, ISNULL(temp_tbl.crop_year, temp_tbl2.crop_year)
							, ISNULL(temp_tbl.lot, temp_tbl2.lot)
							, ISNULL(temp_tbl.batch_id, temp_tbl2.batch_id)
							, CAST(sdh.source_deal_header_id AS VARCHAR(1000)) + '' [''+ sdh.deal_id +'']''
							, sdh.source_deal_header_id
							, ISNULL(temp_tbl.estimated_movement_date_to, temp_tbl2.estimated_movement_date_to)
							, ISNULL(temp_tbl.frequency, temp_tbl2.frequency)
							, ISNULL(temp_tbl.multiple_single_deals, temp_tbl2.multiple_single_deals)
							, ISNULL(temp_tbl.multiple_single_location, temp_tbl2.multiple_single_location)
							, ISNULL(temp_tbl.source_major_location_ID, sml.source_major_location_ID)
							, sdt.source_deal_type_name
							, ISNULL(temp_tbl.form_location_id, temp_tbl2.form_location_id)
							, ISNULL(sdd.location_id, temp_tbl.source_minor_location_id)
							, ISNULL(sdd.location_id, temp_tbl.source_minor_location_id)
							, ISNULL(temp_tbl.sorting_ids, temp_tbl2.sorting_ids)
							, ISNULL(temp_tbl.base_deal_detail_id, temp_tbl2.base_deal_detail_id)
							, ISNULL(temp_tbl.inco_terms_id, temp_tbl2.inco_terms_id)
							, ISNULL(temp_tbl.crop_year_id, temp_tbl2.crop_year_id)
							, ISNULL(temp_tbl.shipment_workflow_status, temp_tbl2.shipment_workflow_status)
							, ISNULL(temp_tbl.container_number, temp_tbl2.container_number)
							, sdd.position_uom
							, sdd.position_uom
							, ISNULL(temp_tbl.base_id, temp_tbl2.base_id) '
			SET @sql_from = ' FROM source_deal_header sdh						
						INNER JOIN #temp_inserted_sch_deals temp ON temp.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
						INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id							
						INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
						INNER JOIN #temp_shipping_name tshp ON tshp.deal_detail_id = sdd.source_deal_detail_id
						LEFT JOIN source_counterparty sc2 ON sc2.source_counterparty_id = sdh.counterparty_id2	
						LEFT JOIN source_commodity sco ON sco.source_commodity_id = sdd.detail_commodity_id		
						OUTER APPLY (
							SELECT sml.source_minor_location_id, t1.order_id
							FROM source_minor_location sml
							INNER JOIN #temp_storage_locations t1 ON t1.location_id = sml.source_minor_location_id
							WHERE sml.source_minor_location_id = sdd.location_id
						) sto_eq
						OUTER APPLY (SELECT DISTINCT 1 sto_present FROM #temp_storage_locations) sto
						LEFT JOIN (SELECT DISTINCT 
										source_commodity_id, source_minor_location_id, buy_sell_flag, match_group_shipment_id 
										, saved_origin 
										, saved_form 
										, organic 
										, saved_commodity_form_attribute1
										, saved_commodity_form_attribute2
										, saved_commodity_form_attribute3
										, saved_commodity_form_attribute4
										, saved_commodity_form_attribute5
										, match_group_id
										, group_name
										, match_group_shipment
										, po_number
										, match_group_header_id
										, match_book_auto_id
										, commodity
										, last_edited_by
										, last_edited_on
										, scheduler
										, container
										, carrier
										, consignee
										, pipeline_cycle
										, scheduling_period
										, scheduled_to
										, scheduled_from
										, comments
										, match_number
										, lineup
										, bookout_match
										, notes
										, estimated_movement_date
										, source_counterparty_id
										, counterparty_name
										, from_location
										, to_location
										, incoterm
										, crop_year
										, NULL lot
										, batch_id
										, estimated_movement_date_to
										, frequency
										, multiple_single_deals
										, multiple_single_location
										, source_major_location_ID
										, form_location_id
										, source_minor_location_id_split
										, location_split
										, sorting_ids
										, base_deal_detail_id
										, inco_terms_id
										, crop_year_id
										, shipment_workflow_status
										, container_number
										, base_id
										, is_complete
									FROM ' + CAST(@match_propertes AS VARCHAR(MAX)) + ' ) temp_tbl 
							ON temp_tbl.source_commodity_id = sdd.detail_commodity_id
							AND temp_tbl.source_minor_location_id = sdd.location_id
							AND temp_tbl.buy_sell_flag = CASE WHEN sdd.buy_sell_flag = ''s'' THEN ''b'' ELSE ''s'' END
							AND temp_tbl.match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + '
						OUTER APPLY (SELECT TOP(1) * FROM ' + CAST(@match_propertes AS VARCHAR(MAX)) + ' WHERE match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ' AND buy_sell_flag = CASE WHEN sdd.buy_sell_flag = ''s'' THEN ''b'' ELSE ''s'' END) temp_tbl2
						OUTER APPLY (
							SELECT t1.is_group_path, t1.order_id
							FROM source_minor_location sml
							INNER JOIN #temp_location_ordering t1 ON t1.location_id = sml.source_minor_location_id
							INNER JOIN source_major_location smj ON smj.source_major_location_ID = sml.source_major_location_ID
							WHERE sml.source_minor_location_id = sdd.location_id
						) temp_tbl3
						OUTER APPLY (
							SELECT sdv_form.code
							FROM commodity_form cf 
							LEFT JOIN commodity_type_form ct_form ON ct_form.commodity_type_form_id = cf.form
							LEFT JOIN static_data_value sdv_form ON sdv_form.value_id = ct_form.commodity_form_value AND sdv_form.value_id > 0 
							WHERE cf.commodity_form_id = ISNULL(temp_tbl.saved_form, temp_tbl2.saved_form)
						) sdv_form
						OUTER APPLY (
							SELECT sdv_origin.code
							FROM commodity_origin co 
							LEFT JOIN static_data_value sdv_origin ON sdv_origin.value_id = co.origin AND sdv_origin.value_id > 0 
							WHERE co.commodity_origin_id = ISNULL(temp_tbl.saved_origin, temp_tbl2.saved_origin)
						) sdv_origin
						OUTER APPLY (
							SELECT sdv_att1.code
							FROM commodity_form_attribute1 cfa1 
							LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
							LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
							WHERE cfa1.commodity_form_attribute1_id = COALESCE(temp_tbl.saved_commodity_form_attribute1, temp_tbl2.saved_commodity_form_attribute1, -1)
						) sdv_att1
						OUTER APPLY (
							SELECT sdv_att1.code
							FROM commodity_form_attribute2 cfa1 
							LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
							LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
							WHERE cfa1.commodity_form_attribute2_id = COALESCE(temp_tbl.saved_commodity_form_attribute2, temp_tbl2.saved_commodity_form_attribute2, -1)
						) sdv_att2
						OUTER APPLY (
							SELECT sdv_att1.code
							FROM commodity_form_attribute3 cfa1 
							LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
							LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
							WHERE cfa1.commodity_form_attribute3_id = COALESCE(temp_tbl.saved_commodity_form_attribute3, temp_tbl2.saved_commodity_form_attribute3, -1)
						) sdv_att3
						OUTER APPLY (
							SELECT sdv_att1.code
							FROM commodity_form_attribute4 cfa1 
							LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
							LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
							WHERE cfa1.commodity_form_attribute4_id = COALESCE(temp_tbl.saved_commodity_form_attribute4, temp_tbl2.saved_commodity_form_attribute4, -1)
						) sdv_att4
						OUTER APPLY (
							SELECT sdv_att1.code
							FROM commodity_form_attribute5 cfa1 
							LEFT JOIN commodity_attribute_form caf1 on caf1.commodity_attribute_form_id = cfa1.attribute_form_id
							LEFT JOIN static_data_value sdv_att1 ON sdv_att1.value_id = caf1.commodity_attribute_value AND sdv_att1.value_id > 0
							WHERE cfa1.commodity_form_attribute5_id = COALESCE(temp_tbl.saved_commodity_form_attribute5, temp_tbl2.saved_commodity_form_attribute5, -1)
						) sdv_att5


						'
				--PRINT(@sql)
				--PRINT(@sql_select)
				--PRINT(@sql_from)
				EXEC (@sql+@sql_select+@sql_from)			
				--SELECT * INTO ##temp_inserted_sch_deals FROM #temp_inserted_sch_deals
				--SELECT * FROM #temp_shipping_name
				--SELECT location, buy_sell_flag, * FROM adiha_process.dbo.match_propertes_farrms_admin_4515609E_A19D_4F2F_86CB_86CE0173A384 where match_group_shipment_id IS NOT NULL order by match_order_sequence
				--SELECT location,buy_sell_flag, * FROM adiha_process.dbo.match_propertes_farrms_admin_4515609E_A19D_4F2F_86CB_86CE0173A384 where match_group_shipment_id IS NULL order by match_order_sequence
				--EXEC('select * from ' + @match_propertes)


 
				IF EXISTS(SELECT 1 FROM #temp_storage_locations)
				BEGIN
					DECLARE @loc_count INT
					SELECT @loc_count = COUNT(1) FROM #temp_location_ordering

					SET @sql = '
						-- location is final point
						UPDATE t1
						SET match_group_shipment_id = NULL,
							match_group_shipment = temp3.match_group_shipment + '' - '' + CAST(temp2.id AS VARCHAR(20))
						FROM ' + @match_propertes + ' t1
						INNER JOIN #temp_location_ordering t2 ON t1.source_minor_location_id = t2.location_id
						OUTER APPLY (SELECT MAX(shipping_name_final) id FROM #temp_shipping_name WHERE shipping_name_final <> ''original'') temp2
						OUTER APPLY (SELECT TOP(1) match_group_shipment FROM ' + @match_propertes + ' WHERE match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ') temp3
						WHERE t2.order_id > ' + CAST((@loc_count/2)+1 AS VARCHAR(10)) + '
						AND (match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ')

						-- location is initial point
						UPDATE t1
						SET match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ',
							match_group_shipment = temp2.match_group_shipment
						FROM ' + @match_propertes + ' t1
						INNER JOIN #temp_location_ordering t2 ON t1.source_minor_location_id = t2.location_id
						OUTER APPLY (SELECT TOP(1) match_group_shipment FROM ' + @match_propertes + ' WHERE match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ') temp2
						WHERE t2.order_id = 1
						AND (match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ')
					'
					EXEC(@sql)

					-- update sequence for initial location
					SET @sql = '
						UPDATE t1
						SET match_order_sequence = t2.order_id
						FROM ' + @match_propertes + ' t1
						INNER JOIN #temp_location_ordering t2 ON t1.source_minor_location_id = t2.location_id AND t2.order_id < ' + CAST(@min_storage_seq AS VARCHAR(20)) + '
						WHERE (match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ' OR match_group_shipment_id IS NULL)
						'
					EXEC(@sql)

					-- update sequence for storage location - trans deal
					SET @sql = '
						UPDATE t1
						SET match_order_sequence = t2.order_id
						FROM ' + @match_propertes + ' t1
						INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t1.source_deal_header_id
						INNER JOIN #temp_storage_locations t2 ON t2.location_id = t1.source_minor_location_id
						WHERE (match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ' OR match_group_shipment_id IS NULL)
						AND ISNULL(sdh.internal_deal_type_value_id, -1) NOT IN (15,16) AND t1.buy_sell_flag = ''b''

						'
					EXEC(@sql)


					-- update sequence for storage location - storage deals
					SET @sql = '
						UPDATE t1
						SET match_order_sequence = CASE WHEN ISNULL(sdh.internal_deal_type_value_id, -1) = 15 THEN t2.order_id+1 WHEN ISNULL(sdh.internal_deal_type_value_id, -1) = 16 THEN t2.order_id+1 END
						FROM ' + @match_propertes + ' t1
						INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t1.source_deal_header_id
						INNER JOIN #temp_storage_locations t2 ON t2.location_id = t1.source_minor_location_id
						WHERE (match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ' OR match_group_shipment_id IS NULL)
						AND ISNULL(sdh.internal_deal_type_value_id, -1) IN (15,16)
						'
					EXEC(@sql)

					

					-- update sequence for storage location - trans deal
					SET @sql = '
						UPDATE t1
						SET match_order_sequence = t2.order_id+1
						FROM ' + @match_propertes + ' t1
						INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = t1.source_deal_header_id
						INNER JOIN #temp_storage_locations t2 ON t2.location_id = t1.source_minor_location_id
						WHERE (match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ' OR match_group_shipment_id IS NULL)						
						AND ISNULL(sdh.internal_deal_type_value_id, -1) NOT IN (15,16) AND t1.buy_sell_flag = ''s''

						'
					EXEC(@sql)

					-- update sequence for final location
					SET @sql = '
						UPDATE t1
						SET match_order_sequence = t2.order_id + 1
						FROM ' + @match_propertes + ' t1
						INNER JOIN #temp_location_ordering t2 ON t1.source_minor_location_id = t2.location_id AND t2.order_id > ' + CAST(@max_storage_seq AS VARCHAR(20)) + '
						WHERE (match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ' OR match_group_shipment_id IS NULL)
						'
					EXEC(@sql)
				END
				ELSE
				BEGIN
					-- update sequence as per location seq
					SET @sql = '
						UPDATE t1
						SET match_order_sequence = t2.order_id
						FROM ' + @match_propertes + ' t1
						INNER JOIN #temp_location_ordering t2 ON t1.source_minor_location_id = t2.location_id
						WHERE (match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ' OR match_group_shipment_id IS NULL)
						'
					EXEC(@sql)
				END

				-- update shipment status
				SET @sql = '
					UPDATE t1
					SET shipment_status = ' + CAST(@shipment_status AS VARCHAR(20)) + '
					FROM ' + @match_propertes + ' t1
					WHERE match_group_shipment_id = ' + CAST(@shipment_id AS VARCHAR(20)) + ' OR match_group_shipment_id IS NULL
					'
				EXEC(@sql)
			END
			
			--update booking cpty and carrier cpty
			SET @sql = ' UPDATE parent_tbl
						 SET booking_no = chld_tbl.booking_no
							, carrier_counterparty = chld_tbl.carrier_cpty
						 FROM  match_group_shipment parent_tbl
						 INNER JOIN (
							 SELECT MAX(sdh.counterparty_id) booking_cpty, MAX(sdh.counterparty_id2) carrier_cpty, MAX(sdh.deal_id) booking_no, a.match_group_shipment_id
							 FROM ' + @match_propertes + ' a
							 INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = a.source_deal_header_id
							 INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
								AND sdt.source_deal_type_name = ''Transportation''
						GROUP BY a.match_group_shipment_id) chld_tbl ON chld_tbl.match_group_shipment_id = parent_tbl.match_group_shipment_id'
			EXEC spa_print @sql 
			EXEC(@sql)

			--for process table
			SET @sql = ' UPDATE parent_tbl
						 SET booking_no = chld_tbl.booking_no
							, carrier_counterparty = chld_tbl.carrier_cpty
						 FROM  ' + @match_propertes + ' parent_tbl
						 INNER JOIN (
							 SELECT MAX(sdh.counterparty_id) booking_cpty, MAX(sdh.counterparty_id2) carrier_cpty, MAX(sdh.deal_id) booking_no, a.match_group_shipment_id
							 FROM ' + @match_propertes + ' a
							 INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = a.source_deal_header_id
							 INNER JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
								AND sdt.source_deal_type_name = ''Transportation''
						GROUP BY a.match_group_shipment_id) chld_tbl ON chld_tbl.match_group_shipment_id = parent_tbl.match_group_shipment_id'
			EXEC spa_print @sql 
			EXEC(@sql)
		END

		
		--EXEC('select a.source_deal_detail_id,deal_id,	a.buy_sell_flag,
		--	sml.location_id, sdd.leg
		--	,* from ' +  @match_propertes 
		--	+ ' a INNER JOIN source_minor_location sml ON sml.source_minor_location_id= a.source_minor_location_id
		--		INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id = a.source_deal_detail_id') 
		--rollback tran return 


		EXEC spa_ErrorHandler 0
			   , 'Deal'
			   , 'Deal'
			   , 'Success'
			   , 'Changes saved sucessfully.'
			   , ''
   	END
END
ELSE IF @flag = 'x'
BEGIN
	DECLARE @from_loc INT
	DECLARE @to_loc INT
	
	SELECT @from_loc = MAX(source_minor_location_id)
	FROM   #temp_tbl_form
	WHERE buy_sell_flag = 'b'
	
	SELECT @to_loc = MAX(source_minor_location_id)
	FROM   #temp_tbl_form
	WHERE buy_sell_flag = 's'

	
	SELECT @from_loc [from_loc], @to_loc [to_loc]
END

ELSE IF @flag = 'y'
BEGIN
	DECLARE @status CHAR(1) = 'y', @trans_created CHAR(1)

	IF EXISTS(SELECT COUNT(1) FROM #temp_tbl_form HAVING COUNT(1) > 1) -- no need to check volume for agency deals
	BEGIN 
	IF EXISTS(
   		SELECT SUM(bookout_split_volume)
		FROM (
   			SELECT SUM(CASE WHEN buy_sell_flag = 's' THEN -1*bookout_split_volume ELSE bookout_split_volume END)	bookout_split_volume 					
			FROM #temp_tbl_form
			GROUP BY buy_sell_flag
		) a 
   		HAVING SUM(bookout_split_volume) > 1
	)
	BEGIN
		SET @status = 'n'
	END
	END
	SELECT @trans_created = CASE WHEN is_transport_deal_created = 0 THEN 'n' ELSE 'y' END
	FROM match_group_shipment
	WHERE match_group_shipment_id = @shipment_id
	
	SELECT @status [continue_process], @process_id [process_id], @shipment_id [shipment_id], @trans_created [trans_created]
END