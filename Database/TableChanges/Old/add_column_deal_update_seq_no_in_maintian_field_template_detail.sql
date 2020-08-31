IF COL_LENGTH('maintain_field_template_detail', 'deal_update_seq_no') IS NULL
BEGIN
    ALTER TABLE maintain_field_template_detail ADD deal_update_seq_no INT
END
GO