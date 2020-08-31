SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[matching_header]', N'U') IS NULL
BEGIN
	 CREATE TABLE [dbo].[matching_header](

		[link_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		--[link_id] INT  REFERENCES matching_header(link_id) NOT NULL,
		[fas_book_id] [int] NULL,
		[perfect_hedge] [char](1) NULL,
		[fully_dedesignated] [char](1) NULL,
		[link_description] [varchar](1000) NULL,
		[eff_test_profile_id] [int] NULL,
		[link_effective_date] [datetime] NOT NULL,
		[link_type_value_id] [int] NULL,
		[link_active] [char](1) NULL,
		[original_link_id] [int] NULL,
		[link_end_date] [datetime] NULL,
		[dedesignated_percentage] [float] NULL,
		[total_matched_volume] FLOAT  NULL,
		[group1] [int] NULL,
		[group2] [int] NULL,
		[group3] [int] NULL,
		[group4] [int] NULL,
		[lock] [char](1) NULL,
		[create_user]                    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]                      DATETIME NULL DEFAULT GETDATE(),
		[update_user]                    VARCHAR(50) NULL,
		[update_ts]                      DATETIME NULL
	)

END
ELSE
BEGIN
    PRINT 'Table matching_header EXISTS'
END


--drop table matching_header


