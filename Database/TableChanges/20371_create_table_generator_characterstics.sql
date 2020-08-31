
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[generator_characterstics]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[generator_characterstics](
		rec_id  INT IDENTITY(1,1) NOT NULL,
		location_id INT REFERENCES dbo.source_minor_location(source_minor_location_id) NOT NULL,
		generator_config_value_id int REFERENCES dbo.static_data_value(value_id) NOT NULL,
		fuel_value_id int REFERENCES dbo.static_data_value(value_id) NOT NULL,
		fuel_curve_id int REFERENCES dbo.source_price_curve_def(source_curve_def_id) NOT NULL,
		coeff_a numeric(20,8),
		coeff_b  numeric(20,8),
		coeff_c  numeric(20,8),
		heat_rate  numeric(20,8),
		unit_min  numeric(20,8),
		unit_max  numeric(20,8),
		effective_date datetime,
		is_default bit,
		create_ts DATETIME  DEFAULT GETDATE(),
		create_user VARCHAR(50) DEFAULT dbo.FNADBUser(),
		update_ts DATETIME  null,
		update_user VARCHAR(50) null
	)

END
ELSE PRINT 'Table ''generator_characterstics'' already exists.'
