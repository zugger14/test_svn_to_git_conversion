/*
   Thursday, February 12, 20092:48:52 PM
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
ALTER TABLE dbo.curve_correlation
	DROP CONSTRAINT FK_curve_correlation_vol_cor_header
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.curve_correlation
	DROP CONSTRAINT FK_curve_correlation_static_data_value
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.curve_correlation
	DROP CONSTRAINT FK_curve_correlation_source_price_curve_def
GO
ALTER TABLE dbo.curve_correlation
	DROP CONSTRAINT FK_curve_correlation_source_price_curve_def1
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_curve_correlation
	(
	id int NOT NULL IDENTITY (1, 1),
	vol_cor_header_id int NULL,
	as_of_date datetime NOT NULL,
	curve_id_from int NOT NULL,
	curve_id_to int NOT NULL,
	term1 datetime NOT NULL,
	term2 datetime NOT NULL,
	curve_source_value_id int NOT NULL,
	value float(53) NOT NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_curve_correlation ON
GO
IF EXISTS(SELECT * FROM dbo.curve_correlation)
	 EXEC('INSERT INTO dbo.Tmp_curve_correlation (id, vol_cor_header_id, as_of_date, curve_id_from, curve_id_to, term1, term2, curve_source_value_id, value, create_user, create_ts, update_user, update_ts)
		SELECT id, vol_cor_header_id, as_of_date, curve_id_from, curve_id_to, term1, term2, curve_source_value_id, value, create_user, create_ts, update_user, update_ts FROM dbo.curve_correlation WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_curve_correlation OFF
GO
DROP TABLE dbo.curve_correlation
GO
EXECUTE sp_rename N'dbo.Tmp_curve_correlation', N'curve_correlation', 'OBJECT' 
GO
ALTER TABLE dbo.curve_correlation ADD CONSTRAINT
	PK_curve_correlation PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.curve_correlation ADD CONSTRAINT
	FK_curve_correlation_source_price_curve_def FOREIGN KEY
	(
	curve_id_from
	) REFERENCES dbo.source_price_curve_def
	(
	source_curve_def_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.curve_correlation ADD CONSTRAINT
	FK_curve_correlation_source_price_curve_def1 FOREIGN KEY
	(
	curve_id_to
	) REFERENCES dbo.source_price_curve_def
	(
	source_curve_def_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.curve_correlation ADD CONSTRAINT
	FK_curve_correlation_static_data_value FOREIGN KEY
	(
	curve_source_value_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.curve_correlation ADD CONSTRAINT
	FK_curve_correlation_vol_cor_header FOREIGN KEY
	(
	vol_cor_header_id
	) REFERENCES dbo.vol_cor_header
	(
	id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
