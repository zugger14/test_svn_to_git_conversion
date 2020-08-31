
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_invoice_lineitem_default_glcode_fas_subsidiaries]') AND parent_object_id = OBJECT_ID(N'[dbo].[invoice_lineitem_default_glcode]'))
ALTER TABLE [dbo].[invoice_lineitem_default_glcode] DROP CONSTRAINT [FK_invoice_lineitem_default_glcode_fas_subsidiaries]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_invoice_lineitem_default_glcode_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[invoice_lineitem_default_glcode]'))
ALTER TABLE [dbo].[invoice_lineitem_default_glcode] DROP CONSTRAINT [FK_invoice_lineitem_default_glcode_static_data_value]

GO
/****** Object:  Table [dbo].[invoice_lineitem_default_glcode]    Script Date: 12/18/2008 13:18:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[invoice_lineitem_default_glcode]') AND type in (N'U'))
DROP TABLE [dbo].[invoice_lineitem_default_glcode]

Go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[invoice_lineitem_default_glcode](
	[default_id] [int] IDENTITY(1,1) NOT NULL,
	[invoice_line_item_id] [int] NULL,
	[sub_id] [int] NULL,
	[default_gl_id] [int] NULL,
	[estimated_actual] [char](1) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_invoice_lineitem_default_glcode] PRIMARY KEY CLUSTERED 
(
	[default_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_invoice_lineitem_default_glcode] UNIQUE NONCLUSTERED 
(
	[invoice_line_item_id] ASC,
	[sub_id] ASC,
	[estimated_actual] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[invoice_lineitem_default_glcode]  WITH CHECK ADD  CONSTRAINT [FK_invoice_lineitem_default_glcode_fas_subsidiaries] FOREIGN KEY([sub_id])
REFERENCES [dbo].[fas_subsidiaries] ([fas_subsidiary_id])
GO
ALTER TABLE [dbo].[invoice_lineitem_default_glcode] CHECK CONSTRAINT [FK_invoice_lineitem_default_glcode_fas_subsidiaries]
GO
ALTER TABLE [dbo].[invoice_lineitem_default_glcode]  WITH CHECK ADD  CONSTRAINT [FK_invoice_lineitem_default_glcode_static_data_value] FOREIGN KEY([invoice_line_item_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[invoice_lineitem_default_glcode] CHECK CONSTRAINT [FK_invoice_lineitem_default_glcode_static_data_value]