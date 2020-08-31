
/*
The function return the most recent fee (clm2_value) for the range value ( clm1_value) of the given generic mapping table name.

*/
IF OBJECT_ID(N'FNARGetGMContractFee', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNARGetGMContractFee]
GO 
CREATE FUNCTION dbo.FNARGetGMContractFee (
	@mapping_table_id INT
	,@clm1_filter_value float
)
RETURNS FLOAT
 AS  
 
/*
declare  @mapping_name varchar(500)='Apx'
	,@clm1_filter_value numeric(20,8)=31
 
--*/ 
BEGIN 
	 DECLARE @ret_fees FLOAT
	 SELECT @ret_fees=isnull(val.clm2_value,val1.clm2_value) FROM generic_mapping_header gmh
	 outer apply
	 (
		SELECT top(1) clm2_value FROM  generic_mapping_values gmv 
		WHERE gmh.mapping_table_id=gmv.mapping_table_id
			and isnull(cast(clm1_value as numeric(20,0)),9999999)>=floor(@clm1_filter_value)
		ORDER BY cast(clm1_value as numeric(20,8))
	 ) val
	  outer apply
	 (
		SELECT top(1) clm2_value FROM  generic_mapping_values gmv 
		WHERE gmh.mapping_table_id=gmv.mapping_table_id
			and isnull(cast(clm1_value as numeric(20,0)),9999999)<floor(@clm1_filter_value)
			and val.clm2_value is null
		ORDER BY cast(clm1_value as numeric(20,8)) desc
	 ) val1
	  WHERE   gmh.mapping_table_id  = @mapping_table_id
	  
	 RETURN isnull(@ret_fees,0)
	 
 END 