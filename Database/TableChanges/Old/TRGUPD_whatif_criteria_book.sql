SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_whatif_criteria_book]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_whatif_criteria_book]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_whatif_criteria_book]
ON [dbo].[whatif_criteria_book]
FOR UPDATE
AS
    UPDATE whatif_criteria_book
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM whatif_criteria_book t
      INNER JOIN DELETED u ON t.whatif_criteria_book_id = u.whatif_criteria_book_id
GO