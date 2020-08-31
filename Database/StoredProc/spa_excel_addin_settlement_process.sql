IF OBJECT_ID(N'[dbo].[spa_excel_addin_settlement_process]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_excel_addin_settlement_process]
GO
    
SET ANSI_NULLS ON
GO
    
SET QUOTED_IDENTIFIER ON
GO
   
CREATE PROCEDURE [dbo].[spa_excel_addin_settlement_process](
    @flag                CHAR(1),
    @counterparty_id     VARCHAR(MAX)=NULL,
    @contract_id         VARCHAR(MAX)=NULL,
    @prod_date           DATETIME =NULL,
    @prod_date_to        DATETIME =NULL,
    @as_of_date          DATETIME =NULL,
    @unique_process_id VARCHAR(255) = NULL
)
AS
DECLARE @sql VARCHAR(MAX), @calc_filter NVARCHAR(MAX), @ssis_cmd_parameter NVARCHAR(MAX), @document_path NVARCHAR(1500), @result_output NVARCHAR(MAX), @ssis_system_variables NVARCHAR(1024)
SELECT @document_path = cs.document_path FROM connection_string AS cs

SET @unique_process_id = ISNULL(@unique_process_id, dbo.FNAGetNewID())
IF  @flag = 'c'
BEGIN
	--SET @contract_id = 9234
	IF OBJECT_ID('tempdb..#data_component') IS NOT NULL
		DROP TABLE #data_component
	
	CREATE TABLE #data_component
	(
		[ContractId]       INT,
		[ChargeTypeId]     INT,
		[ChargeTypeName]     VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[Granularity]      INT,
		[DataComponent]      VARCHAR(500) COLLATE DATABASE_DEFAULT,
		[DataSource]       NVARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		[Type]             INT,
		[ParamsetHash]     NVARCHAR(500),
		[FormulaId]        INT,
		[Value] NVARCHAR(255)
	)
	INSERT INTO #data_component
	SELECT cgd.contract_id,
		   cgd.invoice_line_item_id,
	       sdv.code,
	       COALESCE(dcd.granularity, cgd.volume_granularity, 982) 
	       [volume_granularity],
		   dc.[description],
		   dc.data_source,
		   dc.[type],
		   dc.paramset_hash,
		   dc.formula_id,
		   dcd.value
	FROM   contract_group_detail AS cgd
		   INNER JOIN data_component_detail dcd
				ON  cgd.id = dcd.contract_group_detail_id
		   INNER JOIN data_component dc
				ON  dc.data_component_id = dcd.data_component_id
	       INNER JOIN static_data_value  AS sdv
	            ON  cgd.invoice_line_item_id =  sdv.value_id
	WHERE  cgd.contract_id = @contract_id

	SELECT [ContractId],
	       [ChargeTypeId],
	       [ChargeTypeName],
	       [Granularity],
	       [DataComponent],
	       ISNULL(
	           REPLACE(
	       REPLACE(
			   REPLACE(
				   REPLACE(
					   REPLACE(
						   REPLACE(
							   REPLACE(
								   REPLACE(
									   CASE 
	                                                WHEN [Type] = 107300 THEN 
	                                                     REPLACE([DataSource], '@meter_id', [Value])
											ELSE [DataSource]
									   END,
									   '@prod_date_to',
	                                           CONVERT(char(10),  @prod_date_to ,126)
								   ),
								   '@prod_date',
	                                       CONVERT(char(10),  @prod_date ,126)
							   ),
							   '@as_of_date',
	                                   CONVERT(char(10),  @as_of_date ,126)
						   ),
						   '@granularity',
						   [Granularity]
					   ),
					   '@paramset_id',
					   ISNULL(rpt.[ParamsetId], 0)
				   ),
				   '@tablix_id',
				   ISNULL(rpt.[TablixId], 0)
			   ),
	        '@process_id',
	        @unique_process_id
	               ),
	               '@curve_id',
	               ISNULL([Value],'')
	           ),
	           ''
	        )
	       [DataSource],
	       [Type],
	       ISNULL([ParamsetHash], '') [ParamsetHash],
	       ISNULL([FormulaId], 0)     FormulaId,
	       ISNULL([Value], '') [Value],
	       ISNULL(rpt.[ParamsetId], 0) [ParamsetId],
	       ISNULL(rpt.[TablixId], 0) [TablixId]
	FROM   #data_component
	       -- To replace paramset id / tablix id based on report hash
	       OUTER APPLY (
	    SELECT r.report_id AS [Id],
	           MAX(rps.name) [Name],
	           rps.report_paramset_id [ParamsetId],
	           rpt.report_page_tablix_id [TablixId],
	           rps.paramset_hash
	    FROM   report r
	           INNER JOIN report_page rp
	                ON  rp.report_id = r.report_id
	           INNER JOIN report_paramset rps
	                ON  rps.page_id = rp.report_page_id
	           LEFT JOIN report_dataset_paramset rdp
	                ON  rdp.paramset_id = rps.report_paramset_id
	           LEFT JOIN report_param rpm
	                ON  rdp.report_dataset_paramset_id = rpm.dataset_paramset_id
	           LEFT JOIN report_privilege rpv
	                ON  r.report_hash = rpv.report_hash
	           LEFT JOIN report_paramset_privilege rpp
	                ON  rpp.paramset_hash = rps.paramset_hash
	           INNER JOIN report_page_tablix rpt
	                ON  rpt.page_id = rps.page_id
	    WHERE  rp.is_deployed = 1 --Show deployed reports only as they are the ones that can be run.
	           AND rps.paramset_hash = [ParamsetHash]
	    GROUP BY
	           rps.report_paramset_id,
	           rp.report_page_id,
	           r.report_id,
	           rpt.report_page_tablix_id,
	           rps.paramset_hash
	)                                 rpt
END
ELSE IF @flag = 's' -- Summary
BEGIN
	SELECT TOP 1 CASE 
	                  WHEN @counterparty_id IS NULL THEN 'Counterparty'
	                  ELSE sc.counterparty_id
	             END [Counterparty],
	       CASE 
	            WHEN @contract_id IS NULL THEN 'Contract'
	            ELSE ctrct.[Contract]
	       END [Contract],
	       ISNULL(CONVERT(char(10),  @prod_date ,126), dbo.FNAGetContractMonth(GETDATE())) [ProdDate],
	       ISNULL(CONVERT(char(10),  @prod_date_to ,126), CONVERT(char(10), EOMONTH(GETDATE()),126)) [ProdDateTo],
	       ISNULL(CONVERT(char(10),  @as_of_date ,126), CONVERT(char(10), EOMONTH(GETDATE()),126)) [AsOfDate]
	FROM   source_counterparty  AS sc
	       OUTER APPLY(
	    SELECT cg.[contract_name] [Contract]
	    FROM   contract_group AS cg
	    WHERE  cg.contract_id = @contract_id
	)                              ctrct
	WHERE  sc.source_counterparty_id = ISNULL(@counterparty_id, sc.source_counterparty_id)
END
ELSE IF @flag = 'd' -- Download Sample Excel File
BEGIN
	--SELECT 'success' [status] , '8E0A6DCD_C05E_4E54_A8FF_16DE6887D458.xlsx' [template_filename] 
	
	-- Execute SSIS pkg to create excel template with contract line item (data component) sheet.
		SET @calc_filter = '<Settlement><CounterpartyId>' + ISNULL(@counterparty_id, 1) 
		        + '</CounterpartyId><ContractId>' + @contract_id + 
		        '</ContractId><ProdDate>' + dbo.FNAGetContractMonth(GETDATE()) + 
		        '</ProdDate><ProdDateTo>' + CONVERT(char(10), EOMONTH(GETDATE()),126) + 
		        '</ProdDateTo><AsOfDate>' + CONVERT(char(10), EOMONTH(GETDATE()),126) + 
		        '</AsOfDate><ProcessId>' + @unique_process_id + 
		        '</ProcessId><CreateTemplate>y</CreateTemplate></Settlement>'
		SET @ssis_cmd_parameter = 'PS_ViewReportFilterXmlParam=' + @calc_filter + ',PS_ProcessId=' + @unique_process_id + ',PS_SettlementCalc=y'
	
		SET @ssis_system_variables = ' /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + dbo.FNADBUser()+ '"'
		--SELECT @ssis_cmd_parameter
		EXEC spa_execute_ssis_package_using_clr 'PRJ_Excel_Snapshot','ExcelSnapshot',@ssis_cmd_parameter, @ssis_system_variables,'n','n',@result_output OUTPUT
		
		-- Sample file created from ssis package will be placed in temp note after pkg execution is success
		IF (dbo.FNAFileExists(@document_path + '\temp_note\' + @unique_process_id + '.xlsx') = 1)
		BEGIN
			SELECT 'success' [status] , @unique_process_id + '.xlsx' [template_filename] 
END
		ELSE
BEGIN
			SELECT 'error' [status] , @unique_process_id + '.xlsx' [template_filename] 
		END
END
ELSE IF @flag = 'e' -- Collect Temp Deals
BEGIN
	SET @sql = '
	SELECT a.source_deal_header_id [Deal ID],
	       sdh.deal_id [Ref Id],
	       CAST(deal_term_start AS DATE) [Term Start],
	       CAST(deal_term_end AS DATE) [Term End],
	       CAST(a.settlement_date AS DATE) [Settlement Date],
	       leg [Leg],
	       a.physical_financial_flag [Physical Financial],
	       deal_type [Deal Type],
	       buy_sell [Buy Sell],
	       curve_id [Curve],
	       deal_volume [Deal Volume],
	       alloc_volume [Allocation Volume],
	       deal_settlement_volume [Settlement Volume],
	       uom_name [UOM],
	       deal_settlement_price [Settlement Price],
	       deal_settlement_amount [Settlement Amount]
	FROM   adiha_process.dbo.excel_add_in_temp_deal_' + @unique_process_id + ' 
	       a
	       LEFT JOIN source_deal_header  AS sdh
	            ON  a.source_deal_header_id = sdh.source_deal_header_id
	       INNER JOIN contract_group     AS cg
	            ON  a.contract_id = cg.contract_id
	       INNER JOIN source_counterparty AS sc
	            ON  a.counterparty_id = sc.source_counterparty_id
	       LEFT JOIN source_uom          AS su
	            ON  a.uom_id = su.source_uom_id'
	EXEC (@sql)
END
ELSE IF @flag = 'r' -- Run Exel Calc
BEGIN
	DECLARE @contract_calc_template_file VARCHAR(2000), @contract_calc_replica_file VARCHAR(2000)
	
	SELECT TOP 1 @contract_calc_template_file = REPLACE(notes_attachment,'/','\') , @contract_calc_replica_file = @document_path  + '\excel_calculations\' + @unique_process_id + '.xlsx' 
	FROM   application_notes
	WHERE  internal_type_value_id     = 40
		   AND notes_object_id        = @contract_id
		   AND user_category          = -43001
	--SELECT @contract_calc_template_file, @contract_calc_replica_file
	-- Copy Template calc file to share docs excel_calculations folder
	EXEC spa_copy_file @contract_calc_template_file, @contract_calc_replica_file , @result_output
	-- Check if file has been copied to temp note
	IF (dbo.FNAFileExists(@contract_calc_replica_file) = 1)
	BEGIN
		-- Execute SSIS pkg to run calc
		SET @calc_filter = '<Settlement><CounterpartyId>' + @counterparty_id 
		        + '</CounterpartyId><ContractId>' + @contract_id + 
		        '</ContractId><ProdDate>' + CONVERT(char(10),  @prod_date ,126) + 
		        '</ProdDate><ProdDateTo>' + CONVERT(char(10),  @prod_date_to ,126) + 
		        '</ProdDateTo><AsOfDate>' + CONVERT(char(10),  @as_of_date ,126) + 
		        '</AsOfDate><ProcessId>' + @unique_process_id + 
		        '</ProcessId><CreateTemplate>n</CreateTemplate></Settlement>'
		SET @ssis_cmd_parameter = 'PS_ViewReportFilterXmlParam=' + @calc_filter + ',PS_ProcessId=' + @unique_process_id + ',PS_SettlementCalc=y'
		--SELECT @ssis_cmd_parameter
		SET @ssis_system_variables = ' /SET "\Package.Connections[OLE_CONN_MainDB].Properties[UserName]";"' + dbo.FNADBUser()+ '"'
		
		EXEC spa_execute_ssis_package_using_clr 'PRJ_Excel_Snapshot','ExcelSnapshot',@ssis_cmd_parameter, @ssis_system_variables,'n','n',@result_output OUTPUT
		
		--UPDATE civ
		--    SET    civ.calculated_excel_file = @unique_process_id + '.xlsx'
		--    FROM   Calc_invoice_Volume_variance AS civv
		--           INNER JOIN calc_invoice_volume AS civ
		--                ON  civv.calc_id = civ.calc_id
		--    WHERE  civv.prod_date = @prod_date
		--           AND civv.prod_date_to = @prod_date_to
		--           AND civv.as_of_date = @as_of_date
		--           AND civv.counterparty_id = @counterparty_id
		--           AND civv.contract_id = @contract_id
		           
		SELECT @result_output
		
	END
END
ELSE IF @flag = 'f' -- Download Calculated Excel File 
BEGIN
	SELECT 11
END

