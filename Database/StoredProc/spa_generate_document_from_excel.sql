
IF OBJECT_ID(N'[dbo].[spa_generate_document_from_excel]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_generate_document_from_excel]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_generate_document_from_excel]
	@object_id INT ,
	@template_type INT,
	@template_category INT,
    @export_format VARCHAR(10) = 'PDF',
    @process_id VARCHAR(200) = NULL,
    @show_result BIT = 1
AS
SET NOCOUNT ON	
BEGIN
	DECLARE @user NVARCHAR(200) = dbo.FNADBUser(), @report_filter VARCHAR(MAX), @document_sheet_id INT
	SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
	
	--	Invoice
	IF @template_type IN (38, -38) AND @template_category = 42031
	BEGIN
	
		IF OBJECT_ID('tempdb..#invoice_report_collection_params') IS NOT NULL
			DROP TABLE #invoice_report_collection_params
		
		DECLARE @template_id INT

		IF @template_type > 0
		BEGIN
			CREATE TABLE #invoice_report_collection_params
			(
				as_of_date             VARCHAR(20),
				counterparty_id        INT,
				prod_date              VARCHAR(20),
				contract_id            INT,
				invoice_type           VARCHAR(1) COLLATE DATABASE_DEFAULT,
				netting_group_id       INT,
				report_type            VARCHAR(50) COLLATE DATABASE_DEFAULT,
				statement_type         VARCHAR(10) COLLATE DATABASE_DEFAULT,
				settlement_date        VARCHAR(20),
				template_filename      VARCHAR(200) COLLATE DATABASE_DEFAULT,
				template_name          VARCHAR(200) COLLATE DATABASE_DEFAULT,
				calc_id                INT,
				client_date_format     VARCHAR(20) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #invoice_report_collection_params
			EXEC spa_rfx_invoice_report_collection @invoice_ids  = @object_id, @runtime_user  = @user, @flag = 'a'

			SELECT @template_id = crt.template_id,
				   @report_filter         = '<Parameters><Parameter><Name>as_of_date</Name><Value>' 
				   + ISNULL(as_of_date, '') + '</Value></Parameter>' 
				   + '<Parameter><Name>counterparty_id</Name><Value>' + CAST(counterparty_id AS VARCHAR) + '</Value></Parameter>'
				   + '<Parameter><Name>prod_date</Name><Value>' + prod_date + '</Value></Parameter>'
				   + '<Parameter><Name>contract_id</Name><Value>' + CAST(contract_id AS VARCHAR) + '</Value></Parameter>'
				   + '<Parameter><Name>invoice_type</Name><Value>' + ISNULL(invoice_type, 'i') + '</Value></Parameter>'
				   + '<Parameter><Name>netting_group_id</Name><Value>' + CAST(netting_group_id AS VARCHAR) + '</Value></Parameter>'
				   + '<Parameter><Name>statement_type</Name><Value>' + ISNULL(statement_type, '') + '</Value></Parameter>'
				   + '<Parameter><Name>settlement_date</Name><Value>' + ISNULL(settlement_date, '') + '</Value></Parameter>'
					+ '<Parameter><Name>stmt_invoice_id</Name><Value>' + ISNULL(settlement_date, '') + '</Value></Parameter>'
				   + '<Parameter><Name>calc_id</Name><Value>' + CAST(calc_id AS VARCHAR) + '</Value></Parameter></Parameters>',
				   @document_sheet_id     = crt.excel_sheet_id
			FROM   #invoice_report_collection_params ircp
				   INNER JOIN Contract_report_template AS crt
						ON  ircp.template_name = crt.template_name
			WHERE crt.document_type ='e'
		END
		ELSE
		BEGIN
			CREATE TABLE #invoice_report_collection_params1
			(
				report_type             VARCHAR(200)  COLLATE DATABASE_DEFAULT,
				template_filename       VARCHAR(200)  COLLATE DATABASE_DEFAULT,
				save_invoice_id         INT
			)

			INSERT INTO #invoice_report_collection_params1
			EXEC spa_rfx_invoice_report_collection @invoice_ids  = @object_id, @runtime_user  = @user, @flag = 'b'
			
			SELECT @template_id = crt.template_id,
				   @report_filter         = '<Parameters>' 
				   + '<Parameter><Name>stmt_invoice_id</Name><Value>' + CAST(save_invoice_id AS VARCHAR) + '</Value></Parameter></Parameters>',
				   @document_sheet_id     = crt.excel_sheet_id
			FROM   #invoice_report_collection_params1 ircp
				   INNER JOIN Contract_report_template AS crt
						ON  ircp.template_filename = crt.template_name
			WHERE crt.document_type ='e'
		END
		SET @template_type = ABS(@template_type)

		--SELECT @template_id, @report_filter, @document_sheet_id, @process_id
	END
	-- Trade Ticket
	ELSE IF @template_type = 33	AND @template_category = 42019
	BEGIN
		SET @report_filter = '<Parameters><Parameter><Name>source_deal_header_id</Name><Value>' + CAST(@object_id AS VARCHAR) + '</Value></Parameter></Parameters>'
		
		--	Currently Trade ticket template is default one , Trade ticket based on deal template is not implemented yet.
		SELECT TOP 1 @document_sheet_id = crt.excel_sheet_id
		FROM   Contract_report_template  AS crt
		WHERE  crt.template_category = 42019
		       AND crt.template_type = 33
		       AND crt.document_type = 'e'
		       AND crt.[default] = 1
	END
	-- Deal Confirmation
	ELSE IF @template_type = 33	AND @template_category = 42018 
	BEGIN
		SET @report_filter = '<Parameters><Parameter><Name>source_deal_header_id</Name><Value>' + CAST(@object_id AS VARCHAR) + '</Value></Parameter></Parameters>'
		-- Logic to pick template sheet mapped in confirmation rule
		-- Confirmation rule must be setup with contract template with excel type
		-- Excel type contract temlate must be ascociated with uploded excel sheet.
		
		SELECT TOP(1) @document_sheet_id = crt.excel_sheet_id
		FROM   Contract_report_template crt
		       INNER JOIN deal_confirmation_rule dcr
		            ON  crt.template_id = dcr.confirm_template_id AND crt.document_type = 'e'
		       INNER JOIN source_deal_header sdh
		            ON  sdh.source_deal_header_id = @object_id
		            AND CASE 
		                     WHEN @template_category = 42021 THEN ISNULL(dcr.counterparty_id, sdh.counterparty_id2)
		                     ELSE ISNULL(dcr.counterparty_id, sdh.counterparty_id)
		                END = CASE 
		                           WHEN @template_category = 42021 THEN sdh.counterparty_id2
		                           ELSE sdh.counterparty_id
		                      END
		            AND COALESCE(dcr.deal_type_id, sdh.source_deal_type_id, '') = COALESCE(sdh.source_deal_type_id, '')
		            AND COALESCE(dcr.deal_sub_type, sdh.deal_sub_type_type_id, '') = COALESCE(sdh.deal_sub_type_type_id, '')
		            AND dcr.buy_sell_flag = CASE 
		                                         WHEN dcr.buy_sell_flag = 'a' THEN 
		                                              'a'
		                                         ELSE sdh.header_buy_sell_flag
		                                    END
		            AND COALESCE(dcr.deal_template_id, sdh.template_id, '') = COALESCE(sdh.template_id, '')
		       INNER JOIN source_deal_detail sdd
		            ON  sdh.source_deal_header_id = sdd.source_deal_header_id
		            AND COALESCE(dcr.origin, sdd.origin, '') = COALESCE(sdd.origin, '')
		            AND COALESCE(dcr.commodity_id, sdd.detail_commodity_id, '') = COALESCE(sdd.detail_commodity_id, sdh.commodity_id, '')
		WHERE  template_type = 33
		       AND ISNULL(dcr.deal_confirm, 42018) = @template_category		       
		-- If no match is found according deal confirmation rule check for available default template  (excel type)	       
		SELECT @document_sheet_id = CASE 
		                                 WHEN @document_sheet_id IS NULL THEN 
		                                      crt.excel_sheet_id
		                                 ELSE @document_sheet_id
		                            END
		FROM   Contract_report_template AS crt
		WHERE  crt.document_type = 'e'
		       AND crt.template_category = 42018
		       AND crt.[default] = 1
		       
	END
	
	DECLARE @temp_export_format VARCHAR(10) = @export_format
	
	IF @export_format = 'excel'
		SET @export_format = 'png'
			
	IF (@document_sheet_id IS NOT NULL)
	BEGIN
		EXEC spa_synchronize_excel_reports
			 @excel_sheet_id = @document_sheet_id,
			 @synchronize_report = 'y',
			 @image_snapshot = 'y',
			 @batch_xml_report_param = NULL,
			 @view_report_filter_xml = @report_filter,
			 @process_id = @process_id,
			 @export_format = @export_format,
			 @suppress_result = 'y' 
	END
	
	DECLARE @file_exists INT, @snapshot_filename VARCHAR(1024)

	SELECT @snapshot_filename = ess.snapshot_filename
	FROM   excel_sheet_snapshot AS ess
	WHERE  ess.process_id = @process_id


	SELECT @file_exists = dbo.FNAFileExists(cs.document_path + '\temp_note\' + CASE WHEN @temp_export_format = 'excel' THEN @process_id + '.xlsx' ELSE @snapshot_filename END ) FROM connection_string cs	
	
	-- This was added to suppress result while executing from different sp Eg. spa_generate_document_view. Because nested inserted is not supported.
	IF @show_result =1 
	BEGIN
		IF (@file_exists = 1 AND EXISTS (SELECT ess.snapshot_filename FROM   excel_sheet_snapshot AS ess WHERE  ess.process_id = @process_id))
		BEGIN
			SELECT excel_sheet_snapshot_id [id],
				   snapshot_applied_filter [filter],
				   dbo.FNADateTimeFormat(ess.snapshot_refreshed_on, 0) [created_date],
				   CASE 
						WHEN @temp_export_format = 'EXCEL'
							THEN @process_id + '.xlsx'
						ELSE ess.snapshot_filename
						END AS document_name, 
				   COALESCE(es.[description], NULLIF(es.alias, ''), es.sheet_name)  AS [description],
				   'Success' [status]
			FROM   excel_sheet_snapshot      AS ess
				   INNER JOIN excel_sheet    AS es
						ON  ess.excel_sheet_id = es.excel_sheet_id
			WHERE  ess.process_id = @process_id
		END
		ELSE
		BEGIN
			SELECT '' [id],
				   '' [filter],
				   '' [created_date],
				   '' document_name,
				   CASE WHEN @document_sheet_id IS NULL THEN 'Error: Document sheet not found.' ELSE 'Error: Failed to generate document.' END [description],
				   'Failed' [status]
		END
	END
	
END

