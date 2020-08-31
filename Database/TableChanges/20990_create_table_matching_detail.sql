SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[matching_detail]', N'U') IS NULL
BEGIN
	 CREATE TABLE [dbo].[matching_detail](

		[fas_link_detail_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[link_id] INT  REFERENCES matching_header(link_id) NOT NULL,
		[source_deal_header_id] [int] NOT NULL,
		[matched_volume] FLOAT NULL,
		[set] [char](1) NULL, -- 1 dataset1, 2 dataset2
		[create_user]                    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]                      DATETIME NULL DEFAULT GETDATE(),
		[update_user]                    VARCHAR(50) NULL,
		[update_ts]                      DATETIME NULL
	)

END
ELSE
BEGIN
    PRINT 'Table matching_detail EXISTS'
END

-- drop table matching_detail

