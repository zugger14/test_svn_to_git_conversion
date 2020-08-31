IF OBJECT_ID('release_patch_detail') IS NULL
BEGIN
    CREATE TABLE [dbo].[release_patch_detail]
    (
    	release_patch_detail_id     INT IDENTITY(1, 1) PRIMARY KEY,
    	release_patch_id            INT FOREIGN KEY REFERENCES release_patch(release_patch_id),
    	[filename] NVARCHAR(4000),
    	[executed]                  NVARCHAR(20),
    	[copied]                    NVARCHAR(20),
    	[error]                     NVARCHAR(4000),
    	[sequence]                  INT
    )
END
