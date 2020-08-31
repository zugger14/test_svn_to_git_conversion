/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
IF NOT EXISTS (SELECT 'X' FROM information_schema.tables WHERE table_name = 'process_risk_std_steps' and TABLE_SCHEMA = 'dbo')
BEGIN
	CREATE TABLE [dbo].[process_risk_std_steps](
		[risk_control_step_id] [int] IDENTITY(1,1) NOT NULL,
		[requirement_revision_id] [int] NOT NULL,
		[step_sequence] [int] NOT NULL,
		[step_desc1] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[step_desc2] [varchar](250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[step_reference] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[create_ts] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		[update_ts] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	 CONSTRAINT [PK_process_risk_std_steps] PRIMARY KEY CLUSTERED 
	(
		[risk_control_step_id] ASC
	)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]

	

	ALTER TABLE [dbo].[process_risk_std_steps]  WITH NOCHECK ADD  CONSTRAINT [FK_process_risk_std_steps] FOREIGN KEY([requirement_revision_id])
	REFERENCES [dbo].[process_requirements_revisions] ([requirements_revision_id])

	ALTER TABLE [dbo].[process_risk_std_steps] CHECK CONSTRAINT [FK_process_risk_std_steps]


END