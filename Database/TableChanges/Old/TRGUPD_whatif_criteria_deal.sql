SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_whatif_criteria_deal]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_whatif_criteria_deal]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_whatif_criteria_deal]
ON [dbo].[whatif_criteria_deal]
FOR UPDATE
AS
    UPDATE whatif_criteria_deal
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM whatif_criteria_deal t
      INNER JOIN DELETED u ON t.whatif_criteria_deal_id = u.whatif_criteria_deal_id
GO