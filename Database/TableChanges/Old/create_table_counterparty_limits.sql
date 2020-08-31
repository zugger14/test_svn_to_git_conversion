/****** Object:  Table [dbo].[counterparty_limits]    Script Date: 01/18/2010 16:15:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[counterparty_limits](
	[counterparty_limit_id] [int] IDENTITY(1,1) NOT NULL,
	[limit_type] [int] NULL,
	[applies_to] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[counterparty_id] [int] NULL,
	[internal_rating_id] [int] NULL,
	[volume_limit_type] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[limit_value] [float] NULL,
	[uom_id] [int] NULL,
	[formula_id] [int] NULL,
	[currency_id] [int] NULL,
 CONSTRAINT [PK_counterparty_limits] PRIMARY KEY CLUSTERED 
(
	[counterparty_limit_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[counterparty_limits]  WITH NOCHECK ADD  CONSTRAINT [FK_counterparty_limits_formula_editor] FOREIGN KEY([formula_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
GO
ALTER TABLE [dbo].[counterparty_limits] CHECK CONSTRAINT [FK_counterparty_limits_formula_editor]
GO
ALTER TABLE [dbo].[counterparty_limits]  WITH NOCHECK ADD  CONSTRAINT [FK_counterparty_limits_source_counterparty] FOREIGN KEY([counterparty_id])
REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
GO
ALTER TABLE [dbo].[counterparty_limits] CHECK CONSTRAINT [FK_counterparty_limits_source_counterparty]
GO
ALTER TABLE [dbo].[counterparty_limits]  WITH NOCHECK ADD  CONSTRAINT [FK_counterparty_limits_source_currency] FOREIGN KEY([currency_id])
REFERENCES [dbo].[source_currency] ([source_currency_id])
GO
ALTER TABLE [dbo].[counterparty_limits] CHECK CONSTRAINT [FK_counterparty_limits_source_currency]
GO
ALTER TABLE [dbo].[counterparty_limits]  WITH NOCHECK ADD  CONSTRAINT [FK_counterparty_limits_source_uom] FOREIGN KEY([uom_id])
REFERENCES [dbo].[source_uom] ([source_uom_id])
GO
ALTER TABLE [dbo].[counterparty_limits] CHECK CONSTRAINT [FK_counterparty_limits_source_uom]
GO
ALTER TABLE [dbo].[counterparty_limits]  WITH NOCHECK ADD  CONSTRAINT [FK_counterparty_limits_static_data_value] FOREIGN KEY([limit_type])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[counterparty_limits] CHECK CONSTRAINT [FK_counterparty_limits_static_data_value]
GO
ALTER TABLE [dbo].[counterparty_limits]  WITH NOCHECK ADD  CONSTRAINT [FK_counterparty_limits_static_data_value1] FOREIGN KEY([internal_rating_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[counterparty_limits] CHECK CONSTRAINT [FK_counterparty_limits_static_data_value1]