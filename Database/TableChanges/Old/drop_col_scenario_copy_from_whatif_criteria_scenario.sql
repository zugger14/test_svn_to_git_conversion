/**
* drop comlumn scenario copy
**/

IF COL_LENGTH('whatif_criteria_scenario', 'scenario_copy') IS NOT NULL
BEGIN
    ALTER TABLE whatif_criteria_scenario DROP COLUMN scenario_copy
END
GO