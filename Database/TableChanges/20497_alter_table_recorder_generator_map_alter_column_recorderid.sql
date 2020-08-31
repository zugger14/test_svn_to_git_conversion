
IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name = 'recorder_generator_map'
AND column_name = 'recorderid' AND data_type = 'varchar' and character_maximum_length = 100)
BEGIN
		ALTER TABLE recorder_generator_map ALTER COLUMN recorderid VARCHAR(100)

END

