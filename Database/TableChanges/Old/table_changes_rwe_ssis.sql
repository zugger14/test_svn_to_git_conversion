
ALTER TABLE stage_sdd ALTER COLUMN [filename] VARCHAR(150) 

IF not EXISTS(SELECT * FROM sys.[columns] WHERE [object_id]=object_id('stage_sdd') AND [name]='fileAsOfDate')
	ALTER TABLE stage_sdd add fileAsOfDate VARCHAR(20) 



ALTER TABLE source_system_data_import_status ALTER COLUMN module VARCHAR(500)
ALTER TABLE source_system_data_import_status_detail ALTER COLUMN [TYPE] VARCHAR(500)

ALTER TABLE source_system_data_import_status_vol ALTER COLUMN module VARCHAR(500)
ALTER TABLE source_system_data_import_status_vol_detail ALTER COLUMN [TYPE] VARCHAR(500)

update connection_string set import_path='d:\rwe'