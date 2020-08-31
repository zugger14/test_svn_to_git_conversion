IF NOT EXISTS(SELECT 'function' FROM application_functions AS af WHERE af.function_id = 10121000)
	BEGIN
		INSERT INTO application_functions(
			function_id,
			function_name,
			function_desc,
			func_ref_id,
			document_path,
			function_call,
			file_path,
			book_required
		)VALUES (
			10121000,
			'Maintain Compliance Groups',
			'Maintain Compliance Groups',
			10100000,
			'',
			'windowMaintainComplianceProcess',
			'_compliance_management/maintain_compliance_group/maintain.complaince.process.group.php',
			1
		)
	END
ELSE
	BEGIN
		UPDATE application_functions 
		SET file_path = '_compliance_management/maintain_compliance_group/maintain.complaince.process.group.php',
			func_ref_id = 10100000,
			document_path = '',
			book_required = 1
		WHERE function_id = 10121000
	END
