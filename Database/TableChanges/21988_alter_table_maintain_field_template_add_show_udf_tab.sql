IF COL_LENGTH('maintain_field_template', 'show_udf_tab') IS NULL
BEGIN
    ALTER TABLE maintain_field_template ADD show_udf_tab NCHAR(1)
END
GO

--select * from maintain_field_template