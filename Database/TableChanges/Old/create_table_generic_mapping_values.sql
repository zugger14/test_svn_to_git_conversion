GO

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[generic_mapping_values]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].generic_mapping_values
	(
	[generic_mapping_values_id] INT IDENTITY(1,1),
	[mapping_table_id]	INT REFERENCES [dbo].[generic_mapping_header] (mapping_table_id) NOT NULL,
	[clm1_value]		VARCHAR(250) NULL,
	[clm2_value]		VARCHAR(250) NULL,
	[clm3_value]		VARCHAR(250) NULL,
	[clm4_value]		VARCHAR(250) NULL,
	[clm5_value]		VARCHAR(250) NULL,
	[clm6_value]		VARCHAR(250) NULL,
	[clm7_value]		VARCHAR(250) NULL,
	[clm8_value]		VARCHAR(250) NULL,
	[clm9_value]		VARCHAR(250) NULL,
	[clm10_value]		VARCHAR(250) NULL,
	[clm11_value]		VARCHAR(250) NULL,
	[clm12_value]		VARCHAR(250) NULL,
	[clm13_value]		VARCHAR(250) NULL,
	[clm14_value]		VARCHAR(250) NULL,
	[clm15_value]		VARCHAR(250) NULL,
	[clm16_value]		VARCHAR(250) NULL,
	[clm17_value]		VARCHAR(250) NULL,
	[clm18_value]		VARCHAR(250) NULL,
	[clm19_value]		VARCHAR(250) NULL,
	[clm20_value]		VARCHAR(250) NULL,
	[create_user]		VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]			DATETIME DEFAULT GETDATE(),
	[update_user]		VARCHAR(100) NULL,
	[update_ts]			DATETIME NULL	
	) ON [PRIMARY]
	
    PRINT 'Table Successfully Created'
END

GO

--DROP TABLE generic_mapping_values