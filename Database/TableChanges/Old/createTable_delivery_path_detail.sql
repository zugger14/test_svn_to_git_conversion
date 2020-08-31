/****** Object:  Table [dbo].[delivery_path_detail]    Script Date: 09/16/2009 15:24:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[delivery_path_detail]') AND type in (N'U'))
DROP TABLE [dbo].[delivery_path_detail]
GO
CREATE TABLE [dbo].[delivery_path_detail](
	[delivery_path_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[Path_id] [int] null,
	[Path_name] [varchar](50) NULL,
	[From_meter] [int] NULL,
	[To_meter] [int] NULL
	
 CONSTRAINT [FK_delivery_path_detail] PRIMARY KEY CLUSTERED 
(
	[delivery_path_detail_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
