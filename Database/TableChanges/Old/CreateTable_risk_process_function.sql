
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_risk_process_function_process_control_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[risk_process_function]'))
ALTER TABLE [dbo].[risk_process_function] DROP CONSTRAINT [FK_risk_process_function_process_control_header]
GO

/****** Object:  Table [dbo].[risk_process_function]    Script Date: 04/12/2009 20:31:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[risk_process_function]') AND type in (N'U'))
DROP TABLE [dbo].[risk_process_function]
/****** Object:  Table [dbo].[risk_process_function]    Script Date: 04/12/2009 20:31:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[risk_process_function](
	[function_id] [int] NOT NULL,
	[function_description] [varchar](100) NULL,
	[group_name] [varchar](100) NULL,
	[process_id] [int] NULL,
 CONSTRAINT [PK_risk_process_function] PRIMARY KEY CLUSTERED 
(
	[function_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[risk_process_function]  WITH CHECK ADD  CONSTRAINT [FK_risk_process_function_process_control_header] FOREIGN KEY([process_id])
REFERENCES [dbo].[process_control_header] ([process_id])
GO
ALTER TABLE [dbo].[risk_process_function] CHECK CONSTRAINT [FK_risk_process_function_process_control_header]