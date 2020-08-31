IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 14100100
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
        14100100,
        'Compliance Jurisdiction',
        'Compliance Jurisdiction',
        NULL,
        NULL,
        NULL,
        '_setup/compliance_jurisdiction/compliance.jurisdiction.php',
        0
      )
    PRINT 'INSERTED  - Compliance Jurisdiction.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID - Compliance Jurisdiction already EXISTS.'
END