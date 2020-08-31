IF  Exists(Select 1 FROM setup_menu where function_id = 20001100)
BEGIN
	UPDATE setup_menu SET display_name ='Re-Import Data'
	WHERE function_id = 20001100 
END

