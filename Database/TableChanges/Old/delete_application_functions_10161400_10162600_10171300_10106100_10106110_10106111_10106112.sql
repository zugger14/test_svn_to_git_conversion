DELETE FROM dbo.application_functional_users where function_id IN 
(
	10161400,
	10162600,
	10171300,
	10106100, 
	10106110, 
	10106111, 
	10106112
)

DELETE FROM application_functions where function_id = 10161400
DELETE FROM application_functions where function_id = 10162600
DELETE FROM application_functions where function_id = 10171300
DELETE FROM application_functions where function_id = 10106100
DELETE FROM application_functions where function_id = 10106110
DELETE FROM application_functions where function_id = 10106111
DELETE FROM application_functions where function_id = 10106112

