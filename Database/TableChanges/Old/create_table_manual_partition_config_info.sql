

/****** Object:  Table [dbo].[manual_partition_config_info]    Script Date: 05/03/2012 16:09:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[manual_partition_config_info]', N'U') IS NULL

CREATE TABLE [dbo].[manual_partition_config_info](
	mp_id					NUMERIC(18, 0) IDENTITY(1,1) NOT NULL,
	archive_type_value_id	NUMERIC(18, 0) NULL,
	curve_id				VARCHAR(200) NULL,
	period					NUMERIC(18, 0) NULL,
	del_flg					BIT NOT NULL DEFAULT 1 ,
 CONSTRAINT [PK_manual_partition_config_info] PRIMARY KEY CLUSTERED 
(
	[mp_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO




