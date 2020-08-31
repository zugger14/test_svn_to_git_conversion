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
  eval_string = 'dbo.FNARECChannel(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),CAST(NULLIF(arg9,''NULL'') AS INT),cast(arg10 as int),cast(arg11 as int))',
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
  arg11 = 'CONVERT(VARCHAR(10),t.counterparty_id)',
  arg12 = NULL,
  arg13 = NULL,
  arg14 = NULL,
  arg15 = NULL,
  arg16 = NULL,
  arg17 = NULL,
  arg18 = NULL 
 WHERE function_name = 'Channel'
END