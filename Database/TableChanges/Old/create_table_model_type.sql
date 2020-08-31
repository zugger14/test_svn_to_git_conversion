/****** Object:  Table [dbo].[cash_flow_model_type]    Script Date: 07/20/2010 15:53:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cash_flow_model_type]') AND type in (N'U'))
DROP TABLE [dbo].[cash_flow_model_type]
GO
/****** Object:  Table [dbo].[cash_flow_model_type]    Script Date: 07/20/2010 15:53:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cash_flow_model_type](
	[model_id] [int] IDENTITY(1,1) NOT NULL,
	[model_name] VARCHAR(100) NOT NULL
 CONSTRAINT [PK_cash_flow_model_type] PRIMARY KEY CLUSTERED 
(
	[model_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
