
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[process_long_term_generation_unit_cost]') AND type in (N'U'))
BEGIN
	create table dbo.process_long_term_generation_unit_cost
	(
		rec_id bigint identity(1,1) ,
		as_of_date datetime ,
		location_id int,
		generator_config_value_id int,
		term datetime,
		fuel_value_id int,
		fuel_curve_id int,
		tou int,
		volume numeric(20,8),price numeric(20,8),
		create_ts DATETIME  DEFAULT GETDATE(),
		create_user VARCHAR(50) DEFAULT dbo.FNADBUser()
	)
END
	ELSE PRINT 'Table ''process_long_term_generation_unit_cost'' already exists.'