IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_risk_process_function_map_detail_publish_activity_table]') AND parent_object_id = OBJECT_ID(N'[dbo].[risk_process_function_map_detail]'))
ALTER TABLE [dbo].[risk_process_function_map_detail] DROP CONSTRAINT [FK_risk_process_function_map_detail_publish_activity_table]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_risk_process_function_map_detail_risk_process_function_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[risk_process_function_map_detail]'))
ALTER TABLE [dbo].[risk_process_function_map_detail] DROP CONSTRAINT [FK_risk_process_function_map_detail_risk_process_function_header]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_risk_process_function_map_detail_risk_process_function_map]') AND parent_object_id = OBJECT_ID(N'[dbo].[risk_process_function_map_detail]'))
ALTER TABLE [dbo].[risk_process_function_map_detail] DROP CONSTRAINT [FK_risk_process_function_map_detail_risk_process_function_map]
GO

/****** Object:  Table [dbo].[risk_process_function_map_detail]    Script Date: 04/12/2009 20:34:10 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[risk_process_function_map_detail]') AND type in (N'U'))
DROP TABLE [dbo].[risk_process_function_map_detail]

/****** Object:  Table [dbo].[risk_process_function_map_detail]    Script Date: 04/12/2009 20:34:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[risk_process_function_map_detail](
	[function_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[function_map_id] [int] NULL,
	[risk_control_id] [int] NULL,
	[sequence_number] [int] NULL,
	[Publish_table_id] [int] NULL,
	[column_value] [nvarchar](100) NULL,
	[column_value_name] [nvarchar](100) NULL,
	incr_id INT NULL,
 CONSTRAINT [PK_risk_process_function_map_detail] PRIMARY KEY CLUSTERED 
(
	[function_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[risk_process_function_map_detail]  WITH CHECK ADD  CONSTRAINT [FK_risk_process_function_map_detail_publish_activity_table] FOREIGN KEY([Publish_table_id])
REFERENCES [dbo].[publish_activity_table] ([publish_table_id])
GO
ALTER TABLE [dbo].[risk_process_function_map_detail] CHECK CONSTRAINT [FK_risk_process_function_map_detail_publish_activity_table]
GO
ALTER TABLE [dbo].[risk_process_function_map_detail]  WITH CHECK ADD  CONSTRAINT [FK_risk_process_function_map_detail_risk_process_function_header] FOREIGN KEY([risk_control_id])
REFERENCES [dbo].[process_risk_controls] ([risk_control_id])
GO
ALTER TABLE [dbo].[risk_process_function_map_detail] CHECK CONSTRAINT [FK_risk_process_function_map_detail_risk_process_function_header]
GO
ALTER TABLE [dbo].[risk_process_function_map_detail]  WITH CHECK ADD  CONSTRAINT [FK_risk_process_function_map_detail_risk_process_function_map] FOREIGN KEY([function_map_id])
REFERENCES [dbo].[risk_process_function_map] ([function_map_id])
GO
ALTER TABLE [dbo].[risk_process_function_map_detail] CHECK CONSTRAINT [FK_risk_process_function_map_detail_risk_process_function_map]