SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[company_source_sink_type_temp]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[company_source_sink_type_temp]
    (
    	company_source_sink_type_id  INT IDENTITY(1, 1) NOT NULL,
    	company_type_id              INT,
    	source_sink_type_id          INT,
    	process_id                   VARCHAR(100),
    	[create_user]                VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table company_source_sink_type_temp EXISTS'
END
 
GO