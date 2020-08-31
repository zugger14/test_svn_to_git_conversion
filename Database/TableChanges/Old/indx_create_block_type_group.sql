
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_curve_def]') 
					AND name = N'indx_source_price_curve_def_udf_block_group_id')
BEGIN
	CREATE index indx_block_type_group_id  on dbo.block_type_group(  block_type_group_id)
	CREATE index indx_hourly_block_id  on dbo.block_type_group(  hourly_block_id)
	CREATE index indx_udf_block_group_id  on dbo.source_price_curve_def(  udf_block_group_id) where udf_block_group_id is not null
END					


