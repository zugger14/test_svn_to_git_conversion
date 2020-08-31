IF COL_LENGTH('module_events','eod_as_of_date') IS NULL
BEGIN
	ALTER TABLE module_events
	ADD eod_as_of_date VARCHAR(1000)
END
