UPDATE mfd
SET mfd.default_label = 'System Certificate'
FROM maintain_field_deal mfd 
WHERE farrms_field_id = 'certificate' and field_id = 148