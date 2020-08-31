
/****** Object:  Trigger [dbo].[TRGINS_bid_offer_formulator_header]    Script Date: 25/May/2009 17:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGINS_bid_offer_formulator_header]
ON [dbo].[bid_offer_formulator_header]
FOR INSERT
AS
UPDATE bid_offer_formulator_header SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  bid_offer_formulator_header.bid_offer_id in (select bid_offer_id from inserted)
