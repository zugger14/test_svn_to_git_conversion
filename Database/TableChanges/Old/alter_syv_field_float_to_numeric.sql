IF EXISTS (SELECT 1 FROM maintain_field_deal  WHERE data_type='float' AND farrms_field_id='standard_yearly_volume')
BEGIN
	UPDATE maintain_field_deal SET data_type = 'numeric(38,20)' WHERE data_type='float' AND farrms_field_id='standard_yearly_volume'
	PRINT 'Data Type Changed from to numeric(38,20)'
END
ELSE PRINT 'Field doesnot exists'
GO

IF COL_LENGTH('source_deal_detail_template', 'standard_yearly_volume') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_detail_template ALTER COLUMN standard_yearly_volume NUMERIC(38,20)
    PRINT 'Data Type Changed from to numeric(38,20)'
END
ELSE PRINT 'Field doesnot exists'
GO