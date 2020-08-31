--procedure used by SSIS component
IF OBJECT_ID(N'spa_stage_mv90_data_update', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_stage_mv90_data_update]
GO 

CREATE PROCEDURE [dbo].[spa_stage_mv90_data_update]
	@process_id VARCHAR(100),
	@user_login_id VARCHAR(50),
	@meter_id VARCHAR(100) = NULL,
	@granularity VARCHAR(25) = NULL,
	@uom VARCHAR(25) = NULL,
	@counterparty VARCHAR(25) = NULL,
	@commodity VARCHAR(25) = NULL,
	@file_type VARCHAR(25) = NULL,
	@time_stamp VARCHAR(25) = NULL,
	@data_version VARCHAR(25) = NULL,
	@file_name VARCHAR(100) = NULL,
	@input_folder VARCHAR(50) = NULL,
	@error_code VARCHAR(2) = '0'
	/* @error_code
	* 0 - no error
	* 1 - File invalid/missing header error
	* 2 -  Working folder Empty
	* 3 - Invalid file format error (occurs when DFT component fails)
	* 4 - Commodity/counterparty doesn't exists
	* 5 - Error in parsing details, exception occur in SSIS
	* 6 - UOM mismatch as of file and existing
	*/
	  
AS

DECLARE @error_msg VARCHAR(1000), @table_name VARCHAR(200) = NULL
DECLARE @folder_type CHAR(2)

SELECT @folder_type = CASE @input_folder WHEN 'Manual' THEN 0 WHEN 'Batch' THEN 1 END


SET @error_msg = ''

DECLARE @stage_ebase_mv90_data_header VARCHAR(128)		
-- header information of all source file is inserted in same stage table.
SELECT @stage_ebase_mv90_data_header = dbo.FNAProcessTableName('stage_ebase_mv90_data_header', @user_login_id, @process_id)

DECLARE @country VARCHAR(50)
SET @country = ''

IF @error_code = '3' -- SSIS DFT component failure
BEGIN
	SET @error_msg = 'Invalid File Format'
END
ELSE IF @error_code = '5'
BEGIN
	SET @error_msg = 'Invalid File Format (Exception occurs)'
END
ELSE
BEGIN
	IF @meter_id = '' OR @granularity = '' OR @uom = '' OR @counterparty = '' OR @commodity = ''
		BEGIN
			SET @error_code = '1' -- header error
			SET @error_msg = 'Invalid File Header Format'
		END
	ELSE
	BEGIN
		SELECT @country= dbo.FNAGetSplitPart(@commodity,'_','2')
		
		SET @error_code = '0'
		 --counterparty / commodity mapping
		SELECT @counterparty = ISNULL(sc.counterparty_id, @counterparty) FROM source_counterparty sc LEFT JOIN counterparty_mapping_ebase cm 
		ON sc.source_counterparty_id = cm.source_counterparty_id
		WHERE cm.map_name = @counterparty		 
		SELECT @commodity = ISNULL(sc.commodity_id, @commodity) FROM source_commodity sc LEFT JOIN commodity_mapping_ebase cm 
		ON sc.source_commodity_id = cm.source_commodity_id
		WHERE cm.map_name = @commodity		 
		
		--SELECT @counterparty = CASE @counterparty WHEN 'B2B' THEN 'Essent B2B' WHEN 'B2C' THEN 'Essent B2C' ELSE @counterparty END
		--SELECT @commodity = CASE WHEN @commodity IN ('P_NL', 'P_BE') THEN 'Power' WHEN @commodity IN ('G_NL', 'G_BE') THEN 'Gas' ELSE @commodity END
		
		DECLARE @existing_uom VARCHAR(50), @uom_msg VARCHAR(300)
		SET @uom_msg = ''
		--check counterparty/commodity for new meterID
		IF NOT EXISTS (SELECT 1 FROM meter_id mi WHERE mi.recorderid = @meter_id)
		BEGIN

			IF NOT EXISTS(SELECT 1 FROM source_counterparty sc WHERE sc.counterparty_id = @counterparty)
			BEGIN
				SET @error_code = '4'
				SET @error_msg = 'Counterparty: ' + @counterparty 
			END				
			IF NOT EXISTS(SELECT 1 FROM source_commodity sc WHERE sc.commodity_id = @commodity)
			BEGIN
				SELECT @error_msg = @error_msg + CASE WHEN @error_code = '4' THEN ', ' ELSE '' END + ' Commodity: ' + @commodity
				SET @error_code = '4'
			END
			IF NOT EXISTS(SELECT 1 FROM source_uom su WHERE su.uom_id = @uom)
			BEGIN
				SELECT @error_msg = @error_msg + CASE WHEN @error_code = '4' THEN ', ' ELSE '' END + ' UOM: ' + @uom
				SET @error_code = '4'
			END
			
			SELECT @error_msg = CASE WHEN @error_code = '4' THEN @error_msg + ' does not exists for meterID: ' + @meter_id ELSE '' END
		END
		
	END
	
	--SELECT TOP 1 @existing_uom = su.uom_id FROM mv90_data mv
	--INNER JOIN source_uom su ON su.source_uom_id = mv.uom_id
	--INNER JOIN meter_id mi ON mi.meter_id = mv.meter_id
	--WHERE mi.recorderid = @meter_id
	
	SELECT TOP 1 @existing_uom = su.uom_id FROM recorder_properties rp
	INNER JOIN meter_id mi ON mi.meter_id = rp.meter_id
	INNER JOIN source_uom su ON su.source_uom_id = rp.uom_id
	WHERE mi.recorderid = @meter_id	

	IF @existing_uom IS NOT NULL AND @existing_uom <> @uom
	BEGIN 
		SET @error_code = '6'
		SELECT @uom_msg = ' UOM mismatch for meter ID: ' + @meter_id + '. File UOM: ' + @uom + '. Existing UOM:' +@existing_uom
	END
	
	DECLARE @existing_gran VARCHAR(50), @gran_msg VARCHAR(300)
	SET @gran_msg = ''
	SELECT @existing_gran = mi.granularity FROM meter_id mi	WHERE mi.recorderid = @meter_id
	
	IF @existing_gran IS NOT NULL AND @existing_gran <> @granularity
	BEGIN 
		SET @error_code = '6'
		SELECT @gran_msg = ' Granularity mismatch for meter ID: ' + @meter_id + '. File Granularity: ' + @granularity + '. Existing Granularity:' + @existing_gran + '. '
	END

			
	 SELECT @error_msg  = @error_msg + '  ' + @uom_msg + ' ' + @gran_msg
END
	
EXEC('INSERT INTO ' + @stage_ebase_mv90_data_header + '([meter_id], [granularity], [uom], [counterparty], [commodity], 
	  [filetype], [timestamp], [dataversion], [h_filename], [h_error], [error_code], [file_category], [country])
	  SELECT ''' + @meter_id + ''', ''' + @granularity + ''', ''' + @uom + ''', ''' + @counterparty + ''', ''' + @commodity +
	  ''', ''' + @file_type + ''', ''' + @time_stamp + ''', ''' + @data_version + ''', ''' + @file_name + ''', ''' + @error_msg +
	  ''', ''' + @error_code + ''', ''' + @folder_type + ''', ''' + @country + '''  ') 

SELECT @error_code error_code
