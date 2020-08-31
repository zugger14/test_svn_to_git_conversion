/*
   Monday, May 25, 200911:56:54 AM
   User: farrms_admin
   Server: MSINGH\INSTANCE1
   Database: TRMTracker
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
ALTER TABLE dbo.bid_offer_formulator_detail
	DROP CONSTRAINT FK_bid_offer_formulator_detail_formula_editor
GO
ALTER TABLE dbo.bid_offer_formulator_detail
	DROP CONSTRAINT FK_bid_offer_formulator_detail_formula_editor1
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.bid_offer_formulator_detail
	DROP CONSTRAINT FK_bid_offer_formulator_detail_bid_offer_formulator_header
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_bid_offer_formulator_detail
	(
	bid_offer_detail_id int NOT NULL IDENTITY (1, 1),
	bid_offer_id int NOT NULL,
	block_id int NOT NULL,
	volume_formula_id int NULL,
	price_formula_id int NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_bid_offer_formulator_detail ON
GO
IF EXISTS(SELECT * FROM dbo.bid_offer_formulator_detail)
	 EXEC('INSERT INTO dbo.Tmp_bid_offer_formulator_detail (bid_offer_detail_id, bid_offer_id, block_id, volume_formula_id, price_formula_id, create_user, create_ts, update_user, update_ts)
		SELECT bid_offer_detail_id, bid_offer_id, block_id, volume_formula_id, price_formula_id, create_user, create_ts, update_user, update_ts FROM dbo.bid_offer_formulator_detail WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_bid_offer_formulator_detail OFF
GO
DROP TABLE dbo.bid_offer_formulator_detail
GO
EXECUTE sp_rename N'dbo.Tmp_bid_offer_formulator_detail', N'bid_offer_formulator_detail', 'OBJECT' 
GO
ALTER TABLE dbo.bid_offer_formulator_detail ADD CONSTRAINT
	PK_bid_offer_formulator_detail PRIMARY KEY CLUSTERED 
	(
	bid_offer_detail_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

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
ALTER TABLE dbo.bid_offer_formulator_detail ADD CONSTRAINT
	FK_bid_offer_formulator_detail_formula_editor FOREIGN KEY
	(
	volume_formula_id
	) REFERENCES dbo.formula_editor
	(
	formula_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.bid_offer_formulator_detail ADD CONSTRAINT
	FK_bid_offer_formulator_detail_formula_editor1 FOREIGN KEY
	(
	price_formula_id
	) REFERENCES dbo.formula_editor
	(
	formula_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
CREATE TRIGGER [dbo].[TRGINS_bid_offer_formulator_detail]
ON dbo.bid_offer_formulator_detail
FOR INSERT
AS
UPDATE bid_offer_formulator_detail SET create_user =  dbo.FNADBUser(), create_ts = getdate() where  bid_offer_formulator_detail.bid_offer_id in (select bid_offer_detail_id from inserted)
GO
CREATE TRIGGER [dbo].[TRGUPD_bid_offer_formulator_detail]
ON dbo.bid_offer_formulator_detail
FOR UPDATE
AS
UPDATE bid_offer_formulator_detail SET update_user =  dbo.FNADBUser(), update_ts = getdate()  where  bid_offer_formulator_detail.bid_offer_id in (select bid_offer_detail_id from deleted)
GO
COMMIT
