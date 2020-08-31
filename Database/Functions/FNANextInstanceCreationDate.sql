IF OBJECT_ID('dbo.FNANextInstanceCreationDate','fn') IS NOT NULL
DROP FUNCTION dbo.FNANextInstanceCreationDate
GO
/*
Author : Vishwas Khanal
Desc   : Compliance Renovation. This will output the next instance creation date for the activity.
		 It will skip the holidays and give the next available date.
Dated  : 09.July.2009
*/
CREATE FUNCTION dbo.FNANextInstanceCreationDate
(@activityid INT)
RETURNS DATETIME
--IF OBJECT_ID('dbo.FNANextInstanceCreationDatetmp','p') IS NOT NULL
--DROP PROCEDURE dbo.FNANextInstanceCreationDatetmp
--GO
--CREATE PROCEDURE dbo.FNANextInstanceCreationDatetmp
--@activityid INT
AS
BEGIN

	RETURN dbo.FNANextInstanceDate(@activityid,default,default)

END
/* The same logic was required with different set of parameters in spa_getCalendarData */
/*
	DECLARE								
			@workingdayId		INT, 
			@holiday			INT,
			@offDay				VARCHAR(100),			
			@frequency_type		CHAR(1),
			@day				INT,
			@run_frequency		INT,
			@run_effective_date DATETIME,
			@run_end_date		DATETIME,		
			@daysFrom			CHAR(1), -- 'b' : from start, e : from end
			@month				INT,
			@nextInstanceDate	DATETIME,
			@lastInstanceDate	DATETIME,
			@pos_LICD			INT, --Week Day position Of Last Instance Creation Date
			@nod				INT,
			@start_LICD			DATETIME,
			@end_LICD			DATETIME,
			@temp				DATETIME,
			@pos_temp			INT,
			@exists				CHAR(1),
			@day_LICD			INT,
			@endday_LICD		INT,
			@endday_NM			INT,
			@run_date			DATETIME
	-- Begin : Used on Holiday Calendar implementation--
		SELECT @offDay = ''	
		SELECT @workingdayId = working_days_value_id FROM dbo.process_risk_controls (nolock) WHERE risk_control_id = @activityid
		SELECT @holiday = holiday_calendar_value_id FROM dbo.process_risk_controls (nolock) WHERE risk_control_id = @activityid
		SELECT @offDay = @offDay + ',' + CAST(weekday AS VARCHAR) FROM working_days (nolock) WHERE  block_value_id = @workingdayId AND val = 0
	-- End  : Used on Holiday Calendar implementation--

	SELECT @exists = 'n'

	SELECT @nod = no_of_days ,
		   @daysFrom = days_start_from,
		   @run_frequency = run_frequency,
		   @run_effective_date = run_effective_date,
		   @run_end_date = run_end_date,
		   @frequency_type =frequency_type,
		   @run_date = run_date
		FROM process_risk_controls (nolock) WHERE risk_control_id = @activityid
	
	IF @daysFrom = 'e'
		SELECT @nod = @nod - 1 

	IF @frequency_type = 'o'
	BEGIN
		IF EXISTS (SELECT 'x' FROM process_risk_controls_activities WHERE risk_control_id = @activityid ) OR (@run_date < CAST(dbo.FNAGetSQLStandardDate(GETDATE()) AS DATETIME))			
			SELECT @nextInstanceDate = NULL 	
		ELSE
			SELECT @nextInstanceDate = run_date FROM process_risk_controls WHERE risk_control_id = @activityid	
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT 'x' FROM dbo.process_risk_controls_activities WHERE risk_control_id = @activityid)
		BEGIN
			SELECT @lastInstanceDate = MAX(actualRunDate)
				FROM dbo.process_risk_controls_activities (nolock)
					WHERE risk_control_id = @activityid	
			SELECT @exists = 'y'
		END
		ELSE
		BEGIN
			IF @run_effective_date < GETDATE()
				SELECT @lastInstanceDate = dbo.FNAgetSQLStandardDate(GETDATE())
			ELSE 
				SELECT @lastInstanceDate = @run_effective_date
		END

		IF @run_frequency = 700 -- Daily
			BEGIN			
				SELECT @nextInstanceDate = 
					CASE @exists WHEN 'y' THEN DATEADD(dd,1,@lastInstanceDate) ELSE @lastInstanceDate END					
			END			
		IF @run_frequency = 701 -- Weekly
		BEGIN
			SELECT @pos_LICD = DATEPART(dw,@lastInstanceDate) 
			
			SELECT @start_LICD = DATEADD(dd,-@pos_LICD,@lastInstanceDate),@end_LICD = DATEADD(dd,7-@pos_LICD,@lastInstanceDate)

			IF @daysFrom = 'b'
			BEGIN
				SELECT @temp = @start_LICD + @nod

				SELECT @pos_temp = DATEPART(dw,@temp) 
				IF @pos_temp > @pos_LICD
					SELECT @nextInstanceDate = @temp
				ELSE IF @pos_temp < @pos_LICD
					SELECT @nextInstanceDate = DATEADD(dd,@nod,@end_LICD)
				ELSE  --IF @pos_temp = @pos_LICD
				BEGIN
					IF @exists = 'y'
						SELECT @nextInstanceDate = DATEADD(dd,@nod,@end_LICD)
					ELSE				
						SELECT @nextInstanceDate = @temp
				END	
			END
			ELSE
			BEGIN
				SELECT @temp = @end_LICD - @nod 

				SELECT @pos_temp = DATEPART(dw,@temp) 

				
				IF @pos_temp>@pos_LICD
					SELECT @nextInstanceDate = @temp
				ELSE IF @pos_temp<@pos_LICD
					SELECT @nextInstanceDate = DATEADD(dd,7-@nod,@end_LICD)
				ELSE --IF @pos_temp = @pos_LICD
				BEGIN
					IF @exists = 'y'
						SELECT @nextInstanceDate = DATEADD(dd,7-@nod,@end_LICD)
					ELSE
						SELECT @nextInstanceDate = @temp				
				END
			END															
		END	
		ELSE IF @run_frequency = 703 -- Monthly
		BEGIN

			SELECT @day_LICD = DATEPART(dd,@lastInstanceDate) 

			IF @daysFrom = 'b'
			BEGIN				
				SELECT @temp = DATEADD(mm,1,@lastInstanceDate)

				SELECT @temp = DATEADD(dd,@nod-1,CAST(DATEPART(yy,@temp) AS VARCHAR)+'-'+CAST(DATEPART(mm,@temp) AS VARCHAR)+'-01')

				IF @day_LICD = @nod
				BEGIN
					IF @exists = 'y'						
						SELECT @nextInstanceDate = @temp
					ELSE
						SELECT @nextInstanceDate = @lastInstanceDate
				END
				ELSE IF @day_LICD > @nod
				BEGIN
					SELECT @nextInstanceDate = @temp
				END
				ELSE IF @day_LICD < @nod
				BEGIN
					SELECT @nextInstanceDate = CAST(DATEPART(yy,@lastInstanceDate) AS VARCHAR)+'-'+ CAST(DATEPART(mm,@lastInstanceDate) AS VARCHAR)+'-'+ CAST(@nod AS VARCHAR)
				END
			END
			ELSE
			BEGIN
				
				SELECT @endday_LICD =  DATEPART(dd,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@lastInstanceDate)+1,0)))
				SELECT @day = @endday_LICD - @nod
							
				SELECT @endday_NM= DATEPART(dd,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,DATEADD(m,1,@lastInstanceDate))+1,0)))
				SELECT @temp = DATEADD(mm,1,@lastInstanceDate)
				SELECT @temp = CAST(DATEPART(yy,@temp) AS VARCHAR)+'-'+CAST(DATEPART(mm,@temp) AS VARCHAR)+'-'+CAST(@endday_NM AS VARCHAR)								

				IF @day_LICD = @day
				BEGIN
					IF @exists = 'y'
					BEGIN
						SELECT @nextInstanceDate = DATEADD(dd,-@nod,@temp)
					END	
					ELSE
						SELECT @nextInstanceDate = @lastInstanceDate									
				END	
				ELSE IF @day_LICD > @day			
					SELECT @nextInstanceDate = DATEADD(dd,-@nod,@temp)
				ELSE
					SELECT @nextInstanceDate = CAST(DATEPART(yy,@lastInstanceDate) AS VARCHAR)+'-'+CAST(DATEPART(mm,@lastInstanceDate) AS VARCHAR)+'-'+CAST(@day AS VARCHAR)			
			END
		END
		ELSE IF @run_frequency IN (704,705,706) -- Quaterly,SemiAnually,Anually
		BEGIN
--			SELECT @temp = 
--					CASE  @daysFrom WHEN 'b' THEN
--						DATEADD(dd,@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-01-01' AS DATETIME))
--					ELSE
--						DATEADD(dd,-@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-12-31' AS DATETIME))
--					END

			SELECT @month = DATEPART(mm,@lastInstanceDate)
			
			SELECT @temp = 
					CASE @run_frequency 
						WHEN 706 THEN -- Anually
							CASE  @daysFrom WHEN 'b' THEN
								DATEADD(dd,@nod-1,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-01-01' AS DATETIME))
							ELSE
								DATEADD(dd,-@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-12-31' AS DATETIME))
						END
						WHEN 704 THEN -- Quaterly
							CASE  WHEN @month IN (1,2,3) THEN 
								CASE  @daysFrom WHEN 'b' THEN
									DATEADD(dd,@nod-1,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-01-01' AS DATETIME))
										ELSE
											DATEADD(dd,-@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-03-31' AS DATETIME)) END
								 WHEN @month IN (4,5,6) THEN 
									CASE  @daysFrom WHEN 'b' THEN
										DATEADD(dd,@nod-1,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-04-01' AS DATETIME))
											ELSE
												DATEADD(dd,-@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-06-30' AS DATETIME)) END
								 WHEN @month IN (7,8,9) THEN 
									CASE  @daysFrom WHEN 'b' THEN
										DATEADD(dd,@nod-1,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-07-01' AS DATETIME))
											ELSE
												DATEADD(dd,-@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-09-30' AS DATETIME)) END
								ELSE
									CASE  @daysFrom WHEN 'b' THEN
										DATEADD(dd,@nod-1,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-10-01' AS DATETIME))
											ELSE
												DATEADD(dd,-@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-12-31' AS DATETIME)) END
						END		
						WHEN 705 THEN -- SemiAnually
							CASE  WHEN @month IN (1,2,3,4,5,6) THEN 
								CASE  @daysFrom WHEN 'b' THEN
									DATEADD(dd,@nod-1,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-01-01' AS DATETIME))
										ELSE
											DATEADD(dd,-@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-06-30' AS DATETIME)) END
								 WHEN @month IN (7,8,9,10,11,12) THEN 
									CASE  @daysFrom WHEN 'b' THEN
										DATEADD(dd,@nod-1,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-07-01' AS DATETIME))
											ELSE
												DATEADD(dd,-@nod,CAST(CAST(DATEPART(yy,@lastInstanceDate) as varchar)+'-12-31' AS DATETIME)) END
						END

					END			

			IF @temp > @lastInstanceDate
				SELECT @nextInstanceDate = @temp	
			ELSE
			BEGIN
				IF @temp = @lastInstanceDate				
							SELECT @nextInstanceDate =  
								CASE @exists WHEN 'y' THEN 
									CASE @run_frequency  
										WHEN 706 THEN  DATEADD(yy,1,@temp) 
										WHEN 705 THEN  DATEADD(qq,2,@temp) 
										WHEN 704 THEN  DATEADD(qq,1,@temp) 
									END
								ELSE @temp END 
				ELSE
							SELECT @nextInstanceDate = 
								CASE @run_frequency  
										WHEN 706 THEN  DATEADD(yy,1,@temp) 
										WHEN 705 THEN  DATEADD(qq,2,@temp) 
										WHEN 704 THEN  DATEADD(qq,1,@temp) 
									END						

				SELECT @month = DATEPART(mm,@nextInstanceDate)

				SELECT @nextInstanceDate = 									
					CASE @run_frequency 
						WHEN 706 THEN -- Anually
							CASE @daysFrom WHEN 'b' THEN
									CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-01-01' AS DATETIME)
								ELSE
									CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-12-31' AS DATETIME)
							END
						WHEN 705 THEN -- Semi Anually
							CASE WHEN @month IN (1,2,3,4,5,6) THEN
								CASE @daysFrom WHEN 'b' THEN
										CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-01-01' AS DATETIME)
									ELSE
										CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-06-30' AS DATETIME)
								END
							ELSE
								CASE @daysFrom WHEN 'b' THEN
										CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-07-01' AS DATETIME)
									ELSE
										CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-12-31' AS DATETIME)
								END
							END					
						WHEN 704 THEN -- Quaterly
							CASE  WHEN @month IN (1,2,3) THEN
								CASE @daysFrom WHEN 'b'THEN
										CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-01-01' AS DATETIME)
									ELSE
										CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-03-31' AS DATETIME)
								END
								WHEN @month IN (4,5,6) THEN
									CASE @daysFrom WHEN 'b' THEN
											CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-04-01' AS DATETIME)
										ELSE
											CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-06-30' AS DATETIME)
									END					
								WHEN @month IN (7,8,9) THEN
									CASE @daysFrom WHEN 'b' THEN
											CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-07-01' AS DATETIME)
										ELSE
											CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-09-30' AS DATETIME)
									END					
								ELSE
									CASE @daysFrom WHEN 'b' THEN
										CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-10-01' AS DATETIME)
									ELSE
										CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR) +'-12-31' AS DATETIME)
								END	
							END				
					END							

					IF @daysFrom = 'e'
						SELECT @nextInstanceDate = DATEADD(dd,-@nod,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@nextInstanceDate)+1,0)))
					ELSE
						SELECT @nextInstanceDate = DATEADD(dd,@nod-1,CAST(CAST(DATEPART(yy,@nextInstanceDate) AS VARCHAR)+'-'+CAST(DATEPART(mm,@nextInstanceDate) AS VARCHAR) +'-01' AS DATETIME))
			END
		END
	END
	


					------------------------- Implementation of Holiday Calendar  --------------------------------------	
	IF @nextInstanceDate IS NOT NULL
	BEGIN
		IF CHARINDEX(',',@offDay)>0
			SELECT @offDay = SUBSTRING(@offDay,1,LEN(@offDay))	
		

		IF @frequency_type = 'o'
		BEGIN
			IF (DATEPART(dw,@nextInstanceDate) IN (SELECT item FROM dbo.splitCommaSeperatedValues(@offDay))) OR 
				(EXISTS (SELECT 'x' FROM dbo.holiday_group (nolock) WHERE @nextInstanceDate BETWEEN hol_date AND ISNULL(exp_date,hol_date) AND
						hol_group_value_id = @holiday))						
				SELECT @nextInstanceDate = NULL 	
		END
		BEGIN
		WHILE(1=1)
			BEGIN		
				IF (DATEPART(dw,@nextInstanceDate) IN (SELECT item FROM dbo.splitCommaSeperatedValues(@offDay)))
				OR (EXISTS (SELECT 'x' FROM dbo.holiday_group (nolock) WHERE @nextInstanceDate BETWEEN hol_date AND ISNULL(exp_date,hol_date) AND
						hol_group_value_id = @holiday))		
				BEGIN


	--				IF @daysFrom = 'e'
	--					SELECT @nextInstanceDate = DATEADD(dd,-1,@nextInstanceDate)		
	--				ELSE
						SELECT @nextInstanceDate = DATEADD(dd,1,@nextInstanceDate)		
				END
				ELSE
					BREAK		
			END
		END


		-- If the next Instance Creation date doesn't fall between its effective range, return NULL.		
		IF @frequency_type <> 'o' AND (@nextInstanceDate NOT BETWEEN @run_effective_date AND @run_end_date ) 
		SELECT  @nextInstanceDate  = NULL 					

	END
--	SELECT @nextInstanceDate		
	RETURN @nextInstanceDate		
END*/