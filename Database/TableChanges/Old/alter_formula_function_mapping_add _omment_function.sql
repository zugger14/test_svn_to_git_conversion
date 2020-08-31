 IF COL_LENGTH('formula_function_mapping', 'comment_function') IS NULL
BEGIN
	 alter  TABLE [dbo].formula_function_mapping add comment_function VARCHAR(1) 

end

 IF COL_LENGTH('formula_function_mapping', 'arg13') IS NULL
BEGIN
	alter  TABLE [dbo].formula_function_mapping add arg13 VARCHAR(3000) NULL
	alter  TABLE [dbo].formula_function_mapping add arg14 VARCHAR(3000) NULL
	alter  TABLE [dbo].formula_function_mapping add arg15 VARCHAR(3000) NULL
	alter  TABLE [dbo].formula_function_mapping add arg16 VARCHAR(3000) NULL
	alter  TABLE [dbo].formula_function_mapping add arg17 VARCHAR(3000) NULL
	alter  TABLE [dbo].formula_function_mapping add arg18 VARCHAR(3000) NULL
end

