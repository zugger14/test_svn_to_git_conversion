IF COL_LENGTH('setup_submission_rule', 'broker_id') IS NULL
BEGIN
   ALTER TABLE 
   /**
	 ADD column broker_id
	*/
   setup_submission_rule ADD broker_id INT
END
GO