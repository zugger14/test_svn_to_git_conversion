IF EXISTS (
       SELECT 1
       FROM   application_functions af
       WHERE  af.function_id = 10232310
   )
BEGIN
    IF EXISTS (
           SELECT 1
           FROM   application_functional_users afu
           WHERE  afu.function_id = 10232310
       )
    BEGIN
        UPDATE application_functional_users
        SET    function_id = 10232410
        WHERE  function_id = 10232310
    END
    
    DELETE 
    FROM   application_functions
    WHERE  function_id = 10232310
END