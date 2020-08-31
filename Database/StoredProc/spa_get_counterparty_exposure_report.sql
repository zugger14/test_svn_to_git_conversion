
/****** Object:  StoredProcedure [dbo].[spa_get_counterparty_exposure_report]    Script Date: 05/07/2009 16:50:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_counterparty_exposure_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_counterparty_exposure_report]
/****** Object:  StoredProcedure [dbo].[spa_get_counterparty_exposure_report]    Script Date: 05/07/2009 16:50:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Author : Vishwas Khanal
/*************************************************
Modification Histroy
Modified By: Anal Shrestha
Modified on: 03/23/2009
Comments: In the Net exposure column used the column net_exposure_to_us. fixed drill down for Counterparty Credit and the detail drill down
***************************************************/

CREATE PROC [dbo].[spa_get_counterparty_exposure_report]
	@report_type					CHAR(1)					= 'e'	,
	@summary_option					CHAR(1)					= 's'	, 
	@group_by						CHAR(1)					= 'b'	,
	@as_of_date						DATETIME						,
	@sub_entity_id					VARCHAR(MAX)			= NULL	,	
	@strategy_entity_id				VARCHAR(100)			= NULL	,
	@book_entity_id					VARCHAR(100)			= NULL	,
	@counterparty_id				VARCHAR(MAX)			= NULL	,
	@term_start						DATETIME				= NULL	,
	@term_end						DATETIME				= NULL	,
	@counterparty_entity_type		INT						= NULL	,
	@counterparty_type				CHAR(1)					= NULL	, 
	@risk_rating					INT						= NULL	,
	@debt_rating					INT						= NULL	,
	@industry_type1					INT						= NULL	,
	@industry_type2					INT						= NULL	,
	@sic_code						INT						= NULL  ,
	@include_potential				CHAR(1)					= 'n'	,
	@show_exceptions				CHAR(1)					= 'n'	,
	@account_status					INT						= NULL	,
	@watch_list						CHAR(1)					= 'n'	,
	@tenor_option					CHAR(1)					= 'c'	,
	@ROUND_value					INT						= NULL	,
	@apply_paging					CHAR(1)					= 'n'	,
	@curve_source					INT						= NULL	,
	@nettingParentGroup				VARCHAR(MAX)			= NULL	, 
	@present_future					CHAR(1)					= NULL	,
	@drill_book						VARCHAR(100)			= NULL	,
	@drill_parent_counterparty		VARCHAR(100)			= NULL	,
	@drill_counterparty				VARCHAR(MAX)			= NULL	,
	@drill_term						VARCHAR(50)				= NULL	,
	@source_system_bookid1			INT						= NULL	,
	@source_system_bookid2			INT						= NULL  ,
	@source_system_bookid3			INT						= NULL	,
	@source_system_bookid4			INT						= NULL  ,
	@trader_id						INT						= NULL	
AS
SET NOCOUNT ON  
BEGIN	

	if @tenor_option<>'u'
	begin
		IF @drill_term is not null and len(@drill_term)<11
			SET @drill_term	=dbo.fnastddate(substring(@drill_term,1,10)	)
	end


-- @tenor_option   = 'u'    : Cumulative
-- @tenor_option   = 'c'    : Contract Month
-- @tenor_option   = 's'    : Summary

-- @present_future = 'u'	: Future ELSE Present

-- @report_type	   = 'e'	: Credit Exposure Report
-- @report_type	   = 'c'	: Concentration Report
-- @report_type	   = 'f'	: Fixed MTM Report
-- @report_type	   = 'r'	: Credit Reserve Report
-- @report_type	   = 'g'	: Pie Chart in Concentration Report


/*exp_type_id = 1 -- MTMGain
			  = 2 -- MTMLoss
			  = 3 -- A/R Billed, 
			  = 4 -- A/R UnBilled, 
			  = 5 -- A/P Billed,
			  = 6 -- A/P UnBilled, 
			  = 7 -- Cash Rec, 
			  = 8 -- Cash Pay */

/* @group_by parameters 
	 'b' Exposure to US , 
	 'p' parent counterparty, 
	 'c' individual counterparty, 
	 'e' counterparty entity type, 
	 'r' risk- rating, 
	 'd' debt rating,
	 'i' industry type1, 
	 't' industry type 2,
	 's' SIC code
*/		
		DECLARE @sql_stmt						VARCHAR(8000)		
		DECLARE @sql_group_by					VARCHAR(8000)
		DECLARE @sql_where						VARCHAR(5000)
		DECLARE @Columns						VARCHAR(8000)		
		DECLARE @curveSource					VARCHAR(500)
		DECLARE @counterparty_entity_type_tmp	VARCHAR(100)
		DECLARE @sql_select						VARCHAR(8000)
		DECLARE @sql_orderby					VARCHAR(500)
		DECLARE @sql_select1					VARCHAR(5000)
		DECLARE @sql_group_by1					VARCHAR(5000)
		DECLARE @sql_orderby1					VARCHAR(100)
		DECLARE @drill_term_start				DATETIME
		DECLARE @drill_term_end					DATETIME
		DECLARE @gross_exposure					FLOAT
		DECLARE @net_exposure					FLOAT
		DECLARE @sql_join						VARCHAR(5000)
		DECLARE @cumu_sql						VARCHAR(1000)
		DECLARE @id								VARCHAR(200)
		DECLARE @table							VARCHAR(300)
		DECLARe @table_tmp						VARCHAR(300)

		DECLARE @risk_rating_tmp				VARCHAR(500),
				@debt_rating_tmp				VARCHAR(500),
				@industry_type1_tmp				VARCHAR(500),
				@industry_type2_tmp				VARCHAR(500),
				@sic_code_tmp					VARCHAR(500),
				@graph_cloumn					VARCHAR(500),
				@col							VARCHAR(1000),
				@checkFlag						CHAR(1),
				@debt_rating_id					INT, -- it holds debt rating of primary counterparty
				@debt_rating_str VARCHAR(50)
				
		SELECT @id = REPLACE(newid(),'-','_')
		SELECT @table = dbo.FNAProcessTableName('cer',dbo.FNAdbuser(),@id)
		SELECT @table_tmp = 'cer_'+dbo.FNAdbuser()+'_'+@id
		
	
		SELECT @sql_stmt = '', @sql_where = '', @sql_orderby = '',@checkFlag = 'v'
		

		IF @group_by = 'b' OR @group_by = 'c'
							SELECT @sql_stmt = 'SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+
												CASE WHEN @report_type = 'g' 
													THEN 'ced.counterparty_name [Counterparty],'
												ELSE 'dbo.FNAHyperLinkText(10101122,ced.counterparty_name,MAX(ced.Source_Counterparty_ID)) [Counterparty],' END				
												,@sql_group_by = ' GROUP BY ced.counterparty_name'
												,@graph_cloumn = 'Counterparty'																				  
												,@sql_orderby  = ' ORDER BY ced.counterparty_name'

		IF @group_by = 'p'						
							SELECT @sql_stmt = 'SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+
												CASE WHEN @report_type = 'g' 
													THEN ' ced.parent_counterparty_name [Parent Counterparty],'
												ELSE ' dbo.FNAHyperLinkText(10101122,ced.parent_counterparty_name,MAX(ced.Source_Counterparty_ID)) [Parent Counterparty],' END
												,@sql_group_by = ' GROUP BY ced.parent_counterparty_name'
												,@graph_cloumn = '[Parent Counterparty]'
												,@sql_orderby  = ' ORDER BY ced.parent_counterparty_name'

	
		IF @group_by = 'e'  SELECT @sql_stmt = 'SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name [Counterparty Name]' ELSE 'ced.counterparty_type [Counterparty Type]' END+','			
									,@sql_group_by = ' GROUP BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.counterparty_type' END,@graph_cloumn= '[Counterparty Type]'
									,@sql_orderby  = ' ORDER BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.counterparty_type' END

		IF @group_by = 'r'  SELECT @sql_stmt = 'SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name [Counterparty Name]' ELSE 'ced.risk_rating  [Risk Rating]' END+','						
								  ,@sql_group_by = ' GROUP BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.risk_rating' END,@graph_cloumn='[Counterparty Name]'
								  ,@sql_orderby  = ' ORDER BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.risk_rating' END


		IF @group_by = 'd'  SELECT @sql_stmt = 'SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID], '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name [Counterparty Name]' ELSE 'ced.debt_rating [Debt Rating]' END +','						
								  ,@sql_group_by = ' GROUP BY  '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.debt_rating' END,@graph_cloumn = ' [Counterparty Name]'
								  ,@sql_orderby  = ' ORDER BY  '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.debt_rating' END


		IF @group_by = 'i'  SELECT @sql_stmt = 'SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name [Counterparty Name]' ELSE 'ced.industry_type1 [Industry Type1]' END +','				
								  ,@sql_group_by = ' GROUP BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.industry_type1' END ,@graph_cloumn = ' [Counterparty Name]'
								  ,@sql_orderby  = ' ORDER BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.industry_type1' END

		IF @group_by = 't'  SELECT @sql_stmt = 'SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name [Counterparty Name]' ELSE 'ced.industry_type2 [Industry Type2]' END +','				
								  ,@sql_group_by = ' GROUP BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.industry_type2' END ,@graph_cloumn ='[Counterparty Name]'
								  ,@sql_orderby  = ' ORDER BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.industry_type2' END

		IF @group_by = 's'  SELECT @sql_stmt = 'SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name [Counterparty Name]' ELSE 'ced.sic_code [SIC Code]' END +','							
								  ,@sql_group_by = ' GROUP BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.sic_code' END,@graph_cloumn = '[Counterparty Name]'
								  ,@sql_orderby  = ' ORDER BY '+CASE WHEN @summary_option = 'm'  THEN 'ced.counterparty_name' ELSE 'ced.sic_code' END

		
		
		SELECT @col = SUBSTRING(@sql_group_by,10,len(@sql_group_by))
		
						
		
		IF @counterparty_type = 'a'
			SELECT @counterparty_type = 'b'

		SELECT @curveSource = code FROM static_data_value WHERE value_id = @curve_source

		SELECT @counterparty_entity_type_tmp = code FROM static_data_value WHERE value_id = @counterparty_entity_type

		IF @report_type IN ('e','f','c','r','g')
		BEGIN	
		
			IF @summary_option = 'd' and @report_type <> 'e'  AND @drill_counterparty IS NULL AND @report_type <> 'g' --  For the detailed report other than that of credit exposure report.	
			BEGIN
				SELECT @sql_stmt = '',@sql_group_by = ''

				SELECT @sql_stmt ='
					SELECT ced.Source_Counterparty_ID [Source Counterparty ID],ced.counterparty_name [Counterparty],
					dbo.FNAHyperLinkText(10131010, cast(ced.source_deal_header_id as VARCHAR),ced.source_deal_header_id) [Source Deal Header ID],
						sc.commodity_name [Commodity],'	+		
