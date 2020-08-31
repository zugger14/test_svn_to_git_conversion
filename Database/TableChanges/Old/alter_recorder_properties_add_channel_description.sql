IF COL_LENGTH('recorder_properties','channel_description') IS NULL
ALTER TABLE recorder_properties ADD channel_description VARCHAR(400)