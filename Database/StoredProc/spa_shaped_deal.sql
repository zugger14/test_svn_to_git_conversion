IF OBJECT_ID('[dbo].[spa_shaped_deal]', 'p') IS NOT NULL
    DROP PROC [dbo].[spa_shaped_deal]
GO 

CREATE PROC [dbo].spa_shaped_deal 
	@flag CHAR(1),
	@source_deal_header_id VARCHAR(MAX) = NULL,
	@source_deal_detail_id VARCHAR(MAX) = NULL
AS 

/************************************************
	DECLARE @flag CHAR(1),
			@source_deal_header_id VARCHAR(MAX) = NULL,
			@source_deal_detail_id VARCHAR(MAX) = NULL

	SELECT @flag='z', @source_deal_header_id='228807'
--**********************************************/
SET NOCOUNT ON
BEGIN 
	IF @flag = 'c'
	BEGIN
		CREATE TABLE #temp_deal_collection(source_deal_header_id INT, source_deal_detail_id INT, deal_volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT , granularity INT)

		IF @source_deal_header_id IS NOT NULL 
		BEGIN 
			INSERT INTO #temp_deal_collection(source_deal_header_id, source_deal_detail_id, deal_volume_frequency)
			SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.deal_volume_frequency
			FROM dbo.FNASplit(@source_deal_header_id, ',') t
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = t.item
		END 

		IF @source_deal_detail_id <> 'NULL' --@source_deal_detail_id
		BEGIN 
			INSERT INTO #temp_deal_collection(source_deal_header_id, source_deal_detail_id, deal_volume_frequency)	
			SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.deal_volume_frequency
			FROM dbo.FNASplit(@source_deal_detail_id, ',') t
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = t.item
		END 

		DECLARE @profile_type_check INT
		DECLARE @profile_type_id INT

		SELECT @profile_type_check = COUNT(code) FROM (SELECT code  
		FROM source_deal_header sdh
		INNER JOIN #temp_deal_collection tdc ON tdc.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN static_data_value sdv ON sdv.value_id = internal_desk_id
		GROUP BY code) a

		--to do if @profile_type_check > 2 return error message 
		IF (@profile_type_check > 2)
		BEGIN 
			EXEC spa_ErrorHandler -1,
				'spa_shaped_deal table',
				'spa_shaped_deal',
				'DB Error',
				'Profile Type does not match for selected deals.',
				''
			RETURN 
		END 
		ELSE 
		BEGIN 
			SELECT @profile_type_id = internal_desk_id  
			FROM source_deal_header sdh
			INNER JOIN #temp_deal_collection tdc ON tdc.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN static_data_value sdv ON sdv.value_id = internal_desk_id
			GROUP BY code, internal_desk_id

			EXEC spa_ErrorHandler 0,
    	     'spa_shaped_deal table',
    	     'spa_shaped_deal',
    	     'Success',
    	     'Data Check Successfully.',
    	     @profile_type_id
		END

		/* check for deal profile are same or not start*/
	END 
	ELSE IF @flag = 'z'-- check for monthly deal
	BEGIN
		--IF EXISTS(
		--	SELECT 1
		--	FROM source_deal_header sdh
		--	INNER JOIN dbo.FNASplit(@source_deal_header_id, ',') i
		--		ON i.item = sdh.source_deal_header_id
		--	WHERE sdh.term_frequency = 'm'
		--		AND sdh.internal_desk_id = 17301
		--)
		--BEGIN 
		--	EXEC spa_ErrorHandler -1,
		--		'spa_shaped_deal table',
		--		'spa_shaped_deal',
		--		'DB Error',
		--		'Please select valid deals.',
		--		''
		--	RETURN 
		--END
		--ELSE 
		--BEGIN
			DECLARE @term_frequency CHAR(1), @profile_id INT, @recommendation VARCHAR(1024)
			
			SELECT @term_frequency = sdh.term_frequency,
				   @profile_id = COALESCE(sdd.profile_id, sml.profile_id, '')
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
			WHERE sdh.source_deal_header_id = @source_deal_header_id

			SET @recommendation = @term_frequency + ',' + CAST(@profile_id AS VARCHAR(10))

			EXEC spa_ErrorHandler 0,
    	     'spa_shaped_deal table',
    	     'spa_shaped_deal',
    	     'Success',
    	     'Data Check Successfully.',
    	     @recommendation
		END
	--END
END

