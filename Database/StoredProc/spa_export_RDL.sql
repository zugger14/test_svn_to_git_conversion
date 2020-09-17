IF OBJECT_ID(N'[dbo].[spa_export_RDL]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_export_RDL]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: ashrestha@pioneersolutionsglobal.com
-- Create date: 2016-05-17
-- Description: This SP exports Report Sertver Reports to different file format(PDF,XLS) in a folder.
 
-- Params:
-- @report_RDL_name NVARCHAR(500)       - Name of the SSRS Report to export
-- @parameters NVARCHAR(500)		- SSRS Report Parameters
-- @OutputFileFormat NVARCHAR(10)	- File Formta e.g. (Excel, PDF , Word)
-- @output_filename NVARCHAR(200)	- Full path Out put file name 
-- EXEC [spa_export_RDL] 'Confirm Replacement Report Collection','source_deal_header_id:354966','PDF','D:\Applications\TRMTracker\Branches\TRMTracker_Master_Questar\FARRMS\trm\adiha.php.scripts\dev\shared_docs\Deal\report1one.pdf'

-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_export_RDL]
    @report_RDL_name NVARCHAR(1000),
	@parameters NVARCHAR(MAX),
	@OutputFileFormat NVARCHAR(25),
	@output_filename NVARCHAR(1000),
	@process_id nvarchar(1024) = NULL,
	@paramset_hash NVARCHAR(50) = NULL,
	@batch_process_id VARCHAR(100) = '',	
	@batch_report_param VARCHAR(500) = ''
AS
/*---------------------------Debug Section-----------------------------
DECLARE @report_RDL_name NVARCHAR(1000),
		@parameters NVARCHAR(max),
		@OutputFileFormat NVARCHAR(25),
		@output_filename NVARCHAR(1000),
		@process_id nvarchar(1024) = null,
		@batch_process_id VARCHAR(100) = '',	
		@batch_report_param VARCHAR(500) = ''

SELECT @report_RDL_name ='Counterparty Detail Report_Counterparty Detail Report', @parameters ='paramset_id:40363,ITEM_StandardCounterpartyDetailReport_page1_tab_0:39617,report_filter:''account_status_id=10082,active=NULL,counterparty_id=NULL,entity_type_id=NULL,watch_list=NULL,parent_counterparty_id=NULL'',is_refresh:0,report_region:en-US,runtime_user:runaj,global_currency_format:$,global_date_format:M/dd/yyyy,global_thousand_format:,#,global_rounding_format:#0.00,global_science_rounding_format:2,global_negative_mark_format:1,is_html:n', @OutputFileFormat = 'EXCELOPENXML', @output_filename = '\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\BatchReport - Counterparty Detail Report_runaj_2019_06_17_145705.xlsx', @csv_field_delimiter =',', @csv_include_header ='0', @process_id ='D8E92DEE_CC9F_4FEC_A5D2_871E94AC7592_5d07397ea6479',  @xml_format='-100000',@batch_process_id='2B6A5240_B406_40AB_AC56_2AB0B156B1FC_5d073abe9789e',@batch_report_param='spa_export_RDL @report_RDL_name =''Counterparty Detail Report_Counterparty Detail Report'', @parameters =''paramset_id:40363,ITEM_StandardCounterpartyDetailReport_page1_tab_0:39617,report_filter:''''account_status_id=10082,active=NULL,counterparty_id=NULL,entity_type_id=NULL,watch_list=NULL,parent_counterparty_id=NULL'''',is_refresh:0,report_region:en-US,runtime_user:runaj,global_currency_format:$,global_date_format:M/dd/yyyy,global_thousand_format:,#,global_rounding_format:#0.00,global_science_rounding_format:2,global_negative_mark_format:1,is_html:n'', @OutputFileFormat = ''EXCELOPENXML'', @output_filename = ''\\SG-D-WEB01\shared_docs_TRMTracker_Release\temp_Note\BatchReport - Counterparty Detail Report_runaj_2019_06_17_145705.xlsx'', @csv_field_delimiter ='','', @csv_include_header =''0'', @process_id =''D8E92DEE_CC9F_4FEC_A5D2_871E94AC7592_5d07397ea6479'',  @xml_format=''-100000'''
---------------------------------------------------------------------*/
SET NOCOUNT ON
BEGIN
	DECLARE @Server_url NVARCHAR(1000),
			@userName NVARCHAR(100),
			@password NVARCHAR(1000),
			@domain NVARCHAR(200),
			@output  NVARCHAR(MAX),
			@message_header VARCHAR(100)

	SET @message_header = LEFT(@report_RDL_name, CHARINDEX( '_', @report_RDL_name) - 1)

	SELECT @Server_url = report_server_url,
	       @report_RDL_name = CASE WHEN CHARINDEX( 'custom_reports', @report_RDL_name,0) <> 0 THEN report_folder +'/' + @report_RDL_name ELSE  report_folder + '/' + @report_RDL_name END,
	       @userName = report_server_user_name,
	       @password = dbo.[FNADecrypt](report_server_password),
	       @domain = report_server_domain
	FROM connection_string

	SET @process_id = ISNULL(@process_id, REPLACE(NEWID(),'-','_'))
	
	--REBUILD @parameters with run time calculated paramset_id and compoenent_id, so that scheduled job reports would not break
	BEGIN
		DECLARE @run_time_ids VARCHAR(2000)

		SELECT @run_time_ids = 'paramset_id:' + CAST(rp.report_paramset_id AS VARCHAR(20)) + ',' + [dbo].[FNARFXGenerateReportItemsCombined](rp.page_id) + ','
		FROM report_paramset rp
		WHERE rp.paramset_hash = @paramset_hash

		SET @parameters = ISNULL(@run_time_ids, '') + @parameters

	END
	
		
	IF @OutputFileFormat IN ('EXCEL', 'EXCELOPENXML', 'PDF', 'WORD', 'IMAGE')
	BEGIN
		EXEC spa_generate_doc_from_rdl @Server_url, @userName, @password, @domain, @report_RDL_name, @parameters, @OutputFileFormat, @output_filename, @process_id, @output OUTPUT

		IF @output = 'true'
		BEGIN
			SELECT 'Sucess' AS Status, 'Document Saved Successfully' AS Message
		END
		ELSE
		BEGIN 
			SELECT 'Error' AS Status, @output AS Message
		END
	END 
	/*NOTE: CSV,TXT and XML file generation is handled by spa_dump_csv in generic way (for both Std and Report Manager Report)
	which is called in spa_message_board. 
	spa_message_board is called in 2nd step of Report Job creation(spa_rfx_export_report_job).*/	 

