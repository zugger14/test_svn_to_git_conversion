IF COL_LENGTH('adiha_default_codes_values_possible', 'description') IS NOT NULL
BEGIN
    ALTER TABLE adiha_default_codes_values_possible ALTER COLUMN [description] VARCHAR(MAX)
END

GO