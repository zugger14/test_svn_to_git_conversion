
/****** Object:  Trigger [dbo].[TRGINS_SOURCE_product]    Script Date: 05/20/2009 17:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGINS_location_price_index]
ON [dbo].[location_price_index]
FOR INSERT
AS
UPDATE location_price_index SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  location_price_index.location_price_index_id in (select location_price_index_id from inserted)