END

										
IF ISNULL(@batch_process_id,'')!= '' AND ISNULL(@batch_report_param,'' )!= '' 
BEGIN
	SET @userName = dbo.FNADBUser()

	DECLARE @url_description VARCHAR(5000) = 'Batch process completed for <b>' + @message_header + '</b>.Report has been saved. Please <a target="_blank" href="../../adiha.php.scripts/dev/shared_docs/' + SUBSTRING(@output_filename, CHARINDEX('temp_Note', @output_filename), LEN(@output_filename)) +'"><b>Click Here</a></b> to download.',
			@job_name VARCHAR(500) = 'report_batch_' + @batch_process_id,
			@table_name VARCHAR(200) = 'adiha_process.dbo.batch_report_' + @userName + '_' + @batch_process_id,
			@enable_email CHAR(1),
			@email_description VARCHAR(50)

	SELECT TOP(1) @enable_email = IIF(notification_type IN (750, 752, 754, 756), 'y', 'n')
	FROM batch_process_notifications
	WHERE process_id = RIGHT(@process_id, 13)

	SET @email_description = IIF(@enable_email = 'y', 'Batch process completed for <b>' + @message_header + '</b>.', NULL) 

	EXEC spa_message_board @flag = 'u', @user_login_id = @userName, @source = @message_header, @description = @url_description, @type='s',
						   @job_name = @job_name, @process_id=@batch_process_id, @process_table_name=@table_name, @email_enable=@enable_email, 
						   @email_description = @email_description, @report_sp = @batch_report_param
END
GO