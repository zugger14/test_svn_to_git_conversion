IF COL_LENGTH('recorder_properties', 'recorder_property_id') IS NULL
alter table recorder_properties add recorder_property_id int identity(1,1)