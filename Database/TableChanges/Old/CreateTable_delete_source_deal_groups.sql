SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[delete_source_deal_groups]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[delete_source_deal_groups](
    	[delete_source_deal_groups_id]     INT IDENTITY(1, 1) NOT NULL,
    	[source_deal_groups_id]            INT,
    	[source_deal_groups_name]          VARCHAR(100) NULL,
    	[source_deal_header_id]            INT NULL,
    	[term_from]                        DATETIME NULL,
    	[term_to]                          DATETIME NULL,
    	[location_id]                      INT NULL,
    	[curve_id]                         INT NULL,
    	[detail_flag]                      INT NULL,
    	[leg]                              INT NULL,
    	[create_user]                      VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                        DATETIME NULL DEFAULT GETDATE(),
    	[delete_user]                      VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[delete_ts]                        DATETIME NULL DEFAULT GETDATE()
    )
END
ELSE
BEGIN
    PRINT 'Table delete_source_deal_groups EXISTS'
END
 
GO
