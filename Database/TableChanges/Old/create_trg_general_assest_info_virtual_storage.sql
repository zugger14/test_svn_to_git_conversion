SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_general_assest_info_virtual_storage]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_general_assest_info_virtual_storage]
GO

CREATE TRIGGER [dbo].[TRGUPD_general_assest_info_virtual_storage]
ON [dbo].[general_assest_info_virtual_storage]
FOR UPDATE
AS
    UPDATE general_assest_info_virtual_storage
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM general_assest_info_virtual_storage t
      INNER JOIN DELETED u ON t.general_assest_id = u.general_assest_id
GO
