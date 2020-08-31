
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_static_data_value3
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_static_data_value4
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_static_data_value5
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_static_data_value6
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_static_data_value
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_static_data_value1
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_static_data_value2
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_portfolio_hierarchy
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.process_risk_controls
	DROP CONSTRAINT FK_process_risk_controls_process_requirements_revisions
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_process_risk_controls
	(
	risk_control_id int NOT NULL IDENTITY (1, 1),
	risk_description_id int NOT NULL,
	risk_control_description varchar(150) NULL,
	perform_role int NULL,
	approve_role int NULL,
	run_frequency int NULL,
	control_type int NULL,
	threshold_days int NULL,
	requires_approval char(1) NULL,
	requires_proof char(1) NULL,
	control_objective int NULL,
	internal_function_id int NULL,
	run_date datetime NULL,
	activity_category_id int NULL,
	activity_who_for_id int NULL,
	run_end_date datetime NULL,
	where_id int NULL,
	activity_area_id int NULL,
	activity_sub_area_id int NULL,
	activity_action_id int NULL,
	monetary_value float(53) NULL,
	monetary_value_frequency_id int NULL,
	monetary_value_changes varchar(1) NULL,
	requires_approval_for_late varchar(1) NULL,
	fas_book_id int NULL,
	requirements_revision_id int NULL,
	mitigation_plan_required varchar(1) NULL,
	run_effective_date datetime NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL,
	perform_activity int NULL,
	frequency_type char(1) NOT NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_process_risk_controls ON
GO
IF EXISTS(SELECT * FROM dbo.process_risk_controls)
	 EXEC('INSERT INTO dbo.Tmp_process_risk_controls (risk_control_id, risk_description_id, risk_control_description, perform_role, approve_role, run_frequency, control_type, threshold_days, requires_approval, requires_proof, control_objective, internal_function_id, run_date, activity_category_id, activity_who_for_id, run_end_date, where_id, activity_area_id, activity_sub_area_id, activity_action_id, monetary_value, monetary_value_frequency_id, monetary_value_changes, requires_approval_for_late, fas_book_id, requirements_revision_id, mitigation_plan_required, run_effective_date, create_user, create_ts, update_user, update_ts, perform_activity, frequency_type)
		SELECT risk_control_id, risk_description_id, risk_control_description, perform_role, approve_role, run_frequency, control_type, threshold_days, requires_approval, requires_proof, control_objective, internal_function_id, run_date, activity_category_id, activity_who_for_id, run_end_date, where_id, activity_area_id, activity_sub_area_id, activity_action_id, monetary_value, monetary_value_frequency_id, monetary_value_changes, requires_approval_for_late, fas_book_id, requirements_revision_id, mitigation_plan_required, run_effective_date, create_user, create_ts, update_user, update_ts, perform_activity, frequency_type FROM dbo.process_risk_controls WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_process_risk_controls OFF
GO
ALTER TABLE dbo.risk_process_function_map_detail
	DROP CONSTRAINT FK_risk_process_function_map_detail_risk_process_function_header
GO
ALTER TABLE dbo.process_risk_controls_dependency
	DROP CONSTRAINT FK_process_risk_controls_dependency_process_risk_controls
GO
DROP TABLE dbo.process_risk_controls
GO
EXECUTE sp_rename N'dbo.Tmp_process_risk_controls', N'process_risk_controls', 'OBJECT' 
GO
ALTER TABLE dbo.process_risk_controls ADD CONSTRAINT
	PK_process_risk_controls PRIMARY KEY CLUSTERED 
	(
	risk_control_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_process_requirements_revisions FOREIGN KEY
	(
	requirements_revision_id
	) REFERENCES dbo.process_requirements_revisions
	(
	requirements_revision_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_portfolio_hierarchy FOREIGN KEY
	(
	fas_book_id
	) REFERENCES dbo.portfolio_hierarchy
	(
	entity_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_static_data_value3 FOREIGN KEY
	(
	activity_area_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_static_data_value4 FOREIGN KEY
	(
	activity_sub_area_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_static_data_value5 FOREIGN KEY
	(
	activity_action_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_static_data_value6 FOREIGN KEY
	(
	monetary_value_frequency_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_static_data_value FOREIGN KEY
	(
	activity_category_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_static_data_value1 FOREIGN KEY
	(
	activity_who_for_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.process_risk_controls WITH NOCHECK ADD CONSTRAINT
	FK_process_risk_controls_static_data_value2 FOREIGN KEY
	(
	where_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
CREATE TRIGGER [TRGINS_process_risk_controls]
ON dbo.process_risk_controls
FOR INSERT
AS
UPDATE process_risk_controls SET create_user =  dbo.FNADBUser(), create_ts = getdate() 
where  process_risk_controls.risk_control_id in (select risk_control_id from inserted)
GO
CREATE TRIGGER [TRGUPD_process_risk_controls]
ON dbo.process_risk_controls
FOR UPDATE
AS
UPDATE process_risk_controls SET update_user =  dbo.FNADBUser(), update_ts = getdate() 
where  process_risk_controls.risk_control_id in (select risk_control_id from deleted)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.process_risk_controls_dependency ADD CONSTRAINT
	FK_process_risk_controls_dependency_process_risk_controls FOREIGN KEY
	(
	risk_control_id
	) REFERENCES dbo.process_risk_controls
	(
	risk_control_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.risk_process_function_map_detail ADD CONSTRAINT
	FK_risk_process_function_map_detail_risk_process_function_header FOREIGN KEY
	(
	risk_control_id
	) REFERENCES dbo.process_risk_controls
	(
	risk_control_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
