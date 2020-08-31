
/****** Object:  Trigger [dbo].[TRGUPD_power_outage]    Script Date: 05/26/2009 18:01:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGUPD_power_outage_detail]
ON [dbo].[power_outage_detail]
FOR UPDATE
AS
UPDATE power_outage_detail SET update_user =  dbo.FNADBUser(), update_ts = getdate()  where  power_outage_detail.power_outage_detail_id in (select power_outage_detail_id from deleted)
