/***************************MODIFICATION HISTORY************************/
/* Vishwas Khanal / Dated : 05 Mar 2009 /Log ID : 424				   */
/* Vishwas Khanal / Dated : 12 Mar 2009 /Log ID : 444				   */
/***********************************************************************/
IF OBJECT_ID('[dbo].[spa_get_Counterparty_Exposure_Report_Paging]','p') IS NOT NULL
DROP PROC [dbo].[spa_get_Counterparty_Exposure_Report_Paging] 
go
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
go

/*
Created By Pawan KC
Date:04 March 2009
Purpose: To show the Pagign Report for the Credit Exposure Report.
Modified By Pawan KC
Date:06 March 2009
Purpose: To Syncronise with the spa_get_Counterparty_Exposure_Report according to changed made.
*/

CREATE  PROC [dbo].[spa_get_Counterparty_Exposure_Report_Paging]
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
					@account_status					INT 					= NULL	,
					@watch_list						CHAR(1)					= 'n'	,
					@tenor_option					CHAR(1)					= 'c'	,
					@ROUND_value					INT						= NULL	,
					@apply_paging					CHAR(1)					= 'n'	,
					@curve_source					INT						= NULL	,
					@nettingParentGroup				INT						= NULL	, 
					@present_future					CHAR(1)					= NULL	,
					@drill_book						VARCHAR(100)			= NULL	,
					@drill_parent_counterparty		VARCHAR(100)			= NULL	,
					@drill_counterparty				VARCHAR(100)			= NULL	,
					@drill_term						VARCHAR(50)				= NULL  , 
					
					@source_system_bookid1			INT						= NULL	,
					@source_system_bookid2			INT						= NULL  ,
					@source_system_bookid3			INT						= NULL	,
					@source_system_bookid4			INT						= NULL  ,
					@trader_id						INT						= NULL  ,		
			
				
					@process_id						varchar(200)			= NULL	, 
					@page_size						int						= NULL	,
					@page_no						int						= NULL 
	
 AS

	SET NOCOUNT ON

	DECLARE @user_login_id  VARCHAR(50)	 ,
			@tempTable		VARCHAR(300) ,
			@flag			CHAR(1)		 ,
			@sqlStmt		VARCHAR(5000)

	SET @user_login_id=dbo.FNADBUser()

	IF @process_id is NULL
	BEGIN
		SET @flag='i'
		SET @process_id=REPLACE(newid(),'-','_')
	END

	SELECT @tempTable=dbo.FNAProcessTableName('paging_temp_Counterparty_Exposure_Report', @user_login_id,@process_id)
	
/*
	exec spa_get_counterparty_exposure_report 'e','d','c','Feb 24 2009 12:00AM','195, 192, 193, 196, 194, 230',NULL,NULL,NULL,NULL,NULL,NULL,'e',
	NULL,NULL,NULL,NULL,NULL,'n','n','n','n','c','2','y','4500','4','u',NULL,NULL,NULL,NULL 

*/

---------------------------------------------------------------------------------------------------------------------------------------------
			--												TABLE CREATION SECTION
---------------------------------------------------------------------------------------------------------------------------------------------


	IF @flag='i' and @report_type = 'e'
	BEGIN
