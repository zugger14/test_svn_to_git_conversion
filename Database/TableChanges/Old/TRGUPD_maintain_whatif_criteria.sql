SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_maintain_whatif_criteria]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_maintain_whatif_criteria]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_maintain_whatif_criteria]
ON [dbo].[maintain_whatif_criteria]
FOR UPDATE
AS
    UPDATE maintain_whatif_criteria
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM maintain_whatif_criteria t
      INNER JOIN DELETED u ON t.criteria_id = u.criteria_id
GO