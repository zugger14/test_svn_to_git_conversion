/****** Object:  StoredProcedure [dbo].[spa_get_settlement_sap_export]    Script Date: 07/06/2011 10:50:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_settlement_sap_export]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_settlement_sap_export]
GO

/****** Object:  StoredProcedure [dbo].[spa_get_settlement_sap_export]    Script Date: 07/06/2011 09:25:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================
-- Create date: 2011-07-06 04:47PM
-- Description:	Settlement SAP Export Generate and Maintain Log
-- Params:
-- @flag - 's' select the export for SAP, 'p' Post to SAP, 'l' create log
-- @term_start - settlement start term for filter
-- @term_end - settlement End term for filter
-- @counterparty_id - settlement counterparty for filter
-- @commodity_id - settlement Commodity for filter
-- @location_id - settlement Location for filter
-- @deal_id - settlement Deal ID for filter
-- @buysell_option - settlement Buy/Sell for filter
-- @physical_financial_option - settlement Physical/Financial for filter
-- @batch_process_id - Process ID ro run batch Job

-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_get_settlement_sap_export]
	@flag CHAR(1) = 's', -- 's' select counterparty, 'p' post settlement to SAP,'r' - run the SAP Export job
	@as_of_date VARCHAR(20) = NULL,
	@term_start VARCHAR(20) = NULL,
	@term_end VARCHAR(20) = NULL,
	@counterparty_id INT = NULL,
	@commodity_id INT = NULL,
	@location_id INT = NULL,
	@contract_id INT =NULL,
	@deal_id INT = NULL,
	@buysell_option CHAR(1) = 'a', -- 'a' All
	@physical_financial_option CHAR(1)='b',
	@header_status_id INT = NULL,
	@process_id VARCHAR(100) = NULL,
	@correlation_id VARCHAR(500) = NULL,
	@message_status VARCHAR(100) = NULL,
	@message VARCHAR(1000) = NULL,
	@detail_status_id INT = NULL,
	@user_login_id VARCHAR(50) = NULL,
	@export_row_id VARCHAR(5000) = NULL,
	@order_type CHAR(1) = 's',
	@batch_process_id	varchar(50) = NULL,
	@batch_report_param	varchar(5000) = NULL
AS
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	DECLARE @sql_main VARCHAR(MAX)
	DECLARE @header_id INT
	DECLARE @root VARCHAR(500)
	DECLARE @ssis_path  VARCHAR(500)
	DECLARE @proc_desc VARCHAR(100)
	DECLARE @job_name VARCHAR(200)
	DECLARE @round_value CHAR(2)
	DECLARE @sap_export_table VARCHAR(100)
	DECLARE @process_id_ini VARCHAR(100)
	--set @order_type='i'
	SET @round_value = 2
	
	IF @user_login_id IS NULL
		SET @user_login_id = dbo.FNAdbuser()

	IF @flag='s' AND @process_id IS NULL
	BEGIN
			SET @process_id_ini = REPLACE(NEWID(), '-', '_')
			SET @sap_export_table=dbo.FNAProcessTableName('sap_export', @user_login_id, @process_id_ini)
			
	END
	ELSE IF @flag='p'
	BEGIN
			SET @sap_export_table=dbo.FNAProcessTableName('sap_export', @user_login_id, @process_id)
			
	END		
			
	IF @flag = 's' OR @flag = 'p'
	BEGIN
		
		IF @flag = 's' AND @process_id IS NULL
		BEGIN
			SET @sql_main = 'CREATE TABLE '+@sap_export_table+'(row_id INT IDENTITY(1,1),GridID VARCHAR(20),source_counterparty_id INT,CounterpartyID VARCHAR(100),OrderType VARCHAR(20),MaterialID VARCHAR(20),Volume NUMERIC(38,18),[Settlement Value] NUMERIC(38,18),ProfitCenterID VARCHAR(20),DeliveryPeriod VARCHAR(8),UOM VARCHAR(20),report_type INT, process_id VARCHAR(100),ContractPurchaseOrder VARCHAR(35),ContractItemNumber VARCHAR(6),DeliveryPricingDate VARCHAR(8),BillingDate VARCHAR(8),ServiceRenderedDate VARCHAR(8),AccountingRemarks VARCHAR(70),ItemCategory VARCHAR(4))' 		
			EXEC(@sql_main)
		END
		
		SET @sql_main = ' 
			SELECT
					sc.source_counterparty_id,
					CASE WHEN ISNULL(sml.Location_Name,spcd.curve_name) LIKE ''%Wholesale NL%'' THEN 8380
						 WHEN ISNULL(sml.Location_Name,spcd.curve_name) LIKE ''%APX%'' THEN 8381
						 WHEN ISNULL(sml.Location_Name,spcd.curve_name) LIKE ''%Wholesale BE%'' THEN 8382
						 WHEN ISNULL(sml.Location_Name,spcd.curve_name) LIKE ''%BELPEX%'' THEN 8383
						 WHEN ISNULL(sml.Location_Name,spcd.curve_name) LIKE ''%TTF%'' THEN 8384
						 WHEN ISNULL(sml.Location_Name,spcd.curve_name) LIKE ''%ZBR%'' THEN 8385
						 WHEN ISNULL(sml.Location_Name,spcd.curve_name) LIKE ''%LSFO%'' THEN 8386
						 WHEN ISNULL(sml.Location_Name,spcd.curve_name) LIKE ''%Gasoil%'' THEN 8387						 
					END AS GridID,				
					sc.customer_duns_number as CounterpartyID,
					CASE WHEN sdd.physical_financial_flag=''p'' AND sdd.buy_sell_flag=''b'' THEN ''Purchase'+CASE WHEN @order_type='i' THEN 'IC' ELSE '' END+'Order'' 
						 WHEN sdd.physical_financial_flag=''p'' AND sdd.buy_sell_flag=''s'' THEN ''Sales'+CASE WHEN @order_type='i' THEN 'IC' ELSE '' END+'Order'' 
						 ELSE ''Sales'+CASE WHEN @order_type='i' THEN 'IC' ELSE '' END+'Order''
						END AS OrderType,
					CASE WHEN ph3.entity_name LIKE ''%Power%'' AND sdh.source_deal_type_id = 2 THEN 1816 -- power physical 
						 WHEN ph3.entity_name LIKE ''%Power%'' AND sdh.source_deal_type_id = 8 THEN 1817 -- power Swap 
						 WHEN ph3.entity_name LIKE ''%Gas%'' AND sdh.source_deal_type_id = 2 THEN 1818 -- Gas Physical
						 WHEN ph3.entity_name LIKE ''%Gas%'' AND sdh.source_deal_type_id = 8 THEN 1822 -- Gas Physical
					END AS MaterialID,
					SUM(ROUND(sds.volume,' + @round_value + ')) Volume,
					SUM(ROUND(CASE WHEN sdd.physical_financial_flag=''p'' THEN abs(sds.settlement_amount) ELSE sds.settlement_amount END,'+@round_value+')) price,
					CASE WHEN ph3.entity_name LIKE ''%Gas%'' THEN 802818 WHEN ph3.entity_name LIKE ''%Power%'' THEN 802819 END AS ProfitCenterID,
					CAST(YEAR(sds.term_start) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(sds.term_start) AS VARCHAR),2) AS DeliveryPeriod,
					CASE WHEN MAX(su.uom_name) LIKE ''%m3%'' THEN ''Nm3'' WHEN MAX(su.uom_name) LIKE ''%MT%'' THEN ''Mt'' ELSE MAX(su.uom_name) END [UOM],
					1 AS report_type,
					CAST(YEAR(sds.term_start) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(sds.term_start) AS VARCHAR),2) AS DeliveryPricingDate,
					CAST(YEAR(sds.term_start) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(sds.term_start) AS VARCHAR),2) AS BillingDate,
					MAX(CAST(YEAR(sds.term_start) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(sds.term_start) AS VARCHAR),2)+ RIGHT(''00''+CAST(dbo.FNALastDayInMonth(sds.term_start) AS VARCHAR),2)) ServiceRenderedDate,
					MAX(ph3.entity_name +'' ''+ CAST(YEAR(sds.term_start) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(sds.term_start) AS VARCHAR),2)) AS AccountingRemarks,
					CASE WHEN sdd.buy_sell_flag=''s'' THEN ''ZICA'' ELSE ''ZICE'' END AS ItemCategory,
					'''' AS ContractPurchaseOrder,
					MAX(CAST(cg.contract_id as VARCHAR)) AS ContractItemNumber								
				FROM
					(SELECT MAX(as_of_date) as_of_date, source_deal_header_id,term_start,leg FROM source_deal_settlement WHERE term_start BETWEEN '''+@term_start+''' 	AND '''+@term_end+''' GROUP BY source_deal_header_id,term_start,leg) sds1
					INNER JOIN source_deal_settlement sds ON sds.source_deal_header_id= sds1.source_deal_header_id
						AND sds.term_start= sds1.term_start
						AND sds.leg= sds1.leg
						AND sds.as_of_date= sds1.as_of_date
					INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sds.source_deal_header_id
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id=sdh.counterparty_id
					LEFT JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id
						AND sds.term_start=sdd.term_start
						AND sds.term_end=sdd.term_end
						AND sdd.leg=1
					LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id	
					LEFT JOIN static_data_value sdv ON sdv.value_id=sml.grid_value_id
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
					LEFT JOIN source_uom su ON su.source_uom_id=sds.volume_uom
					LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1=sdh.source_system_book_id1
						AND ssbm.source_system_book_id2=sdh.source_system_book_id2
						AND ssbm.source_system_book_id3=sdh.source_system_book_id3
						AND ssbm.source_system_book_id4=sdh.source_system_book_id4
					LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id=ssbm.fas_book_id AND ph1.hierarchy_level=0
					LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id=ph1.parent_entity_id AND ph2.hierarchy_level=1
					LEFT JOIN portfolio_hierarchy ph3 ON ph3.entity_id=ph2.parent_entity_id AND ph3.hierarchy_level=2
					LEFT JOIN sap_trm_mapping stm1 ON stm1.map_type=''grid'' AND stm1.invoice_line_item_id IS NULL
						 AND ((stm1.location_id=sdd.location_id AND stm1.location_id IS NOT NULL) OR (stm1.curve_id=sdd.curve_id AND stm1.location_id IS NULL)) 
					LEFT JOIN sap_trm_mapping stm2 ON stm2.map_type=''material'' AND stm2.invoice_line_item_id IS NULL
						 AND stm2.deal_type_id =sdh.source_deal_type_id AND stm2.entity_id =ph3.entity_id
					LEFT JOIN sap_trm_mapping stm3 ON stm3.map_type=''profitcenter'' AND stm3.invoice_line_item_id IS NULL
						 AND stm3.entity_id =ph3.entity_id		
					LEFT JOIN contract_group cg ON cg.contract_id=sdh.contract_id						 		 
				WHERE 1=1
					AND sds.term_start BETWEEN '''+@term_start+''' 	AND '''+@term_end+''''
				+CASE WHEN @counterparty_id IS NOT NULL THEN ' AND sdh.counterparty_id=	'+CAST(@counterparty_id AS VARCHAR) ELSE '' END
				+CASE WHEN @commodity_id IS NOT NULL THEN ' AND spcd.commodity_id=	'+CAST(@commodity_id AS VARCHAR) ELSE '' END
				+CASE WHEN @deal_id IS NOT NULL THEN ' AND sdh.source_deal_header_id=	'+CAST(@deal_id AS VARCHAR) ELSE '' END
				+CASE WHEN @contract_id IS NOT NULL THEN ' AND sdh.contract_id=	'+CAST(@contract_id AS VARCHAR) ELSE '' END			
				+CASE WHEN @location_id IS NOT NULL THEN ' AND sdd.location_id=	'+CAST(@location_id AS VARCHAR) ELSE '' END			
				+CASE WHEN @buysell_option <>'a' THEN ' AND sdd.buy_sell_flag='''+@buysell_option+'''' ELSE '' END
				+CASE WHEN @physical_financial_option <>'b' THEN ' AND sdd.physical_financial_flag='''+@physical_financial_option+'''' ELSE '' END
				+' GROUP BY 
					sc.source_counterparty_id,sc.counterparty_name,ISNULL(sml.Location_Name,spcd.curve_name),sc.customer_duns_number,
					spcd.commodity_id,sdh.source_deal_type_id,CAST(YEAR(sds.term_start) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(sds.term_start) AS VARCHAR),2)
					,sdd.physical_financial_flag,sdd.buy_sell_flag,ph3.entity_name '
		
		SET @sql_main = @sql_main + ' UNION 		
			SELECT
				sc.source_counterparty_id,
				stm2.type_id AS GridID,
				sc.customer_duns_number as CounterpartyID,
				''Sales'+CASE WHEN @order_type='i' THEN 'IC' ELSE '' END+'Order'' AS OrderType,
				stm3.type_id AS MaterialID,
				SUM(ROUND(civ.volume,' + @round_value + ')) Volume,
				SUM(ROUND(civ.Value,'+@round_value+')) price,
				stm1.type_id AS ProfitCenterID,
				CAST(YEAR(civv.prod_date) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(civv.prod_date) AS VARCHAR),2) AS DeliveryPeriod,
				CASE WHEN MAX(su.uom_name) LIKE ''%m3%'' THEN ''Nm3'' WHEN MAX(su.uom_name) LIKE ''%MT%'' THEN ''Mt'' ELSE MAX(su.uom_name) END [UOM],
				2 AS report_type,
				CAST(YEAR(civv.prod_date) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(civv.prod_date) AS VARCHAR),2) AS DeliveryPricingDate,
				CAST(YEAR(civv.prod_date) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(civv.prod_date) AS VARCHAR),2) AS BillingDate,
				MAX(CAST(YEAR(civv.prod_date) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(civv.prod_date) AS VARCHAR),2)+ RIGHT(''00''+CAST(dbo.FNALastDayInMonth(civv.prod_date) AS VARCHAR),2)) ServiceRenderedDate,	
				MAX(ph.entity_name +'' ''+ CAST(YEAR(civv.prod_date) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(civv.prod_date) AS VARCHAR),2)) AS AccountingRemarks,
				''ZICA'' AS ItemCategory,
				'''' AS ContractPurchaseOrder,
				MAX(CAST(cg.contract_id as VARCHAR)) AS ContractItemNumber																	
			FROM
				(SELECT MAX(as_of_date) as_of_date,counterparty_id,contract_id,prod_date FROM calc_invoice_volume_variance WHERE prod_date BETWEEN '''+@term_start+''' 	AND '''+@term_end+''' GROUP BY counterparty_id,contract_id,prod_date) civv1
				INNER JOIN calc_invoice_volume_variance civv 
					ON civv.counterparty_id = civv1.counterparty_id
					AND civv.contract_id = civv1.contract_id
					AND civv.prod_date = civv1.prod_date
					AND civv.as_of_date = civv1.as_of_date
				INNER JOIN calc_invoice_volume civ
					ON civv.calc_id=civ.calc_id
				LEFT JOIN sap_trm_mapping stm1 ON civv.counterparty_id = stm1.counterparty_id
						   AND stm1.invoice_line_item_id = civ.invoice_line_item_id AND stm1.map_type=''profitcenter'' 
				LEFT JOIN sap_trm_mapping stm2 ON civv.counterparty_id = stm2.counterparty_id AND stm1.invoice_line_item_id IS NOT NULL
						   AND stm2.invoice_line_item_id = civ.invoice_line_item_id AND stm2.map_type=''grid''
				LEFT JOIN sap_trm_mapping stm3 ON civv.counterparty_id = stm3.counterparty_id AND stm1.invoice_line_item_id IS NOT NULL
						   AND stm3.invoice_line_item_id = civ.invoice_line_item_id AND stm3.map_type=''material''		   		   
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id AND stm1.invoice_line_item_id IS NOT NULL
				LEFT JOIN source_uom su ON su.source_uom_id=civv.uom
				LEFT JOIN contract_group cg On cg.contract_id=civv.contract_id
				LEFT JOIN portfolio_hierarchy ph ON ph.entity_id=cg.sub_id
			WHERE
				civv.prod_date BETWEEN '''+@term_start+''' 	AND '''+@term_end+''''
			+CASE WHEN @counterparty_id IS NOT NULL THEN ' AND civv.counterparty_id=	'+CAST(@counterparty_id AS VARCHAR) ELSE '' END			
			+CASE WHEN @contract_id IS NOT NULL THEN ' AND civv.contract_id=	'+CAST(@contract_id AS VARCHAR) ELSE '' END			
			+' GROUP BY 
					stm2.type_id,stm3.type_id,stm1.type_id,sc.source_counterparty_id,sc.customer_duns_number,CAST(YEAR(civv.prod_date) AS VARCHAR)+RIGHT(''00''+CAST(MONTH(civv.prod_date) AS VARCHAR),2)'


		IF @flag = 's' AND @process_id IS NULL
		BEGIN
			SET @sql='
				INSERT INTO '+@sap_export_table+'(GridID ,source_counterparty_id,CounterpartyID,MaterialID,ProfitCenterID,DeliveryPeriod,OrderType,[Settlement Value],Volume,UOM,
						ContractPurchaseOrder,ContractItemNumber,DeliveryPricingDate,BillingDate,ServiceRenderedDate,AccountingRemarks,ItemCategory,process_id)		
				SELECT
					GridID,
					source_counterparty_id,
					CounterpartyID,
					MaterialID,
					ProfitCenterID,
					DeliveryPeriod,
					OrderType,
					ROUND(SUM(a.price),'+@round_value+') [Settlement Value],
					ROUND(ABS(SUM(a.Volume)),'+@round_value+') Volume,
					a.[UOM],
					MAX(a.ContractPurchaseOrder),MAX(a.ContractItemNumber),MAX(a.DeliveryPricingDate),MAX(a.BillingDate),
						 MAX(a.ServiceRenderedDate),MAX(a.AccountingRemarks),MAX(a.ItemCategory),'''+@process_id_ini+''' AS process_id					
				FROM ('+@sql_main+') a					
					LEFT JOIN trm_sap_status_log_detail d ON ISNULL(a.GridID,-1)=ISNULL(d.grid_id,-1)
						AND ISNULL(a.source_counterparty_id,-1)=ISNULL(d.Counterparty_id,-1)
						AND ISNULL(a.MaterialID,-1)=ISNULL(d.material_id,-1)
						AND ISNULL(a.ProfitCenterID,-1)=ISNULL(d.profitcenter_id,-1)
						AND ISNULL(a.DeliveryPeriod,-1)=ISNULL(d.delivery_period,-1)
						AND ISNULL(a.OrderType,-1)=ISNULL(d.order_type,-1)
				WHERE 1=1
					AND ISNULL(d.status,'''') <> ''Success''
				GROUP BY GridID,CounterpartyID,OrderType,MaterialID,ProfitCenterID,DeliveryPeriod,a.[UOM],report_type,source_counterparty_id

				SELECT 
					row_id [Row ID],
					GridID [Grid ID],
					CounterpartyID [Counterparty ID],
					' + CASE WHEN @order_type='i' THEN 'ContractPurchaseOrder,ContractItemNumber,' ELSE '' END +'
					MaterialID [Material ID],
					ProfitCenterID [Profit Center ID],
					DeliveryPeriod [Delivery Period],
					'+ CASE WHEN @order_type='i' THEN 'DeliveryPricingDate,BillingDate,ServiceRenderedDate,AccountingRemarks,ItemCategory,' ELSE '' END +'
					OrderType [Order Type],
					ROUND([Settlement Value],'+@round_value+') [Settlement Value],
					ROUND(Volume,'+@round_value+') Volume,
					UOM,
					process_id [Process ID]
				FROM '+@sap_export_table+' ORDER BY GridID,CounterpartyID,DeliveryPeriod,OrderType'
				EXEC(@sql)		

		END
		IF @flag = 's' AND @process_id IS NOT NULL -- select from process table
		BEGIN
			SET @sql='
				SELECT
					ld.grid_id GridID,
					ld.counterparty CounterpartyID,
					ld.material_id MaterialID,
					ld.profitcenter_id ProfitCenterID,
					ld.delivery_period DeliveryPeriod,
					ld.order_type OrderType,
					CAST(ld.price AS NUMERIC(38,2))  Price,
					CAST(ld.volume AS NUMERIC(38,2)) Volume,
					ld.[UOM],
					ld.detail_status_id,
					ContractPurchaseOrder,ContractItemNumber,DeliveryPricingDate,BillingDate,ServiceRenderedDate,AccountingRemarks,ItemCategory
				
				FROM	
					trm_sap_status_log_detail ld
					INNER JOIN trm_sap_status_log_header  lh ON ld.header_status_id=lh.header_status_id
				WHERE
					process_id = '''+@process_id+''''	
			
			EXEC(@sql)			
		END
		ELSE IF @flag = 'p'
		BEGIN
			DECLARE @Params NVARCHAR(500);
			SET @Params = N'@header_id INT OUTPUT';
						
			IF @process_id IS NULL
				SET @process_id=dbo.FNAGetNewID()
			-- Insert into log header
			SELECT @batch_process_id
			SET @sql= '
				INSERT INTO trm_sap_status_log_header(process_id,as_of_date,message_sent_timestamp)
				SELECT '''+@batch_process_id+''',
					'''+@as_of_date+''',
					GETDATE()
					
				SET @header_id = SCOPE_IDENTITY() '

			--EXEC(@sql)
			EXECUTE sp_executesql @sql, @Params, @header_id = @header_id OUTPUT;
					
			SET @sql= '
				INSERT INTO trm_sap_status_log_detail(header_status_id,grid_id,counterparty_id,counterparty,material_id,profitcenter_id,delivery_period,order_type,price,volume,uom,ContractPurchaseOrder,ContractItemNumber,DeliveryPricingDate,BillingDate,ServiceRenderedDate,AccountingRemarks,ItemCategory)
				SELECT 
					'+CAST(@header_id AS VARCHAR)+',
					GridID,
					source_counterparty_id,
					CounterpartyID,
					MaterialID,
					ProfitCenterID,
					DeliveryPeriod,
					OrderType,
					([Settlement Value]) Price,
					ABS((Volume)) Volume,
					[UOM],
					ContractPurchaseOrder,ContractItemNumber,DeliveryPricingDate,BillingDate,ServiceRenderedDate,AccountingRemarks,ItemCategory
				FROM '+@sap_export_table+' a
				WHERE
					gridID is NOT NULL
					AND ProfitCenterID IS NOT NULl
					AND [UOM] IS NOT NULL
					'+CASE WHEN @export_row_id IS NOT NULL THEN ' AND row_id IN('+@export_row_id+')' ELSE '' END					
				
					
			EXEC(@sql)			
			
			-- Execute SSIS PACKAGE

				SELECT @root = import_path FROM connection_string 
				SET @ssis_path = @root +'\TRMSAPExport\'+ 'TRMSAPExport.dtsx'
				--SET @sql = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET \Package.Variables[User::PS_ProcessID].Properties[Value];"' + @batch_process_id + '" /SET \Package.Variables[User::PS_ImportUserName].Properties[Value];"' + @user_login_id+ '"' 
				SET @sql = N'/FILE "' + @ssis_path + '" /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /REPORTING E /SET "\Package.Variables[User::PS_ProcessID].Properties[Value]";"' + @batch_process_id + '" /SET "\Package.Variables[User::PS_OrderType].Properties[Value]";"' + @order_type + '" /SET "\Package.Variables[User::PS_UserName].Properties[Value]";"' + @user_login_id + '" /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + @user_login_id+ '"'
				
				SET @proc_desc = 'TRM_SAP_Export'
				SET @job_name = @proc_desc + '_' + @batch_process_id

				EXEC dbo.spa_run_sp_as_job @job_name, @sql, 'TRM_SAP_Export', @user_login_id, 'SSIS', 2, 'y'
		END
	END	
	ELSE IF @flag = 'l'
	BEGIN
		
		
		
		SET @sql = ' UPDATE lh
				SET
					[correlation_id]='''+@correlation_id+''',
					[message_received_timestamp]=GETDATE(),
					[status]='''+@message_status+''',
					[message]='''+@message+'''
				FROM
					[trm_sap_status_log_header] lh
				WHERE
					process_id='''+@process_id+''''
		
		EXEC(@sql)
							
		IF @detail_status_id IS NOT NULL	
			SET @sql = ' UPDATE ld
				SET
					[status]='''+@message_status+''',
					[message]='''+@message+'''
				FROM
					[trm_sap_status_log_detail] ld
					INNER JOIN [trm_sap_status_log_header] lh ON ld.header_status_id=lh.header_status_id
				WHERE
					lh.process_id='''+@process_id+'''
					AND ld.detail_status_id='''+CAST(@detail_status_id AS VARCHAR)+''''
							
		EXEC(@sql)		
	END	
	
	ELSE IF @flag = 'h'
	BEGIN		
		SET @sql = '
			SELECT
				header_status_id as [Header Status ID],
				dbo.FNADateformat(as_of_date) [As of Date],
				[correlation_id] [Correlation ID],
				[status] [Status],
				[message_sent_timestamp] [Message Sent On],
				[message_received_timestamp] [Message Received On],
				[message] Message
				FROM
					[trm_sap_status_log_header] lh
				WHERE 1=1 '
					+CASE WHEN @as_of_date IS NOT NULL THEN ' AND lh.as_of_date = '''+CAST(@as_of_date AS VARCHAR)+'''' ELSE '' END
				
		EXEC(@sql)		
	END	
	ELSE IF @flag = 'd'
	BEGIN		
		SET @sql = '
				SELECT
					ld.grid_id [Grid ID],
					ld.counterparty [Counterparty ID],
					ld.material_id [Material ID],
					ld.profitcenter_id [Profit Center ID],
					ld.delivery_period [Delivery Period],
					ld.order_type [Order Type],
					CAST(ld.price AS NUMERIC(38,2))  [Settlement Value],
					CAST(ld.volume AS NUMERIC(38,2)) Volume,
					ld.[UOM],
					ld.status Status,
					ld.[message] Message
				FROM
					[trm_sap_status_log_detail] ld
					INNER JOIN [trm_sap_status_log_header] lh ON ld.header_status_id=lh.header_status_id
				WHERE 1=1 '
					+CASE WHEN @process_id IS NOT NULL THEN ' AND lh.process_id = '''+@process_id+'''' ELSE '' END
					+CASE WHEN @header_status_id IS NOT NULL THEN ' AND ld.header_status_id = '+CAST(@header_status_id AS VARCHAR) ELSE '' END
				
		EXEC(@sql)		
	END	
	ELSE IF @flag = 'm' -- publish message in message board
	BEGIN
		
		DECLARE @url VARCHAR(500),@desc VARCHAR(500)
		SET @job_name = 'batch_SAP Export'+ '_' + @process_id
		
		SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + 
			'&spa=exec spa_get_settlement_sap_export ''d'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, ''' + @process_id + ''''
		
		SET @desc = '<a target="_blank" href="' + @url + '">' + 
					'SAP Export completed successfully on: ' + CONVERT(VARCHAR(10),getdate(),120) + 
					' Please click here for detail.'  +
					'.</a>'



		EXEC  spa_message_board 'u', @user_login_id, NULL, 'SAP Export',  @desc, '', '', 's', @job_name,NULL,@process_id

		
	
	END
	
	ELSE IF @flag = 't'
		BEGIN
			SELECT * FROM report_writer_column
		END
	
END	
	
