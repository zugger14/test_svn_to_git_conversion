SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  Table [dbo].[trm_sap_status_log_detail]    Script Date: 07/06/2011 10:46:07 ******/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[trm_sap_status_log_detail]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[trm_sap_status_log_detail](
	[detail_status_id] [int] IDENTITY(1,1) NOT NULL,
	[header_status_id] [int] NOT NULL,
	[grid_id] VARCHAR(20),
	[counterparty_id] [int],
	[counterparty] VARCHAR(100) ,
	[material_id] VARCHAR(20),
	[profitcenter_id] VARCHAR(20),	
	[delivery_period] VARCHAR(8),
	[order_type] VARCHAR(20),
	[price] [numeric](38, 18),
	[volume] [numeric](38, 18) ,
	[uom] VARCHAR(20) NOT NULL,
	[status] VARCHAR(100),
	[message] VARCHAR(500),  
 CONSTRAINT [PK_trm_sap_status_log_detail] PRIMARY KEY CLUSTERED 
(
	[detail_status_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_trm_sap_status_log_detail_trm_sap_status_log_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[trm_sap_status_log_detail]'))
	ALTER TABLE [dbo].[trm_sap_status_log_detail]  WITH CHECK ADD  CONSTRAINT [FK_trm_sap_status_log_detail_trm_sap_status_log_header] FOREIGN KEY([header_status_id])
	REFERENCES [dbo].[trm_sap_status_log_header] ([header_status_id])
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_trm_sap_status_log_detail_trm_sap_status_log_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[trm_sap_status_log_detail]'))
	ALTER TABLE [dbo].[trm_sap_status_log_detail] CHECK CONSTRAINT [FK_trm_sap_status_log_detail_trm_sap_status_log_header]
GO
