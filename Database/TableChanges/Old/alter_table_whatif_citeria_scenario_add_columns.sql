IF COL_LENGTH('whatif_criteria_scenario', 'risk_factor') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD risk_factor CHAR(1)
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'month_from') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD month_from INT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'month_to') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD month_to INT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'scenario_type') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD scenario_type CHAR(1)
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift1') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift1 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift2') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift2 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift3') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift3 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift4') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift4 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift5') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift5 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift6') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift6 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift7') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift7 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift8') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift8 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift9') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift9 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'shift10') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD shift10 FLOAT
END
GO

IF COL_LENGTH('whatif_criteria_scenario', 'use_existing_values') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario ADD use_existing_values CHAR(1)
END
GO