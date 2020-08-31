--- default_flag is used to make a tab active by default in UI, active_flag is used to show/hide tabs

UPDATE application_ui_template_group
SET default_flag = 'n'
WHERE default_flag IS NULL

UPDATE application_ui_template_group
SET default_flag = 'y'
WHERE active_flag = 'y'

UPDATE application_ui_template_group
SET active_flag = 'y'