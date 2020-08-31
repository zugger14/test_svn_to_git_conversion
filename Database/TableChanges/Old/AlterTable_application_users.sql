/*
select * from application_users
*/

IF NOT EXISTS (SELECT 'x' FROM information_schema.columns WHERE table_name = 'application_users' AND column_name = 'timezone_id')
	ALTER TABLE application_users ADD timezone_id INT
