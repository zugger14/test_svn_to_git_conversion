SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_generic_mapping_values]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_generic_mapping_values]
GO

CREATE TRIGGER [dbo].[TRGUPD_generic_mapping_values]
ON [dbo].[generic_mapping_values]
FOR UPDATE
AS
    UPDATE generic_mapping_values
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM generic_mapping_values os
      INNER JOIN DELETED d ON os.mapping_table_id = d.mapping_table_id
GO
