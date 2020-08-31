IF COL_LENGTH('source_deal_cva_simulation', 'd_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD d_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_exposure_to_us Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'd_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD d_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_exposure_to_them Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'effective_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD effective_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'effective_exposure_to_us Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'effective_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD effective_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'effective_exposure_to_them Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'd_effective_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD d_effective_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_effective_exposure_to_us Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'd_effective_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD d_effective_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_effective_exposure_to_them Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'cva_with_collateral') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD cva_with_collateral FLOAT NULL
END
ELSE
BEGIN
    PRINT 'cva_with_collateral Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'dva_with_collateral') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD dva_with_collateral FLOAT NULL
END
ELSE
BEGIN
    PRINT 'dva_with_collateral Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'd_cva_with_collateral') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD d_cva_with_collateral FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_cva_with_collateral Already Exists.'
END

IF COL_LENGTH('source_deal_cva_simulation', 'd_dva_with_collateral') IS NULL
BEGIN
    ALTER TABLE source_deal_cva_simulation ADD d_dva_with_collateral FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_dva_with_collateral Already Exists.'
END