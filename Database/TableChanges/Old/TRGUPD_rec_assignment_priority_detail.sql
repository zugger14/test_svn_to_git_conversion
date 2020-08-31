SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_rec_assignment_priority_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].TRGUPD_rec_assignment_priority_detail
GO
 
CREATE TRIGGER [dbo].TRGUPD_rec_assignment_priority_detail
ON [dbo].[rec_assignment_priority_detail]
FOR UPDATE
AS
    UPDATE rec_assignment_priority_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM rec_assignment_priority_detail t
      INNER JOIN DELETED u ON t.rec_assignment_priority_detail_id = u.rec_assignment_priority_detail_id
GO
