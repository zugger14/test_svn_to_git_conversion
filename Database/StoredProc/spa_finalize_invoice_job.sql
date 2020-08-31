IF OBJECT_ID('spa_finalize_invoice_job') IS NOT NULL
    DROP PROC [dbo].[spa_finalize_invoice_job]

GO
	
CREATE PROC [dbo].[spa_finalize_invoice_job]
@flag CHAR(1),
@xml TEXT,
@reporting_param VARCHAR(MAX),
@report_file_path VARCHAR(2000) = NULL,
@report_folder VARCHAR(2000)
AS
SET NOCOUNT ON; 
DECLARE @batch_process_id VARCHAR(1024),@spa VARCHAR(MAX), @idoc INT, @sql VARCHAR(MAX), @msg VARCHAR(MAX)
SET @batch_process_id = dbo.FNAGetNewID()

IF OBJECT_ID('tempdb..#prevent_alert') IS NOT NULL
	DROP TABLE #prevent_alert

CREATE TABLE #prevent_alert(errorcode VARCHAR(50), [message] VARCHAR(1000))

EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
IF OBJECT_ID('tempdb..#temp_finalize_unfinalize_invoices') IS NOT NULL
	DROP TABLE #temp_finalize_unfinalize_invoices

 --Execute a SELECT statement that uses the OPENXML rowset provider.
SELECT calc_id [calc_id],
		finalized_date finalized_date
INTO #temp_finalize_unfinalize_invoices
FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
WITH (
	calc_id VARCHAR(10),
	finalized_date DATETIME
)
		
INSERT INTO #temp_finalize_unfinalize_invoices
SELECT 
	civv.calc_id,tfui.finalized_date
FROM 
	#temp_finalize_unfinalize_invoices tfui
	INNER JOIN Calc_invoice_Volume_variance civv ON tfui.calc_id = civv.netting_calc_id

DECLARE @alert_process_table VARCHAR(300)
DECLARE @process_id VARCHAR(1024) = dbo.FNAGetNewID()			
SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id + '_ai'

EXEC('CREATE TABLE ' + @alert_process_table + ' (
		calc_id				INT NOT NULL,
		counterparty_id		INT,
		contract_id			INT,
		as_of_date			DATETIME,
		invoice_date		DATETIME,
		flag				CHAR(1),
		errorcode			VARCHAR(100),
		message				VARCHAR(4000)
		)')
				
SET @sql = 'INSERT INTO ' + @alert_process_table + '(calc_id, counterparty_id, contract_id, as_of_date, invoice_date, flag, errorcode, message) 
			SELECT civv.calc_id, civv.counterparty_id, civv.contract_id, civv.as_of_date, civv.settlement_date, ''f'', '''', ''''
			FROM calc_invoice_volume_variance civv 
			INNER JOIN #temp_finalize_unfinalize_invoices tmp ON tmp.calc_id = civv.calc_id'
		
EXEC(@sql)
		
IF @flag = 'f'
BEGIN
	-- Trigger Workflow for Event "Invoice - Pre Update" Start
	EXEC spa_register_event 20605, 20525, @alert_process_table, 0, @process_id
		
	SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @alert_process_table + ' WHERE errorcode = ''error'')
				BEGIN
					INSERT INTO #prevent_alert(errorcode,message)
					SELECT errorcode,message FROM ' +@alert_process_table + '
				END'
	EXEC(@sql)

	IF EXISTS(SELECT 1 FROM #prevent_alert WHERE errorcode = 'error')
	BEGIN
		SELECT @msg = [message] FROM #prevent_alert WHERE errorcode = 'error'
		EXEC spa_ErrorHandler -1,
				'Settlement History',
				'spa_settlement_history',
				'DB Error',
				@msg,
				''
				RETURN
	END
	ELSE
	BEGIN
		SET @spa = 'spa_settlement_history @flag=''' + @flag + ''', @xml=''' +  CAST(@xml AS VARCHAR(MAX)) + ''', @reporting_param=''' + @reporting_param +''', @report_file_path=''' + @report_file_path + ''', @report_folder=''' + @report_folder +''', @batch_process_id=''' + @batch_process_id + ''''

			DECLARE @job_name VARCHAR(1024) = DB_NAME() + '_finalize_invoice_job_' + @batch_process_id
			DECLARE @user_name VARCHAR(512) = dbo.FNADBUser()

			DECLARE @model_name VARCHAR(100),@desc VARCHAR(500),@url VARCHAR(5000)

			SET @model_name = 'Invoice Process'
			SET @msg = 'Process to create invoice PDFs has been started.'

			--SET @msg = 'Settlements finalization process has been started.'
			EXEC spa_message_board 'i',@user_name,NULL,@model_name,@msg,'','','',@job_name,NULL,@batch_process_id
 
			EXEC spa_run_sp_as_job @job_name, @spa, @model_name, @user_name, 'TSQL'

			EXEC spa_ErrorHandler
				@error = 0,
				@msgType1 = 'Settlement History',
				@msgType2 = 'spa_finalize_invoice_job',
				@msgType3 = 'Success',
				@msg = 'Process to create invoice PDFs has been started. Check message board for details.',
				@recommendation = 'Check message board for details.',
				@logFlag = null	    		
	END
END