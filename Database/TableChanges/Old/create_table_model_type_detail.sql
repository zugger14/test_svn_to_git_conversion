IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_model_type_detail_formula_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[cash_flow_model_type_detail]'))
ALTER TABLE [dbo].[cash_flow_model_type_detail] DROP CONSTRAINT [FK_model_type_detail_formula_id]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_model_type_detail_model_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[cash_flow_model_type_detail]'))
ALTER TABLE [dbo].[cash_flow_model_type_detail] DROP CONSTRAINT [FK_model_type_detail_model_id]
GO
/****** Object:  Table [dbo].[cash_flow_model_type_detail]    Script Date: 07/20/2010 15:53:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cash_flow_model_type_detail]') AND type in (N'U'))
DROP TABLE [dbo].[cash_flow_model_type_detail]
GO
/****** Object:  Table [dbo].[cash_flow_model_type_detail]    Script Date: 07/20/2010 15:53:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cash_flow_model_type_detail](
	[model_type_id] [int] IDENTITY(1,1) NOT NULL,
	[model_type] INT  NULL,
	[description] VARCHAR(100) NULL,
	[formula_id] INT NULL,
	[model_id] INT NULL
 CONSTRAINT [PK_cash_flow_model_type_detail] PRIMARY KEY CLUSTERED 
(
	[model_type_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cash_flow_model_type_detail]  WITH NOCHECK ADD  CONSTRAINT [FK_model_type_detail_formula_id] FOREIGN KEY([formula_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
GO
ALTER TABLE [dbo].[cash_flow_model_type_detail] CHECK CONSTRAINT [FK_model_type_detail_formula_id]
GO
ALTER TABLE [dbo].[cash_flow_model_type_detail]  WITH NOCHECK ADD  CONSTRAINT [FK_model_type_detail_model_id] FOREIGN KEY([model_id])
REFERENCES [dbo].[cash_flow_model_type] ([model_id])
GO
ALTER TABLE [dbo].[cash_flow_model_type_detail] CHECK CONSTRAINT [FK_model_type_detail_model_id]
GO
