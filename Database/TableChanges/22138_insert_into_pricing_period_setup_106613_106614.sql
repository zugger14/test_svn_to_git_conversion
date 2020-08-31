IF NOT EXISTS(SELECT 1 FROM pricing_period_setup WHERE pricing_period_value_id = 106613)
BEGIN
	INSERT INTO pricing_period_setup(pricing_period_value_id, period_type, average_period, skip_period, delivery_period,expiration_calendar, formula_id)
	SELECT 106613, 'm', 6, 0, 0, 0, NULL
END
ELSE
	PRINT('Data for 106613 already exists.')



IF NOT EXISTS(SELECT 1 FROM pricing_period_setup WHERE pricing_period_value_id = 106614)
BEGIN
	INSERT INTO pricing_period_setup(pricing_period_value_id, period_type, average_period, skip_period, delivery_period,expiration_calendar, formula_id)
	SELECT 106614, 'm', 6, 1, 0, 0, NULL
END
ELSE
	PRINT('Data for 106614 already exists.')