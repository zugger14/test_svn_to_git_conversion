DECLARE @ice_tenor_bucket_id INT
DECLARE @ice_projection_index_group_id INT
DECLARE @ice_trader_id INT
DECLARE @ice_broker_id INT
DECLARE @ice_counterparty_id INT
	
SELECT @ice_tenor_bucket_id = mapping_table_id  FROM generic_mapping_header gmh WHERE gmh.mapping_name = 'Ice Tenor Bucket'
SELECT @ice_projection_index_group_id = mapping_table_id  FROM generic_mapping_header gmh WHERE gmh.mapping_name = 'Ice Projection Index Group'
SELECT @ice_trader_id = mapping_table_id  FROM generic_mapping_header gmh WHERE gmh.mapping_name = 'Ice Trader'
SELECT @ice_broker_id = mapping_table_id  FROM generic_mapping_header gmh WHERE gmh.mapping_name = 'Ice Broker'
SELECT @ice_counterparty_id = mapping_table_id  FROM generic_mapping_header gmh WHERE gmh.mapping_name = 'Ice CounterParty'
	 
DECLARE @index INT
DECLARE @tenor_bucket INT 
DECLARE @ice_trader INT
DECLARE @trm_trader INT 
DECLARE @ice_broker INT 
DECLARE @trm_broker INT 
DECLARE @ice_counterparty INT 
DECLARE @trm_counterparty INT 
DECLARE @pro_index_group INT 
DECLARE @uom_from INT 
DECLARE @uom_to INT 
 
SELECT @index = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Index'
SELECT @tenor_bucket = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Tenor Bucket'
SELECT @ice_trader = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'ICE Trader'
SELECT @trm_trader = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TRM Trader'
SELECT @ice_broker = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'ICE Broker'
SELECT @trm_broker = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TRM Broker'
SELECT @ice_counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'ICE Counterparty'
SELECT @trm_counterparty = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'TRM Counterparty'
SELECT @pro_index_group = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'Projection Index Group'
SELECT @uom_from = udf_template_id FROM user_defined_fields_template WHERE Field_label = 'UOM From'
SELECT @uom_to= udf_template_id FROM user_defined_fields_template WHERE Field_label = 'UOM To'

INSERT INTO generic_mapping_definition
(
	mapping_table_id,
	clm1_label,
	clm1_udf_id,
	clm2_label,
	clm2_udf_id	
)
VALUES
(
	@ice_tenor_bucket_id,
	'Index',
	@Index,
	'Tenor Bucket',
	@tenor_bucket
)

INSERT INTO generic_mapping_definition
(
	mapping_table_id,
	clm1_label,
	clm1_udf_id,
	clm2_label,
	clm2_udf_id,
	clm3_label,
	clm3_udf_id		
)
VALUES
(
	@ice_projection_index_group_id,
	'Projection Index Group',
	@pro_index_group,
	'UOM From',
	@uom_from,
	'UOM To',
	@uom_to	
)

INSERT INTO generic_mapping_definition
(
	mapping_table_id,
	clm1_label,
	clm1_udf_id,
	clm2_label,
	clm2_udf_id	
)
VALUES
(
	@ice_trader_id,
	'ICE Trader',
	@ice_trader,
	'TRM Trader',
	@trm_trader
)

INSERT INTO generic_mapping_definition
(
	mapping_table_id,
	clm1_label,
	clm1_udf_id,
	clm2_label,
	clm2_udf_id	
)
VALUES
(
	@ice_broker_id,
	'ICE Broker',
	@ice_broker,
	'TRM Broker',
	@trm_broker
)

INSERT INTO generic_mapping_definition
(
	mapping_table_id,
	clm1_label,
	clm1_udf_id,
	clm2_label,
	clm2_udf_id	
)
VALUES
(
	@ice_counterparty_id,
	'ICE Counterparty',
	@ice_counterparty,
	'TRM Counterparty',
	@trm_counterparty
)

SELECT * FROM generic_mapping_definition gmd