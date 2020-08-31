IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_rec_gen_eligibility') 
BEGIN
	ALTER TABLE rec_gen_eligibility ADD CONSTRAINT UC_rec_gen_eligibility UNIQUE (program_scope, gen_state_value_id, technology, state_value_id, tier_type,assignment_type)
END
ELSE 
	PRINT 'Unique Key UC_rec_gen_eligibility already exists.'