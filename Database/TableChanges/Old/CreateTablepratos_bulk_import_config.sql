/****** Object:  Table [dbo].[pratos_bulk_import_config]    Script Date: 12/05/2011 04:41:28 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_bulk_import_config]') AND type in (N'U'))
--DROP TABLE [dbo].[pratos_bulk_import_config]
--GO


--/****** Object:  Table [dbo].[pratos_bulk_import_config]    Script Date: 12/05/2011 04:41:20 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

--SET ANSI_PADDING ON
--GO

CREATE TABLE [dbo].[pratos_bulk_import_config](
	[bulk_import] [char](1) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

if not exists(select * from pratos_bulk_import_config)
	insert into pratos_bulk_import_config(bulk_import)
	select 'n'
