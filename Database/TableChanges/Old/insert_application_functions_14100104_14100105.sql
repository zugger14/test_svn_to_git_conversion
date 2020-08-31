IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 14100104
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
        14100104,
        'Add/Save',
        'Add/Save',
        14100103,
        NULL,
        NULL,
        NULL,
        0
      )
    PRINT 'INSERTED  - 14100104.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID - 14100104 already EXISTS.'
END

IF NOT EXISTS(
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 14100105
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
        14100105,
        'Delete',
        'Delete',
        14100103,
        NULL,
        NULL,
        NULL,
        0
      )
    PRINT 'INSERTED  - 14100105.'
END
ELSE
BEGIN
    PRINT 'Application FunctionID - 14100105 already EXISTS.'
END