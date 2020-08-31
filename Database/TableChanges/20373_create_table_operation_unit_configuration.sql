
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[operation_unit_configuration]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[operation_unit_configuration](
		rec_id  INT IDENTITY(1,1) NOT NULL,
		effective_date datetime,
		effective_end_date datetime,
		location_id INT REFERENCES dbo.source_minor_location(source_minor_location_id) NOT NULL,
		generator_config_value_id int REFERENCES dbo.static_data_value(value_id)  NULL,
		hour_from int,
		hour_to int,
		unit_from int,
		unit_to int,
		fuel_value_id int,
		period_type varchar(2),
		tou int,
		create_ts DATETIME  DEFAULT GETDATE(),
		create_user VARCHAR(50) DEFAULT dbo.FNADBUser(),
		update_ts DATETIME  null,
		update_user VARCHAR(50) null
		)

END
ELSE PRINT 'Table ''operation_unit_configuration'' already exists.'
