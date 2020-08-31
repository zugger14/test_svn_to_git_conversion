SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_rec_assignment_priority_order]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_rec_assignment_priority_order]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_rec_assignment_priority_order]
ON [dbo].[rec_assignment_priority_order]
FOR UPDATE
AS
    UPDATE rec_assignment_priority_order
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM rec_assignment_priority_order t
      INNER JOIN DELETED u ON t.rec_assignment_priority_order_id = u.rec_assignment_priority_order_id
GO
