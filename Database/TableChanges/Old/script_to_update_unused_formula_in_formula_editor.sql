/*
* Update unused user defined formula with equivalent formula.
*/
UPDATE formula_editor SET formula = REPLACE(formula, 'UDFCharges', 'UDFValue')
UPDATE formula_editor SET formula = REPLACE(formula, 'CVDemand', 'CVD')
UPDATE formula_editor SET formula = REPLACE(formula, 'ContractVolume', 'ContractVol')
