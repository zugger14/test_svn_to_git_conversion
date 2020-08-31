SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_whatif_criteria_measure]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_whatif_criteria_measure]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_whatif_criteria_measure]
ON [dbo].[whatif_criteria_measure]
FOR UPDATE
AS
    UPDATE whatif_criteria_measure
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM whatif_criteria_measure t
      INNER JOIN DELETED u ON t.criteria_id = u.criteria_id
GO