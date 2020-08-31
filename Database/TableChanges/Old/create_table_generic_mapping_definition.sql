GO

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[generic_mapping_definition]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].[generic_mapping_definition]
	(
	[generic_mapping_definition_id] INT IDENTITY(1,1),
	[mapping_table_id]	INT REFERENCES [dbo].[generic_mapping_header] (mapping_table_id) NOT NULL,
	[clm1_label]		VARCHAR(250) NULL,
	[clm1_udf_id]		INT NULL,
	[clm2_label]		VARCHAR(250) NULL,
	[clm2_udf_id]		INT NULL,
	[clm3_label]		VARCHAR(250) NULL,
	[clm3_udf_id]		INT NULL,
	[clm4_label]		VARCHAR(250) NULL,
	[clm4_udf_id]		INT NULL,
	[clm5_label]		VARCHAR(250) NULL,
	[clm5_udf_id]		INT NULL,
	[clm6_label]		VARCHAR(250) NULL,
	[clm6_udf_id]		INT NULL,
	[clm7_label]		VARCHAR(250) NULL,
	[clm7_udf_id]		INT NULL,
	[clm8_label]		VARCHAR(250) NULL,
	[clm8_udf_id]		INT NULL,
	[clm9_label]		VARCHAR(250) NULL,
	[clm9_udf_id]		INT NULL,
	[clm10_label]		VARCHAR(250) NULL,
	[clm10_udf_id]		INT NULL,
	[clm11_label]		VARCHAR(250) NULL,
	[clm11_udf_id]		INT NULL,
	[clm12_label]		VARCHAR(250) NULL,
	[clm12_udf_id]		INT NULL,
	[clm13_label]		VARCHAR(250) NULL,
	[clm13_udf_id]		INT NULL,
	[clm14_label]		VARCHAR(250) NULL,
	[clm14_udf_id]		INT NULL,
	[clm15_label]		VARCHAR(250) NULL,
	[clm15_udf_id]		INT NULL,
	[clm16_label]		VARCHAR(250) NULL,
	[clm16_udf_id]		INT NULL,
	[clm17_label]		VARCHAR(250) NULL,
	[clm17_udf_id]		INT NULL,
	[clm18_label]		VARCHAR(250) NULL,
	[clm18_udf_id]		INT NULL,
	[clm19_label]		VARCHAR(250) NULL,
	[clm19_udf_id]		INT NULL,
	[clm20_label]		VARCHAR(250) NULL,	
	[clm20_udf_id]		INT NULL,
	[create_user]		VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]			DATETIME DEFAULT GETDATE(),
	[update_user]		VARCHAR(100) NULL,
	[update_ts]			DATETIME NULL	
	) ON [PRIMARY]
	
    PRINT 'Table Successfully Created'
END

GO

--DROP TABLE generic_mapping_definition