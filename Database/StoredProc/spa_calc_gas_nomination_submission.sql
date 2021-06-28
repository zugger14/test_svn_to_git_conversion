IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_gas_nomination_submission]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_gas_nomination_submission]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
Calculate - Gas Nomination Submission Process
@as_of_date: As of Date
*/

CREATE PROC [dbo].[spa_calc_gas_nomination_submission]
@as_of_date VARCHAR(10) = NULL
AS

DECLARE  @process_id VARCHAR(100) = REPLACE(NEWID(),'-','_')
DECLARE @batch_unique_id VARCHAR(50) = SUBSTRING(REPLACE(NEWID(),'-',''), 1, 13), @error_role_id INT, @success_role_id INT

DECLARE  @report_path VARCHAR(300), @report_file_full_path VARCHAR(300) -- '\\EU-D-SQL01\shared_docs_TRMTracker_Enercity\temp_Note\' 
SELECT @report_path = document_path + '\temp_Note\' FROM connection_string

DECLARE @report_param VARCHAR(MAX), @_desc VARCHAR(MAX), @_as_of_date VARCHAR(10), @term_start VARCHAR(10), @term_end VARCHAR(10), @common_param VARCHAR(2000)
DECLARE @export_web_service_id INT
SELECT @export_web_service_id = id FROM export_web_service where ws_name = 'Timeseries Decimal Segments'

DECLARE @current_datetime DATETIME = GETDATE()
SET @as_of_date = ISNULL(@as_of_date, CONVERT(VARCHAR(10), @current_datetime, 120))

SET @common_param = 
'sub_id=6!7!8!9,stra_id=12!13!14!15!16!17!18!19,book_id=23!24!25!26!27!28!29!30!31!32!33!34!35!36!37!38!39!40,
sub_book_id=6!7!8!9!10!11!12!13!14!15!16!17!18!19!20!21!22!23!24!25!26!27!28!29,commodity_id=-1,convert_timezone_id=14,
counterparty_ids=NULL,deal_id=NULL,location_ids=NULL,source_deal_header_ids=NULL,external_id1=NULL'

--'sub_id=121,stra_id=126!127,book_id=136!137!138!139!140!141!142!143!144, sub_book_id=84!85!86!87!88!89!90!91!92!93!94,
-- commodity_id=-1,convert_timezone_id=14,counterparty_ids=NULL,deal_id=NULL,location_ids=NULL,source_deal_header_ids=NULL,external_id1=NULL'

SELECT @success_role_id = role_id from application_security_role WHERE role_name = 'Nomination Submission Notification-Success'
SELECT @error_role_id = role_id from application_security_role WHERE role_name = 'Nomination Submission Notification-Error'

DECLARE	@paramset_id INT, @component_id INT
SELECT  @paramset_id =  rp.report_paramset_id FROM report r
						INNER JOIN report_page rpage ON r.report_id = rpage.report_id
						INNER JOIN report_paramset rp ON rpage.report_page_id = rp.page_id
						WHERE r.name = 'Nomination Report Enercity'

SELECT @component_id = report_page_tablix_id from report_page_tablix where name = 'Nomination Report Enercity_tablix'

