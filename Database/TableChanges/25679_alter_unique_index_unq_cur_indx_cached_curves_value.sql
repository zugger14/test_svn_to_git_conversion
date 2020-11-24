IF EXISTS(SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.cached_curves_value') AND name = N'unq_cur_indx_cached_curves_value')
BEGIN
	DROP INDEX [unq_cur_indx_cached_curves_value] ON dbo.cached_curves_value 
END

CREATE UNIQUE CLUSTERED INDEX unq_cur_indx_cached_curves_value ON cached_curves_value(Master_ROWID,as_of_date,term,pricing_option,curve_source_id,value_type)