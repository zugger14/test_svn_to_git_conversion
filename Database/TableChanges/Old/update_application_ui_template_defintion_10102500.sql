DECLARE @default_commodity INT,
		@default_valuation_curve INT

SELECT @default_commodity = source_commodity_id FROM source_commodity WHERE commodity_id = 'Natural Gas'
SELECT @default_valuation_curve = source_curve_def_id FROM source_price_curve_def WHERE curve_id = 'Default_Curve' AND curve_name = 'Default_Curve'

UPDATE application_ui_template_definition SET default_value = @default_commodity WHERE application_function_id = 10102500 AND field_id = 'commodity_id'
UPDATE application_ui_template_definition SET default_value = @default_valuation_curve WHERE application_function_id = 10102500 AND field_id = 'term_pricing_index'