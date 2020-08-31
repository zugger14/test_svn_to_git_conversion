IF COL_LENGTH('multiple_scenario_shift_result', 'mtm_value_one') IS NULL
BEGIN
    ALTER TABLE multiple_scenario_shift_result ADD mtm_value_one FLOAT NULL
END
ELSE
BEGIN
    PRINT 'mtm_value_one Already Exists.'
END

IF COL_LENGTH('multiple_scenario_shift_result', 'mtm_value_two') IS NULL
BEGIN
    ALTER TABLE multiple_scenario_shift_result ADD mtm_value_two FLOAT NULL
END
ELSE
BEGIN
    PRINT 'mtm_value_two Already Exists.'
END