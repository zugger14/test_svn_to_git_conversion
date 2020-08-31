IF COL_LENGTH('fas_eff_hedge_rel_type', 'effectiveness_testing_not_required') IS NULL 
BEGIN
    ALTER TABLE fas_eff_hedge_rel_type 
	ADD effectiveness_testing_not_required VARCHAR(1) DEFAULT 'n'
	PRINT 'effectiveness_testing_not_required column added on table fas_eff_hedge_rel_type'
END
ELSE
BEGIN
	PRINT 'effectiveness_testing_not_required column Already Added'	
END
GO