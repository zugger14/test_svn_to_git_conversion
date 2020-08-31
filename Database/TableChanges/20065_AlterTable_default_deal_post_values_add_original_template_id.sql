IF COL_LENGTH('default_deal_post_values', 'original_template_id') IS NULL
BEGIN
    ALTER TABLE default_deal_post_values ADD original_template_id INT
END
GO