--						CASE WHEN @tenor_option = 'u' 
--							THEN ' ced.agg_term_start [Term],'
--							ELSE ' dbo.FNADateFormat(ced.term_start) [Term],' END +
							' dbo.FNADateFormat(ced.term_start) [Term],' +							
						CASE WHEN @present_future = 'u' 
							THEN ' ROUND(ISNULL(gross_exposure,0), '+ CAST(@round_value  AS VARCHAR)+') [Gross Exposure],'
							ELSE ' ROUND(ISNULL(d_gross_exposure,0),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'	END +
							CASE WHEN @group_by = 'b' THEN
								CASE WHEN @present_future = 'u' THEN ' ROUND(net_exposure_to_them,'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(d_net_exposure_to_them,'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
							ELSE
								CASE WHEN @present_future = 'u' THEN ' ROUND(net_exposure_to_us,'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(d_net_exposure_to_us,'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
							END +
--						CASE WHEN @present_future = 'u' 
--							THEN ' ROUND(ISNULL(total_net_exposure,0),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure], '
--							ELSE ' ROUND(ISNULL(d_total_net_exposure,0),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ,' END +
						',ced.currency_name [Currency] into '+@table+'
					FROM credit_exposure_detail ced 
					INNER JOIN source_deal_detail sdd 
						ON ced.Source_Deal_Header_ID = sdd.source_deal_header_id
					INNER JOIN source_price_curve_def spc
						ON spc.source_curve_def_id = sdd.curve_id
					INNER JOIN source_commodity sc
						ON sc.source_commodity_id = spc.commodity_id
					WHERE 1=1 '
			END
			ELSE -- IF @summary_option = 'd' and @report_type <> 'e' 
			BEGIN
			
				IF @report_type = 'g'
				BEGIN
					GOTO ConcentrationReport
				END
				IF @report_type = 'r'
				BEGIN			
/*		
					SELECT @sql_stmt =@sql_stmt +
						CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(gross_exposure), '+ CAST(@round_value  AS VARCHAR)+') [Gross Exposure],'
						ELSE ' ROUND(SUM(d_gross_exposure),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'	END +
--						CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_us,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
--						ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_us,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END + 	
						CASE WHEN @group_by = 'b' THEN
							CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_them,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
							ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_them,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
						ELSE
							CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_us,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
							ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_us,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
						END + 
						' ,ROUND (max(ISNULL(dp.probability,1)) ,'+ CAST(@round_value  AS VARCHAR)+') [Default Probability]
						  ,ROUND (max(ISNULL(drr.rate,1)) ,'+ CAST(@round_value  AS VARCHAR)+') [Recovery Rate]' +
						CASE WHEN @present_future = 'u' THEN
							',SUM((ISNULL(ced.gross_exposure,1))) * max(ISNULL(dp.probability,1)) * (1-max(ISNULL(drr.rate,1))) [GrossExposureReserve],'
						ELSE
							',SUM((ISNULL(ced.d_gross_exposure,1))) * max(ISNULL(dp.probability,1)) * (1-max(ISNULL(drr.rate,1))) [GrossExposureReserve],' END +
						CASE WHEN @present_future = 'u' THEN
							'SUM((ISNULL(ced.total_net_exposure,1))) * max(ISNULL(dp.probability,1)) * (1-max(ISNULL(drr.rate,1))) [NetExposureReserve]'							
						ELSE
							'SUM((ISNULL(ced.d_total_net_exposure,1)))* max(ISNULL(dp.probability,1)) * (1-max(ISNULL(drr.rate,1))) [NetExposureReserve]' END+							
						 ' INTO '+@table+' FROM credit_exposure_detail ced  
						LEFT OUTER JOIN counterparty_credit_info cci
						 ON ced.Source_Counterparty_ID = cci.Counterparty_id
						LEFT OUTER JOIN default_recovery_rate drr 
						 ON drr.debt_rating=cci.debt_rating
							AND term_start>=drr.effective_date
						LEFT OUTER JOIN default_probability dp 
						  ON dp.debt_rating=cci.debt_rating
							AND drr.months = dp.months
							AND term_start>=dp.effective_date WHERE 1=1 '	
*/


					IF @summary_option IN ('d','n')
						GOTO GrossNetDrillDown
					ELSE IF @summary_option = 'k'
					BEGIN
						GOTO TermDrillDown
					END
					ELSE
					BEGIN
						--IF @tenor_option<>'s'
						--BEGIN
						--Taking debt rating from primary counterparty
							SELECT @debt_rating_id = cci.Debt_rating 
							FROM fas_subsidiaries fs 
							INNER JOIN counterparty_credit_info cci ON fs.counterparty_id = cci.Counterparty_ID
							WHERE fs.fas_subsidiary_id = '-1'
							
							SET @debt_rating_str = ISNULL(CAST(@debt_rating_id AS VARCHAR), '')
							
							IF @group_by <> 'b'
								SET @debt_rating_str = 'ced.debt_rating_id'
						
							SELECT @sql_group_by = @sql_group_by + CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' WHEN @tenor_option = 'c' THEN ',term_start'  ELSE '' END
							SELECT @sql_stmt =@sql_stmt +
								CASE WHEN @tenor_option<>'s' THEN
								CASE WHEN @tenor_option = 'u' THEN ' agg_term_start [Term],'
									ELSE 'dbo.FNADateFormat(term_start) [Term],' END  ELSE '' END+
								CASE WHEN @present_future = 'u' AND @group_by = 'b' THEN
									' ROUND(SUM(gross_exposure_to_them), '+ CAST(@round_value  AS VARCHAR)+') [Gross Exposure],'
								ELSE
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(gross_exposure), '+ CAST(@round_value  AS VARCHAR)+') [Gross Exposure],'
									ELSE ' ROUND(SUM(d_gross_exposure),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'	END 
								END	+
								CASE WHEN @group_by = 'b' THEN
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_them,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_them,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
								ELSE
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_us,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_us,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
								END +

								CASE WHEN @tenor_option='c' THEN								
										',MAX([dbo].[FNAGetProbabilityDefault](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date)) [Default Probability]
										,MAX([dbo].[FNAGetRecoveryRate](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date)) [Recovery Rate] '
									ELSE '' 
								END+
	/* 
								',MAX([dbo].[FNAGetProbabilityDefault](ced.debt_rating_id ,DATEDIFF(mm,dbo.FNADateFormat(ced.as_of_date),dbo.FNADateFormat(ced.term_start)),dbo.FNADateFormat(ced.as_of_date))) [Default Probability]
								,MAX([dbo].[FNAGetRecoveryRate](ced.debt_rating_id ,DATEDIFF(mm,dbo.FNADateFormat(ced.as_of_date),dbo.FNADateFormat(ced.term_start)),dbo.FNADateFormat(ced.as_of_date))) [Recovery Rate] '+*/
								CASE WHEN @present_future = 'u' THEN
								' ,SUM(ISNULL(ced.gross_exposure,0) * [dbo].[FNAGetProbabilityDefault](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date) * (1-[dbo].[FNAGetRecoveryRate](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date))) [Gross Exposure Reserve]'
								ELSE
								' ,SUM(ISNULL(ced.d_gross_exposure,0) * [dbo].[FNAGetProbabilityDefault](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date) * (1-[dbo].[FNAGetRecoveryRate](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date))) [Gross Exposure Reserve]' END +
								CASE WHEN @group_by = 'b' THEN
									CASE WHEN @present_future = 'u' THEN ',SUM(ISNULL(ced.net_exposure_to_them,0) * [dbo].[FNAGetProbabilityDefault](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date) * (1-[dbo].[FNAGetRecoveryRate](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date))) [Net Exposure Reserve] '
										ELSE ',SUM(ISNULL(ced.d_net_exposure_to_them,0) * [dbo].[FNAGetProbabilityDefault](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date) * (1-[dbo].[FNAGetRecoveryRate](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date))) [Net Exposure Reserve] ' END 
								ELSE
									CASE WHEN @present_future = 'u' THEN ',SUM(ISNULL(ced.net_exposure_to_us,0) * [dbo].[FNAGetProbabilityDefault](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date) * (1-[dbo].[FNAGetRecoveryRate](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date))) [Net Exposure Reserve] '
										ELSE ',SUM(ISNULL(ced.d_net_exposure_to_us,0) * [dbo].[FNAGetProbabilityDefault](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date) * (1-[dbo].[FNAGetRecoveryRate](' + @debt_rating_str + ' ,DATEDIFF(mm,ced.as_of_date,ced.term_start),ced.as_of_date))) [Net Exposure Reserve] ' END END +
								' INTO '+@table+' FROM credit_exposure_detail ced 
								 WHERE 1=1 '
					END
				END -- IF @report_type = 'r'
				ELSE IF @report_type = 'f' 
				BEGIN
					IF @summary_option  = 'c'
					BEGIN
						-- @summary_option  = 'c' -- Drill Down for Credit Limit
						GOTO CreditLimitDrillDown
					END
					ELSE IF @summary_option  IN ('f','m') OR (@summary_option  = 's' AND @tenor_option <> 's')
					BEGIN

						-- @summary_option  = 'f' -- Drill Down for Fixed Exposure
						-- @summary_option  = 'm' -- Drill Down for MTM Exposure

						FixedExposureDrillDown:

						SELECT @sql_group_by = CASE @summary_option  
							WHEN 'f' THEN ' GROUP BY ced.counterparty_name' ELSE @sql_group_by END
								+ CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ',term_start' END						

						SELECT @sql_orderby = CASE @summary_option  
							WHEN 'f' THEN ' ORDER BY counterparty_name' ELSE @sql_orderby END 
								+ CASE WHEN @tenor_option = 'u' THEN ',CONVERT(DATETIME,SUBSTRING(ced.agg_term_start,1,0))' ELSE ',term_start' End
						SET @graph_cloumn = REPLACE(@graph_cloumn, '[', '')
						SET @graph_cloumn = REPLACE(@graph_cloumn, ']', '')
						SELECT @sql_stmt  = 
							'SELECT	MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+							
							CASE WHEN @summary_option = 'f' THEN ' counterparty_name [Counterparty],'
							ELSE @col + '[' + @graph_cloumn + '],' END +
								
							CASE WHEN @tenor_option = 'u' THEN ' MAX(agg_term_start) [Term],'
							ELSE ' dbo.FNADateFormat(MAX(term_start)) [Term],' END +
							' ROUND(SUM(CASE 
										 WHEN exp_type_id IN (3,4,5,6,7,8) THEN  '+
											  CASE WHEN @group_by = 'b' THEN 
													CASE WHEN @present_future = 'u' THEN  'net_exposure_to_them' ELSE 'd_net_exposure_to_them' END
											  ELSE 
													 CASE WHEN @present_future = 'u' THEN  'net_exposure_to_us'  ELSE 'd_net_exposure_to_us' END 
											  END 
										+' ELSE 0 END ),'+CAST(@round_value AS VARCHAR)+') [Fixed Exposure],' +
							' ROUND(SUM(CASE 
										 WHEN exp_type_id IN (1,2) THEN  '+
											  CASE WHEN @group_by = 'b' THEN 
													CASE WHEN @present_future = 'u' THEN  'net_exposure_to_them' ELSE 'd_net_exposure_to_them' END
											  ELSE 
													 CASE WHEN @present_future = 'u' THEN  'net_exposure_to_us' ELSE 'd_net_exposure_to_us' END 
											  END 
										+' ELSE 0 END ),'+CAST(@round_value AS VARCHAR)+') [MTM Exposure],' +

							CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(gross_exposure), '+ CAST(@round_value  AS VARCHAR)+') [Gross Exposure],'
							ELSE ' ROUND(SUM(d_gross_exposure),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'	END +
							CASE WHEN @group_by = 'b' THEN
								CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_them,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
								ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_them,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
							ELSE
								CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_us,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
								ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_us,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
							END +
							' INTO '+@table+' FROM credit_exposure_detail ced WHERE 1 = 1 '																	
					END
					ELSE IF @summary_option = 'k'
					BEGIN
						-- @summary_option  = 'k' -- Drill Down for Term
						GOTO TermDrillDown 
					END
					ELSE
					BEGIN			
			
							SELECT @sql_stmt =@sql_stmt +
								CASE WHEN @group_by IN  ('b','p','c') THEN
									CASE WHEN @group_by  = 'b' THEN ' ROUND(MAX(total_limit_received), '+CAST(@round_value AS VARCHAR)+')[Limit],'
										 WHEN @group_by  = 'p' THEN ' ROUND(MAX(CASE WHEN counterparty_name = parent_counterparty_name THEN total_limit_provided ELSE 0 END), '+CAST(@round_value AS VARCHAR)+')[Limit],'
										ELSE ' ROUND(MAX(total_limit_provided), '+CAST(@round_value AS VARCHAR)+')[Limit],' END ELSE '' END +
								' ROUND(SUM(CASE 
											 WHEN exp_type_id IN (3,4,5,6,7,8) THEN  '+
												  CASE WHEN @group_by = 'b' THEN 
														CASE WHEN @present_future = 'u' THEN  'net_exposure_to_them' ELSE 'd_net_exposure_to_them' END
												  ELSE 
														 CASE WHEN @present_future = 'u' THEN  'net_exposure_to_us'  ELSE 'd_net_exposure_to_us' END 
												  END 
											+' ELSE 0 END ),'+CAST(@round_value AS VARCHAR)+') [Fixed Exposure],' +
								' ROUND(SUM(CASE 
											 WHEN exp_type_id IN (1,2) THEN  '+
												  CASE WHEN @group_by = 'b' THEN 
														CASE WHEN @present_future = 'u' THEN  'net_exposure_to_them' ELSE 'd_net_exposure_to_them' END
												  ELSE 
														 CASE WHEN @present_future = 'u' THEN  'net_exposure_to_us' ELSE 'd_net_exposure_to_us' END 
												  END 
											+' ELSE 0 END ),'+CAST(@round_value AS VARCHAR)+') [MTM Exposure],' +
								CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(gross_exposure), '+ CAST(@round_value  AS VARCHAR)+') [Gross Exposure],'
								ELSE ' ROUND(SUM(d_gross_exposure),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'	END +
								CASE WHEN @group_by = 'b' THEN
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_them,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_them,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
								ELSE
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_us,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_us,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
								END +
								' INTO '+@table+' FROM credit_exposure_detail ced WHERE 1=1 '			
					END
				END -- ELSE IF @report_type = 'f'
				ELSE IF @report_type = 'c'
				BEGIN		
	
					IF @summary_option  = 'c'
					BEGIN						
						-- @summary_option  = 'c' -- Drill Down for Credit Limit
						GOTO CreditLimitDrillDown
					END
					ELSE IF (@summary_option = 'd' AND @drill_counterparty IS NOT NULL)OR (@summary_option  = 's' AND @tenor_option <> 's')
					BEGIN 				
						

						IF @summary_option  = 's' AND @tenor_option <> 's'
							SELECT @checkFlag = 'y'

						-- @summary_option  = 'd' -- Drill Down for Gross Exposure
						GOTO GrossNetDrillDown


