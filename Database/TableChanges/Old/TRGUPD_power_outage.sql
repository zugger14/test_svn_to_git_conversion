
/****** Object:  Trigger [dbo].[TRGUPD_source_generator]    Script Date: 05/26/2009 17:58:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGUPD_power_outage]
ON [dbo].[power_outage]
FOR UPDATE
AS
UPDATE power_outage SET update_user =  dbo.FNADBUser(), update_ts = getdate()  where  power_outage.power_outage_id in (select power_outage_id from deleted)
