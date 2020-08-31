IF COL_LENGTH('source_remit_standard','calc_id') IS NULL
	ALTER TABLE source_remit_standard ADD calc_id INT