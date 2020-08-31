GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[map_rate_schedule]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].map_rate_schedule
    (
    	[map_rate_schedule_id]		INT IDENTITY(1, 1) NOT NULL,
    	location_loss_factor_id		INT REFERENCES [dbo].[location_loss_factor] NOT NULL,
    	effective_date              DATETIME,
    	fuel_loss                   FLOAT,
    	fuel_loss_group             INT,
		[create_user]				VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME DEFAULT GETDATE(),
    	[update_user]				VARCHAR(100) NULL,
    	[update_ts]					DATETIME NULL,
    ) 
END
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_map_rate_schedule]'))
	DROP TRIGGER [dbo].[TRGUPD_map_rate_schedule]
GO

CREATE TRIGGER dbo.TRGUPD_map_rate_schedule
   ON  dbo.map_rate_schedule
   AFTER UPDATE
AS 
BEGIN
	UPDATE map_rate_schedule 
	SET update_user =  dbo.FNADBUser(),
		update_ts = getdate() 
	from [map_rate_schedule] s inner join deleted i on 
	s.map_rate_schedule_id = i.map_rate_schedule_id
END

