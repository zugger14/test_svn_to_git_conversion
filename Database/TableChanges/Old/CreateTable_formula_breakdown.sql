IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_formula_breakdown_formula_editor]') AND parent_object_id = OBJECT_ID(N'[dbo].[formula_breakdown]'))
ALTER TABLE [dbo].[formula_breakdown] DROP CONSTRAINT [FK_formula_breakdown_formula_editor]
GO
/****** Object:  Table [dbo].[formula_breakdown]    Script Date: 04/22/2011 12:41:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[formula_breakdown]') AND type in (N'U'))
DROP TABLE [dbo].[formula_breakdown]
GO
/****** Object:  Table [dbo].[formula_breakdown]    Script Date: 04/22/2011 12:41:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[formula_breakdown](
	[formula_breakdown_id] [int] IDENTITY(1,1) NOT NULL,
	[formula_id] [int] NOT NULL,
	[nested_id] [INT] NULL,
	[formula_level] [int] NULL,
	[func_name] [varchar](100) NULL,
	[arg_no_for_next_func] [tinyint] NULL,
	[parent_nested_id] [int] NULL,
	[level_func_sno] [tinyint] NULL,
	[parent_level_func_sno] [tinyint] NULL,
	[arg1] [varchar](50) NULL,
	[arg2] [varchar](50) NULL,
	[arg3] [varchar](50) NULL,
	[arg4] [varchar](50) NULL,
	[arg5] [varchar](50) NULL,
	[arg6] [varchar](50) NULL,
	[arg7] [varchar](50) NULL,
	[arg8] [varchar](50) NULL,
	[arg9] [varchar](50) NULL,
	[arg10] [varchar](50) NULL,
	[arg11] [varchar](50) NULL,
	[arg12] [varchar](50) NULL,
	[eval_value] [float] NULL,
	[create_user] [varchar](100) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](100) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_formula_breakdown] PRIMARY KEY CLUSTERED 
(
	[formula_breakdown_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[formula_breakdown]  WITH CHECK ADD  CONSTRAINT [FK_formula_breakdown_formula_editor] FOREIGN KEY([formula_id])
REFERENCES [dbo].[formula_editor] ([formula_id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[formula_breakdown] CHECK CONSTRAINT [FK_formula_breakdown_formula_editor]
GO


/****** Object:  Trigger [TRGINS_formula_breakdown]    Script Date: 04/22/2011 12:42:44 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_formula_breakdown]'))
DROP TRIGGER [dbo].[TRGINS_formula_breakdown]
GO
/****** Object:  Trigger [dbo].[TRGINS_formula_breakdown]    Script Date: 04/22/2011 12:42:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRGINS_formula_breakdown]
ON [dbo].[formula_breakdown]
FOR INSERT
AS
UPDATE formula_breakdown SET create_user =dbo.FNADBUser(), create_ts = getdate() where  formula_breakdown.formula_breakdown_id in (select formula_breakdown_id from inserted)



GO
/****** Object:  Trigger [TRGINS_formula_breakdown]    Script Date: 04/22/2011 12:42:44 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_formula_breakdown]'))
DROP TRIGGER [dbo].[TRGUPD_formula_breakdown]
GO
/****** Object:  Trigger [dbo].[TRGINS_formula_breakdown]    Script Date: 04/22/2011 12:42:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TRGUPD_formula_breakdown]
ON [dbo].[formula_breakdown]
FOR UPDATE
AS
UPDATE formula_breakdown SET create_user =dbo.FNADBUser(), create_ts = getdate() where  formula_breakdown.formula_breakdown_id in (select formula_breakdown_id from deleted)



GO