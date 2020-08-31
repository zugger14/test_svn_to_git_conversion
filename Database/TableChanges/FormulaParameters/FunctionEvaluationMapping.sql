
/* Script to Insert into the table formula_function_mapping for formula definitions*/
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'LagCurve') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'LagCurve', 
  'dbo.FNARCLagCurve(REPLACE(arg1,''ASFLOAT'','' AS FLOAT '') ,arg2,cast(arg3 as int),cast(arg4  as int),cast(arg5  as int),cast(arg6  as int),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),CAST(NULLIF(arg10,''NULL'') AS INT)  ,CAST(NULLIF(arg11,''NULL'') AS FLOAT),CAST(NULLIF(arg12,''NULL'') AS FLOAT),arg13,CAST(NULLIF(arg14,''NULL'') AS VARCHAR),wif.curve_shift_val  ,wif.curve_shift_per)',
  'CONVERT(VARCHAR(20),prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  '''4500''',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'arg1',
  'arg2',
  'arg3',
  'arg4',
  'arg5',
  'arg6',
  'arg7',
  'arg8',
  'arg9',
  'arg10',
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'LagCurve', 
  eval_string = 'dbo.FNARCLagCurve(REPLACE(arg1,''ASFLOAT'','' AS FLOAT '') ,arg2,cast(arg3 as int),cast(arg4  as int),cast(arg5  as int),cast(arg6  as int),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),CAST(NULLIF(arg10,''NULL'') AS INT)  ,CAST(NULLIF(arg11,''NULL'') AS FLOAT),CAST(NULLIF(arg12,''NULL'') AS FLOAT),arg13,CAST(NULLIF(arg14,''NULL'') AS VARCHAR),wif.curve_shift_val  ,wif.curve_shift_per)',
  arg1 = 'CONVERT(VARCHAR(20),prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = '''4500''',
  arg4 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg5 = 'arg1',
  arg6 = 'arg2',
  arg7 = 'arg3',
  arg8 = 'arg4',
  arg9 = 'arg5',
  arg10 = 'arg6',
  arg11 = 'arg7',
  arg12 = 'arg8',
  arg13 = 'arg9',
  arg14 = 'arg10',
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'LagCurve'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Volume') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Volume', 
  'arg1',
  'CONVERT(VARCHAR(20),t.Volume)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Volume', 
  eval_string = 'arg1',
  arg1 = 'CONVERT(VARCHAR(20),t.Volume)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Volume'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealVolm', 
  'dbo.FNARDealVolm(arg1 ,arg2,cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg9 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  'CONVERT(VARCHAR(10),ISNULL(t.curve_tou,18900))',
  'CONVERT(VARCHAR(10),t.deal_type)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealVolm', 
  eval_string = 'dbo.FNARDealVolm(arg1 ,arg2,cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg9 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg5 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg6 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg7 = 'CONVERT(VARCHAR(10),ISNULL(t.curve_tou,18900))',
  arg8 = 'CONVERT(VARCHAR(10),t.deal_type)',
  arg9 = 'arg1',
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'WghtFixPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'WghtFixPrice', 
  'dbo.FNARWghtFixPrice(arg1 ,arg2,cast(arg3 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'WghtFixPrice', 
  eval_string = 'dbo.FNARWghtFixPrice(arg1 ,arg2,cast(arg3 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'WghtFixPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'FixedVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'FixedVolm', 
  'dbo.FNARFixedVolm(arg1 ,arg2,cast(arg3 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'FixedVolm', 
  eval_string = 'dbo.FNARFixedVolm(arg1 ,arg2,cast(arg3 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'FixedVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CurveM') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CurveM', 
  'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARECCurveSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),wif.curve_shift_val  ,wif.curve_shift_per) ELSE dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),0,0,0,wif.curve_shift_val  ,wif.curve_shift_per) END',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CASE WHEN ''@calc_type''=''s'' THEN CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR) ELSE arg1 END',
  'arg2',
  'CONVERT(VARCHAR,t.curve_source_value_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CurveM', 
  eval_string = 'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARECCurveSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),wif.curve_shift_val  ,wif.curve_shift_per) ELSE dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),0,0,0,wif.curve_shift_val  ,wif.curve_shift_per) END',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CASE WHEN ''@calc_type''=''s'' THEN CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR) ELSE arg1 END',
  arg4 = 'arg2',
  arg5 = 'CONVERT(VARCHAR,t.curve_source_value_id)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CurveM'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'UDFValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'UDFValue', 
  'case when isnull(''@formula_audit'',''n'')=''y'' then dbo.FNARUDFValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),''@as_of_date'',cast(arg10 as INT)) else dbo.FNARUDFValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),null,cast(arg10 as INT)) end',
  'CONVERT(VARCHAR(10),case when uddft.udf_type=''d'' then -1*ISNULL(t.source_deal_detail_id,sdd.source_deal_detail_id) else ISNULL(t.source_deal_header_id,sdd.source_deal_header_id) end)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'CONVERT(VARCHAR(20),t.prod_date)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'UDFValue', 
  eval_string = 'case when isnull(''@formula_audit'',''n'')=''y'' then dbo.FNARUDFValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),''@as_of_date'',cast(arg10 as INT)) else dbo.FNARUDFValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),null,cast(arg10 as INT)) end',
  arg1 = 'CONVERT(VARCHAR(10),case when uddft.udf_type=''d'' then -1*ISNULL(t.source_deal_detail_id,sdd.source_deal_detail_id) else ISNULL(t.source_deal_header_id,sdd.source_deal_header_id) end)',
  arg2 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date)',
  arg4 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg5 = 'CONVERT(VARCHAR,t.hour)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg9 = 'CONVERT(VARCHAR,t.contract_id)',
  arg10 = 'arg1',
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'UDFValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Channel') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Channel', 
  'dbo.FNARECChannel(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),CAST(NULLIF(arg9,''NULL'') AS INT),cast(arg10 as int),cast(arg11 as int))',
  'CONVERT(VARCHAR(20),prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR,t.mins)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'CONVERT(VARCHAR(10),t.meter_id)',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'CONVERT(VARCHAR(10),t.commodity_id)',
  'arg1',
  'arg2',
  'CONVERT(VARCHAR(10),t.is_dst)',
  'CONVERT(VARCHAR(10),t.counterparty_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Channel', 
  eval_string = 'dbo.FNARECChannel(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),CAST(NULLIF(arg9,''NULL'') AS INT),cast(arg10 as int))',
  arg1 = 'CONVERT(VARCHAR(20),prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.hour)',
  arg3 = 'CONVERT(VARCHAR,t.mins)',
  arg4 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg5 = 'CONVERT(VARCHAR(10),t.meter_id)',
  arg6 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg7 = 'CONVERT(VARCHAR(10),t.commodity_id)',
  arg8 = 'arg1',
  arg9 = 'arg2',
  arg10 = 'CONVERT(VARCHAR(10),t.is_dst)',
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Channel'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MnthlyRollingAveg') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MnthlyRollingAveg', 
  'dbo.FNARMnthlyRollingAveg(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'CONVERT(VARCHAR,t.hour)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MnthlyRollingAveg', 
  eval_string = 'dbo.FNARMnthlyRollingAveg(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg5 = 'CONVERT(VARCHAR,t.formula_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'arg1',
  arg8 = 'arg2',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MnthlyRollingAveg'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'RollingSum') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'RollingSum', 
  'dbo.FNARRollingSum(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg9 as int),cast(arg10 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'arg1',
  'arg2',
  'arg3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'RollingSum', 
  eval_string = 'dbo.FNARRollingSum(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg9 as int),cast(arg10 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg5 = 'CONVERT(VARCHAR,t.formula_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg8 = 'arg1',
  arg9 = 'arg2',
  arg10 = 'arg3',
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'RollingSum'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Rolling') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Rolling', 
  'dbo.FNARRolling(arg1,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg8 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Rolling', 
  eval_string = 'dbo.FNARRolling(arg1,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg8 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg5 = 'CONVERT(VARCHAR,t.formula_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg8 = 'arg1',
  arg9 = 'arg2',
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Rolling'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'LastMnthValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'LastMnthValue', 
  'dbo.FNARLastMnthValue(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'CONVERT(VARCHAR,t.hour)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'LastMnthValue', 
  eval_string = 'dbo.FNARLastMnthValue(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg5 = 'CONVERT(VARCHAR,t.formula_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'arg1',
  arg8 = 'arg2',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'LastMnthValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CorresMnthValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CorresMnthValue', 
  'dbo.FNARCorresMnthValue(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg9 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CorresMnthValue', 
  eval_string = 'dbo.FNARCorresMnthValue(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg9 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg5 = 'CONVERT(VARCHAR,t.formula_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg8 = 'arg1',
  arg9 = 'arg2',
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CorresMnthValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AnnualVolCOD') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AnnualVolCOD', 
  'dbo.FNARAnnualVolCOD(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AnnualVolCOD', 
  eval_string = 'dbo.FNARAnnualVolCOD(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg5 = 'CONVERT(VARCHAR,t.formula_id)',
  arg6 = 'arg1',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AnnualVolCOD'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DPrice', 
  'deal_settlement_price',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DPrice', 
  eval_string = 'deal_settlement_price',
  arg1 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg4 = 'CONVERT(VARCHAR,t.hour)',
  arg5 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IsPeak') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IsPeak', 
  'CAST(curve_tou AS INT)',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IsPeak', 
  eval_string = 'CAST(curve_tou AS INT)',
  arg1 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.hour)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IsPeak'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Month') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Month', 
  'dbo.FNARMonth(arg1)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Month', 
  eval_string = 'dbo.FNARMonth(arg1)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Month'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'GeneratorMxHour') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'GeneratorMxHour', 
  'dbo.FNARGeneratorMxHour(arg1,cast(arg2 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'GeneratorMxHour', 
  eval_string = 'dbo.FNARGeneratorMxHour(arg1,cast(arg2 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'arg1',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'GeneratorMxHour'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MxRwValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MxRwValue', 
  'dbo.FNARMxRwValue(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'CONVERT(VARCHAR,t.hour)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MxRwValue', 
  eval_string = 'dbo.FNARMxRwValue(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg5 = 'CONVERT(VARCHAR,t.formula_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'arg1',
  arg8 = 'arg2',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MxRwValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'PeakDmd') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'PeakDmd', 
  'dbo.FNARPeakDmd(arg1,arg2,arg3,arg4,arg5)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'PeakDmd', 
  eval_string = 'dbo.FNARPeakDmd(arg1,arg2,arg3,arg4,arg5)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = 'arg1',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'PeakDmd'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'InterruptCalc') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'InterruptCalc', 
  'dbo.FNARPeakDmd(arg1,arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT) )',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'InterruptCalc', 
  eval_string = 'dbo.FNARPeakDmd(arg1,arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT) )',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'arg1',
  arg5 = 'arg2',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'InterruptCalc'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ContractVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ContractVol', 
  'dbo.FNARContractVol(arg1,arg2,arg3)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ContractVol', 
  eval_string = 'dbo.FNARContractVol(arg1,arg2,arg3)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'arg1',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ContractVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ContractValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ContractValue', 
  'dbo.FNARContractValue(arg1,arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT), CAST(arg7 AS INT), arg8, arg9)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'arg1',
  'arg2',
  'arg3',
  'arg4',
  'CONVERT(VARCHAR,t.[hour])',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ContractValue', 
  eval_string = 'dbo.FNARContractValue(arg1,arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT), CAST(arg7 AS INT), arg8, arg9)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'arg1',
  arg4 = 'arg2',
  arg5 = 'arg3',
  arg6 = 'arg4',
  arg7 = 'CONVERT(VARCHAR,t.[hour])',
  arg8 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg9 = 'arg6',
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ContractValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CVD') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CVD', 
  'dbo.FNARCVD(arg1,arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CVD', 
  eval_string = 'dbo.FNARCVD(arg1,arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'arg1',
  arg5 = 'arg2',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CVD'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'HourlyDmd') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'HourlyDmd', 
  'dbo.FNARHourlyDmd(arg1,arg2,arg3,arg4)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'HourlyDmd', 
  eval_string = 'dbo.FNARHourlyDmd(arg1,arg2,arg3,arg4)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'HourlyDmd'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DmdDateTime') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DmdDateTime', 
  'dbo.FNARDmdDateTime(arg1,arg2,arg3,arg4,CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DmdDateTime', 
  eval_string = 'dbo.FNARDmdDateTime(arg1,arg2,arg3,arg4,CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DmdDateTime'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'InterruptVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'InterruptVol', 
  'dbo.FNARInterruptVol(arg1,arg2,arg3,CAST(arg4 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'InterruptVol', 
  eval_string = 'dbo.FNARInterruptVol(arg1,arg2,arg3,CAST(arg4 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'arg1',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'InterruptVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'WeekDaysInMnth') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'WeekDaysInMnth', 
  'dbo.FNARWeekDaysInMnth(arg1,arg2)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR, t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'WeekDaysInMnth', 
  eval_string = 'dbo.FNARWeekDaysInMnth(arg1,arg2)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR, t.contract_id)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'WeekDaysInMnth'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CoIncidentPeak') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CoIncidentPeak', 
  'dbo.FNARCoIncidentPeak(arg1,arg2,arg3,arg4,CAST(arg3 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CoIncidentPeak', 
  eval_string = 'dbo.FNARCoIncidentPeak(arg1,arg2,arg3,arg4,CAST(arg3 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = 'arg1',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CoIncidentPeak'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'PeakDmndMeter') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'PeakDmndMeter', 
  'dbo.FNARPeakDmndMeter(arg1,arg2,arg3,arg4,CAST(arg3 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'PeakDmndMeter', 
  eval_string = 'dbo.FNARPeakDmndMeter(arg1,arg2,arg3,arg4,CAST(arg3 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = 'arg1',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'PeakDmndMeter'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IsInterrupt') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IsInterrupt', 
  'dbo.FNARIsInterrupt(arg1,arg2,arg3,CAST(arg4 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IsInterrupt', 
  eval_string = 'dbo.FNARIsInterrupt(arg1,arg2,arg3,CAST(arg4 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IsInterrupt'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IntCumulativeMnth') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IntCumulativeMnth', 
  'dbo.FNARIntCumulativeMnth(arg1,arg2,arg3)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IntCumulativeMnth', 
  eval_string = 'dbo.FNARIntCumulativeMnth(arg1,arg2,arg3)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IntCumulativeMnth'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IntStartMnth') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IntStartMnth', 
  'dbo.FNARIntStartMnth(arg1,arg2,arg3)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IntStartMnth', 
  eval_string = 'dbo.FNARIntStartMnth(arg1,arg2,arg3)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IntStartMnth'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IntStopMnth') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IntStopMnth', 
  'dbo.FNARIntStopMnth(arg1,arg2,arg3)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IntStopMnth', 
  eval_string = 'dbo.FNARIntStopMnth(arg1,arg2,arg3)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IntStopMnth'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DailyRollingAveg') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DailyRollingAveg', 
  'dbo.FNARDailyRollingAveg(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'CONVERT(VARCHAR,t.hour)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DailyRollingAveg', 
  eval_string = 'dbo.FNARDailyRollingAveg(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg5 = 'CONVERT(VARCHAR,t.formula_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'arg1',
  arg8 = 'arg2',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DailyRollingAveg'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MTMPNL') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MTMPNL', 
  'dbo.FNARMTMPNL(CAST(arg1 AS INT),arg2)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MTMPNL', 
  eval_string = 'dbo.FNARMTMPNL(CAST(arg1 AS INT),arg2)',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MTMPNL'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MTMSettlement') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MTMSettlement', 
  'dbo.FNARMTMSettlement(CAST(arg1 AS INT),arg2)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MTMSettlement', 
  eval_string = 'dbo.FNARMTMSettlement(CAST(arg1 AS INT),arg2)',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MTMSettlement'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealType') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealType', 
  'dbo.FNARDealType(CAST(arg1 AS INT),CAST(arg2 AS INT),CAST(NULLIF(arg3,''NULL'') AS INT),CAST(NULLIF(arg4,''NULL'') AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealType', 
  eval_string = 'dbo.FNARDealType(CAST(arg1 AS INT),CAST(arg2 AS INT),CAST(NULLIF(arg3,''NULL'') AS INT),CAST(NULLIF(arg4,''NULL'') AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg3 = 'arg1',
  arg4 = 'arg2',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealType'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'OptionsPremium') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'OptionsPremium', 
  NULL,
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'OptionsPremium', 
  eval_string = NULL,
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'OptionsPremium'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealLeg') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealLeg', 
  'dbo.FNARDealLeg(cast(arg1 AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealLeg', 
  eval_string = 'dbo.FNARDealLeg(cast(arg1 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealLeg'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ExPostVolume') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ExPostVolume', 
  'dbo.FNARExPostVolume(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT))',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ExPostVolume', 
  eval_string = 'dbo.FNARExPostVolume(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR,t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.hour)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ExPostVolume'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ExAnteVolume') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ExAnteVolume', 
  'dbo.FNARExAnteVolume(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT))',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ExAnteVolume', 
  eval_string = 'dbo.FNARExAnteVolume(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR,t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.hour)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ExAnteVolume'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ExPostPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ExPostPrice', 
  'dbo.FNARExPostPrice(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT),CAST(arg7 AS INT))',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ExPostPrice', 
  eval_string = 'dbo.FNARExPostPrice(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT),CAST(arg7 AS INT))',
  arg1 = 'CONVERT(VARCHAR,t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.hour)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ExPostPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ExAntePrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ExAntePrice', 
  'dbo.FNARExAntePrice(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ExAntePrice', 
  eval_string = 'dbo.FNARExAntePrice(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
  arg1 = 'CONVERT(VARCHAR,t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.hour)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ExAntePrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'BilateralVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'BilateralVol', 
  'dbo.FNARBilateralVolume(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'BilateralVol', 
  eval_string = 'dbo.FNARBilateralVolume(CAST(arg1 AS INT),arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
  arg1 = 'CONVERT(VARCHAR,t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.hour)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'BilateralVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'WeekDay') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'WeekDay', 
  'dbo.FNARWeekDay(arg1)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'WeekDay', 
  eval_string = 'dbo.FNARWeekDay(arg1)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'WeekDay'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IsHoliday') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IsHoliday', 
  'dbo.FNARIsHoliday(cast(arg1 as int),arg2)',
  'CONVERT(VARCHAR,t.contract_id)',	
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IsHoliday', 
  eval_string = 'dbo.FNARIsHoliday(cast(arg1 as int),arg2)',
  arg1 = 'CONVERT(VARCHAR,t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IsHoliday'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CounterpartyRating') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CounterpartyRating', 
  'dbo.FNARCounterpartyRating(cast(arg1 as int))',
  'CONVERT(VARCHAR,t.counterparty_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CounterpartyRating', 
  eval_string = 'dbo.FNARCounterpartyRating(cast(arg1 as int))',
  arg1 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CounterpartyRating'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CounterpartyMTM') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CounterpartyMTM', 
  'dbo.FNARCounterpartyMTM(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CounterpartyMTM', 
  eval_string = 'dbo.FNARCounterpartyMTM(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'arg1',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CounterpartyMTM'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CounterpartyNetPwrPurchas') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CounterpartyNetPwrPurchas', 
  NULL,
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CounterpartyNetPwrPurchas', 
  eval_string = NULL,
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CounterpartyNetPwrPurchas'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'LoadVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'LoadVolm', 
  'dbo.FNARLoadVolm(arg1,CAST(arg2 AS INT))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'LoadVolm', 
  eval_string = 'dbo.FNARLoadVolm(arg1,CAST(arg2 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'arg1',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'LoadVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageHourlyPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageHourlyPrice', 
  'dbo.FNARAverageHourlyPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id_avg_curve'')',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageHourlyPrice', 
  eval_string = 'dbo.FNARAverageHourlyPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id_avg_curve'')',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg5 = 'arg1',
  arg6 = 'arg2',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageHourlyPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ImbalanceVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ImbalanceVol', 
  'dbo.FNARImbalanceVol(CAST(arg1 AS INT),CAST(arg2 AS INT),arg3,CAST(arg4 AS INT),CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,sdd.location_id)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ImbalanceVol', 
  eval_string = 'dbo.FNARImbalanceVol(CAST(arg1 AS INT),CAST(arg2 AS INT),arg3,CAST(arg4 AS INT),CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR,sdd.location_id)',
  arg5 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ImbalanceVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageDailyPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageDailyPrice', 
  'dbo.FNARAverageDailyPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id) ',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1 ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageDailyPrice', 
  eval_string = 'dbo.FNARAverageDailyPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id) ',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'arg1 ',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageDailyPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'LocationVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'LocationVol', 
  'dbo.FNARLocationVol(CAST(arg1 AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id) ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'LocationVol', 
  eval_string =  'dbo.FNARLocationVol(CAST(arg1 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id) ',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'LocationVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ImbalanceTotalVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ImbalanceTotalVol', 
  'dbo.FNARImbalanceTotalVol(CAST(arg1 AS INT),arg2)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ImbalanceTotalVol', 
  eval_string = 'dbo.FNARImbalanceTotalVol(CAST(arg1 AS INT),arg2)',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ImbalanceTotalVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DaysInMnth') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DaysInMnth', 
  'dbo.FNARDaysInMnth(arg1)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DaysInMnth', 
  eval_string = 'dbo.FNARDaysInMnth(arg1)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DaysInMnth'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ContractualOffPeakVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ContractualOffPeakVolm', 
  'dbo.FNARContractualOnPeakVolm(arg1,CAST(arg2 AS VARCHAR),CAST(arg3 AS VARCHAR))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ContractualOffPeakVolm', 
  eval_string = 'dbo.FNARContractualOnPeakVolm(arg1,CAST(arg2 AS VARCHAR),CAST(arg3 AS VARCHAR))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ContractualOffPeakVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ContractualOnPeakVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ContractualOnPeakVolm', 
  'dbo.FNARContractualOffPeakVolm(arg1,CAST(arg2 AS VARCHAR),CAST(arg3 AS VARCHAR))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ContractualOnPeakVolm', 
  eval_string = 'dbo.FNARContractualOffPeakVolm(arg1,CAST(arg2 AS VARCHAR),CAST(arg3 AS VARCHAR))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ContractualOnPeakVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DutchTOU') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DutchTOU', 
  'dbo.FNARDutchTOU(arg1,arg2,arg3)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DutchTOU', 
  eval_string = 'dbo.FNARDutchTOU(arg1,arg2,arg3)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DutchTOU'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealTotalVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealTotalVolm', 
  'dbo.FNARDealTotalVolm(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealTotalVolm', 
  eval_string = 'dbo.FNARDealTotalVolm(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg5 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg6 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealTotalVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealFixPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealFixPrice', 
  'dbo.FNARDealFixPrice(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealFixPrice', 
  eval_string = 'dbo.FNARDealFixPrice(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg5 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg6 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealFixPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MnPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MnPrice', 
  'dbo.FNARMnPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MnPrice', 
  eval_string = 'dbo.FNARMnPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'arg1',
  arg5 = 'arg2',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MnPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MxPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MxPrice', 
  'dbo.FNARMxPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MxPrice', 
  eval_string = 'dbo.FNARMxPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'arg1',
  arg5 = 'arg2',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MxPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'SettlementDate') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'SettlementDate', 
  'dbo.FNARSettlementDate(arg1,arg2,arg3)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'arg1',
  'arg2 ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'SettlementDate', 
  eval_string = 'dbo.FNARSettlementDate(arg1,arg2,arg3)',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'arg1',
  arg3 = 'arg2 ',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'SettlementDate'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'BookMap') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'BookMap', 
  'dbo.FNARBookMap(CAST(arg1 AS INT),CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'arg1',
  'CONVERT(VARCHAR(30),t.contract_id)   ',
  'CONVERT(VARCHAR(30),t.counterparty_id) ',
  'CONVERT(VARCHAR(30),t.calc_aggregation) ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'BookMap', 
  eval_string = 'dbo.FNARBookMap(CAST(arg1 AS INT),CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg2 = 'arg1',
  arg3 = 'CONVERT(VARCHAR(30),t.contract_id)   ',
  arg4 = 'CONVERT(VARCHAR(30),t.counterparty_id) ',
  arg5 = 'CONVERT(VARCHAR(30),t.calc_aggregation) ',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'BookMap'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ActualVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ActualVol', 
  NULL,
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ActualVol', 
  eval_string = NULL,
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ActualVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ActualTotalVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ActualTotalVol', 
  'dbo.FNARActualTotalVol(CAST(arg1 AS INT),arg2)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ActualTotalVol', 
  eval_string = 'dbo.FNARActualTotalVol(CAST(arg1 AS INT),arg2)',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ActualTotalVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CurveY') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CurveY', 
  'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARECCurveSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),wif.curve_shift_val  ,''@curve_shift_per'') ELSE dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),0,0,0,wif.curve_shift_val  ,wif.curve_shift_per) END',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CASE WHEN ''@calc_type''=''s'' THEN CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR) ELSE arg1 END',
  'arg2',
  'CONVERT(VARCHAR,t.curve_source_value_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CurveY', 
  eval_string = 'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARECCurveSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),wif.curve_shift_val  ,''@curve_shift_per'') ELSE dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),0,0,0,wif.curve_shift_val  ,wif.curve_shift_per) END',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CASE WHEN ''@calc_type''=''s'' THEN CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR) ELSE arg1 END',
  arg4 = 'arg2',
  arg5 = 'CONVERT(VARCHAR,t.curve_source_value_id)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CurveY'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CurveD') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CurveD', 
  'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARECCurveSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),wif.curve_shift_val  ,@curve_shift_per) ELSE dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),0,0,0,wif.curve_shift_val  ,wif.curve_shift_per) END',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CASE WHEN ''@calc_type''=''s'' THEN CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR) ELSE arg1 END',
  'arg2',
  'CONVERT(VARCHAR,t.curve_source_value_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CurveD', 
  eval_string = 'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARECCurveSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),wif.curve_shift_val  ,@curve_shift_per) ELSE dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),0,0,0,wif.curve_shift_val  ,wif.curve_shift_per) END',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CASE WHEN ''@calc_type''=''s'' THEN CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR) ELSE arg1 END',
  arg4 = 'arg2',
  arg5 = 'CONVERT(VARCHAR,t.curve_source_value_id)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CurveD'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CurveH') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CurveH', 
  'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARECCurveSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),@curve_shift_val  ,@curve_shift_per) ELSE dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),isnull(cast(arg6 as int),0),0,0,@curve_shift_val  ,@curve_shift_per) END',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1',
  'arg2',
  'CONVERT(VARCHAR,t.curve_source_value_id)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CurveH', 
  eval_string = 'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARECCurveSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),@curve_shift_val  ,@curve_shift_per) ELSE dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),isnull(cast(arg6 as int),0),0,0,@curve_shift_val  ,@curve_shift_per) END',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'arg1',
  arg4 = 'arg2',
  arg5 = 'CONVERT(VARCHAR,t.curve_source_value_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CurveH'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Curve15') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Curve15', 
  'dbo.FNARCurve15(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),cast(arg6 as int),cast(arg7 as int),@curve_shift_val  ,@curve_shift_per)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1',
  'arg2',
  'CONVERT(VARCHAR,t.curve_source_value_id)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR,t.mins)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Curve15', 
  eval_string = 'dbo.FNARCurve15(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),cast(arg6 as int),cast(arg7 as int),@curve_shift_val  ,@curve_shift_per)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'arg1',
  arg4 = 'arg2',
  arg5 = 'CONVERT(VARCHAR,t.curve_source_value_id)',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'CONVERT(VARCHAR,t.mins)',
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Curve15'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Curve30') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Curve30', 
  'dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),cast(arg6 as int),cast(arg7 as int),f.is_dst,wif.curve_shift_val  ,wif.curve_shift_per)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CASE WHEN ''@calc_type''=''s'' THEN ''CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR)'' ELSE ''arg1'' END',
  'arg2',
  'arg2',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR,t.mins)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Curve30', 
  eval_string = 'dbo.FNARECCurve(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),cast(arg6 as int),cast(arg7 as int),f.is_dst,wif.curve_shift_val  ,wif.curve_shift_per)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CASE WHEN ''@calc_type''=''s'' THEN ''CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR)'' ELSE ''arg1'' END',
  arg4 = 'arg2',
  arg5 = 'arg2',
  arg6 = 'CONVERT(VARCHAR,t.hour)',
  arg7 = 'CONVERT(VARCHAR,t.mins)',
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Curve30'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Curve') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Curve', 
  'dbo.FNARECCurve(arg1,arg2,CAST(arg3 AS INT), CAST(NULLIF(arg4,''NULL'') AS FLOAT),0,0,0,wif.curve_shift_val  ,wif.curve_shift_per)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CASE WHEN ''@calc_type''=''s'' THEN ''CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR)'' ELSE ''arg1'' END',
  'arg2',
  'CONVERT(VARCHAR,t.curve_source_value_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Curve', 
  eval_string = 'dbo.FNARECCurve(arg1,arg2,CAST(arg3 AS INT), CAST(NULLIF(arg4,''NULL'') AS FLOAT),0,0,0,wif.curve_shift_val  ,wif.curve_shift_per)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CASE WHEN ''@calc_type''=''s'' THEN ''CAST(ISNULL(spcd_s.settlement_curve_id,f.arg1) AS VARCHAR)'' ELSE ''arg1'' END',
  arg4 = 'arg2',
  arg5 = 'CONVERT(VARCHAR,t.curve_source_value_id)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Curve'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'PriorCurve') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'PriorCurve', 
  'dbo.FNARPriorCurve(arg1 ,arg2 ,cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg9 as int),cast(arg10 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR,t.curve_source_value_id)',
  'arg1',
  'arg2',
  'arg3',
  'arg4',
  'arg5',
  'arg6',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'PriorCurve', 
  eval_string = 'dbo.FNARPriorCurve(arg1 ,arg2 ,cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),cast(arg9 as int),cast(arg10 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.hour)',
  arg4 = 'CONVERT(VARCHAR,t.curve_source_value_id)',
  arg5 = 'arg1',
  arg6 = 'arg2',
  arg7 = 'arg3',
  arg8 = 'arg4',
  arg9 = 'arg5',
  arg10 = 'arg6',
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'PriorCurve'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'RelativePeriod') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'RelativePeriod', 
  'dbo.FNARRelativePeriod(arg1,arg2,cast(arg3 as int),cast(arg4 as int),cast(arg5 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120) ',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR,t.curve_source_value_id)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'RelativePeriod', 
  eval_string = 'dbo.FNARRelativePeriod(arg1,arg2,cast(arg3 as int),cast(arg4 as int),cast(arg5 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120) ',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.curve_source_value_id)',
  arg4 = 'arg1',
  arg5 = 'arg2',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'RelativePeriod'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'PeakHours') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'PeakHours', 
  'dbo.FNARPeakHours(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120) ',
  'CONVERT(VARCHAR(10),t.granularity)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'PeakHours', 
  eval_string = 'dbo.FNARPeakHours(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120) ',
  arg2 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg3 = 'arg1',
  arg4 = 'arg2',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'PeakHours'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'UDFCurveValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'UDFCurveValue', 
  'dbo.FNARUDFCurveValue(cast(arg1  as INT) ,arg2,arg3,cast(arg4  as INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'UDFCurveValue', 
  eval_string = 'dbo.FNARUDFCurveValue(cast(arg1  as INT) ,arg2,arg3,cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'arg1',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'UDFCurveValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealSettlement') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealSettlement', 
  'CASE WHEN deal_type=CAST(arg6 AS INT) THEN deal_settlement_amount ELSE 0 END',
  'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  '''@estimate_calculation''',
  'CONVERT(VARCHAR,t.[source_deal_header_id])',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealSettlement', 
  eval_string = 'CASE WHEN deal_type=CAST(arg6 AS INT) THEN deal_settlement_amount ELSE 0 END',
  arg1 = 'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = '''@estimate_calculation''',
  arg5 = 'CONVERT(VARCHAR,t.[source_deal_header_id])',
  arg6 = 'arg1',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealSettlement'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealFees') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealFees', 
  'dbo.FNARDealFees(cast(arg1  as INT) ,arg2,arg3,cast(arg4  as INT),cast(arg5  as INT),cast(arg6  as INT),''@cpt_model_type'',cast(arg7  as INT))',
  'CONVERT(VARCHAR(10),ISNULL(sdd.source_deal_detail_id,t.source_deal_header_id))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealFees', 
  eval_string = 'dbo.FNARDealFees(cast(arg1  as INT) ,arg2,arg3,cast(arg4  as INT),cast(arg5  as INT),cast(arg6  as INT),''@cpt_model_type'',cast(arg7  as INT))',
  arg1 = 'CONVERT(VARCHAR(10),ISNULL(sdd.source_deal_detail_id,t.source_deal_header_id))',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg5 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg6 = 'CONVERT(VARCHAR,t.contract_id)',
  arg7 = 'arg1',
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealFees'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'StaticCurve') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'StaticCurve', 
  'dbo.FNARStaticCurve(arg1,arg2,NULL,cast(arg4 as INT))',
  'CONVERT(VARCHAR(10),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.as_of_date,120)',
  NULL,
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'StaticCurve', 
  eval_string = 'dbo.FNARStaticCurve(arg1,arg2,NULL,cast(arg4 as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(10),t.as_of_date,120)',
  arg3 = NULL,
  arg4 = 'arg1',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'StaticCurve'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'FinancialVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'FinancialVol', 
  'fin_volume',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.[Hour])',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'FinancialVol', 
  eval_string = 'dbo.FNARFinancialVol(cast(arg1  as INT),cast(arg2 as INT),arg3,cast(arg4 as INT))',
  arg1 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg2 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR,t.[Hour])',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'FinancialVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'PhysicalVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'PhysicalVol', 
  'dbo.FNARPhysicalVol(cast(arg1 as INT),cast(arg2 as INT),arg3,arg4)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.[Hour])',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'PhysicalVol', 
  eval_string = 'dbo.FNARPhysicalVol(cast(arg1  as INT),cast(arg2 as INT),arg3,arg4)',
  arg1 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg2 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR,t.[Hour])',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'PhysicalVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ShapedVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ShapedVol', 
  'dbo.FNARShapedVol(cast(arg1  as INT),cast(arg2 as INT),cast(arg3 as INT),arg4,cast(arg5 as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.[Hour])',
  'CONVERT(VARCHAR(10),t.granularity)',
  'CONVERT(VARCHAR(10),t.is_dst)',
  'CONVERT(VARCHAR(10),t.mins)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ShapedVol', 
  eval_string = 'dbo.FNARShapedVol(cast(arg1  as INT),cast(arg2 as INT),cast(arg3 as INT),arg4,cast(arg5 as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg3 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg4 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg5 = 'CONVERT(VARCHAR,t.[Hour])',
  arg6 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg7 = 'CONVERT(VARCHAR(10),t.is_dst)',
  arg8 = 'CONVERT(VARCHAR(10),t.mins)',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ShapedVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ABS') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ABS', 
  'dbo.FNARABS(CAST (arg1 AS FLOAT))',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ABS', 
  eval_string = 'dbo.FNARABS(CAST (arg1 AS FLOAT))',
  arg1 = 'arg1',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ABS'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealSetPrice')
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealSetPrice',
  'dbo.FNARDealSetPrice(cast(arg1  as INT),arg2,arg3,cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'CONVERT(VARCHAR(10),ISNULL(t.curve_tou,18900))',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealSetPrice',
  eval_string = 'dbo.FNARDealSetPrice(cast(arg1  as INT),arg2,arg3,cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg5 = 'CONVERT(VARCHAR(10),ISNULL(t.curve_tou,18900))',
  arg6 = 'arg1',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealSetPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealMultiplier') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealMultiplier', 
  'dbo.FNARDealMultiplier(cast(arg1  as INT),cast(arg2 as INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealMultiplier', 
  eval_string = 'dbo.FNARDealMultiplier(cast(arg1  as INT),cast(arg2 as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealMultiplier'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'SettlementVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'SettlementVolm', 
  'deal_settlement_volume',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'SettlementVolm', 
  eval_string = 'deal_settlement_volume',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg4 = 'CONVERT(VARCHAR,t.contract_id)',
  arg5 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg6 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg7 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'SettlementVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CptMeterVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CptMeterVolm', 
  'dbo.FNARCptMeterVolm(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(NULLIF(arg6,''NULL'') AS INT))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.counterparty_id,120)',
  'CONVERT(VARCHAR(20),t.commodity_id,120)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CptMeterVolm', 
  eval_string = 'dbo.FNARCptMeterVolm(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(NULLIF(arg6,''NULL'') AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.counterparty_id,120)',
  arg4 = 'CONVERT(VARCHAR(20),t.commodity_id,120)',
  arg5 = 'arg1',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CptMeterVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealFVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealFVolm', 
  'dbo.FNARDealFVolm(cast(arg1  as INT),cast(arg2 as INT),arg3,arg4,CAST(arg5 AS INT),CAST(arg6 AS INT))',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealFVolm', 
  eval_string = 'dbo.FNARDealFVolm(cast(arg1  as INT),cast(arg2 as INT),arg3,arg4,CAST(arg5 AS INT),CAST(arg6 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg2 = 'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg5 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg6 = 'arg1',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealFVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IndexAllocation') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IndexAllocation', 
  'dbo.FNARIndexAllocation(cast(arg1  as INT),cast(arg2 as INT),arg3,CAST(arg4 AS INT))',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IndexAllocation', 
  eval_string = 'dbo.FNARIndexAllocation(cast(arg1  as INT),cast(arg2 as INT),arg3,CAST(arg4 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg2 = 'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'arg1',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IndexAllocation'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealFloatPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealFloatPrice', 
  'dbo.FNARDealFloatPrice(cast(arg1  as INT),arg2,arg3,cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT),cast(arg7 as INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'CONVERT(VARCHAR(10),ISNULL(t.curve_tou,18900))',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealFloatPrice', 
  eval_string = 'dbo.FNARDealFloatPrice(cast(arg1  as INT),arg2,arg3,cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT),cast(arg7 as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg5 = 'CONVERT(VARCHAR(10),ISNULL(t.curve_tou,18900))',
  arg6 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg7 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg8 = 'arg1',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealFloatPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'BuySell') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'BuySell', 
  'dbo.FNARBuySell(cast(arg1  as INT),cast(arg2  as INT))',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'BuySell', 
  eval_string = 'dbo.FNARBuySell(cast(arg1  as INT),cast(arg2  as INT))',
  arg1 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg2 = 'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'BuySell'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'LocationGrid') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'LocationGrid', 
  'dbo.FNARLocationGrid(cast(arg1  as INT),cast(arg2  as INT),cast(arg3  as INT))',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'LocationGrid', 
  eval_string = 'dbo.FNARLocationGrid(cast(arg1  as INT),cast(arg2  as INT),cast(arg3  as INT))',
  arg1 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg2 = 'CONVERT(VARCHAR(10),sdd.source_deal_detail_id)',
  arg3 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'LocationGrid'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ContractPriceValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ContractPriceValue', 
  'dbo.FNARContractPriceValue(arg1,arg2,cast(arg3 as INT),CAST(NULLIF(arg4,''NULL'') AS INT),CAST(NULLIF(arg5,''NULL'') AS INT),CAST(NULLIF(arg6,''NULL'') AS INT))',
  'CONVERT(VARCHAR(10),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.as_of_date,120)',
  'CONVERT(VARCHAR,t.contract_id)',
  'arg1',
  'arg2',
  'arg3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ContractPriceValue', 
  eval_string = 'dbo.FNARContractPriceValue(arg1,arg2,cast(arg3 as INT),CAST(NULLIF(arg4,''NULL'') AS INT),CAST(NULLIF(arg5,''NULL'') AS INT),CAST(NULLIF(arg6,''NULL'') AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(10),t.as_of_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'arg1',
  arg5 = 'arg2',
  arg6 = 'arg3',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ContractPriceValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AllocVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AllocVolm', 
  'dbo.FNARAllocVolm(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT),CAST(arg7 AS INT),CAST(arg8 AS INT))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.commodity_id)',
  'CONVERT(VARCHAR,ISNULL(t.curve_tou,18900))',
  'CONVERT(VARCHAR,t.calc_aggregation)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AllocVolm', 
  eval_string = 'dbo.FNARAllocVolm(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT),CAST(arg7 AS INT),CAST(arg8 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg4 = 'CONVERT(VARCHAR,t.contract_id)',
  arg5 = 'CONVERT(VARCHAR,t.commodity_id)',
  arg6 = 'CONVERT(VARCHAR,ISNULL(t.curve_tou,18900))',
  arg7 = 'CONVERT(VARCHAR,t.calc_aggregation)',
  arg8 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AllocVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'YearlyContractVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'YearlyContractVolm', 
  'dbo.FNARYearlyContractVolm(arg1 ,arg2,cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  'CONVERT(VARCHAR(10),t.calc_aggregation)',
  'CONVERT(VARCHAR(10),ISNULL(t.curve_tou,18900))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'YearlyContractVolm', 
  eval_string = 'dbo.FNARYearlyContractVolm(arg1 ,arg2,cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg5 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg6 = 'CONVERT(VARCHAR(10),t.calc_aggregation)',
  arg7 = 'CONVERT(VARCHAR(10),ISNULL(t.curve_tou,18900))',
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'YearlyContractVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'YearlySetVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'YearlySetVolm', 
  'dbo.FNARYearlySetVolm(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT),CAST(arg7 AS INT))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.source_deal_detail_id)',
  'CONVERT(VARCHAR,t.source_deal_header_id)',
  'CONVERT(VARCHAR,t.calc_aggregation)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'YearlySetVolm', 
  eval_string = 'dbo.FNARYearlySetVolm(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT),CAST(arg7 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg4 = 'CONVERT(VARCHAR,t.contract_id)',
  arg5 = 'CONVERT(VARCHAR,t.source_deal_detail_id)',
  arg6 = 'CONVERT(VARCHAR,t.source_deal_header_id)',
  arg7 = 'CONVERT(VARCHAR,t.calc_aggregation)',
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'YearlySetVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageHourlyMxPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageHourlyMxPrice', 
  'dbo.FNARAverageHourlyMxPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id'')',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageHourlyMxPrice', 
  eval_string = 'dbo.FNARAverageHourlyMxPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id'')',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg5 = 'arg1',
  arg6 = 'arg2',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageHourlyMxPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageHourlyMnPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageHourlyMnPrice', 
  'dbo.FNARAverageHourlyMnPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id'')',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageHourlyMnPrice', 
  eval_string = 'dbo.FNARAverageHourlyMnPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id'')',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg5 = 'arg1',
  arg6 = 'arg2',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageHourlyMnPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IsYrEnd') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IsYrEnd', 
  'dbo.FNARIsYrEnd(arg1)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IsYrEnd', 
  eval_string = 'dbo.FNARIsYrEnd(arg1)',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IsYrEnd'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'EOHHours') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'EOHHours', 
  'dbo.FNAREOHHours(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.commodity_id,120)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'EOHHours', 
  eval_string = 'dbo.FNAREOHHours(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.commodity_id,120)',
  arg3 = 'arg1',
  arg4 = 'arg2',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'EOHHours'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'PrevEvents') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'PrevEvents', 
  'dbo.FNARPrevEvents(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT),CAST(arg7 AS INT))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.commodity_id,120)',
  'arg1',
  'arg2',
  'arg3',
  'arg4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'PrevEvents', 
  eval_string = 'dbo.FNARPrevEvents(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT),CAST(arg7 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.commodity_id,120)',
  arg4 = 'arg1',
  arg5 = 'arg2',
  arg6 = 'arg3',
  arg7 = 'arg4',
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'PrevEvents'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CptCollateral') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CptCollateral', 
  '[dbo].[FNARCptCollateral](arg1,cast(arg2  as INT)) ',
  'CONVERT(VARCHAR(20),t.as_of_date,120) ',
  'CONVERT(VARCHAR,t.counterparty_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CptCollateral', 
  eval_string = '[dbo].[FNARCptCollateral](arg1,cast(arg2  as INT)) ',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120) ',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CptCollateral'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DMTMChange') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DMTMChange', 
  '[dbo].[FNARDMTMChange](arg1,cast(arg2 as INT),cast(arg3 as INT),cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT)) ',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'CONVERT(VARCHAR,t.calc_aggregation)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DMTMChange', 
  eval_string = '[dbo].[FNARDMTMChange](arg1,cast(arg2 as INT),cast(arg3 as INT),cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT)) ',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = 'CONVERT(VARCHAR,t.contract_id)',
  arg4 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg5 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg6 = 'CONVERT(VARCHAR,t.calc_aggregation)',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DMTMChange'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'RateScheduleFee') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'RateScheduleFee', 
  '[dbo].[FNARRateScheduleFee](arg1,cast(arg2  as INT),cast(arg3  as INT))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'RateScheduleFee', 
  eval_string = '[dbo].[FNARRateScheduleFee](arg1,cast(arg2  as INT),cast(arg3  as INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg3 = 'arg1',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'RateScheduleFee'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'RelativeCurveD') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'RelativeCurveD', 
  '[dbo].[FNARRelativeDailyCurve](arg1,arg2,cast(arg3  as INT),cast(arg4  as INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'RelativeCurveD', 
  eval_string = '[dbo].[FNARRelativeDailyCurve](arg1,arg2,cast(arg3  as INT),cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'arg1',
  arg4 = 'arg2',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'RelativeCurveD'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'TotalVolume') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'TotalVolume', 
  'dbo.FNARTotalVolm(arg1,CAST(NULLIF(arg2,''NULL'') AS INT),CAST(NULLIF(arg3,''NULL'') AS INT),CAST(NULLIF(arg4,''NULL'') AS INT),CAST(NULLIF(arg5,''NULL'') AS INT),CAST(NULLIF(arg6,''NULL'') AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'arg1',
  'arg2',
  'arg3',
  'arg4',
  'arg5',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'TotalVolume', 
  eval_string = 'dbo.FNARTotalVolm(arg1,CAST(NULLIF(arg2,''NULL'') AS INT),CAST(NULLIF(arg3,''NULL'') AS INT),CAST(NULLIF(arg4,''NULL'') AS INT),CAST(NULLIF(arg5,''NULL'') AS INT),CAST(NULLIF(arg6,''NULL'') AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'arg1',
  arg3 = 'arg2',
  arg4 = 'arg3',
  arg5 = 'arg4',
  arg6 = 'arg5',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'TotalVolume'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'VATPercent') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'VATPercent', 
  'dbo.FNARVATPercent(arg1, CAST(arg2 AS INT))',
  'CONVERT(VARCHAR(20), t.as_of_date, 120)',
  'CAST(t.counterparty_id AS VARCHAR(20))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'VATPercent', 
  eval_string = 'dbo.FNARVATPercent(arg1, CAST(arg2 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20), t.as_of_date, 120)',
  arg2 = 'CAST(t.counterparty_id AS VARCHAR(20))',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'VATPercent'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'LocationRegionID') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'LocationRegionID', 
  'dbo.FNARLocationRegionID(arg1)',
  'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'LocationRegionID', 
  eval_string = 'dbo.FNARLocationRegionID(arg1)',
  arg1 = 'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'LocationRegionID'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CounterpartyRegionID') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CounterpartyRegionID', 
  'dbo.FNARCounterpartyRegionID(arg1)',
  'CONVERT(VARCHAR(15), t.source_deal_header_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CounterpartyRegionID', 
  eval_string = 'dbo.FNARCounterpartyRegionID(arg1)',
  arg1 = 'CONVERT(VARCHAR(15), t.source_deal_header_id)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CounterpartyRegionID'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageMnthlyPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageMnthlyPrice', 
  'dbo.FNARAverageMnthlyPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(CAST(arg5 AS FLOAT) AS INT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id_avg_curve'',CAST(arg8 AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  NULL,
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'arg1',
  NULL,
  NULL,
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageMnthlyPrice', 
  eval_string = 'dbo.FNARAverageMnthlyPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(CAST(arg5 AS FLOAT) AS INT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id_avg_curve'',CAST(arg8 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = NULL,
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg5 = 'arg1',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = 'arg2',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageMnthlyPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageYrlyPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageYrlyPrice', 
  'dbo.FNARAverageYrlyPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS FLOAT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id_avg_curve'',CAST(arg8 AS INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  'arg1',
  NULL,
  NULL,
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageYrlyPrice', 
  eval_string = 'dbo.FNARAverageYrlyPrice(CAST(arg1 AS INT),arg2,arg3,CAST(arg4 AS INT),CAST(arg5 AS FLOAT),CAST(NULLIF(arg6,''NULL'') AS INT),''@process_id_avg_curve'',CAST(arg8 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
  arg5 = 'arg1',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = 'arg2',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageYrlyPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MeterVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MeterVol', 
  'dbo.FNARMeterVol(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),CAST(NULLIF(arg6,''NULL'') AS INT),CAST(NULLIF(arg7,''NULL'') AS INT),cast(arg8 as int),CAST(NULLIF(arg9,''NULL'') AS INT),CAST(NULLIF(arg10,''NULL'') AS INT),CAST(NULLIF(arg11,''NULL'') AS INT))',
  'CONVERT(VARCHAR(20),prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR,t.mins)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'arg1',
  'arg2',
  'arg3',
  'CONVERT(VARCHAR(10),t.is_dst)',
  'arg4',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'CONVERT(VARCHAR(10),t.counterparty_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MeterVol', 
  eval_string = 'dbo.FNARMeterVol(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),CAST(NULLIF(arg6,''NULL'') AS INT),CAST(NULLIF(arg7,''NULL'') AS INT),cast(arg8 as int),CAST(NULLIF(arg9,''NULL'') AS INT),CAST(NULLIF(arg10,''NULL'') AS INT),CAST(NULLIF(arg11,''NULL'') AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),prod_date,120)',
  arg2 = 'CONVERT(VARCHAR,t.hour)',
  arg3 = 'CONVERT(VARCHAR,t.mins)',
  arg4 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg5 = 'arg1',
  arg6 = 'arg2',
  arg7 = 'arg3',
  arg8 = 'CONVERT(VARCHAR(10),t.is_dst)',
  arg9 = 'arg4',
  arg10 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg11 = 'CONVERT(VARCHAR(10),t.counterparty_id)',
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MeterVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'BookMapName') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'BookMapName', 
  'dbo.FNARBookMapName(arg1,CAST(arg2 AS INT))',
  'CONVERT(VARCHAR(15), t.source_deal_header_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'BookMapName', 
  eval_string = 'dbo.FNARBookMapName(arg1,CAST(arg2 AS INT))',
  arg1 = 'CONVERT(VARCHAR(15), t.source_deal_header_id)',
  arg2 = 'arg1',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'BookMapName'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DaysInYr') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DaysInYr', 
  'dbo.FNARDaysInYr(arg1)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DaysInYr', 
  eval_string = 'dbo.FNARDaysInYr(arg1)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DaysInYr'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'GetID') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'GetID', 
  'dbo.FNARGetID(arg1,arg2,arg3)WHEN ''UDFDetailValue'' THEN dbo.FNARUDFDetailValue(cast(arg1  as INT),arg2 ,arg3, cast(arg4  as INT))',
  'arg1',
  'arg2',
  'arg3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'GetID', 
  eval_string = 'dbo.FNARGetID(arg1,arg2,arg3)WHEN ''UDFDetailValue'' THEN dbo.FNARUDFDetailValue(cast(arg1  as INT),arg2 ,arg3, cast(arg4  as INT))',
  arg1 = 'arg1',
  arg2 = 'arg2',
  arg3 = 'arg3',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'GetID'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'UDFDetailValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'UDFDetailValue', 
  'dbo.FNARUDFDetailValue(cast(arg1  as INT),arg2 ,arg3, cast(arg4  as INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'UDFDetailValue', 
  eval_string = 'dbo.FNARUDFDetailValue(cast(arg1  as INT),arg2 ,arg3, cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg4 = 'arg1',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'UDFDetailValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageQVol') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageQVol', 
  'dbo.FNARAverageQVol(CAST(arg1  AS INT),CAST(arg2 AS INT),CAST(arg3 AS DATETIME),CAST(arg4 AS INT),CAST(arg5 AS INT))',
  'arg1',
  'arg2',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR(10),t.is_dst)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageQVol', 
  eval_string = 'dbo.FNARAverageQVol(CAST(arg1  AS INT),CAST(arg2 AS INT),CAST(arg3 AS DATETIME),CAST(arg4 AS INT),CAST(arg5 AS INT))',
  arg1 = 'arg1',
  arg2 = 'arg2',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR,t.hour)',
  arg5 = 'CONVERT(VARCHAR(10),t.is_dst)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageQVol'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DynamicCurve') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DynamicCurve', 
  'dbo.FNARDynamicCurve(arg1,arg2,cast(arg3 as INT),NULL)',
  'CONVERT(VARCHAR(10),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.as_of_date,120)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DynamicCurve', 
  eval_string = 'dbo.FNARDynamicCurve(arg1,arg2,cast(arg3 as INT),NULL)',
  arg1 = 'CONVERT(VARCHAR(10),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(10),t.as_of_date,120)',
  arg3 = 'arg1',
  arg4 = 'arg2',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DynamicCurve'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Input') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Input', 
  'dbo.FNAEMSInput(cast(arg1  as INT),arg2,cast(arg3  as INT),cast(arg4  as INT),cast(arg5  as INT),cast(arg6  as INT),cast(arg7  as INT),cast(arg8  as INT),cast(arg9  as INT),cast(arg10  as INT),cast(arg11  as INT),cast(arg12  as INT),cast(arg13  as INT))',
  'CONVERT(VARCHAR,t.generator_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.input_char1)',
  'CONVERT(VARCHAR(10),t.input_char2)',
  'CONVERT(VARCHAR(10),t.input_char3)',
  'CONVERT(VARCHAR(10),t.input_char4)',
  'CONVERT(VARCHAR(10),t.input_char5)',
  'CONVERT(VARCHAR(10),t.input_char6)',
  'CONVERT(VARCHAR(10),t.input_char7)',
  'CONVERT(VARCHAR(10),t.input_char8)',
  'CONVERT(VARCHAR(10),t.input_char9)',
  'CONVERT(VARCHAR(10),t.input_char10)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Input', 
  eval_string = 'dbo.FNAEMSInput(cast(arg1  as INT),arg2,cast(arg3  as INT),cast(arg4  as INT),cast(arg5  as INT),cast(arg6  as INT),cast(arg7  as INT),cast(arg8  as INT),cast(arg9  as INT),cast(arg10  as INT),cast(arg11  as INT),cast(arg12  as INT),cast(arg13  as INT))',
  arg1 = 'CONVERT(VARCHAR,t.generator_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR(10),t.input_char1)',
  arg4 = 'CONVERT(VARCHAR(10),t.input_char2)',
  arg5 = 'CONVERT(VARCHAR(10),t.input_char3)',
  arg6 = 'CONVERT(VARCHAR(10),t.input_char4)',
  arg7 = 'CONVERT(VARCHAR(10),t.input_char5)',
  arg8 = 'CONVERT(VARCHAR(10),t.input_char6)',
  arg9 = 'CONVERT(VARCHAR(10),t.input_char7)',
  arg10 = 'CONVERT(VARCHAR(10),t.input_char8)',
  arg11 = 'CONVERT(VARCHAR(10),t.input_char9)',
  arg12 = 'CONVERT(VARCHAR(10),t.input_char10)',
  arg13 = 'arg1',
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Input'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'EMSConv') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'EMSConv', 
  'dbo.FNAEMSEMSConv(cast(arg1  as INT),CAST(arg2 AS INT),arg3,cast(arg4  as INT),cast(arg5  as INT),cast(arg6  as INT),cast(arg7  as INT),cast(arg8  as INT),cast(arg9  as INT),cast(arg10  as INT),cast(arg11  as INT),cast(arg12  as INT),cast(arg13  as INT),cast(arg14  as INT),cast(arg15  as INT),cast(arg16  as INT),cast(arg17  as INT),cast(arg18  as INT))',
  'CONVERT(VARCHAR,t.curve_id)',
  'CONVERT(VARCHAR,t.generator_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.input_char1)',
  'CONVERT(VARCHAR(10),t.input_char2)',
  'CONVERT(VARCHAR(10),t.input_char3)',
  'CONVERT(VARCHAR(10),t.input_char4)',
  'CONVERT(VARCHAR(10),t.input_char5)',
  'CONVERT(VARCHAR(10),t.input_char6)',
  'CONVERT(VARCHAR(10),t.input_char7)',
  'CONVERT(VARCHAR(10),t.input_char8)',
  'CONVERT(VARCHAR(10),t.input_char9)',
  'CONVERT(VARCHAR(10),t.input_char10)',
  'arg1',
  'arg2',
  'arg3',
  'arg4',
  'arg5'
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'EMSConv', 
  eval_string = 'dbo.FNAEMSEMSConv(cast(arg1  as INT),CAST(arg2 AS INT),arg3,cast(arg4  as INT),cast(arg5  as INT),cast(arg6  as INT),cast(arg7  as INT),cast(arg8  as INT),cast(arg9  as INT),cast(arg10  as INT),cast(arg11  as INT),cast(arg12  as INT),cast(arg13  as INT),cast(arg14  as INT),cast(arg15  as INT),cast(arg16  as INT),cast(arg17  as INT),cast(arg18  as INT))',
  arg1 = 'CONVERT(VARCHAR,t.curve_id)',
  arg2 = 'CONVERT(VARCHAR,t.generator_id)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),t.input_char1)',
  arg5 = 'CONVERT(VARCHAR(10),t.input_char2)',
  arg6 = 'CONVERT(VARCHAR(10),t.input_char3)',
  arg7 = 'CONVERT(VARCHAR(10),t.input_char4)',
  arg8 = 'CONVERT(VARCHAR(10),t.input_char5)',
  arg9 = 'CONVERT(VARCHAR(10),t.input_char6)',
  arg10 = 'CONVERT(VARCHAR(10),t.input_char7)',
  arg11 = 'CONVERT(VARCHAR(10),t.input_char8)',
  arg12 = 'CONVERT(VARCHAR(10),t.input_char9)',
  arg13 = 'CONVERT(VARCHAR(10),t.input_char10)',
  arg14 = 'arg1',
  arg15 = 'arg2',
  arg16 = 'arg3',
  arg17 = 'arg4',
  arg18 = 'arg5' 
 WHERE function_name = 'EMSConv'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'GetLogicalValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'GetLogicalValue', 
  'dbo.FNARGetLogicalValue(arg1,CAST(arg2 AS INT), CAST(arg3 AS INT), CAST(arg4 AS INT))',
  'arg1',
  'arg2',
  'CONVERT(VARCHAR(20),t.counterparty_id,120)',
  'CONVERT(VARCHAR,t.contract_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'GetLogicalValue', 
  eval_string = 'dbo.FNARGetLogicalValue(arg1,CAST(arg2 AS INT), CAST(arg3 AS INT), CAST(arg4 AS INT))',
  arg1 = 'arg1',
  arg2 = 'arg2',
  arg3 = 'CONVERT(VARCHAR(20),t.counterparty_id,120)',
  arg4 = 'CONVERT(VARCHAR,t.contract_id)',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'GetLogicalValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'NOXEmissionsValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'NOXEmissionsValue', 
  'dbo.FNAEMSNOXEmissionsValue(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  'CONVERT(VARCHAR,t.curve_id) ',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.generator_id) ',
  'CONVERT(VARCHAR,t.[Hour])',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'NOXEmissionsValue', 
  eval_string = 'dbo.FNAEMSNOXEmissionsValue(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR,t.curve_id) ',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.generator_id) ',
  arg4 = 'CONVERT(VARCHAR,t.[Hour])',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'NOXEmissionsValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CO2EmissionsValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CO2EmissionsValue', 
  'dbo.FNAEMSCO2EmissionsValue(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  'CONVERT(VARCHAR,t.curve_id) ',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.generator_id) ',
  'CONVERT(VARCHAR,t.[Hour])',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CO2EmissionsValue', 
  eval_string = 'dbo.FNAEMSCO2EmissionsValue(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR,t.curve_id) ',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.generator_id) ',
  arg4 = 'CONVERT(VARCHAR,t.[Hour])',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CO2EmissionsValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'SO2EmissionsValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'SO2EmissionsValue', 
  'dbo.FNAEMSSO2EmissionsValue(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  'CONVERT(VARCHAR,t.curve_id) ',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.generator_id) ',
  'CONVERT(VARCHAR,t.[Hour])',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'SO2EmissionsValue', 
  eval_string = 'dbo.FNAEMSSO2EmissionsValue(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR,t.curve_id) ',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.generator_id) ',
  arg4 = 'CONVERT(VARCHAR,t.[Hour])',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'SO2EmissionsValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'EDRHeatInput') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'EDRHeatInput', 
  'dbo.FNAEMSEDRHeatInput(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  'CONVERT(VARCHAR,t.curve_id)  ',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.generator_id)  ',
  'CONVERT(VARCHAR,t.[Hour])',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'EDRHeatInput', 
  eval_string = 'dbo.FNAEMSEDRHeatInput(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR,t.curve_id)  ',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.generator_id)  ',
  arg4 = 'CONVERT(VARCHAR,t.[Hour])',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'EDRHeatInput'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IsSingleStackBoiler') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IsSingleStackBoiler', 
  'dbo.FNAEMSIsSingleStackBoiler(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  'CONVERT(VARCHAR,t.curve_id)  ',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.generator_id)  ',
  'CONVERT(VARCHAR,t.[Hour])',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IsSingleStackBoiler', 
  eval_string = 'dbo.FNAEMSIsSingleStackBoiler(cast(arg1  as INT),arg2,cast(arg3 AS INT),cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR,t.curve_id)  ',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.generator_id)  ',
  arg4 = 'CONVERT(VARCHAR,t.[Hour])',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IsSingleStackBoiler'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'EDRValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'EDRValue', 
  NULL,
  'CONVERT(VARCHAR,t.curve_id)  ',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.generator_id)  ',
  'CONVERT(VARCHAR,t.[Hour])',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'EDRValue', 
  eval_string = NULL,
  arg1 = 'CONVERT(VARCHAR,t.curve_id)  ',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.generator_id)  ',
  arg4 = 'CONVERT(VARCHAR,t.[Hour])',
  arg5 = 'arg1',
  arg6 = 'arg2',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'EDRValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'SourceEmissionsValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'SourceEmissionsValue', 
  'dbo.FNAEMSSourceEmissionsValue(arg1,cast(arg2 as INT),cast(arg3 as INT),cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT))',
  'CONVERT(VARCHAR(10),t.prod_date,120) ',
  'CONVERT(VARCHAR,t.curve_id)',
  'arg1  ',
  'arg2',
  'arg3',
  'arg4',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'SourceEmissionsValue', 
  eval_string = 'dbo.FNAEMSSourceEmissionsValue(arg1,cast(arg2 as INT),cast(arg3 as INT),cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.prod_date,120) ',
  arg2 = 'CONVERT(VARCHAR,t.curve_id)',
  arg3 = 'arg1  ',
  arg4 = 'arg2',
  arg5 = 'arg3',
  arg6 = 'arg4',
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'SourceEmissionsValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'EMSCoeff') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'EMSCoeff', 
  'dbo.FNAEMSEMSCoeff(cast(arg1  as INT),CAST(arg2 AS INT),arg3,cast(arg4  as INT),cast(arg5  as INT),cast(arg6  as INT),cast(arg7  as INT),cast(arg8  as INT),cast(arg9  as INT),cast(arg10  as INT),cast(arg11  as INT),cast(arg12  as INT),cast(arg13  as INT),cast(arg14  as INT),cast(arg15  as INT),cast(arg16  as INT))',
  'CONVERT(VARCHAR,t.curve_id)',
  'CONVERT(VARCHAR,t.generator_id)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.input_char1)',
  'CONVERT(VARCHAR(10),t.input_char2)',
  'CONVERT(VARCHAR(10),t.input_char3)',
  'CONVERT(VARCHAR(10),t.input_char4)',
  'CONVERT(VARCHAR(10),t.input_char5)',
  'CONVERT(VARCHAR(10),t.input_char6)',
  'CONVERT(VARCHAR(10),t.input_char7)',
  'CONVERT(VARCHAR(10),t.input_char8)',
  'CONVERT(VARCHAR(10),t.input_char9)',
  'CONVERT(VARCHAR(10),t.input_char10)',
  'arg1',
  'arg2',
  'arg3',
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'EMSCoeff', 
  eval_string = 'dbo.FNAEMSEMSCoeff(cast(arg1  as INT),CAST(arg2 AS INT),arg3,cast(arg4  as INT),cast(arg5  as INT),cast(arg6  as INT),cast(arg7  as INT),cast(arg8  as INT),cast(arg9  as INT),cast(arg10  as INT),cast(arg11  as INT),cast(arg12  as INT),cast(arg13  as INT),cast(arg14  as INT),cast(arg15  as INT),cast(arg16  as INT))',
  arg1 = 'CONVERT(VARCHAR,t.curve_id)',
  arg2 = 'CONVERT(VARCHAR,t.generator_id)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg4 = 'CONVERT(VARCHAR(10),t.input_char1)',
  arg5 = 'CONVERT(VARCHAR(10),t.input_char2)',
  arg6 = 'CONVERT(VARCHAR(10),t.input_char3)',
  arg7 = 'CONVERT(VARCHAR(10),t.input_char4)',
  arg8 = 'CONVERT(VARCHAR(10),t.input_char5)',
  arg9 = 'CONVERT(VARCHAR(10),t.input_char6)',
  arg10 = 'CONVERT(VARCHAR(10),t.input_char7)',
  arg11 = 'CONVERT(VARCHAR(10),t.input_char8)',
  arg12 = 'CONVERT(VARCHAR(10),t.input_char9)',
  arg13 = 'CONVERT(VARCHAR(10),t.input_char10)',
  arg14 = 'arg1',
  arg15 = 'arg2',
  arg16 = 'arg3',
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'EMSCoeff'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'SourceActivity') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'SourceActivity', 
  'dbo.FNAEMSSourceActivity(arg1,CAST(arg2 AS INT),arg3,cast(arg4  as INT))',
  'CONVERT(VARCHAR(10),t.prod_date,120)',
  'arg1',
  'arg2',
  'arg3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'SourceActivity', 
  eval_string = 'dbo.FNAEMSSourceActivity(arg1,CAST(arg2 AS INT),arg3,cast(arg4  as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.prod_date,120)',
  arg2 = 'arg1',
  arg3 = 'arg2',
  arg4 = 'arg3',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'SourceActivity'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'FixedCurve') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'FixedCurve', 
  'dbo.FNARFixedCurve(arg1, arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(20), t.prod_date, 120)',
  'CONVERT(VARCHAR(20), t.as_of_date, 120)',
  'CONVERT(VARCHAR(10), t.granularity)',
  'CONVERT(VARCHAR, t.hour)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'FixedCurve', 
  eval_string = 'dbo.FNARFixedCurve(arg1, arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20), t.prod_date, 120)',
  arg2 = 'CONVERT(VARCHAR(20), t.as_of_date, 120)',
  arg3 = 'CONVERT(VARCHAR(10), t.granularity)',
  arg4 = 'CONVERT(VARCHAR, t.hour)',
  arg5 = 'arg1',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'FixedCurve'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DealStrikePrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DealStrikePrice', 
  'dbo.FNARDealStrikePrice(cast(arg1  as INT), CAST(arg2 AS INT))',
  'CONVERT(VARCHAR(10), t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10), t.source_deal_header_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DealStrikePrice', 
  eval_string = 'dbo.FNARDealStrikePrice(cast(arg1  as INT), CAST(arg2 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10), t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(10), t.source_deal_header_id)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DealStrikePrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IsInternalPortfolio') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IsInternalPortfolio', 
  'dbo.FNARIsInternalPortfolio(CAST(arg1 AS INT), CAST(arg2 AS INT))',
  'CONVERT(VARCHAR(15), t.source_deal_header_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IsInternalPortfolio', 
  eval_string = 'dbo.FNARIsInternalPortfolio(CAST(arg1 AS INT), CAST(arg2 AS INT))',
  arg1 = 'CONVERT(VARCHAR(15), t.source_deal_header_id)',
  arg2 = 'arg1',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IsInternalPortfolio'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ExAnteVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ExAnteVolm', 
  'dbo.FNARExAnteVolume(CAST(arg1 AS INT), arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'CONVERT(VARCHAR(20), t.prod_date, 120)',
  'CONVERT(VARCHAR, t.hour)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ExAnteVolm', 
  eval_string = 'dbo.FNARExAnteVolume(CAST(arg1 AS INT), arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20), t.prod_date, 120)',
  arg3 = 'CONVERT(VARCHAR, t.hour)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ExAnteVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ExPostVolm') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ExPostVolm', 
  'dbo.FNARExPostVolume(CAST(arg1 AS INT), arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT))',
  'CONVERT(VARCHAR(10),t.contract_id)',
  'CONVERT(VARCHAR(20), t.prod_date, 120)',
  'CONVERT(VARCHAR, t.hour)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ExPostVolm', 
  eval_string = 'dbo.FNARExPostVolume(CAST(arg1 AS INT), arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.contract_id)',
  arg2 = 'CONVERT(VARCHAR(20), t.prod_date, 120)',
  arg3 = 'CONVERT(VARCHAR, t.hour)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ExPostVolm'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'YrCount') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'YrCount', 
  'dbo.FNARYearCount(arg1, arg2)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20), t.prod_date, 120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'YrCount', 
  eval_string = 'dbo.FNARYearCount(arg1, arg2)',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR(20), t.prod_date, 120)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'YrCount'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Year') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Year', 
  'dbo.FNARYear(arg1)',
  'CONVERT(VARCHAR(10), t.prod_date, 120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Year', 
  eval_string =  'dbo.FNARYear(arg1)',
  arg1 = 'CONVERT(VARCHAR(10), t.prod_date, 120)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Year'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ShapedDealPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ShapedDealPrice', 
  'dbo.FNARShapedDealPrice(cast(arg1  as INT),cast(arg2 as INT),cast(arg3 as INT),arg4,cast(arg5 as INT),cast(arg6 as INT), cast(arg7 as INT), cast(arg8 as int))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'CONVERT(VARCHAR(20),t.contract_id)',
  'CONVERT(VARCHAR(20),t.counterparty_id,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.[Hour])               ',
  'CONVERT(VARCHAR(10),t.granularity)',
  'CONVERT(VARCHAR(10),t.is_dst)',
  'CONVERT(VARCHAR,t.mins)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ShapedDealPrice', 
  eval_string = 'dbo.FNARShapedDealPrice(cast(arg1  as INT),cast(arg2 as INT),cast(arg3 as INT),arg4,cast(arg5 as INT),cast(arg6 as INT), cast(arg7 as INT), cast(arg8 as int))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = 'CONVERT(VARCHAR(20),t.contract_id)',
  arg3 = 'CONVERT(VARCHAR(20),t.counterparty_id,120)',
  arg4 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg5 = 'CONVERT(VARCHAR,t.[Hour])               ',
  arg6 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg7 = 'CONVERT(VARCHAR(10),t.is_dst)',
  arg8 = 'CONVERT(VARCHAR,t.mins)',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ShapedDealPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'PriceCurve') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'PriceCurve', 
  'dbo.FNARPriceCurve(arg1, arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT), CAST(arg6 AS INT), CAST(NULLIF(arg7,''NULL'') AS FLOAT), CAST(NULLIF(arg8,''NULL'') AS FLOAT))',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR,t.hour)               ',
  'CONVERT(VARCHAR,t.mins)',
  'CONVERT(VARCHAR,t.is_dst)',
  'arg1',
  'arg2',
  'arg3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'PriceCurve', 
  eval_string = 'dbo.FNARPriceCurve(arg1, arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT), CAST(arg6 AS INT), CAST(NULLIF(arg7,''NULL'') AS FLOAT), CAST(NULLIF(arg8,''NULL'') AS FLOAT))',
  arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.hour)               ',
  arg4 = 'CONVERT(VARCHAR,t.mins)',
  arg5 = 'CONVERT(VARCHAR,t.is_dst)',
  arg6 = 'arg1',
  arg7 = 'arg2',
  arg8 = 'arg3',
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'PriceCurve'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'DaysInPeriod') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'DaysInPeriod', 
  'dbo.FNARDaysInPeriod(cast(arg1  as INT))',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'DaysInPeriod', 
  eval_string = 'dbo.FNARDaysInPeriod(cast(arg1  as INT))',
  arg1 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'DaysInPeriod'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'GetBookID') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'GetBookID', 
  'dbo.FNARGetBookID(arg1)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'GetBookID', 
  eval_string = 'dbo.FNARGetBookID(arg1)',
  arg1 = 'arg1',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'GetBookID'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Round') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Round', 
  'dbo.FNARRound(CAST (arg1 AS FLOAT),CAST (arg2 AS INT))',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Round', 
  eval_string = 'dbo.FNARRound(CAST (arg1 AS FLOAT),CAST (arg2 AS INT))',
  arg1 = 'arg1',
  arg2 = 'arg2',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Round'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'PriorInvoiceAdjustment') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'PriorInvoiceAdjustment', 
  'dbo.FNARPriorInvoiceAdjustment(CAST(arg1 AS DATETIME), CAST(arg2 AS DATETIME), CAST(arg3 as INT),CAST(arg4 as INT),CAST(arg5 as INT),CAST(arg6 as INT),CAST(arg7 as INT),CAST(arg8 as INT),CAST(arg9 as INT),CAST(arg10 as INT),CAST(arg11 as INT),CAST(arg12 as INT),CAST(arg13 as INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  'CONVERT(VARCHAR,t.formula_id)',
  'CONVERT(VARCHAR,t.hour)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  'arg1',
  'arg2',
  'arg3',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'PriorInvoiceAdjustment', 
  eval_string = 'dbo.FNARPriorInvoiceAdjustment(CAST(arg1 AS DATETIME), CAST(arg2 AS DATETIME), CAST(arg3 as INT),CAST(arg4 as INT),CAST(arg5 as INT),CAST(arg6 as INT),CAST(arg7 as INT),CAST(arg8 as INT),CAST(arg9 as INT),CAST(arg10 as INT),CAST(arg11 as INT),CAST(arg12 as INT),CAST(arg13 as INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg3 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg4 = 'CONVERT(VARCHAR,t.contract_id)',
  arg5 = 'CONVERT(VARCHAR,t.invoice_Line_item_id)',
  arg6 = 'CONVERT(VARCHAR,t.formula_id)',
  arg7 = 'CONVERT(VARCHAR,t.hour)',
  arg8 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg9 = 'CONVERT(VARCHAR(10),t.source_deal_header_id)',
  arg10 = 'CONVERT(VARCHAR(10),t.source_deal_detail_id)',
  arg11 = 'arg1',
  arg12 = 'arg2',
  arg13 = 'arg3',
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'PriorInvoiceAdjustment'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ConstantValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ConstantValue', 
  'arg1',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ConstantValue', 
  eval_string = 'arg1',
  arg1 = 'arg1',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ConstantValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageQtrDailyPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageQtrDailyPrice', 
  'dbo.FNARAverageQtrDailyPrice(CAST(arg1 AS DATETIME),CAST(arg2 AS INT), CAST(arg3 AS INT))',
  'CONVERT(VARCHAR(20),prod_date,120)',
  'arg1',
  'arg2   ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageQtrDailyPrice', 
  eval_string = 'dbo.FNARAverageQtrDailyPrice(CAST(arg1 AS DATETIME),CAST(arg2 AS INT), CAST(arg3 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),prod_date,120)',
  arg2 = 'arg1',
  arg3 = 'arg2   ',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageQtrDailyPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'GetRelativeCurveID') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'GetRelativeCurveID', 
  'dbo.FNARGetRelativeCurveID(CAST(arg1 AS INT))       ',
  'CONVERT(VARCHAR(20),t.Volume)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'GetRelativeCurveID', 
  eval_string = 'dbo.FNARGetRelativeCurveID(CAST(arg1 AS INT))       ',
  arg1 = 'CONVERT(VARCHAR(20),t.Volume)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'GetRelativeCurveID'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'FieldValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'FieldValue', 
  'case when isnull(''@formula_audit'',''n'')=''y'' then dbo.FNARFieldValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),''@as_of_date'',cast(arg10 as INT)) else dbo.FNARFieldValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),null,cast(arg10 as INT)) end',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(10),t.granularity)',
  'CONVERT(VARCHAR(20),t.prod_date)    ',
  'CONVERT(VARCHAR(20),t.as_of_date,120)',
  'CONVERT(VARCHAR,t.hour)',
  NULL,
  NULL,
  'CONVERT(VARCHAR,t.counterparty_id)',
  'CONVERT(VARCHAR,t.contract_id)',
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'FieldValue', 
  eval_string = 'case when isnull(''@formula_audit'',''n'')=''y'' then dbo.FNARFieldValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),''@as_of_date'',cast(arg10 as INT)) else dbo.FNARFieldValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),null,cast(arg10 as INT)) end',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(10),t.granularity)',
  arg3 = 'CONVERT(VARCHAR(20),t.prod_date)    ',
  arg4 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
  arg5 = 'CONVERT(VARCHAR,t.hour)',
  arg6 = NULL,
  arg7 = NULL,
  arg8 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg9 = 'CONVERT(VARCHAR,t.contract_id)',
  arg10 = 'arg1',
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'FieldValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'GetUserDefinedValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'GetUserDefinedValue', 
  'dbo.FNARGetUserDefinedValue(CAST(arg1 AS INT), CAST(arg2 AS INT), CAST(arg3 AS INT))',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'arg1',
  'arg2',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'GetUserDefinedValue', 
  eval_string = 'dbo.FNARGetUserDefinedValue(CAST(arg1 AS INT), CAST(arg2 AS INT), CAST(arg3 AS INT))',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'arg1',
  arg3 = 'arg2',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'GetUserDefinedValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Escalation') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Escalation', 
  'dbo.FNAREscalation(CAST(arg1 AS INT), CAST(arg2 AS FLOAT))',
  'CONVERT(VARCHAR(20),prod_date,120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Escalation', 
  eval_string = 'dbo.FNAREscalation(CAST(arg1 AS INT), CAST(arg2 AS FLOAT))',
  arg1 = 'CONVERT(VARCHAR(20),prod_date,120)',
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Escalation'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'WACOGPrice') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'WACOGPrice', 
  'dbo.FNARWACOGPrice(arg1,arg2, wif1.curve_shift_val  ,wif1.curve_shift_per)',
  'CONVERT(VARCHAR(20),t.prod_date,120)',
  'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'WACOGPrice', 
  eval_string = 'dbo.FNARWACOGPrice(arg1,arg2, wif1.curve_shift_val  ,wif1.curve_shift_per)',
  arg1 = 'CONVERT(VARCHAR(20),t.prod_date,120)',
  arg2 = 'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'WACOGPrice'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'CounterpartyNetPwrPurchase') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'CounterpartyNetPwrPurchase', 
  'dbo.FNARCounterpartyNetPwrPurchase(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT))',
  NULL,
  'CONVERT(VARCHAR,t.counterparty_id)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'CounterpartyNetPwrPurchase', 
  eval_string = 'dbo.FNARCounterpartyNetPwrPurchase(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT))',
  arg1 = NULL,
  arg2 = 'CONVERT(VARCHAR,t.counterparty_id)',
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'CounterpartyNetPwrPurchase'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageCurveValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageCurveValue', 
  'dbo.FNARAverageCurveValue(arg1,cast(arg2 as INT), arg3,wif1.curve_shift_val  ,wif1.curve_shift_per)',
  NULL,
  'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  'CASE WHEN ''@calc_type''=''s'' THEN null ELSE CONVERT(VARCHAR(20), t.as_of_date, 120)  END',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageCurveValue', 
  eval_string = 'dbo.FNARAverageCurveValue(arg1,cast(arg2 as INT), arg3,wif1.curve_shift_val  ,wif1.curve_shift_per)',
  arg1 = NULL,
  arg2 = 'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  arg3 = 'CASE WHEN ''@calc_type''=''s'' THEN null ELSE CONVERT(VARCHAR(20), t.as_of_date, 120)  END',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageCurveValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ProvisionalCurveValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ProvisionalCurveValue', 
  'dbo.FNARProvisionalCurveValue(arg1,cast(arg2 as INT), arg3,wif1.curve_shift_val  ,wif1.curve_shift_per)',
  NULL,
  'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  'CASE WHEN ''@calc_type''=''s'' THEN null ELSE  CONVERT(VARCHAR(20), t.as_of_date, 120)  END',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ProvisionalCurveValue', 
  eval_string = 'dbo.FNARProvisionalCurveValue(arg1,cast(arg2 as INT), arg3,wif1.curve_shift_val  ,wif1.curve_shift_per)',
  arg1 = NULL,
  arg2 = 'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  arg3 = 'CASE WHEN ''@calc_type''=''s'' THEN null ELSE  CONVERT(VARCHAR(20), t.as_of_date, 120)  END',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ProvisionalCurveValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageMonthlyCurveValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageMonthlyCurveValue', 
  'dbo.FNARAverageMonthlyCurveValue(arg1,cast(arg2 as INT), arg3,arg4,wif1.curve_shift_val  ,wif1.curve_shift_per)',
  NULL,
  NULL,
  'CONVERT(VARCHAR(15), t.source_deal_detail_id)  ',
  'CASE WHEN ''@calc_type''=''s'' THEN ''null'' ELSE  CONVERT(VARCHAR(20), t.as_of_date, 120) END',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageMonthlyCurveValue', 
  eval_string = 'dbo.FNARAverageMonthlyCurveValue(arg1,cast(arg2 as INT), arg3,arg4,wif1.curve_shift_val  ,wif1.curve_shift_per)',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = 'CONVERT(VARCHAR(15), t.source_deal_detail_id)  ',
  arg4 = 'CASE WHEN ''@calc_type''=''s'' THEN ''null'' ELSE  CONVERT(VARCHAR(20), t.as_of_date, 120) END',
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageMonthlyCurveValue'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '-') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '-', 
  'cast(arg1 AS FLOAT)+(-1.00*cast(arg2 AS FLOAT))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '-', 
  eval_string = 'cast(arg1 AS FLOAT)+(-1.00*cast(arg2 AS FLOAT))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '-'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '*') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '*', 
  'cast(arg1 AS FLOAT)*cast(arg2 AS FLOAT)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '*', 
  eval_string = 'cast(arg1 AS FLOAT)*cast(arg2 AS FLOAT)',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '*'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '/') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '/', 
  'cast(arg1 AS FLOAT)/ISNULL(NULLIF(cast(arg2 AS FLOAT),0),1)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '/', 
  eval_string = 'cast(arg1 AS FLOAT)/ISNULL(NULLIF(cast(arg2 AS FLOAT),0),1)',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '/'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '^') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '^', 
  'power(cast(arg1 AS FLOAT),cast(arg2 AS FLOAT))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '^', 
  eval_string = 'power(cast(arg1 AS FLOAT),cast(arg2 AS FLOAT))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '^'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '+') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '+', 
  'cast(ISNULL(arg1,0) AS FLOAT)+cast(ISNULL(arg2,0) AS FLOAT)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '+', 
  eval_string = 'cast(ISNULL(arg1,0) AS FLOAT)+cast(ISNULL(arg2,0) AS FLOAT)',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '+'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '<') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '<', 
  'CASE WHEN cast(arg1 AS FLOAT) < cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '<', 
  eval_string = 'CASE WHEN cast(arg1 AS FLOAT) < cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '<'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '<=') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '<=', 
  'CASE WHEN cast(arg1 AS FLOAT) <= cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '<=', 
  eval_string = 'CASE WHEN cast(arg1 AS FLOAT) <= cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '<='
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '<>') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '<>', 
  'CASE WHEN cast(arg1 AS FLOAT) <> cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '<>', 
  eval_string = 'CASE WHEN cast(arg1 AS FLOAT) <> cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '<>'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '>') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '>', 
  'CASE WHEN cast(arg1 AS FLOAT) > cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '>', 
  eval_string = 'CASE WHEN cast(arg1 AS FLOAT) > cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '>'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = '>=') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT '>=', 
  'CASE WHEN cast(arg1 AS FLOAT) >= cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = '>=', 
  eval_string = 'CASE WHEN cast(arg1 AS FLOAT) >= cast(arg2 AS FLOAT) THEN 1 ELSE 0 END ',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = '>='
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AND') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AND', 
  'CASE WHEN cast(arg1 AS FLOAT) = 1  AND cast(arg2 AS FLOAT) =1 THEN 1 ELSE 0 END ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AND', 
  eval_string = 'CASE WHEN cast(arg1 AS FLOAT) = 1  AND cast(arg2 AS FLOAT) =1 THEN 1 ELSE 0 END ',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AND'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AVG') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AVG', 
  'dbo.FNAAVG(CAST(arg1 AS FLOAT),CAST(arg2 AS FLOAT))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AVG', 
  eval_string = 'dbo.FNAAVG(CAST(arg1 AS FLOAT),CAST(arg2 AS FLOAT))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AVG'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Ceiling') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Ceiling', 
  'ceiling(cast(arg1 as float))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Ceiling', 
  eval_string = 'ceiling(cast(arg1 as float))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Ceiling'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'COALESCE') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'COALESCE', 
  'dbo.FNARCoalesce(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'COALESCE', 
  eval_string = 'dbo.FNARCoalesce(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12)',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'COALESCE'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Floor') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Floor', 
  'Floor(cast(arg1 as float))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Floor', 
  eval_string = 'Floor(cast(arg1 as float))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Floor'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'IF') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'IF', 
  'CASE WHEN cast(arg1 AS FLOAT)=1 THEN cast(arg2 AS FLOAT) ELSE cast(arg3 AS FLOAT) END',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'IF', 
  eval_string = 'CASE WHEN cast(arg1 AS FLOAT)=1 THEN cast(arg2 AS FLOAT) ELSE cast(arg3 AS FLOAT) END',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'IF'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ISNULL') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ISNULL', 
  'dbo.FNARIsNull(CAST(arg1 AS VARCHAR(5000)),CAST(arg2 AS VARCHAR(5000)))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'ISNULL', 
  eval_string = 'dbo.FNARIsNull(CAST(arg1 AS VARCHAR(5000)),CAST(arg2 AS VARCHAR(5000)))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'ISNULL'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MAX') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MAX', 
  'dbo.FNAMax(CAST(arg1 AS FLOAT),CAST(arg2 AS FLOAT))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MAX', 
  eval_string = 'dbo.FNAMax(CAST(arg1 AS FLOAT),CAST(arg2 AS FLOAT))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MAX'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'MIN') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'MIN', 
  'dbo.FNAMIN(CAST(arg1 AS FLOAT),CAST(arg2 AS FLOAT))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'MIN', 
  eval_string = 'dbo.FNAMIN(CAST(arg1 AS FLOAT),CAST(arg2 AS FLOAT))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'MIN'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'offPeakVolume') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'offPeakVolume', 
  'offPeakVolume',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'offPeakVolume', 
  eval_string = 'offPeakVolume',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'offPeakVolume'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'onPeakVolume') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'onPeakVolume', 
  'onPeakVolume',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'onPeakVolume', 
  eval_string = 'onPeakVolume',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'onPeakVolume'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'OR') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'OR', 
  'CASE WHEN cast(arg1 AS FLOAT) = 1  OR cast(arg2 AS FLOAT) =1 THEN 1 ELSE 0 END ',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'OR', 
  eval_string = 'CASE WHEN cast(arg1 AS FLOAT) = 1  OR cast(arg2 AS FLOAT) =1 THEN 1 ELSE 0 END ',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'OR'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Parenthesis') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Parenthesis', 
  'arg1',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Parenthesis', 
  eval_string = 'arg1',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Parenthesis'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Power') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Power', 
  'dbo.FNAPower(CAST(arg1 AS FLOAT),CAST(arg2 AS FLOAT))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Power', 
  eval_string = 'dbo.FNAPower(CAST(arg1 AS FLOAT),CAST(arg2 AS FLOAT))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Power'
END
IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'Sqrt') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'Sqrt', 
  'dbo.FNASqrt(CAST(arg1 AS FLOAT))',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'Sqrt', 
  eval_string = 'dbo.FNASqrt(CAST(arg1 AS FLOAT))',
  arg1 = NULL,
  arg2 = NULL,
  arg3 = NULL,
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Sqrt'
END

IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AverageCurveValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'AverageCurveValue', 
  'dbo.FNARAverageCurveValue(arg1,cast(arg2 as INT),arg3,wif1.curve_shift_val  ,wif1.curve_shift_per)',
  NULL,
  'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  'CONVERT(VARCHAR(10), t.as_of_date, 120)',
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
END
ELSE
BEGIN
 UPDATE formula_function_mapping
 SET
  function_name = 'AverageCurveValue', 
  eval_string = 'dbo.FNARAverageCurveValue(arg1,cast(arg2 as INT),arg3,wif1.curve_shift_val  ,wif1.curve_shift_per)',
  arg1 = NULL,
  arg2 = 'CONVERT(VARCHAR(15), t.source_deal_detail_id)',
  arg3 = 'CONVERT(VARCHAR(10), t.as_of_date, 120)',
  arg4 = NULL,
  arg5 = NULL,
  arg6 = NULL,
  arg7 = NULL,
  arg8 = NULL,
  arg9 = NULL,
  arg10 = NULL,
  arg11 = NULL,
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'AverageCurveValue'
END

IF NOT EXISTS(SELECT * FROM formula_function_mapping WHERE function_name='DaysInContractMnth')
BEGIN
	INSERT INTO formula_function_mapping(function_name,eval_string,arg1, arg2, arg3)
	SELECT 'DaysInContractMnth','dbo.FNARDaysInContractMnth(cast(arg1 as int),cast(arg2 as int),arg3)','CONVERT(VARCHAR(10),t.contract_id)','CONVERT(VARCHAR(10),t.counterparty_id)','CONVERT(VARCHAR(20),t.prod_date,120)'
END
ELSE 
BEGIN
	UPDATE formula_function_mapping
	SET
		function_name = 'DaysInContractMnth',
		eval_string = 'dbo.FNARDaysInContractMnth(cast(arg1 as int),cast(arg2 as int),arg3)',
		arg1 = 'CONVERT(VARCHAR(10),t.contract_id)',
		arg2 = 'CONVERT(VARCHAR(10),t.counterparty_id)',
		arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)'
	WHERE function_name = 'DaysInContractMnth'	
END

--Get Contract Fee
IF NOT EXISTS (SELECT 1 FROM   formula_function_mapping WHERE  function_name = 'GetGMContractFee')
BEGIN
    INSERT INTO formula_function_mapping
      (
        function_name,
        eval_string,
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
        arg8,
        arg9,
        arg10,
        arg11,
        arg12,
        arg13,
        arg14,
        arg15,
        arg16,
        arg17,
        arg18
      )
    SELECT 'GetGMContractFee',
           'dbo.FNARGetGMContractFee(CAST(NULLIF(arg1,''NULL'') AS INT),CAST(NULLIF(arg2,''NULL'') AS FLOAT))',
           'arg1',
           'arg2',
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL
END
ELSE
BEGIN
    UPDATE formula_function_mapping
    SET    function_name     = 'GetGMContractFee',
           eval_string       = 
           'dbo.FNARGetGMContractFee(CAST(NULLIF(arg1,''NULL'') AS INT),CAST(NULLIF(arg2,''NULL'') AS FLOAT))',
           arg1              = 'arg1',
           arg2              = 'arg2',
           arg3              = NULL,
           arg4              = NULL,
           arg5              = NULL,
           arg6              = NULL,
           arg7              = NULL,
           arg8              = NULL,
           arg9              = NULL,
           arg10             = NULL,
           arg11             = NULL,
           arg12             = NULL,
           arg13             = NULL,
           arg14             = NULL,
           arg15             = NULL,
           arg16             = NULL,
           arg17             = NULL,
           arg18             = NULL
    WHERE  function_name     = 'GetGMContractFee'
END

--Derive Day Ahead
IF NOT EXISTS (SELECT 1 FROM   formula_function_mapping WHERE  function_name = 'DeriveDayAhead')
BEGIN
    INSERT INTO formula_function_mapping
      (
        function_name,
        eval_string,
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
        arg8,
        arg9,
        arg10,
        arg11,
        arg12,
        arg13,
        arg14,
        arg15,
        arg16,
        arg17,
        arg18
      )
    SELECT 'DeriveDayAhead',
           'dbo.FNARDeriveDayAhead(CAST(NULLIF(arg1,''NULL'') AS INT),CAST(NULLIF(arg2,''NULL'') AS INT),CAST(NULLIF(arg3,''NULL'') AS INT),arg4)',
           'arg1',
           'arg2',
           'arg3',
           'CONVERT(VARCHAR(20),t.as_of_date,120)',
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL
END
ELSE
BEGIN
    UPDATE formula_function_mapping
    SET    function_name     = 'DeriveDayAhead',
           eval_string       = 
           'dbo.FNARDeriveDayAhead(CAST(NULLIF(arg1,''NULL'') AS INT),CAST(NULLIF(arg2,''NULL'') AS INT),CAST(NULLIF(arg3,''NULL'') AS INT),arg4)',
           arg1              = 'arg1',
           arg2              = 'arg2',
           arg3              = 'arg3',
           arg4              = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
           arg5              = NULL,
           arg6              = NULL,
           arg7              = NULL,
           arg8              = NULL,
           arg9              = NULL,
           arg10             = NULL,
           arg11             = NULL,
           arg12             = NULL,
           arg13             = NULL,
           arg14             = NULL,
           arg15             = NULL,
           arg16             = NULL,
           arg17             = NULL,
           arg18             = NULL
    WHERE  function_name     = 'DeriveDayAhead'
END
