IF COL_LENGTH('maintain_field_deal', 'update_required') IS NULL
BEGIN
    ALTER TABLE maintain_field_deal ADD update_required CHAR(1)
END
ELSE PRINT 'Field already exists'
GO