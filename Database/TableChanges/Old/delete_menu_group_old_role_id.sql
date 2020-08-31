DELETE menu_group
FROM menu_group mg
LEFT JOIN application_security_role asr ON mg.role_id = asr.role_id
WHERE asr.role_id IS NULL





	
