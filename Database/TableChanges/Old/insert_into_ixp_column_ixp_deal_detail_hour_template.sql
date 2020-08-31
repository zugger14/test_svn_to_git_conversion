DECLARE @ixp_deal_detail_hour_template_id INT	
SELECT @ixp_deal_detail_hour_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_deal_detail_hour_template'

IF @ixp_deal_detail_hour_template_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'is_dst' AND ixp_table_id = @ixp_deal_detail_hour_template_id) 
	BEGIN INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, header_detail) 
	SELECT @ixp_deal_detail_hour_template_id, 'is_dst', 0, NULL END
	END
ELSE
BEGIN
	SELECT 'ixp_deal_detail_hour_template not present in ixp_tables'
END