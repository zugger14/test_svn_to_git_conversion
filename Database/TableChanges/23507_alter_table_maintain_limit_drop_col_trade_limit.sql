IF COL_LENGTH('maintain_limit', 'trade_date') IS NULL
BEGIN
ALTER TABLE maintain_limit DROP COLUMN trade_date
END