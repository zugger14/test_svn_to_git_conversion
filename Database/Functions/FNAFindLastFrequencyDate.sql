/****************************************************************************************/
/* Author      : Vishwas Khanal															 */
/* Date		   : 04.Feb.2009															 */
/* Description : Given a start date and end date with the frequency, it finds the first	 */
/*			   : date of the last frequency within the given period.					 */
/* Purpose     : TRM Demo																 */
/*****************************************************************************************/

IF OBJECT_ID ('dbo.FNAFindLastFrequencyDate','FN') IS NOT NULL
 DROP FUNCTION dbo.FNAFindLastFrequencyDate
GO
CREATE FUNCTION dbo.FNAFindLastFrequencyDate
(
@term_start					DATETIME		,
@term_end					DATETIME		,
@frequency					VARCHAR(1)		
)
RETURNS DATETIME
AS
BEGIN

	-- 'd' :	Daily -  Done
	-- 'w' :	Weely 			
	-- 'm' :	Monthly - Done
	-- 'q' :	Quaterly 
	-- 's' :	Semi Anually (Half Yearly)			
	-- 'a' :	Anually			

	DECLARE @returnDate DATETIME
	DECLARE @startMonth INT
	DECLARE @startYear  INT
	DECLARE @date_tmp	VARCHAR(10)
	DECLARE @endMonth INT
	DECLARE @endYear  INT
	DECLARE @month INT
	DECLARE @year  INT
	DECLARE @lastDate INT

	SELECT @startMonth = DATEPART(mm,@term_start)
	SELECT @startYear = DATEPART(yy,@term_start)
	SELECT @endMonth = DATEPART(mm,@term_end)
	SELECT @endYear = DATEPART(yy,@term_end)
	

	IF @frequency = 'd'
	BEGIN
		SELECT @returnDate = @term_end
	END
	ELSE IF @frequency = 'm'
	BEGIN
		SELECT @date_tmp = CAST(@endMonth AS VARCHAR)+ '/' + '01' + '/' + CAST(@endYear AS VARCHAR)
		SELECT @returndate = CONVERT(DATETIME,@date_tmp)
	END	
	ELSE IF @frequency = 'w'
	BEGIN
		DECLARE @d INT	
		DECLARE @flag CHAR(1)
		DECLARE @tmp INT
		SELECT @d = DATEPART(dd,@term_start)
		SELECT @month = @startMonth
		SELECT @year = @startYear	
		SELECT @flag = 'n'
		
		WHILE (@year < = @endYear)
		BEGIN

			IF ((@year = @endYear) AND (@month=@endMonth))
			BEGIN
				SELECT @flag = 'y'
				SELECT @lastDate = DATEPART(dd,@term_end)
			END
			ELSE
			BEGIN
				SELECT @date_tmp = CAST(@month AS VARCHAR)+ '/01/' + CAST(@year AS VARCHAR)
				SELECT @lastDate = DATEPART(dd,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@date_tmp)+1,0)))
			END	

			WHILE (@d < = @lastDate)	
			BEGIN
				SELECT @tmp = @d
				SELECT @d = @d + 7
				IF ((@d > @lastDate) AND (@flag = 'n'))
				BEGIN
					
					SELECT @d = @d - @lastDate
					SELECT @month = @month + 1
					IF @month > 12
					BEGIN
						SELECT @month = @month - 12
						SELECT @year = @year + 1
					END
					BREAK -- break the loop WHILE (@d < = @lastDate)
				END
									
			END		
			IF (@flag = 'y')
			BEGIN
				IF @d < = 7
					SELECT @month = @month - 1

				SELECT @d = @tmp
				BREAK -- break the loop WHILE (@year < = @endYear)
			END
		
		END

		SELECT @date_tmp = CAST(@month AS VARCHAR)+ '/' + CAST(@d AS VARCHAR) + '/' + CAST(@year AS VARCHAR)

		SELECT @returndate = CONVERT(DATETIME,@date_tmp)
	END -- ELSE IF @frequency = 'w'
	ELSE
	BEGIN
		DECLARE @i INT
		IF @frequency = 'q' SELECT @i = 3
		IF @frequency = 's' SELECT @i = 6
		IF @frequency = 'a' SELECT @i = 12

		SELECT @month = @startMonth 
		SELECT @year = @startYear

		WHILE (@year < = @endYear)			
		BEGIN
			IF (@year = @endYear)
			BEGIN
				WHILE (@month < @endMonth-(@i-1))
				BEGIN
					SELECT @month = @month + @i								
				END
				BREAK
			END
			ELSE
			BEGIN
				SELECT @month = @month + @i			
				IF @month > 12
				BEGIN
					SELECT @month = @month -12
					SELECT @year = @year + 1					
				END				
			END
		END
								
		SELECT @date_tmp = CAST(@Month AS VARCHAR)+ '/' + '01' + '/' + CAST(@year AS VARCHAR)
		
		SELECT @returndate = CONVERT(DATETIME,@date_tmp)
	END -- IF @frequency = 'q'
	
	RETURN @returndate 
END

