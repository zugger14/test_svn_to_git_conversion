UPDATE formula_editor
SET    formula = REPLACE(formula, 'dbo.FNADynamicCurve', 'dbo.FNAContractPriceValue')
WHERE  formula LIKE '%dbo.FNADynamicCurve%'

UPDATE formula_editor
SET formula = REPLACE(formula, 'dbo.FNAEODHours', 'dbo.FNAEOHHours')
WHERE formula LIKE '%dbo.FNAEODHours%'

