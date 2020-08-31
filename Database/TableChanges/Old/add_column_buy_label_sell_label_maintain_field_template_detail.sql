IF COL_LENGTH('maintain_field_template_detail', 'buy_label') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD buy_label VARCHAR(500)
END
GO

IF COL_LENGTH('maintain_field_template_detail', 'sell_label') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD sell_label VARCHAR(500)
END
GO