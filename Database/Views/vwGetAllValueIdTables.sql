IF  EXISTS (SELECT 1 FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwGetAllValueIdTables]'))
DROP VIEW [dbo].vwGetAllValueIdTables
GO

/****** Object:  View [dbo].[vwGetAllValueIdTables]    Script Date: 08/04/2010 12:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].vwGetAllValueIdTables
AS 
SELECT value_id, description AS Tables , CASE value_id 
				WHEN 4001 THEN 'source_commodity' 
				WHEN 4002 THEN 'source_counterparty' 
				WHEN 4003 THEN 'source_currency' 
				WHEN 4007 THEN 'source_deal_type' 
				WHEN 4008 THEN 'source_price_curve_def' 
				WHEN 4010 THEN 'source_traders' 
				WHEN 4011 THEN 'source_uom' 
				WHEN 4014 THEN 'source_brokers' 
				WHEN 4016 THEN 'contract_group' 
				WHEN 4017 THEN 'source_legal_entity' 
				WHEN 4031 THEN 'source_minor_location' 
				WHEN 400000 THEN 'meter_id' 
				ELSE NULL
			END [source_table_name] 
			, CASE value_id 
				WHEN 4001 THEN 'source_commodity_id' 
				WHEN 4002 THEN 'source_counterparty_id' 
				WHEN 4003 THEN 'source_currency_id' 
				WHEN 4007 THEN 'source_deal_type_id' 
				WHEN 4008 THEN 'source_curve_def_id' 
				WHEN 4010 THEN 'source_trader_id' 
				WHEN 4011 THEN 'source_uom_id' 
				WHEN 4014 THEN 'source_broker_id' 
				WHEN 4016 THEN 'contract_id' 
				WHEN 4017 THEN 'source_legal_entity_id' 
				WHEN 4031 THEN 'source_minor_location_id' 
				WHEN 400000 THEN 'meter_id' 
				ELSE NULL 
			END [pk_column]
FROM static_data_value
WHERE (type_id = 4000) 
	AND (NOT (value_id IN (4012, 4004, 4048, 4005, 4006, 4013,4032,4033, 4009,4035,4036,4037,4038,4039,4040,4041,4043,4044,4045,4046,4047,4049, 4053, 4064)))
UNION
SELECT type_id [value_id], type_name [description], NULL,NULL
FROM static_data_type WHERE type_id = 4200
 
 
 