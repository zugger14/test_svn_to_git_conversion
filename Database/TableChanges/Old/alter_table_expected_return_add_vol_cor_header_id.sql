

IF COL_LENGTH('expected_return', 'vol_cor_header_id') IS NULL
BEGIN
	alter table expected_return add vol_cor_header_id int
	alter table expected_return add granularity int
END
