SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[ssis_configurations]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[ssis_configurations](
		[ConfigurationFilter] [nvarchar](255) NOT NULL,
		[ConfiguredValue] [nvarchar](255) NULL,
		[PackagePath] [nvarchar](255) NOT NULL,
		[ConfiguredValueType] [nvarchar](20) NOT NULL
	) ON [PRIMARY]
	PRINT 'Table ssis_configurations created.'
END
ELSE
BEGIN
    PRINT 'Table ssis_configurations exist.'
END

GO


