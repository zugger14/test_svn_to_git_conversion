/**
* add column matching_type (char(1)) for hedging relationship types
* sligal
* 11/06/2012
**/
IF COL_LENGTH('fas_eff_hedge_rel_type', 'matching_type') IS NULL
BEGIN
    ALTER TABLE fas_eff_hedge_rel_type ADD matching_type CHAR(1) NOT NULL DEFAULT('a')
END
GO