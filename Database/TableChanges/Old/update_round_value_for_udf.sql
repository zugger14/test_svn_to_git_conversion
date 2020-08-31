update udddf set  udddf.udf_value = 0 from user_defined_deal_detail_fields udddf
inner join source_deal_detail sdd on udddf.source_deal_detail_id = sdd.source_deal_detail_id
inner join source_deal_header sdh on sdh.source_deal_header_id = sdh.source_deal_header_id
inner join user_defined_deal_fields_template uddft on uddft.udf_template_id = udddf.udf_template_id
where sdh.template_id = 223 
and field_label = 'round'
and uddft.field_name = '-5632'