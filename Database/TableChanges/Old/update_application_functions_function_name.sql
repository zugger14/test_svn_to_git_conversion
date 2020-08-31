/* Removed the 'Run' from the report name */
UPDATE application_functions
SET function_name = 'Deal Settlement Report',
	function_desc = 'Deal Settlement Report'
where function_id = 10222300

UPDATE application_functions
SET function_name = 'Contract Settlement Report',
	function_desc = 'Contract Settlement Report'
where function_id = 10221200

UPDATE application_functions
SET function_name = 'System Access Log Report',
	function_desc = 'System Access Log Report'
where function_id = 10111400

UPDATE application_functions
SET function_name = 'Privilege Report',
	function_desc = 'Privilege Report'
where function_id = 10111300

UPDATE application_functions
SET function_name = 'Data Import/Export Audit Report',
	function_desc = 'Data Import/Export Audit Report'
where function_id = 10201900
