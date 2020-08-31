GO
/****** Object:  Table [dbo].[commodity_mapping_ebase]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[commodity_mapping_ebase]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[commodity_mapping_ebase](
	[commodity_mapping_ebase_id] [int] IDENTITY(1,1) NOT NULL,
	[source_commodity_id] [INT] NOT NULL,
	[map_name] [VARCHAR] (50) NULL,
	CONSTRAINT [pk_commodity_mapping_ebase] PRIMARY KEY NONCLUSTERED (commodity_mapping_ebase_id),  
	CONSTRAINT [fk_commodity_mapping_ebase_source_commodity] FOREIGN KEY (source_commodity_id)
	REFERENCES source_commodity(source_commodity_id),
	--CONSTRAINT [uk_commodity_mapping_source_commodity] UNIQUE (source_commodity_id)


) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table commodity_mapping_ebase already EXISTS'
END

SET ANSI_PADDING OFF
GO