IF COL_LENGTH('deal_confirmation_rule', 'deal_template_id') IS NULL
BEGIN
    ALTER TABLE deal_confirmation_rule ADD deal_template_id INT
END
GO