IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 10141400
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
        10141400,
        'Transcations Report',
        'Transcations Report',
        '10202200',
        NULL,
        NULL,
        NULL,
        0
      )
    PRINT 'INSERTED 10141400 - Transcations Report.'
END
ELSE
BEGIN
    PRINT 
    'Application FunctionID 10141400 - Transcations Report already EXISTS.'
END