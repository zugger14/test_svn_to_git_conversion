/****** Object:  Table [dbo].[user_defined_deal_fields]    Script Date: 09/30/2011 23:32:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_defined_deal_fields](
	[udf_deal_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NULL,
	[udf_template_id] [int] NULL,
	[udf_value] [varchar](8000) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_user_defined_deal_fields] PRIMARY KEY CLUSTERED 
(
	[udf_deal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields]') AND name = N'IX_user_defined_deal_fields')
CREATE NONCLUSTERED INDEX [IX_user_defined_deal_fields] ON [dbo].[user_defined_deal_fields] 
(
	[source_deal_header_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields]') AND name = N'IX_user_defined_deal_fields_1')
CREATE NONCLUSTERED INDEX [IX_user_defined_deal_fields_1] ON [dbo].[user_defined_deal_fields] 
(
	[udf_template_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[user_defined_deal_fields_template]    Script Date: 09/30/2011 23:32:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields_template]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[user_defined_deal_fields_template](
	[udf_template_id] [int] IDENTITY(1,1) NOT NULL,
	[template_id] [int] NOT NULL,
	[field_name] [int] NULL,
	[Field_label] [varchar](50) NULL,
	[Field_type] [varchar](100) NULL,
	[data_type] [varchar](50) NULL,
	[is_required] [char](1) NULL,
	[sql_string] [varchar](500) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[udf_type] [char](1) NOT NULL,
	[sequence] [int] NULL,
	[field_size] [int] NULL,
	[field_id] [int] NULL,
	[default_value] [varchar](500) NULL,
	[book_id] [int] NULL,
	[udf_group] [int] NULL,
	[udf_tabgroup] [int] NULL,
	[formula_id] [int] NULL,
	[internal_field_type] [int] NULL,
	[currency_field_id] [int] NULL,
 CONSTRAINT [PK_user_defined_deal_fields_template] PRIMARY KEY CLUSTERED 
(
	[udf_template_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields_template]') AND name = N'IX_user_defined_deal_fields_template')
CREATE UNIQUE NONCLUSTERED INDEX [IX_user_defined_deal_fields_template] ON [dbo].[user_defined_deal_fields_template] 
(
	[template_id] ASC,
	[field_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Default [DF__user_defi__udf_t__78EAF436]    Script Date: 09/30/2011 23:32:12 ******/
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__user_defi__udf_t__78EAF436]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields_template]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__user_defi__udf_t__78EAF436]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[user_defined_deal_fields_template] ADD  DEFAULT ('u') FOR [udf_type]
END


End
GO
/****** Object:  ForeignKey [FK_user_defined_deal_fields_source_deal_header]    Script Date: 09/30/2011 23:32:12 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_defined_deal_fields_source_deal_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields]'))
ALTER TABLE [dbo].[user_defined_deal_fields]  WITH NOCHECK ADD  CONSTRAINT [FK_user_defined_deal_fields_source_deal_header] FOREIGN KEY([source_deal_header_id])
REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_defined_deal_fields_source_deal_header]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields]'))
ALTER TABLE [dbo].[user_defined_deal_fields] NOCHECK CONSTRAINT [FK_user_defined_deal_fields_source_deal_header]
GO
/****** Object:  ForeignKey [FK_user_defined_deal_fields_user_defined_deal_fields_template]    Script Date: 09/30/2011 23:32:12 ******/
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_defined_deal_fields_user_defined_deal_fields_template]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields]'))
ALTER TABLE [dbo].[user_defined_deal_fields]  WITH NOCHECK ADD  CONSTRAINT [FK_user_defined_deal_fields_user_defined_deal_fields_template] FOREIGN KEY([udf_template_id])
REFERENCES [dbo].[user_defined_deal_fields_template] ([udf_template_id])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_user_defined_deal_fields_user_defined_deal_fields_template]') AND parent_object_id = OBJECT_ID(N'[dbo].[user_defined_deal_fields]'))
ALTER TABLE [dbo].[user_defined_deal_fields] NOCHECK CONSTRAINT [FK_user_defined_deal_fields_user_defined_deal_fields_template]
GO
