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
CREATE TABLE dbo.Tmp_source_deal_pnl_arch2
	(
	source_deal_header_id int NOT NULL,
	term_start datetime NOT NULL,
	term_end datetime NOT NULL,
	Leg int NOT NULL,
	pnl_as_of_date datetime NOT NULL,
	und_pnl float(53) NOT NULL,
	und_intrinsic_pnl float(53) NOT NULL,
	und_extrinsic_pnl float(53) NOT NULL,
	dis_pnl float(53) NOT NULL,
	dis_intrinsic_pnl float(53) NOT NULL,
	dis_extrinisic_pnl float(53) NOT NULL,
	pnl_source_value_id int NOT NULL,
	pnl_currency_id int NOT NULL,
	pnl_conversion_factor float(53) NOT NULL,
	pnl_adjustment_value float(53) NULL,
	deal_volume float(53) NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL,
	source_deal_pnl_id int NULL,
	und_pnl_set float(53) NULL
	)  ON [PRIMARY]
GO
IF EXISTS(SELECT * FROM dbo.source_deal_pnl_arch2)
	 EXEC('INSERT INTO dbo.Tmp_source_deal_pnl_arch2 (source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, und_pnl, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor, pnl_adjustment_value, deal_volume, create_user, create_ts, update_user, update_ts, source_deal_pnl_id, und_pnl_set)
		SELECT source_deal_header_id, term_start, term_end, Leg, pnl_as_of_date, und_pnl, und_intrinsic_pnl, und_extrinsic_pnl, dis_pnl, dis_intrinsic_pnl, dis_extrinisic_pnl, pnl_source_value_id, pnl_currency_id, pnl_conversion_factor, pnl_adjustment_value, deal_volume, create_user, create_ts, update_user, update_ts, source_deal_pnl_id, und_pnl_set FROM dbo.source_deal_pnl_arch2 WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.source_deal_pnl_arch2
GO
EXECUTE sp_rename N'dbo.Tmp_source_deal_pnl_arch2', N'source_deal_pnl_arch2', 'OBJECT' 
GO
COMMIT