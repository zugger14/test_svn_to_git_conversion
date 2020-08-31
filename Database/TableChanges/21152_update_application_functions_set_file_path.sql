DECLARE @id INT

SELECT @id = function_id FROM application_functions WHERE function_desc = 'Insert Hedging RelationShip'

UPDATE application_functions SET file_path = '_accounting\derivative\transaction_processing\des_of_a_hedge\view.link.php' WHERE function_id = @id

