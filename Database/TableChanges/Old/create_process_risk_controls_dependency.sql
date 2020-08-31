IF EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.TABLES WHERE table_name = 'process_risk_controls_dependency')
	DROP TABLE process_risk_controls_dependency 
GO 

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON


CREATE TABLE [dbo].[process_risk_controls_dependency](
	[risk_control_dependency_id] [int] IDENTITY(1,1) NOT NULL,
	[risk_control_id] [int] NOT NULL,
	[risk_control_id_depend_on] [int] NULL,
	[risk_hierarchy_level] [int] NOT NULL CONSTRAINT [DF_process_risk_controls_dependency_risk_hierarchy_level]  DEFAULT ((0)),
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [char](10) NULL,
 CONSTRAINT [PK_process_risk_controls_dependency] PRIMARY KEY CLUSTERED 
(
	[risk_control_dependency_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [TRGINS_PROCESS_RISK_CONTROLS_DEPENDENCY]
ON [dbo].[process_risk_controls_dependency]
FOR INSERT
AS
UPDATE PROCESS_RISK_CONTROLS_DEPENDENCY SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  PROCESS_RISK_CONTROLS_DEPENDENCY.risk_control_id in (select risk_control_id from inserted) AND PROCESS_RISK_CONTROLS_DEPENDENCY.risk_control_id_depend_on in (select risk_control_id_depend_on from inserted)

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [TRGUPD_PROCESS_RISK_CONTROLS_DEPENDENCY]
ON [dbo].[process_risk_controls_dependency]
FOR UPDATE
AS
UPDATE PROCESS_RISK_CONTROLS_DEPENDENCY SET update_user =  dbo.FNADBUser(), update_ts = getdate() where  PROCESS_RISK_CONTROLS_DEPENDENCY.risk_control_id in (select risk_control_id from deleted) AND PROCESS_RISK_CONTROLS_DEPENDENCY.risk_control_id_depend_on in (select risk_control_id_depend_on from deleted)

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_process_risk_controls_dependency_process_risk_controls]') AND parent_object_id = OBJECT_ID(N'[dbo].[process_risk_controls_dependency]'))
ALTER TABLE [dbo].[process_risk_controls_dependency]  WITH CHECK ADD  CONSTRAINT [FK_process_risk_controls_dependency_process_risk_controls] FOREIGN KEY([risk_control_id])
REFERENCES [dbo].[process_risk_controls] ([risk_control_id])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_process_risk_controls_dependency_process_risk_controls1]') AND parent_object_id = OBJECT_ID(N'[dbo].[process_risk_controls_dependency]'))
ALTER TABLE [dbo].[process_risk_controls_dependency]  WITH CHECK ADD  CONSTRAINT [FK_process_risk_controls_dependency_process_risk_controls1] FOREIGN KEY([risk_control_id_depend_on])
REFERENCES [dbo].[process_risk_controls] ([risk_control_id])