/*
							SELECT @sql_stmt =@sql_stmt +
								CASE WHEN @group_by IN ('b','p','c') THEN
									CASE WHEN  @group_by = 'b' THEN  ' ROUND(MAX(total_limit_received), '+CAST(@round_value AS VARCHAR)+')[Limit],'
									ELSE  ' ROUND(MAX(total_limit_provided), '+CAST(@round_value  AS VARCHAR)+') [Limit],' END 							ELSE '' END +
								CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(gross_exposure), '+ CAST(@round_value  AS VARCHAR)+') [Gross Exposure],'
								ELSE ' ROUND(SUM(d_gross_exposure),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'	END +
	--							CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(total_net_exposure,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
	--							ELSE ' ROUND(SUM(ISNULL(d_total_net_exposure,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END + 													
								CASE WHEN @group_by = 'b' THEN
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_them,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_them,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
								ELSE
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_us,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_us,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
								END +
								',CAST(0.0 AS NUMERIC(8,3)) AS [GrossExposureConcentration%],CAST(0.0 AS NUMERIC(8,3)) AS [NetExposureConcentration%]					
								 INTO '+@table+' FROM credit_exposure_detail ced WHERE 1=1 '		
*/
					END	
					ELSE IF @summary_option  = 'k'
					BEGIN
						-- @summary_option  = 'k' -- Drill Down for Term
						GOTO TermDrillDown
					END		
					ELSE
					BEGIN



