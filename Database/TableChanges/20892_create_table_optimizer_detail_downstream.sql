IF OBJECT_ID('dbo.optimizer_detail_downstream') IS NULL
BEGIN
	CREATE TABLE dbo.optimizer_detail_downstream
	(
		optimizer_detail_downstream_id	INT IDENTITY(1,1),
		optimizer_header_id INT CONSTRAINT FK_optimizer_detail_downstream_optimizer_header_id_optimizer_header_optimizer_header_id REFERENCES dbo.optimizer_header(optimizer_header_id) ON DELETE CASCADE,
		flow_date DATETIME,	
		transport_deal_id INT CONSTRAINT FK_optimizer_detail_downstream_transport_deal_id_source_deal_header_source_deal_header_id REFERENCES dbo.source_deal_header(source_deal_header_id),
		source_deal_header_id INT CONSTRAINT FK_optimizer_detail_downstream_source_deal_header_id_source_deal_header_source_deal_header_id REFERENCES dbo.source_deal_header(source_deal_header_id),
		source_deal_detail_id INT CONSTRAINT FK_optimizer_detail_downstream_source_deal_detail_id_source_deal_detail_source_deal_detail_id REFERENCES dbo.source_deal_detail(source_deal_detail_id) ON DELETE CASCADE,
		deal_volume	NUMERIC(28,8),
		[create_user] VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]	DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(100) NULL,
		[update_ts]	DATETIME NULL
	 )
END
ELSE
	PRINT 'Table optimizer_detail_downstream already Exists.'