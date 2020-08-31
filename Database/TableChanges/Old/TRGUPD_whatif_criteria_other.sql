SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_whatif_criteria_other]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_whatif_criteria_other]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_whatif_criteria_other]
ON [dbo].[whatif_criteria_other]
FOR UPDATE
AS
    UPDATE whatif_criteria_other
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM whatif_criteria_other t
      INNER JOIN DELETED u ON t.whatif_criteria_other_id = u.whatif_criteria_other_id
GO