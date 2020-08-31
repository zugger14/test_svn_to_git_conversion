IF COL_LENGTH('maintain_udf_detail', 'sequence_number') IS NULL
BEGIN
    ALTER TABLE maintain_udf_detail ADD sequence_number INT
END
GO