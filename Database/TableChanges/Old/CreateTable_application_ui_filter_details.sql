SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[application_ui_filter_details]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[application_ui_filter_details] (
    	[application_ui_filter_details_id]		INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[application_ui_filter_id]				INT REFERENCES application_ui_filter(application_ui_filter_id) NOT NULL,
    	[application_field_id]					INT REFERENCES application_ui_template_fields(application_field_id) NULL,
    	[report_column_id]						INT REFERENCES data_source_column(data_source_column_id) NULL,
    	[field_value]							VARCHAR(50) NULL,
    	[create_user]							VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]								DATETIME NULL DEFAULT GETDATE(),
    	[update_user]							VARCHAR(50) NULL,
    	[update_ts]								DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table application_ui_filter_details EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_application_ui_filter_details]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_application_ui_filter_details]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_application_ui_filter_details]
ON [dbo].[application_ui_filter_details]
FOR UPDATE
AS
    UPDATE t
    SET    update_user     = dbo.FNADBUser(),
           update_ts       = GETDATE()
    FROM   application_ui_filter_details t
    INNER JOIN DELETED u ON  t.[application_ui_filter_details_id] = u.[application_ui_filter_details_id]
GO