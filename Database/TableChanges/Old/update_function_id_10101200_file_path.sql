IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101200)
BEGIN
UPDATE application_functions
SET file_path = '_setup/setup_book_structure/setup.hedging.strat.php'
WHERE function_id = 10101200
END
--SELECT * FROM application_functions WHERE function_id = 10101200