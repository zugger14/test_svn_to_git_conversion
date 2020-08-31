
/****** Object:  Trigger [dbo].[TRGINS_settlement_dispute]    Script Date: 05/26/2009 17:58:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGINS_settlement_dispute]
ON [dbo].[settlement_dispute]
FOR INSERT
AS
UPDATE settlement_dispute SET create_user =  dbo.FNADBUser(), create_ts = getdate() 
FROM settlement_dispute s INNER JOIN inserted i ON s.dispute_id=i.dispute_id
