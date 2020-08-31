IF OBJECT_ID(N'FNAContractMonthFormat', N'FN') IS NOT NULL
DROP FUNCTION [dbo].[FNAContractMonthFormat]
 GO 


-- select dbo.FNAContractMonthFormat('2003-1-31')
-- This function converst a datatime to ADIHA contract month format 'mm-yyyy'
-- Inpute is SQL datatime...
-- Input is a SQl Date variable
--DROP FUNCTION FNAContractMonthFormat
CREATE FUNCTION [dbo].[FNAContractMonthFormat]
(
	@DATE DATETIME
)
RETURNS VARCHAR(50)
AS
BEGIN
	Declare @FNAContractMonthFormat As Varchar(50)
	DECLARE @monthI Int

	SET @monthI = MONTH(@DATE)

	--changed to make the yyyy-mm format
	Set @FNAContractMonthFormat = CAST(Year(@DATE) As Varchar)  + '-' + 
					CASE WHEN (@monthI < 10) then '0' else '' end + 
						(CAST(Month(@DATE) As Varchar))
						
-- 	Set @FNAContractMonthFormat = CASE WHEN (@monthI < 10) then '0' else '' end + 
-- 						(CAST(Month(@DATE) As Varchar) +
-- 						'-'+ CAST(Year(@DATE) As Varchar) )
	
	RETURN(@FNAContractMonthFormat)
END














