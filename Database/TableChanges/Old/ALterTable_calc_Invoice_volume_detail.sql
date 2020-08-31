/***************
ALter table calc_invoice_volume_detail ADD sub_id INT
**************/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'calc_invoice_volume_detail' and column_name = 'sub_id')
	ALter table calc_invoice_volume_detail ADD sub_id INT


