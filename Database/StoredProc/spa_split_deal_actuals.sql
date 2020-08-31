 IF OBJECT_ID(N'[dbo].[spa_split_deal_actuals]', N'P') IS NOT NULL
     DROP PROCEDURE [dbo].[spa_split_deal_actuals]
 GO
  
 SET ANSI_NULLS ON
 GO
  
 SET QUOTED_IDENTIFIER ON
 GO
  
-- ===============================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2015-02-08
-- Description: 
 
-- Params:
-- @flag CHAR(1)        - Description of param2

-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_split_deal_actuals]
	@flag CHAR(1),
	@split_deal_actuals_id VARCHAR(2000) = NULL,
	@schedule_match_id VARCHAR(1000) = NULL,
	@form_xml VARCHAR(MAX) = NULL,
	@grid_xml VARCHAR(MAX) = NULL,
	@filter_xml VARCHAR(MAX) = NULL,
	@ticket_match_xml VARCHAR(MAX) = NULL
AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @sql VARCHAR(MAX)
	DECLARE @idoc INT
	DECLARE @match_id VARCHAR(1000)
	
	CREATE TABLE #temp_split_deal_actuals (
		split_deal_actuals_id INT
		,ticket_number	VARCHAR(200) COLLATE DATABASE_DEFAULT
		,schedule_match_id	INT
		,line_item		INT
		,ticket_issuer	INT
		,date_issued	DATETIME
		,product_commodity	INT
		,location_id	INT
		,term_start	DATETIME
		,term_end	DATETIME
		,movement_date_time	DATETIME
		,automatch_status	CHAR(1) COLLATE DATABASE_DEFAULT
		,carrier	INT
		,shipper	INT
		,consginee	INT
		,ticket_type	INT
		,vehicle_number	VARCHAR(200) COLLATE DATABASE_DEFAULT
		,ticket_matching_no	INT
		,origin	INT
		,destination	INT
		,temperature	FLOAT
		,temp_scale_f_c	CHAR(1)
		,api_gravity	FLOAT
		,specific_gravity	FLOAT
		,density	FLOAT
		,density_uom	INT
		,gross_volume	VARCHAR(50) COLLATE DATABASE_DEFAULT
		,net_volume	VARCHAR(50) COLLATE DATABASE_DEFAULT
		,volume_uom	INT
		,gross_weight	FLOAT
		,net_weight	FLOAT
		,weight_uom	INT
		,bsw NUMERIC(38, 20)
		,lease_measurement INT
	)

	CREATE TABLE #ticket_match (
		match_id INT,
		ticket_id INT
	)

	CREATE TABLE #ticket_quality (
		id INT,
		split_deal_actuals_id INT,
		quality INT,
		value VARCHAR(50) COLLATE DATABASE_DEFAULT,
		company INT,
		is_average CHAR(1) COLLATE DATABASE_DEFAULT
	)

	CREATE TABLE #ticket_event (
		id INT,
		split_deal_actuals_id INT,
		event_type INT,
		event_date DATETIME
	)
		
	CREATE TABLE #filter_xml_data (		
		row_id INT IDENTITY(1, 1), 
		commodity_group VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
		commodity_id VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
		period_from DATETIME, 
		period_to DATETIME,	
		ticket_issuer VARCHAR(200) COLLATE DATABASE_DEFAULT,
		location_group VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
		location VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
		quantity_uom VARCHAR(5000) COLLATE DATABASE_DEFAULT, 
		frequency VARCHAR(10) COLLATE DATABASE_DEFAULT,
		price_uom VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		deal_type VARCHAR(500) COLLATE DATABASE_DEFAULT,
		ticket_number VARCHAR(10) COLLATE DATABASE_DEFAULT,
		match_number VARCHAR(10) COLLATE DATABASE_DEFAULT,
		show_match_ticket char(1) COLLATE DATABASE_DEFAULT,
		match_status char(1) COLLATE DATABASE_DEFAULT
	)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @filter_xml

	INSERT INTO #filter_xml_data(
									commodity_id, 
									deal_type, 
									period_from, 
									period_to, 
									ticket_issuer,
									location_group, 
									location, 
									quantity_uom, 
									frequency,
									price_uom, 
									commodity_group,
									ticket_number,
									match_number, 
									show_match_ticket, 
									match_status
								)
	SELECT 
		NULLIF(commodity, ''), 
		NULLIF(deal_type, ''), 
		NULLIF(period_from, ''), 
		NULLIF(period_to, ''), 
		NULLIF(ticket_issuer, ''),
		NULLIF(location_group, ''), 
		NULLIF(location, ''), 
		NULLIF(quantity_uom, ''), 
		NULLIF(frequency, ''), 
		NULLIF(price_uom, ''), 
		NULLIF(commodity_group, ''), 
		NULLIF(ticket_number, ''), 
		NULLIF(match_number, ''),
		NULLIF(show_match_ticket, ''), 
		NULLIF(match_status, '')
	FROM   OPENXML (@idoc, '/Root/FormFilterXML', 2)
		WITH ( 
			commodity		VARCHAR(5000)	'@commodity_id',						
			deal_type		VARCHAR(500)	'@deal_type', 
			period_from		DATETIME		'@period_from',
			period_to		DATETIME		'@period_to',
			ticket_issuer   VARCHAR(200)	'@ticket_issuer',
			location_group	VARCHAR(5000)	'@location_group',
			location		VARCHAR(5000)	'@location',
			quantity_uom	VARCHAR(5000)	'@quantity_uom',
			frequency		VARCHAR(5000)	'@frequency',
			price_uom		VARCHAR(5000)	'@price_uom',
			commodity_group VARCHAR(5000)	'@commodity_group',
			ticket_number   VARCHAR(10)		'@ticket_number',
			match_number	VARCHAR(10)		'@match_number',
			show_match_ticket    VARCHAR(10)'@show_match_ticket',
			match_status	VARCHAR(10)		'@match_status'
			)

		EXEC sp_xml_removedocument @idoc

		DECLARE @commodity			VARCHAR(500)
		DECLARE @deal_type			VARCHAR(500)	
		DECLARE @location_group		VARCHAR(500)
		DECLARE @location			VARCHAR(500)
		DECLARE @quantity_uom		VARCHAR(500)
		DECLARE @quantity_uom_name	VARCHAR(100)
		DECLARE @frequency			VARCHAR(10)
		DECLARE @price_uom			VARCHAR(500)
		DECLARE @commodity_group	VARCHAR(500)
		DECLARE @ticket_number		VARCHAR(10)
		DECLARE @ticket_issuer		VARCHAR(200)
		DECLARE @match_number		VARCHAR(10)
		DECLARE @show_match_ticket	VARCHAR(10)
		DECLARE @match_status		VARCHAR(10)
		DECLARE @period_from		DATETIME
		DECLARE @period_to			DATETIME

		SELECT  @commodity = commodity_id,
				@deal_type = deal_type,
				@location_group = location_group,
				@location = location,
				@quantity_uom = quantity_uom,
				@frequency = frequency,
				@price_uom = price_uom,
				@period_from = period_from,
				@period_to = period_to,
				@commodity_group = commodity_group,
				@ticket_number = ticket_number,
				@ticket_issuer = ticket_issuer,
				@match_number = match_number,
				@show_match_ticket = show_match_ticket,
				@match_status = match_status		
		FROM #filter_xml_data

