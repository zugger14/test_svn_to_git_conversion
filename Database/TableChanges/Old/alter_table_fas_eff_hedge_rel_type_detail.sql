IF COL_LENGTH('fas_eff_hedge_rel_type_detail', 'source_system_book_id1') IS NULL
BEGIN
	ALTER TABLE fas_eff_hedge_rel_type_detail ADD source_system_book_id1 INT
END
ELSE
BEGIN
	PRINT 'Column Already Exists.'
END	

IF COL_LENGTH('fas_eff_hedge_rel_type_detail', 'source_system_book_id2') IS NULL
BEGIN
	ALTER TABLE fas_eff_hedge_rel_type_detail ADD source_system_book_id2 INT
END
ELSE
BEGIN
	PRINT 'Column Already Exists.'
END	

IF COL_LENGTH('fas_eff_hedge_rel_type_detail', 'source_system_book_id3') IS NULL
BEGIN
	ALTER TABLE fas_eff_hedge_rel_type_detail ADD source_system_book_id3 INT
END
ELSE
BEGIN
	PRINT 'Column Already Exists.'
END	

IF COL_LENGTH('fas_eff_hedge_rel_type_detail', 'source_system_book_id4') IS NULL
BEGIN
	ALTER TABLE fas_eff_hedge_rel_type_detail ADD source_system_book_id4 INT
END
ELSE
BEGIN
	PRINT 'Column Already Exists.'
END