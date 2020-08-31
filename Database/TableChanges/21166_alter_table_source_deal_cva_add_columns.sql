IF COL_LENGTH('source_deal_cva', 'd_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD d_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_exposure_to_us Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'd_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD d_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_exposure_to_them Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'effective_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD effective_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'effective_exposure_to_us Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'effective_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD effective_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'effective_exposure_to_them Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'd_effective_exposure_to_us') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD d_effective_exposure_to_us FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_effective_exposure_to_us Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'd_effective_exposure_to_them') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD d_effective_exposure_to_them FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_effective_exposure_to_them Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'cva_with_collateral') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD cva_with_collateral FLOAT NULL
END
ELSE
BEGIN
    PRINT 'cva_with_collateral Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'dva_with_collateral') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD dva_with_collateral FLOAT NULL
END
ELSE
BEGIN
    PRINT 'dva_with_collateral Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'd_cva_with_collateral') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD d_cva_with_collateral FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_cva_with_collateral Already Exists.'
END

IF COL_LENGTH('source_deal_cva', 'd_dva_with_collateral') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD d_dva_with_collateral FLOAT NULL
END
ELSE
BEGIN
    PRINT 'd_dva_with_collateral Already Exists.'
END