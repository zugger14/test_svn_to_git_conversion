SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[location_ranking]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[location_ranking]
    (
    [location_ranking_id]		INT IDENTITY(1, 1) PRIMARY KEY,
	[rank_id]					INT REFERENCES [dbo].[static_data_value] (value_id) NULL,
    [effective_date]			DATETIME NULL,
	[location_id]				INT SPARSE NULL,
	[path_id]					INT SPARSE NULL,
    [create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]					DATETIME NULL DEFAULT GETDATE(),
    [update_user]				VARCHAR(50) NULL,
    [update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table location_ranking EXISTS'
END
 
GO
