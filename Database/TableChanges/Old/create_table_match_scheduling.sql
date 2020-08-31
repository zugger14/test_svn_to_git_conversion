SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[match_group_shipment]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].match_group_shipment
    (
    [match_group_shipment_id]   INT IDENTITY(1, 1) NOT NULL,
    [match_group_id]		INT NOT NULL,
    [match_group_shipment]		VARCHAR(MAX) NULL,
    [create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]				DATETIME NULL DEFAULT GETDATE(),
    [update_user]			VARCHAR(50) NULL,
    [update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table match_group_shipment EXISTS'
END
 
GO

