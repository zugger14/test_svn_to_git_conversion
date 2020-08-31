SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[data_component]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[data_component]
    (
    	[data_component_id]     INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    	[description]           NVARCHAR(255) NOT NULL,
    	[type]                  INT FOREIGN KEY REFERENCES static_data_value(value_id),
    	[data_source]           NVARCHAR(MAX),
    	[paramset_hash]         NVARCHAR(500),
    	[formula_id]            INT,
    	[create_user]           NVARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]             DATETIME NULL DEFAULT GETDATE(),
    	[update_user]           NVARCHAR(50) NULL,
    	[update_ts]             NVARCHAR NULL,
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table data_component EXISTS'
END

SET ANSI_PADDING OFF
GO


