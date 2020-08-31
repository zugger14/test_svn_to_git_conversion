
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_risk_process_function_map_process_risk_controls]') AND parent_object_id = OBJECT_ID(N'[dbo].[risk_process_function_map]'))
ALTER TABLE [dbo].[risk_process_function_map] DROP CONSTRAINT [FK_risk_process_function_map_process_risk_controls]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_risk_process_function_map_risk_process_function]') AND parent_object_id = OBJECT_ID(N'[dbo].[risk_process_function_map]'))
ALTER TABLE [dbo].[risk_process_function_map] DROP CONSTRAINT [FK_risk_process_function_map_risk_process_function]
GO

/****** Object:  Table [dbo].[risk_process_function_map]    Script Date: 04/12/2009 20:32:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[risk_process_function_map]') AND type in (N'U'))
DROP TABLE [dbo].[risk_process_function_map]
/****** Object:  Table [dbo].[risk_process_function_map]    Script Date: 04/12/2009 20:32:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[risk_process_function_map](
	[function_map_id] [int] IDENTITY(1,1) NOT NULL,
	[function_id] [int] NOT NULL,
	[risk_description_id] [int] NOT NULL,
 CONSTRAINT [PK_risk_process_function_map] PRIMARY KEY CLUSTERED 
(
	[function_map_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [IX_function_risk_control] UNIQUE NONCLUSTERED 
(
	[function_id] ASC,
	[risk_description_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[risk_process_function_map]  WITH CHECK ADD  CONSTRAINT [FK_risk_process_function_map_process_risk_controls] FOREIGN KEY([risk_description_id])
REFERENCES [dbo].[process_risk_description] ([risk_description_id])
GO
ALTER TABLE [dbo].[risk_process_function_map] CHECK CONSTRAINT [FK_risk_process_function_map_process_risk_controls]
GO
ALTER TABLE [dbo].[risk_process_function_map]  WITH CHECK ADD  CONSTRAINT [FK_risk_process_function_map_risk_process_function] FOREIGN KEY([function_id])
REFERENCES [dbo].[risk_process_function] ([function_id])
GO
ALTER TABLE [dbo].[risk_process_function_map] CHECK CONSTRAINT [FK_risk_process_function_map_risk_process_function]