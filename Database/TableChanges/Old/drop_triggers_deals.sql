IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name]='TRGUPD_deal_detail_hour')
	drop TRIGGER [TRGUPD_deal_detail_hour] 
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name]='TRGINS_deal_detail_hour')
	drop TRIGGER [TRGINS_deal_detail_hour]
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name]='TRGDEL_deal_detail_hour')
	drop TRIGGER [TRGDEL_deal_detail_hour] 
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name]='TRGDEL_source_deal_HEADER')
	drop TRIGGER [TRGDEL_source_deal_HEADER]
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name]='TRGUPD_SOURCE_DEAL_HEADER')
	drop TRIGGER [TRGUPD_SOURCE_DEAL_HEADER]
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name]='TRGINS_source_deal_HEADER')
	drop TRIGGER [TRGINS_source_deal_HEADER] 
	
	
IF EXISTS(SELECT 1 FROM sys.triggers WHERE [name]='TRGDEL_SOURCE_DEAL_DETAIL')
	drop TRIGGER [TRGDEL_SOURCE_DEAL_DETAIL] 
