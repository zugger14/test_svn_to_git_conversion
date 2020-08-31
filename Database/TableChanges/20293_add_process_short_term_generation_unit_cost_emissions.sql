
IF COL_LENGTH('process_generation_unit_cost', 'fuel_coal_intensity') IS NULL
BEGIN
    ALTER TABLE dbo.process_generation_unit_cost ADD fuel_gas_intensity float
	ALTER TABLE dbo.process_generation_unit_cost ADD OBA_target float
	ALTER TABLE dbo.process_generation_unit_cost ADD carbon_cost float
	ALTER TABLE dbo.process_generation_unit_cost ADD fuel_coal_intensity float
END
ELSE
BEGIN
    PRINT 'Column: fuel_coal_intensity is already exist.'
END


IF COL_LENGTH('process_short_term_generation_unit_cost', 'emissions') IS NULL
BEGIN
    ALTER TABLE dbo.process_short_term_generation_unit_cost ADD emissions float
	ALTER TABLE dbo.process_short_term_generation_unit_cost ADD emissions_intensity float
	ALTER TABLE dbo.process_short_term_generation_unit_cost ADD reduced_baseline float
	ALTER TABLE dbo.process_short_term_generation_unit_cost ADD carbon_cost float
END
ELSE
BEGIN
    PRINT 'Column:emissions is already exist.'
END

