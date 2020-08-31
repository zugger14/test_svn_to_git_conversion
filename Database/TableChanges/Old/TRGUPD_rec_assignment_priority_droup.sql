SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_rec_assignment_priority_group]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].TRGUPD_rec_assignment_priority_group
GO
 
CREATE TRIGGER [dbo].TRGUPD_rec_assignment_priority_group
ON [dbo].[rec_assignment_priority_group]
FOR UPDATE
AS
    UPDATE rec_assignment_priority_group
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM rec_assignment_priority_group t
      INNER JOIN DELETED u ON t.rec_assignment_priority_group_id = u.rec_assignment_priority_group_id
GO
