
/****** Object:  StoredProcedure [dbo].[spa_meter_id]    Script Date: 06/07/2009 11:23:25 ******/
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_meter_id]')AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_meter_id]
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Modified By: bbishural@pioneersolutionsglobal.com
-- Created date: 2012-07-13
-- Description: CRUD operations for table meter_id

-- Params:
-- @flag CHAR(1) - Operation flag
-- @recorderid VARCHAR(1000) - Recorder Id 
-- @meter_manufacturer VARCHAR(100) - meter manufacturer
-- @meter_type VARCHAR(500)- meter type
-- @meter_serial_number	VARCHAR(100)- meter serial number
-- @meter_certification	DATETIME - meter certification
-- @meter_id - meter id
-- @sub_meter_id INT - sub meter id
-- @counterparty VARCHAR(100) - counterparty
-- @commodity VARCHAR(100) - commodity
-- @country VARCHAR(100) - country
-- @allocationType VARCHAR(100) - allocation type
-- @granularityValue VARCHAR(100) - grnaularity values
-- @multipleLocation CHAR(1) - multiple Location 
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_meter_id]
	@flag					CHAR(1), -- 'c' show counterparty report
	@recorderid				VARCHAR(1000) = NULL,
	@desc					VARCHAR(255) = NULL,
	@meter_manufacturer		VARCHAR(100) = NULL,
	@meter_type				VARCHAR(100) = NULL,
	@meter_serial_number	VARCHAR(100) = NULL,
	@meter_certification	DATETIME = NULL,
	@meter_id				VARCHAR(500) = NULL,
	@sub_meter_id			INT = NULL,
	@counterparty			VARCHAR(100) = NULL,
	@commodity				VARCHAR(100) = NULL,
	@country				VARCHAR(100) = NULL,
	@allocationType         VARCHAR(100) = NULL,
	@granularityValue       VARCHAR(100) = NULL,
	@multipleLocation		CHAR(1) = NULL,
	@location_id			INT = NULL
AS
BEGIN
SET NOCOUNT ON

IF @flag = 'g'
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'meter'
END

DECLARE @sql VARCHAR(8000)
IF @flag='s'	
BEGIN
SET @sql = 'SELECT mi.recorderid [Recorder ID],
				   mi.[DESCRIPTION] [Description],
				   mi.meter_id [Meter ID],
				   mi1.recorderid [Sub Meter]
			FROM   meter_id mi
			LEFT JOIN meter_id mi1 ON mi.sub_meter_id = mi1.meter_id ' + 
			CASE 
			     WHEN @location_id IS NOT NULL THEN 
			          'LEFT JOIN source_minor_location_meter smlm ON smlm.meter_id = mi.meter_id 
					   LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = smlm.source_minor_location_id ' 
			          
			     ELSE ''
			END + ' 
			WHERE  1 = 1 '+
			CASE 
				WHEN @recorderid IS NOT NULL 
					THEN ' AND mi.recorderid LIKE '''+@recorderid+''' OR mi.description LIKE '''+@recorderid + ''''
					ELSE '' 
			END +
			CASE 
			     WHEN @location_id IS NOT NULL THEN 
			          'AND sml.source_minor_location_id = ' + CAST(@location_id AS varchar(15)) 
			          
			     ELSE ''
			END
			 
			--CASE WHEN @desc IS NOT NULL THEN ' and description like '''+@desc+'%''' ELSE '' END 
EXEC spa_print @sql
EXEC (@sql)
END
ELSE IF @flag='a'
BEGIN
	SELECT mi.recorderid,
	       mi.[DESCRIPTION],
	       mi.meter_manufacturer,
	       mi.meter_type,
	       mi.meter_serial_number,
	       dbo.FNADateFormat(mi.meter_certification) meter_certification,
	       mi.sub_meter_id [Sub Meter],
	       mi1.recorderid,
	       mi.counterparty_id,
	       mi.commodity_id,
	       mi.country_id,
	       mi.allocation_type,
	       mi.granularity,
	       mi.multiple_location
	FROM   meter_id mi 
	LEFT JOIN meter_id mi1 ON mi.sub_meter_id = mi1.meter_id
	WHERE  mi.meter_id = @meter_id
END
ELSE IF @flag='i'
BEGIN
	--/******************check if recorder id exists***********************************************************/
	IF NOT EXISTS(SELECT 1 FROM meter_id WHERE recorderid = @recorderid) 
	BEGIN 
		INSERT INTO meter_id
		  (
		    recorderid,
		    DESCRIPTION,
		    meter_manufacturer,
		    meter_type,
		    meter_serial_number,
		    meter_certification,
		    sub_meter_id,
		    counterparty_id,
		    commodity_id,
		    country_id,
		    allocation_type,
		    granularity,
		    multiple_location
		  )
		SELECT @recorderid,
		       @desc,
		       @meter_manufacturer,
		       @meter_type,
		       @meter_serial_number,
		       @meter_certification,
		       @sub_meter_id,
		       @counterparty,
		       @commodity,
		       @country,
		       @allocationType,
		       @granularityValue,
		       @multipleLocation

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR
				, 'Recorder ID Detail'
				, 'spa_meter'
				, 'DB ERROR'
				, 'ERROR Inserting Recoder Information.'
				, ''
		ELSE
			EXEC spa_ErrorHandler 0
				, 'Recorder ID'
				, 'spa_meter'
				, 'Success'
				, 'Recorder Information successfully inserted.'
				, ''
	END
	ELSE
	BEGIN
		EXEC spa_print 'duplicate'
		EXEC spa_ErrorHandler -1
			, 'Recorder ID'
			, 'spa_meter'
			, 'UNIQUE KEY ERROR'
			, 'Recorder ID already exists.'
			, ''
	END
