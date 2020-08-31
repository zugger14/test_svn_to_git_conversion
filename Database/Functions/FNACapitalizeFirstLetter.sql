SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].FNACapitalizeFirstLetter', N'FN') IS NOT NULL 
	DROP FUNCTION [dbo].FNACapitalizeFirstLetter
GO

/**
	Makes first letter of a string capital.

	Parameters
	@string	:	String whose first letter is to be capitalized.
*/

CREATE FUNCTION [dbo].[FNACapitalizeFirstLetter]
(
	@string NVARCHAR(2000) -- Sring to convert
)
RETURNS NVARCHAR(2000)
AS

BEGIN
	DECLARE @Index INT,
			@ResultString NVARCHAR(2000)
	
	SET @Index = 1
	SET @ResultString = ''
		
	WHILE (@Index <LEN(@string)+1)
	BEGIN
		IF (@Index = 1)--first letter of the string
		BEGIN
			--make the first letter capital
			SET @ResultString = @ResultString + UPPER(SUBSTRING(@string, @Index, 1))
			SET @Index = @Index+ 1
		END				
		ELSE IF ((SUBSTRING(@string, @Index-1, 1) =' 'or SUBSTRING(@string, @Index-1, 1) ='-' or SUBSTRING(@string, @Index+1, 1) ='-'))--and @Index+1 <> LEN(@string)) -- IF the previous character is space or '-' or next character is '-'
		BEGIN		
			SET @ResultString = @ResultString + UPPER(SUBSTRING(@string,@Index, 1))
			SET @Index = @Index +1
		END
		ELSE -- all others
		BEGIN
			-- make the letter simple
			SET @ResultString = @ResultString + LOWER(SUBSTRING(@string,@Index, 1))
			SET @Index = @Index +1--incerase the index
		END
	END--END of the loop
	
	IF (@@ERROR <> 0)-- any error occur return the sEND string
	BEGIN
		SET @ResultString = @string
	END
	-- IF no error found return the new string
	RETURN @ResultString
END



GO
