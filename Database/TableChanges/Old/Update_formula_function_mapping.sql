update formula_function_mapping set eval_string='dbo.FNARMeterVol(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),CAST(NULLIF(arg6,''NULL'') AS INT),CAST(NULLIF(arg7,''NULL'') AS INT),cast(arg8 as int),CAST(NULLIF(arg9,''NULL'') AS INT),CAST(NULLIF(arg10,''NULL'') AS INT),cast(arg11 AS INT))', arg11='CONVERT(VARCHAR(10),t.counterparty_id)' where function_name ='MeterVol'
update formula_function_mapping set eval_string='dbo.FNARECChannel(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),CAST(NULLIF(arg9,''NULL'') AS INT),cast(arg10 as int))', arg10='CONVERT(VARCHAR(10),t.counterparty_id)' where function_name ='channel'


