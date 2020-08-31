IF OBJECT_ID(N'[dbo].[spa_process_rec_api_info]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_process_rec_api_info]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	This SP is used to process rec certificates to/from webservices.
	It is also used in Transfer RECs menu to process grid data.

	Parameters
	@operation_type     : Operation Flag 
		link_grid				 : Link Grid in Transfer RECs menu
		powerfactor_vols		 : Insert actual volume information from Powerfactor web service to process table
		get_recs				 : Get RECS certificate information from GATS PJM Webservice
		registry				 : To populate Registry dropdown in Transfer RECs window	
		status_grid				 : Status of the Link transfered to webservices
		status_detail_grid		 : Detail Status of the Link transfered to webservices
		export_recs				 : Export certificates to different webservices (GATS, Nepool)
		locus_energy_volume		 : Insert actual volume information from Locus Energy web service to process table
		nepool_trans_positions	 : Insert RECs information from Nepool web service to process table
		power_track_volume		 : Insert actual volume information from PowerTrack web service to process table
		build_powertrack_request : Build request to be used during the import of actual volume information from PowerTrack web service
	@rules_id			: Import Rule Id
	@process_table		: Process Table Name
	@web_response		: Response from Webservice
	@filter_xml			: Filter Parameters
	@site_id			: Site Id for Power Track Import
	@batch_process_id	: Batch Process Id
	@batch_report_param : Batch Parameters
*/

CREATE PROCEDURE [dbo].[spa_process_rec_api_info]
    @operation_type VARCHAR(100) = NULL, -- operation type
	@rules_id INT = NULL,
	@process_table VARCHAR(512) = NULL,
	@web_response VARCHAR(MAX) = NULL,
	@filter_xml TEXT = NULL,
	@site_id VARCHAR(MAX) = NULL,
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(500) = NULL   
AS
SET NOCOUNT ON
	
DECLARE @sql VARCHAR(MAX), 
	@sql2 VARCHAR(MAX),
	@destination_column_name VARCHAR(MAX), 
	@out_msg VARCHAR(MAX), 
	@process_id VARCHAR(80) = dbo.FNAGetNewId(), 
	@user_login_id VARCHAR(50) = dbo.FNADBUser(),
	@response_msg_detail XML,
	@xml_response_msg_detail XML,
	@date_from DATE , 
	@date_to DATE, 
	@link_ids VARCHAR(MAX), 
	@interface_id INT ,
	@filter_process_id VARCHAR(MAX),
	@link_id INT,
	@handler_class_name VARCHAR(50)	,
	@request_msg_detail VARCHAR(MAX)
	
IF @process_table IS NOT NULL
	EXEC('IF OBJECT_ID( ''' + @process_table + ''') IS NOT NULL DROP TABLE ' + @process_table )

IF @batch_process_id IS NOT NULL
	SET @process_id = @batch_process_id

IF @operation_type <> 'link_grid'
BEGIN	
	IF OBJECT_ID(N'tempdb..#tmp_filter_details', N'U') IS NOT NULL
		DROP TABLE #tmp_filter_details
		
	DECLARE @idoc INT 
	--declare @filter_xml VARCHAR(1000) = '<Root><FormXML  date_from="2017-1-4" date_to="2017-4-4" link_ids="3431,3430"></FormXML></Root>'
	--DECLARE @filter_xml VARCHAR(1000) = '<Root><FormXML  date_from="" date_to="" link_ids="3431,3430"></FormXML></Root>'
	EXEC sp_xml_preparedocument @idoc OUTPUT, @filter_xml
	SELECT NULLIF(date_from, '1900-01-01') date_from,
			NULLIF(date_to, '1900-01-01') date_to,
			NULLIF(link_ids, '')link_ids,
			interface_id,
			filter_process_id
	INTO #tmp_filter_details
	FROM OPENXML(@idoc, 'Root/FormXML')
	WITH (
		date_from DATE '@date_from',
		date_to DATE '@date_to',
		link_ids VARCHAR(MAX) '@link_ids',
		interface_id INT '@interface_id',
		filter_process_id VARCHAR(MAX) '@filter_process_id')

	EXEC sp_xml_removedocument @idoc

	SELECT 
		@date_from = date_from, 
		@date_to = date_to, 
		@link_ids = link_ids, 
		@interface_id = ews.id,
		@filter_process_id = filter_process_id,
		@handler_class_name = handler_class_name
	FROM #tmp_filter_details tfd
	LEFT JOIN export_web_service ews ON ews.certificate_entity = tfd.interface_id	
END

IF @operation_type = 'powerfactor_vols'
BEGIN
	BEGIN TRY
		IF OBJECT_ID('tempdb..#temp_data') IS NOT NULL
			DROP TABLE #temp_data
	
		CREATE TABLE #temp_data (
			[uni_id] INT , 
			[id] VARCHAR(1024) COLLATE DATABASE_DEFAULT,	
			[interval] VARCHAR(1024) COLLATE DATABASE_DEFAULT,
			[start_time] DATETIME,
			[end_time] DATETIME,
			[name] VARCHAR(1024) COLLATE DATABASE_DEFAULT,
			[volume] NUMERIC(38,4)
		)

		IF OBJECT_ID('tempdb..#temp_dates') IS NOT NULL
			DROP TABLE #temp_dates
	
		CREATE TABLE #temp_dates (	
			[start_time] DATETIME,
			[end_time] DATETIME, 
			row_num INT
		)

		EXEC('CREATE TABLE ' + @process_table + '(
			[id] VARCHAR(1024),	
			[interval] VARCHAR(1024),
			[start_time] DATETIME,
			[end_time] DATETIME,
			[name] VARCHAR(1024),
			[volume] NUMERIC(38,4)
		)')

		SET @sql = '
			INSERT INTO #temp_data (id, interval, start_time, end_time, [name], volume, uni_id )
			SELECT b.id, b.interval, CAST(b.startTime AS DATE) , CAST(b.endTime AS DATE) , c.[name], ISNULL(NULLIF(d.volume, ''null''),0), ROW_NUMBER() OVER (PARTITION BY b.id ORDER BY b.id ASC)
			FROM OPENJSON(''[' + @web_response + ']'')
			WITH (  
				assets NVARCHAR(MAX) ''$.assets'' AS JSON
			) a
			CROSS APPLY OPENJSON(a.assets)
			WITH (id NVARCHAR(100), 
				interval NVARCHAR(10),
				startTime NVARCHAR(50),
				endTime NVARCHAR(50),
				attributes NVARCHAR(MAX) ''$.attributes'' AS JSON
			) b
			CROSS APPLY OPENJSON(b.attributes)
			WITH (
				name NVARCHAR(10),
				volume NVARCHAR(MAX) ''$.values'' AS JSON
			) c
			OUTER APPLY OPENJSON(volume)
			WITH (volume NVARCHAR(100) ''$'') d;
			
			DECLARE @term_start DATETIME, @term_end DATETIME

			SELECT TOP 1 @term_start = start_time,  @term_end =end_time  FROM #temp_data

			INSERT INTO #temp_dates
			SELECT DATEADD(mm, DATEDIFF(mm, 0, term_start), 0) term_start, EOMONTH(term_end) term_end,  ROW_NUMBER() OVER (ORDER BY term_start asc) AS SortOrder 
			FROM [dbo].[FNATermBreakdown] (''d'', @term_start,@term_end)  AS MyTable
			ORDER BY term_start asc

			UPDATE datas
			SET start_time = dates.start_time,  end_time = dates.end_time
			FROM #temp_data datas
			INNER JOIN #temp_dates dates ON dates.row_num = datas.uni_id'
		EXEC (@sql)

		EXEC('INSERT INTO ' + @process_table + ' SELECT [id], [interval], [start_time], [end_time], [name], [volume] FROM #temp_data')

		EXEC spa_ErrorHandler 0,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Success',
			'Data inserted in Process table successfully.',
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Error',
			'Failed to insert data in Process table.',
			''
	END CATCH

END
ELSE IF @operation_type = 'get_recs'
BEGIN
	BEGIN TRY
		--SELECT @destination_column_name = COALESCE(@destination_column_name + ', ', '') + ixp_columns_name + ' ' + column_datatype  
		--FROM ixp_import_data_mapping iidm
		--INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iidm.dest_column
		--WHERE ixp_rules_id = @rules_id

		--EXEC('CREATE TABLE ' + @process_table + '(' + @destination_column_name + ')')

		EXEC('CREATE TABLE ' + @process_table + '(
			  [Action] NVARCHAR(2048)
			, [Certificate Folder] NVARCHAR(2048)	
			, [Unit ID]	NVARCHAR(2048)	
			, [Facility Name]	NVARCHAR(2048)	
			, [Fuel Type]	NVARCHAR(2048)	
			, [Loc of Generator]	NVARCHAR(2048)	
			, [Month of Generation]	NVARCHAR(2048)	
			, [Certificate Serial Numbers]	NVARCHAR(2048)	
			, [Qty]	NVARCHAR(2048)	
			, [REC Create]	NVARCHAR(2048)	
			, [Previous Owner]	NVARCHAR(2048)	
			, [Price]	NVARCHAR(2048)	
			, [New Jersey]	NVARCHAR(2048)	
			, [NJ State Number]	NVARCHAR(2048)	
			, [NJ Eligibility End Date]	NVARCHAR(2048)	
			, [Maryland]	NVARCHAR(2048)	
			, [MD State Number]	NVARCHAR(2048)	
			, [MD Eligibility End Date]	NVARCHAR(2048)	
			, [District of Columbia]	NVARCHAR(2048)	
			, [DC State Number]	NVARCHAR(2048)	
			, [DC Eligibility End Date]	NVARCHAR(2048)	
			, [Pennsylvania]	NVARCHAR(2048)	
			, [PA State Number]	NVARCHAR(2048)	
			, [PA Eligibility End Date]	NVARCHAR(2048)	
			, [Delaware]	NVARCHAR(2048)	
			, [DE State Number]	NVARCHAR(2048)	
			, [DE Eligibility End Date]	NVARCHAR(2048)	
			, [Illinois]	NVARCHAR(2048)	
			, [IL State Number]	NVARCHAR(2048)	
			, [IL Eligibility End Date]	NVARCHAR(2048)	
			, [Ohio]	NVARCHAR(2048)	
			, [OH State Number]	NVARCHAR(2048)	
			, [OH Eligibility End Date]	NVARCHAR(2048)	
			, [Virginia]	NVARCHAR(2048)	
			, [VA State Number]	NVARCHAR(2048)	
			, [VA Eligibility End Date]	NVARCHAR(2048)	
			, [Green-e]	NVARCHAR(2048)	
			, [EFEC]	NVARCHAR(2048)	
			, [EFEC Cert Number]	NVARCHAR(2048)	
			, [IL ZEC]	NVARCHAR(2048)	
			, [West Virginia] NVARCHAR(2048)		
			, [WV State Number]	NVARCHAR(2048)	
			, [WV Eligibility End Date]	NVARCHAR(2048)	
			)
		')
		SET @sql = '
		DECLARE @inner_sql VARCHAR(MAX), @XML XML = ''' + @web_response + '''		
					
		;WITH XMLNAMESPACES (''http://pjm-eis.com/Aggregator'' AS ns)	
		SELECT N.value(''ns:RecSubaccountType[1]'',''VARCHAR(MAX)'') AS RecSubaccountType,
		N.value(''ns:GATSUnitID[1]'',''VARCHAR(MAX)'') AS GATSUnitID,
		N.value(''ns:FacilityName[1]'',''VARCHAR(MAX)'') AS FacilityName,
		N.value(''ns:FuelType[1]'',''VARCHAR(MAX)'') AS FuelType,
		N.value(''ns:LocationOfGenerator[1]'',''VARCHAR(MAX)'') AS LocationOfGenerator,						
		N.value(''ns:MonthYearGeneration[1]'',''VARCHAR(MAX)'') AS MonthYearGeneration,
		N.value(''ns:RECSerialNumber[1]'',''VARCHAR(MAX)'') AS RECSerialNumber,						
		N.value(''ns:Quantity[1]'',''VARCHAR(MAX)'') AS Quantity,						
		N.value(''ns:CurrentPrice[1]'',''VARCHAR(MAX)'') AS CurrentPrice,						
		N.value(''ns:MonthYearCreation[1]'',''VARCHAR(MAX)'') AS MonthYearCreation,												
		N.value(''ns:PreviousOwner[1]'',''VARCHAR(MAX)'') AS PreviousOwner,
		N.value(''ns:NJRPSProgram[1]'',''VARCHAR(MAX)'') AS NJRPSProgram,
		N.value(''ns:NJCertificationNumber[1]'',''VARCHAR(MAX)'') AS NJCertificationNumber,
		N.value(''ns:NJEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS NJEligibilityEndDate,						
		N.value(''ns:MDRPSProgram[1]'',''VARCHAR(MAX)'') AS MDRPSProgram,
		N.value(''ns:MDCertificationNumber[1]'',''VARCHAR(MAX)'') AS MDCertificationNumber,
		N.value(''ns:MDEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS MDEligibilityEndDate,
		N.value(''ns:DCRPSProgram[1]'',''VARCHAR(MAX)'') AS DCRPSProgram,
		N.value(''ns:DCEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS DCEligibilityEndDate,
		N.value(''ns:DCCertificationNumber[1]'',''VARCHAR(MAX)'') AS DCCertificationNumber,
		N.value(''ns:PARPSProgram[1]'',''VARCHAR(MAX)'') AS PARPSProgram,
		N.value(''ns:PACertificationNumber[1]'',''VARCHAR(MAX)'') AS PACertificationNumber,
		N.value(''ns:PAEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS PAEligibilityEndDate,						
		N.value(''ns:DERPSProgram[1]'',''VARCHAR(MAX)'') AS DERPSProgram,						
		N.value(''ns:DECertificationNumber[1]'',''VARCHAR(MAX)'') AS DECertificationNumber,
		N.value(''ns:DEEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS DEEligibilityEndDate,
		N.value(''ns:ILRPSProgram[1]'',''VARCHAR(MAX)'') AS ILRPSProgram,
		N.value(''ns:ILCertificationNumber[1]'',''VARCHAR(MAX)'') AS ILCertificationNumber,
		N.value(''ns:ILEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS ILEligibilityEndDate,
		N.value(''ns:OHRPSProgram[1]'',''VARCHAR(MAX)'') AS OHRPSProgram,
		N.value(''ns:OHCertificationNumber[1]'',''VARCHAR(MAX)'') AS OHCertificationNumber,						
		N.value(''ns:OHEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS OHEligibilityEndDate,
		N.value(''ns:WVRPSProgram[1]'',''VARCHAR(MAX)'') AS WVRPSProgram,						
		N.value(''ns:WVCertificationNumber[1]'',''VARCHAR(MAX)'') AS WVCertificationNumber,
		N.value(''ns:WVEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS WVEligibilityEndDate,
		N.value(''ns:VARPSProgram[1]'',''VARCHAR(MAX)'') AS VARPSProgram,
		N.value(''ns:VACertificationNumber[1]'',''VARCHAR(MAX)'') AS VACertificationNumber,
		N.value(''ns:VAEligibilityEndDate[1]'',''VARCHAR(MAX)'') AS VAEligibilityEndDate,
		N.value(''ns:GreeneEligible[1]'',''VARCHAR(MAX)'') AS GreeneEligible,		
		N.value(''ns:EFECEligible[1]'',''VARCHAR(MAX)'') AS EFECEligible,						
		N.value(''ns:EFECCertificationNumber[1]'',''VARCHAR(MAX)'') AS EFECCertificationNumber
		INTO #temp_data
		FROM @XML.nodes(''/*:Envelope/*:Body/ns:GetRECsResponse/ns:GetRECsResult/ns:RecInfoResults/ns:RecInfos'') AS T(N)
		
		INSERT INTO ' + @process_table + '(
			[Unit ID]		
			, [Facility Name]		
			, [Fuel Type]		
			, [Loc of Generator]		
			, [Month of Generation]		
			, [Certificate Serial Numbers]		
			, [Qty]		
			, [REC Create]		
			, [Previous Owner]		
			, [Price]		
			, [New Jersey]		
			, [NJ State Number]		
			, [NJ Eligibility End Date]		
			, [Maryland]		
			, [MD State Number]		
			, [MD Eligibility End Date]		
			, [District of Columbia]		
			, [DC State Number]		
			, [DC Eligibility End Date]		
			, [Pennsylvania]		
			, [PA State Number]		
			, [PA Eligibility End Date]		
			, [Delaware]		
			, [DE State Number]		
			, [DE Eligibility End Date]		
			, [Illinois]		
			, [IL State Number]		
			, [IL Eligibility End Date]		
			, [Ohio]		
			, [OH State Number]		
			, [OH Eligibility End Date]		
			, [Virginia]		
			, [VA State Number]		
			, [VA Eligibility End Date]		
			, [Green-e]
			, [EFEC]			
			, [EFEC Cert Number]
			, [West Virginia]		
			, [WV State Number]		
			, [WV Eligibility End Date]			
		)
		
		SELECT 
			GATSUnitID
			, NULLIF(FacilityName, '''')
			, NULLIF(FuelType, '''')
			, NULLIF(LocationOfGenerator, '''')
			, CONVERT(DATETIME, ''01/'' + NULLIF(MonthYearGeneration, ''''), 103)
			, NULLIF(RECSerialNumber, '''')
			, NULLIF(Quantity, '''')
			, CONVERT(DATETIME, ''01/'' + NULLIF(MonthYearCreation, ''''), 103)  
			, NULLIF(PreviousOwner, '''')
			, NULLIF(CurrentPrice, '''')
			, NULLIF(NJRPSProgram, '''')
			, NULLIF(NJCertificationNumber, '''')
			, NULLIF(NJEligibilityEndDate, '''')
			, NULLIF(MDRPSProgram, '''')
			, NULLIF(MDCertificationNumber, '''')
			, NULLIF(MDEligibilityEndDate, '''')
			, NULLIF(DCRPSProgram, '''')
			, NULLIF(DCCertificationNumber, '''')
			, NULLIF(DCEligibilityEndDate, '''')
			, NULLIF(PARPSProgram, '''')
			, NULLIF(PACertificationNumber, '''')
			, NULLIF(PAEligibilityEndDate, '''')
			, NULLIF(DERPSProgram, '''')
			, NULLIF(DECertificationNumber, '''')
			, NULLIF(DEEligibilityEndDate, '''')
			, NULLIF(ILRPSProgram, '''')
			, NULLIF(ILCertificationNumber, '''')
			, NULLIF(ILEligibilityEndDate, '''')
			, NULLIF(OHRPSProgram, '''')
			, NULLIF(OHCertificationNumber, '''')
			, NULLIF(OHEligibilityEndDate, '''')
			, NULLIF(VARPSProgram, '''')
			, NULLIF(VACertificationNumber, '''')
			, NULLIF(VAEligibilityEndDate, '''')
			, NULLIF(GreeneEligible, '''')
			, NULLIF(EFECEligible, '''')
			, NULLIF(EFECCertificationNumber, '''')
			, NULLIF(WVRPSProgram, '''')
			, NULLIF(WVCertificationNumber, '''')
			, NULLIF(WVEligibilityEndDate, '''')

		FROM #temp_data			
		'
		EXEC(@sql)
		
		EXEC spa_ErrorHandler 0,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Success',
			'Data inserted in Process table successfully.',
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Error',
			'Failed to insert data in Process table.',
			''
	END CATCH
END
IF @operation_type = 'registry'
BEGIN
	SELECT value_id, ws_name 
	FROM static_data_value sdv 
	INNER JOIN export_web_service ewb ON ewb.certificate_entity = sdv.value_id
	WHERE handler_class_name IN ('GatsPjmTransferRecsExporter', 'NepoolTransferRequestExporter')
END
ELSE IF @operation_type = 'status_grid'
BEGIN	
	SET @sql = 'SELECT DISTINCT mhdi.link_id [Link ID], process_id [Process Id], dbo.FNADateTimeFormat(rsrl.create_ts, 0) [Sent Date], rsrl.create_user [User]
		FROM remote_service_response_log rsrl 
		INNER JOIN matching_header_detail_info mhdi ON mhdi.id = rsrl.generic_obj_id 
		INNER JOIN export_web_service ewb ON ewb.id = rsrl.export_web_service_id
		AND handler_class_name IN (''GatsPjmTransferRecsExporter'', ''NepoolTransferRequestExporter'')'
		+ ' WHERE 1=1 ' + 
		CASE WHEN @link_ids IS NOT NULL THEN ' AND mhdi.link_id IN (' +  @link_ids + ') ' ELSE ''  END
		+ CASE WHEN @date_from IS NOT NULL THEN ' AND CONVERT(DATE,rsrl.create_ts) >= ''' +  CAST(@date_from AS VARCHAR(20)) + '''' ELSE ''  END
		 + CASE WHEN @date_to IS NOT NULL THEN ' AND CONVERT(DATE,rsrl.create_ts) <= ''' +  CAST(@date_to AS VARCHAR(20)) + '''' ELSE ''  END 
		+ ' ORDER BY mhdi.link_id DESC'
	EXEC(@sql)
	
END
ELSE IF @operation_type = 'status_detail_grid'
BEGIN	
	IF OBJECT_ID('tempdb..#response_details') IS NOT NULL
	DROP TABLE #response_details

	CREATE TABLE #response_details (
		match_info_id INT, 
		serial_number VARCHAR(100) COLLATE DATABASE_DEFAULT,
		process_id VARCHAR(120) COLLATE DATABASE_DEFAULT,
		counterparty_name VARCHAR(50) COLLATE DATABASE_DEFAULT
	)
	DECLARE @cur_response_msg_detail VARCHAR(MAX)
	DECLARE @cur_status CURSOR
	SET @cur_status = CURSOR FOR	
	SELECT DISTINCT a.[value] process_id, response_msg_detail, handler_class_name, request_msg_detail
	FROM remote_service_response_log rsrl
	INNER JOIN string_split(@filter_process_id, ',') a on a.[value] = rsrl.process_id 	
	INNER JOIN export_web_service ews ON ews.id = rsrl.export_web_service_id

	OPEN @cur_status
	FETCH NEXT
	FROM @cur_status INTO @process_id, @cur_response_msg_detail, @handler_class_name, @request_msg_detail
	WHILE @@FETCH_STATUS = 0
	BEGIN		
		IF (@handler_class_name = 'GatsPjmTransferRecsExporter')
		BEGIN				
			SET @xml_response_msg_detail = @cur_response_msg_detail
			
			;WITH XMLNAMESPACES ('http://pjm-eis.com/Aggregator' AS ns)	
			INSERT INTO #response_details (match_info_id, serial_number, process_id, counterparty_name)
			SELECT 
			N.value('ns:RowID[1]','VARCHAR(MAX)')  match_info_id,
			N.value('ns:RECSerialNumber[1]','VARCHAR(MAX)') serial_number,
			@process_id, 
			a.cpty_name
			FROM @xml_response_msg_detail.nodes('/*:Envelope/*:Body/ns:TransferRecResponse/ns:TransferRecResult/ns:RECTransferResults/ns:RECTransfers ') AS T(N)
			OUTER APPLY
			(
				SELECT sc.counterparty_name cpty_name FROM generic_mapping_header gmh
				INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id= gmv.clm5_value
				WHERE gmh.mapping_name = 'Value Mapping' AND clm2_value = 'c'
				AND N.value('ns:AccountName[1]','VARCHAR(MAX)') = clm4_value
			) a
		END
		ELSE IF (@handler_class_name = 'NepoolTransferRequestExporter')
		BEGIN
			INSERT INTO #response_details (match_info_id, serial_number, process_id, counterparty_name)
			SELECT requestCorrelationId, certificateSerialNumberRange, @process_id, a.counterparty_name
			FROM OPENJSON(@request_msg_detail)
			WITH (
				buyerAccountId VARCHAR(100),
				[certificateSerialNumberRange] VARCHAR(500),
				requestCorrelationId INT
			) b
			CROSS APPLY
			(
				SELECT sc.counterparty_name FROM generic_mapping_header gmh
				INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id= gmv.clm5_value
				WHERE gmh.mapping_name = 'Value Mapping' AND clm2_value = 'c'
				AND buyerAccountId = clm3_value
			) a
		END

		FETCH NEXT
		FROM @cur_status INTO @process_id, @cur_response_msg_detail, @handler_class_name, @request_msg_detail
	END
	CLOSE @cur_status
	DEALLOCATE @cur_status	

	SELECT mhdi.link_id, mhdi.source_deal_header_id sell_deal_id, mhdi.source_deal_header_id_from buy_deal_id, 
	b.facility_name, b.unit_id, mhdi.assigned_vol, rd.serial_number, rd.counterparty_name,
	IIF(rsrl.response_status IN ('OK_DATA', 'Success') , 'Transferred', 'Error')[status], response_message 
	FROM remote_service_response_log rsrl
	INNER JOIN matching_header_detail_info mhdi ON mhdi.id = rsrl.generic_obj_id
	LEFT JOIN #response_details rd ON rd.process_id = rsrl.process_id AND rd.match_info_id = mhdi.id
	LEFT JOIN static_data_value sdv ON sdv.value_id = mhdi.transfer_status AND sdv.[type_id] = 112100
	OUTER APPLY (
		SELECT ISNULL(rg.name, gc.facility_name) facility_name, 		
		CASE WHEN sc.int_ext_flag = 'i' THEN rg.code 
			WHEN sc.int_ext_flag = 'e' THEN gc.unit_id
		END unit_id 
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 		
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id			
		LEFT JOIN rec_generator rg ON rg.generator_id = sdh.generator_id		
		LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id AND gc.state_value_id = mhdi.state_value_id AND gc.tier_type = mhdi.tier_value_id			
		WHERE sdd.source_deal_header_id = mhdi.source_deal_header_id_from AND sdd.source_deal_detail_id = mhdi.source_deal_detail_id_from	
	) b 
	INNER JOIN string_split(@filter_process_id, ',') a on a.[value] = rsrl.process_id 	

END
ELSE IF @operation_type = 'link_grid'
BEGIN	
	DECLARE @destination_registry INT, @status VARCHAR(10), @grid_proc_table VARCHAR(100)
	SET @grid_proc_table  = dbo.FNAProcessTableName('grid_link', @user_login_id, @process_id)
	
	EXEC spa_buy_sell_match @flag = 's', @xmlValue = @filter_xml, @return_process_table = @grid_proc_table
	
	DECLARE @idoc3 INT
	EXEC sp_xml_preparedocument @idoc3 OUTPUT, @filter_xml
			
	IF OBJECT_ID('tempdb..#temp_deal_match_filter') IS NOT NULL
		DROP TABLE #temp_deal_match_filter
		
	SELECT	
		NULLIF(destination_registry, '')	[destination_registry],
		NULLIF([status], '')	[status]
	INTO #temp_deal_match_filter
	FROM OPENXML(@idoc3, '/Root/FormXML', 1)
	WITH (
		destination_registry	INT,
		[status]	VARCHAR(10)
	)

	SELECT 
		@destination_registry = destination_registry,
		@status = [status]
	FROM #temp_deal_match_filter

	IF OBJECT_ID('tempdb..#service_type') IS NOT NULL
		DROP TABLE #service_type
	
	CREATE TABLE #service_type(id INT , code VARCHAR(100) COLLATE DATABASE_DEFAULT)

	--DECLARE @sql VARCHAR(500)
	SELECT @sql=sql_string from user_defined_fields_template udft
	WHERE udft.field_name = -10000287
	
	INSERT INTO #service_type
	EXEC(@sql )
	
	SET @sql = 'SELECT 
	DISTINCT 
	dbo.[FNATRMWinHyperlink](''a'',''20007900'',lg.link_id,lg.link_id,''n'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0) hyper_link_id,
	[description], [mh.effective_date], group1, group2, group3, group4, 
	total_matched_volume, price, lg.currency_id, match_status, lg.link_id
	FROM ' + @grid_proc_table + ' lg
	INNER JOIN matching_header_detail_info mhdi ON mhdi.link_id = lg.link_id
	INNER JOIN gis_certificate gc ON gc.source_deal_header_id = mhdi.source_deal_detail_id_from '
	
	IF EXISTS (SELECT 1 FROM #service_type)
	BEGIN
		SET @sql += ' LEFT JOIN user_defined_deal_fields uddf
				ON mhdi.source_deal_header_id = uddf.source_deal_header_id
			LEFT JOIN user_defined_deal_fields_template uddft
				ON uddft.udf_template_id = uddf.udf_template_id 
			LEFT JOIN user_defined_fields_template udft
				ON udft.field_id = uddft.field_id AND udft.field_name = -10000287 
			OUTER APPLY (SELECT id FROM #service_type WHERE code = ''Auto Transfer'') st 			
			WHERE ISNULL(uddf.udf_value, -1) <> ISNULL(st.id, -2) AND gc.certification_entity = ' + CAST(@destination_registry AS VARCHAR(50)) +
			' AND ISNULL(mhdi.transfer_status, 112100) = ' + CAST(@status AS VARCHAR(50))
	END
	ELSE
	BEGIN
		SET @sql += ' WHERE gc.certification_entity = ' + CAST(@destination_registry AS VARCHAR(50)) +
			' AND ISNULL(mhdi.transfer_status, 112100) = ' + CAST(@status AS VARCHAR(50))
	END
	SET @sql += ' AND mhdi.sequence_from IS NOT NULL AND mhdi.sequence_to IS NOT NULL ORDER BY lg.link_id DESC'
	EXEC (@sql)
END
ELSE IF @operation_type = 'export_recs'
BEGIN	
	IF OBJECT_ID('tempdb..#link_ids') IS NOT NULL
		DROP TABLE #link_ids

	CREATE TABLE #link_ids (
		link_id INT
	)

	INSERT INTO #link_ids SELECT * FROM STRING_SPLIT(@link_ids, ',') 	
		
	IF OBJECT_ID('tempdb..#certificate_less_links') IS NOT NULL
		DROP TABLE #certificate_less_links

	CREATE TABLE #certificate_less_links (
		link_id INT,
		match_info_id INT
	)

	IF OBJECT_ID('tempdb..#validate_links') IS NOT NULL
		DROP TABLE #validate_links

	CREATE TABLE #validate_links (
		link_id INT,
		match_info_id INT,
		val_message VARCHAR(500) COLLATE DATABASE_DEFAULT
	)
	
	IF OBJECT_ID('tempdb..#dependent_links') IS NOT NULL
		DROP TABLE #dependent_links

	CREATE TABLE #dependent_links (
		link_id INT,
		dependent_link_id INT, 
		transfer_Status INT,
		match_info_id INT
	)

	IF OBJECT_ID('tempdb..#rec_info') IS NOT NULL
		DROP TABLE #rec_info

	CREATE TABLE #rec_info (
		row_id INT,
		gats_unit_id VARCHAR(50) COLLATE DATABASE_DEFAULT,  
		rec_serial_number VARCHAR(50) COLLATE DATABASE_DEFAULT,
		month_year VARCHAR(10) COLLATE DATABASE_DEFAULT,
		quantity INT,
		price NUMERIC(38,4),
		account_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
		account_name VARCHAR(50) COLLATE DATABASE_DEFAULT,
		transfer_type VARCHAR(10) COLLATE DATABASE_DEFAULT
	)
	
	INSERT INTO #certificate_less_links(link_id, match_info_id)
	SELECT DISTINCT mhdi.link_id, mhdi.id
	FROM matching_header_detail_info mhdi
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mhdi.source_deal_detail_id_from 
	INNER JOIN #link_ids li ON li.[link_id] = mhdi.link_id
	LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id 
	WHERE gc.source_certificate_number IS NULL

	UPDATE matching_header_detail_info SET transfer_status = 112101 WHERE ID IN (SELECT match_info_id FROM #certificate_less_links) -- SET transfer_status = Error
	
	--- Remove those deals without certificate
	DELETE FROM #link_ids WHERE link_id IN (SELECT link_id FROM #certificate_less_links)

	INSERT INTO #dependent_links(link_id, dependent_link_id, transfer_status, match_info_id )
	SELECT mhdi.link_id, buy_mhdi.link_id dependent_link_id, buy_mhdi.transfer_status, mhdi.id
	FROM matching_header_detail_info mhdi
		INNER JOIN matching_header_detail_info buy_mhdi ON buy_mhdi.source_deal_detail_id_from = mhdi.source_deal_detail_id_from
			AND buy_mhdi.sequence_from < mhdi.sequence_from 	
		AND ISNULL(buy_mhdi.transfer_Status, 112100) NOT IN (112103, 112102)  -- 112102 delivered,112103 transfered 
	INNER JOIN #link_ids li ON li.link_id = mhdi.link_id	
		AND buy_mhdi.link_id NOT IN (SELECT link_id FROM #link_ids)
	OUTER APPLY (SELECT mhdia.id 
			FROM matching_header_detail_info_audit mhdia 
			WHERE mhdia.source_deal_detail_id_from = mhdi.source_deal_detail_id_from
			AND mhdi.sequence_from = mhdia.sequence_from --AND mhdia.sequence_to
			AND mhdia.user_action = 'Delete' and ISNULL(mhdia.transfer_status, -1) IN (112103, 112102)) aud
	WHERE aud.id IS NULL

	UPDATE matching_header_detail_info SET transfer_status = 112101 WHERE ID IN (SELECT match_info_id FROM #dependent_links) -- SET transfer_status = Error

	DELETE FROM #link_ids WHERE link_id IN (SELECT link_id FROM #dependent_links)

	--cursor query

	DECLARE @cur_transfer_recs CURSOR
	SET @cur_transfer_recs = CURSOR FOR
	
	SELECT 
	DISTINCT li.link_id
	FROM matching_header_detail_info mhdi
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = mhdi.source_deal_detail_id_from 
	INNER JOIN #link_ids li ON li.[link_id] = mhdi.link_id
	INNER JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id 		
	ORDER BY li.link_id ASC

	OPEN @cur_transfer_recs
	FETCH NEXT
	FROM @cur_transfer_recs INTO @link_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE FROM #rec_info	
		SET @sql2 = ''	

		INSERT INTO #rec_info(row_id, gats_unit_id, rec_serial_number, month_year, quantity, price, account_id, account_name, transfer_type )
		SELECT 
			DISTINCT mhdi.id row_id,
			ISNULL(buy_deal.gats_unit_id,'') gats_unit_id, 
			buy_deal.rec_serial_number ,
			buy_deal.vintage month_year,
			mhdi.assigned_vol quantity, 
			sell_deal.fixed_price price, 
			ISNULL(sell_deal.account_id, '') account_id,
			ISNULL(sell_deal.account_name, '') account_name,
			'spot' transfer_type
		FROM matching_header_detail_info mhdi 
		OUTER APPLY(
			SELECT
			a.account_id, inner_sdd1.fixed_price, a.account_name account_name
			FROM source_deal_header inner_sdh1
			INNER JOIN source_deal_detail inner_sdd1 ON inner_sdd1.source_deal_header_id = inner_sdh1.source_deal_header_id AND mhdi.source_deal_detail_id =inner_sdd1.source_deal_detail_id
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = inner_sdh1.counterparty_id
			OUTER APPLY
			(
				SELECT gmv.clm3_value account_id, gmv.clm4_value account_name FROM generic_mapping_header gmh
				INNER JOIN generic_mapping_values gmv ON gmv.mapping_table_id = gmh.mapping_table_id
				INNER JOIN #tmp_filter_details tdf ON tdf.interface_id = clm1_value
				WHERE gmh.mapping_name = 'Value Mapping' AND clm2_value = 'c'
				AND sc.source_counterparty_id = clm5_value
			) a
			WHERE inner_sdh1.source_deal_header_id = mhdi.source_deal_header_id
			) sell_deal 	
		OUTER APPLY(
			SELECT
			CAST(FORMAT(inner_sdd2.term_start,'MM') AS CHAR(2)) + '/' + CAST(FORMAT(inner_sdd2.term_start,'yyyy') AS VARCHAR(4)) vintage
				--, sc.int_ext_flag,  inner_sdh.counterparty_id, gc.source_deal_header_id, inner_sdd.source_deal_detail_id, gc.unit_id
				, CASE WHEN sc.int_ext_flag = 'i' THEN rg.code 
					WHEN sc.int_ext_flag = 'e' THEN gc.unit_id
				END gats_unit_id,
				dbo.FNAGetSplitPart(gc.gis_certificate_number_from, '-', LEN(gc.gis_certificate_number_from) - LEN(REPLACE(gc.gis_certificate_number_from,'-',''))) 
				+ CASE WHEN @handler_class_name = 'GatsPjmTransferRecsExporter' THEN ' '
					   WHEN @handler_class_name = 'NepoolTransferRequestExporter' THEN ' - '	
				  END	
				+ CAST(mhdi.sequence_from AS VARCHAR(10)) 
				+ CASE WHEN @handler_class_name = 'GatsPjmTransferRecsExporter' THEN '-'
					   WHEN @handler_class_name = 'NepoolTransferRequestExporter' THEN ' to '	
				  END 
				+ CASE 
					WHEN latest_volume.sequence_from > mhdi.sequence_to 
					AND latest_volume.id < mhdi.id	-- FOR seq available after link delete before transfering
						THEN CAST(mhdi.sequence_to AS VARCHAR(10))
					WHEN deleted_links.sequence_to IS NOT NULL
						THEN CAST(deleted_links.sequence_to AS VARCHAR(10))  
					ELSE
						CAST(certificate_number_to_int AS VARCHAR(10))  
				END rec_serial_number
			FROM source_deal_header inner_sdh2 
			INNER JOIN source_deal_detail inner_sdd2 ON inner_sdd2.source_deal_header_id = inner_sdh2.source_deal_header_id AND inner_sdd2.source_deal_detail_id = mhdi.source_deal_detail_id_from 
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = inner_sdh2.counterparty_id
			LEFT JOIN rec_generator rg ON rg.generator_id = inner_sdh2.generator_id
			OUTER APPLY (
				SELECT TOP 1 gis_certificate_number_from, gc.unit_id, certificate_number_to_int 
				FROM gis_certificate gc
				WHERE  gc.source_deal_header_id = inner_sdd2.source_deal_detail_id  ) gc
			OUTER APPLY (SELECT TOP 1 id, assigned_vol, mhdi1.sequence_from, mhdi1.sequence_to  
				FROM matching_header_detail_info mhdi1 
				WHERE mhdi1.source_deal_detail_id_from = mhdi.source_deal_detail_id_from 
				AND ISNULL(mhdi1.transfer_status, 112100) NOT IN (112100) AND mhdi1.id <> mhdi.id 
				ORDER BY mhdi1.id DESC) latest_volume
			OUTER APPLY(
				SELECT TOP 1 sequence_from, sequence_to 
				FROM matching_header_detail_info_audit mhdia WHERE mhdia.source_Deal_detail_id_from= mhdi.source_deal_detail_id_from 
				AND  mhdia.user_action= 'Delete' AND ISNULL(mhdia.transfer_status, -1) IN (112103, 112102) AND mhdia.sequence_from = mhdi.sequence_from
				ORDER BY 1 DESC) deleted_links -- Those links which have been transfered but again deleted and new link is created from it. In Web interface, new cerificate range is already made with range of those transfered link		
			WHERE inner_sdh2.source_deal_header_id = mhdi.source_deal_header_id_from
		) buy_deal	
		WHERE mhdi.link_id = @link_id AND ISNULL(mhdi.transfer_status, 112100) NOT IN (112103, 112102)
		
		/*Transfer Status
		112102	Delivered
		112101	Error
		112100	Outstanding
		112103	Transferred
		*/

		IF @handler_class_name = 'GatsPjmTransferRecsExporter'
		BEGIN			
			INSERT INTO #validate_links (link_id, match_info_id, val_message)
			SELECT  
				@link_id, 
				row_id, 		
				CASE 
					WHEN NULLIF(gats_unit_id,'') IS NULL THEN 'The GATS Unit ID was not provided'
					WHEN NULLIF(month_year,'') IS NULL THEN 'The month and year of the REC is missing'
					WHEN NULLIF(rec_serial_number,'') IS NULL THEN 'The serial number is missing' 
					WHEN NULLIF(quantity,0) IS NULL THEN 'The number of RECs for transfer is missing'
					WHEN NULLIF(price,0) IS NULL THEN 'The price is missing' 
					WHEN ISNUMERIC(price) <> 1 OR price < 0 OR price >= 10000 THEN 'The price is not in a valid format or less than 0 or greater than 999.99'
					WHEN NULLIF(account_name,'') IS NULL THEN 'The buyer Account Name is missing'
					WHEN NULLIF(account_id,'') IS NULL THEN 'The buyer’s Account ID is missing'
					WHEN ISNUMERIC(account_id) <> 1 THEN 'Data Type mismatch for buyer’s Account ID'
				END
			FROM #rec_info 
			WHERE NULLIF(gats_unit_id,'') IS NULL 
				OR NULLIF(month_year,'') IS NULL
				OR NULLIF(rec_serial_number,'') IS NULL 
				OR NULLIF(quantity,0) IS NULL
				OR NULLIF(price,0) IS NULL 
				OR ISNUMERIC(price) <> 1  OR price < 0 OR price >= 10000 
				OR NULLIF(account_name,'') IS NULL 
				OR NULLIF(account_id,'') IS NULL
				OR ISNUMERIC(account_id) <> 1 

			UPDATE matching_header_detail_info SET transfer_status = 112101 WHERE ID IN (SELECT match_info_id FROM #validate_links) -- SET transfer_status = Error
		
			DELETE FROM #rec_info WHERE row_id IN (SELECT match_info_id FROM #validate_links) 
			SELECT @sql2 = COALESCE(@sql2, '') +
					'<agg:RECtransfer>
						<agg:RowID>' + CAST(row_id AS VARCHAR(20)) + '</agg:RowID>
						<agg:GATSUnitID>' + gats_unit_id + '</agg:GATSUnitID>
						<agg:RECSerialNumber>' + rec_serial_number + '</agg:RECSerialNumber>
						<agg:MonthYear>' + month_year + '</agg:MonthYear>
						<agg:Quantity>' + CAST(quantity AS VARCHAR(100)) + '</agg:Quantity>
						<agg:Price>' + CAST(price AS VARCHAR(100)) + '</agg:Price>
						<agg:AccountID>' + account_id + '</agg:AccountID>
						<agg:AccountName>' + account_name + '</agg:AccountName>
						<agg:TransferType>' + transfer_type + '</agg:TransferType>
					</agg:RECtransfer>'
			FROM #rec_info 
			ORDER BY row_id ASC
	
			SELECT @sql = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:agg="http://pjm-eis.com/Aggregator">
				<soapenv:Header/>
				<soapenv:Body>
				<agg:TransferRec>
						<agg:aggName>' + [user_name] + '</agg:aggName>
						<agg:aggToken>' + auth_token + '</agg:aggToken>
						<agg:RECRecords>'
			FROM export_web_service WHERE id = @interface_id
			SET @sql +=	@sql2
			SET @sql += '			</agg:RECRecords>
					</agg:TransferRec>
				</soapenv:Body>
			</soapenv:Envelope>'

		--select @sql
		--	declare @out_msg  VARCHAR(MAX), @process_id VARCHAR(80) = dbo.FNAGetNewId()
		--return
			/* Request sample
		set @sql = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:agg="http://pjm-eis.com/Aggregator">
			<soapenv:Header/>
			<soapenv:Body>
			<agg:TransferRec>
					<agg:aggName>Test1</agg:aggName>
					<agg:aggToken>1FA1074A-A6D4-4522-A77E-D38F73D8798E</agg:aggToken>
					<agg:RECRecords>
						<!--Zero or more repetitions:-->
					<agg:RECtransfer>
						<agg:RowID>22222</agg:RowID>
						<agg:GATSUnitID>MSET53813137</agg:GATSUnitID>
						<agg:RECSerialNumber>1771330 1-10</agg:RECSerialNumber>
						<agg:MonthYear>12/2015</agg:MonthYear>
						<agg:Quantity>10</agg:Quantity>
						<!--Optional:-->
						<agg:Price>3.5</agg:Price>
						<agg:AccountID>14191</agg:AccountID>
						<agg:AccountName>14191 ACC</agg:AccountName>
						<agg:TransferType>Spot</agg:TransferType>
					</agg:RECtransfer>
					</agg:RECRecords>
				</agg:TransferRec>
			</soapenv:Body>
		</soapenv:Envelope>'
			*/	
			IF EXISTS (SELECT 1 FROM #rec_info) AND NULLIF(@sql,'') IS NOT NULL		
			BEGIN 
				EXEC spa_post_data_to_web_service @interface_id, @sql, NULL, @process_id, @out_msg OUTPUT
				--select @out_msg
					/* Response sample
				set @out_msg = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
								<soap:Body>
									<TransferRecResponse xmlns="http://pjm-eis.com/Aggregator">
										<TransferRecResult>
										<RECTransferResults>
											<RowID>22222</RowID>
											<Code>E_BADSER</Code>
											<BatchTransferID xsi:nil="true"/>
											<SerialNumber/>
											<RECTransfers>
												<RowID>22222</RowID>
												<GATSUnitID>MSET53813137</GATSUnitID>
												<RECSerialNumber>1771330 1-10</RECSerialNumber>
												<MonthYear>11/2015</MonthYear>
												<Quantity>10</Quantity>
												<Price>3.50</Price>
												<AccountID>14191</AccountID>
												<AccountName>14191 ACC</AccountName>
												<TransferType></TransferType>
											</RECTransfers>
										</RECTransferResults>
										</TransferRecResult>
									</TransferRecResponse>
								</soap:Body>
							</soap:Envelope>'

				*/
				--declare @response_msg_detail XML 

				SET @response_msg_detail = @out_msg
				IF CHARINDEX('soap:Envelope',@out_msg, 1) > 0
				BEGIN
					;WITH XMLNAMESPACES ('http://pjm-eis.com/Aggregator' AS ns)	
					INSERT INTO remote_service_response_log (generic_obj_id, process_id, response_status, response_message, response_msg_detail, request_msg_detail, export_web_service_id)
					SELECT 
						N.value('ns:RowID[1]','INT') match_info_id
						, @process_id
						, RTRIM(LTRIM(N.value('ns:Code[1]','VARCHAR(MAX)')))  response_status
						, CASE  N.value('ns:Code[1]','VARCHAR(MAX)') 
							WHEN 'OK_DATA' 	THEN 'Success'
							WHEN 'E_INVGEN'	THEN 'Invalid Gats Unit ID'
							WHEN 'E_INVDATE' THEN 'Invalid REC Date'
							WHEN 'E_INVSER'	THEN 'Invalid Serial Number'
							WHEN 'E_BADSER'	THEN 'Serial Number Not Found'
							WHEN 'E_INVREC'	THEN 'Invalid Number of RECs'
							WHEN 'E_INVBUY'	THEN 'Invalid Buyer ID'
							WHEN 'E_INVNM'	THEN 'Invalid Buyer''s Name'
							WHEN 'E_INVTYPE' THEN 'Invalid Transfer Type'
							WHEN 'E_HIREC' THEN 'The number of RECs being transferred is higher than the number of RECs available for the serial number'
						END response_message
						, @out_msg response_msg_detail
						, @sql request_msg_detail
						, @interface_id 
					FROM @response_msg_detail.nodes('/*:Envelope/*:Body/ns:TransferRecResponse/ns:TransferRecResult/ns:RECTransferResults') AS T(N)
					WHERE  N.value('ns:RowID[1]','INT') <> -1
				END
				ELSE 
				BEGIN
					INSERT INTO remote_service_response_log (generic_obj_id, process_id, response_status, response_message, response_msg_detail, request_msg_detail, export_web_service_id)
					SELECT row_id, @process_id, 'Error', @out_msg, @out_msg, @sql, @interface_id FROM #rec_info
				END
				UPDATE mhdi
				SET transfer_status = IIF(rsrl.response_status <> 'OK_DATA', 112101, 112103)  --112103 Transfered
				, delivery_date = IIF(rsrl.response_status <> 'OK_DATA', delivery_date, GETDATE())				
				FROM matching_header_detail_info mhdi
				INNER JOIN remote_service_response_log rsrl ON rsrl.generic_obj_id = mhdi.id 
				AND rsrl.process_id = @process_id
			END
		END
		ELSE IF @handler_class_name = 'NepoolTransferRequestExporter'
		BEGIN	
			INSERT INTO #validate_links (link_id, match_info_id, val_message)
			SELECT  
				@link_id, 
				row_id, 		
				CASE 
					WHEN NULLIF(rec_serial_number,'') IS NULL THEN 'The serial number is missing' 
					WHEN NULLIF(quantity,0) IS NULL THEN 'The number of RECs for transfer is missing'
					WHEN NULLIF(price,0) IS NULL THEN 'The price is missing' 
					WHEN ISNUMERIC(price) <> 1 OR price < 0 OR price >= 10000 THEN 'The price is not in a valid format or less than 0 or greater than 999.99'
					WHEN NULLIF(account_id,'') IS NULL THEN 'The buyer''s account id is missing'
				END
			FROM #rec_info 
			WHERE NULLIF(rec_serial_number,'') IS NULL 
				OR NULLIF(quantity,0) IS NULL
				OR NULLIF(price,0) IS NULL 
				OR ISNUMERIC(price) <>1  OR price < 0 OR price >= 10000 
				OR NULLIF(account_id,'') IS NULL 

			UPDATE matching_header_detail_info SET transfer_status = 112101 WHERE ID IN (SELECT match_info_id FROM #validate_links) -- SET transfer_status = Error
		
			DELETE FROM #rec_info WHERE row_id IN (SELECT match_info_id FROM #validate_links) 

			SELECT @sql = COALESCE(@sql + ',', '') +
							' {
								"buyerAccountId": ' + CAST(account_id AS VARCHAR(20)) + ',
								"certificateSerialNumberRange": "' + rec_serial_number + '",
								"notes": "Certificate transfer",
								"pricePerCertificate":' + CAST(CAST(ROUND(price, 2) AS NUMERIC(36,2))  AS VARCHAR(100)) + ',
								"quantity": ' + CAST(quantity AS VARCHAR(100)) + ',
								"requestCorrelationId": "' + CAST(row_id AS VARCHAR(20)) + '"
							  } '

			FROM #rec_info
			ORDER BY row_id ASC
			SET @sql = '[' + @sql + ']'

			IF EXISTS (SELECT 1 FROM #rec_info) AND NULLIF(@sql,'') IS NOT NULL	
			BEGIN 
				EXEC spa_post_data_to_web_service @interface_id, @sql, NULL, @process_id, @out_msg OUTPUT

				IF CHARINDEX('"requestCorrelationId"',@out_msg, 1) > 0 OR CHARINDEX('"errors"',@out_msg, 1) > 0 
				BEGIN
					IF CHARINDEX('errors', @out_msg, 1)	> 0
					BEGIN
						INSERT INTO remote_service_response_log (generic_obj_id, process_id, response_status, response_message, response_msg_detail, request_msg_detail, export_web_service_id)
						SELECT correlationid
							, @process_id
							, 'Error'
							, [message]
							, @out_msg response_msg_detail
							, @sql request_msg_detail
							, @interface_id
						FROM OPENJSON(@out_msg)
						WITH (
							[errors] NVARCHAR(MAX) '$.errors' AS JSON
						) a
						CROSS APPLY OPENJSON(a.[errors])
						WITH (
							correlationId INT,
							[message] VARCHAR(50),
							parameterName VARCHAR(25)
						) b
					END
					ELSE
					BEGIN 
						INSERT INTO remote_service_response_log (generic_obj_id, process_id, response_status, response_message, response_msg_detail, request_msg_detail, export_web_service_id)
						SELECT [requestCorrelationId]
							, @process_id
							, 'Success'
							, 'Success'
							, @out_msg response_msg_detail
							, @sql request_msg_detail
							, @interface_id 
							FROM OPENJSON(@out_msg)
						WITH (
							[requestCorrelationId] INT '$.requestCorrelationId' ,
							[transferId] INT '$.transferId' ,
							[remainingCertificateSerialNumberRange] VARCHAR(100) '$.remainingCertificateSerialNumberRange',
							[resultCodes] VARCHAR(50) '$.resultCodes'
						) a
			
					END					
				END
				ELSE 
				BEGIN
					INSERT INTO remote_service_response_log (generic_obj_id, process_id, response_status, response_message, response_msg_detail, request_msg_detail, export_web_service_id)
					SELECT row_id, @process_id, 'Error', @out_msg, @out_msg, @sql, @interface_id FROM #rec_info
				END
				UPDATE mhdi
				SET transfer_status = IIF(rsrl.response_status <> 'success', 112101, 112103)  --112103 Transfered
				FROM matching_header_detail_info mhdi
				INNER JOIN remote_service_response_log rsrl ON rsrl.generic_obj_id = mhdi.id 
				AND rsrl.process_id = @process_id

				SELECT @sql = NULL
			END
		END
	FETCH NEXT
	FROM @cur_transfer_recs INTO @link_id
	END
	CLOSE @cur_transfer_recs
	DEALLOCATE @cur_transfer_recs	
	-- END cursor					

	INSERT INTO remote_service_response_log (generic_obj_id, process_id, response_status, response_message, export_web_service_id)
	SELECT match_info_id, 
		@process_id, 
		'Error',
		val_message,
		@interface_id
	FROM #validate_links

	INSERT INTO remote_service_response_log (generic_obj_id, process_id, response_status, response_message, export_web_service_id)
	SELECT match_info_id, 
		@process_id, 
		'Error',
		'Link ID ' + CAST(link_id AS VARCHAR(10)) + ' is dependent on Link ID '  + CAST(dependent_link_id AS VARCHAR(10)),
		@interface_id
	FROM #dependent_links

	INSERT INTO remote_service_response_log (generic_obj_id, process_id, response_status, response_message, export_web_service_id)
		SELECT match_info_id, 
		@process_id, 
		'Error',
		'Certificate not available',
		@interface_id
	FROM #certificate_less_links		

	INSERT INTO source_system_data_import_status (
		process_id
		, code
		, module
		, [source]
		, [type]
		, [description]
		, recommendation
	)
	SELECT DISTINCT @process_id, 
		IIF(response_message = 'Success', 'Success', 'Error'), 
		'Export RECs', 
		'Transfer RECs', 
		IIF(response_message ='Success', '', 'Data Error'),
		response_message + IIF(CHARINDEX('Link ID', response_message) = 0, ' for Link ID ' + CAST(mhdi.link_id AS VARCHAR(10)), ''),
		IIF(response_message ='Success', '', 'Please check your data.')
	FROM remote_service_response_log rsrl
	INNER JOIN matching_header_detail_info mhdi ON mhdi.id = rsrl.generic_obj_id
	WHERE process_id = @process_id
			
	DECLARE @url  VARCHAR(MAX), @desc VARCHAR(MAX), @error_exists CHAR(1)
	 
	IF EXISTS (SELECT 1 FROM source_system_data_import_status WHERE process_id = @process_id AND code = 'Error')
	BEGIN
		SET @error_exists = 'y'
	END

	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id +''''
 	SELECT @desc = '<a target="_blank" href="' + @url + '">Links have been exported.' + IIF (@error_exists = 'y', '<font color="red">(Errors Found).</font>','') + '<br/></a>' 

	EXEC spa_message_board 'u', @user_login_id,  NULL, 'Export Data', @desc, '', '', 'e',  NULL, NULL, @process_id, '', '', '', 'n'
END
ELSE IF @operation_type = 'locus_energy_volume'
BEGIN
	BEGIN TRY
		EXEC('CREATE TABLE ' + @process_table + '(
			[volume] NUMERIC(28,4),	
			[id] VARCHAR(100),
			[start_time] DATETIME,
			[end_time] DATETIME
		)')

		SET @sql = '
			INSERT INTO  ' + @process_table + ' (volume, id, start_time)
			SELECT b.Wh_sum, b.id, CAST(b.ts AS DATE)
			FROM OPENJSON(''' + @web_response + ''')
			WITH (
				[data] NVARCHAR(MAX) ''$.data'' AS JSON
			) a
			CROSS APPLY OPENJSON(a.[data])
			WITH (
				Wh_sum NUMERIC(38,4),
				id INT,
				ts NVARCHAR(25)
			) b
			
			UPDATE ' + @process_table + ' SET end_time = EOMONTH(start_time)'			
		EXEC (@sql)
		EXEC spa_ErrorHandler 0,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Success',
			'Data inserted in Process table successfully.',
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Error',
			'Failed to insert data in Process table.',
			''
	END CATCH
END
ELSE IF @operation_type = 'nepool_trans_positions'
BEGIN
	BEGIN TRY
		EXEC('CREATE TABLE ' + @process_table + '(
			[ahId] INT,	
			[unitId] VARCHAR(100),
			[generatorName] VARCHAR(100),
			[jurisdiction] VARCHAR(10),
			[fuelType] VARCHAR(100),
			[vintageYear] INT,
			[vintageMonth] INT,
			[certificateSerialNumberRange] VARCHAR(100),
			[quantity] INT,
			[eligibilities] VARCHAR(100),
			[previousOwner] VARCHAR(100)
		)')

		SET @sql = ' INSERT INTO ' + @process_table + ' (
				[ahId], 
				[unitId], 
				[generatorName], 
				[jurisdiction], 
				[fuelType], 
				[vintageYear], 
				[vintageMonth], 
				[certificateSerialNumberRange],
				[quantity], 
				[eligibilities], 
				[previousOwner]
			)
			SELECT a.[ahId], 
				a.[unitId], 
				a.[generatorName], 
				a.[jurisdiction], 
				a.[fuelType], 
				b.[year], 
				b.[month], 
				a.[certificateSerialNumberRange],
				a.[quantity], 
				c.[value][eligibilities], 
				a.[previousOwner]
			FROM OPENJSON(''' + @web_response + ''')
			WITH (
				[ahId] INT ''$.ahId'' ,
				[unitId] VARCHAR(100) ''$.unitId'' ,
				[generatorName] VARCHAR(100) ''$.generatorName'' ,
				[jurisdiction] VARCHAR(10) ''$.jurisdiction'' ,
				[fuelType] VARCHAR(100) ''$.fuelType'' ,
				[vintage] NVARCHAR(MAX) ''$.vintage'' AS JSON,
				[certificateSerialNumberRange] VARCHAR(100) ''$.certificateSerialNumberRange'' ,
				[quantity] INT ''$.quantity'' ,
				[eligibilities] NVARCHAR(MAX) ''$.eligibilities'' AS JSON,
				[previousOwner] VARCHAR(100) ''$.previousOwner'' 
			) a
			CROSS APPLY OPENJSON(a.[vintage])
			WITH (
				[year] INT,
				[month] INT
			) b
			CROSS APPLY OPENJSON(a.[eligibilities]) c
			'			
		EXEC (@sql)
		EXEC spa_ErrorHandler 0,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Success',
			'Data inserted in Process table successfully.',
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Error',
			'Failed to insert data in Process table.',
			''
	END CATCH
END
ELSE IF @operation_type = 'power_track_volume'
BEGIN
	BEGIN TRY
		EXEC('CREATE TABLE ' + @process_table + '(
			[hardware_id] INT,	
			[field_name] VARCHAR(100),
			[units] VARCHAR(20),
			[timestamp] VARCHAR(100),
			[value] NUMERIC(38,4)
		)')

		IF OBJECT_ID('tempdb..#info') IS NOT NULL
			DROP TABLE #info
	
		CREATE TABLE #info (
			hardwareId INT,
			id INT,
			[name] VARCHAR(25) COLLATE DATABASE_DEFAULT,
			units VARCHAR(25) COLLATE DATABASE_DEFAULT
		)

		IF OBJECT_ID('tempdb..#items') IS NOT NULL
			DROP TABLE #items
	
		CREATE TABLE #items (
			id INT,
			[timestamp] VARCHAR(20) COLLATE DATABASE_DEFAULT,
			[value] NUMERIC(38,20)
		)

		SET @sql = ' 
			INSERT INTO #info
			SELECT b.hardwareId, b.dataIndex+1 id, b.[name], b.units
			FROM OPENJSON(''' + @web_response + ''')
			WITH (
				[info] NVARCHAR(MAX) ''$.info'' AS JSON,
				[items] NVARCHAR(MAX) ''$.items'' AS JSON
			) a
			CROSS APPLY OPENJSON(a.[info])
			WITH (
				hardwareId INT,
				dataIndex INT,
				[name] NVARCHAR(25),
				units NVARCHAR(25)
			) b
		
			INSERT INTO #items 
			SELECT ROW_NUMBER() OVER (
				  PARTITION BY c.[timestamp]
				  ORDER BY c.[timestamp]) id,  CAST(c.[timestamp] AS DATE) [timestamp], d.[value]
			FROM OPENJSON(''' + @web_response + ''')
			WITH (
				[items] NVARCHAR(MAX) ''$.items'' AS JSON
			) a
			OUTER APPLY OPENJSON(a.[items])
			WITH (
				[timestamp] NVARCHAR(50),
				[data] NVARCHAR(MAX) ''$.data'' AS JSON
			) c
			CROSS APPLY OPENJSON(c.[data]) d
					
			INSERT INTO ' + @process_table + ' (
				[hardware_id],	
				[field_name],
				[units],
				[timestamp],
				[value]
			)
			SELECT i.hardwareid, [name], units, [timestamp], [value] 
			FROM #info i 
			INNER JOIN #items t ON i.id = t.id
		'	
		EXEC (@sql)
		EXEC spa_ErrorHandler 0,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Success',
			'Data inserted in Process table successfully.',
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
			'Insert in Process table.',
			'spa_process_rec_api_info',
			'Error',
			'Failed to insert data in Process table.',
			''
	END CATCH
END
ELSE IF @operation_type = 'build_powertrack_request'
BEGIN	
	DECLARE @request_body VARCHAR(MAX)

	SELECT @request_body = [request_body]
	FROM ixp_import_data_source iids
	INNER JOIN import_web_service iws
		ON iids.clr_function_id = iws.clr_function_id
	WHERE rules_id = @rules_id
		
	SELECT @sql = COALESCE(@sql + ',', '') + REPLACE(REPLACE(REPLACE(@request_body, '<__hw_id__>', hardware_id), '<__site_id__>',site_id), '<__field_name__>', 'KWHnet')
	FROM udt_also_energy_site_hardware_mapping udt
	INNER JOIN dbo.SplitCommaSeperatedValues(@site_id) a ON a.item = udt.site_id

	SELECT '[' + @sql + ']' request_sample	
	RETURN
END
