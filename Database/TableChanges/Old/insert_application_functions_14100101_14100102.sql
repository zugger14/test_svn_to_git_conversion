IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 14100101
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
        14100101,
        'Add/Save',
        'Add/Save',
        14100100,
        NULL,
        NULL,
        NULL,
        0
      )
    PRINT 'INSERTED  - 14100101.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID - 14100101 already EXISTS.'
END

IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 14100102
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
        14100102,
        'Delete',
        'Delete',
        14100100,
        NULL,
        NULL,
        NULL,
        0
      )
    PRINT 'INSERTED  - 14100102.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID - 14100102 already EXISTS.'
END