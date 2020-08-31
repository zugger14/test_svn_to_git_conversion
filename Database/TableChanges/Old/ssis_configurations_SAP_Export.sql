
/****** Object:  Table [dbo].[ssis_configurations]    Script Date: 07/12/2011 18:54:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ssis_configurations]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[ssis_configurations](
	[ConfigurationFilter] [nvarchar](255) NOT NULL,
	[ConfiguredValue] [nvarchar](255) NULL,
	[PackagePath] [nvarchar](255) NOT NULL,
	[ConfiguredValueType] [nvarchar](20) NOT NULL
) ON [PRIMARY]
END
GO

DELETE FROM ssis_configurations WHERE ConfigurationFilter IN ('PRJ_TRMSAPExport')
INSERT [dbo].[ssis_configurations] ([ConfigurationFilter], [ConfiguredValue], [PackagePath], [ConfiguredValueType]) VALUES (N'PRJ_TRMSAPExport', NULL, N'\Package.Variables[User::PS_SAPUser].Properties[Value]', N'String')
INSERT [dbo].[ssis_configurations] ([ConfigurationFilter], [ConfiguredValue], [PackagePath], [ConfiguredValueType]) VALUES (N'PRJ_TRMSAPExport', N'tcp://localhost:7222', N'\Package.Variables[User::PS_SAPServer].Properties[Value]', N'String')
INSERT [dbo].[ssis_configurations] ([ConfigurationFilter], [ConfiguredValue], [PackagePath], [ConfiguredValueType]) VALUES (N'PRJ_TRMSAPExport', NULL, N'\Package.Variables[User::PS_SAPPwd].Properties[Value]', N'String')
