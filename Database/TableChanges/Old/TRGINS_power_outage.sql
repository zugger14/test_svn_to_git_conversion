
/****** Object:  Trigger [dbo].[TRGINS_source_generator]    Script Date: 05/26/2009 17:58:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGINS_power_outage]
ON [dbo].[power_outage]
FOR INSERT
AS
UPDATE power_outage SET create_user =  dbo.FNADBUser(), create_ts = getdate() 
FROM power_outage s INNER JOIN inserted i ON s.power_outage_id=i.power_outage_id
