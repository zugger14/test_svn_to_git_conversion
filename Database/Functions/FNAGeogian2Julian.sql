set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go
IF OBJECT_ID(N'FNAGeogian2Julian', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAGeogian2Julian]
GO

CREATE FUNCTION [dbo].[FNAGeogian2Julian] (@Geogian_in datetime)  

RETURNS int  AS  

BEGIN 
 declare @JulianDate_out as  INT
 declare @Century INT
 declare @YY int
 declare @DayofYear INT 


        Select @Century = case  when datepart(yyyy,@Geogian_in)> 2000 then 100000
                   else  0  end
 
 Select @YY =  CAST(  (SUBSTRING( CAST(DATEPART(YYYY, @Geogian_in) AS VARCHAR(4)), 3, 2))  AS INT) 

 select @DayOfYear =  datepart(dayofyear, @Geogian_in ) 
                   
 SELECT @JulianDate_out = @Century + @YY * 1000 + @DayofYear 
 
        RETURN(@JulianDate_out)

END



