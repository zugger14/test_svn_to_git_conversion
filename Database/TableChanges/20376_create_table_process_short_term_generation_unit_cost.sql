
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[process_short_term_generation_unit_cost]') AND type in (N'U'))
BEGIN
	create table dbo.process_short_term_generation_unit_cost
	(
		rec_id bigint identity(1,1) ,
		location_id int,
		generator_config_value_id int,
		fuel_value_id int,
		term_hr datetime,
		min_unit numeric(20,8),
		max_unit numeric(20,8),
		unit_value numeric(20,8),
		fuel numeric(20,8),
		fuel_amount numeric(20,8),
		coefficient_a numeric(20,8),
		coefficient_b numeric(20,8),
		coefficient_c numeric(20,8),
		om1 numeric(20,8),
		om2 numeric(20,8),
		om3 numeric(20,8),
		om4 numeric(20,8),
		total_cost numeric(20,8),
		avg_cost numeric(20,8),
		inc_cost numeric(20,8),
		must_run_indicator numeric(20,8),
		operating_limit_constraints numeric(20,8),
		seasonal_variations numeric(20,8),
		fuel_price numeric(20,8),
		derate_unit  numeric(20,8),
		heat_rate numeric(20,8),
		is_default bit,
		is_mix bit,
		fuel_curve_id int,
		overlap_fuel_value_id int,
		overlap_fuel_curve_id int,
		create_ts DATETIME  DEFAULT GETDATE(),
		create_user VARCHAR(50) DEFAULT dbo.FNADBUser()
	)
END
	ELSE PRINT 'Table ''process_short_term_generation_unit_cost'' already exists.'