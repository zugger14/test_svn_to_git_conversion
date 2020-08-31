/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
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
ALTER TABLE dbo.deal_confirmation_rule
	DROP CONSTRAINT FK_deal_confirmation_rule_source_deal_type
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.deal_confirmation_rule
	DROP CONSTRAINT FK_deal_confirmation_rule_contract_group
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.deal_confirmation_rule
	DROP CONSTRAINT FK_deal_confirmation_rule_source_commodity
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.deal_confirmation_rule
	DROP CONSTRAINT FK_deal_confirmation_rule_source_counterparty
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_deal_confirmation_rule
	(
	rule_id int NOT NULL IDENTITY (1, 1),
	counterparty_id int NOT NULL,
	buy_sell_flag char(1) NULL,
	commodity_id int NULL,
	contract_id int NULL,
	deal_type_id int NULL,
	confirm_template_id int NULL,
	revision_confirm_template_id int NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_deal_confirmation_rule ON
GO
IF EXISTS(SELECT * FROM dbo.deal_confirmation_rule)
	 EXEC('INSERT INTO dbo.Tmp_deal_confirmation_rule (rule_id, counterparty_id, buy_sell_flag, commodity_id, contract_id, deal_type_id, confirm_template_id, revision_confirm_template_id)
		SELECT rule_id, counterparty_id, buy_sell_flag, commodity_id, contract_id, deal_type_id, confirm_template_id, revision_confirm_template_id FROM dbo.deal_confirmation_rule WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_deal_confirmation_rule OFF
GO
DROP TABLE dbo.deal_confirmation_rule
GO
EXECUTE sp_rename N'dbo.Tmp_deal_confirmation_rule', N'deal_confirmation_rule', 'OBJECT' 
GO
ALTER TABLE dbo.deal_confirmation_rule ADD CONSTRAINT
	PK_deal_confirmation_rule PRIMARY KEY CLUSTERED 
	(
	rule_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.deal_confirmation_rule WITH NOCHECK ADD CONSTRAINT
	FK_deal_confirmation_rule_source_counterparty FOREIGN KEY
	(
	counterparty_id
	) REFERENCES dbo.source_counterparty
	(
	source_counterparty_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.deal_confirmation_rule WITH NOCHECK ADD CONSTRAINT
	FK_deal_confirmation_rule_source_commodity FOREIGN KEY
	(
	commodity_id
	) REFERENCES dbo.source_commodity
	(
	source_commodity_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.deal_confirmation_rule WITH NOCHECK ADD CONSTRAINT
	FK_deal_confirmation_rule_contract_group FOREIGN KEY
	(
	contract_id
	) REFERENCES dbo.contract_group
	(
	contract_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.deal_confirmation_rule WITH NOCHECK ADD CONSTRAINT
	FK_deal_confirmation_rule_source_deal_type FOREIGN KEY
	(
	deal_type_id
	) REFERENCES dbo.source_deal_type
	(
	source_deal_type_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
