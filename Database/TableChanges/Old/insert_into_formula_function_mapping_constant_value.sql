IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'ConstantValue') 
BEGIN
 INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18)
 SELECT 'ConstantValue', 
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
  function_name = 'ConstantValue', 
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
 WHERE function_name = 'ConstantValue'
END