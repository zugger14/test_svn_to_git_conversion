IF NOT EXISTS(
	SELECT sdh.source_deal_header_id, uddft.udf_template_id, sdv.value_id
	FROM source_deal_header sdh
		INNER JOIN user_defined_deal_fields_template uddft
			ON sdh.template_id = uddft.template_id
	CROSS JOIN (
			SELECT value_id FROM static_data_value sdv
			 INNER JOIN  static_data_type sdt 
				ON sdv.type_id = sdv.type_id 
			 WHERE type_name  = 'Generation Category'
				AND code = 'Intermediate Load Generation'
	) sdv
		INNER JOIN user_defined_deal_fields uddf
			ON uddf.udf_template_id = uddft.udf_template_id
	WHERE uddft.field_label = 'Generation Category'
		AND sdh.deal_id IN (
								'Valley View 2 Deal',
								'Valley View 1 Deal',
								'SH2 Deal',
								'SH1 Deal',
								'Scotford Deal',
								'Rainbow 5 Deal',
								'Rainbow 4 Deal',
								'Primrose Deal',
								'Poplar Hill Deal',
								'OMRH Deal',
								'Muskeg Deal',
								'Joffre1',
								'HSM1 Deal',
								'BR5 Deal',
								'BR4 Coal Deal',
								'BR3 Coal Deal'
							)
)

BEGIN

	INSERT INTO user_defined_deal_fields( source_deal_header_id, udf_template_id, udf_value)
	SELECT source_deal_header_id, uddft.udf_template_id, sdv.value_id
	FROM source_deal_header sdh
		INNER JOIN user_defined_deal_fields_template uddft
			ON sdh.template_id = uddft.template_id
	CROSS JOIN (
			SELECT value_id FROM static_data_value sdv
			 INNER JOIN  static_data_type sdt 
				ON sdv.type_id = sdv.type_id 
			 WHERE type_name  = 'Generation Category'
				AND code = 'Intermediate Load Generation'
	) sdv
	WHERE uddft.field_label = 'Generation Category'
		AND sdh.deal_id IN (
								'Valley View 2 Deal',
								'Valley View 1 Deal',
								'SH2 Deal',
								'SH1 Deal',
								'Scotford Deal',
								'Rainbow 5 Deal',
								'Rainbow 4 Deal',
								'Primrose Deal',
								'Poplar Hill Deal',
								'OMRH Deal',
								'Muskeg Deal',
								'Joffre1',
								'HSM1 Deal',
								'BR5 Deal',
								'BR4 Coal Deal',
								'BR3 Coal Deal'
							)

END

