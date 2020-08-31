/*
	Create new table eligibility_mapping_template_detail
*/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[eligibility_mapping_template_detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[eligibility_mapping_template_detail] (
		[template_detail_id]	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		[template_id]			INT NOT NULL FOREIGN KEY REFERENCES [eligibility_mapping_template] (template_id),
		[state_value_id]		INT NOT NULL FOREIGN KEY REFERENCES [static_data_value] (value_id),
		[tier_id]				INT NOT NULL FOREIGN KEY REFERENCES [static_data_value] (value_id),
		[create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME NULL DEFAULT GETDATE(),
		[update_user]			VARCHAR(50) NULL,
		[update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table eligibility_mapping_template_detail EXISTS'
END
 
GO