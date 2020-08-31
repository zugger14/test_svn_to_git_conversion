IF OBJECT_ID(N'state_properties_details', N'U') IS NOT NULL AND COL_LENGTH('state_properties_details', 'effective_date') IS NULL
BEGIN
    ALTER TABLE state_properties_details ADD effective_date DATE
END
GO
