SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[deal_grouping_information]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_grouping_information](
    	[deal_grouping_information_id]     INT IDENTITY(1, 1) NOT NULL,
    	[template_id]                      INT NOT NULL REFERENCES source_deal_header_template(template_id),
    	[grouping_columns]                 VARCHAR(8000) NULL,
    	[create_user]                      VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                        DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                      VARCHAR(50) NULL,
    	[update_ts]                        DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table deal_grouping_information EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_grouping_information]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_grouping_information]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_grouping_information]
ON [dbo].[deal_grouping_information]
FOR UPDATE
AS
    UPDATE deal_grouping_information
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_grouping_information t
      INNER JOIN DELETED u ON t.[deal_grouping_information_id] = u.[deal_grouping_information_id]
GO