IF EXISTS (SELECT 'X' FROM information_schema.tables WHERE table_name = 'process_risk_control_std_dependency')
	DROP TABLE dbo.process_risk_control_std_dependency
go

/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
IF NOT EXISTS (SELECT 'X' FROM information_schema.tables WHERE table_name = 'process_risk_control_std_dependency' and TABLE_SCHEMA = 'dbo')
BEGIN
	CREATE TABLE [dbo].[process_risk_control_std_dependency](
		[requirements_revision_dependency_id] [int] IDENTITY(1,1) NOT NULL,
		[requirements_revision_id] [int] NOT NULL,
		[risk_control_depend_id] [int] NULL,
		[requirement_revision_hierarchy_level] [int] NOT NULL,
		[requirements_revision_id_depend_on] [int] NULL,
		[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[update_ts] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	 CONSTRAINT [PK_process_risk_control_std_dependency] PRIMARY KEY CLUSTERED 
	(
		[requirements_revision_dependency_id] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]


	ALTER TABLE [dbo].[process_risk_control_std_dependency]  WITH NOCHECK ADD  CONSTRAINT [FK_process_risk_control_std_dependency] FOREIGN KEY([requirements_revision_id])
	REFERENCES [dbo].[process_requirements_revisions] ([requirements_revision_id])

	ALTER TABLE [dbo].[process_risk_control_std_dependency] CHECK CONSTRAINT [FK_process_risk_control_std_dependency]

END