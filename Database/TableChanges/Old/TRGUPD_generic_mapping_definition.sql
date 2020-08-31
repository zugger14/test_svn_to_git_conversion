SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_generic_mapping_definition]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_generic_mapping_definition]
GO

CREATE TRIGGER [dbo].[TRGUPD_generic_mapping_definition]
ON [dbo].[generic_mapping_definition]
FOR UPDATE
AS
    UPDATE generic_mapping_definition
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM generic_mapping_definition os
      INNER JOIN DELETED d ON os.mapping_table_id = d.mapping_table_id
GO
