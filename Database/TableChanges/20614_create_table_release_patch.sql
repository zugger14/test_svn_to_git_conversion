IF OBJECT_ID('release_patch') IS NULL
BEGIN
    CREATE TABLE [dbo].[release_patch]
    (
    	release_patch_id     INT IDENTITY(1, 1) PRIMARY KEY,
    	[description]        NVARCHAR(255),
    	[patch_executor]     NVARCHAR(255),
    	[create_user]		 VARCHAR(255) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]          DATETIME NULL DEFAULT GETDATE()
    )
END


