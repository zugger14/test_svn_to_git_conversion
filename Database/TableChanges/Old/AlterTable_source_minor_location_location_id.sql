IF COL_LENGTH('source_minor_location', 'location_id') IS NULL
BEGIN
    ALTER TABLE source_minor_location ADD location_id varchar(500)
END
GO