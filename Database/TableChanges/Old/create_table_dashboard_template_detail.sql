SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
 
IF OBJECT_ID(N'[dbo].[dashboard_template_detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dashboard_template_detail]
    (
		[dashboard_template_detail_id]		INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		[dashboard_template_id]				INT REFERENCES dashboard_template(dashboard_template_id) NOT NULL,
		[template_data_type]				INT REFERENCES static_data_value(value_id) NOT NULL,
		[category]							NVARCHAR(100) NOT NULL,
		[template_data_type_order]			INT NOT NULL,
		[category_order]					INT NOT NULL,
		[filter]							NVARCHAR(4000) NULL,
		[option_editable]					NCHAR(1) NULL,
		[option_formula]					INT NULL,
		[create_user]						NVARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]							DATETIME NULL DEFAULT GETDATE(),
		[update_user]						NVARCHAR(50) NULL,
		[update_ts]							DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table dashboard_template_detail EXISTS'
END
GO

--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_dashboard_template_detail]'))
    DROP TRIGGER [dbo].[TRGUPD_dashboard_template_detail]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_dashboard_template_detail]
ON [dbo].[dashboard_template_detail]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE dashboard_template_detail
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM dashboard_template_detail dt
        INNER JOIN DELETED d ON d.dashboard_template_detail_id = dt.dashboard_template_detail_id
    END
END
GO



