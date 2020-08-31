
IF COL_LENGTH('stmt_contract_settlement_detail','source_deal_header_id') IS NULL
BEGIN
    ALTER TABLE stmt_contract_settlement_detail ADD source_deal_header_id INT NULL
END
ELSE
PRINT 'source_deal_header_id column already Exists'


IF COL_LENGTH('stmt_contract_settlement_detail','source_deal_detail_id') IS NULL
BEGIN
    ALTER TABLE stmt_contract_settlement_detail ADD source_deal_detail_id INT NULL
END
ELSE
PRINT 'source_deal_detail_id column already Exists'