IF COL_LENGTH(N'source_emir', N'counterparty_domicile') IS NOT NULL
BEGIN
	EXEC sp_rename 'source_emir.counterparty_domicile', 'counterparty_country', 'COLUMN'
END
ELSE 
BEGIN
	IF COL_LENGTH(N'source_emir', N'counterparty_country') IS NULL
	BEGIN
		ALTER TABLE source_emir ADD counterparty_country VARCHAR(500)
	END
END