--
--						SELECT @sql_orderby = CASE @summary_option  
--							WHEN 'f' THEN 'ORDER BY counterparty_name' ELSE @sql_orderby END 
--								+ CASE WHEN @tenor_option = 'u' THEN ',CONVERT(DATETIME,SUBSTRING(ced.agg_term_start,1,0))' ELSE ',CAST(dbo.FNADateFormat(term_start) AS DATETIME)' End

							ConcentrationReport:	
							SELECT @sql_stmt =@sql_stmt +
								CASE WHEN @group_by IN ('b','p','c') THEN
									CASE WHEN  @group_by = 'b' THEN  ' ROUND(MAX(total_limit_received), '+CAST(@round_value AS VARCHAR)+')[Limit],'
									ELSE  ' ROUND(MAX(total_limit_provided), '+CAST(@round_value  AS VARCHAR)+') [Limit],' END 							ELSE '' END +
								CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(gross_exposure), '+ CAST(@round_value  AS VARCHAR)+') [Gross Exposure],'
								ELSE ' ROUND(SUM(d_gross_exposure),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'	END +
	--							CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(total_net_exposure,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
	--							ELSE ' ROUND(SUM(ISNULL(d_total_net_exposure,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END + 													
								CASE WHEN @group_by = 'b' THEN
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_them,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_them,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
								ELSE
									CASE WHEN @present_future = 'u' THEN ' ROUND(SUM(ISNULL(net_exposure_to_us,0)),'+ CAST(@round_value  AS VARCHAR)+') [Net Exposure] '
									ELSE ' ROUND(SUM(ISNULL(d_net_exposure_to_us,0)),'+CAST(@round_value  AS VARCHAR)+') [Net Exposure] ' END 
								END +
								',CAST(0.0 AS NUMERIC(30,3)) AS [Gross Exposure Concentration %],CAST(0.0 AS NUMERIC(30,3)) AS [Net Exposure Concentration %]					
								 INTO '+@table+' FROM credit_exposure_detail ced WHERE 1=1 '							
					END
				END -- ELSE IF @report_type = 'c'
				ELSE IF @report_type = 'e'
				BEGIN
				
					IF @summary_option  = 's' AND @tenor_option <> 's'
					BEGIN
					
						SELECT @sql_group_by = @sql_group_by + 
							CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ' ,term_start' END

						SELECT @sql_orderby  = @sql_orderby  + CASE WHEN @tenor_option = 'u' THEN ',CAST(LEFT(ced.agg_term_start,10) AS DATETIME)' ELSE ',ced.term_start' End

						SELECT @sql_stmt  = @sql_stmt +	
								CASE WHEN @tenor_option = 'u' THEN ' agg_term_start [Term],'
								ELSE ' dbo.FNADateFormat(term_start) [Term],' END +
								CASE WHEN @group_by = 'b'THEN 'SUM(gross_exposure_to_them)' ELSE 'SUM(gross_exposure)' END + ' [Gross Exposure],'+						
								CASE WHEN @group_by = 'b'THEN
									CASE WHEN @present_future = 'u' THEN  'ROUND(SUM(ISNULL(net_exposure_to_them,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]'
										ELSE 'ROUND(SUM(ISNULL(d_net_exposure_to_them,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]' END
								ELSE						
									CASE WHEN @present_future = 'u' THEN 'ROUND(SUM(ISNULL(net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]'
										ELSE 'ROUND(SUM(ISNULL(d_net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]' END END +  
							' INTO '+@table+' FROM credit_exposure_detail ced WHERE 1=1 '	
					END							
					ELSE IF @summary_option  = 's' AND @tenor_option = 's'
					BEGIN
					
						IF @group_by = 'b'
						BEGIN
							SELECT @sql_stmt  = @sql_stmt +	
							'ROUND(MAX(total_limit_received), '+CAST(@round_value AS VARCHAR)+')[Limit],'+
							CASE WHEN @present_future = 'u' THEN  'ROUND(SUM(ISNULL(net_exposure_to_them,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure],'
								ELSE 'ROUND(SUM(ISNULL(d_net_exposure_to_them,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure],' END+
							CASE WHEN @present_future = 'u' THEN 'ROUND(MAX(limit_to_them_avail), '+CAST(@round_value AS VARCHAR)+') [Limit Available],'
								ELSE 'ROUND(MAX(d_limit_to_them_avail), '+CAST(@round_value AS VARCHAR)+') [Limit Available],' END +
							CASE WHEN @present_future = 'u' THEN  'ROUND(MAX(limit_to_them_variance), '+CAST(@round_value AS VARCHAR)+') [Limit Variance],'
								ELSE 'ROUND(MAX(d_limit_to_them_variance), '+CAST(@round_value AS VARCHAR)+') [Limit Variance],' END +
							'CASE WHEN (MAX(limit_to_them_violated) = 1) THEN ''Yes'' ELSE ''No'' END [Limit Violation]'+
							+' into '+@table+' FROM credit_exposure_detail ced  WHERE 1=1 '
						END
						ELSE IF @group_by IN ('p','c')
						BEGIN						
							
							EXEC spa_print 'i m here'
							SELECT @sql_stmt  = @sql_stmt +
							'MAX(tenor_days) [Tenor Days],
							MAX(tenor_limit) [Tenor Days Limit],
							CASE WHEN (MAX(tenor_limit_violated) = 1) THEN ''Yes'' ELSE ''No'' END [Tenor Violation],
							ROUND(MAX('+CASE WHEN @group_by = 'p' THEN 'CASE WHEN counterparty_name = parent_counterparty_name THEN total_limit_provided ELSE 0 END' ELSE 'total_limit_provided' END+'), '+CAST(@round_value AS VARCHAR)+') [Limit],'+
							CASE WHEN @present_future = 'u' THEN 'ROUND(SUM(gross_exposure), '+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'
								ELSE 'ROUND(SUM(d_gross_exposure),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure]			,' END +
							CASE WHEN @present_future = 'u' THEN 'ROUND(SUM(ISNULL(net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure],'
								ELSE 'ROUND(SUM(ISNULL(net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure],' END + 
							--CASE WHEN @present_future = 'u' THEN 'ROUND(MAX('+CASE WHEN @group_by = 'p' THEN 'CASE WHEN counterparty_name = parent_counterparty_name THEN limit_to_us_avail ELSE 0 END' ELSE 'limit_to_us_avail' END+'), '+CAST(@round_value AS VARCHAR)+') [Limit Available],'
							--	ELSE 'ROUND(MAX('+CASE WHEN @group_by = 'p' THEN 'CASE WHEN counterparty_name = parent_counterparty_name THEN d_limit_to_us_avail ELSE 0 END' ELSE 'd_limit_to_us_avail' END+'), '+CAST(@round_value AS VARCHAR)+') [Limit Available],' END + 
							--CASE WHEN @present_future = 'u' THEN 'ROUND(MAX('+CASE WHEN @group_by = 'p' THEN 'CASE WHEN counterparty_name = parent_counterparty_name THEN limit_to_us_variance ELSE 0 END' ELSE 'limit_to_us_variance' END+'), '+CAST(@round_value AS VARCHAR)+') [Limit Variance],'
							--	ELSE 'ROUND(MAX('+CASE WHEN @group_by = 'p' THEN 'CASE WHEN counterparty_name = parent_counterparty_name THEN d_limit_to_us_variance ELSE 0 END' ELSE 'd_limit_to_us_variance' END+'), '+CAST(@round_value AS VARCHAR)+') [Limit Variance],' END +
							+'ROUND(CASE WHEN MAX('+CASE WHEN @group_by = 'p' THEN 'CASE WHEN counterparty_name = parent_counterparty_name THEN total_limit_provided ELSE 0 END' ELSE 'total_limit_provided' END+')-'+
							CASE WHEN @present_future = 'u' THEN 'SUM(ISNULL(net_exposure_to_us,0))'
								ELSE 'SUM(ISNULL(net_exposure_to_us,0))' END +' > 0 THEN MAX('+CASE WHEN @group_by = 'p' THEN 'CASE WHEN counterparty_name = parent_counterparty_name THEN total_limit_provided ELSE 0 END' ELSE 'total_limit_provided' END+')-'+
							CASE WHEN @present_future = 'u' THEN 'SUM(ISNULL(net_exposure_to_us,0))'
								ELSE 'SUM(ISNULL(net_exposure_to_us,0))' END +' ELSE 0 END , '+CAST(@round_value AS VARCHAR)+') [Limit Available],'

							+'ROUND(MAX('+CASE WHEN @group_by = 'p' THEN 'CASE WHEN counterparty_name = parent_counterparty_name THEN total_limit_provided ELSE 0 END' ELSE 'total_limit_provided' END+')-'+
							CASE WHEN @present_future = 'u' THEN 'SUM(ISNULL(net_exposure_to_us,0))'
								ELSE 'SUM(ISNULL(net_exposure_to_us,0))' END +', '+CAST(@round_value AS VARCHAR)+') [Limit Variance],'
							+'CASE WHEN (MAX(limit_to_us_violated) = 1) THEN ''Yes'' ELSE ''No'' END [Limit Violation]
							INTO '+@table+' FROM credit_exposure_detail ced WHERE 1=1'				
						END
						ELSE 
						BEGIN					
							SELECT @sql_stmt  = @sql_stmt +
--							'MAX(tenor_days) [TenorDays],
--							MAX(tenor_limit) [TenorDaysLimit],
--							CASE WHEN (MAX(tenor_limit_violated) = 1) THEN ''Yes'' ELSE ''No'' END [TenorViolation],
--							ROUND(MAX(total_limit_provided), '+CAST(@round_value AS VARCHAR)+') [Limit],'+
							CASE WHEN @present_future = 'u' THEN 'ROUND(SUM(gross_exposure), '+CAST(@round_value AS VARCHAR)+') [Gross Exposure],'
								ELSE 'ROUND(SUM(d_gross_exposure),'+CAST(@round_value AS VARCHAR)+') [Gross Exposure]			,' END +
							CASE WHEN @present_future = 'u' THEN 'ROUND(SUM(ISNULL(net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]'
								ELSE 'ROUND(SUM(ISNULL(d_total_net_exposure,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]' END + 
--							CASE WHEN @present_future = 'u' THEN 'ROUND(MAX(limit_to_us_avail), '+CAST(@round_value AS VARCHAR)+') [LimitAvailable],'
--								ELSE 'ROUND(MAX(d_limit_to_us_avail), '+CAST(@round_value AS VARCHAR)+') [LimitAvailable],' END + 
--							CASE WHEN @present_future = 'u' THEN 'ROUND(MAX(limit_to_us_variance), '+CAST(@round_value AS VARCHAR)+') [LimitVariance],'
--								ELSE 'ROUND(MAX(d_limit_to_us_variance), '+CAST(@round_value AS VARCHAR)+') [LimitVariance],' END +
--							'CASE WHEN (MAX(limit_to_us_violated) = 1) THEN ''Yes'' ELSE ''No'' END [LimitViolation]
							' INTO '+@table+' FROM credit_exposure_detail ced WHERE 1=1'				
						END
					END
					ELSE IF @summary_option = 'd' AND @drill_counterparty IS NULL
					BEGIN
						SELECT @sql_stmt = '',@sql_group_by = ''
						SELECT @sql_stmt  = '
							SELECT dbo.FNADateFormat(as_of_date) [As of Date],
								--curve_source_value_id [Curve Source value id],'+
								@curveSource +' [Curve Source Value ID],
								--Netting_Parent_Group_ID [Netting Parent Group ID],
								Netting_Parent_Group_Name [Parent Netting Group],
								--Netting_Group_ID [Netting Group ID],
								Netting_Group_Name [Netting Group],
	--							Netting_Group_Detail_ID  [Netting Group Detail ID],
								CASE WHEN  CAST(Netting_Group_Detail_ID AS VARCHAR) =  -1 THEN ''Unselected'' ELSE CAST(Netting_Group_Detail_ID AS VARCHAR) END  [Group Applies To] ,
	--							fas_subsidiary_id [Fas Subsidiary ID],
	--							fas_strategy_id [Fas Strategy ID],
	--							fas_book_id [Fas Book ID],
								subs.entity_name [Sub],
								strt.entity_name [Strategy],
								book.entity_name [Book],
								Source_Deal_Header_ID [Source Deal Header ID],
								ced.Source_Counterparty_ID [Source Counterparty ID],
								dbo.FNADateFormat(term_start) [Term Start],
								agg_term_start [Agg Term Start],'+
								CASE WHEN @present_future = 'u' 
								THEN 'Final_Und_Pnl'
								ELSE 'Final_Dis_Pnl ' END+' [Final PNL],'+
								'legal_entity [Legal Entity],
	--							exp_type_id [Exp Type ID],
								exp_type [Exp Type],'+
								CASE WHEN @present_future = 'u' 
								THEN 'gross_exposure'
								ELSE 'd_gross_exposure ' END+'  [Gross Exposure],
								invoice_due_date [Invoice Due Date],
								aged_invoice_days [Aged Invoice Days],
	--							netting_counterparty_id [Netting Counterparty],
								sc.counterparty_name [Netting Counterparty],
								ced.counterparty_name [Counterparty],
								parent_counterparty_name [Parent Counterparty],
								counterparty_type [Counterparty Type],
								risk_rating [Risk Rating],
								debt_rating [Debt Rating],
								industry_type1 [Industry Type1],
								industry_type2 [Industry Type2],
								sic_code [SIC Code],
								account_status [Account Status],
								currency_name [Currency],
								watch_list [Watch List],
	--							ced.int_ext_flag [Counterparty Group],
								tenor_limit [Tenor Limit],
								tenor_days [Tenor Days],
								total_limit_provided [Total Limit Provided],
								total_limit_received [Total Limit Received],'+
								CASE WHEN @present_future = 'u' 
								THEN 'net_exposure_to_us'
								ELSE 'd_net_exposure_to_us ' END+' [Net Exposure To Us],'+
								CASE WHEN @present_future = 'u' 
								THEN 'net_exposure_to_them'
								ELSE 'd_net_exposure_to_them ' END+' [Net Exposure For Them],'+
								CASE WHEN @present_future = 'u' 
								THEN 'total_net_exposure'
								ELSE 'd_total_net_exposure ' END+' [Total Net Exposure],'+
								CASE WHEN @present_future = 'u' 
								THEN 'limit_to_us_avail'
								ELSE 'd_limit_to_us_avail ' END+' [Limit To Us Available],'+
								CASE WHEN @present_future = 'u' 
								THEN 'limit_to_them_avail'
								ELSE 'd_limit_to_them_avail' END+' [Limit From Them Available],
								CASE WHEN (limit_to_us_violated = 1) THEN ''Yes'' ELSE ''No'' END [Limit To Us Violated],
								CASE WHEN (limit_to_them_violated = 1) THEN ''Yes'' ELSE ''No'' END [Limit From Them Violated],
								CASE WHEN (tenor_limit_violated = 1) THEN ''Yes'' ELSE ''No'' END [Tenor Limit Violated],'+
								CASE WHEN @present_future = 'u' 
								THEN 'limit_to_us_variance'
								ELSE 'd_limit_to_us_variance' END+' [Limit To Us Variance],'+
								CASE WHEN @present_future = 'u' 
								THEN 'limit_to_them_variance'
								ELSE 'd_limit_to_them_variance' END+' [Limit From Them Variance]
							INTO '+@table+' FROM credit_exposure_detail ced
								JOIN portfolio_hierarchy subs
								ON subs.entity_id = ced.fas_subsidiary_id
								JOIN portfolio_hierarchy strt
								ON 	strt.entity_id = ced.fas_strategy_id	
								JOIN portfolio_hierarchy book
								ON book.entity_id = ced.fas_book_id	
								JOIN source_counterparty sc
								ON sc.source_counterparty_id = 	ced.netting_counterparty_id
						WHERE 1=1'	
					END
					ELSE IF (@summary_option = 'd' OR @summary_option = 'n') AND @drill_counterparty IS NOT NULL
					BEGIN			
		
						-- @summary_option = 'd' -- Drill Down of Gross Exposure
						-- @summary_option = 'n' -- Drill Down of Net Exposure						
						GrossNetDrillDown:

--						SELECT @sql_group_by = CASE WHEN @tenor_option = 'u' THEN ' GROUP BY counterparty_name,agg_term_start' ELSE ' GROUP BY counterparty_name ,term_start' End
--						SELECT @sql_orderby  = CASE WHEN @tenor_option = 'u' THEN ' ORDER BY counterparty_name,ced.agg_term_start' ELSE ' ORDER BY counterparty_name,ced.term_start' End
--						SELECT @sql_group_by = @sql_group_by + CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ' ,term_start' End
--						SELECT @sql_orderby  = @sql_orderby  + CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ' ,term_start' End


--						IF @summary_option  = 's' and @tenor_option <> 's'
--							SELECT @sql_group_by = @sql_group_by 							
--								+ CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ',dbo.FNADateFormat(term_start)' END						

--						
--							SELECT @sql_group_by = 
--								CASE @summary_option  WHEN 's' THEN @sql_group_by 							
--									+ CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ',dbo.FNADateFormat(term_start)' END 
--								ELSE  ' GROUP BY ced.counterparty_name' + CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ' ,term_start' END
--								END

							SELECT @sql_group_by = 
								CASE @checkFlag  WHEN 'y' THEN @sql_group_by 							
									+ CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ',term_start' END 
								ELSE  ' GROUP BY ced.counterparty_name' + CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ' ,term_start' END
								END


							SELECT @sql_orderby  = 
								CASE @checkFlag  WHEN 'y' THEN @sql_orderby 							
									+ CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ',term_start' END 
								ELSE ' ORDER BY MAX(ced.counterparty_name)'  + CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ' ,term_start' END 
								END

--						SELECT @sql_group_by = ' GROUP BY ced.counterparty_name' + CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ' ,term_start' End

--						SELECT @sql_orderby  = ' ORDER BY MAX(ced.counterparty_name)'  + CASE WHEN @tenor_option = 'u' THEN ',agg_term_start' ELSE ' ,term_start' End
						
						--SELECT @sql_orderby = ''
		
						SELECT @sql_stmt  = '
							SELECT MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],'+
							CASE WHEN @checkFlag = 'y' 
							  THEN @col + '[' + @graph_cloumn + '],' 
								ELSE ' MAX(ced.counterparty_name) [Counterparty Name],'END +								
								CASE WHEN @tenor_option = 'u' THEN ' agg_term_start [Term],'
								ELSE ' dbo.FNADateFormat(term_start) [Term],' END +
								CASE WHEN @group_by = 'b' THEN 'SUM(gross_exposure_to_them)' ELSE 'SUM(gross_exposure)' END + ' [Gross Exposure],'+						
								CASE WHEN @group_by = 'b' THEN
									CASE WHEN @present_future = 'u' THEN  'ROUND(SUM(ISNULL(net_exposure_to_them,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]'
										ELSE 'ROUND(SUM(ISNULL(d_net_exposure_to_them,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]' END
								ELSE						
									CASE WHEN @present_future = 'u' THEN 'ROUND(SUM(ISNULL(net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]'
										ELSE 'ROUND(SUM(ISNULL(d_net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]' END END +  
							' INTO '+@table+' FROM credit_exposure_detail ced WHERE 1=1 '			
		
					END
					ELSE IF @summary_option = 'c' 
					BEGIN 
					-- @summary_option  = 'c' -- Drill Down for Credit Limit							
						CreditLimitDrillDown:
						
						SELECT @sql_stmt = '',@sql_group_by = ' GROUP BY scp.counterparty_name',@sql_orderby  = ' ORDER BY [As Of Date]'

						SELECT @sql_stmt  = '
							SELECT	MAX(scp.Source_Counterparty_ID) [Source Counterparty ID],'''+ dbo.FNADateFormat(@as_of_date)+''' [As Of Date],
								scp.counterparty_name Counterparty,'+
								CASE WHEN @group_by ='b'
									THEN ' MAX(ISNULL(cci.credit_limit_from, 0)) '
								ELSE ' MAX(ISNULL(cci.credit_limit, 0)) ' END +' [Unsecured Limit],'+
								CASE WHEN @group_by ='b' THEN ' SUM(CASE WHEN(margin = ''n'') THEN ISNULL(amount, 0) else 0 end) [Enhancement],' 
									ELSE ' SUM(case when(margin = ''y'') THEN ISNULL(amount, 0) else 0 end) [Enhancement] ,' END +'
								MAX(sc.currency_name) [Currency] into '+@table+'
							FROM 
								counterparty_credit_info cci 
								LEFT OUTER JOIN	source_counterparty scp on scp.source_counterparty_id = cci.counterparty_id 
								LEFT OUTER JOIN counterparty_credit_enhancements cce ON cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
									AND ''' +CAST(@as_of_date AS varchar) + ''' BETWEEN isnull(cce.eff_date,'''+cast(@as_of_date AS varchar)+''') and isnull(cce.expiration_date,'''+cast(@as_of_date AS varchar)+''')								 
									AND cce.exclude_collateral = ''n''
								LEFT OUTER JOIN	 source_currency sc on sc.source_currency_id = cci.curreny_code
								JOIN (SELECT DISTINCT source_counterparty_id from credit_exposure_detail ) ced
									 ON ced.Source_Counterparty_ID = scp.source_counterparty_id						
							WHERE 1 =1 '		
					END 
					ELSE IF @summary_option = 'r' 
					BEGIN
						-- @summary_option = 'r' -- Drill Down for Risk Rating
						SELECT @sql_stmt = '',@sql_group_by = ''
						SELECT @sql_stmt  = '
							SELECT ced.Source_Counterparty_ID [Source Counterparty ID],
								dbo.FNAHyperLinkText(10101122,counterparty_name,source_counterparty_id) [Counterparty],
								parent_counterparty_name [Parent Counterparty], '+
								CASE WHEN @tenor_option = 'u' THEN ' agg_term_start [Term],'
									ELSE ' dbo.FNADateFormat(term_start) [Term],' END +		
								'risk_rating [Risk Rating],
								debt_rating [Debt Rating],
								tenor_limit  [Tenor Limit Days] into '+@table+'
							FROM credit_exposure_detail ced WHERE 1=1 '
					END 
					ELSE IF @summary_option = 'k'
					BEGIN	
						--	@summary_option = 'k' -- Drill Down for Term
						TermDrillDown:

						SELECT @sql_stmt = '',@sql_group_by = '', @sql_Orderby = ''
									
						SELECT @sql_Orderby = ' ORDER BY [Counterparty]'
						
						SELECT @sql_group_by = CASE WHEN @tenor_option = 'u' THEN ' GROUP BY ced.source_deal_header_id,counterparty_name,agg_term_start,exp_type'													
												ELSE ' GROUP BY ced.source_deal_header_id,counterparty_name,term_start,exp_type' END	

						--',exp_type AS [EXPType],SUM('+@col+') AS [Exposure]
						SELECT @sql_stmt ='
							SELECT  dbo.FNAHyperLinkText(10131010, cast(ced.source_deal_header_id as VARCHAR),ced.source_deal_header_id) [Source Deal Header ID],
									MAX(ced.Source_Counterparty_ID) [Source Counterparty ID],
									ced.counterparty_name [Counterparty],
			 						'+
									CASE WHEN @tenor_option = 'u' THEN ' agg_term_start [Term]'
										 ELSE ' dbo.FNADateFormat(term_start) [Term]' END +									
									',exp_type AS [EXP Type],'+
										CASE WHEN @present_future = 'u' THEN ' SUM(Final_Und_Pnl) ' ELSE ' SUM(Final_Dis_Pnl) ' END +' AS [Value],'
								+ CASE WHEN @group_by = 'b' THEN 'SUM(gross_exposure_to_them)' ELSE 'SUM(gross_exposure)' END + ' [Gross Exposure],'+						
								CASE WHEN @group_by = 'b'THEN
									CASE WHEN @present_future = 'u' THEN  'ROUND(SUM(ISNULL(net_exposure_to_them,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]'
										ELSE 'ROUND(SUM(ISNULL(d_net_exposure_to_them,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]' END
								ELSE						
									CASE WHEN @present_future = 'u' THEN 'ROUND(SUM(ISNULL(net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]'
										ELSE 'ROUND(SUM(ISNULL(d_net_exposure_to_us,0)), '+CAST(@round_value AS VARCHAR)+') [Net Exposure]' END END +  
							' INTO '+@table+' 
							FROM 
								credit_exposure_detail ced 
							LEFT OUTER JOIN counterparty_credit_info 
								ON Counterparty_id = ced.Source_Counterparty_ID 
							WHERE 1=1 '		
					END -- ELSE IF @summary_option = 'k'
				END --  ELSE IF @report_type = 'e'
			END -- END FOR ELSE OF "IF @summary_option = 'd' and @report_type <> 'e'" 


		/************************************************************************************************************/
										--  FILTER CHECK
		/************************************************************************************************************/		
			IF @as_of_date IS NOT NULL
			BEGIN

				IF @summary_option <> 'c' 				
