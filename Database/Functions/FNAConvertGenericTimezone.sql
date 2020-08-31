IF OBJECT_ID(N'FNAConvertGenericTimezone', N'FN') IS NOT NULL
DROP FUNCTION dbo.FNAConvertGenericTimezone
GO

  
CREATE FUNCTION [dbo].[FNAConvertGenericTimezone] (  
 @DATE AS DATETIME,  
 @time_zone_from INT=0,
 @time_zone_to INT=0,
 @user_login_id VARCHAR(30)=NULL,
 @date_format bit=0 --0=format return value is date format; else datetime format
)  
RETURNS VARCHAR(30)  
AS  
BEGIN  
  
 DECLARE @NEWDATE DATETIME  
 if @time_zone_from=@time_zone_to
	 SET @NEWDATE = @Date 
 ELSE
 BEGIN
 	
	 -- Find Out System Defined Time Zone  
	 IF isnull(@time_zone_from,0)=0
		 SELECT @time_zone_from= var_value  FROM adiha_default_codes_values  
		 WHERE  (instance_no = 1) AND (default_code_id = 36) AND (seq_no = 1)  
	  
	IF isnull(@time_zone_to,0)=0
		SELECT @time_zone_to=timezone_id from application_users where user_login_id=dbo.FNAdbuser()  
	  
	IF @time_zone_to IS NULL  
		SET @time_zone_to=@time_zone_from  
	  
	   
	  
	 -- Check to see if the provided timezone for the source datetime is in GMT or UTC time  
	 -- If it is not then convert the provided datetime to UTC time  
	IF @time_zone_from =14 --GMT
		SELECT @NEWDATE = dbo.FNAGetLOCALTime(dbo.FNAGetUTCTTime(@Date,@time_zone_from)  ,@time_zone_to)
	ELSE  
		SET @NEWDATE = @Date  
END  
 -- Return the new date that has been converted from UTC time  
 RETURN [dbo].FNAGetGenericDate(@NEWDATE,@user_login_id)+CASE WHEN @date_format=0 THEN '' ELSE CONVERT(varchar(8),@NEWDATE,108) end
END  
  
  
  