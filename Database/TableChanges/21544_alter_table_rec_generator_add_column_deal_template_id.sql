IF COL_LENGTH('rec_generator', 'deal_template_id') IS NULL
BEGIN
    ALTER TABLE rec_generator ADD deal_template_id INT NULL
END