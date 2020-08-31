--&report_name=2
--&report_filter=source_deal_header_id=farrms_admin,term_start=2011-09-19,2_term_start=2012-09-19
--&export_type=HTML4.0

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[report_group_parameters_criteria]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[report_group_parameters_criteria]
    (
    	[report_group_parameters_criteria_id]  INT PRIMARY KEY IDENTITY(1, 1) NOT NULL,
    	[report_manager_group_id]              INT FOREIGN KEY REFERENCES report_manager_group(report_manager_group_id),
    	[report_writer_id]                     INT NULL,
    	[critetia]                             VARCHAR(8000) NULL,
    	[report_name]                          VARCHAR(5000) NULL,
    	[section]                              INT NULL,
    	[create_user]                          VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                            DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                          VARCHAR(50) NULL,
    	[update_ts]                            DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table report_group_parameters_criteria EXISTS'
END
GO

--DROP TABLE report_group_parameters_criteria