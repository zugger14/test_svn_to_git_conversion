IF COL_LENGTH('maintain_udf_detail_values', 'udf_values') IS NOT NULL
BEGIN
    ALTER TABLE maintain_udf_detail_values ALTER COLUMN udf_values VARCHAR(8000)
END
GO