IF COL_LENGTH('fas_eff_hedge_rel_type', 'externalization') IS NULL
BEGIN
	ALTER TABLE fas_eff_hedge_rel_type ADD externalization VARCHAR(1)
	PRINT 'Column fas_eff_hedge_rel_type.externalization added.'
END
ELSE
BEGIN
	PRINT 'Column fas_eff_hedge_rel_type.externalization already exists.'
END
GO

