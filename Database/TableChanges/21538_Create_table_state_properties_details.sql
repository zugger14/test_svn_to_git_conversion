/*
	Create new table state_properties_details
*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[state_properties_details]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[state_properties_details] (
		[state_properties_details_id]	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[state_value_id]		INT NOT NULL FOREIGN KEY REFERENCES [state_properties] (state_value_id),
		[technology_id]			INT NOT NULL,
		[technology_subtype_id]	INT,
		[tier_id]				INT NOT NULL,
		[price_index]			INT,
		[create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME NULL DEFAULT GETDATE(),
		[update_user]			VARCHAR(50) NULL,
		[update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ''state_properties_details'' EXISTS'
END
 
GO

