IF OBJECT_ID(N'[dbo].[spa_curve_interpolation]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_curve_interpolation]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 28 Oct 2014
-- portfolio_group_description: Maintain portfolio group operations 

-- Params:
-- @flag CHAR(1) - Operation flag
-- @as_of_date_from DATETIME - 
-- @as_of_date_to DATETIME - 
-- @term_start - 
-- @term_end DATETIME - 
-- @formula_sql VARCHAR(MAX) - 
-- @curve_id INT
-- ============================================================================================================

CREATE PROCEDURE [dbo].[spa_curve_interpolation]
	@flag CHAR(1)
	, @as_of_date_from DATETIME = NULL
	, @as_of_date_to DATETIME = NULL
	, @term_start DATETIME = NULL
	, @term_end DATETIME = NULL
	, @curve_id INT = NULL
	, @process_id VARCHAR(100) = NULL
AS
/*
DECLARE
@flag CHAR(1) = 'r'
	, @as_of_date_from DATETIME = '2014-04-04'
	, @as_of_date_to DATETIME = '2014-04-04'
	, @term_start DATETIME = '2014-04-04'
	, @term_end DATETIME = '2044-04-30'
	, @curve_id INT = 2419
	, @process_id varchar(20) = '9999'
--*/

IF @flag IN ('c', 'r')
BEGIN
	BEGIN TRY
		DECLARE @sql VARCHAR(max)
		DECLARE @tbl_report_result VARCHAR(1000)
		DECLARE @formula_sql VARCHAR(8000)

		IF @process_id is null
			SELECT @process_id = dbo.FNAGetNewID()

		SET @tbl_report_result = dbo.FNAProcessTableName('curve_interpolation_result', dbo.FNADBUser(), @process_id)
	
		/*
		select * from source_price_curve s where s.source_curve_def_id = 2419 and s.as_of_date = '2014-04-04' and s.maturity_date between '2014-04-04' and '2044-04-08'
		select * from adiha_process.dbo.curve_interpolation_result_farrms_admin_7FF1102D_E4CA_4A0E_B3E2_C06B796FD8AB
		select * delete s from source_price_curve s where s.source_curve_def_id = 2419 and s.as_of_date = '2014-04-04' and s.maturity_date not IN ('2014-04-04','2014-04-30')
		*/

		SELECT 	
			@formula_sql = fes.formula_sql 
		FROM source_price_curve_def spcd
		INNER JOIN formula_editor_sql fes ON spcd.formula_id = fes.formula_id
		WHERE spcd.source_curve_def_id = @curve_id


		--SELECT @formula_sql = 'EXEC spa_interpolate_curve ''b'', ''@_as_of_date_from'', ''@_as_of_date_to'', ''@_term_start'', ''@_term_end'', 2418, 360, 0.01'
		IF @formula_sql IS NOT NULL
		BEGIN
			SET @formula_sql = REPLACE(@formula_sql, '@_as_of_date_from',  CONVERT(VARCHAR(10), @as_of_date_from, 120))
			SET @formula_sql = REPLACE(@formula_sql, '@_as_of_date_to', CONVERT(VARCHAR(10), @as_of_date_to, 120))
			SET @formula_sql = REPLACE(@formula_sql, '@_term_start', CONVERT(VARCHAR(10), @term_start, 120))
			SET @formula_sql = REPLACE(@formula_sql, '@_term_end', CONVERT(VARCHAR(10), @term_end, 120))
		END
		--select @formula_sql

		--RETURN

		IF OBJECT_ID(N'tempdb..#source_price_curve') IS NOT NULL
			DROP TABLE #source_price_curve
	 
		CREATE TABLE #source_price_curve(
				source_curve_def_id INT		
				, as_of_date DATETIME
				, Assessment_curve_type_value_id INT
				, curve_source_value_id INT
				, maturity_date DATETIME
				, curve_value FLOAT
				, is_dst CHAR(1)
		)

		--SELECT @formula_sql AS [Formula]
		INSERT INTO #source_price_curve
		EXEC(@formula_sql)
	
		DELETE source_price_curve 
		from source_price_curve s 
		  INNER JOIN #source_price_curve t on s.source_curve_def_id= @curve_id and s.as_of_date=t.as_of_date
				and s.curve_source_value_id=t.curve_source_value_id and s.maturity_date=t.maturity_date and s.is_dst=t.is_dst

		INSERT INTO source_price_curve(
			source_curve_def_id		
					, as_of_date
			, Assessment_curve_type_value_id
			, curve_source_value_id
			, maturity_date
			, curve_value
					, is_dst)
		SELECT
		@curve_id
		, as_of_date
				, Assessment_curve_type_value_id
				, curve_source_value_id
				, maturity_date
				, curve_value
						, is_dst
		FROM #source_price_curve

		DECLARE @continous_compounding  TINYINT,
				@discrete_daily_365     TINYINT,
				@discrete_daily_input   TINYINT,
				@discrete_monthly       TINYINT

		SET @continous_compounding = 128 
		SET @discrete_daily_365 = 126
		SET @discrete_daily_input = 127
		SET @discrete_monthly = 125

		DECLARE @is_discount_curve_a_factor INT
		SELECT @is_discount_curve_a_factor = var_value
		FROM   adiha_default_codes_values
		WHERE  (instance_no = 1)
			   AND (default_code_id = 14)
			   AND (seq_no = 1)

		--SELECT OBJECT_ID(N''''#subs'''')
		IF OBJECT_ID(N'tempdb..#subs') IS NOT NULL
			DROP TABLE #subs

		SELECT fas_subsidiary_id,
			   ISNULL(discount_curve_id, default_discount_curve_id) discount_curve_id,
			   disc_type_value_id,
			   case when days_in_year=0 then 1 else days_in_year end days_in_year
		INTO #subs
		FROM   fas_subsidiaries
			   FULL OUTER JOIN
				(
					SELECT MAX(source_curve_def_id) default_discount_curve_id
					FROM   source_price_curve_def
					WHERE  source_curve_type_value_id = 577
				) df ON  1 = 1
			   LEFT OUTER JOIN source_price_curve_def spcd 
					ON spcd.source_curve_def_id = ISNULL(discount_curve_id, default_discount_curve_id) 
		where ISNULL(discount_curve_id, default_discount_curve_id) is NOT NULL

		IF OBJECT_ID(N'tempdb..#discount_calc_deals') IS not NULL
			DROP TABLE #discount_calc_deals

		SELECT  distinct sdh.source_deal_header_id,s.discount_curve_id,s.disc_type_value_id,s.days_in_year,
			COALESCE(dbo.FNAInvoiceDueDate(sdd.term_start, cg.invoice_due_date, cg.holiday_calendar_id ,cg.payment_days),hgc.exp_date,sdd.term_start) term_start, sdd.term_start deal_term_start
		into  #discount_calc_deals
		FROM	#subs s 
			inner join Portfolio_hierarchy stra (nolock) ON stra.parent_entity_id = s.fas_subsidiary_id 
			inner join Portfolio_hierarchy book (nolock) ON book.parent_entity_id = stra.entity_id 
			inner JOIN	source_system_book_map sbm ON sbm.fas_book_id = book.entity_id   
			inner join source_deal_header sdh on sdh.source_system_book_id1=sbm.source_system_book_id1
				and sdh.source_system_book_id2=sbm.source_system_book_id2
				and sdh.source_system_book_id3=sbm.source_system_book_id3
				and sdh.source_system_book_id4=sbm.source_system_book_id4
				and sdh.deal_date<=@as_of_date_from
			cross apply (
				select distinct term_start,settlement_date from source_deal_detail  where source_deal_header_id=sdh.source_deal_header_id and term_end>@as_of_date_from
				) sdd
			left JOIN contract_group cg ON cg.contract_id = sdh.contract_id 
			LEFT JOIN holiday_group hgc ON hgc.hol_group_value_id = cg.payment_calendar 
				and convert(varchar(7), hgc.hol_date, 120) = convert(varchar(7), sdd.term_start, 120) 

		create index inx_discount_calc_deals on #discount_calc_deals (discount_curve_id,term_start)

		delete source_deal_discount_factor from 
			(select distinct source_deal_header_id from #discount_calc_deals) t
			inner join source_deal_discount_factor f on f.source_deal_header_id=t.source_deal_header_id
				and f.as_of_date=@as_of_date_from

		INSERT INTO source_deal_discount_factor 
			(as_of_date,source_deal_header_id,maturity,market_price,discount_factor,create_user,create_ts)

		SELECT  @as_of_date_from, t.source_deal_header_id,t.deal_term_start,null,  
				isnull(
				CASE	
					WHEN @is_discount_curve_a_factor in (1,2) THEN 1.0/ISNULL(spc.curve_value, 1)
				ELSE
					CASE	WHEN t.disc_type_value_id =@continous_compounding THEN
						power(2.71828, (-1* coalesce( spc.curve_value, 0)*datediff(day, @as_of_date_from,spc.maturity_date)/nullif(t.days_in_year,0)))
					WHEN(t.disc_type_value_id = @discrete_monthly) THEN
						power(1+(coalesce( spc.curve_value, 0)/12), (-1* datediff(month,  @as_of_date_from ,spc.maturity_date)))
					WHEN t.disc_type_value_id = @discrete_daily_365 THEN
						power(1+(coalesce(spc.curve_value, 0)/365), (-1* datediff(day, @as_of_date_from ,spc.maturity_date)))
					ELSE
						power(1+(coalesce(spc.curve_value, 0)/nullif(t.days_in_year,0)), (-1* datediff(day, @as_of_date_from ,spc.maturity_date)))
					END 
				END,1) AS discount_factor, dbo.fnadbuser(),getdate()
		FROM	#discount_calc_deals t
		inner join source_price_curve spc ON t.discount_curve_id = spc.source_curve_def_id  
			AND spc.assessment_curve_type_value_id = 77 AND spc.as_of_date = @as_of_date_from and spc.curve_source_value_id=4500 
			and spc.maturity_date=t.term_start	
	
		IF @flag = 'r'
		BEGIN
			SET @sql = '
			IF OBJECT_ID(N''' + @tbl_report_result + ''') IS NOT NULL
				DROP TABLE ' + @tbl_report_result
			PRINT (@sql)
			EXEC (@sql)


			set @sql = '
			SELECT
			as_of_date as_of_date
			, CONVERT(DATETIME,''' + cast(dbo.FNAGetSQLStandardDate(@as_of_date_from) as varchar(10)) + ''' , 127) AS from_as_of_date
			, CONVERT(DATETIME,''' + cast(dbo.FNAGetSQLStandardDate(@as_of_date_to) as varchar(10)) + ''' , 127) AS to_as_of_date
			, CONVERT(DATETIME,''' + cast(dbo.FNAGetSQLStandardDate(@term_start) as varchar(10)) + ''' , 127) AS term_start
			, CONVERT(DATETIME,''' + cast(dbo.FNAGetSQLStandardDate(@term_end) as varchar(10)) + ''' , 127) AS term_end
	, ''' + CAST(@curve_id AS VARCHAR(10)) + ''' AS curve_ids
			, curve_name
			, curve_source_value_id [Curve Source]
			, maturity_date [Maturity date]
			, CONVERT(numeric(30,10), curve_value) [Value]
			INTO ' + @tbl_report_result + '
			FROM #source_price_curve spc
			INNER JOIN source_price_curve_def spcd on spcd.source_curve_def_id = ' + cast(@curve_id as varchar(10))

			PRINT (@sql)
			EXEC (@sql)
		END			 
	
		IF @flag = 'c'
		BEGIN
			DECLARE @desc VARCHAR(500)= 'Interpolation calculation process is completed for ' + dbo.FNADateFormat(@as_of_date_from) + '.'
			
			EXEC spa_ErrorHandler 0
			, 'Curve Interpolation'
			, 'spa_curve_interpolation'
			, 'Success'
			, @desc
			, ''
		END
	END TRY
	BEGIN CATCH  
		EXEC spa_ErrorHandler @@ERROR
				, 'Curve Interpolation'
				, 'spa_curve_interpolation'
				, 'Error'
				, 'Fail'
				, ''
	END CATCH
END 


