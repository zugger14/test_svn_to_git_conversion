--After Adding Static Data
DECLARE @positive_price_commodity_value_id INT, @negative_price_commodity_value_id INT

SELECT @positive_price_commodity_value_id = value_id 
FROM static_data_value 
WHERE type_id = 5500
AND code = 'Positive Price Commodity Old'

SELECT @negative_price_commodity_value_id = value_id 
FROM static_data_value 
WHERE type_id = 5500
AND code = 'Negative Price Commodity Old'

ALTER TABLE user_defined_deal_fields_template_main NOCHECK CONSTRAINT FK_user_defined_deal_fields_template_field_id
ALTER TABLE user_defined_deal_fields_template_main NOCHECK CONSTRAINT FK_user_defined_deal_fields_template_field_name

UPDATE user_defined_deal_fields_template_main SET field_id = -10000368, field_name = -10000368 WHERE field_id = @positive_price_commodity_value_id

UPDATE user_defined_deal_fields_template_main SET field_id = -10000369, field_name = -10000369 WHERE field_id = @negative_price_commodity_value_id

UPDATE user_defined_fields_template SET field_id = -10000368, field_name = -10000368 WHERE field_id = @positive_price_commodity_value_id

UPDATE user_defined_fields_template SET field_id = -10000369, field_name = -10000369 WHERE field_id = @negative_price_commodity_value_id

ALTER TABLE user_defined_deal_fields_template_main WITH CHECK CHECK CONSTRAINT FK_user_defined_deal_fields_template_field_id
ALTER TABLE user_defined_deal_fields_template_main WITH CHECK CHECK CONSTRAINT FK_user_defined_deal_fields_template_field_name

--Updating field_id(s) with new of the existing results in the table 
UPDATE ifbs SET ifbs.field_id = sdv.value_id
FROM index_fees_breakdown_settlement ifbs
INNER JOIN static_data_value sdv ON sdv.code = ifbs.field_name
	AND sdv.type_id = 5500
WHERE ifbs.field_id = @positive_price_commodity_value_id

UPDATE ifbs SET ifbs.field_id = sdv.value_id
FROM index_fees_breakdown_settlement ifbs
INNER JOIN static_data_value sdv ON sdv.code = ifbs.field_name
	AND sdv.type_id = 5500
WHERE ifbs.field_id = @negative_price_commodity_value_id

--Updating value based on the existing UDF 
UPDATE sdht SET split_positive_and_negative_commodity = 'y'
FROM source_deal_header_template sdht
INNER JOIN (SELECT DISTINCT template_id FROM user_defined_deal_fields_template WHERE field_id IN (-10000369, -10000368)
			UNION ALL
			SELECT DISTINCT template_id FROM user_defined_deal_fields_template_main WHERE field_id IN (-10000369, -10000368)) t ON t.template_id = sdht.template_id

--Deleting existing mapped UDF as these are not required now because we using the checkbox option as "split_positive_and_negative_commodity" from "table source_deal_header_template" to calculate positive/negative commodity value calculation

DELETE uddf
FROM user_defined_deal_fields uddf
INNER JOIN (SELECT DISTINCT udf_template_id FROM user_defined_deal_fields_template WHERE field_id IN (-10000369, -10000368)
			UNION ALL
			SELECT DISTINCT udf_template_id FROM user_defined_deal_fields_template_main WHERE field_id IN (-10000369, -10000368)) t ON t.udf_template_id = uddf.udf_template_id

DELETE udddf
FROM user_defined_deal_detail_fields udddf
INNER JOIN (SELECT DISTINCT udf_template_id FROM user_defined_deal_fields_template WHERE field_id IN (-10000369, -10000368)
			UNION ALL
			SELECT DISTINCT udf_template_id FROM user_defined_deal_fields_template_main WHERE field_id IN (-10000369, -10000368)) t ON t.udf_template_id = udddf.udf_template_id

DELETE FROM user_defined_deal_fields_template_main WHERE field_id IN (-10000369, -10000368)