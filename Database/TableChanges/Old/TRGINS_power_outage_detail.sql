
/****** Object:  Trigger [dbo].[TRGINS_power_outage]    Script Date: 05/26/2009 18:01:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create TRIGGER [dbo].[TRGINS_power_outage_detail]
ON [dbo].[power_outage_detail]
FOR INSERT
AS
UPDATE power_outage_detail SET create_user =  dbo.FNADBUser(), create_ts = getdate() 
FROM power_outage_detail s INNER JOIN inserted i ON s.power_outage_detail_id=i.power_outage_detail_id
