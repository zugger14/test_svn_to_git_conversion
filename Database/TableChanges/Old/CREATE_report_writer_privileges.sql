/*
	Author	 : Sudeep Lamsal
	Dated	 : 7th Sept. 2010
	DESC	 : Report Writer Privileges Table and Triggers
*/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_writer_privileges]') AND type in (N'U'))
DROP TABLE [dbo].[report_writer_privileges]
Go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_writer_privileges](
	[report_writer_privilege_ID] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [varchar](100) NULL,
	[role_id] [int] NULL,
	[report_writer_ID] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_report_writer_privileges] PRIMARY KEY CLUSTERED 
(
	[report_writer_privilege_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
PRINT 'Table created:-report_writer_privileges'


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-----------------TRIGGERS
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_report_writer_privileges]'))
DROP TRIGGER [dbo].[TRGUPD_report_writer_privileges]
GO

create TRIGGER [TRGUPD_report_writer_privileges]
ON [dbo].report_writer_privileges
FOR UPDATE
AS
UPDATE report_writer_privileges SET update_user =  dbo.FNADBUser(), update_ts = getdate() 
FROM  report_writer_privileges s INNER JOIN deleted d ON s.report_writer_privilege_ID = d.report_writer_privilege_ID

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_report_writer_privileges]'))
DROP TRIGGER [dbo].[TRGINS_report_writer_privileges]
GO

create TRIGGER [TRGINS_report_writer_privileges]
ON [dbo].report_writer_privileges
FOR INSERT
AS
UPDATE report_writer_privileges SET create_user =  dbo.FNADBUser(), create_ts = getdate()  
FROM report_writer_privileges s INNER JOIN inserted i ON s.report_writer_privilege_ID= i.report_writer_privilege_ID

------------------------------ Application Function
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id =  10201015)  
BEGIN     
	INSERT INTO application_functions   
		(function_id, function_name, function_desc, func_ref_id, requires_at, document_path, 
		function_call, function_parameter, module_type, create_user, create_ts)   
	VALUES(10201015,'Report Writer Privileges','Create Report Writer Privileges for Users and Roles','10201000',NULL,NULL
		,'windowReportWriterPrivileges',NULL,NULL,'farrms_admin','2010-09-08 11:00:00')  
END 



