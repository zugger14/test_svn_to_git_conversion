IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 14100103
   )
BEGIN
    INSERT INTO application_functions
      (
        function_id,
        function_name,
        function_desc,
        func_ref_id,
        function_call,
        document_path,
        file_path,
        book_required
      )
    VALUES
      (
        14100103,
        'Requirement',
        'Requirement',
        NULL,
        NULL,
        NULL,
        '_setup/compliance_jurisdiction/compliance.jurisdiction.requirement.php',
        0
      )
    PRINT 'INSERTED  - Requirement'
END
ELSE
BEGIN
    PRINT 'Application FunctionID - Requirement already EXISTS.'
END