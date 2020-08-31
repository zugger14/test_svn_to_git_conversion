SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_generic_mapping_header]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_generic_mapping_header]
GO

CREATE TRIGGER [dbo].[TRGUPD_generic_mapping_header]
ON [dbo].[generic_mapping_header]
FOR UPDATE
AS
    UPDATE generic_mapping_header
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM generic_mapping_header os
      INNER JOIN DELETED d ON os.mapping_table_id = d.mapping_table_id
GO
