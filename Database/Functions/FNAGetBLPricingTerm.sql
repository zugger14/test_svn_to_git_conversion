IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAGetBLPricingTerm]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAGetBLPricingTerm]

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNAGetBLPricingTerm](
		@source_deal_detail_id INT  --if @source_deal_detail_id is +ve then BLPricing and -ve for Provisional Pricing
		,@call_from int=0 --1 for wacog price ,2=calendar date    and rest for other

) 
	RETURNS @price_dates TABLE 
(
	[curve_id] int,
	[term_start] datetime,
	maturity_date datetime
)
AS
BEGIN
	
	/* Test Data
	-- SELECT * from dbo.FNAGetBLPricingTerm(19,0)	
	--DROP TABLE #price_dates
	DECLARE @source_deal_detail_id INT, @as_of_date DATETIME,@call_from int=null
	SET @source_deal_detail_id = 44984
	--select * from source_deal_detail where source_deal_header_id=1964
	declare  @price_dates TABLE 
	(
		[curve_id] int,
		[term_start] datetime,maturity_date datetime
	)


	
	--*/
	DECLARE @curve_id INT, @from_date VARCHAR(10),@to_date VARCHAR(10),@term_start VARCHAR(10),@logical_name VARCHAR(100)
	,@generic_mapping_name VARCHAR(100),@pricing_type varchar(1), @holiday_calendar INT

	DECLARE @table_var TABLE ( label VARCHAR(100),udf_value VARCHAR(100))
	
	SELECT  @holiday_calendar = calendar_desc   FROM default_holiday_calendar

	declare @pricing_index varchar(10)
	select @pricing_index=value_id from static_data_value 
	where code = 'Pricing Index'
	
	IF @holiday_calendar IS NULL
		SET @holiday_calendar = 291898
	
	set @pricing_type='b'
	if @source_deal_detail_id<0 
	begin
		set @source_deal_detail_id=abs(@source_deal_detail_id)
		set @pricing_type='p'
	end

	if isnull(@call_from,0)=1 --wacog price
	begin

		;WITH CTE AS (
			SELECT 	pricing_index, CAST(dbo.FNAGetBusinessDay ('n',DATEADD(DAY,-1,pricing_start),@holiday_calendar) AS DATETIME) bl_date ,pricing_end  
			FROM wacog_fixed_price_deemed WHERE source_deal_detail_id=@source_deal_detail_id
			UNION ALL
			SELECT pricing_index,CAST(dbo.FNAGetBusinessDay ('n',bl_date,@holiday_calendar) AS DATETIME),pricing_end FROM CTE 
					WHERE CAST(dbo.FNAGetBusinessDay('n',bl_date,@holiday_calendar) AS DATETIME) <= pricing_end
			)
			
			INSERT INTO @price_dates(curve_id,term_start,maturity_date)
			SELECT pricing_index,bl_date,null FROM CTE
			cross apply
			( select exp_calendar_id from   source_price_curve_def where source_curve_def_id=pricing_index ) spcd 
			left JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id and hg.hol_date  =bl_date
				where spcd.exp_calendar_id is null or (spcd.exp_calendar_id is not null and hg.hol_group_value_id is not null)


		--- select * from @price_dates
		return 

	end
	else
	begin
		DECLARE @detail_pricing INT
		if @pricing_type='p'
			SELECT 	@from_date = max(case when uddft.field_id='-5644' then NULLIF(uddf.udf_value,'1900-01-01') else null end) --'Pricing Start Date'
				, 	@to_date =  max(case when uddft.field_id='-5643' then NULLIF(uddf.udf_value,'1900-01-01') else null end) --Pricing End Date
				, 	@term_start = null
				, 	@curve_id =max(case when uddft.field_id=case when isnull(@call_from,0)=2 then '-5637' else '-5642' end then uddf.udf_value else null end) --Pricing Index
			FROM source_deal_detail td 
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id and td.source_deal_detail_id=@source_deal_detail_id 
				INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id=sdh.template_id	and isnull(uddft.leg,td.leg)=td.leg	
				and uddft.udf_type='h'
				LEFT JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = td.source_deal_header_id  
						AND uddf.udf_template_id = uddft.udf_template_id
			--WHERE uddft.internal_field_type IS NOT NULL 
			
		else
			SELECT 	@from_date = CASE  sdd.detail_pricing 
							WHEN 1608 THEN CONVERT(VARCHAR(10),CAST(YEAR(sdd.term_start) AS VARCHAR)+'-'+CAST(MONTH(sdd.term_start) AS VARCHAR)+'-01',120)
							WHEN 1609 THEN CONVERT(VARCHAR(10),CONVERT(VARCHAR(7),DATEADD(m,-2,sdd.term_start),120)+'-26',120) 
							WHEN 1610 THEN CONVERT(VARCHAR(10),COALESCE(sda.movement_date_time,mgd.estimated_movement_date,sdd.term_end),120)
							ELSE dbo.FNAGetSQLStandardDate(pricing_start) END
				, 	@to_date = CASE sdd.detail_pricing
							WHEN 1608 THEN CONVERT(VARCHAR(10),DATEADD(m,1,(CAST(YEAR(sdd.term_start) AS VARCHAR)+'-'+CAST(MONTH(sdd.term_start) AS VARCHAR)+'-01'))-1,120) 
							WHEN 1609 THEN CONVERT(VARCHAR(10),CONVERT(VARCHAR(7),DATEADD(m,-1,sdd.term_start),120)+'-25',120) 
							WHEN 1610 THEN CONVERT(VARCHAR(10),COALESCE(sda.movement_date_time,mgd.estimated_movement_date,sdd.term_end),120)
							ELSE dbo.FNAGetSQLStandardDate(pricing_end) END
				, 	@term_start = NULL
				, 	@curve_id = case when uddft.field_id=case when isnull(@call_from,0)=2 then '-5637' else @pricing_index end then udddf.udf_value else null end 
				, 	@logical_name = NULL
				,	@detail_pricing = sdd.detail_pricing
				--max(case when uddft.field_label='BL Pricing Type' then udddf.udf_value else null end) 
			FROM
					source_deal_detail sdd
					INNER JOIN user_defined_deal_detail_fields udddf ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
					INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
					OUTER APPLY(SELECT MAX(split_id) split_id,MIN(estimated_movement_date) estimated_movement_date FROM  match_group_detail WHERE source_deal_detail_id = sdd.source_deal_detail_id) mgd
					LEFT JOIN actual_match am ON am.deal_volume_split_id = mgd.split_id
					LEFT JOIN split_deal_actuals sda On sda.split_deal_actuals_id = am.split_deal_actuals_id
				WHERE
					sdd.source_deal_detail_id=@source_deal_detail_id
	end



	SELECT @logical_name = clm1_value FROM generic_mapping_values WHERE generic_mapping_values_id = @logical_name

	SELECT @term_start = ISNULL(@term_start,CONVERT(VARCHAR(10),sdd.term_start,120))
		,@from_date = ISNULL(nullif(@from_date,''),CONVERT(VARCHAR(10),sdd.term_start,120))
		,@to_date = ISNULL(nullif(@to_date,''),CONVERT(VARCHAR(10),sdd.term_end,120))
	 FROM source_deal_detail sdd WHERE sdd.source_deal_detail_id = @source_deal_detail_id


	SET @generic_mapping_name = 'Average Pricing Method'	
	
	DECLARE @avg_curve_value FLOAT, @BL_date DATETIME, @BL_skpidays INT,@BL_DaysBefore INT,@BL_DaysAfter INT,@BL_IncludeEvent VARCHAR(10),@BL_Holiday INT,@BL_SkipDays int
	
	IF  isnull(@logical_name,'')<>'' and @pricing_type<>'p'
	BEGIN

		if @logical_name='UserDefined'
		begin

			select 
				@BL_DaysAfter= max(case when uddft.field_label='BL_DaysAfter' then uddf.udf_value else null end)
				,@BL_DaysBefore = max(case when uddft.field_label='BL_DaysBefore' then uddf.udf_value else null end)
				,@BL_Holiday = max(case when uddft.field_label='BL_Holiday' then uddf.udf_value else null end)
				,@BL_IncludeEvent = max(case when uddft.field_label='BL_IncludeEvent' then uddf.udf_value else null end)
				,@BL_SkipDays = max(case when uddft.field_label='BL_SkipDays' then uddf.udf_value else null end)
			FROM source_deal_detail td 
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id
				and td.source_deal_detail_id=@source_deal_detail_id 
				INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id=sdh.template_id	and isnull(uddft.leg,td.leg)=td.leg	
				and uddft.udf_type='d'
				LEFT JOIN user_defined_deal_detail_fields uddf ON uddf.source_deal_detail_id = td.source_deal_detail_id 
						AND uddf.udf_template_id = uddft.udf_template_id

		end
		else
		begin
			SELECT	@BL_SkipDays=clm2_value,
					@BL_DaysBefore = clm3_value,
					@BL_DaysAfter = clm4_value,
					@BL_IncludeEvent = clm5_value,
					@BL_Holiday = clm6_value
			FROM	
				generic_mapping_values gmv
				INNER JOIN generic_mapping_header gmh ON gmv.mapping_table_id = gmh.mapping_table_id
			WHERE
				gmh.mapping_name = @generic_mapping_name
				AND gmv.clm1_value = @logical_name	
		end

		SELECT  @BL_date = CASE WHEN @BL_Holiday = 0 THEN  dbo.FNAGetBusinessDay ('p',DATEADD(DAY,1,DATEADD(DAY,@BL_SkipDays,@term_start)),@holiday_calendar)
						ELSE dbo.FNAGetBusinessDay ('n',DATEADD(DAY,-1,DATEADD(DAY,@BL_SkipDays,@term_start)),@holiday_calendar) END
				

		declare @i int,@BL_term_start datetime,@BL_term_end datetime

		set @BL_term_start=@BL_date
		set @BL_term_end=@BL_date
		set @i=1	
		while @i <=@BL_DaysBefore
		begin
			select @BL_term_start=dbo.FNAGetBusinessDay ('p',@BL_term_start,@holiday_calendar)
			--select @BL_term_start
			set @i=@i+1
		end 

		set @i=1	
		while @i <=@BL_DaysAfter
		begin
			select @BL_term_end=dbo.FNAGetBusinessDay ('n',@BL_term_end,@holiday_calendar)
			set @i=@i+1
		end 
		
		;WITH CTE AS (
			SELECT @BL_term_start bl_date
			UNION ALL
			SELECT dateadd(day,1,bl_date) bl_date FROM CTE WHERE bl_date<@BL_term_end
		)

		INSERT INTO @price_dates(curve_id,term_start,maturity_date)
		SELECT @curve_id,bl_date,
			case when isnull(@call_from,0)=2 then isnull(hg1.hol_date,bl_date) else null end maturity_date 
		FROM CTE c 
		cross apply
					( select exp_calendar_id from   source_price_curve_def where source_curve_def_id=@curve_id ) spcd
		left join holiday_group hg on hg.hol_group_value_id = @holiday_calendar AND hg.hol_date = c.bl_date
		left JOIN holiday_group hg1 ON hg1.hol_group_value_id = spcd.exp_calendar_id and hg1.hol_date  =c.bl_date
		where hg.hol_date is null and ( spcd.exp_calendar_id is null or (spcd.exp_calendar_id is not null and hg1.hol_group_value_id is not null))
		

		if  @BL_IncludeEvent = 'No'
			delete @price_dates where term_start=@BL_date

	 END
	 ELSE
	 BEGIN
	
		IF @detail_pricing = 1610
		BEGIN
			INSERT INTO @price_dates(curve_id,term_start)
			SELECT @curve_id,@from_date
		END
		ELSE
		BEGIN
			;WITH CTE AS (
				SELECT CAST(dbo.FNAGetBusinessDay ('n',DATEADD(DAY,-1,@from_date),@holiday_calendar) AS DATETIME) bl_date
				UNION ALL
				SELECT CAST(dbo.FNAGetBusinessDay ('n',bl_date,@holiday_calendar) AS DATETIME) FROM CTE WHERE CAST(dbo.FNAGetBusinessDay('n',bl_date,@holiday_calendar) AS DATETIME) <= @to_date
			)
			
			INSERT INTO @price_dates(curve_id,term_start,maturity_date)
			SELECT @curve_id,bl_date,
			case when isnull(@call_from,0)=2 then isnull(hg.hol_date,bl_date) else null end maturity_date 
			 FROM CTE
			cross apply
			( select exp_calendar_id from   source_price_curve_def where source_curve_def_id=@curve_id ) spcd 
			left JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id and hg.exp_date  =bl_date
				where spcd.exp_calendar_id is null or (spcd.exp_calendar_id is not null and hg.hol_group_value_id is not null)
	 END
	 END
	 --select * from @price_dates
	 return 
end
