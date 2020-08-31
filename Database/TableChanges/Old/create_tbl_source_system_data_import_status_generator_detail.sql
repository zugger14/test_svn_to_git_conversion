IF OBJECT_ID('source_system_data_import_status_generator_detail') IS NULL
CREATE TABLE source_system_data_import_status_generator_detail(
status_id INT IDENTITY(1,1),
process_id VARCHAR(50),
source VARCHAR(250),
[type] VARCHAR(500),
book VARCHAR(100),
facility_name VARCHAR(100),
facility_id VARCHAR(100),
unit_name VARCHAR(100),
unit_id VARCHAR(100),
juridiction VARCHAR(100),
facility_owner VARCHAR(100),
[start_date] VARCHAR(100),
[fuel_type] VARCHAR(100),
technology VARCHAR(100),
create_user VARCHAR(50),
create_ts DATETIME,
update_user VARCHAR(50),
update_ts DATETIME
)