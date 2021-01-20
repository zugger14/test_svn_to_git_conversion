IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_auto_balancing_nomination_submission]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_auto_balancing_nomination_submission]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
Calculate - Auto Balancing and Power Nomination export
@as_of_date: As of Date
@term_start: Term Start
@term_end: Term End
*/

CREATE PROC[dbo].[spa_calc_auto_balancing_nomination_submission] 
@as_of_date VARCHAR(10) = NULL,
@term_start VARCHAR(10) = NULL,
@term_end VARCHAR(10) = NULL
AS

--set statistics io on
--set statistics time on
DECLARE @current_datetime DATETIME = GETDATE()

SET @as_of_date = ISNULL(@as_of_date, CONVERT(VARCHAR(10), @current_datetime, 120))
SET @term_start = ISNULL(@term_start, @as_of_date)
SET @term_end = ISNULL(@term_end, CASE WHEN CAST(@current_datetime AS TIME) >= '23:38' THEN CONVERT(VARCHAR(10), DATEADD(DAY, 1, @current_datetime), 120) ELSE @as_of_date END)

DECLARE @_location_ids VARCHAR(1000), @_balance_location_id INT, @_desc VARCHAR(MAX), @process_id VARCHAR(100) = REPLACE(NEWID(),'-','_')

DECLARE @batch_unique_id VARCHAR(50) = SUBSTRING(REPLACE(NEWID(),'-',''), 1, 13), @role_id INT

DECLARE  @report_path VARCHAR(300), @report_file_full_path VARCHAR(300) -- '\\EU-D-SQL01\shared_docs_TRMTracker_Enercity\temp_Note\' 
SELECT @report_path = document_path + '\temp_Note\' FROM connection_string
SET @report_file_full_path = @report_path + 'Enercity Nomination Report_farrms_admin.xlsx'

SELECT @_location_ids = STUFF((SELECT ',' + CAST(source_minor_location_id AS VARCHAR(10))
FROM source_minor_location where location_name IN ('Tennet', 'Amprion', 'Transnet', '50Hertz')
FOR XML PATH('')) ,1,1,'')
SELECT @_balance_location_id = source_minor_location_id FROM source_minor_location WHERE location_name = 'Tennet'

DECLARE  @sub VARCHAR(MAX) = ''
SELECT @sub = STUFF((SELECT DISTINCT ',' +  CAST(entity_id AS VARCHAR(20)) 
					 FROM portfolio_hierarchy
					 WHERE [entity_name] IN ('Market Access & Speculative Trading','Market Services','Risk Management & Hedging')
					  AND entity_type_value_id = 525
				FOR XML PATH('')), 1, 1, '') 

IF OBJECT_ID('tempdb..#tmp_result') IS NOT NULL
	DROP TABLE #tmp_result
 
CREATE TABLE #tmp_result (
	 ErrorCode VARCHAR(200) COLLATE DATABASE_DEFAULT
	,Module VARCHAR(200) COLLATE DATABASE_DEFAULT
	,Area VARCHAR(200) COLLATE DATABASE_DEFAULT
	,STATUS VARCHAR(200) COLLATE DATABASE_DEFAULT
	,Message VARCHAR(1000) COLLATE DATABASE_DEFAULT
	,Recommendation VARCHAR(200) COLLATE DATABASE_DEFAULT
)

--INSERT INTO #tmp_result (ErrorCode, Module, Area, Status, Message, Recommendation)   
  EXEC spa_calc_power_balance  -- insert exec causes error due to nested so insertion in #tmp_result is used in sp itself
	  'b'
	, @as_of_date
	, @sub
	, NULL
	, NULL
	, NULL
	, NULL
	, @_location_ids
	, @term_start
	, @term_end
	, NULL
	, NULL
	, NULL
	, 'RAMPS' 
	, NULL
	, '123'
	, 'p'
	, NULL
	, @_balance_location_id
	, 1185
	, NULL
    ,NULL
	,@process_id

IF EXISTS(SELECT 1 FROM #tmp_result WHERE [Status] = 'Error')
BEGIN
	SELECT @role_id = role_id from application_security_role WHERE role_name = 'Nomination Submission Notification-Error'

	SELECT top 1 @_desc = [message] FROM #tmp_result WHERE [Status] = 'Error'
	SET @_desc = 'Error in auto balancing calculation: ' + ISNULL(@_desc, '')

 	--EXEC spa_message_board 'u', 'farrms_admin', NULL, 'Calculation', @_desc, '', '', 'e', NULL, NULL, @process_id, '', '', '', 'n'
	EXEC spa_NotificationUserByRole 4, @process_id, 'Auto-Balancing Calculation', @_desc , 'e', NULL, 1, 0, @role_id

END
--ELSE
--BEGIN
--	SELECT @role_id = role_id from application_security_role WHERE role_name = 'Nomination Submission Notification-Success'

--	--EXEC spa_message_board 'u', 'farrms_admin', NULL, 'Calculation', @_desc, '', '', 'e', NULL, NULL, @process_id, '', '', '', 'n'
--	EXEC spa_NotificationUserByRole 4, @process_id, 'Auto-Balancing Calculation', 'Auto-Balancing Calculation Process is completed.' , 's', NULL, 1, 0, @role_id

--	DECLARE @report_param VARCHAR(MAX)
--	SET @report_param = 'report_filter:''''as_of_date=' + @as_of_date + ',sub_id=NULL,stra_id=NULL,book_id=NULL,sub_book_id=NULL,convert_timezone_id=14,term_start=' + @term_start + ',term_end=' + @term_end + ',commodity_id=123,source_deal_header_ids=NULL,counterparty_ids=NULL,location_ids=NULL,deal_id=NULL,deal_status_id=NULL,deal_type_id=NULL,external_id1=NULL'''',is_refresh:0,report_region:en-US,runtime_user:farrms_admin,global_currency_format:$,global_date_format:dd.M.yyyy,global_thousand_format:,#,global_rounding_format:#0.0000,global_price_rounding_format:#0.0000,global_volume_rounding_format:#0.00,global_amount_rounding_format:#0.00,global_science_rounding_format:2,global_negative_mark_format:1,global_number_format_region:de-DE,is_html:n'

--	SET @_desc = 'EXEC spa_rfx_export_report_job @report_param = ''' + REPLACE(@report_param, '''', '''''') + '''
--	, @proc_desc = ''BatchReport'', @user_login_id = ''farrms_admin'', @report_RDL_name = ''Enercity Nomination Report_Enercity Nomination Report'' 
--	, @report_file_name = ''Enercity Nomination Report_farrms_admin.xlsx''
--	, @report_file_full_path = ''' + @report_file_full_path + '''
--	, @output_file_format = ''EXCELOPENXML'', @paramset_hash = ''9F239C20_03E5_4F47_81A9_55A6A1EB2959'''
--	--print @_desc

--	EXEC batch_report_process
--	@_desc
--	, 'i'
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, ''
--	, 'r'
--	, 0
--	, ''
--	, ''
--	, @role_id
--	, '751'
--	, 'n'
--	, @batch_unique_id
--	, NULL
--	, ''
--	, ''
--	, ''
--	, ''
--	, @report_path
--	, ''
--	, ''
--	, 'n'
--	, ','
--	, '0'
--	, '-100000'
--	, '.xlsx'
--	, ''
--	, '3'
--	, ''
--	, ''

--END