--if @summary_option='s'
		SET @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			AsOfDate VARCHAR(100),
			ParentNettingGroup VARCHAR(100),
			NettingGroup VARCHAR(100),
			GroupAppliesTo VARCHAR(100),
			Sub VARCHAR(100),
			Strategy VARCHAR(100),
			Book VARCHAR(100),
			SourceDealHeaderID VARCHAR(100),
			TermStart VARCHAR(100),
			AggTermStart VARCHAR(100),
			Final_PNL VARCHAR(100),
			LegalEntity VARCHAR(100),
			ExpType VARCHAR(100),
			GrossExposure VARCHAR(100),
			InvoiceDueDate VARCHAR(100),
			AgedInvoiceDays VARCHAR(100),
			NettingCounterparty VARCHAR(100),
			Counterparty VARCHAR(100),
			ParentCounterparty VARCHAR(100),
			CounterpartyType VARCHAR(100),
			RiskRating VARCHAR(100),
			DebtRating VARCHAR(100),
			IndustryType1 VARCHAR(100),
			IndustryType2 VARCHAR(100),
			SICCode VARCHAR(100),
			AccountStatus VARCHAR(100),
			Currency VARCHAR(100),
			WatchList VARCHAR(100),
	--		CounterpartyGroup VARCHAR(100),
			TenorLimit VARCHAR(100),
			TenorDays VARCHAR(100),
			TotalLimitProvided VARCHAR(100),
			TotalLimitReceived VARCHAR(100),
			NetExposureToUs VARCHAR(100),
			NetExposureForThem VARCHAR(100),
			TotalNetExposure VARCHAR(100),
			LimitToUsAvailable VARCHAR(100),
			LimitFromThemAvailable VARCHAR(100),
			LimitToUsViolated VARCHAR(100),
			LimitFromThemViolated VARCHAR(100),
			TenorLimitViolated VARCHAR(100),
			LimitToUsVariance VARCHAR(100),
			LimitFromThemVariance VARCHAR(100)
			)'
			exec(@sqlStmt)
			
		
	END

	ELSE IF @flag='i' AND  @report_type = 'a'
	BEGIN
		
set @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			Counterparty VARCHAR(500),
			ParentCounterparty VARCHAR(500),
			ThirtyDaysAR NUMERIC(38,10),
			SixtyDaysAR NUMERIC(38,10),
			NinetyDaysAR NUMERIC(38,10))'
			exec(@sqlStmt)
			
	END
	
	ELSE IF @flag='i' and @report_type NOT IN ('e','a')
	BEGIN

	--if @summary_option='s'
		set @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			Counterparty VARCHAR(100),
			SourceDealHeaderID VARCHAR(500),
			Commodity VARCHAR(100),
			Term VARCHAR(100),
			GrossExposure VARCHAR(100),
			NetExposure VARCHAR(100),
			Currency VARCHAR(100))'
			exec(@sqlStmt)
	END
	
	

---------------------------------------------------------------------------------------------------------------------------------------------
			--												TABLE INSERTION SECTION
---------------------------------------------------------------------------------------------------------------------------------------------

	IF @flag='i'
	BEGIN

		set @sqlStmt=' insert  '+@tempTable+'
			exec  spa_get_counterparty_exposure_report '+ 
			dbo.FNASingleQuote(@report_type) +','+ 
			dbo.FNASingleQuote(@summary_option) +','+ 
			dbo.FNASingleQuote(@group_by) +','+ 
			dbo.FNASingleQuote(@as_of_date) +','+ 
			dbo.FNASingleQuote(@sub_entity_id) +',' +
			dbo.FNASingleQuote(@strategy_entity_id) +',' +
			dbo.FNASingleQuote(@book_entity_id) +',' +
			dbo.FNASingleQuote(@counterparty_id)+',' +
			dbo.FNASingleQuote(@term_start)+','+
			dbo.FNASingleQuote(@term_end)+','+
			dbo.FNASingleQuote(@counterparty_entity_type)+','+
			dbo.FNASingleQuote(@counterparty_type) +','+
			dbo.FNASingleQuote(@risk_rating) +','+
			dbo.FNASingleQuote(@debt_rating) +','+
			dbo.FNASingleQuote(@industry_type1)+','+
			dbo.FNASingleQuote(@industry_type2)+','+
			dbo.FNASingleQuote(@sic_code)+','+
			dbo.FNASingleQuote(@include_potential)+','+
			dbo.FNASingleQuote(@show_exceptions)+','+
			dbo.FNASingleQuote(@account_status)+','+
			dbo.FNASingleQuote(@watch_list)+','+
			dbo.FNASingleQuote(@tenor_option)+','+
			dbo.FNASingleQuote(@ROUND_value)+','+
			dbo.FNASingleQuote(@apply_paging)+','+
			dbo.FNASingleQuote(@curve_source)+','+
			dbo.FNASingleQuote(@nettingParentGroup)+','+
			dbo.FNASingleQuote(@present_future)

		--	+','+ dbo.FNASingleQuote(@drill_book)+','+
		--	dbo.FNASingleQuote(@drill_parent_counterparty)+','+
		--	dbo.FNASingleQuote(@drill_counterparty)+','+
		--	dbo.FNASingleQuote(@drill_term)
		--	
			
			EXEC spa_print @sqlStmt
			EXEC(@sqlStmt)	

			SET @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
			EXEC spa_print @sqlStmt
			EXEC(@sqlStmt)
	END 
