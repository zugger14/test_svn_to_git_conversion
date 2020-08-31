IF EXISTS(SELECT 'X' FROm formula_function_mapping WHERE function_name='WACOGLocPur')
	DELETE FROM  formula_function_mapping WHERE function_name='WACOGLocPur'

IF EXISTS(SELECT 'X' FROm formula_function_mapping WHERE function_name='WACOGWD')
	DELETE FROM  formula_function_mapping WHERE function_name='WACOGWD'

--select * from formula_function_mapping

INSERT INTO formula_function_mapping(function_name,eval_string,arg1)
SELECT 'WACOGLocPur','dbo.FNARWACOGLocPur(arg1)','CONVERT(VARCHAR(15), sdh.source_deal_header_id)'

INSERT INTO formula_function_mapping(function_name,eval_string,arg1)
SELECT 'WACOGWD','dbo.FNARWACOGWD(arg1)','CONVERT(VARCHAR(15), sdh.source_deal_header_id)'

