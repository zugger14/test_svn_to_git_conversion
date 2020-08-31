
IF NOT EXISTS(SELECT 1 FROM pricing_period_setup WHERE pricing_period_value_id = 106615)
BEGIN
	INSERT INTO pricing_period_setup(pricing_period_value_id, period_type, average_period, skip_period, delivery_period,expiration_calendar, formula_id)
	SELECT 106615, 'm', 1, 1, 1, 0, NULL
END
ELSE
BEGIN
	PRINT 'Data for 106615 already exists.'
END