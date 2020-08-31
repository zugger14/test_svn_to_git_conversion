GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[generic_mapping_header]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].generic_mapping_header
    (
	[mapping_table_id]		INT IDENTITY(1,1) NOT NULL,
	[mapping_name]			VARCHAR(50) NOT NULL,
	[total_columns_used]	INT NOT NULL,
	[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]				DATETIME DEFAULT GETDATE(),
	[update_user]			VARCHAR(100) NULL,
	[update_ts]				DATETIME NULL,
	CONSTRAINT [pk_mapping_table_id] PRIMARY KEY CLUSTERED([mapping_table_id] ASC)WITH (IGNORE_DUP_KEY = OFF) 
	ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END

GO

--DROP TABLE generic_mapping_header