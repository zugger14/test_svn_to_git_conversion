

--SELECT [dbo].[FNAStdDate]('7/1/2004')

--select dbo.Curve('3/1/2004', 4500, '7/1/2004', 1)
--select dbo.Curve('4/1/2004', 4500, '7/1/2004', 1)
IF OBJECT_ID('[dbo].[FNAStdDate]') IS NOT NULL
DROP FUNCTION [dbo].[FNAStdDate]
go
CREATE  FUNCTION [dbo].[FNAStdDate] (@as_of_date VARCHAR(30))
RETURNS DATETIME AS  
BEGIN 
DECLARE @ret DATETIME
SELECT  @ret=
	  CONVERT(DATETIME ,@as_of_date, CASE WHEN region_id =1 OR  region_id =3 THEN  101
		WHEN region_id =2 OR region_id =4  OR region_id =5 THEN  105 END)
		FROM dbo.application_users where user_login_id= dbo.FNADBUser()

	return @ret
END




