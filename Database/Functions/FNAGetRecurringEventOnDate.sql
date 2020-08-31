IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].FNAGetRecurringEventOnDate') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[FNAGetRecurringEventOnDate]
GO 

CREATE FUNCTION FNAGetRecurringEventOnDate( 
   @today_date DATETIME
) 
RETURNS @list TABLE (item VARCHAR(MAX)) 
AS 
BEGIN
	DECLARE @event_id INT, @rec_type VARCHAR(100), @start_date DATETIME, @end_date DATETIME

	DECLARE event_cursor CURSOR FOR
		SELECT calendar_event_id, ce.rec_type, ce.start_date, ce.end_date
		FROM calendar_events ce
		WHERE ce.rec_type <> ''
		AND CONVERT(VARCHAR(10),ce.start_date, 120) <= @today_date
		AND CONVERT(VARCHAR(10),ce.end_date-1, 120) >= @today_date
	OPEN event_cursor
	FETCH NEXT FROM event_cursor INTO @event_id, @rec_type, @start_date, @end_date
	WHILE @@FETCH_STATUS = 0   
	BEGIN
		IF @rec_type IS NOT NULL
		BEGIN
			SET @rec_type = SUBSTRING(@rec_type, 0, CHARINDEX('#',@rec_type))

			DECLARE @type VARCHAR(10), @count INT, @days VARCHAR(30), @day INT, @count2 INT, @is_exists INT = 0
			SELECT @type = clm1, @count = clm2, @day = clm3, @count2 = clm4, @days = clm5 FROM dbo.FNASplitAndTranspose(@rec_type, '_')

			IF @type = 'day'
			BEGIN
				WHILE CONVERT(VARCHAR(10),DATEADD(DAY, @count, @start_date), 120) <= @end_date AND @is_exists = 0
				BEGIN
					IF CONVERT(VARCHAR(10),@start_date,120) = @today_date
					BEGIN
						SET @is_exists = 1
						INSERT INTO @list(item) VALUES(@event_id)
					END
			
					SET @start_date = CONVERT(VARCHAR(10),DATEADD(DAY, @count, @start_date), 120)
				END
			END
			ELSE IF @type = 'week' -- week_2___1,2,3,4,5#
			BEGIN
				IF CHARINDEX(CAST(DATEPART(dw,@today_date) - 1 AS VARCHAR(10)), @days) > 0
				BEGIN
					DECLARE @week_count INT = 1

					SET @start_date = CONVERT(VARCHAR(10), @start_date, 120)
					WHILE @start_date <= @end_date AND @is_exists = 0
					BEGIN
						IF CHARINDEX(CAST(DATEPART(dw,@start_date) - 1 AS VARCHAR(10)), @days) > 0
						BEGIN
							IF CONVERT(VARCHAR(10), @start_date, 120) = @today_date AND (@week_count % @count != 0 OR @count = 1)
							BEGIN
								SET @is_exists = 1
								INSERT INTO @list(item) VALUES(@event_id)
							END
						END
				
						IF DATEPART(dw,@start_date) - 1 = 5
							SET @week_count += 1

						SET @start_date = DATEADD(DAY, 1, @start_date)
					END
				END
			END
			ELSE IF @type = 'month' -- month_1_1_2_#  month_2___#no
			BEGIN
				SET @start_date = CONVERT(VARCHAR(10), @start_date, 120)
			
				WHILE @start_date <= @end_date AND @is_exists = 0
				BEGIN
					IF @today_date = @start_date
					BEGIN
						SET @is_exists = 1
						INSERT INTO @list(item) VALUES(@event_id)
					END
					ELSE IF DATEPART(MONTH,@today_date) = DATEPART(MONTH,@start_date) AND DATEPART(dw,@today_date) - 1 = @day AND dbo.FNAGetNthWeekDayofMonth(@start_date,@day+1,@count2) = @today_date
					BEGIN
						SET @is_exists = 1
						INSERT INTO @list(item) VALUES(@event_id)
					END
					ELSE
						SET @start_date = DATEADD(MONTH, @count, @start_date)
				END
			END
		END
		FETCH NEXT FROM event_cursor INTO @event_id, @rec_type, @start_date, @end_date
	END
	CLOSE event_cursor   
	DEALLOCATE event_cursor

	RETURN
END