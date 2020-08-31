SELECT * FROM dbo.application_functions WHERE function_id = 10161711

SELECT * FROM dbo.application_functions WHERE function_call LIKE '% Position Report%'

UPDATE application_functions
SET
function_name ='Delete Bid Offer Formulator Header Delete'
WHERE function_id = 10161711