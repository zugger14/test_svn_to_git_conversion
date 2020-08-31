
IF COL_LENGTH('process_generation_unit_cost','outage') IS NULL 
begin
	alter table dbo.process_generation_unit_cost add outage bit
	alter table dbo.process_short_term_generation_unit_cost add max_unit_actual int
end