-- Removed deprecated column from New Framework.

IF COL_LENGTH('application_functions', 'function_call') IS NOT NULL
BEGIN
    ALTER TABLE application_functions DROP COLUMN function_call
END
ELSE PRINT '''function_call'' column does not exists in application_functions table.'
GO

IF COL_LENGTH('setup_menu', 'window_name') IS NOT NULL
BEGIN
    ALTER TABLE setup_menu DROP COLUMN window_name
END
ELSE PRINT '''window_name'' column does not exists in setup_menu table.'
GO

IF COL_LENGTH('favourites_menu', 'window_name') IS NOT NULL
BEGIN
    ALTER TABLE favourites_menu DROP COLUMN window_name
END
ELSE PRINT '''window_name'' column does not exists in favourites_menu table.'
GO

IF COL_LENGTH('user_application_log', 'instance_name') IS NOT NULL
BEGIN
    ALTER TABLE user_application_log DROP COLUMN instance_name
END
ELSE PRINT '''instance_name'' column does not exists in user_application_log table.'
GO
