IF COL_LENGTH('recorder_generator_map', 'recorderid') IS NULL
BEGIN
    ALTER TABLE recorder_generator_map ADD recorderid varchar(10)
END
GO