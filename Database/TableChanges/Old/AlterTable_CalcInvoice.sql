/**************************************
Alter table calc_invoice_volume,calc_invoice_volume_detail,calc_formula_value
select * from calc_invoice_volume
select * from calc_invoice_volume_detail
select * from calc_formula_value
**************************************/

ALTER TABLE calc_invoice_volume ADD deal_type_id INT
ALTER TABLE calc_invoice_volume_detail ADD deal_type_id INT
ALTER TABLE calc_formula_value ADD deal_type_id INT
ALTER TABLE calc_invoice_summary ADD deal_type_id INT

