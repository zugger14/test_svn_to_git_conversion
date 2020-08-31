IF OBJECT_ID('TRGUPD_matching_detail') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_matching_detail]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_matching_detail]
ON [dbo].[matching_detail]
FOR UPDATE
AS
    UPDATE matching_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM matching_detail t
      INNER JOIN DELETED u ON t.[link_id] = u.[link_id]
GO