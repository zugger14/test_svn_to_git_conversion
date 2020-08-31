
/****** Object:  Table [dbo].[contract_charge_type]    Script Date: 12/10/2008 17:39:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[contract_charge_type](
	[contract_charge_type_id] [int] IDENTITY(1,1) NOT NULL,
	[contract_charge_desc] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[sub_id] [int] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_contract_charge_type] PRIMARY KEY CLUSTERED 
(
	[contract_charge_type_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF