
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[generator_data]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[generator_data](
		rec_id  INT IDENTITY(1,1) NOT NULL,
		location_id INT REFERENCES dbo.source_minor_location(source_minor_location_id) NOT NULL,
		effective_date datetime,
		effective_end_date datetime,
		period_type varchar(2),
		hour_from int,
		hour_to int,
		tou int,
		data_type_value_id int,
		data_value  numeric(20,8),
		create_ts DATETIME  DEFAULT GETDATE(),
		create_user VARCHAR(50) DEFAULT dbo.FNADBUser(),
		update_ts DATETIME  null,
		update_user VARCHAR(50) null
		)

END
ELSE PRINT 'Table ''generator_data'' already exists.'
