/****** Object:  UserDefinedFunction [dbo].[FNARWeekDaysInMnth]    Script Date: 05/02/2011 11:25:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNARWeekDaysInMnth]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARWeekDaysInMnth]
GO
/****** Object:  UserDefinedFunction [dbo].[FNARWeekDaysInMnth]    Script Date: 05/02/2011 11:25:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =================================================================================================
-- Modified date: 2014-02-11 12:12PM
-- Description:	Returns numbers of business days in a month of given prod date excluding holiday 
--				determined by calendar mapped in given contract.
--				Previous logic has been commented and is available at the end.
-- Params:
--	@prod_date DATETIME: Production Date
--	@contract_id INT: Contract ID
-- Returns:		INT Number of business days
-- =================================================================================================
CREATE FUNCTION [dbo].[FNARWeekDaysInMnth](
	@prod_date DATETIME,
	@contract_id INT
)
RETURNS TINYINT AS

/***TEST DATA

DECLARE @prod_date DATETIME = '2012-9-1'
DECLARE @contract_id INT = 726
--***/

BEGIN
	DECLARE @first_day_of_month DATETIME
	DECLARE @num_days TINYINT = 0
	SET @first_day_of_month = CAST(CAST(YEAR(@prod_date) AS VARCHAR) +'-'+ CAST(MONTH(@prod_date) AS VARCHAR) + '-01' AS DATETIME)

	SELECT @num_days = COUNT(1)
	FROM dbo.seq s
	CROSS APPLY (SELECT DATEADD(DAY, n - 1, @first_day_of_month) derived_date ) dd		--derive every date for that month
	WHERE n <= 32																		--reduce the search to max of a month days
		AND MONTH(dd.derived_date) = MONTH(@first_day_of_month)							--reduce search to same month only
		AND DATEPART(dw, dd.derived_date) NOT IN (1, 7)									--exclude weekend. Make sure @@DATEFIRST returns 7
		AND NOT EXISTS (SELECT 1 FROM holiday_group hg									--exclude holiday	
						INNER JOIN contract_group cg ON cg.holiday_calendar_id = hg.hol_group_value_id
		                WHERE cg.contract_id = @contract_id
							AND hg.hol_date = DATEADD(DAY, n - 1, @first_day_of_month))
	
	--SELECT @num_days
	RETURN @num_days
	
	/*OLD LOGIC
	DECLARE @numdays int,@weekdays int,@new_date datetime
	set @weekdays=0
	set @new_date=@prod_date

	set @numdays=day(dateadd(month,1,dbo.fnagetcontractmonth(@prod_date))-1)

	while @numdays>=1
		begin
			
			select @weekdays=@weekdays+1
				from hourly_block hb inner join
					 contract_group cg on cg.hourly_block=hb.block_value_id
			where
				cg.contract_id=@contract_id
				and datepart(dw,@new_date)=week_day	and week_day in(2,3,4,5,6)
				and onpeak_offpeak='o'
				and @new_date not  in(select hol_date from holiday_group where hol_date=@new_date)
		
			set @new_date=dateadd(day,1,@new_date)
			set @numdays=@numdays-1
		end
	return @weekdays
	--return @new_date
	*/
END





