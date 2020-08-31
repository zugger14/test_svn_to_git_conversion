/*
   Monday, March 23, 200910:36:41 AM
   User: sa
   Server: PIONEER-PC\BSUBBA
   Database: TRM_Master
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
ALTER TABLE dbo.source_deal_detail
	DROP CONSTRAINT FK_source_deal_detail_source_deal_header
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_deal_detail
	DROP CONSTRAINT FK_static_data_value_day_count
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_deal_detail
	DROP CONSTRAINT FK_source_deal_detail_source_price_curve_def
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_deal_detail
	DROP CONSTRAINT FK_source_deal_detail_source_uom
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_deal_detail
	DROP CONSTRAINT FK_source_deal_detail_source_currency
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_deal_detail
	DROP CONSTRAINT FK_source_deal_detail_formula_editor
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_source_deal_detail
	(
	source_deal_detail_id int NOT NULL IDENTITY (1, 1),
	source_deal_header_id int NOT NULL,
	term_start datetime NOT NULL,
	term_end datetime NOT NULL,
	Leg int NOT NULL,
	contract_expiration_date datetime NOT NULL,
	fixed_float_leg char(1) NOT NULL,
	buy_sell_flag char(1) NOT NULL,
	curve_id int NULL,
	fixed_price float(53) NULL,
	fixed_price_currency_id int NULL,
	option_strike_price float(53) NULL,
	deal_volume float(53) NOT NULL,
	deal_volume_frequency char(1) NOT NULL,
	deal_volume_uom_id int NOT NULL,
	block_description varchar(100) NULL,
	deal_detail_description varchar(100) NULL,
	formula_id int NULL,
	volume_left float(53) NULL,
	settlement_volume float(53) NULL,
	settlement_uom int NULL,
	create_user varchar(50) NULL,
	create_ts datetime NULL,
	update_user varchar(50) NULL,
	update_ts datetime NULL,
	price_adder float(53) NULL,
	price_multiplier float(53) NULL,
	settlement_date datetime NULL,
	day_count_id int NULL,
	location_id int NULL,
	meter_id int NULL,
	physical_financial_flag char(1) NULL,
	Booked char(1) NULL
	)  ON [PRIMARY]
GO
SET IDENTITY_INSERT dbo.Tmp_source_deal_detail ON
GO
IF EXISTS(SELECT * FROM dbo.source_deal_detail)
	 EXEC('INSERT INTO dbo.Tmp_source_deal_detail (source_deal_detail_id, source_deal_header_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left, settlement_volume, settlement_uom, create_user, create_ts, update_user, update_ts, price_adder, price_multiplier, settlement_date, day_count_id, location_id, physical_financial_flag, Booked)
		SELECT source_deal_detail_id, source_deal_header_id, term_start, term_end, Leg, contract_expiration_date, fixed_float_leg, buy_sell_flag, curve_id, fixed_price, fixed_price_currency_id, option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, block_description, deal_detail_description, formula_id, volume_left, settlement_volume, settlement_uom, create_user, create_ts, update_user, update_ts, price_adder, price_multiplier, settlement_date, day_count_id, location_id, physical_financial_flag, Booked FROM dbo.source_deal_detail WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_source_deal_detail OFF
GO
ALTER TABLE dbo.Calc_Invoice_Volume_variance
	DROP CONSTRAINT FK_Calc_Invoice_Volume_variance_source_deal_detail
GO
ALTER TABLE dbo.calc_invoice_volume_recorder
	DROP CONSTRAINT FK_calc_invoice_volume_recorder_source_deal_detail
GO
ALTER TABLE dbo.deal_exercise_detail
	DROP CONSTRAINT FK_deal_exercise_detail_source_deal_detail
GO
ALTER TABLE dbo.assignment_audit
	DROP CONSTRAINT FK_assignment_audit_source_deal_detail
GO
ALTER TABLE dbo.Gis_Certificate
	DROP CONSTRAINT FK_Gis_Certificate_source_deal_detail
GO
DROP TABLE dbo.source_deal_detail
GO
EXECUTE sp_rename N'dbo.Tmp_source_deal_detail', N'source_deal_detail', 'OBJECT' 
GO
ALTER TABLE dbo.source_deal_detail ADD CONSTRAINT
	PK_source_deal_detail PRIMARY KEY NONCLUSTERED 
	(
	source_deal_detail_id
	) WITH( PAD_INDEX = OFF, FILLFACTOR = 90, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
CREATE UNIQUE CLUSTERED INDEX IX_source_deal_detail ON dbo.source_deal_detail
	(
	source_deal_header_id,
	term_start,
	term_end,
	Leg
	) WITH( PAD_INDEX = OFF, FILLFACTOR = 90, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_source_deal_detail_1 ON dbo.source_deal_detail
	(
	buy_sell_flag,
	curve_id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE dbo.source_deal_detail WITH NOCHECK ADD CONSTRAINT
	FK_source_deal_detail_formula_editor FOREIGN KEY
	(
	formula_id
	) REFERENCES dbo.formula_editor
	(
	formula_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_deal_detail WITH NOCHECK ADD CONSTRAINT
	FK_source_deal_detail_source_currency FOREIGN KEY
	(
	fixed_price_currency_id
	) REFERENCES dbo.source_currency
	(
	source_currency_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_deal_detail WITH NOCHECK ADD CONSTRAINT
	FK_source_deal_detail_source_uom FOREIGN KEY
	(
	deal_volume_uom_id
	) REFERENCES dbo.source_uom
	(
	source_uom_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_deal_detail WITH NOCHECK ADD CONSTRAINT
	FK_source_deal_detail_source_price_curve_def FOREIGN KEY
	(
	curve_id
	) REFERENCES dbo.source_price_curve_def
	(
	source_curve_def_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_deal_detail WITH NOCHECK ADD CONSTRAINT
	FK_static_data_value_day_count FOREIGN KEY
	(
	day_count_id
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_deal_detail WITH NOCHECK ADD CONSTRAINT
	FK_source_deal_detail_source_deal_header FOREIGN KEY
	(
	source_deal_header_id
	) REFERENCES dbo.source_deal_header
	(
	source_deal_header_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
CREATE TRIGGER [TRGDEL_SOURCE_DEAL_DETAIL]
ON dbo.source_deal_detail
FOR Delete
AS
INSERT INTO [source_deal_detail_audit]
           ([source_deal_detail_id]
           ,[source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           ,[update_user]
           ,[update_ts]
           ,[user_action],price_adder,
			price_multiplier,
			settlement_date,
			day_count_id)
select [source_deal_detail_id]
           ,[source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           , dbo.FNADBUser()
           ,getDate()
           ,'Delete',price_adder,
			price_multiplier,
			settlement_date,
			day_count_id
from deleted
GO
CREATE TRIGGER [TRGINS_SOURCE_DEAL_DETAIL]
ON dbo.source_deal_detail
FOR Insert
AS

update source_deal_detail
	set volume_left=s.deal_volume,create_ts=getdate(),create_user =  dbo.FNADBUser()
	from inserted i inner join source_deal_detail s
	on  s.source_deal_detail_id=i.source_deal_detail_id

INSERT INTO [source_deal_detail_audit]
           ([source_deal_detail_id]
           ,[source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           ,[update_user]
           ,[update_ts]
           ,[user_action]
			,price_adder,
			price_multiplier,
			settlement_date,
			day_count_id)
select [source_deal_detail_id]
           ,[source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           , dbo.FNADBUser()
           ,getDate()
           ,'Insert'
			,price_adder,
			price_multiplier,
			settlement_date,
			day_count_id
from inserted
GO
CREATE TRIGGER [TRGUPD_SOURCE_DEAL_DETAIL]
ON dbo.source_deal_detail
FOR UPDATE
AS
UPDATE SOURCE_DEAL_DETAIL SET update_user =  dbo.FNADBUser(), update_ts = getdate() from [source_deal_DETAIL] s inner join deleted i on 
s.source_deal_DETAIL_id=i.source_deal_DETAIL_id

if update(deal_volume)
begin
	update source_deal_detail
	set volume_left= case when (source_deal_detail.deal_volume-deleted.deal_volume)+deleted.volume_left<0 then 0 else
	(source_deal_detail.deal_volume-deleted.deal_volume)+deleted.volume_left end	
	from deleted, source_deal_detail
	where source_deal_detail.source_deal_detail_id=deleted.source_deal_detail_id
end
if not update(create_user) and not update(create_ts)
INSERT INTO [source_deal_detail_audit]
           ([source_deal_detail_id]
           ,[source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           ,[update_user]
           ,[update_ts]
           ,[user_action],price_adder,
			price_multiplier,
			settlement_date,
			day_count_id)
select [source_deal_detail_id]
           ,[source_deal_header_id]
           ,[term_start]
           ,[term_end]
           ,[Leg]
           ,[contract_expiration_date]
           ,[fixed_float_leg]
           ,[buy_sell_flag]
           ,[curve_id]
           ,[fixed_price]
           ,[fixed_price_currency_id]
           ,[option_strike_price]
           ,[deal_volume]
           ,[deal_volume_frequency]
           ,[deal_volume_uom_id]
           ,[block_description]
           ,[deal_detail_description]
           ,[formula_id]
           ,[volume_left]
           ,[settlement_volume]
           ,[settlement_uom]
           , dbo.FNADBUser()
           ,getDate()
           ,'Update',price_adder,
			price_multiplier,
			settlement_date,
			day_count_id
from inserted
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Gis_Certificate WITH NOCHECK ADD CONSTRAINT
	FK_Gis_Certificate_source_deal_detail FOREIGN KEY
	(
	source_deal_header_id
	) REFERENCES dbo.source_deal_detail
	(
	source_deal_detail_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.assignment_audit WITH NOCHECK ADD CONSTRAINT
	FK_assignment_audit_source_deal_detail FOREIGN KEY
	(
	source_deal_header_id
	) REFERENCES dbo.source_deal_detail
	(
	source_deal_detail_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.deal_exercise_detail ADD CONSTRAINT
	FK_deal_exercise_detail_source_deal_detail FOREIGN KEY
	(
	source_deal_detail_id
	) REFERENCES dbo.source_deal_detail
	(
	source_deal_detail_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.calc_invoice_volume_recorder ADD CONSTRAINT
	FK_calc_invoice_volume_recorder_source_deal_detail FOREIGN KEY
	(
	deal_id
	) REFERENCES dbo.source_deal_detail
	(
	source_deal_detail_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Calc_Invoice_Volume_variance ADD CONSTRAINT
	FK_Calc_Invoice_Volume_variance_source_deal_detail FOREIGN KEY
	(
	deal_id
	) REFERENCES dbo.source_deal_detail
	(
	source_deal_detail_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
COMMIT
