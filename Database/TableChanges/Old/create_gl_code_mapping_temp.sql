/****** Object:  Table [dbo].[gl_code_mapping_temp]    Script Date: 07/03/2013 14:36:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO
 
IF OBJECT_ID(N'[dbo].[gl_code_mapping_temp]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[gl_code_mapping_temp]
	(
		[gl_account_id]           [INT] IDENTITY(1, 1) NOT NULL,
		[gl_account_description]  [VARCHAR](200) NULL,
		[gl_account_value_id]     [INT] NULL,
		[account_type_id]         [INT] NULL,
		[column_map_name]         [VARCHAR](100) NULL,
		[sequence_order]          [INT] NULL,
		CONSTRAINT [PK_gl_code_mapping_temp] PRIMARY KEY CLUSTERED([gl_account_id] ASC)
		WITH (
			PAD_INDEX = OFF,
			STATISTICS_NORECOMPUTE = OFF,
			IGNORE_DUP_KEY = OFF,
			ALLOW_ROW_LOCKS = ON,
			ALLOW_PAGE_LOCKS = ON
		) ON [PRIMARY]
	) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table table_name EXISTS'
END
 
GO

SET ANSI_PADDING OFF
GO


