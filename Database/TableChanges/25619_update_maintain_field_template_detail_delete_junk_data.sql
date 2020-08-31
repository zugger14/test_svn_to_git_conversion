-- Delete Junk Data
DELETE mftd
FROM maintain_field_template_detail mftd
LEFT JOIN maintain_field_template_group_detail mftgd ON mftgd.group_id = mftd.detail_group_id
WHERE mftd.detail_group_id IS NOT NULL AND mftgd.group_id IS NULL