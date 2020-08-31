
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[process_generation_unit_cost]') AND type in (N'U'))
BEGIN
	create table dbo.process_generation_unit_cost
	(
		rec_id bigint identity(1,1) ,
		as_of_date datetime,
		long_short varchar(2), --lt=long, st=short
		location_id int,
		generator_config_value_id int,
		fuel_value_id int,
		tou int,
		term_hr datetime,
		min_capacity numeric(20,8),
		max_capacity numeric(20,8),
		contractual_unit_min numeric(20,8),
		om1 numeric(20,8),
		om2 numeric(20,8),
		om3 numeric(20,8),
		om4 numeric(20,8),
		online_indicator bit,
		must_run_indicator numeric(20,8),
		operating_limit_constraints numeric(20,8),
		seasonal_variations numeric(20,8),
		fuel_price numeric(20,8),
		derate_unit  numeric(20,8),
		coefficient_a numeric(20,8), coefficient_b numeric(20,8), coefficient_c numeric(20,8),
		fuel_curve_id int,
		heat_rate numeric(20,8),
		is_default bit,
		is_mix bit,
		create_ts DATETIME  DEFAULT GETDATE(),
		create_user VARCHAR(50) DEFAULT dbo.FNADBUser()
	)
END
	ELSE PRINT 'Table ''process_generation_unit_cost'' already exists.'

