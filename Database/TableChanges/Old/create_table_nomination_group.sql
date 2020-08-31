GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[nomination_group]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].nomination_group
    (
	[nomination_group_id]		INT IDENTITY(1,1) NOT NULL,
	[nomination_group]			INT NOT NULL,
	[effective_date]			DATETIME NOT NULL,
	[priority]					INT NOT NULL,
	[create_user]				VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]					DATETIME DEFAULT GETDATE(),
	[update_user]				VARCHAR(100) NULL,
	[update_ts]					DATETIME NULL,
	CONSTRAINT [pk_nomination_group_id] PRIMARY KEY CLUSTERED([nomination_group_id] ASC)WITH (IGNORE_DUP_KEY = OFF) 
	ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END

GO