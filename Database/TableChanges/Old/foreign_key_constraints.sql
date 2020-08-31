/* 
This script adds foreign key constraints to various new tables created for TRM specific functions and/or during the integration of 
ComplianceTracker and SettlementTracker.
Author : Milan Lamichhane
Date: 05/04/2009
*/
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
ALTER TABLE dbo.limit_tracking WITH NOCHECK ADD CONSTRAINT
	FK_limit_tracking_source_traders FOREIGN KEY
	(
	trader_id
	) REFERENCES dbo.source_traders
	(
	source_trader_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT


BEGIN TRANSACTION
GO
ALTER TABLE dbo.limit_tracking_curve WITH NOCHECK ADD CONSTRAINT
	FK_limit_tracking_curve_source_price_curve_def FOREIGN KEY
	(
	curve_id
	) REFERENCES dbo.source_price_curve_def
	(
	source_curve_def_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT


BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_minor_location WITH NOCHECK ADD CONSTRAINT
	FK_source_minor_location_source_major_location FOREIGN KEY
	(
	source_major_location_ID
	) REFERENCES dbo.source_major_location
	(
	source_major_location_ID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_minor_location WITH NOCHECK ADD CONSTRAINT
	FK_source_minor_location_source_price_curve_def FOREIGN KEY
	(
	Pricing_Index
	) REFERENCES dbo.source_price_curve_def
	(
	source_curve_def_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_minor_location WITH NOCHECK ADD CONSTRAINT
	FK_source_minor_location_source_commodity FOREIGN KEY
	(
	Commodity_id
	) REFERENCES dbo.source_commodity
	(
	source_commodity_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT


BEGIN TRANSACTION
GO
ALTER TABLE dbo.source_major_location WITH NOCHECK ADD CONSTRAINT
	FK_source_major_location_static_data_value FOREIGN KEY
	(
	location_type
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_major_location WITH NOCHECK ADD CONSTRAINT
	FK_source_major_location_static_data_value_region FOREIGN KEY
	(
	region
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.source_major_location WITH NOCHECK ADD CONSTRAINT
	FK_source_major_location_source_counterparty FOREIGN KEY
	(
	counterparty
	) REFERENCES dbo.source_counterparty
	(
	source_counterparty_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT


BEGIN TRANSACTION
GO
ALTER TABLE dbo.formula_nested WITH NOCHECK ADD CONSTRAINT
	FK_formula_nested_formula_editor FOREIGN KEY
	(
	formula_id
	) REFERENCES dbo.formula_editor
	(
	formula_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.formula_nested WITH NOCHECK ADD CONSTRAINT
	FK_formula_nested_formula_editor_formula_group FOREIGN KEY
	(
	formula_group_id
	) REFERENCES dbo.formula_editor
	(
	formula_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT

BEGIN TRANSACTION
GO
ALTER TABLE dbo.delivery_path WITH NOCHECK ADD CONSTRAINT
	FK_delivery_path_source_minor_location_meter_from FOREIGN KEY
	(
	meter_from
	) REFERENCES dbo.source_minor_location_meter
	(
	meter_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.delivery_path WITH NOCHECK ADD CONSTRAINT
	FK_delivery_path_source_minor_location_meter_to FOREIGN KEY
	(
	meter_to
	) REFERENCES dbo.source_minor_location_meter
	(
	meter_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.delivery_path WITH NOCHECK ADD CONSTRAINT
	FK_delivery_path_static_data_value FOREIGN KEY
	(
	delivery_means
	) REFERENCES dbo.static_data_value
	(
	value_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT


BEGIN TRANSACTION
GO
ALTER TABLE dbo.system_formula WITH NOCHECK ADD CONSTRAINT
	FK_system_formula_formula_editor FOREIGN KEY
	(
	formulaId
	) REFERENCES dbo.formula_editor
	(
	formula_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.system_formula WITH NOCHECK ADD CONSTRAINT
	FK_system_formula_source_deal_type FOREIGN KEY
	(
	dealType
	) REFERENCES dbo.source_deal_type
	(
	source_deal_type_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT


BEGIN TRANSACTION
GO
ALTER TABLE dbo.mv90_data_hour WITH NOCHECK ADD CONSTRAINT
	FK_mv90_data_hour_source_deal_header FOREIGN KEY
	(
	source_deal_header_id
	) REFERENCES dbo.source_deal_header
	(
	source_deal_header_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT


BEGIN TRANSACTION
GO
ALTER TABLE dbo.mv90_data_mins WITH NOCHECK ADD CONSTRAINT
	FK_mv90_data_mins_source_deal_header FOREIGN KEY
	(
	source_deal_header_id
	) REFERENCES dbo.source_deal_header
	(
	source_deal_header_id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
COMMIT