SELECT @quantity_uom_name = uom_name 
FROM source_uom 
WHERE source_uom_id = @quantity_uom

/* filters end */

	IF @flag IN('t', 'o')
	BEGIN
		SET @sql = 
					'
					
					SELECT from_source_uom_id, to_source_uom_id, conversion_factor 	
						INTO #calculated_unit_conversion
					FROM rec_volume_unit_conversion 
					WHERE to_source_uom_id = ' + CAST(ISNULL(@quantity_uom, -1) AS VARCHAR(10)) + '
					UNION ALL 
					SELECT to_source_uom_id, from_source_uom_id, 1/conversion_factor 
					FROM rec_volume_unit_conversion 
					WHERE from_source_uom_id = ' + CAST(ISNULL(@quantity_uom, -1) AS VARCHAR(10)) + '					
				
					SELECT sda.split_deal_actuals_id
						,MAX(ticket_number) ticket_number
						,MAX(line_item) line_item
						,MAX(scpt.counterparty_name) ticket_issuer
						,MAX(dbo.FNADateTimeFormat(sda.movement_date_time, '''')) movement_date_time
						,MAX(dbo.FNADateFormat(sda.date_issued)) date_issued
						,MAX(sml.Location_Name) Location_Name
						,MAX(sc.commodity_name) commodity_name'
		
		IF @frequency = 700 
		BEGIN
			SET @sql =	@sql +
						',MAX(dbo.FNARemoveTrailingZeroes(ROUND((sda.gross_volume * ISNULL(cuc.conversion_factor, 1))/dbo.FNARDaysInMnth(movement_date_time), 4))) gross_volume
						,MAX(dbo.FNARemoveTrailingZeroes(ROUND((sda.net_volume * ISNULL(cuc.conversion_factor, 1))/dbo.FNARDaysInMnth(movement_date_time), 4))) net_volume'
		END
		ELSE 
		BEGIN
			SET @sql =	@sql +
						',MAX(dbo.FNARemoveTrailingZeroes(sda.gross_volume * ISNULL(cuc.conversion_factor, 1))) gross_volume
						,MAX(dbo.FNARemoveTrailingZeroes(sda.net_volume * ISNULL(cuc.conversion_factor, 1))) net_volume'

			
		END

		SET @sql =	@sql +
						'
						,MAX(CASE WHEN cuc.conversion_factor IS NULL THEN su.uom_name ELSE ''' + @quantity_uom_name + ''' END)	uom_name
						,MAX(sdvtt.code) ticket_type
						,LEFT(match_ids, LEN(match_ids ) - 1) match_id
						,MAX(sml_o.location_name) orgin
						,MAX(sml_d.location_name) destination
						,MAX(dbo.FNADateFormat(sda.term_start)) term_start 
						,MAX(dbo.FNADateFormat(sda.term_end)) term_end		 	 
					FROM split_deal_actuals sda
						LEFT JOIN source_uom su
							ON su.source_uom_id = sda.volume_uom
						LEFT JOIN static_data_value sdvtt
							ON sdvtt.type_id = 39200
							AND sdvtt.value_id = sda.ticket_type
						LEFT JOIN source_minor_location sml
							ON sda.location_id = sml.source_minor_location_id
						--LEFT JOIN source_major_location smjl
						--	ON smjl.source_major_location_id  = sml.source_major_location_id
						LEFT JOIN source_commodity sc 
							ON sc.source_commodity_id = sda.product_commodity 
						LEFT JOIN #calculated_unit_conversion cuc	
							ON cuc.from_source_uom_id = sda.volume_uom
						LEFT JOIN source_minor_location sml_o
							ON sda.origin = sml_o.source_minor_location_id
						LEFT JOIN source_minor_location sml_d
							ON sda.destination = sml_d.source_minor_location_id
						' 
				
			IF @flag = 'o'
			BEGIN
				SET @sql =	@sql +
							' INNER JOIN actual_match am1
						 		ON  am1.split_deal_actuals_id = sda.split_deal_actuals_id   '
			END 
			
			SET @sql =	@sql + 		
						' LEFT JOIN source_counterparty  scpt
							ON scpt.source_counterparty_id = sda.ticket_issuer
						CROSS APPLY
						(
							SELECT bookout_id + '', '' 
							FROM deal_volume_split AS dvs
								LEFT JOIN actual_match am
									ON  am.split_deal_actuals_id = sda.split_deal_actuals_id	
							WHERE dvs.deal_volume_split_id = am.deal_volume_split_id
							FOR XML PATH('''')
						) m (match_ids)	
						'		
					+ CASE WHEN @location_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @location_group + ''', '','')) loc_group ON loc_group.item = sml.region ' ELSE '' END 
					+ CASE WHEN @location IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @location + ''', '','')) location ON location.item = sda.location_id ' ELSE '' END 
					+ CASE WHEN @commodity_group IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity_group + ''', '','')) commodity_group ON commodity_group.item = sc.commodity_group1 '  ELSE '' END 
					+ CASE WHEN @commodity IS NOT NULL THEN ' INNER JOIN (SELECT item FROM dbo.FNASplit(''' + @commodity + ''', '','')) commodity ON commodity.item = sda.product_commodity '  ELSE '' END 
					
		 SET @sql = @sql + ' WHERE 1 = 1 '
		 
		 SET @sql = @sql + CASE WHEN @ticket_number IS NOT NULL THEN ' AND ticket_number LIKE ''' + @ticket_number + '''' ELSE '' END
		 SET @sql = @sql + CASE WHEN @ticket_issuer IS NOT NULL THEN ' AND sda.ticket_issuer IN ( ' + @ticket_issuer + ')' ELSE '' END
		 
		 SET @sql = @sql + CASE WHEN @period_from IS NOT NULL THEN ' AND CAST(sda.movement_date_time AS DATE) >= ''' + CAST(dbo.FNAGetSQLStandardDate(@period_from) AS VARCHAR(10)) + '''' ELSE '' END
		 
		 IF @schedule_match_id IS NULL 
		 BEGIN
			 SET @sql = @sql + CASE WHEN @period_to IS NOT NULL THEN ' AND  CAST(sda.movement_date_time AS DATE) <= ''' + CAST(dbo.FNAGetSQLStandardDate(@period_to) AS VARCHAR(10)) + '''' ELSE '' END
			 SET @sql = @sql + CASE ISNULL(@show_match_ticket, 'u') WHEN  'b' THEN '' WHEN 'm' THEN ' AND match_ids IS NOT NULL ' ELSE ' AND match_ids IS  NULL ' END
		END	 			
		IF @schedule_match_id IS NOT NULL 
			SET @sql = @sql + ' AND am1.deal_volume_split_id = ' + CAST(@schedule_match_id AS VARCHAR(10))
		
		SET @sql = @sql + ' GROUP BY sda.split_deal_actuals_id, match_ids ORDER BY ticket_number '

		EXEC spa_print @sql 
		
		EXEC(@sql)

	END
	ELSE IF @flag = 'm'
	BEGIN
		SELECT  max(mgd.match_number) match_number, (sda.ticket_number) ticket_number, deal_volume_split_id ID, max(sml.Location_Name) location, max(sc.commodity_name) commodity
		FROM deal_volume_split dvs
			INNER JOIN match_group_detail mgd
				ON dvs.deal_volume_split_id = mgd.split_id
			INNER JOIN source_minor_location sml
				ON sml.source_minor_location_id = mgd.location
			INNER JOIN source_commodity sc
				ON sc.source_commodity_id = mgd.source_commodity_id	
			LEFT JOIN split_deal_actuals sda 
				ON sda.schedule_match_id = dvs.deal_volume_split_id
		group by deal_volume_split_id, sda.ticket_number
	END
	ELSE IF @flag = 'l'
	BEGIN
		BEGIN TRY
			BEGIN TRAN
			EXEC sp_xml_preparedocument @idoc OUTPUT, @ticket_match_xml

			INSERT INTO #ticket_match
			SELECT 
				match_id, 
				NULLIF(ticket_id, '')
			FROM   OPENXML (@idoc, '/Root/match/ticket', 2)
			WITH ( 
					match_id	VARCHAR(10)	'../@match_id',						
					ticket_id	VARCHAR(10)	'@ticket_id'
				)
		
			EXEC sp_xml_removedocument @idoc

			DELETE am 
			FROM actual_match  am
			INNER JOIN #ticket_match tm
				ON tm.match_id = am.deal_volume_split_id		
		
			INSERT INTO actual_match (
										split_deal_actuals_id
										,deal_volume_split_id
									)
			SELECT tm.ticket_id, tm.match_id	
			FROM #ticket_match tm
			
			WHERE tm.ticket_id IS NOT NULL

			SELECT @match_id = ISNULL(@match_id + ',', '') +  CAST( match_id AS VARCHAR(10)) 
			FROM (SELECT DISTINCT match_id FROM #ticket_match ) a
		
			EXEC spa_split_deal_actuals 'q', NULL, @match_id
			
			DECLARE @alert_process_table VARCHAR(300), @jobs_process_id VARCHAR(200) = dbo.FNAGETNewID()
			SET @alert_process_table = 'adiha_process.dbo.alert_deal_' + @jobs_process_id + '_ad'
						
			EXEC ('CREATE TABLE ' + @alert_process_table + '(
					source_deal_header_id VARCHAR(50),
					source_deal_detail_id VARCHAR(50),
					split_deal_actuals_id VARCHAR(50),
					hyperlink1            VARCHAR(5000),
					hyperlink2            VARCHAR(5000),
					hyperlink3            VARCHAR(5000),
					hyperlink4            VARCHAR(5000),
					hyperlink5            VARCHAR(5000)
					)')
			
			EXEC('
				INSERT INTO ' + @alert_process_table + ' (source_deal_header_id, source_deal_detail_id, split_deal_actuals_id)
				SELECT sdd.source_deal_header_id, mgd.source_deal_detail_id, sda.split_deal_actuals_id
				FROM actual_match am  
				INNER JOIN split_deal_actuals sda ON sda.split_deal_actuals_id = am.split_deal_actuals_id
				INNER JOIN match_group_detail mgd ON mgd.split_id = am.deal_volume_split_id
				INNER JOIN source_deal_detail sdd ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
				INNER JOIN dbo.SplitCommaSeperatedValues(''' + @match_id + ''') m ON am.deal_volume_split_id = m.item
			')
			
			SET @sql = 'spa_register_event 20601, 20524, ''' + @alert_process_table + ''', 1, ''' + @jobs_process_id + ''''
			exec spa_print @sql
			EXEC(@sql)
			
			COMMIT
			EXEC spa_ErrorHandler 0, 'Actualize Schedule', 
 						'spa_split_deal_actuals', 'Success', 
 						'Changes have been saved successfully.', ''
		END TRY
		BEGIN CATCH 
			IF @@TRANCOUNT > 0
				ROLLBACK
			
			EXEC spa_ErrorHandler @@ERROR, 'Actualize Schedule', 
 						'spa_split_deal_actuals', 'DB Error', 
 						'Error Saving data.', ''
			
		END CATCH
	--alert			
	END
	ELSE IF @flag IN ('i', 'u')
	BEGIN	
		BEGIN TRY
			BEGIN TRAN
			EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml

			INSERT INTO #temp_split_deal_actuals(
					split_deal_actuals_id 
					,ticket_number
					,schedule_match_id
					,line_item
					,ticket_issuer
					,date_issued
					,product_commodity
					,location_id
					,term_start
					,term_end
					,movement_date_time
					,automatch_status
					,carrier
					,shipper
					,consginee
					,ticket_type
					,vehicle_number
					,ticket_matching_no
					,origin
					,destination
					,temperature
					,temp_scale_f_c
					,api_gravity
					,specific_gravity
					,density
					,density_uom
					,gross_volume
					,net_volume
					,volume_uom
					,gross_weight
					,net_weight
					,weight_uom
					,bsw
					,lease_measurement
				)
			SELECT 
				NULLIF(split_deal_actuals_id, '')
				,NULLIF(ticket_number, '')
				,NULLIF(schedule_match_id, '')
				,NULLIF(line_item, '')
				,NULLIF(ticket_issuer, '')
				,NULLIF(date_issued, '')
				,NULLIF(product_commodity, '')
				,NULLIF(location_id, '')
				,NULLIF(term_start, '')
				,NULLIF(term_end, '')
				,NULLIF(movement_date_time, '')
				,NULLIF(automatch_status, '')
				,NULLIF(carrier, '')
				,NULLIF(shipper, '')
				,NULLIF(consginee, '')
				,NULLIF(ticket_type, '')
				,NULLIF(vehicle_number, '')
				,NULLIF(ticket_matching_no, '')
				,NULLIF(origin, '')
				,NULLIF(destination, '')
				,NULLIF(temperature, '')
				,NULLIF(temp_scale_f_c, '')
				,NULLIF(api_gravity, '')
				,NULLIF(specific_gravity, '')
				,NULLIF(density, '')
				,NULLIF(density_uom, '')
				,NULLIF(gross_volume, '')
				,NULLIF(net_volume, '')
				,NULLIF(volume_uom, '')
				,NULLIF(gross_weight, '')
				,NULLIF(net_weight, '')
				,NULLIF(weight_uom, '')
				,NULLIF(bsw, '')
				,NULLIF(lease_measurement, '')
			FROM   OPENXML (@idoc, '/Root/FormXML', 2)
				WITH ( 
					split_deal_actuals_id		VARCHAR(20)	 '@split_deal_actuals_id'
					,ticket_number				VARCHAR(200) '@ticket_number'
					,schedule_match_id			VARCHAR(20)	 '@schedule_match_id'
					,line_item					VARCHAR(20)	 '@line_item'
					,ticket_issuer				VARCHAR(20)	 '@ticket_issuer'
					,date_issued				DATETIME     '@date_issued'
					,product_commodity			VARCHAR(20)	 '@product_commodity'
					,location_id				VARCHAR(20)	 '@location_id'
					,term_start					DATETIME     '@term_start'
					,term_end					DATETIME	 '@term_end'
					,movement_date_time			DATETIME	 '@movement_date_time'
					,automatch_status			VARCHAR(1)	 '@automatch_status'
					,carrier					VARCHAR(20)	 '@carrier'
					,shipper					VARCHAR(20)	 '@shipper'
					,consginee					VARCHAR(20)	 '@consginee'
					,ticket_type				VARCHAR(20)	 '@ticket_type'
					,vehicle_number				VARCHAR(200) '@vehicle_number'
					,ticket_matching_no			VARCHAR(20)  '@ticket_matching_no'
					,origin						VARCHAR(20)  '@origin'
					,destination				VARCHAR(20)  '@destination'
					,temperature				VARCHAR(50)  '@temperature'
					,temp_scale_f_c				VARCHAR(1)   '@temp_scale_f_c'
					,api_gravity				VARCHAR(50)  '@api_gravity'
					,specific_gravity			VARCHAR(50)  '@specific_gravity'
					,density					VARCHAR(50)  '@density'
					,density_uom				VARCHAR(20)  '@density_uom'
					,gross_volume				VARCHAR(50)  '@gross_volume'
					,net_volume					VARCHAR(50)  '@net_volume'
					,volume_uom					VARCHAR(20)  '@volume_uom'
					,gross_weight				VARCHAR(50)  '@gross_weight'
					,net_weight					VARCHAR(50)  '@net_weight'
					,weight_uom					VARCHAR(20)  '@weight_uom'
					,bsw						VARCHAR(20)  '@bsw'
					,lease_measurement			VARCHAR(20)  '@lease_measurement'
				)

			EXEC sp_xml_removedocument @idoc


			IF @flag = 'i' 
			BEGIN

				DECLARE @line_item INT;
				
				SET @line_item = 1;

				IF EXISTS (SELECT 1 
							FROM #temp_split_deal_actuals tsda 
								INNER JOIN split_deal_actuals sda 
									ON tsda.ticket_number = sda.ticket_number
									AND tsda.ticket_issuer = sda.ticket_issuer
									AND YEAR(tsda.date_issued) = sda.issued_year)
				BEGIN
					SELECT @line_item = MAX(sda.line_item) + 1 
							FROM #temp_split_deal_actuals tsda 
								INNER JOIN split_deal_actuals sda 
									ON tsda.ticket_number = sda.ticket_number
									AND tsda.ticket_issuer = sda.ticket_issuer
									AND YEAR(tsda.date_issued) = sda.issued_year
				END
			
				INSERT INTO split_deal_actuals (
					ticket_number
					,schedule_match_id
					,line_item
					,ticket_issuer
					,date_issued
					,product_commodity
					,location_id
					,term_start
					,term_end
					,movement_date_time
					,automatch_status
					,carrier
					,shipper
					,consginee
					,ticket_type
					,vehicle_number
					,ticket_matching_no
					,origin
					,destination
					,temperature
					,temp_scale_f_c
					,api_gravity
					,specific_gravity
					,density
					,density_uom
					,gross_volume
					,net_volume
					,volume_uom
					,gross_weight
					,net_weight
					,weight_uom
					,issued_year	
					,bsw
					,lease_measurement	
				)
				SELECT
					ticket_number
					,schedule_match_id
					,@line_item
					,ticket_issuer
					,date_issued
					,product_commodity
					,location_id
					,term_start
					,term_end
					,movement_date_time
					,automatch_status
					,carrier
					,shipper
					,consginee
					,ticket_type
					,vehicle_number
					,ticket_matching_no
					,ISNULL(origin, location_id)
					,ISNULL(destination, location_id) 
					,temperature
					,temp_scale_f_c
					,api_gravity
					,specific_gravity
					,density
					,density_uom
					,gross_volume
					,net_volume
					,volume_uom
					,gross_weight
					,net_weight
					,weight_uom
					,YEAR(date_issued)
					,bsw
					,lease_measurement	
				FROM #temp_split_deal_actuals

				IF EXISTS(SELECT 1 FROM #temp_split_deal_actuals WHERE schedule_match_id IS NOT NULL) 
				BEGIN
					INSERT INTO actual_match (
										split_deal_actuals_id
										,deal_volume_split_id
									)
					SELECT IDENT_CURRENT('split_deal_actuals'), schedule_match_id
					FROM #temp_split_deal_actuals 
				END 
			END
			ELSE 
			BEGIN
				UPDATE  sda
				SET 	
					sda.ticket_number = tsda.ticket_number
					,sda.schedule_match_id = tsda.schedule_match_id
					,sda.line_item = tsda.line_item
					,sda.ticket_issuer = tsda.ticket_issuer
					,sda.date_issued = tsda.date_issued
					,sda.product_commodity = tsda.product_commodity
					,sda.location_id = tsda.location_id
					,sda.term_start = tsda.term_start
					,sda.term_end = tsda.term_end
					,sda.movement_date_time = tsda.movement_date_time
					,sda.automatch_status = tsda.automatch_status
					,sda.carrier = tsda.carrier
					,sda.shipper = tsda.shipper
					,sda.consginee = tsda.consginee
					,sda.ticket_type = tsda.ticket_type
					,sda.vehicle_number = tsda.vehicle_number
					,sda.ticket_matching_no = tsda.ticket_matching_no
					,sda.origin = ISNULL(tsda.origin, tsda.location_id) 
					,sda.destination = ISNULL(tsda.destination, tsda.location_id)  
					,sda.temperature = tsda.temperature
					,sda.temp_scale_f_c = tsda.temp_scale_f_c
					,sda.api_gravity = tsda.api_gravity
					,sda.specific_gravity = tsda.specific_gravity
					,sda.density = tsda.density
					,sda.density_uom = tsda.density_uom
					,sda.gross_volume = tsda.gross_volume
					,sda.net_volume = tsda.net_volume
					,sda.volume_uom = tsda.volume_uom
					,sda.gross_weight = tsda.gross_weight
					,sda.net_weight = tsda.net_weight
					,sda.weight_uom = tsda.weight_uom
					,sda.issued_year = YEAR(tsda.date_issued)
					,bsw = tsda.bsw
					,lease_measurement = tsda.lease_measurement
				FROM split_deal_actuals sda
					INNER JOIN #temp_split_deal_actuals tsda
						ON sda.split_deal_actuals_id = tsda.split_deal_actuals_id		
			END
				
			EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml

			INSERT INTO #ticket_quality (
				id,
				split_deal_actuals_id,
				quality,
				value,
				company,
				is_average
			)
			SELECT 
				NULLIF(id,''),
				NULLIF(split_deal_actuals_id,''),
				NULLIF(quality,''),
				NULLIF(value,''),
				NULLIF(company, ''),
				NULLIF(is_average, '')
			FROM   OPENXML (@idoc, '/GridGroup/Grid/GridRow', 2)
				WITH ( 
					id							VARCHAR(20)	 '@deal_actual_id'
					,split_deal_actuals_id		VARCHAR(20)	 '@split_deal_actuals_id'
					,quality					VARCHAR(20)	 '@quality'
					,value						VARCHAR(50)	 '@value'
					,company					VARCHAR(20)	 '@company'
					,is_average					VARCHAR(1)	 '@is_average'
					,grid_id					VARCHAR(20)  '../@grid_id'
				)x
			WHERE x.grid_id = 'Quality'


			INSERT INTO #ticket_event (
				id,
				split_deal_actuals_id,
				event_type,
				event_date
			)
			SELECT 
				NULLIF(id,''),
				NULLIF(split_deal_actuals_id,''),
				NULLIF(event_type,''),
				NULLIF(event_date,'')
			FROM   OPENXML (@idoc, '/GridGroup/Grid/GridRow', 2)
				WITH ( 
					id							VARCHAR(20)	 '@deal_actual_event_date_id'
					,split_deal_actuals_id		VARCHAR(20)	 '@split_deal_actuals_id'
					,event_type					VARCHAR(20)	 '@event_type'
					,event_date					VARCHAR(50)	 '@event_date'
					,grid_id					VARCHAR(20)  '../@grid_id'
				)x
			WHERE x.grid_id = 'Event'

			EXEC sp_xml_removedocument @idoc
		
					
			IF NULLIF(@split_deal_actuals_id, '') IS NULL
			BEGIN
				INSERT INTO deal_actual_quality (
					split_deal_actuals_id,
					quality,
					value,
					company,
					is_average
				)
				SELECT IDENT_CURRENT('split_deal_actuals')
					,quality
					,value
					,company
					,is_average
				FROM #ticket_quality

				INSERT INTO deal_actual_event_date (
					split_deal_actuals_id,
					event_type,
					event_date
				)
				SELECT IDENT_CURRENT('split_deal_actuals')
					,event_type
					,event_date
				FROM #ticket_event
			END
			ELSE 
			BEGIN

				UPDATE e 
				SET e.event_type = te.event_type
					,e.event_date = te.event_date
				FROM #ticket_event te
					INNER JOIN deal_actual_event_date e
						ON te.id = e.deal_actual_event_date_id
				WHERE te.split_deal_actuals_id IS NOT NULL

				UPDATE q
				SET q.quality = tq.quality,
					q.value = tq.value,
					q.company = tq.company,
					q.is_average = tq.is_average
				FROM #ticket_quality tq
					INNER JOIN deal_actual_quality q
						ON tq.id = q.deal_actual_id
				WHERE tq.split_deal_actuals_id IS NOT NULL

				DELETE e 
				FROM deal_actual_event_date e
				LEFT JOIN #ticket_event te
					ON te.id = e.deal_actual_event_date_id
				WHERE te.id IS NULL  AND
					 e.split_deal_actuals_id = @split_deal_actuals_id

				DELETE q 
				FROM deal_actual_quality q
				LEFT JOIN #ticket_quality tq
					ON tq.id = q.deal_actual_id
				WHERE tq.id IS NULL AND
					 q.split_deal_actuals_id = @split_deal_actuals_id

				INSERT INTO deal_actual_quality (
					split_deal_actuals_id,
					quality,
					value,
					company,
					is_average
				)
				SELECT @split_deal_actuals_id
					,quality
					,value
					,company
					,is_average
				FROM #ticket_quality
				WHERE split_deal_actuals_id IS NULL

				INSERT INTO deal_actual_event_date (
					split_deal_actuals_id,
					event_type,
					event_date
				)
				SELECT @split_deal_actuals_id
					,event_type
					,event_date
				FROM #ticket_event
				WHERE split_deal_actuals_id IS NULL
		
			END

			SET @split_deal_actuals_id = ISNULL(@split_deal_actuals_id, IDENT_CURRENT('split_deal_actuals'))

			
			SELECT @match_id = ISNULL(@match_id + ',', '') + deal_volume_split_id 
			FROM actual_match am
			WHERE split_deal_actuals_id = @split_deal_actuals_id

			EXEC spa_split_deal_actuals 'q', NULL, @match_id

			COMMIT 
 			EXEC spa_ErrorHandler 0, 'Ticket', 
 					'spa_split_deal_actuals', 'Success', 
 					'Changes have been saved successfully.', ''
		END TRY
		BEGIN CATCH 
			IF @@TRANCOUNT > 0
			   ROLLBACK
			
			DECLARE @desc VARCHAR(500) = dbo.FNAHandleDBError(10166600)
			
			EXEC spa_ErrorHandler @@ERROR, 'Ticket', 
 							'spa_split_deal_actuals', 'DB Error', 
 							@desc, ''
			
		END CATCH
	END
	ELSE IF @flag = 'd'
	BEGIN 
		DELETE sda 
		FROM split_deal_actuals sda
		INNER JOIN dbo.SplitCommaSeperatedValues(@split_deal_actuals_id) t
			ON t.item = sda.split_deal_actuals_id
		

		IF @@ERROR <> 0
		BEGIN
 				EXEC spa_ErrorHandler @@ERROR, 'Actualize Schedule', 
 						'spa_split_deal_actuals', 'DB Error', 
 						'Error Saving data.', ''
		END
		ELSE
 		BEGIN
			EXEC spa_split_deal_actuals 'q', NULL, @schedule_match_id
			
			EXEC spa_ErrorHandler 0, 'Actualize Schedule', 
 					'spa_split_deal_actuals', 'Success', 
 					'Changes have been saved successfully.', ''
		END

	END
	ELSE IF @flag = 'q' --UPDATE quality of match
	BEGIN

	IF @schedule_match_id IS NULL
		RETURN;
		
		SET @sql = '
		
				CREATE TABLE #updated_sdd (
					source_deal_detail_id INT
				)
				
				DECLARE @user_login_id VARCHAR(50)
				SET @user_login_id = dbo.FNADBUser();

				UPDATE mgd 
					SET quantity = s.sum_vol
					OUTPUT Inserted.source_deal_detail_id INTO #updated_sdd
					FROM match_group_detail mgd 
						INNER JOIN 
							(
								SELECT  mgd.source_deal_detail_id, 
								mgd.split_id, 
								SUM(CASE WHEN ISNULL(sdh.settlement_vol_type, ''n'') = ''n'' THEN sda.net_volume ELSE ISNULL(sda.gross_volume, sda.net_volume) END ) sum_vol 
								FROM match_group_detail mgd 
									LEFT JOIN actual_match am
										ON mgd.split_id = am.deal_volume_split_id
									LEFT JOIN split_deal_actuals sda
										ON sda.split_deal_actuals_id = am.split_deal_actuals_id
									LEFT JOIN source_deal_detail sdd 
										ON mgd.source_deal_detail_id = sdd.source_deal_detail_id
									LEFT JOIN source_deal_header sdh
										ON sdh.source_deal_header_id = sdd.source_deal_header_id ' 									
									+ 
								    CASE WHEN @schedule_match_id IS NOT NULL  THEN
										'INNER JOIN dbo.SplitCommaSeperatedValues(''' + @schedule_match_id + ''') m
											ON mgd.split_id = m.item' 
									ELSE ''
									END 
									+ 
									-- CASE WHEN @split_deal_actuals_id IS NOT NULL  THEN
									--	'INNER JOIN dbo.SplitCommaSeperatedValues(''' + @split_deal_actuals_id + ''') t
									--		ON am.split_deal_actuals_id = t.item' 
									--ELSE ''
									--END 
									--+
									' GROUP BY mgd.split_id, mgd.source_deal_detail_id
							) s
								ON s.split_id = mgd.split_id
								AND s.source_deal_detail_id = mgd.source_deal_detail_id 
								
						UPDATE sdd 
							SET actual_volume = mgd.actual_volume,
								deal_volume_frequency = ''t''
							
						FROM #updated_sdd us
						INNER JOIN (
										SELECT source_deal_detail_id, 
												SUM(mgd.quantity) actual_volume 
										FROM match_group_detail mgd 
										GROUP BY source_deal_detail_id
									) mgd
							ON mgd.source_deal_detail_id = us.source_deal_detail_id
						INNER JOIN source_deal_detail sdd
							ON sdd.source_deal_detail_id = mgd.source_deal_detail_id
						

						DECLARE @source_deal_header_id VARCHAR(2000)

						SELECT @source_deal_header_id = ISNULL(@source_deal_header_id + '','' , '''') 
															+ CAST(sdd.source_deal_header_id AS VARCHAR(10))
						FROM #updated_sdd us
							INNER JOIN source_deal_detail sdd
								ON us.source_deal_detail_id = sdd.source_deal_detail_id
						
						IF NULLIF(@source_deal_header_id, '''') IS NOT NULL
						EXEC spa_update_deal_total_volume @source_deal_header_id, NULL, 0, NULL, @user_login_id, ''y''
								
						'
		EXEC spa_print @sql
		EXEC(@sql)
	END
END

