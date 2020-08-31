-- Updating static_data_udf_values because Combo is changed to Textbox in UI
-- Static_data_udf_values column is holding combo ID not value so, 
-- Updatating combo ID to its value in table so, user can see the actual value in Textbox.

UPDATE musd SET musd.static_data_udf_values = mi.recorderid
FROM maintain_udf_static_data_detail_values musd
INNER JOIN meter_id mi ON CAST(mi.meter_id AS VARCHAR(150)) = CAST(musd.static_data_udf_values AS VARCHAR(150))
INNER JOIN application_ui_template_fields autf ON musd.application_field_id = autf.application_field_id
INNER JOIN user_defined_fields_template udft 
ON udft.udf_template_id = autf.udf_template_id
WHERE udft.field_name IN (-5622,-5623) AND ISNUMERIC(musd.static_data_udf_values) = 1

