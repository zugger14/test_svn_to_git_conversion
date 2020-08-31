If exists (select * from application_functions where function_id = 10183414)
Begin
	Update
	application_functions
	set
	function_name = 'Add/Save'
	where
	function_id = 10183414
End
