/*
   Thursday, February 12, 20092:47:32 PM
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
ALTER TABLE dbo.curve_volatility
	DROP CONSTRAINT FK_curve_volatility_vol_cor_header
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.curve_volatility
	DROP CONSTRAINT FK_curve_volatility_static_data_value
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.curve_volatility
	DROP CONSTRAINT FK_curve_volatility_source_price_curve_def
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_curve_volatility
	(
	id int NOT NULL IDENTITY (1, 1),
	vol_cor_header_id int NULL,
	as_of_date datetime NOT NULL,
	curve_id int NOT NULL,
	curve_source_value_id int NOT NULL,
	term datetime NOT NULL,
	value float(53) NOT NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_curve_volatility ON
GO
IF EXISTS(SELECT * FROM dbo.curve_volatility)
	 EXEC('INSERT INTO dbo.Tmp_curve_volatility (id, vol_cor_header_id, as_of_date, curve_id, curve_source_value_id, term, value, create_user, create_ts, update_user, update_ts)
		SELECT id, vol_cor_header_id, as_of_date, curve_id, curve_source_value_id, term, value, create_user, create_ts, update_user, update_ts FROM dbo.curve_volatility WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_curve_volatility OFF
GO
DROP TABLE dbo.curve_volatility
GO
EXECUTE sp_rename N'dbo.Tmp_curve_volatility', N'curve_volatility', 'OBJECT' 
GO
ALTER TABLE dbo.curve_volatility ADD CONSTRAINT
	PK_Volatility PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.curve_volatility ADD CONSTRAINT
	FK_curve_volatility_source_price_curve_def FOREIGN KEY
	(
	curve_id
	) REFERENCES dbo.source_price_curve_def
	(
	source_curve_def_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.curve_volatility ADD CONSTRAINT
	FK_curve_volatility_static_data_value FOREIGN KEY
	(
	curve_source_value_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.curve_volatility ADD CONSTRAINT
	FK_curve_volatility_vol_cor_header FOREIGN KEY
	(
	vol_cor_header_id
	) REFERENCES dbo.vol_cor_header
	(
	id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
