
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[contract_report_template_views]') AND type in (N'U'))
DROP TABLE [dbo].[contract_report_template_views]
GO 


/****** Object:  Table [dbo].[contract_report_template_views]    Script Date: 09/18/2009 17:09:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[contract_report_template_views](
	[contract_report_template_views_id] [int] IDENTITY(1,1) NOT NULL,
	[template_id] INT,
	[data_source_id] INT
 CONSTRAINT [PK_contract_report_template_views] PRIMARY KEY CLUSTERED 
(
	[contract_report_template_views_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]