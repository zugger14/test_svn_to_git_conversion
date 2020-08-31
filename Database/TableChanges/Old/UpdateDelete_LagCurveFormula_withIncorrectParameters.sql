/* Delete The Conflicting Old Formulas */

UPDATE source_price_curve_def
SET    formula_id = NULL
WHERE  formula_id IN (32, 119, 50, 52, 51, 608, 635, 636,749)

DELETE formula_nested
WHERE  formula_id IN (31, 32, 33, 50, 51, 52, 116, 119, 520, 521, 593, 595, 608,635, 636,749)

DELETE formula_editor
WHERE  formula_id IN (31, 32, 33, 50, 51, 52, 116, 119, 520, 521, 593, 595, 608,635, 636, 749)


/* End - Delete */

/* Update The Formula */

UPDATE formula_editor
SET
	formula = 'dbo.FNALagCurve(116,0,6,0,3,null,0,7.34)+dbo.FNALagCurve(193,0,6,0,3,null,0,12.23)'
WHERE formula_id = 692

/* Update - End */

