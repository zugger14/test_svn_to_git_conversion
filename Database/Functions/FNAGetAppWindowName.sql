/*
This function is used to replace logic of function_call column of application_functions and window_name column of setup_menu. 
These columns are in used in New Framework for creating window. So this window name should be unique for each form.
Single window for each form should be used when opened from main menu, recent menu, favorite menu. 
*/

IF OBJECT_ID('dbo.FNAGetAppWindowName') IS NOT NULL
DROP FUNCTION dbo.FNAGetAppWindowName
GO

CREATE FUNCTION [dbo].[FNAGetAppWindowName]()
RETURNS @items TABLE (function_id INT, window_name VARCHAR(20) NOT NULL)
AS
BEGIN
	
	INSERT INTO @items (function_id,window_name)
	SELECT function_id, 'win_' + CAST(function_id AS VARCHAR(8)) FROM application_functions WHERE file_path IS NOT NULL
	
	RETURN
END


