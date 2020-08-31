GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_minor_location_nomination_group]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].source_minor_location_nomination_group
    (
    	[source_minor_location_nomination_group_id] INT IDENTITY(1, 1) NOT NULL,
    	[source_minor_location_id]					INT REFERENCES [dbo].[source_minor_location] (source_minor_location_id) NOT NULL, 	
    	[group_id]									INT NULL,
    	[priority_id]								INT NULL,
    	[effective_date]							DATETIME NULL,
    	[end_date]									DATETIME NULL,
    	[create_user]								VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]									DATETIME DEFAULT GETDATE(),
    	[update_user]								VARCHAR(100) NULL,
    	[update_ts]									DATETIME NULL,
    	CONSTRAINT [pk_source_minor_location_nomination_group_id] PRIMARY KEY CLUSTERED([source_minor_location_nomination_group_id] ASC)
    	WITH (IGNORE_DUP_KEY = OFF) 
    	ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
GO