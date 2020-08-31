DECLARE @id INT

SELECT @id = function_id FROM application_functions WHERE function_desc = 'Setup Hedging Relationship Types IU' 

UPDATE application_functions SET file_path = '_accounting/derivative/accounting_strategy/setup_hedge_rel_type/setup.hedge.rel.type.php' WHERE function_id = @id