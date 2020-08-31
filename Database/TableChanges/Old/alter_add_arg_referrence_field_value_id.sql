IF COL_LENGTH('formula_editor_parameter', 'arg_referrence_field_value_id') IS NULL
BEGIN
	ALTER TABLE formula_editor_parameter ADD arg_referrence_field_value_id int
	PRINT 'Column formula_editor_parameter.arg_referrence_field_value_id added.'
END
ELSE
BEGIN
	PRINT 'Column formula_editor_parameter.arg_referrence_field_value_id already exists.'
END
GO

/*

select sdv.code,fep.* from dbo.formula_editor_parameter fep
	inner join dbo.static_data_value sdv on fep.formula_id=sdv.value_id		
where sdv.code in ( 
	'PeakHours',
	'DealType',
	'ContractValue',
	'GetLogicalValue',
	'UDFDetailValue',
	'UDFValue',
	'AveragePrice',
	'MnPrice',
	'MxPrice',
	'GetCurveValue',
	'AverageQVol',
	'DealFVolm',
	'MeterVol',
	'DealSettlement',
	'DealFees',
	'DealNetPrice',
	'GetTimeSeriesData',
	'DealFloatPrice'
)

order by 1,sequence

*/

update formula_editor_parameter 
set arg_referrence_field_value_id =40000 where  formula_id in (-905,-916,-838,-844) and sequence=1

update formula_editor_parameter 
set arg_referrence_field_value_id =40002 where  formula_id in (-898,850) and sequence=1

update formula_editor_parameter 
set arg_referrence_field_value_id =null where  formula_param_id=51