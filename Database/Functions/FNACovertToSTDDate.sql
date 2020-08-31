IF OBJECT_ID(N'FNACovertToSTDDate', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNACovertToSTDDate]
GO 
--This function returns the date in a regional format to standard sql format 'yyyy-mm-dd'
--select dbo.FNACovertToSTDDate('31/1/2003')
CREATE FUNCTION [dbo].[FNACovertToSTDDate]
(
	@aDate VARCHAR(20)
)
RETURNS Varchar(20)
AS
BEGIN
	DECLARE @format varchar(20)
	DECLARE @FNACovertToSTDDate varchar(50)
	DECLARE  @sqlDate DATETIME
	DECLARE @monthI Int
	DECLARE @dayI Int
	
	
	SELECT @format = date_format from APPLICATION_USERS AU INNER JOIN 
			REGION r ON r.region_id = AU.region_id AND AU.user_login_id = dbo.FNADBUser()
	
	--select @format
	set @sqlDate  = CASE 	
					WHEN (@format = 'mm/dd/yyyy') THEN
						convert(datetime, @aDate, 102)
					WHEN (@format = 'mm-dd-yyyy') THEN
						convert(datetime, @aDate, 110)
					WHEN (@format = 'dd/mm/yyyy') THEN
						convert(datetime, @aDate, 103)
					WHEN (@format = 'dd.mm.yyyy') THEN
						convert(datetime, @aDate, 104)
					WHEN (@format = 'dd-mm-yyyy') THEN
						convert(datetime, @aDate, 105)
					ELSE
						convert(datetime, '1/1/1900', 102)
				END

	
	
	SET @monthI = MONTH(@sqlDate)
	SET @dayI = DAY(@sqlDate)

	SET @FNACovertToSTDDate = 	CAST(Year(@sqlDate) As Varchar) +
					'-'+ CASE WHEN (@monthI < 10) then '0' else '' end + 
						CAST(@monthI As Varchar) +
					'-'+ CASE WHEN (@dayI < 10) then '0' else '' end + 
						CAST(@dayI As Varchar)	

--	select @FNACovertToSTDDate 	
	RETURN @FNACovertToSTDDate

END