IF(CAST(CAST(@current_datetime AS TIME) AS VARCHAR(5)) = '02:45' OR CAST(CAST(@current_datetime AS TIME) AS VARCHAR(5)) = '03:45')
BEGIN
	SET @report_file_full_path = @report_path + 'Enercity Nomination Report_2_farrms_admin.xlsx'
	SET @_as_of_date = CONVERT(VARCHAR(10), DATEADD(DAY, -1, @as_of_date), 120)
	SET @term_start = @_as_of_date
	SET @term_end = @_as_of_date

	SET @report_param = 'report_filter:''''as_of_date=' + @_as_of_date + ', ' + @common_param + ', term_start=' + @term_start + ',term_end=' + @term_end + ' '''',is_refresh:0,report_region:en-US,runtime_user:farrms_admin,global_currency_format:$,global_date_format:dd.M.yyyy,global_thousand_format:,#,global_rounding_format:#0.0000,global_price_rounding_format:#0.0000,global_volume_rounding_format:#0.00,global_amount_rounding_format:#0.00,global_science_rounding_format:2,global_negative_mark_format:1,global_number_format_region:de-DE,is_html:n'

	SET @_desc = 'EXEC spa_rfx_export_report_job @report_param = ''' + REPLACE(@report_param, '''', '''''') + '''
	, @proc_desc = ''BatchReport'', @user_login_id = ''farrms_admin'', @report_RDL_name = ''Nomination Report Enercity2_Nomination Report Enercity2'' 
	, @report_file_name = ''Nomination Report Enercity_2_farrms_admin.xlsx''
	, @report_file_full_path = ''' + @report_file_full_path + '''
	, @output_file_format = ''EXCELOPENXML'', @paramset_hash = ''84DA7562_09A8_4C52_98B4_377D362D44DF'''
 
	EXEC batch_report_process @_desc, 'i', '', '', '', '', '', '', '', '', '', '', '', '', '', 'r', 0, '', '', @success_role_id, '751', 'n', @batch_unique_id, NULL, '', '', '', '', @report_path, '', '', 'n', ',', '0', '-100000', '.xlsx', '', @export_web_service_id, '', ''

	SET @report_param =  @common_param + ', as_of_date=' + @_as_of_date + ', term_start=' + @term_start + ',term_end=' + @term_end
	EXEC spa_rfx_run_sql @paramset_id, @component_id, @report_param, NULL,'t','farrms_admin', 'y' , 0 , NULL, @process_id

	SET @_desc = ' 
	IF NOT EXISTS(SELECT 1 FROM adiha_process.dbo.batch_report_farrms_admin_' + @process_id + ')
	BEGIN
		EXEC spa_NotificationUserByRole 4, ''' + @process_id + ''', ''Gas Nomination Submission'', ''Gas Nomination Submission Process is completed with errors for as of date ' + @_as_of_date + ' '' , ''e'', NULL, 1, 0, ' + CAST(@error_role_id AS VARCHAR) + '
	END
	'
	EXEC(@_desc)

END

SET @process_id = REPLACE(NEWID(),'-','_')
SET @batch_unique_id = SUBSTRING(REPLACE(NEWID(),'-',''), 1, 13)
SET @_as_of_date = CONVERT(VARCHAR(10), @as_of_date, 120)
SET @term_start = @_as_of_date
SET @term_end = @_as_of_date
SET @report_file_full_path = @report_path + 'Enercity Nomination Report_farrms_admin.xlsx'

SET @report_param = 'report_filter:''''as_of_date=' + @_as_of_date + ', ' + @common_param + ', term_start=' + @term_start + ',term_end=' + @term_end + ' '''',is_refresh:0,report_region:en-US,runtime_user:farrms_admin,global_currency_format:$,global_date_format:dd.M.yyyy,global_thousand_format:,#,global_rounding_format:#0.0000,global_price_rounding_format:#0.0000,global_volume_rounding_format:#0.00,global_amount_rounding_format:#0.00,global_science_rounding_format:2,global_negative_mark_format:1,global_number_format_region:de-DE,is_html:n'

SET @_desc = 'EXEC spa_rfx_export_report_job @report_param = ''' + REPLACE(@report_param, '''', '''''') + '''
, @proc_desc = ''BatchReport'', @user_login_id = ''farrms_admin'', @report_RDL_name = ''Nomination Report Enercity_Nomination Report Enercity'' 
, @report_file_name = ''Nomination Report Enercity_farrms_admin.xlsx''
, @report_file_full_path = ''' + @report_file_full_path + '''
, @output_file_format = ''EXCELOPENXML'', @paramset_hash = ''84DA7562_09A8_4C52_98B4_377D362D44DF'''

EXEC batch_report_process @_desc, 'i', '', '', '', '', '', '', '', '', '', '', '', '', '', 'r', 0, '', '', @success_role_id, '751', 'n', @batch_unique_id, NULL, '', '', '', '', @report_path, '', '', 'n', ',', '0', '-100000', '.xlsx', '', @export_web_service_id, '', ''

EXEC spa_NotificationUserByRole 4, @process_id, 'Gas Nomination Submission', 'Gas Nomination Submission Process is completed.' , 's', NULL, 1, 0, @success_role_id

--EXEC spa_message_board 'u', 'farrms_admin', NULL, 'Calculation', @_desc, '', '', 'e', NULL, NULL, @process_id, '', '', '', 'n'

SET @report_param =  @common_param + ', as_of_date=' + @_as_of_date + ', term_start=' + @term_start + ',term_end=' + @term_end
 
EXEC spa_rfx_run_sql @paramset_id, @component_id, @report_param, NULL,'t','farrms_admin', 'y' , 0 , NULL, @process_id

SET @_desc = ' 
IF NOT EXISTS(SELECT 1 FROM adiha_process.dbo.batch_report_farrms_admin_' + @process_id + ')
BEGIN
	EXEC spa_NotificationUserByRole 4, ''' + @process_id + ''', ''Gas Nomination Submission'', ''Gas Nomination Submission Process is completed with errors for as of date ' + @_as_of_date + ' '' , ''e'', NULL, 1, 0, ' + CAST(@error_role_id AS VARCHAR) + '
END
'

EXEC(@_desc)

