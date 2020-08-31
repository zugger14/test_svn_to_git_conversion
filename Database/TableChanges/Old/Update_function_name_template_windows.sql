UPDATE application_functions
SET    function_name     = 'Setup Deal Template'
WHERE  function_name     = 'Maintain Deal Template'

UPDATE setup_menu
SET    display_name     = 'Setup Deal Template'
WHERE  display_name     = 'Maintain Deal Template'

UPDATE application_functions
SET    function_name     = 'Setup Field Template'
WHERE  function_name     = 'Maintain Field Template'

UPDATE setup_menu
SET    display_name     = 'Setup Field Template'
WHERE  display_name     = 'Maintain Field Template'

UPDATE application_functions
SET    function_name     = 'Setup UDF Template'
WHERE  function_name     = 'Maintain UDF Template'

UPDATE setup_menu
SET    display_name     = 'Setup UDF Template'
WHERE  display_name     = 'Maintain UDF Template'