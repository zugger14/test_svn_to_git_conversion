IF COL_LENGTH('process_short_term_generation_unit_cost', 'comments') IS not NULL
BEGIN
	alter table dbo.process_short_term_generation_unit_cost drop column comments
END

IF COL_LENGTH('operation_unit_configuration', 'comments') IS not NULL
BEGIN
	alter table dbo.[operation_unit_configuration] drop column comments
END
IF COL_LENGTH('process_long_term_generation_unit_cost', 'comments') IS not NULL
BEGIN
	alter table dbo.process_long_term_generation_unit_cost drop column comments
END

IF COL_LENGTH('process_generation_unit_cost', 'comments') IS not NULL
BEGIN

	alter table dbo.process_generation_unit_cost drop column comments
END
