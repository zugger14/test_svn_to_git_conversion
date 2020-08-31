SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[source_deal_groups]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[source_deal_groups](
    	[source_deal_groups_id]       INT IDENTITY(1, 1) NOT NULL,
    	[source_deal_groups_name]     VARCHAR(100) NULL,
    	[source_deal_header_id]		  INT NULL,
    	[term_from]                   DATETIME NULL,
    	[term_to]                     DATETIME NULL,
    	[location_id]                 INT NULL,
    	[curve_id]					  INT NULL,
    	[detail_flag]                 INT NULL,
    	[leg]						  INT NULL,
    	[create_user]                 VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                   DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                 VARCHAR(50) NULL,
    	[update_ts]                   DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table source_deal_groups EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_source_deal_groups]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_source_deal_groups]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_source_deal_groups]
ON [dbo].[source_deal_groups]
FOR UPDATE
AS
    UPDATE source_deal_groups
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM source_deal_groups t
      INNER JOIN DELETED u ON t.[source_deal_groups_id] = u.[source_deal_groups_id]
GO