/****Custom Report Collection RDL deletion where type and category is not mentioned ***/

DELETE FROM Contract_report_template WHERE [filename] = 'Confirm Replacement Report Collection' AND (template_category IS NULL OR template_category <> '42023')
DELETE FROM Contract_report_template WHERE [filename] = 'Invoice Report Collection' AND (template_category IS NULL OR template_category <> '42024')
DELETE FROM Contract_report_template WHERE [filename] = 'Trade Ticket Collection' AND (template_category IS NULL OR template_category <> '42022')
GO

/****Custom Report Collection RDL insertion ***/

IF NOT EXISTS (SELECT 1 FROM Contract_report_template crt WHERE crt.template_type = 33 AND crt.template_category = 42023)
BEGIN
	INSERT INTO contract_report_template
      (
        template_name,
        template_desc,
        sub_id,
        [filename],
        template_type,
        [default],
        [document_type],
        [template_category]
      )
    VALUES
      (
        'Confirm Replacement Report Collection',
        'Confirm Replacement Report Collection',
        NULL,
        'Confirm Replacement Report Collection',
        33,
        1,
        'r',
        42023
      )
      
     PRINT 'Confirm Replacement Report Collection inserted.'
END
ELSE
BEGIN
	UPDATE Contract_report_template
	SET
		template_name = 'Confirm Replacement Report Collection',
		template_desc = 'Confirm Replacement Report Collection',
		sub_id = NULL,
		[filename] = 'Confirm Replacement Report Collection',
		[default] = 1,
		[document_type] = 'r'
	WHERE template_type = 33 AND template_category = 42023	
	
	PRINT 'Confirm Replacement Report Collection updated.'
END
 
GO
IF NOT EXISTS (SELECT 1 FROM Contract_report_template crt WHERE crt.template_type = 38 AND crt.template_category = 42024)
BEGIN
	INSERT INTO contract_report_template
		  (
			template_name,
			template_desc,
			sub_id,
			[filename],
			template_type,
			[default],
			[document_type],
			[template_category]
		  )
		VALUES
		  (
			'Invoice Report Collection',
			'Invoice Report Collection',
			NULL,
			'Invoice Report Collection',
			 38,
				1,
				'r',
				42024
			)
		  
	PRINT 'Invoice Report Collection inserted.'
END
ELSE
BEGIN
	UPDATE Contract_report_template
	SET
		template_name = 'Invoice Report Collection',
		template_desc = 'Invoice Report Collection',
		sub_id = NULL,
		[filename] = 'Invoice Report Collection',
		[default] = 1,
		[document_type] = 'r'
	WHERE template_type = 38 AND template_category = 42024	
	
	PRINT 'Invoice Collection updated.'
END

GO

IF NOT EXISTS (SELECT 1 FROM Contract_report_template crt WHERE crt.template_type = 33 AND crt.template_category = 42022)
BEGIN
	INSERT INTO contract_report_template
		  (
			template_name,
			template_desc,
			sub_id,
			[filename],
			template_type,
			[default],
			[document_type],
			[template_category]
		  )
		VALUES
		  (
			'Trade Ticket Collection',
			'Trade Ticket Collection',
			NULL,
			'Trade Ticket Collection',
			 33,
			1,
			'r',
			42022
		  )
		  
	PRINT 'Trade Ticket Collection inserted.'
	
END
ELSE
BEGIN
	UPDATE Contract_report_template
	SET
		template_name = 'Trade Ticket Collection',
		template_desc = 'Trade Ticket Collection',
		sub_id = NULL,
		[filename] = 'Trade Ticket Collection',
		[default] = 1,
		[document_type] = 'r'
	WHERE template_type = 33 AND template_category = 42022	
	
	PRINT 'Trade Ticket Collection updated.'
END

GO