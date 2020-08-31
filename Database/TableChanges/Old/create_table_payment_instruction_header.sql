/****** Object:  Table [dbo].[payment_instruction_header]    Script Date: 12/30/2008 11:27:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

DROP TABLE [dbo].[payment_instruction_header]
go

CREATE TABLE [dbo].[payment_instruction_header](
	[payment_ins_header_id] [int] IDENTITY(1,1) NOT NULL,
	[counterparty_id] [int] NULL,
	[payment_ins_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[prod_date] [datetime] NULL,
	[comments] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_payment_instruction_header] PRIMARY KEY CLUSTERED 
(
	[payment_ins_header_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF