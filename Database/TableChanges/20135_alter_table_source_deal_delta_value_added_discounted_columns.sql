IF COL_LENGTH('source_deal_delta_value', 'dis_market_value_delta') IS NULL
BEGIN
    ALTER TABLE source_deal_delta_value ADD dis_market_value_delta FLOAT NULL
END
ELSE
BEGIN
    PRINT 'dis_market_value_delta Already Exists.'
END

IF COL_LENGTH('source_deal_delta_value', 'dis_contract_value_delta') IS NULL
BEGIN
    ALTER TABLE source_deal_delta_value ADD dis_contract_value_delta FLOAT NULL
END
ELSE
BEGIN
    PRINT 'dis_contract_value_delta Already Exists.'
END

IF COL_LENGTH('source_deal_delta_value', 'dis_avg_value') IS NULL
BEGIN
    ALTER TABLE source_deal_delta_value ADD dis_avg_value FLOAT NULL
END
ELSE
BEGIN
    PRINT 'dis_avg_value Already Exists.'
END

IF COL_LENGTH('source_deal_delta_value', 'dis_delta_value') IS NULL
BEGIN
    ALTER TABLE source_deal_delta_value ADD dis_delta_value FLOAT NULL
END
ELSE
BEGIN
    PRINT 'dis_delta_value Already Exists.'
END

IF COL_LENGTH('source_deal_delta_value', 'dis_avg_delta_value') IS NULL
BEGIN
    ALTER TABLE source_deal_delta_value ADD dis_avg_delta_value FLOAT NULL
END
ELSE
BEGIN
    PRINT 'dis_avg_delta_value Already Exists.'
END