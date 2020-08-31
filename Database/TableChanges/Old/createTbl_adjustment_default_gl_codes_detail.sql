
CREATE TABLE [dbo].[adjustment_default_gl_codes_detail](
	[detail_id] [int] IDENTITY(1,1) NOT NULL,
	[default_gl_id] [int] NOT NULL,
	[debit_gl_number] [int] NOT NULL,
	[credit_gl_number] [int] NOT NULL,
	[debit_volume_multiplier] [int] NOT NULL,
	[credit_volume_multiplier] [int] NOT NULL,
	[add_volume] [varchar](1) NULL,
	[debit_remark] [varchar](100) NULL,
	[credit_remark] [varchar](100) NULL,
	[uom_id] [int] NULL,
	[term_start] [datetime] NULL,
	[term_end] [datetime] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[adjustment_default_gl_codes_detail]  WITH CHECK ADD  CONSTRAINT [FK_adjustment_default_gl_codes_detail_adjustment_default_gl_codes] FOREIGN KEY([default_gl_id])
REFERENCES [dbo].[adjustment_default_gl_codes] ([default_gl_id])
GO
ALTER TABLE [dbo].[adjustment_default_gl_codes_detail] CHECK CONSTRAINT [FK_adjustment_default_gl_codes_detail_adjustment_default_gl_codes]
GO
ALTER TABLE [dbo].[adjustment_default_gl_codes_detail]  WITH CHECK ADD  CONSTRAINT [FK_adjustment_default_gl_codes_detail_source_uom] FOREIGN KEY([uom_id])
REFERENCES [dbo].[source_uom] ([source_uom_id])
GO
ALTER TABLE [dbo].[adjustment_default_gl_codes_detail] CHECK CONSTRAINT [FK_adjustment_default_gl_codes_detail_source_uom]