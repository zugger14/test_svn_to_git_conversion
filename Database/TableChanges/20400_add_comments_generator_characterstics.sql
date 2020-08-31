IF COL_LENGTH('generator_characterstics', 'comments') IS NULL
BEGIN
    alter table dbo.generator_characterstics add comments varchar(1000)
	alter table dbo.[operation_unit_configuration] add comments varchar(1000)
	alter table dbo.process_long_term_generation_unit_cost add comments varchar(1000)
	alter table dbo.process_short_term_generation_unit_cost add comments varchar(1000)
	alter table dbo.process_generation_unit_cost add comments varchar(1000)
END
ELSE
BEGIN
    PRINT 'Column:comments Already Exists.'
END