IF COL_LENGTH('rec_generator', 'eligibility_mapping_template_id') IS NULL
BEGIN
    ALTER TABLE rec_generator
	ADD eligibility_mapping_template_id INT NULL REFERENCES eligibility_mapping_template (template_id)
END

GO