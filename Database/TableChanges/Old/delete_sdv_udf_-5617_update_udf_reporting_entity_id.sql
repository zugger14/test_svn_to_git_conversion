update user_defined_fields_template set field_label = 'Code' where field_name = -5615
update user_defined_fields_template set field_label = 'Code Type' where field_name = -5616
--select * from user_defined_deal_fields_template where field_name = -5617

delete uddf from user_defined_deal_fields uddf 
inner join user_defined_deal_fields_template uddft ON uddf.udf_template_id = uddft.udf_template_id 
and uddft.field_label = 'uti'
delete from user_defined_deal_fields_template where field_name = -5617
delete from user_defined_fields_template where field_name = -5617
delete from static_data_value where value_id =-5617 and code ='uti'

--select * from user_defined_deal_fields

--select * from user_defined_deal_fields_template

--select * from user_defined_deal_fields where udf_template_id in (7334,7335,7336,7337,7340,7341)

delete from maintain_field_template_detail where field_template_id  = 134 and field_caption = 'UTI'

update static_data_value set code = 'Reporting Entity ID', description = 'Reporting Entity ID' where value_id = -5618
update static_data_value set code = 'Reporting Entity ID Source', description = 'Reporting Entity ID Source' where value_id = -5619

update user_defined_fields_template set field_label = 'Reporting Entity ID' where field_name = -5618
update user_defined_fields_template set field_label = 'Reporting Entity ID Source' where field_name = -5619

update user_defined_deal_fields_template set field_label = 'Reporting Entity ID' where field_name = -5618
update user_defined_deal_fields_template set field_label = 'Reporting Entity ID Source', field_type = 'd', sql_string = 'SELECT ''ID_1'',''ACER'' UNION ALL select ''ID_2'',''LEI'' UNION ALL SELECT ''ID_3'',''BIC''' where field_name = -5619

UPDATE maintain_field_template_detail set field_caption = 'Reporting Entity ID' where field_template_id  = 134 and field_caption = 'Sourcing Classification'
UPDATE maintain_field_template_detail set field_caption = 'Reporting Entity ID Source' where field_template_id  = 134 and field_caption = 'Forecasting Group'