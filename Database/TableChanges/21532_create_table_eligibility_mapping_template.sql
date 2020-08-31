/*
	Create new table eligibility_mapping_template
*/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[eligibility_mapping_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[eligibility_mapping_template] (
		[template_id]		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[template_name]		VARCHAR(500) NOT NULL UNIQUE,
		[create_user]		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]			DATETIME NULL DEFAULT GETDATE(),
		[update_user]		VARCHAR(50) NULL,
		[update_ts]			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table eligibility_mapping_template EXISTS'
END
 
GO