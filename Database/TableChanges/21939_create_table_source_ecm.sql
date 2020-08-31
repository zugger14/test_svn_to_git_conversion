IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[source_ecm]') AND TYPE IN (N'U'))
BEGIN
	CREATE TABLE [dbo].[source_ecm] (
		[id] INT IDENTITY(1, 1) CONSTRAINT [pk_source_ecm_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[source_deal_header_id] INT NULL,
		[deal_id] VARCHAR(200) NULL,
		[sub_book_id] INT NULL,
		[physical_financial_flag] CHAR(1), 
		[document_id] VARCHAR(100),
		[document_usage] VARCHAR(10),
		[sender_id] VARCHAR(50),
		[receiver_id] VARCHAR(50),
		[receiver_role] VARCHAR(25),
		[document_version] VARCHAR(25),
		[market] VARCHAR(50),
		[commodity] VARCHAR(100),
		[transaction_type] VARCHAR(25),
		[delivery_point_area] VARCHAR(50),
		[buyer_party] VARCHAR(100),
		[seller_party] VARCHAR(100),
		[load_type] VARCHAR(25),
		[agreement] VARCHAR(50),
		[currency] VARCHAR(50),
		[total_volume] FLOAT,
		[total_volume_unit] VARCHAR(50),
		[trade_date] DATETIME,
		[capacity_unit] VARCHAR(50),
		[price_unit_currency] VARCHAR(50),
		[price_unit_capacity_unit] VARCHAR(50),
		[total_contract_value] FLOAT,
		[delivery_start] DATETIME,
		[delivery_end] DATETIME,
		[contract_capacity] FLOAT,
		[price] FLOAT,
		[buyer_hubcode] VARCHAR(50),
		[seller_hubcode] VARCHAR(50),
		[trader_name] VARCHAR(50),
		[ecm_document_type] VARCHAR(20),
		[broker_fee] FLOAT,
		[reference_document_id] VARCHAR(100),
		[reference_document_version] VARCHAR(25), 
		[report_type] INT NULL,
		[create_date_from] DATETIME NULL,
		[create_date_to] DATETIME NULL,	
		[acer_submission_status] INT NULL,
		[acer_submission_date] DATETIME NULL,
		[acer_confirmation_date] DATETIME NULL,
		[process_id] VARCHAR(100) NULL,
		[error_validation_message] VARCHAR(MAX) NULL,
		[file_export_name] VARCHAR(100) NULL,
		[create_ts] DATETIME NULL,
		[create_user] VARCHAR(50) DEFAULT([dbo].[FNADBUser]())
	) ON [PRIMARY]
END
GO