---------------------------------------------------------------------------------------------------------------------------------------------
			--												OUTPUT SECTION
---------------------------------------------------------------------------------------------------------------------------------------------
	IF @flag IS NULL
	BEGIN
		DECLARE @row_to		INT,
				@row_from	INT
		
		SELECT @row_to=@page_no * @page_size
		
		IF @page_no > 1 
			SELECT @row_from =((@page_no-1) * @page_size)+1
		ELSE
			SELECT @row_from =@page_no
	END

	IF @flag IS NULL and @report_type = 'e'
	BEGIN

	SET @sqlStmt='SELECT AsOfDate [As of Date] ,
					ParentNettingGroup [Parent Netting Group]  , 
					NettingGroup [Netting Group], 
					GroupAppliesTo [Group Applies To] ,
					Sub ,
					Strategy ,
					Book ,
					SourceDealHeaderID [Source Deal Header ID], 
					TermStart [Term Start],
					AggTermStart [Agg Term Start] ,
					Final_PNL [Final PNL],
					LegalEntity [Legal Entity],
					ExpType [Exp Type],
					GrossExposure [Gross Exposure] ,
					InvoiceDueDate [Invoice Due Date],
					AgedInvoiceDays [Aged Invoice Days] ,
					NettingCounterparty [Netting Counterparty],
					Counterparty, 
					ParentCounterparty[Parent Counterparty] ,
					CounterpartyType[Counterparty Type], 
					RiskRating  [Risk Rating], 
					DebtRating  [Debt Rating] ,
					IndustryType1 [Industry Type1] ,
					IndustryType2 [Industry Type2] ,
					SICCode [SIC Code] ,
					AccountStatus [Account Status] ,
					Currency ,
					WatchList [Watch List] ,
--					CounterpartyGroup [Counterparty Group] ,
					TenorLimit [Tenor Limit],
					TenorDays  [Tenor Days], 
					TotalLimitProvided   [Total Limit Provided ], 
					TotalLimitReceived  [Total Limit Received] ,
					NetExposureToUs [Net Exposure To Us],
					NetExposureForThem [Net Exposure For Them], 
					TotalNetExposure [Total Net Exposure],
					LimitToUsAvailable [Limit To Us Available],
					LimitFromThemAvailable [Limit From Them Available] ,
					LimitToUsViolated [Limit To Us Violated] ,
					LimitFromThemViolated  [Limit From Them Violated],
					TenorLimitViolated [Tenor Limit Violated], 
					LimitToUsVariance [Limit To Us Variance] ,
					LimitFromThemVariance [Limit From Them Variance]
				   FROM '+ @tempTable  +' WHERE sno BETWEEN '+ cast(@row_from as varchar) +' AND '+ cast(@row_to as varchar)+ ' ORDER BY sno asc'

		EXEC spa_print @sqlStmt
		EXEC(@sqlStmt)
	END

	IF @flag IS NULL and @report_type NOT IN ('e','a')
	BEGIN
			SET @sqlStmt='SELECT 
			Counterparty,
			SourceDealHeaderID [Source Deal Header ID],
			Commodity,
			Term,
			GrossExposure [Gross Exposure],
			NetExposure [Net Exposure],
			Currency
			FROM '+ @tempTable  +' WHERE sno BETWEEN '+ cast(@row_from as varchar) +' AND '+ cast(@row_to as varchar)+ ' ORDER BY sno asc'
		EXEC spa_print @sqlStmt
		EXEC(@sqlStmt)
	
	END

	IF @flag IS NULL and @report_type = 'a'
	BEGIN
			SET @sqlStmt='SELECT 
			Counterparty,
			ParentCounterparty [Parent Counterparty],
			ThirtyDaysAR [30 Days AR],
			SixtyDaysAR [60 Days AR],
			NinetyDaysAR [90 Days AR]
			FROM '+ @tempTable  +' WHERE sno BETWEEN '+ cast(@row_from as varchar) +' AND '+ cast(@row_to as varchar)+ ' ORDER BY sno asc'
		EXEC spa_print @sqlStmt
		EXEC(@sqlStmt)
	
	END

























