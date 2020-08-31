IF OBJECT_ID(N'FNAGetGenericDate', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGetGenericDate]
GO

--This function returns the date in standard format defined in the region table
--Each user will be assigned a region and hence date format
--select dbo.FNAGetGenericDate('2003-1-31')
CREATE FUNCTION [dbo].[FNAGetGenericDate]
(
	@std_date       DATETIME,
	@user_login_id  VARCHAR(50)
)  
RETURNS VARCHAR(10)  
AS  
BEGIN  
	DECLARE @FNAGetGenericDate varchar(10)
	DECLARE @region_id INT
	
	SELECT @region_id = region_id
	FROM   application_users
	WHERE  user_login_id = @user_login_id  
      
	SET @FNAGetGenericDate = CASE ISNULL(@region_id, -1)
	                                 WHEN 1 THEN CONVERT(VARCHAR(10), @std_date, 101)
	                                 WHEN 3 THEN CONVERT(VARCHAR(10), @std_date, 110)
	                                 WHEN 2 THEN CONVERT(VARCHAR(10), @std_date, 103)
	                                 WHEN 5 THEN CONVERT(VARCHAR(10), @std_date, 104)
	                                 WHEN 4 THEN CONVERT(VARCHAR(10), @std_date, 105)
	                                 --for Reporting Framework demo. SSRS reports run under Windows Auth, so region id is NULL.
	                                 WHEN -1 THEN CONVERT(VARCHAR(10), @std_date, 101)
	                                 ELSE CONVERT(VARCHAR(10), @std_date, 120)
	                            END


	RETURN @FNAGetGenericDate  
END  