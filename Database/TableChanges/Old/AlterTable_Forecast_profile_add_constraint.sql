IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[forecast_profile]') AND name = N'IX_forecast_profile')
	DROP INDEX [IX_forecast_profile] ON [dbo].[forecast_profile] 

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[forecast_profile]') AND name = N'IX_forecast_profile')
CREATE UNIQUE NONCLUSTERED INDEX [IX_forecast_profile] ON [dbo].[forecast_profile] 
(
	[external_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

/****** Object:  Trigger [TRGUPD_source_minor_location]    Script Date: 09/19/2011 19:33:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_source_minor_location]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[TRGUPD_source_minor_location]
ON [dbo].[source_minor_location]
FOR UPDATE
AS

UPDATE source_minor_location SET update_user = dbo.FNADBUser(), 
	update_ts = getdate() where  source_minor_location.source_minor_location_id in (select source_minor_location_id from deleted)

'
GO
/****** Object:  Trigger [TRGUPD_forecast_profile]    Script Date: 09/19/2011 19:33:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_forecast_profile]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[TRGUPD_forecast_profile]
ON [dbo].[forecast_profile]
FOR Update
AS

UPDATE forecast_profile SET update_user = dbo.FNADBUser(), 
	update_ts = getdate() where  forecast_profile.profile_id in (select profile_id from deleted)

'
GO
/****** Object:  Trigger [TRGINS_source_minor_location]    Script Date: 09/19/2011 19:33:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_source_minor_location]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[TRGINS_source_minor_location]
ON [dbo].[source_minor_location]
FOR INSERT
AS
UPDATE source_minor_location SET create_user = dbo.FNADBUser(), 
	create_ts = getdate() where  source_minor_location.source_minor_location_id in (select source_minor_location_id from inserted)


'
GO
/****** Object:  Trigger [TRGINS_forecast_profile]    Script Date: 09/19/2011 19:33:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_forecast_profile]'))
EXEC dbo.sp_executesql @statement = N'

CREATE TRIGGER [dbo].[TRGINS_forecast_profile]
ON [dbo].[forecast_profile]
FOR INSERT
AS

UPDATE forecast_profile SET create_user = dbo.FNADBUser(), 
	create_ts = getdate() where  forecast_profile.profile_id in (select profile_id from inserted)

'
GO
