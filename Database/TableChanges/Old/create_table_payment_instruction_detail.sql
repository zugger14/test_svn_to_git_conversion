/****** Object:  Table [dbo].[payment_instruction_detail]    Script Date: 12/30/2008 11:26:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
DROP TABLE [dbo].[payment_instruction_detail]
GO

CREATE TABLE [dbo].[payment_instruction_detail](
	[payment_ins_detail_Id] [int] IDENTITY(1,1) NOT NULL,
	[payment_ins_header_id] [int] NULL,
	[invoice_line_item_id] [int] NULL,
	[calc_detail_id] [int] NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_payment_instruction_detail] PRIMARY KEY CLUSTERED 
(
	[payment_ins_detail_Id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[payment_instruction_detail]  WITH CHECK ADD  CONSTRAINT [FK_payment_instruction_detail_payment_instruction_header] FOREIGN KEY([payment_ins_header_id])
REFERENCES [dbo].[payment_instruction_header] ([payment_ins_header_id])
ON DELETE CASCADE