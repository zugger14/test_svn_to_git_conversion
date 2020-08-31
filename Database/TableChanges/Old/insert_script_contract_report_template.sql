--SELECT * FROM  contract_report_template
    
    --Invoice Report A.rdl
    --Invoice Report.rdl
    --Invoice Std Cht Type - No Sub Total.rdl
    --Invoice Std Deal - No Sub Total.rdl
    --Invoice Std Deal - Sub Total.rdl
    
    
   IF NOT EXISTS (SELECT 1 FROM contract_report_template WHERE template_name = 'Invoice Report A')
   BEGIN   	
		INSERT INTO contract_report_template
		(
			template_name,
			template_desc,
			sub_id,
			[filename]
		)
		VALUES
		(
			'Invoice Report A',
			'Invoice Report A',
			NULL,
			'Invoice Report A.rdl'
		)      
   END
   ELSE
	BEGIN
   		UPDATE contract_report_template
   		SET [filename] = 'Invoice Report A.rdl'
   		WHERE template_name = 'Invoice Report A'
	END
	
	GO
	
	IF NOT EXISTS (SELECT 1 FROM contract_report_template WHERE template_name = 'Invoice Report')
   BEGIN   	
		INSERT INTO contract_report_template
		(
			template_name,
			template_desc,
			sub_id,
			[filename]
		)
		VALUES
		(
			'Invoice Report',
			'Invoice Report',
			NULL,
			'Invoice Report.rdl'
		)      
   END
   ELSE
	BEGIN
   		UPDATE contract_report_template
   		SET [filename] = 'Invoice Report.rdl'
   		WHERE template_name = 'Invoice Report'
	END
	
	GO
		
   
   IF NOT EXISTS (SELECT 1 FROM contract_report_template WHERE template_name = 'Invoice Std Cht Type - No Sub Total')
   BEGIN   	
		INSERT INTO contract_report_template
		(
			template_name,
			template_desc,
			sub_id,
			[filename]
		)
		VALUES
		(
			'Invoice Std Cht Type - No Sub Total',
			'Invoice Std Cht Type - No Sub Total',
			NULL,
			'Invoice Std Cht Type - No Sub Total.rdl'
		)      
   END
   ELSE
   BEGIN
   		UPDATE contract_report_template
   		SET [filename] = 'IInvoice Std Cht Type - No Sub Total.rdl'
   		WHERE template_name = 'Invoice Std Cht Type - No Sub Total'
	END
   GO
   
   IF NOT EXISTS (SELECT 1 FROM contract_report_template WHERE template_name = 'Invoice Std Deal - No Sub Total')
   BEGIN   	
		INSERT INTO contract_report_template
		(
			template_name,
			template_desc,
			sub_id,
			[filename]
		)
		VALUES
		(
			'Invoice Std Deal - No Sub Total',
			'Invoice Std Deal - No Sub Total',
			NULL,
			'Invoice Std Deal - No Sub Total.rdl'
		)      
   END
   ELSE
   BEGIN
   		UPDATE contract_report_template
   		SET [filename] = 'Invoice Std Deal - No Sub Total.rdl'
   		WHERE template_name = 'Invoice Std Deal - No Sub Total'
	END
   GO
   
	IF NOT EXISTS (SELECT 1 FROM contract_report_template WHERE template_name = 'Invoice Std Deal - Sub Total')
	BEGIN   	
		INSERT INTO contract_report_template
		(
			template_name,
			template_desc,
			sub_id,
			[filename]
		)
		VALUES
		(
			'Invoice Std Deal - Sub Total',
			'Invoice Std Deal - Sub Total',
			NULL,
			'Invoice Std Deal - Sub Total.rdl'
		)      
	END
	ELSE
	BEGIN
   		UPDATE contract_report_template
   		SET [filename] = 'Invoice Std Deal - Sub Total.rdl'
   		WHERE template_name = 'Invoice Std Deal - Sub Total'
	END
	GO