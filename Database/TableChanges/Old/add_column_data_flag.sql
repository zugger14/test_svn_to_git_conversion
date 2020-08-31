IF COL_LENGTH('maintain_field_deal', 'data_flag') IS NULL
BEGIN
    ALTER TABLE maintain_field_deal ADD data_flag CHAR(1)
END
GO


IF COL_LENGTH('maintain_field_template_detail', 'data_flag') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD data_flag CHAR(1)
END
GO