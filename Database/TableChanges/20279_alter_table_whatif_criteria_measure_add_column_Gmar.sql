IF COL_LENGTH('whatif_criteria_measure', 'Gmar') IS NULL
BEGIN
   ALTER TABLE whatif_criteria_measure ADD Gmar CHAR(1) NULL
END
