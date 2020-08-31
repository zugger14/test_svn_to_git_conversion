IF OBJECT_ID(N'spa_egssis_capacity_booking', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_egssis_capacity_booking]
GO 

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: sbasnet@pioneersolutionsglobal.com
-- Create date: 2019-08-08
 
-- Params:
-- @flag CHAR(1)
-- @process_table_name  VARCHAR(100) - Process table name
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_egssis_capacity_booking]
	@flag CHAR(1),
	@process_table_name VARCHAR(500) = NULL,
	@tableNameorQuery VARCHAR(1000) = NULL, --added for testing purpose
	@type VARCHAR(50) = NULL, 
	@process_id VARCHAR(50) = NULL,
	@file_name VARCHAR(100) = NULL,
	@file_location VARCHAR(1000) = NULL,
	@message VARCHAR(MAX) = NULL	
AS
SET NOCOUNT ON

DECLARE @user_name VARCHAR(50) = dbo.FNAdbuser()
		,@desc_success VARCHAR(MAX)
		,@url VARCHAR(MAX)
		,@request_json NVARCHAR(MAX)
		,@response_json NVARCHAR(MAX)
		,@export_web_service_id INT

SELECT @export_web_service_id = id FROM export_web_service
WHERE handler_class_name = 'EgssisCapacityBooking'
/*
--Debug query for json build
IF OBJECT_ID('tempdb..#temp_data_table', 'U') IS NOT NULL
		DROP TABLE #temp_data_table

CREATE table #temp_data_table(
	[creationDate] NVARCHAR(20),
	[from] NVARCHAR(200),
	grid NVARCHAR(200),
	contract_type NVARCHAR(200),
	zone NVARCHAR(200), 
	location NVARCHAR(200), 
	location_type NVARCHAR(200),
	internal_shipper NVARCHAR(200), 
	counterparty NVARCHAR(200),
	gas_day NVARCHAR(200),
	forecast_overrides_quantity NVARCHAR(200),
	[value] NVARCHAR(200)
)

INSERT INTO #temp_data_table
SELECT '019-07-18T13:21:00Z','egssis_gasum','Energinet','Border','DS000068','21Z0000000000252','RegularBorder','DS000068','DS000068','2019-08-01','false','0'  UNION
SELECT '019-07-18T13:21:00Z','egssis_gasum','Energinet','Border','DS000068','21Z0000000000260','RegularBorder','DS000068','GASPOOLEH4000000','2019-08-01','false','0'
*/
IF @flag = 'j' --For JSON
BEGIN
/*
EXEC('
	SELECT (
	SELECT *
	FROM '+@process_table_name+'
	FOR JSON AUTO
	)  AS [json_data]
')
--*/
--/*
EXEC('IF COL_LENGTH('''+@process_table_name+''',''gas_day1'') IS NULL
	  ALTER TABLE '+ @process_table_name +'
	  ADD gas_day1 VARCHAR(100)
	')

									

EXEC('   
DECLARE  @json NVARCHAR(MAX)
SELECT  @json = COALESCE(@json + '', '', '''') +
			''{
			"location" : "'' + ISNULL([Location],'''') + ''",
			"startDate" : "'' + CONVERT(VARCHAR(10), [Start Date], 120) + ''",
			"endDate" : "'' + CONVERT(VARCHAR(10), [End Date], 120) + ''",
			"value" : "'' + CAST(CAST(ROUND([Value],0) AS INT) AS VARCHAR(100)) + ''",
			"type" : "'' + ISNULL([Type],'''') + ''",
			"direction" : "'' + ISNULL([Direction],'''') + ''",
			"granularity" : "'' + ISNULL([Granularity],'''') + ''",
			"unit" : "'' + ISNULL([Unit],'''') + ''",
			"uniqueID" : "'' + ISNULL(CAST([Unique ID] AS VARCHAR(10)),'''') + ''",
			"bookingReference" : "'' + ISNULL([Booking Reference],'''') + ''"
        }''
FROM '+ @process_table_name +'

SELECT ''{
		"capacities":[
			''+@json+''
		]
	 }
'' [json_data]

')
--*/
END
ELSE If @flag = 'm' -- For building message
BEGIN
	SET @response_json = @message
	IF @type = 'Success'
	BEGIN
		--SET @desc_success = 'Data has been posted successfully. Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the JSON file.'
		--					+ @message
		SET @message =  '<b>Response :</b> ' + @message
		SET @desc_success = 'Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the JSON file.<br>'
						   +  @message
		EXEC spa_message_board 'i',  @user_name , NULL, 'Capacity Booking' , @desc_success , '', '', 's', NULL,NULL, @process_id
	END
	ELSE IF @type = 'Failed'
	BEGIN
		SELECT * 
		INTO #temp_parseJSON_result
		FROM dbo.FNAParseJSON(@message)

		SELECT @message = '<b>Response :</b> ' + [StringValue]
		FROM #temp_parseJSON_result
		WHERE [NAME] = 'message'
		--SET @desc_success = @message + 'Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the JSON file.'
		SET @desc_success = 'Please <a target="_blank" href="../../adiha.php.scripts/force_download.php?path=dev/shared_docs/temp_Note/' + @file_name + '"><b>Click Here</b></a> to download the JSON file.<br>'
						   +  @message
		INSERT INTO source_system_data_import_status (process_id, code, module, source, type, description)
		SELECT @process_id, 'Failed', 'Capacity Booking Interface', 'Capacity Booking Interface', 'Error', @desc_success

		SELECT @url = './spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
 	
		SELECT @desc_success = '<a target="_blank" href="' + @url + '">Failed to post data</a>. '
		EXEC spa_message_board 'i', @user_name,  NULL, 'Capacity Booking', @desc_success, '', '', 's',  NULL, NULL, @process_id
	END
	SELECT @file_name = document_path + '\temp_Note\' + @file_name
	FROM connection_string
	SET @request_json = dbo.FNAReadFileContents(@file_name)

	INSERT INTO remote_service_response_log(response_status,process_id,response_msg_detail,request_msg_detail,export_web_service_id)
	SELECT @type,@process_id,@response_json,@request_json, @export_web_service_id
	
END



