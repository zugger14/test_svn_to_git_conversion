
/****** Object:  Table [dbo].[formula_editor_sql]    Script Date: 01/25/2013 16:05:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[formula_editor_sql]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[formula_editor_sql](
	[formula_sql_id] [int] IDENTITY(1,1) NOT NULL,
	[formula_id] [int] NOT NULL,
	[formula_sql] [varchar](max) NOT NULL,
	[create_user] [varchar](50) NOT NULL,
	[create_ts] [datetime] NOT NULL,
	[update_user] [varchar](50) NOT NULL,
	[update_ts] [datetime] NOT NULL,
 CONSTRAINT [PK_formula_editor_sql] PRIMARY KEY CLUSTERED 
(
	[formula_sql_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Trigger [TRGUPD_formula_editor_sql]    Script Date: 01/25/2013 16:05:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_formula_editor_sql]'))
EXEC dbo.sp_executesql @statement = N'
CREATE TRIGGER [dbo].[TRGUPD_formula_editor_sql]
ON [dbo].[formula_editor_sql]
FOR UPDATE
AS
UPDATE formula_editor_sql SET update_user = dbo.FNADBUser(), update_ts = getdate() where  formula_editor_sql.formula_sql_id in (select formula_sql_id from deleted)

'
GO
/****** Object:  Trigger [TRGINS_formula_editor_sql]    Script Date: 01/25/2013 16:05:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_formula_editor_sql]'))
EXEC dbo.sp_executesql @statement = N'
CREATE TRIGGER [dbo].[TRGINS_formula_editor_sql]
ON [dbo].[formula_editor_sql]
FOR INSERT
AS
UPDATE formula_editor_sql SET create_user = dbo.FNADBUser(), create_ts = getdate() where  formula_editor_sql.formula_sql_id in (select formula_sql_id from inserted)

'
GO
/****** Object:  ForeignKey [FK_formula_editor_sql_formula_editor]    Script Date: 01/25/2013 16:05:36 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_formula_editor_sql_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[formula_editor_sql]'))
ALTER TABLE [dbo].[formula_editor_sql]  WITH CHECK ADD  CONSTRAINT [FK_formula_editor_sql_formula_editor] FOREIGN KEY([formula_sql_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_formula_editor_sql_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[formula_editor_sql]'))
ALTER TABLE [dbo].[formula_editor_sql] CHECK CONSTRAINT [FK_formula_editor_sql_formula_editor]
GO
