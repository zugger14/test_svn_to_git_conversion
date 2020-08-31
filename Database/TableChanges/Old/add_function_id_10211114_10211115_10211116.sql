--copy charge tyoe detail
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211114)
BEGIN
  INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
  VALUES (10211114, 'Template Charge Type Copy', 'Template Charge Type Copy', 10211112, NULL)
  PRINT ' Inserted 10211114 - Template Charge Type Copy.'
END
ELSE
BEGIN
 PRINT 'Application FunctionID 10211114 - Template Charge Type Copy.'
END

--for formula add
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211115)
BEGIN
  INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
  VALUES (10211115, 'Template Charge Type Formula Add/Save', 'Template Charge Type Formula Add/Save', 10211112, NULL)
  PRINT ' Inserted 10211115 - Template Charge Type Formula Add/Save.'
END
ELSE
BEGIN
 PRINT 'Application FunctionID 10211115 - Template Charge Type Formula Add/Save.'
END

--for formula delete
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10211116)
BEGIN
  INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
  VALUES (10211116, 'Template Charge Type Formula Delete', 'Template Charge Type Formula Delete', 10211112, NULL)
  PRINT ' Inserted 10211116 - Template Charge Type Formula Delete.'
END
ELSE
BEGIN
 PRINT 'Application FunctionID 10211116 - Template Charge Type Formula Delete.'
END

--select * from application_functions where function_id=10211114
update application_functions set function_name='Template Charge Type Copy', function_desc='Template Charge Type Copy' where function_id=10211114
update application_functions set function_name='Template Charge Type Formula Add/Save', function_desc='Template Charge Type Formula Add/Save' where function_id=10211115
update application_functions set function_name='Template Charge Type Formula Delete', function_desc='Template Charge Type Formula Delete' where function_id=10211116

update application_functions set function_name='Contract Component Template Menu', function_desc='Contract Component Template Menu' where function_id=10211100
update application_functions set function_name='Contract Component Template Add/Save', function_desc='Contract Component Template Add/Save' where function_id=10211110
update application_functions set function_name='Contract Component Template Delete', function_desc='Contract Component Template Delete' where function_id=10211111
update application_functions set function_name='Template Charge Type Add/save', function_desc='Template Charge Type Add/save' where function_id=10211112
update application_functions set function_name='Template Charge Type Delete', function_desc='Template Charge Type Delete' where function_id=10211113