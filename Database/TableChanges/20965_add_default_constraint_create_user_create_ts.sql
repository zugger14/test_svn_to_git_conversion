
IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='source_minor_location' AND column_name='create_user' AND Table_schema='dbo' AND column_default IS NULL)
ALTER TABLE [dbo].[source_minor_location] ADD  CONSTRAINT [DF_sml_create_user] DEFAULT [dbo].[FNADBUser]() FOR [create_user]
GO

IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='source_minor_location' AND column_name='create_ts' AND Table_schema='dbo' AND column_default IS NULL)
ALTER TABLE [dbo].[source_minor_location] ADD  CONSTRAINT [DF_sml_create_ts] DEFAULT GETDATE() FOR [create_ts]
GO


IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='source_currency' AND column_name='create_user' AND Table_schema='dbo' AND column_default IS NULL)
ALTER TABLE [dbo].[source_currency] ADD  CONSTRAINT [DF_scu_create_user] DEFAULT [dbo].[FNADBUser]() FOR [create_user]
GO

IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='source_currency' AND column_name='create_ts' AND Table_schema='dbo' AND column_default IS NULL)
ALTER TABLE [dbo].[source_currency] ADD  CONSTRAINT [DF_scu_create_ts] DEFAULT GETDATE() FOR [create_ts]
GO


IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='source_commodity' AND column_name='create_user' AND Table_schema='dbo' AND column_default IS NULL)
ALTER TABLE [dbo].[source_commodity] ADD  CONSTRAINT [DF_scom_create_user] DEFAULT [dbo].[FNADBUser]() FOR [create_user]
GO

IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='source_commodity' AND column_name='create_ts' AND Table_schema='dbo' AND column_default IS NULL)
ALTER TABLE [dbo].[source_commodity] ADD  CONSTRAINT [DF_scom_create_ts] DEFAULT GETDATE() FOR [create_ts]
GO


IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='source_major_location' AND column_name='create_ts' AND Table_schema='dbo' AND column_default IS NULL)
ALTER TABLE [dbo].[source_major_location] ADD  CONSTRAINT [DF_sm_create_ts] DEFAULT GETDATE() FOR [create_ts]
GO

IF EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='source_major_location' AND column_name='create_user' AND Table_schema='dbo' AND column_default IS NULL)
ALTER TABLE [dbo].[source_major_location] ADD  CONSTRAINT [DF_sm__create_user] DEFAULT [dbo].[FNADBUser]() FOR [create_user]
GO

