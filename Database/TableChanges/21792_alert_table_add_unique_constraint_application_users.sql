IF NOT EXISTS(
       SELECT 'X'
       FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS
       WHERE  CONSTRAINT_NAME = 'UC_application_users_id'
   )
BEGIN
    ALTER TABLE application_users
	ADD CONSTRAINT UC_application_users_id UNIQUE (application_users_id)
END
