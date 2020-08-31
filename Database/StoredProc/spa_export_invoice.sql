IF OBJECT_ID('spa_export_invoice') IS NOT NULL
    DROP PROC [dbo].[spa_export_invoice]

GO
	
CREATE PROC [dbo].[spa_export_invoice]
@calc_id INT,
@report_service_param VARCHAR(MAX),
@invoice_filename VARCHAR(MAX),
@batch_process_id VARCHAR(1024) = NULL

AS
DECLARE @output_file_name VARCHAR(MAX), @document_path VARCHAR(MAX)

SELECT @output_file_name = cs.document_path + '\invoice_docs\' + @invoice_filename, @document_path = cs.document_path FROM connection_string AS cs


SET @batch_process_id = CASE WHEN @batch_process_id IS NULL THEN dbo.FNAGetNewID() ELSE @batch_process_id END 
DECLARE @output INT,  @err_message VARCHAR(MAX)


IF OBJECT_ID('tempdb..#export_status') IS NOT NULL
	DROP TABLE tempdb..#export_status
	
CREATE TABLE #export_status (result varchar(MAX), [result_message] NVARCHAR(MAX))

-- Excel Document generation
-- Check if invoice is defined as excel template
IF EXISTS (
       SELECT es.excel_sheet_id
       FROM   Calc_invoice_Volume_variance AS civv
              INNER JOIN contract_group  AS cg
                   ON  civv.contract_id = cg.contract_id
              INNER JOIN Contract_report_template AS crt
                   ON  cg.invoice_report_template = crt.template_id
              INNER JOIN excel_sheet     AS es
                   ON  crt.excel_sheet_id = es.excel_sheet_id
       WHERE  civv.calc_id = ABS(@calc_id)
   )
BEGIN
    SET @calc_id = ABS(@calc_id)
    DECLARE @process_id VARCHAR(255) = dbo.FNAGetNewID()
    EXEC spa_generate_document_from_excel
         @object_id = @calc_id,
         @template_type = 38,
         @template_category = 42031,
         @export_format = 'PDF',
         @process_id = @process_id,
         @show_result = 0
    
    DECLARE @snapshot_filename     VARCHAR(1024)
    
    
    --	Copy Generated File to temp_note
	DECLARE @source_filename VARCHAR(1000)
	SELECT @source_filename = @document_path + '\temp_note\' + ess.snapshot_filename, @snapshot_filename = ess.snapshot_filename FROM   excel_sheet_snapshot AS ess WHERE  ess.process_id = @process_id
	
	-- Output file may be null if invoice file name is not supplied.
	SET @output_file_name = ISNULL(@output_file_name, @document_path + '\invoice_docs\' + @snapshot_filename)
	
	EXEC spa_copy_file @source_file = @source_filename ,@destination_file = @output_file_name, @result = NULL
	
	IF @source_filename IS NOT NULL AND dbo.FNAFileExists(@output_file_name) = 1
	BEGIN
		SET @output = 1
		INSERT INTO #export_status ([result],[result_message]) VALUES('Success', @output_file_name)
	END
	ELSE
	BEGIN
		SET @output = 0
		SET @err_message = 'Error: Document generation failed from excel template.'
		INSERT INTO #export_status ([result],[result_message])  VALUES('Error', 'Error: Document generation failed from excel template.')
	END			
END
ELSE -- Export rdl
BEGIN
	INSERT INTO #export_status
	EXEC [spa_export_RDL] 'custom_reports/Invoice Report Collection',@report_service_param,'PDF', @output_file_name

	SELECT TOP 1 @output = CASE WHEN result = 'Sucess' THEN 1 ELSE 0 END  FROM #export_status WHERE result = 'Sucess'
	SET @output = ISNULL(@output, 0)

	IF @output = 0 
		SELECT   @err_message = COALESCE(@err_message + '. ', '') + ISNULL(result_message, '')  FROM #export_status 
END


-- For test purpose to generate error
--SET @output = CASE WHEN @calc_id IN (40306,40200) THEN 0 ELSE @output END 
--SET @err_message = CASE WHEN @output =0 THEN 'Custom error message ' + CAST(@calc_id AS VARCHAR) ELSE '' END 

INSERT INTO process_settlement_invoice_log
		(   
			process_id,
			code,
			module,
			counterparty_id,
			prod_date,
			[description],
			nextsteps,
			invoice_id	   
		)
SELECT @batch_process_id,
       CASE 
            WHEN @output = 1 THEN 'Success'
            ELSE                        '<font color="red"><b>Error</b></font>'
       END,
       'Invoice Process',
       civv.counterparty_id,
       civv.prod_date,
       CASE 
            WHEN @output = 1 THEN 'PDF generated for counterparty: ' + sc.counterparty_name + ' and contract: ' + cg.contract_name + ' for the delivery month: ' + dbo.FNAGetContractMonth(civv.prod_date) + ', Filename: ' + @invoice_filename 
            ELSE 'Error occurred when generating PDF for counterparty: ' + sc.counterparty_name + ' and contract: ' + cg.contract_name + ' for the delivery month: ' + dbo.FNAGetContractMonth(civv.prod_date) + ', Filename: ' + @invoice_filename +  CASE WHEN @output = 0 THEN  '<br>' + @err_message ELSE '' END
       END,
       CASE WHEN @output = 0 THEN 'Contact technical support.' ELSE '' END ,
       @calc_id
FROM   Calc_invoice_Volume_variance     civv
INNER JOIN source_counterparty sc ON civv.counterparty_id = sc.source_counterparty_id
INNER JOIN contract_group cg ON civv.contract_id = cg.contract_id
WHERE  civv.calc_id = ABS(@calc_id)	

IF @output = 0
	RAISERROR (@err_message, 16, 1 )	