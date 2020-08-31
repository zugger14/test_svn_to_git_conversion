
/****** Object:  UserDefinedFunction [dbo].[FNAChangeDateFormat]    Script Date: 1/15/2015 11:13:26 AM ******/
--author- pamatya@pioneersolutionsglobal.com
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'FNAChangeDateFormat', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAChangeDateFormat]
GO

--This function returns the date in standard format defined in the region table
--Each user will be assigned a region and hence date format
--select dbo.FNAChangeDateFormat()
CREATE FUNCTION [dbo].[FNAChangeDateFormat]()  
RETURNS VARCHAR(10)  
AS  
BEGIN  
		DECLARE @FNADate VARCHAR(100)
		DECLARE @region_id INT

		SELECT @region_id= region_id
		FROM   application_users
		WHERE  user_login_id = dbo.FNADBUser()
      	


		SELECT @FNADate = REPLACE(REPLACE(REPLACE(date_format, 'yyyy', '%Y'), 'dd', '%j'), 'mm', '%n')
		FROM   application_users au
		INNER JOIN region r ON  au.region_id = r.region_id
		WHERE  au.user_login_id = dbo.FNADBUser()
		
	RETURN @FNADate  
END  
