
IF  EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_price_curve_simulation') AND name = N'unq_cur_indx_source_price_curve_simulation')
BEGIN
	DROP INDEX unq_cur_indx_source_price_curve_simulation ON dbo.source_price_curve_simulation
END

GO
CREATE UNIQUE CLUSTERED INDEX unq_cur_indx_source_price_curve ON dbo.source_price_curve_simulation
	(
	run_date,
	source_curve_def_id,
	as_of_date,
	maturity_date,
	is_dst,
	curve_source_value_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 

GO
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.source_price_curve_simulation') AND name = N'indx_source_price_curve_simulation_111')
BEGIN
	CREATE NONCLUSTERED INDEX indx_source_price_curve_simulation_111
	ON [dbo].source_price_curve_simulation (run_date,[as_of_date],[curve_source_value_id])
	INCLUDE ([source_curve_def_id],[maturity_date],[is_dst])

END
