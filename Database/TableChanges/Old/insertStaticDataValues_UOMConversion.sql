set identity_insert static_data_value on
GO

INSERT INTO static_data_value(value_id,type_id,code,[description])
SELECT 4015,4000,'rec_volume_unit_conversion','UOM Conversion'
GO

set identity_insert static_data_value off
GO