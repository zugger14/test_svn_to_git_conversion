SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_data_component]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_data_component]
GO

CREATE TRIGGER [dbo].[TRGUPD_data_component]
ON [dbo].[data_component]
FOR UPDATE
AS
    UPDATE data_component
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM data_component t
      INNER JOIN DELETED u ON t.data_component_id = u.data_component_id
GO