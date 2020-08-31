IF NOT EXISTS(SELECT 'X' FROM information_schema.columns WHERE TABLE_NAME = 'source_deal_detail_template' AND COLUMN_NAME = 'formula')
BEGIN
	ALTER TABLE source_deal_detail_template 
	ADD formula VARCHAR(100)
END


IF NOT EXISTS(SELECT 'X' FROM information_schema.columns WHERE TABLE_NAME = 'source_deal_detail_template' AND COLUMN_NAME = 'pay_opposite')
BEGIN
	ALTER TABLE source_deal_detail_template 
	Add pay_opposite VARCHAR(100)
END

     
      