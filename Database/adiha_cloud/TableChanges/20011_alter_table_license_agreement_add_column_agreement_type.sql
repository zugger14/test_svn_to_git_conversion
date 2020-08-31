IF COL_LENGTH('license_agreement', 'agreement_type') IS NULL
BEGIN
    ALTER TABLE license_agreement ADD agreement_type VARCHAR(50)
	PRINT 'Column agreement_type added in table license_agreement.'
END
ELSE
BEGIN
	PRINT 'Column agreement_type already exists in table license_agreement.'
END