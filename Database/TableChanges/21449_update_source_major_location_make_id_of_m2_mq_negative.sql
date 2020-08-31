DECLARE @m2_loc_id INT,	@mq_loc_id INT, @new_id VARCHAR(200) = dbo.FNAGetNewID()

/*
	# Case I:
	m2/mq doesnot exists
	then insert with negative id
*/
IF NOT EXISTS (SELECT 1 FROM source_major_location WHERE location_name = 'M2')
BEGIN
	SET IDENTITY_INSERT source_major_location ON
	INSERT INTO source_major_location (source_major_location_ID, source_system_id, location_name, location_description)
	VALUES (-10, 2, 'M2', 'M2')
	SET IDENTITY_INSERT source_major_location OFF
	PRINT 'M2 inserted with negative id'
END	

IF NOT EXISTS (SELECT 1 FROM source_major_location WHERE location_name = 'MQ')
BEGIN
	SET IDENTITY_INSERT source_major_location ON
	INSERT INTO source_major_location (source_major_location_ID, source_system_id, location_name, location_description)
	VALUES (-11, 2, 'MQ', 'MQ')
	SET IDENTITY_INSERT source_major_location OFF
	PRINT 'MQ inserted with negative id'
END
	
/*
	# Put values of old location_id in a variable
*/
SELECT @m2_loc_id = source_major_location_ID FROM source_major_location WHERE location_name = 'M2'

SELECT @mq_loc_id = source_major_location_ID FROM source_major_location where location_name = 'MQ'

/*
	# Case II:
	m2/mq exists with positive id
*/
IF EXISTS(SELECT 1 FROM source_major_location WHERE location_name = 'M2' AND source_major_location_ID > 0)
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF OBJECT_ID('tempdb..#temp_insert_major') IS NOT NULL
				DROP TABLE #temp_insert_major

			-- Collect existing values from source_major_location
			SELECT -10 AS [source_major_location_ID], source_system_id, location_name, location_description, 
				create_user, create_ts, update_user, update_ts, 
				location_type, region, owner, operator, 
				counterparty, contract, volume, uom
			INTO #temp_insert_major
			FROM source_major_location WHERE location_name = 'M2' AND source_major_location_ID > 0
			--SELECT * FROM #temp_insert_major

			-- Update existing location with process id appended
			UPDATE source_major_location
			SET location_name = CONCAT('M2-', @new_id)
			WHERE source_major_location_ID = @m2_loc_id

			-- Insert new value with new negative location id in source_minor_location
			SET IDENTITY_INSERT source_major_location ON

			INSERT INTO source_major_location (source_major_location_ID, source_system_id, location_name, location_description, 
				create_user, create_ts, update_user, update_ts, 
				location_type, region, owner, operator, 
				counterparty, contract, volume, uom)
			SELECT source_major_location_ID, source_system_id, location_name, location_description, 
				create_user, create_ts, update_user, update_ts, 
				location_type, region, owner, operator, 
				counterparty, contract, volume, uom
			FROM #temp_insert_major	

			SET IDENTITY_INSERT source_major_location OFF

			/*
				# Case III:
				Child exists
				then update column value with new negative id
			*/			
			--SELECT smil.*
			UPDATE smil
			SET source_major_location_ID = -10
			FROM source_minor_location smil
			INNER JOIN source_major_location smal
				ON smal.source_major_location_ID = smil.source_major_location_ID
			WHERE smil.source_major_location_ID = @m2_loc_id

			-- Update location group in deal fields
			--SELECT dfml.*
			UPDATE dfml
			SET location_group = -10
			FROM deal_fields_mapping_locations dfml
			INNER JOIN source_major_location smal
				ON smal.source_major_location_ID = dfml.location_group
			WHERE dfml.location_group = @m2_loc_id

			-- Finally delete major location which is old
			DELETE FROM source_major_location WHERE source_major_location_ID = @m2_loc_id

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		DECLARE @err_msg VARCHAR(MAX) = ERROR_MESSAGE()
		ROLLBACK TRANSACTION
		RAISERROR (@err_msg, 17, -1);
	END CATCH
END
ELSE
	PRINT 'M2 already updated with negative id'

IF EXISTS(SELECT 1 FROM source_major_location WHERE location_name = 'MQ' AND source_major_location_ID > 0)
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF OBJECT_ID('tempdb..#temp_insert_major_mq') IS NOT NULL
				DROP TABLE #temp_insert_major_mq

			-- Collect major
			SELECT -11 AS [source_major_location_ID], source_system_id, location_name, location_description, 
				create_user, create_ts, update_user, update_ts, 
				location_type, region, owner, operator, 
				counterparty, contract, volume, uom
			INTO #temp_insert_major_mq
			FROM source_major_location WHERE location_name = 'MQ' AND source_major_location_ID > 0
			--SELECT * FROM #temp_insert_major

			UPDATE source_major_location
			SET location_name = CONCAT('MQ-', @new_id)
			WHERE source_major_location_ID = @mq_loc_id

			SET IDENTITY_INSERT source_major_location ON

			INSERT INTO source_major_location (source_major_location_ID, source_system_id, location_name, location_description, 
				create_user, create_ts, update_user, update_ts, 
				location_type, region, owner, operator, 
				counterparty, contract, volume, uom)
			SELECT source_major_location_ID, source_system_id, location_name, location_description, 
				create_user, create_ts, update_user, update_ts, 
				location_type, region, owner, operator, 
				counterparty, contract, volume, uom
			FROM #temp_insert_major_mq	

			SET IDENTITY_INSERT source_major_location OFF

			--SELECT smil.*
			UPDATE smil
			SET source_major_location_ID = -11
			FROM source_minor_location smil
			INNER JOIN source_major_location smal
				ON smal.source_major_location_ID = smil.source_major_location_ID
			WHERE smil.source_major_location_ID = @mq_loc_id

			--SELECT dfml.*
			UPDATE dfml
			SET location_group = -11
			FROM deal_fields_mapping_locations dfml
			INNER JOIN source_major_location smal
				ON smal.source_major_location_ID = dfml.location_group
			WHERE dfml.location_group = @mq_loc_id

			DELETE FROM source_major_location WHERE source_major_location_ID = @mq_loc_id

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		DECLARE @err_msg1 VARCHAR(MAX) = ERROR_MESSAGE()
		ROLLBACK TRANSACTION
		RAISERROR (@err_msg1, 17, -1);
	END CATCH
END
ELSE
	PRINT 'MQ already updated with negative id'

GO