IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_curve]') 
					AND name = N'source_curve_def_id_index')
BEGIN
CREATE CLUSTERED INDEX source_curve_def_id_index 
ON source_price_curve(as_of_date, source_curve_def_id, maturity_date, is_dst, curve_source_value_id) 	
END					
