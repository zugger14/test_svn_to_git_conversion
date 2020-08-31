/*
   Sunday, December 14, 20083:03:19 PM
   User: sa
   Server: BSUBBA\INSTANCE1
   Database: TRMTracker2_1
   Application: 
*/

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
COMMIT
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_counterparty_credit_enhancements
	(
	counterparty_credit_enhancement_id int NOT NULL,
	counterparty_credit_info_id int NULL,
	enhance_type int NULL,
	guarantee_counterparty int NULL,
	comment varchar(100) NULL,
	amount float(53) NULL,
	currency_code int NULL,
	eff_date datetime NULL,
	margin char(1) NULL,
	rely_self char(1) NULL
	)  ON [PRIMARY]
GO
IF EXISTS(SELECT * FROM dbo.counterparty_credit_enhancements)
	 EXEC('INSERT INTO dbo.Tmp_counterparty_credit_enhancements (counterparty_credit_enhancement_id, counterparty_credit_info_id, enhance_type, guarantee_counterparty, comment, amount, currency_code, eff_date, margin, rely_self)
		SELECT counterparty_credit_enhancement_id, counterparty_credit_info_id, enhance_type, guarantee_counterparty, comment, amount, currency_code, eff_date, margin, rely_self FROM dbo.counterparty_credit_enhancements WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.counterparty_credit_enhancements
GO
EXECUTE sp_rename N'dbo.Tmp_counterparty_credit_enhancements', N'counterparty_credit_enhancements', 'OBJECT' 
GO
ALTER TABLE dbo.counterparty_credit_enhancements ADD CONSTRAINT
	PK_counterparty_credit_enhancements PRIMARY KEY CLUSTERED 
	(
	counterparty_credit_enhancement_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.counterparty_credit_enhancements ADD CONSTRAINT
	FK_counterparty_credit_enhancements_source_currency FOREIGN KEY
	(
	currency_code
	) REFERENCES dbo.source_currency
	(
	source_currency_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_enhancements ADD CONSTRAINT
	FK_counterparty_credit_enhancements_static_data_value FOREIGN KEY
	(
	enhance_type
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_enhancements ADD CONSTRAINT
	FK_counterparty_credit_enhancements_source_counterparty FOREIGN KEY
	(
	guarantee_counterparty
	) REFERENCES dbo.source_counterparty
	(
	source_counterparty_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_enhancements ADD CONSTRAINT
	FK_counterparty_credit_enhancements_counterparty_credit_info FOREIGN KEY
	(
	counterparty_credit_info_id
	) REFERENCES dbo.counterparty_credit_info
	(
	counterparty_credit_info_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
