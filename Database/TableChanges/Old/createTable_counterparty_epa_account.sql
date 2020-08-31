
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_counterparty_epa_account_source_counterparty]') AND parent_object_id = OBJECT_ID(N'[dbo].[counterparty_epa_account]'))
ALTER TABLE [dbo].[counterparty_epa_account] DROP CONSTRAINT [FK_counterparty_epa_account_source_counterparty]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_counterparty_epa_account_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[counterparty_epa_account]'))
ALTER TABLE [dbo].[counterparty_epa_account] DROP CONSTRAINT [FK_counterparty_epa_account_static_data_value]
GO

/****** Object:  Table [dbo].[counterparty_epa_account]    Script Date: 10/06/2009 12:50:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[counterparty_epa_account]') AND type in (N'U'))
DROP TABLE [dbo].[counterparty_epa_account]

/****** Object:  Table [dbo].[counterparty_epa_account]    Script Date: 10/06/2009 12:50:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[counterparty_epa_account](
	[counterparty_epa_account_id] [int] IDENTITY(1,1) NOT NULL,
	[counterparty_id] [int] NULL,
	[external_type_id] [int] NULL,
	[external_value] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_counterparty_epa_account] PRIMARY KEY CLUSTERED 
(
	[counterparty_epa_account_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[counterparty_epa_account]  WITH CHECK ADD  CONSTRAINT [FK_counterparty_epa_account_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
GO
ALTER TABLE [dbo].[counterparty_epa_account]  WITH CHECK ADD  CONSTRAINT [FK_counterparty_epa_account_static_data_value] FOREIGN KEY([external_type_id])
REFERENCES [dbo].[static_data_value] ([value_id])