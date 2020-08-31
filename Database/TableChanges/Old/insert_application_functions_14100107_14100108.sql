IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 14100107
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
        14100107,
        'Add/Save',
        'Add/Save',
        14100106,
        NULL,
        NULL,
        NULL,
        0
      )
    PRINT 'INSERTED  - 14100107.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID - 14100107 already EXISTS.'
END

IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 14100108
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
        14100108,
        'Delete',
        'Delete',
        14100106,
        NULL,
        NULL,
        NULL,
        0
      )
    PRINT 'INSERTED  - 14100108.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID - 14100108 already EXISTS.'
END