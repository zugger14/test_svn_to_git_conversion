DELETE mftg
-- SELECT mftg.*
FROM maintain_field_template mft
LEFT JOIN source_deal_header_template sdht on sdht.field_template_id = mft.field_template_id
INNER JOIN maintain_field_template_group mftg ON mftg.field_template_id = mft.field_template_id
WHERE sdht.template_id IS NULL


DELETE mftd
-- SELECT mftd.*
FROM maintain_field_template mft
LEFT JOIN source_deal_header_template sdht on sdht.field_template_id = mft.field_template_id
INNER JOIN maintain_field_template_detail mftd ON mftd.field_template_id = mft.field_template_id
WHERE sdht.template_id IS NULL


DELETE mft
-- SELECT mft.*
FROM maintain_field_template mft
LEFT JOIN source_deal_header_template sdht on sdht.field_template_id = mft.field_template_id
WHERE sdht.template_id IS NULL

GO