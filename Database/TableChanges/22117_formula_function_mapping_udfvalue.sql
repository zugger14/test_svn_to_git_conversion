
update formula_function_mapping
set 
eval_string='case when isnull(''@formula_audit'',''n'')=''y'' then dbo.FNARUDFValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),''@as_of_date'',arg11,arg12) else dbo.FNARUDFValue(cast(arg1  as INT) ,cast(arg2  as INT),arg3,arg4,cast(arg5  as INT),cast(arg6 as INT),cast(arg7 as INT),cast(arg8 as INT),cast(arg9 as INT),null,try_cast(arg11 as int),try_cast(arg12 as int)) end'
,arg1='CONVERT(VARCHAR(10),case when uddft.udf_type=''d'' then -1*ISNULL(t.source_deal_detail_id,sdd.source_deal_detail_id) else ISNULL(t.source_deal_header_id,sdd.source_deal_header_id) end)'
,arg2='CONVERT(VARCHAR(10),t.granularity)'
,arg3='CONVERT(VARCHAR(20),t.prod_date)'
,arg4='CONVERT(VARCHAR(20),t.as_of_date,120)'
,arg5='CONVERT(VARCHAR,t.hour)'
,arg6=null
,arg7=null
,arg8='CONVERT(VARCHAR,t.counterparty_id)'
,arg9='CONVERT(VARCHAR,t.contract_id)'
,arg10=null
,arg11='t.deal_price_type_id'
,arg12='arg1'
 where function_name='udfvalue'