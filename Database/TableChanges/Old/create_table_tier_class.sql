SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[tier_class]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[tier_class] (
    	[tier_class_id]   INT IDENTITY(1, 1) NOT NULL,
    	[deal_id]		  INT NULL,
    	[cert_entity]	  VARCHAR(100) NULL,
    	[tier/class]	  INT NULL,
    	[jurisdiction]    INT NULL,
    	[year]			  INT NULL,
    	[and/or]		  BIT NULL,
    	[create_user]     VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]       DATETIME NULL DEFAULT GETDATE(),
    	[update_user]     VARCHAR(50) NULL,
    	[update_ts]       DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table tier_class EXISTS'
END
 