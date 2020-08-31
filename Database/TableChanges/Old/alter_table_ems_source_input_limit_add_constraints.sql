IF OBJECT_ID('IX_ems_source_input_limit','UQ') IS NOT NULL 
BEGIN
	ALTER TABLE dbo.ems_source_input_limit
		DROP CONSTRAINT IX_ems_source_input_limit
END	
GO
	ALTER TABLE dbo.ems_source_input_limit ADD CONSTRAINT
		IX_ems_source_input_limit UNIQUE NONCLUSTERED 
		(
		uom_id,
		source_generator_id,
		criteria_id,
		curve_id,
		series_value_id
		) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]