
UPDATE source_deal_header
SET
internal_deal_type_value_id = '19'
WHERE internal_deal_type_value_id = '23'

UPDATE source_deal_header
SET
internal_deal_type_value_id = '20'
WHERE internal_deal_type_value_id = '24'

UPDATE source_deal_header
SET
internal_deal_type_value_id = '21'
WHERE internal_deal_type_value_id = '25'

UPDATE source_deal_header_template
SET
internal_deal_type_value_id = '19'
WHERE internal_deal_type_value_id = '23'

UPDATE source_deal_header_template
SET
internal_deal_type_value_id = '20'
WHERE internal_deal_type_value_id = '24'


UPDATE source_deal_header_template
SET    internal_deal_type_value_id = '21'
WHERE  internal_deal_type_value_id = '25'

DELETE 
FROM   internal_deal_type_subtype_types
WHERE  internal_deal_type_subtype_id IN (23, 24, 25)

UPDATE internal_deal_type_subtype_types
SET    type_subtype_flag = NULL
WHERE  internal_deal_type_subtype_id IN (19, 20, 21)