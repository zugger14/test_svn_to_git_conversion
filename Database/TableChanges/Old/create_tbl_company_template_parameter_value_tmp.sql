SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[company_template_parameter_value_tmp]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[company_template_parameter_value_tmp](
		[value_id] [int] IDENTITY(1,1) NOT NULL,
		[parameter_id] [int] NOT NULL,
		[parameter_value] [varchar](50) NULL,
		[process_id] [varchar](100) NULL,
		[parent_process_id] [varchar](100) NULL	  
	)
END
ELSE
BEGIN
    PRINT 'Table company_template_parameter_value_tmp EXISTS'
END
 
GO
