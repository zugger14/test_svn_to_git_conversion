SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[matching_detail_audit]', N'U') IS NULL
BEGIN
	 CREATE TABLE [dbo].[matching_detail_audit](
		[audit_id] INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		[fas_link_detail_id] INT NOT NULL,
		[link_id] INT NOT NULL,
		[source_deal_header_id] [int] NOT NULL,
		[matched_volume] FLOAT NULL,
		[set] [char](1) NULL,
		[create_user] VARCHAR(50) NULL,
		[create_ts] DATETIME NULL,
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL,
		[user_action] VARCHAR(50)
	)
END
ELSE
BEGIN
    PRINT 'Table matching_detail_audit EXISTS'
END