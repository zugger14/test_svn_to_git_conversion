
IF NOT EXISTS (
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 10101910
   )
BEGIN
    INSERT INTO application_functions
      (
        function_id,
        function_name,
        function_desc,
        func_ref_id
      )
    VALUES
      (
        10101910,
        'Add/Save',
        'Add/Save',
        10101900
      );
END

UPDATE application_functions
SET    function_name = 'Add/Save',
       function_desc = 'Add/Save',
       func_ref_id = 10101900
WHERE  function_id = 10101910

IF NOT EXISTS (
       SELECT 1
       FROM   application_functions
       WHERE  function_id = 10101911
   )
BEGIN
    INSERT INTO application_functions
      (
        function_id,
        function_name,
        function_desc,
        func_ref_id,
        book_required
      )
    SELECT 10101911,
           'Delete',
           'Delete',
           10101900,
           0
END

UPDATE application_functions
SET    function_name     = 'Delete',
       function_desc     = 'Delete',
       func_ref_id       = 10101900
WHERE  function_id       = 10101911