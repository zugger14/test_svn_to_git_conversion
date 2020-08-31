SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 
IF OBJECT_ID(N'[dbo].[deal_pricing_quality_filter]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[deal_pricing_quality_filter] (
		[deal_pricing_quality_filter_id]   INT IDENTITY(1, 1) NOT NULL,
		[deal_pricing_quality_filter_name] VARCHAR(100) NULL,
		[grid_json]                VARCHAR(MAX) NULL,
		[user_name]                VARCHAR(50) NOT NULL REFERENCES application_users(user_login_id),
		[create_user]              VARCHAR(50) NULL DEFAULT [dbo].[FNADBUser](),
		[create_ts]                DATETIME NULL DEFAULT GETDATE(),
		[update_user]              VARCHAR(50) NULL,
		[update_ts]                DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table deal_pricing_quality_filter EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_deal_pricing_quality_filter]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_deal_pricing_quality_filter]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_deal_pricing_quality_filter]
ON [dbo].[deal_pricing_quality_filter]
FOR UPDATE
AS
    UPDATE deal_pricing_quality_filter
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM deal_pricing_quality_filter t
      INNER JOIN DELETED u ON t.[deal_pricing_quality_filter_id] = u.[deal_pricing_quality_filter_id]
GO