IF EXISTS(SELECT *
          FROM   maintain_field_deal
          WHERE  field_deal_id = 132
                 AND farrms_field_id = 'formula_curve_id')
BEGIN
	UPDATE maintain_field_deal
	SET    field_type = 'w',
	       sql_string = 'SELECT source_curve_def_id,curve_name FROM source_price_curve_def',
	       window_function_id = 10102610
	WHERE
			field_deal_id = 132 
			AND farrms_field_id = 'formula_curve_id' 
END
ELSE
	PRINT 'No Record found'