SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[source_book_map_GL_codes]', N'U') IS NULL
BEGIN
  CREATE TABLE [dbo].[source_book_map_GL_codes] (
	[source_book_map_GL_codes_id] INT IDENTITY(1, 1) NOT NULL,
	[source_book_map_id] INT NULL,
	[gl_number_id_st_asset] [int] NULL,
	[gl_number_id_st_liab] [int] NULL,
	[gl_number_id_lt_asset] [int] NULL,
	[gl_number_id_lt_liab] [int] NULL,
	[gl_number_id_item_st_asset] [int] NULL,
	[gl_number_id_item_st_liab] [int] NULL,
	[gl_number_id_item_lt_asset] [int] NULL,
	[gl_number_id_item_lt_liab] [int] NULL,
	[gl_number_id_aoci] [int] NULL,
	[gl_number_id_pnl] [int] NULL,
	[gl_number_id_set] [int] NULL,
	[gl_number_id_cash] [int] NULL, 
	[gl_number_id_inventory] [int] NULL, 
	[gl_number_id_expense] [int] NULL, 
	[gl_number_id_gross_set] [int] NULL, 
	[gl_id_amortization] [int] NULL,
	[gl_id_interest] [int] NULL,
	[gl_first_day_pnl] [int] NULL, 
	[gl_id_st_tax_asset] [int] NULL, 
	[gl_id_st_tax_liab] [int] NULL, 
	[gl_id_lt_tax_asset] [int] NULL, 
	[gl_id_lt_tax_liab] [int] NULL, 
	[gl_id_tax_reserve] [int] NULL, 
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
  )
END 
ELSE
BEGIN
  PRINT 'Table source_book_map_GL_codes EXISTS'
END
GO

SET ANSI_PADDING OFF
GO

IF NOT EXISTS(
       SELECT 1
       FROM   INFORMATION_SCHEMA.COLUMNS
       WHERE  TABLE_SCHEMA = 'dbo'
              AND TABLE_NAME = 'source_book_map_GL_codes'
              AND COLUMN_NAME = 'create_ts'
              AND COLUMN_DEFAULT IS NOT NULL
   ) 
BEGIN
	ALTER TABLE [dbo].[source_book_map_GL_codes] ADD CONSTRAINT DF_source_book_map_GL_codes_create_ts DEFAULT GETDATE() FOR create_ts
	, CONSTRAINT DF_source_book_map_GL_codes_create_user DEFAULT dbo.FNADBUser() FOR create_user
END
GO


IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping] FOREIGN KEY([gl_number_id_st_asset])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping1', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping1] FOREIGN KEY([gl_number_id_st_liab])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping1]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping2', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping2] FOREIGN KEY([gl_number_id_lt_asset])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping2]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping3', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping3] FOREIGN KEY([gl_number_id_lt_liab])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping3]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping4', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping4] FOREIGN KEY([gl_number_id_item_st_asset])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping4]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping5', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping5] FOREIGN KEY([gl_number_id_item_st_liab])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping5]
 END 
 GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping6', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping6] FOREIGN KEY([gl_number_id_item_lt_asset])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping6]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping7', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping7] FOREIGN KEY([gl_number_id_item_lt_liab])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping7]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping8', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping8] FOREIGN KEY([gl_number_id_aoci])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping8]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping9', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping9] FOREIGN KEY([gl_number_id_pnl])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping9]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping10', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping10] FOREIGN KEY([gl_number_id_set])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping10]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping11', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping11] FOREIGN KEY([gl_id_amortization])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping11]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_gl_system_mapping13', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping13] FOREIGN KEY([gl_id_interest])
REFERENCES [dbo].[gl_system_mapping] ([gl_number_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_gl_system_mapping13]
END 
GO

IF OBJECT_ID(N'FK_source_book_map_GL_codes_source_book_mapping', N'F') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [FK_source_book_map_GL_codes_source_book_mapping] FOREIGN KEY([source_book_map_id])
REFERENCES [dbo].[source_system_book_map] ([book_deal_type_map_id])

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [FK_source_book_map_GL_codes_source_book_mapping]
END 
GO

IF OBJECT_ID(N'UC_source_book_map_id', N'UQ') IS NULL
BEGIN
ALTER TABLE [dbo].[source_book_map_GL_codes] WITH NOCHECK ADD CONSTRAINT [UC_source_book_map_id] UNIQUE(source_book_map_id)

ALTER TABLE [dbo].[source_book_map_GL_codes] CHECK CONSTRAINT [UC_source_book_map_id]
END 
GO