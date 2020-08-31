
/****** Object:  Trigger [dbo].[TRGUPD_SOURCE_product]    Script Date: 05/20/2009 17:01:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGUPD_location_price_index]
ON [dbo].[location_price_index]
FOR UPDATE
AS
UPDATE location_price_index SET update_user =  dbo.FNADBUser(), update_ts = getdate()  where  location_price_index.location_price_index_id in (select location_price_index_id from deleted)
