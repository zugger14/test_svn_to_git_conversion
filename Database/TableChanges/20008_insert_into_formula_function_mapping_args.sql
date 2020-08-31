
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