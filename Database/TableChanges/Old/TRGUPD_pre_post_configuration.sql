SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[testing].[TRGUPD_pre_post_configuration]', 'TR') IS NOT NULL
    DROP TRIGGER [testing].[TRGUPD_pre_post_configuration]
GO

CREATE TRIGGER [testing].[TRGUPD_pre_post_configuration]
ON [testing].[pre_post_configuration]
FOR UPDATE
AS
    UPDATE pre_post_configuration
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pre_post_configuration cd
      INNER JOIN DELETED d ON cd.row_id = d.row_id
GO