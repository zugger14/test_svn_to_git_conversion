IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[commodity_attribute_form]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].commodity_attribute_form
    (
	[commodity_attribute_form_id]	INT IDENTITY(1,1) NOT NULL,
	[commodity_attribute_id]		INT REFERENCES [dbo].[commodity_attribute] (commodity_attribute_id) NOT NULL,
	[commodity_form_name]			VARCHAR(50) NOT NULL,
	[commodity_form_description]	VARCHAR(100) NOT NULL,
	[create_user]					VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]						DATETIME DEFAULT GETDATE(),
	[update_user]					VARCHAR(100) NULL,
	[update_ts]						DATETIME NULL,
	CONSTRAINT [pk_commodity_attribute_form_id] PRIMARY KEY CLUSTERED([commodity_attribute_form_id] ASC)WITH (IGNORE_DUP_KEY = OFF) 
	ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END

GO