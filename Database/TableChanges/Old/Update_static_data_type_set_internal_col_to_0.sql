--select * from static_data_type where type_id in (10098,11099,11100,11101,11102,10083,10084,10096,10097,10097)
--select * from application_ui_template_definition where application_function_id=10101122

UPDATE static_data_type 
SET internal=0 
WHERE type_id IN (10098,11099,11100,11101,11102,10083,10084,10096,10097)