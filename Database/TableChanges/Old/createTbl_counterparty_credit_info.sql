/*
   Sunday, December 14, 20082:43:45 PM
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
COMMIT
BEGIN TRANSACTION
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_counterparty_credit_info
	(
	counterparty_credit_info_id int NOT NULL,
	Counterparty_id int NULL,
	account_status int NULL,
	limit_expiration datetime NULL,
	credit_limit float(53) NULL,
	curreny_code int NULL,
	Tenor_limt int NULL,
	Industry_type1 int NULL,
	Industry_type2 int NULL,
	SIC_Code int NULL,
	Duns_No varchar(100) NULL,
	Risk_rating int NULL,
	Debt_rating int NULL,
	Ticker_symbol varchar(100) NULL,
	Date_established datetime NULL,
	Next_review_date datetime NULL,
	Last_review_date datetime NULL,
	Customer_since datetime NULL,
	Approved_by varchar(50) NULL,
	Watch_list char(1) NULL,
	Settlement_contact_name varchar(100) NULL,
	Settlement_contact_address varchar(100) NULL,
	Settlement_contact_address2 varchar(100) NULL,
	Settlement_contact_phone varchar(10) NULL,
	Settlement_contact_email varchar(50) NULL,
	payment_contact_name varchar(100) NULL,
	payment_contact_address varchar(100) NULL,
	payment_contact_address2 varchar(100) NULL,
	payment_contact_phone varchar(10) NULL,
	payment_contact_email varchar(50) NULL,
	block_deal_type int NULL,
	block_commodity_type int NULL
	)  ON [PRIMARY]
GO
IF EXISTS(SELECT * FROM dbo.counterparty_credit_info)
	 EXEC('INSERT INTO dbo.Tmp_counterparty_credit_info (counterparty_credit_info_id, Counterparty_id, account_status, limit_expiration, credit_limit, curreny_code, Tenor_limt, Industry_type1, Industry_type2, SIC_Code, Duns_No, Risk_rating, Debt_rating, Ticker_symbol, Date_established, Next_review_date, Last_review_date, Customer_since, Approved_by, Watch_list, Settlement_contact_name, Settlement_contact_address, Settlement_contact_address2, Settlement_contact_phone, Settlement_contact_email, payment_contact_name, payment_contact_address, payment_contact_address2, payment_contact_phone, payment_contact_email, block_deal_type, block_commodity_type)
		SELECT counterparty_credit_info_id, Counterparty_id, account_status, limit_expiration, credit_limit, curreny_code, Tenor_limt, Industry_type1, Industry_type2, SIC_Code, Duns_No, Risk_rating, Debt_rating, Ticker_symbol, Date_established, Next_review_date, Last_review_date, Customer_since, Approved_by, Watch_list, Settlement_contact_name, Settlement_contact_address, Settlement_contact_address2, Settlement_contact_phone, Settlement_contact_email, payment_contact_name, payment_contact_address, payment_contact_address2, payment_contact_phone, payment_contact_email, block_deal_type, block_commodity_type FROM dbo.counterparty_credit_info WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.counterparty_credit_info
GO
EXECUTE sp_rename N'dbo.Tmp_counterparty_credit_info', N'counterparty_credit_info', 'OBJECT' 
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	PK_counterparty_credit_info PRIMARY KEY CLUSTERED 
	(
	counterparty_credit_info_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_source_counterparty FOREIGN KEY
	(
	counterparty_credit_info_id
	) REFERENCES dbo.source_counterparty
	(
	source_counterparty_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_static_data_value FOREIGN KEY
	(
	account_status
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_source_currency FOREIGN KEY
	(
	curreny_code
	) REFERENCES dbo.source_currency
	(
	source_currency_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_static_data_value1 FOREIGN KEY
	(
	Industry_type1
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_static_data_value2 FOREIGN KEY
	(
	Industry_type2
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_static_data_value3 FOREIGN KEY
	(
	SIC_Code
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_static_data_value4 FOREIGN KEY
	(
	Risk_rating
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_static_data_value5 FOREIGN KEY
	(
	Debt_rating
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_application_users FOREIGN KEY
	(
	Approved_by
	) REFERENCES dbo.application_users
	(
	user_login_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_source_deal_type FOREIGN KEY
	(
	block_deal_type
	) REFERENCES dbo.source_deal_type
	(
	source_deal_type_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.counterparty_credit_info ADD CONSTRAINT
	FK_counterparty_credit_info_source_commodity FOREIGN KEY
	(
	block_commodity_type
	) REFERENCES dbo.source_commodity
	(
	source_commodity_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
