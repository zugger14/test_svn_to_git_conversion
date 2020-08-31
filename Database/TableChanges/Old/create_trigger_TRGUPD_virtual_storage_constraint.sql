SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_virtual_storage_constraint]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_virtual_storage_constraint]
GO

CREATE TRIGGER [dbo].[TRGUPD_virtual_storage_constraint]
ON [dbo].[virtual_storage_constraint]
FOR UPDATE
AS
    UPDATE virtual_storage_constraint
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM virtual_storage_constraint t
      INNER JOIN DELETED u ON t.constraint_id = u.constraint_id
GO