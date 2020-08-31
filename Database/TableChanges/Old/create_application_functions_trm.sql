/* Author		:  Vishwas Khanal			  */
/* Description  :  Rebuilding Function ID	  */
/* Dated		:  20.05.2009				  */

--USE TRMTracker_function
--GO

IF OBJECT_ID ('application_functions_trm','V') IS NOT NULL
DROP VIEW dbo.application_functions_trm
GO
CREATE VIEW dbo.application_functions_trm
AS
WITH List (function_id,function_path,function_ref_id,Lvl)
AS
(
	SELECT a.function_id,CONVERT(VARCHAR(8000),a.function_name) ,func_ref_id,1 as Lvl 
	FROM application_functions a WHERE function_id = 10000000
	UNION all
	SELECT a.function_id,function_path + '=>'+ CONVERT(VARCHAR(8000),a.function_name) ,func_ref_id,Lvl + 1
	FROM application_functions a INNER JOIN List l ON  a.func_ref_id = l.function_id 
)
SELECT function_id,function_path,Lvl 'Depth' FROM List 
WHERE Lvl > 1 

