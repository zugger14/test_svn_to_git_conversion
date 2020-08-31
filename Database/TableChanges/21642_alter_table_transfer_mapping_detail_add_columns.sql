IF COL_LENGTH('transfer_mapping_detail','template_id') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD template_id INT NULL
END

IF COL_LENGTH('transfer_mapping_detail','transfer_template_id') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD transfer_template_id INT NULL
END

IF COL_LENGTH('transfer_mapping_detail','transfer_type') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD transfer_type INT NULL
END

IF COL_LENGTH('transfer_mapping_detail','index_adder') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD index_adder INT NULL
END

IF COL_LENGTH('transfer_mapping_detail','fixed_adder') IS NULL
BEGIN
	ALTER TABLE transfer_mapping_detail
	ADD fixed_adder float NULL
END