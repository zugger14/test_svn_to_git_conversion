
IF COL_LENGTH('source_deal_pnl', 'must_run_volume') IS NULL
BEGIN
    ALTER TABLE dbo.source_deal_pnl ADD must_run_volume numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail ADD must_run_volume numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl ADD dispatch_volume numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail ADD dispatch_volume numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl ADD must_run_market_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail ADD must_run_market_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl ADD must_run_contract_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail ADD must_run_contract_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl ADD dispatch_market_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail ADD dispatch_market_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl ADD dispatch_contract_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail ADD dispatch_contract_value numeric(18,6)
	
END
ELSE
BEGIN
    PRINT 'Column:must_run_volume Already Exists.'
END


IF COL_LENGTH('source_deal_pnl_arch1', 'must_run_volume') IS NULL
BEGIN
    ALTER TABLE dbo.source_deal_pnl_arch1 ADD must_run_volume numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch1 ADD must_run_volume numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch1 ADD dispatch_volume numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch1 ADD dispatch_volume numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch1 ADD must_run_market_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch1 ADD must_run_market_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch1 ADD must_run_contract_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch1 ADD must_run_contract_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch1 ADD dispatch_market_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch1 ADD dispatch_market_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch1 ADD dispatch_contract_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch1 ADD dispatch_contract_value numeric(18,6)
	
END
ELSE
BEGIN
    PRINT 'arch1:Column:must_run_volume Already Exists.'
END


IF COL_LENGTH('source_deal_pnl_arch2', 'must_run_volume') IS NULL
BEGIN
    ALTER TABLE dbo.source_deal_pnl_arch2 ADD must_run_volume numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch2 ADD must_run_volume numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch2 ADD dispatch_volume numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch2 ADD dispatch_volume numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch2 ADD must_run_market_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch2 ADD must_run_market_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch2 ADD must_run_contract_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch2 ADD must_run_contract_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch2 ADD dispatch_market_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch2 ADD dispatch_market_value numeric(18,6)
	
	ALTER TABLE dbo.source_deal_pnl_arch2 ADD dispatch_contract_value numeric(18,6)
	ALTER TABLE dbo.source_deal_pnl_detail_arch2 ADD dispatch_contract_value numeric(18,6)
	
END
ELSE
BEGIN
    PRINT 'arch2:Column:must_run_volume Already Exists.'
END

