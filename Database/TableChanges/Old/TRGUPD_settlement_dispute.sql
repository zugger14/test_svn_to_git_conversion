
/****** Object:  Trigger [dbo].[TRGUPD_settlement_dispute]    Script Date: 05/26/2009 17:58:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGUPD_settlement_dispute]
ON [dbo].[settlement_dispute]
FOR UPDATE
AS
UPDATE settlement_dispute SET update_user =  dbo.FNADBUser(), update_ts = getdate()  where  settlement_dispute.dispute_id in (select dispute_id from deleted)