END
ELSE IF @flag='u'
BEGIN
	UPDATE meter_id
	SET    DESCRIPTION = @desc,
	       meter_manufacturer = @meter_manufacturer,
	       meter_type = @meter_type,
	       meter_serial_number = @meter_serial_number,
	       meter_certification = @meter_certification,
	       sub_meter_id = @sub_meter_id,
	       recorderid = @recorderid,
	       counterparty_id = @counterparty,
	       commodity_id = @commodity,
	       country_id = @country,
	       allocation_type = @allocationType,
	       granularity = @granularityValue,
	       multiple_location = @multipleLocation  
	WHERE  meter_id = @meter_id

	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         "Recorder ID",
	         "spa_meter",
	         "DB ERROR",
	         "ERROR Updating Recoder Information.",
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Recorder ID',
	         'spa_meter',
	         'Success',
	         'Recoder Information successfully updated.',
	         ''
END
ELSE IF @flag='d'
BEGIN
	DELETE FROM recorder_properties WHERE meter_id = @meter_id	
	DELETE FROM meter_id_allocation WHERE meter_id = @meter_id	
	DELETE FROM meter_id_channel WHERE meter_id = @meter_id
	DELETE FROM recorder_generator_map WHERE meter_id = @meter_id	
	DELETE FROM meter_id WHERE meter_id = @meter_id

	IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         "Recorder ID",
	         "spa_meter",
	         "DB ERROR",
	         "ERROR  Deleting Recoder Information.",
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Recorder ID',
	         'spa_meter',
	         'Success',
	         'Recoder Information Deleted Successfully.',
	         ''
END
ELSE IF @flag='c'
BEGIN

	SET @sql = 'SELECT rgm.meter_id AS [Recorder Id],
				        source_counterparty_id AS [Counterparty ID],
				        counterparty_name AS [Counterparty Name]
				 FROM   rec_generator rg
				        INNER JOIN recorder_generator_map rgm ON  rg.generator_id = rgm.generator_id
				        INNER JOIN meter_id mi ON  mi.meter_id = rgm.meter_id
				        INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = rg.ppa_counterparty_id
				 WHERE mi.meter_id in(' + @meter_id + ')'
exec spa_print @sql
	EXEC(@sql)
END
ELSE IF @flag = 'r'
BEGIN
	SET @sql = '
				SELECT	mi.recorderid
				FROM	meter_id mi
				WHERE	mi.meter_id = ' + @meter_id

	EXEC(@sql)
END
ELSE IF @flag = 'g'
BEGIN
	SET @sql = '
	SELECT DISTINCT mi.meter_id,
	       mi.recorderid,
		   mi.description,
		   sdv.code Granularity,
		   su.uom_name UOM,
		   sc1.counterparty_name counterparty,
		   sc.commodity_name commodity,
		   sdv1.code country,
		   mi1.recorderid submeter,
		   CASE mi.multiple_location WHEN ''y'' THEN ''Yes'' Else ''No'' END multiple_location,
		   sdv2.code allocation_type,
		   mi.meter_manufacturer manufacturer,
		   mi.meter_type type,
		   mi.meter_serial_number serial_number,
		   dbo.FNADateFormat(mi.meter_certification) inspection_date,
		   400000 type_id,
		   ISNULL(sdad.is_active, 0) is_privilege_active
	FROM #final_privilege_list fpl
	' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
		meter_id mi ON mi.meter_id = fpl.value_id
	LEFT JOIN source_uom su ON su.source_uom_id = mi.source_uom_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = mi.granularity	
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = mi.country_id
	LEFT JOIN source_commodity sc ON sc.source_commodity_id = mi.commodity_id
	LEFT JOIN source_counterparty sc1 ON sc1.source_counterparty_id = mi.counterparty_id
	LEFT JOIN meter_id mi1 ON mi1.meter_id = mi.sub_meter_id
	LEFT JOIN static_data_value sdv2 On sdv2.value_id = mi.allocation_type
	LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 400000

	ORDER BY 
		  mi.recorderid'
		 -- print @sql
	EXEC(@sql)
END
ELSE IF @flag = 'x'
BEGIN
	SELECT mi.meter_id,
	       mi.recorderid
	FROM   meter_id mi
	ORDER BY 
		  mi.recorderid
END
END