/*					SELECT @sql_where = CASE WHEN @summary_option = 'c' THEN ' AND ''' +dbo.FNADateFormat(@as_of_date) + ''' BETWEEN isnull(cce.eff_date,'''+dbo.FNADateFormat(@as_of_date)+''') and isnull(cce.expiration_date,'''+dbo.FNADateFormat(@as_of_date)+''')'
										ELSE ' AND ''' +dbo.FNADateFormat(@as_of_date) + ''' BETWEEN isnull(eff_date,'''+dbo.FNADateFormat(@as_of_date)+''') and isnull(expiration_date,'''+dbo.FNADateFormat(@as_of_date)+''')' END					*/
					--SELECT @sql_where = ' AND ''' +CAST(@as_of_date AS varchar) + ''' BETWEEN isnull(cce.eff_date,'''+cast(@as_of_date AS varchar)+''') and isnull(cce.expiration_date,'''+cast(@as_of_date AS varchar)+''')'										
				--ELSE
					SELECT @sql_where = ' AND ced.as_of_date = '''+ cast(@as_of_date AS varchar)+''''
			END			


			IF @counterparty_id IS NOT NULL
				SELECT @sql_where=@sql_where +
					CASE 
						WHEN @summary_option = 'c' THEN ' AND scp.source_counterparty_id IN(' + CAST(@counterparty_id AS VARCHAR(MAX)) +') '
						 ELSE ' AND ced.Source_Counterparty_ID	IN( ' + CAST(@counterparty_id AS VARCHAR(MAX)) + ') ' 
					END

			IF @counterparty_entity_type IS NOT NULL
				SELECT @sql_where=@sql_where +
					CASE WHEN @summary_option = 'c' THEN ' AND scp.type_of_entity = '''+CAST(@counterparty_entity_type AS VARCHAR(MAX))+''''
						ELSE ' AND ced.counterparty_type = '''+CAST(@counterparty_entity_type_tmp AS VARCHAR(MAX))+'''' END

			IF @counterparty_type IS NOT NULL
				SELECT @sql_where=@sql_where + 
					CASE WHEN @summary_option = 'c' THEN ' AND scp.int_ext_flag = '''+@counterparty_type +''''
						 ELSE ' AND ced.int_ext_flag = '''+@counterparty_type +'''' END
				
			IF @risk_rating IS NOT NULL
			BEGIN			
				SELECT @sql_where=@sql_where + 
					CASE WHEN @summary_option = 'c' THEN ' AND cci.Risk_rating = '+CAST(@risk_rating AS VARCHAR(MAX))
						 ELSE ' AND ced.risk_rating_id = '+CAST(@risk_rating AS VARCHAR(MAX)) END 
			END

			IF @debt_rating IS NOT NULL
			BEGIN				
				SELECT @sql_where=@sql_where + 
					CASE WHEN @summary_option = 'c' THEN ' AND cci.Debt_rating = '+CAST(@debt_rating AS VARCHAR(MAX))
						 ELSE ' AND ced.debt_rating_id = '+CAST(@debt_rating AS VARCHAR(MAX)) END
			END

			IF @industry_type1 IS NOT NULL
			BEGIN				
				SELECT @sql_where=@sql_where + 
					CASE WHEN @summary_option = 'c' THEN ' AND cci.Industry_type1 = '+CAST(@industry_type1 AS VARCHAR(MAX))
						 ELSE ' AND ced.industry_type1_id = '+CAST(@industry_type1 AS VARCHAR(MAX)) END
			END

			IF @industry_type2 IS NOT NULL
			BEGIN				
				SELECT @sql_where=@sql_where + 
					CASE WHEN @summary_option = 'c' THEN ' AND cci.Industry_type2 = '+CAST(@industry_type2 AS VARCHAR(MAX))
						 ELSE ' AND ced.industry_type2_id = '+CAST(@industry_type2 AS VARCHAR(MAX)) END
			END

			IF @sic_code IS NOT NULL														
			BEGIN 				
				SELECT @sql_where=@sql_where + 
					CASE WHEN @summary_option = 'c' THEN ' AND cci.SIC_Code = '+CAST(@sic_code AS VARCHAR(MAX))				
						 ELSE ' AND ced.sic_code_id = '+CAST(@sic_code AS VARCHAR(MAX)) END
			END

			IF @summary_option <> 'c' --vk
			BEGIN
				IF @term_start IS NOT NULL 				
					SELECT @sql_where=@sql_where + 
							 ' AND ced.term_start > =  '''+ CAST(@term_start AS VARCHAR(100))+'''' 
				
				IF @term_end IS NOT NULL 					
					SELECT @sql_where=@sql_where +
							 ' AND ced.term_start < =  '''+ CAST(@term_end as VARCHAR(100))+'''' 

  				 IF @nettingParentGroup IS NOT NULL
					SELECT @sql_where=@sql_where + ' AND ced.Netting_Parent_Group_ID	= '+ CAST(@nettingParentGroup AS VARCHAR(MAX))

			    IF @sub_entity_id IS NOT NULL
					SELECT @sql_where=@sql_where+' AND ced.fas_subsidiary_id IN ( ' + @sub_entity_id + ') '
				
				IF @strategy_entity_id IS NOT NULL
					SELECT @sql_where=@sql_where+' AND ced.fas_strategy_id IN ( ' + @strategy_entity_id + ') '

				IF @book_entity_id IS NOT NULL
					SELECT @sql_where=@sql_where+' AND ced.fas_book_id IN ( ' + @book_entity_id + ') '

				IF @show_exceptions = 'y'					
					SELECT  @sql_where=@sql_where+' AND (((ced.limit_to_us_violated = 1 OR ced.tenor_limit_violated=1) AND '''+@group_by+'''<>''b'') OR (ced.limit_to_them_violated=1 AND '''+@group_by+'''=''b''))'

				IF @curve_source IS NOT NULL
					SELECT @sql_where=@sql_where+ ' AND ced.curve_source_value_id = '+CAST(@curve_source AS VARCHAR)				
			END

			SELECT @sql_where = @sql_where + 
				CASE WHEN @summary_option = 'c' THEN ' AND ISNULL(cci.Watch_list,''n'') = '''+@watch_list+'''' 								
					ELSE ' AND ISNULL(ced.watch_list,''n'') = '''+@watch_list+'''' END		
				+CASE WHEN @account_status IS NOT NULL THEN  ' AND account_status=(SELECT code FROM static_data_value where value_id='+CAST(@account_status AS VARCHAR)+')' ELSE '' END

						
		/************************************************************************************************************/
										-- DRILL DOWN VALIDATION 	
		/************************************************************************************************************/

			IF @drill_term IS NOT NULL 	--AND @tenor_option<>'u'				
				SELECT @sql_where=@sql_where + CASE WHEN @tenor_option = 'u' THEN ' AND ced.agg_term_start =  ''' + @drill_term +''''				
					 ELSE ' AND ced.term_start = '''  + @drill_term +'''' END				


			IF @drill_counterparty IS NOT NULL
			BEGIN	
				IF @group_by IN ('c','p','b') OR @summary_option <> 'c' 
				BEGIN
					IF @drill_counterparty = ''
						SELECT @drill_counterparty = ' IS NULL'

					ELSE IF @group_by = 'd'					
						SELECT @drill_counterparty = 'LIKE ' + ''''+ LTRIM(RTRIM(@drill_counterparty))+'%'''

					ELSE 				
						SELECT @drill_counterparty = '= ' + ''''+ @drill_counterparty+''''
						
				END

--ddd
--				IF @summary_option = 'k' and @tenor_option = 's'
--					SELECT @sql_where=@sql_where+' AND ced.counterparty_name ' + @drill_counterparty
--				ELSE 
				IF @summary_option = 'c' 
				BEGIN
					DECLARE @groupbyId INT

					IF @group_by NOT IN ('c','p','b')
					BEGIN
						SELECT @groupbyId = value_id FROM static_data_value WHERE code = @drill_counterparty
	
						IF @groupbyId IS NOT NULL OR @groupbyId = ''					
								SELECT @drill_counterparty = '= ' + CAST(@groupbyId AS VARCHAR)
						ELSE
								SELECT @drill_counterparty =  ' IS NULL'
					END

					IF @group_by IN ('p','c','b') 
						SELECT @sql_where=@sql_where+' AND scp.counterparty_name ' + @drill_counterparty
					ELSE IF @group_by ='e'						
						SELECT @sql_where=@sql_where+' AND scp.type_of_entity  ' + @drill_counterparty -- CAST(@groupbyId AS VARCHAR)					
					ELSE IF @group_by ='r'					
						SELECT @sql_where=@sql_where+' AND cci.Risk_rating  ' + @drill_counterparty -- CAST(@groupbyId AS VARCHAR)		
					ELSE IF @group_by ='d'
						SELECT @sql_where=@sql_where+' AND cci.Debt_rating  ' + @drill_counterparty -- CAST(@groupbyId AS VARCHAR)	
					ELSE IF @group_by ='i'
						SELECT @sql_where=@sql_where+' AND cci.Industry_type1  ' + @drill_counterparty -- CAST(@groupbyId AS VARCHAR)	
					ELSE IF @group_by ='t'
						SELECT @sql_where=@sql_where+' AND cci.Industry_type2  ' + @drill_counterparty -- CAST(@groupbyId AS VARCHAR)	
					ELSE IF @group_by ='s'										
						SELECT @sql_where=@sql_where+' AND cci.SIC_Code  ' + @drill_counterparty --CAST(@groupbyId AS VARCHAR)												
				END
				ELSE IF @summary_option = 'k' and @tenor_option = 's'
					SELECT @sql_where=@sql_where+' AND ced.counterparty_name ' + @drill_counterparty
				ELSE IF @summary_option IN ('d','n','f','k','m')-- and @tenor_option <> 's'
				BEGIN
--					IF @tenor_option <> 's'
--					IF @tenor_option = 's'
--						SELECT @sql_where=@sql_where+' AND ced.counterparty_name ' + @drill_counterparty
--					ELSE
--					BEGIN
				
						IF @group_by IN ('c','b') 
							SELECT @sql_where=@sql_where+' AND ced.counterparty_name ' + @drill_counterparty
						ELSE IF @group_by = 'p'
							SELECT @sql_where=@sql_where+' AND ced.parent_counterparty_name ' + @drill_counterparty
						ELSE IF @group_by ='e'
							SELECT @sql_where=@sql_where+' AND ced.counterparty_type ' + @drill_counterparty
						ELSE IF @group_by ='r'
							SELECT @sql_where=@sql_where+' AND ced.risk_rating ' + @drill_counterparty
						ELSE IF @group_by ='d'
							SELECT @sql_where=@sql_where+' AND ced.debt_rating ' + @drill_counterparty
						ELSE IF @group_by ='i'
							SELECT @sql_where=@sql_where+' AND ced.industry_type1 ' + @drill_counterparty
						ELSE IF @group_by ='t'
							SELECT @sql_where=@sql_where+' AND ced.industry_type2 ' + @drill_counterparty
						ELSE IF @group_by ='s'										
							SELECT @sql_where=@sql_where+' AND ced.sic_code ' + @drill_counterparty			
--					END
				END				
			END
									

			SELECT @sql_stmt = @sql_stmt + @sql_where + @sql_group_by + @sql_orderby
			EXEC spa_print @sql_stmt
			EXEC (@sql_stmt)

			IF @summary_option = 'd' AND @drill_counterparty IS NULL AND @report_type = 'e'
			BEGIN												
				EXEC('UPDATE '+@table+' SET [Group Applies To] = NULL
				FROM '+@table+' JOIN netting_group_detail  ng							
				ON [Group Applies To] = ng.netting_group_detail_id
				WHERE ng.source_counterparty_id IS NULL
				AND [Group Applies To] <> ''Unselected''')
				EXEC('UPDATE '+@table+' SET [Group Applies To] = sc.counterparty_name	
				FROM '+@table+' JOIN netting_group_detail  ng							
				ON [Group Applies To] = ng.netting_group_detail_id
				JOIN source_counterparty sc
				ON sc.source_counterparty_id = ng.source_counterparty_id							
				AND [Group Applies To] <> ''Unselected''')
				/* If no counterparty exists for the Group Applies To then display it as NULL */
			END

			-- In the concentration report % value has to be calculated from the SUM of Gross/Net Exposure in the table.
			IF (@report_type = 'c' AND @drill_counterparty IS NULL AND @summary_option = 's' AND @tenor_option = 's')
				OR (@report_type = 'g' AND @drill_counterparty IS NULL AND @summary_option IN ('s' ,'d'))
			BEGIN															
				-- Update GrossExposureConcentration%
				EXEC('DECLARE @sumOfGross NUMERIC(30,3) SELECT @sumOfGross = SUM([Gross Exposure])  FROM '+@table +
					 ' UPDATE '+@table+' SET [Gross Exposure Concentration %] = [Gross Exposure] /@sumOfGross WHERE [Gross Exposure]<>0 ') 							

				-- Update NetExposureConcentration%
				EXEC('DECLARE @sumOfNet NUMERIC(30,3) SELECT @sumOfNet = SUM([Net Exposure]) FROM '+@table +
					 ' UPDATE '+@table+' SET [Net Exposure Concentration %] = [Net Exposure]/@sumOfNet WHERE [Net Exposure]<>0 ')																
			END

			SELECT @Columns = ''

			SELECT @Columns =  @Columns +'],' + COLUMN_NAME FROM adiha_process.INFORMATION_SCHEMA.COLUMNS 
				WHERE TABLE_NAME = @table_tmp		
				AND COLUMN_NAME <> 'Source Counterparty ID'
			ORDER BY ORDINAL_POSITION ASC
					
			SELECT @Columns  = REPLACE(@Columns,',',',[')
			SELECT @Columns  = SUBSTRING(@Columns,3,LEN(@Columns))
			SELECT @Columns  = @Columns + ']'

			IF @report_type = 'g'
			BEGIN
				SELECT @sql_stmt = 'SELECT '+@graph_cloumn+',[Net Exposure Concentration %] /*,[Gross Exposure]*/ FROM '+@table+' 
						LEFT OUTER JOIN counterparty_credit_info cci
							ON [Source Counterparty ID] = cci.counterparty_credit_info_id
						LEFT OUTER JOIN counterparty_credit_block_trading ccb
							ON ccb.counterparty_credit_info_id = cci.counterparty_credit_info_id'
			END
			ELSE IF @drill_counterparty IS NOT NULL AND @summary_option IN ('d','n') AND @group_by = 'b'
			BEGIN 	
				
				-- When group by ='b',hide the Net Exposure/Gross Exposure if NULL or Zero 
				 SELECT @sql_stmt = 'SELECT '+@Columns +' FROM '+@table+' 
						LEFT OUTER JOIN counterparty_credit_info cci
							ON [Source Counterparty ID] = cci.counterparty_credit_info_id
						LEFT OUTER JOIN counterparty_credit_block_trading ccb
							ON ccb.counterparty_credit_info_id = cci.counterparty_credit_info_id
						WHERE ' + 
							CASE WHEN @summary_option = 'n' THEN ' [Net Exposure] <> 0 AND [Net Exposure] IS NOT NULL '
							ELSE ' [Gross Exposure] <> 0 AND [Gross Exposure] IS NOT NULL ' END		
				 				
			END
			ELSE
			BEGIN
				 SELECT @sql_stmt = 'SELECT '+@Columns +' FROM '+@table+' 
						LEFT OUTER JOIN counterparty_credit_info cci
							ON [Source Counterparty ID] = cci.counterparty_credit_info_id
						LEFT OUTER JOIN counterparty_credit_block_trading ccb
							ON ccb.counterparty_credit_info_id = cci.counterparty_credit_info_id'			
			END
			--PRINT @sql_stmt
			--EXEC(@sql_stmt)
		END -- IF @report_type IN ('e','f','c','r')
		ELSE 
			BEGIN
				IF @report_type='a' -- Aged A/R report
				BEGIN 
					IF @summary_option = 's' OR (@summary_option = 'd' AND @drill_term IS NULL)
					BEGIN
						SET @sql_stmt = '
							SELECT [Counterparty], 
								MAX([Parent Counterparty]) [Parent Counterparty], 
								CASE WHEN SUM([30 Days AR]) > 0 THEN SUM([30 Days AR]) ELSE 0 END AS [30 Days AR],
								CASE WHEN SUM([60 Days AR]) > 0 THEN SUM([60 Days AR]) ELSE 0 END AS [60 Days AR], 
								CASE WHEN SUM([90 Days+ AR]) > 0 THEN SUM([90 Days+ AR]) ELSE 0 END AS [90 Days+ AR] 
							FROM
									(			
										SELECT 
												counterparty_name as [Counterparty],
												parent_counterparty as [Parent Counterparty],
												[30 Days] AS [30 Days AR],[60 Days] AS [60 Days AR],[90 Days] AS [90 Days+ AR]
										FROM
												(SELECT dbo.FNAHyperLinkText(10101122, sc.counterparty_name, sc.source_counterparty_id) counterparty_name, 
														dbo.FNAHyperLinkText(10101122, parent_counterparty.counterparty_name, parent_counterparty.source_counterparty_id) parent_counterparty,
															(CASE WHEN datediff(day, civv.prod_date, ''' + CAST(@as_of_date AS VARCHAR) + ''') < 30 THEN ''30 Days''
																 WHEN datediff(day, civv.prod_date, ''' + CAST(@as_of_date AS VARCHAR)+ ''') BETWEEN 30 AND 60 THEN ''60 Days''
																 ELSE ''90 Days'' END) AS term,
															(CASE WHEN t.calc_id > 1 THEN	  
																CASE WHEN ISNULL(civ.finalized, ''n'') = ''y'' THEN 
																	CASE WHEN icr.settle_status IS NULL THEN 
																		civ.value 
																	ELSE
																		CASE WHEN icr.settle_status = ''o'' THEN icr.variance_amount ELSE 0 END
																	END  
																ELSE 0 END
															ELSE
																CASE WHEN civ.value > 0 AND ISNULL(civ.finalized, ''n'') = ''y'' THEN 
																	CASE WHEN icr.settle_status IS NULL THEN 
																		civ.value 
																	ELSE
																		CASE WHEN icr.settle_status = ''o'' THEN icr.variance_amount ELSE 0 END
																	END  
																ELSE 0 END
															END
															) AS AR_billed 
												 FROM 
													calc_invoice_volume_variance civv 
													INNER JOIN calc_invoice_volume civ on civv.calc_id = civ.calc_id
														AND civ.manual_input IS NULL
													INNER JOIN source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id
													LEFT JOIN invoice_cash_received icr ON civ.calc_detail_id = icr.save_invoice_detail_id
														--AND icr.settle_status <> ''s''
													LEFT JOIN source_counterparty parent_counterparty on parent_counterparty.source_counterparty_id = sc.parent_counterparty_id
													OUTER APPLY (SELECT COUNT(civ1.calc_id) calc_id from calc_invoice_volume civ1 where civv.calc_id = civ1.calc_id) t
												 WHERE
													1 = 1 
													'+CASE WHEN  @counterparty_id IS NOT NULL THEN ' AND civv.counterparty_id IN(' + CAST(@counterparty_id AS VARCHAR(MAX)) +') ' ELSE '' END
													+' AND civv.as_of_date <= ''' + CAST(@as_of_date AS VARCHAR) + ''''				
													+ CASE WHEN @term_start IS NOT NULL THEN '  AND civv.prod_date BETWEEN ''' + CAST(@term_start AS VARCHAR)+ ''' AND ''' + CAST(@term_end AS VARCHAR)+ '''' ELSE '' END
													+ ') p
												PIVOT(
													SUM(AR_billed) 
													for term in
														([30 Days], [60 Days], [90 Days])
													)
													  AS pvt 
									) a GROUP BY [Counterparty], [Parent Counterparty]'

							--PRINT @sql_stmt
							EXEC(@sql_stmt)
						END
						ELSE
						BEGIN
							CREATE TABLE #tmp_exposure_val (counterparty_name VARCHAR(100) COLLATE DATABASE_DEFAULT, prod_date DATE, gross_exposure FLOAT, net_exposure FLOAT)

							SET @sql_join = ''
								SELECT civ.calc_detail_id save_invoice_detail_id, 
									civv.counterparty_id, 
									civv.prod_date, 
									ISNULL(icr.settle_status, 'o') settle_status 
									INTO #tmp_finalized
								FROM  calc_invoice_volume_variance civv 
								INNER JOIN calc_invoice_volume civ on civv.calc_id = civ.calc_id
								LEFT JOIN invoice_cash_received icr ON civ.calc_detail_id = icr.save_invoice_detail_id
									--AND icr.settle_status = 's'
								INNER JOIN source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id
									AND sc.counterparty_name = @drill_counterparty
								INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_id) scsv ON civv.counterparty_id = scsv.item
								WHERE 1 = 1 
									AND civv.as_of_date <= @as_of_date
									AND civv.prod_date = ISNULL(@drill_term, civv.prod_date)

							IF @drill_term IS NULL
							BEGIN
								IF @summary_option = '3'
									SET @sql_where = @sql_where + ' AND DATEDIFF(DAY, civv.prod_date, ''' + CAST(@as_of_date AS VARCHAR) + ''') < 30'
								ELSE IF @summary_option = '6'
									SET @sql_where = @sql_where + ' AND DATEDIFF(DAY, civv.prod_date, ''' + CAST(@as_of_date AS VARCHAR) + ''') BETWEEN 30 AND 60'
								ELSE IF @summary_option = '9'
									SET @sql_where = @sql_where + ' AND DATEDIFF(DAY, civv.prod_date, ''' + CAST(@as_of_date AS VARCHAR) + ''') > 60'
								ELSE
									SET @sql_where = ''

								IF EXISTS(SELECT TOP 1 1 FROM #tmp_finalized) AND NOT EXISTS(SELECT TOP 1 1 FROM #tmp_finalized WHERE settle_status = 'o')
									SET @sql_where = @sql_where + '
										AND NOT EXISTS (SELECT prod_date FROM #tmp_finalized WHERE prod_date = civv.prod_date)'
											
								SET @sql_stmt = 'INSERT INTO #tmp_exposure_val
								SELECT counterparty_name [Counterparty Name], 
									prod_date [Term], 
									SUM(gross_exposure) [Gross Exposure], 
									SUM(net_exposure) [Net Exposure]	
								FROM (
										SELECT DISTINCT sc.counterparty_name,
											dbo.FNADateFormat(civv.prod_date) [prod_date],
											(CASE WHEN t.calc_id > 1 THEN 
												CASE WHEN icr.settle_status IS NULL THEN 
													civ.value 
												ELSE
													CASE WHEN icr.settle_status = ''o'' THEN icr.variance_amount ELSE 0 END
												END 
											ELSE
												CASE WHEN civ.value > 0 THEN
													CASE WHEN icr.settle_status IS NULL THEN 
														civ.value 
													ELSE
														CASE WHEN icr.settle_status = ''o'' THEN icr.variance_amount ELSE 0 END
													END 
												ELSE 0 END	
											END) [gross_exposure],
											(CASE WHEN t.calc_id > 1 THEN 
												CASE WHEN icr.settle_status IS NULL THEN 
													civ.value 
												ELSE
													CASE WHEN icr.settle_status = ''o'' THEN icr.variance_amount ELSE 0 END
												END 
											ELSE
												CASE WHEN civ.value > 0 THEN
													CASE WHEN icr.settle_status IS NULL THEN 
														civ.value 
													ELSE
														CASE WHEN icr.settle_status = ''o'' THEN icr.variance_amount ELSE 0 END
													END 
												ELSE 0 END
											END) [net_exposure]
										FROM  calc_invoice_volume_variance civv 
										INNER JOIN calc_invoice_volume civ on civv.calc_id = civ.calc_id
											AND civ.finalized = ''y''
											AND civ.manual_input IS NULL
										INNER JOIN source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id
											AND sc.counterparty_name = ''' + @drill_counterparty + '''
										LEFT JOIN invoice_cash_received icr ON civ.calc_detail_id = icr.save_invoice_detail_id
										LEFT JOIN source_counterparty scp on scp.source_counterparty_id = sc.parent_counterparty_id
										OUTER APPLY (SELECT COUNT(civ1.calc_id) calc_id from calc_invoice_volume civ1 where civv.calc_id = civ1.calc_id) t
										WHERE 1 = 1 
											AND civv.as_of_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''
											AND civv.counterparty_id IN(' + @counterparty_id +')
											' + @sql_where + ') t
								WHERE t.gross_exposure <> 0
								GROUP BY counterparty_name, prod_date'

							--	EXEC spa_print @sql_stmt
								EXEC(@sql_stmt)

								SELECT counterparty_name [Counterparty Name], prod_date [Term], gross_exposure [Gross Exposure], net_exposure [Net Exposure]  
								FROM #tmp_exposure_val 
								WHERE( 
								SELECT SUM(gross_exposure) total_gross FROM #tmp_exposure_val group by counterparty_name) > 0

							END			
							ELSE
							BEGIN
								IF EXISTS(SELECT TOP 1 1 FROM #tmp_finalized)
									SET @sql_join = '
										INNER JOIN #tmp_finalized tf ON civv.counterparty_id = tf.counterparty_id
											AND civv.prod_date = tf.prod_date
											AND civ.calc_detail_id = tf.save_invoice_detail_id
											AND tf.settle_status <> ''s'''

								SET @sql_stmt = '
									SELECT counterparty_name [Counterparty Name], 
										exp_type [Exp Type], 
										SUM(gross_exposure) [Gross Exposure], 
										SUM(net_exposure) [Net Exposure] 
									FROM (
										SELECT sc.counterparty_name,
											CASE WHEN civ.value > 0 THEN ''A/R Billed'' ELSE ''A/P Billed'' END [exp_type], 
											(CASE WHEN t.calc_id > 1 THEN
												civ.value 
											ELSE
												CASE WHEN civ.value > 0 THEN 
													civ.value 
												ELSE 0 END
											END) [gross_exposure], 
											(CASE WHEN t.calc_id > 1 THEN
												civ.value 
											ELSE
												CASE WHEN civ.value > 0 THEN 
													civ.value 
												ELSE 0 END
											END) [net_exposure],
											newid() rowN,
											t.calc_id
										FROM  calc_invoice_volume_variance civv 
										INNER JOIN calc_invoice_volume civ on civv.calc_id = civ.calc_id
											AND civ.finalized = ''y''
											AND civ.manual_input IS NULL
										INNER JOIN source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id
											AND sc.counterparty_name = ''' + @drill_counterparty + '''
										OUTER APPLY (SELECT COUNT(civ1.calc_id) calc_id from calc_invoice_volume civ1 where civv.calc_id = civ1.calc_id) t
										' + @sql_join + '
										WHERE 1 = 1 
											AND civv.as_of_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''
											AND civv.prod_date = ''' + CAST(@drill_term AS VARCHAR) + '''
											AND civv.counterparty_id IN(' + @counterparty_id +')
										UNION
										SELECT sc.counterparty_name, 
											CASE WHEN icr.invoice_type = ''r'' THEN ''Cash Received'' ELSE ''Cash Paid'' END [exp_type], 
											(CASE WHEN t.calc_id > 1 THEN
												(icr.cash_received*-1) 
											ELSE
												CASE WHEN civ.value > 0 THEN 
													(icr.cash_received*-1) 
												ELSE 0 END
											END) [gross_exposure], 
											(CASE WHEN t.calc_id > 1 THEN
												(icr.cash_received*-1) 
											ELSE
												CASE WHEN civ.value > 0 THEN 
													(icr.cash_received*-1) 
												ELSE 0 END
											END) [net_exposure],
											newid() rowN,
											t.calc_id
										FROM  calc_invoice_volume_variance civv 
										INNER JOIN calc_invoice_volume civ on civv.calc_id = civ.calc_id
											AND civ.finalized = ''y''
											AND civ.manual_input IS NULL
										INNER JOIN invoice_cash_received icr ON civ.calc_detail_id = icr.save_invoice_detail_id
											AND icr.settle_status <> ''s''
										INNER JOIN source_counterparty sc on sc.source_counterparty_id = civv.counterparty_id
											AND sc.counterparty_name = ''' + @drill_counterparty + '''
										OUTER APPLY (SELECT COUNT(civ1.calc_id) calc_id from calc_invoice_volume civ1 where civv.calc_id = civ1.calc_id) t
										WHERE 1 = 1 
											AND civv.as_of_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''
											AND civv.prod_date = ''' + CAST(@drill_term AS VARCHAR) + '''
											AND civv.counterparty_id IN(' + @counterparty_id +')
									) t WHERE t.gross_exposure <> 0
									GROUP BY counterparty_name, exp_type, CASE WHEN t.calc_id > 1 THEN exp_type  ELSE CAST(t.rowN AS VARCHAR(100)) END
									ORDER BY exp_type'

								--	EXEC spa_print @sql_stmt
									EXEC(@sql_stmt)
							END			 
						END	
				END 
			END
		IF @report_type <> 'a'
		BEGIN
			--PRINT @sql_stmt
			EXEC(@sql_stmt)
		END
	END
