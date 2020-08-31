IF OBJECT_ID('UC_rec_gen_eligibility', 'UQ') IS NOT NULL 
BEGIN 
	ALTER TABLE rec_gen_eligibility DROP CONSTRAINT UC_rec_gen_eligibility
	ALTER TABLE rec_gen_eligibility ADD CONSTRAINT UC_rec_gen_eligibility UNIQUE (program_scope, gen_state_value_id, technology, state_value_id, tier_type, assignment_type, technology_sub_type, sub_tier_value_id)	
END
    