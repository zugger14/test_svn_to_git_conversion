SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_pipeline_up_down_service_k]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pipeline_up_down_service_k]
GO

CREATE TRIGGER [dbo].[TRGUPD_pipeline_up_down_service_k]
ON [dbo].[pipeline_up_down_service_k]
FOR UPDATE
AS
    UPDATE pipeline_up_down_service_k
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pipeline_up_down_service_k os
      INNER JOIN DELETED d ON os.pipeline_up_down_service_k_id = d.pipeline_up_down_service_k_id
GO