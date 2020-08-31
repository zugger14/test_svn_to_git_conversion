SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[tbl_sims_status]', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[tbl_sims_status](
	[sid] [int] IDENTITY(1,1) NOT NULL,
	[process_id] [varchar](50) NULL,
	[curve_id] [int] NULL,
	[sims_status] [char](1) NULL
	)
END
ELSE
BEGIN
    PRINT 'Table tbl_sims_status EXISTS'
END

GO


