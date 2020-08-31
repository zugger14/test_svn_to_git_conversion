/*
   Tuesday, May 26, 20092:37:21 PM
   User: sa
   Server: MSINGH\INSTANCE1
   Database: TRMTracker_function
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
ALTER TABLE dbo.bid_offer_formulator_header
	DROP CONSTRAINT FK_bid_offer_formulator_header_static_data_value
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_bid_offer_formulator_header
	(
	bid_offer_id int NOT NULL IDENTITY (1, 1),
	name varchar(50) NOT NULL,
	description varchar(100) NULL,
	product_type_id int NOT NULL,
	bid_offer_flag char(1) NOT NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_bid_offer_formulator_header ON
GO
IF EXISTS(SELECT * FROM dbo.bid_offer_formulator_header)
	 EXEC('INSERT INTO dbo.Tmp_bid_offer_formulator_header (bid_offer_id, name, description, product_type_id, bid_offer_flag, create_user, create_ts, update_user, update_ts)
		SELECT bid_offer_id, name, description, product_type_id, bid_offer_flag, create_user, create_ts, update_user, update_ts FROM dbo.bid_offer_formulator_header WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_bid_offer_formulator_header OFF
GO
ALTER TABLE dbo.bid_offer_formulator_detail
	DROP CONSTRAINT FK_bid_offer_formulator_detail_bid_offer_formulator_header
GO
DROP TABLE dbo.bid_offer_formulator_header
GO
EXECUTE sp_rename N'dbo.Tmp_bid_offer_formulator_header', N'bid_offer_formulator_header', 'OBJECT' 
GO
ALTER TABLE dbo.bid_offer_formulator_header ADD CONSTRAINT
	PK_bid_offer_formulator_header PRIMARY KEY CLUSTERED 
	(
	bid_offer_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.bid_offer_formulator_header ADD CONSTRAINT
	FK_bid_offer_formulator_header_static_data_value FOREIGN KEY
	(
	product_type_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.bid_offer_formulator_detail ADD CONSTRAINT
	FK_bid_offer_formulator_detail_bid_offer_formulator_header FOREIGN KEY
	(
	bid_offer_id
	) REFERENCES dbo.bid_offer_formulator_header
	(
	bid_offer_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
