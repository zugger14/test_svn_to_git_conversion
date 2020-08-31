IF COL_LENGTH('maintain_scenario', 'risk_factor') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD risk_factor CHAR(1)
END
GO

IF COL_LENGTH('maintain_scenario', 'month_from') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD month_from INT
END
GO

IF COL_LENGTH('maintain_scenario', 'month_to') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD month_to INT
END
GO

IF COL_LENGTH('maintain_scenario', 'scenario_type') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD scenario_type CHAR(1)
END
GO

IF COL_LENGTH('maintain_scenario', 'shift1') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift1 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift2') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift2 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift3') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift3 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift4') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift4 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift5') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift5 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift6') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift6 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift7') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift7 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift8') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift8 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift9') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift9 INT
END
GO

IF COL_LENGTH('maintain_scenario', 'shift10') IS NULL
BEGIN
    ALTER TABLE maintain_scenario ADD shift10 INT
END
GO