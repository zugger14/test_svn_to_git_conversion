/****** Object:  View [dbo].[application_functions_trm]    Script Date: 08/04/2010 12:35:48 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[application_functions_trm]'))
DROP VIEW [dbo].[application_functions_trm]
GO

/****** Object:  View [dbo].[application_functions_trm]    Script Date: 08/04/2010 12:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[application_functions_trm]
AS
WITH List (function_id,function_path,function_ref_id,Lvl, display_name)
AS
(
	SELECT a.function_id,CONVERT(VARCHAR(8000),a.function_name) ,func_ref_id,1 as Lvl, CONVERT(VARCHAR(8000),a.function_name)
	FROM application_functions a WHERE function_id = 10000000
	UNION all
	SELECT a.function_id,function_path + '=>'+ CONVERT(VARCHAR(8000),a.function_name) ,func_ref_id,Lvl + 1,  CONVERT(VARCHAR(8000),a.function_name)
	FROM application_functions a 
	INNER JOIN List l ON  a.func_ref_id = l.function_id 
)
SELECT function_id,function_path,Lvl 'Depth', display_name FROM List 
WHERE Lvl > 1 

