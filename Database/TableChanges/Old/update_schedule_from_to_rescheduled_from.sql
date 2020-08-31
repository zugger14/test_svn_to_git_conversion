UPDATE static_data_value SET code = 'Rescheduled From', [description] = 'Rescheduled From' WHERE [value_id] = -5605
PRINT 'Updated Static value -5605 - Rescheduled From.'

UPDATE user_defined_deal_fields_template SET Field_label = 'Rescheduled From' WHERE field_name = -5605 AND field_id = -5605
PRINT 'Updated field label for -5605 as Rescheduled From'

UPDATE mftd SET mftd.field_caption = 'Rescheduled From'
FROM maintain_field_template_detail mftd 
INNER JOIN user_defined_fields_template udft ON udft.udf_template_id = mftd.field_id
WHERE  udft.field_name = -5605 AND mftd.field_caption = 'Scheduled From'
PRINT 'Updated field caption from Scheduled From to Rescheduled From.'