IF OBJECT_ID('dbo.FNAApplicationFunctionsHierarchy') IS NOT NULL
DROP FUNCTION dbo.FNAApplicationFunctionsHierarchy
GO

CREATE FUNCTION dbo.FNAApplicationFunctionsHierarchy
(@product_id AS INT)
RETURNS @application_functions_hierarchy TABLE 
(
    function_id INT,
    function_path NVARCHAR(4000) ,
    depth INT,
    display_name NVARCHAR(200)  
)
AS
BEGIN
	DECLARE @collect_function_id TABLE(
			function_id INT NOT NULL,
			function_name NVARCHAR(1000)  ,
			reference_id INT)
    
	INSERT INTO @collect_function_id(function_id,function_name,reference_id)
	SELECT function_id, display_name, parent_menu_id FROM setup_menu WHERE product_category = @product_id
	UNION
	SELECT af.function_id,function_name,func_ref_id FROM application_functions af
	LEFT JOIN setup_menu sm on sm.function_id = af.function_id
	WHERE sm.function_id is null

	;WITH List (function_id, function_path, function_ref_id, Lvl, display_name)
	AS
	(
		SELECT a.function_id,CONVERT(NVARCHAR(4000),a.function_name) ,reference_id,1 AS Lvl , CONVERT(NVARCHAR(4000),a.function_name)
		FROM @collect_function_id a WHERE function_id = @product_id
		UNION all
		SELECT a.function_id,function_path + '=>'+ CONVERT(NVARCHAR(4000),a.function_name) ,reference_id,Lvl + 1,  CONVERT(NVARCHAR(4000),a.function_name)
		FROM @collect_function_id a INNER JOIN List l ON  a.reference_id = l.function_id 
	)
	INSERT @application_functions_hierarchy(function_id, function_path, depth, display_name)
	SELECT function_id,function_path,Lvl, display_name FROM List 
	WHERE Lvl > 1 
	RETURN
END





