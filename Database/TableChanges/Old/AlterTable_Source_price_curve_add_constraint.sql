IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_price_curve]') AND name = N'IX_unique_source_curve_def_id_index')
BEGIN
	ALTER TABLE source_price_curve
		ADD CONSTRAINT IX_unique_source_curve_def_id_index UNIQUE (as_of_date, source_curve_def_id, maturity_date, is_dst, curve_source_value_id, Assessment_curve_type_value_id)
END
GO