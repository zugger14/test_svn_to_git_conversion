IF COL_LENGTH('recorder_properties', 'channel_description') IS NULL
BEGIN
    ALTER TABLE recorder_properties ADD channel_description VARCHAR(400) NULL
END
