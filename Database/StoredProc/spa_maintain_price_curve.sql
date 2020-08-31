

IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_maintain_price_curve]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_maintain_price_curve]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Author : Vishwas Khanal
Dated  : 01.Sep.2009
Desc   : Rewrote the View Price SP.
*/
CREATE PROC [dbo].[spa_maintain_price_curve]
	@curve_id				VARCHAR(MAX),
	@curve_type				INT,				
	@curve_source			INT,
	@from_date				VARCHAR(20),
	@to_date				VARCHAR(20)		= NULL,
	@tenor_from				VARCHAR(20)		= NULL,
	@tenor_to				VARCHAR(20)		= NULL,
	@ind_con_month			VARCHAR(1)		= NULL,
	@flag					CHAR(1)			= NULL,
	/* 
	'i' - Insert. 's' - View.
	'r' - Graph olot in insert Mode. 
	'v' - Graph plot in View Mode. 
	't' - Outputs all the curve names from the hierarchy. 
	'e' - To get the settlement date.
	*/
	@bidAndask_flag			CHAR(1)			= NULL,
	@differential_flag		CHAR(1)			= NULL,
	@CopyCurveID			INT				= NULL ,
	@average				CHAR(1)			= NULL,
	@settlementPrices		CHAR(1)			= NULL,
	@get_derive_value		CHAR(1)			= 'n', --'y'-> get derive curve, 'n'-> do not get derive curve
	@batch_process_id		VARCHAR(50)		= NULL,
	@batch_report_param		VARCHAR(5000)	= NULL,
	@adhihaTableName		VARCHAR(500)	= NULL,

	@apply_paging			CHAR(1)			= 'n',
	@process_id_paging		VARCHAR(500)	= NULL, 
	@page_size				INT				= NULL,
	@page_no				INT				= NULL
AS
SET NOCOUNT ON

/* **DEBUG Query Start **
	DECLARE @curve_id			VARCHAR(8000),
		@curve_type				INT,				
		@curve_source			INT,
		@from_date				VARCHAR(20),
		@to_date				VARCHAR(20)		= NULL,
		@tenor_from				VARCHAR(20)		= NULL,
		@tenor_to				VARCHAR(20)		= NULL,
		@ind_con_month			VARCHAR(1)		= NULL,
		@flag					CHAR(1)			= NULL,
		@bidAndask_flag			CHAR(1)			= NULL,
		@differential_flag		CHAR(1)			= NULL,
		@CopyCurveID			INT				= NULL,
		@average				CHAR(1)			= NULL,
		@settlementPrices		CHAR(1)			= NULL,
		@get_derive_value		CHAR(1)			= 'n',
		@batch_process_id		VARCHAR(50)		= NULL,
		@batch_report_param		VARCHAR(5000)	= NULL,
		@adhihaTableName		VARCHAR(500)	= NULL,
		@apply_paging			CHAR(1)			= 'n',
		@process_id_paging		VARCHAR(500)	= NULL, 
		@page_size				INT				= NULL,
		@page_no				INT				= NULL

	SELECT @curve_id = '7212,7225'
		, @curve_type = 77
		, @curve_source = 4500
		, @from_date = '2017-12-29'
		, @to_date = '2018-01-01'
		, @tenor_from = '2017-12-29'
		, @tenor_to = '2018-01-15'
		, @ind_con_month = NULL
		, @flag = 's'
		, @bidAndask_flag = 'n'
		, @differential_flag = NULL
		, @CopyCurveID = NULL
		, @average = NULL
		, @settlementPrices = 'n'
		, @get_derive_value = 'n'

		IF OBJECT_ID('tempdb..#curveNames') IS NOT NULL
			DROP TABLE #curveNames
		IF OBJECT_ID('tempdb..#price') IS NOT NULL
			DROP TABLE #price
		IF OBJECT_ID('tempdb..#UNPIVOT') IS NOT NULL
			DROP TABLE #UNPIVOT
		IF OBJECT_ID('tempdb..#template') IS NOT NULL
			DROP TABLE #template
		IF OBJECT_ID('tempdb..#OUTPUT') IS NOT NULL
			DROP TABLE #OUTPUT
		IF OBJECT_ID('tempdb..#filteredData') IS NOT NULL
			DROP TABLE #filteredData
		IF OBJECT_ID('tempdb..#settlementData') IS NOT NULL
			DROP TABLE #settlementData
		IF OBJECT_ID('tempdb..#templateDates') IS NOT NULL
			DROP TABLE #templateDates
		IF OBJECT_ID('tempdb..#formulaData') IS NOT NULL
			DROP TABLE #formulaData
		IF OBJECT_ID('tempdb..#primary_curve_mapping') IS NOT NULL
			DROP TABLE #primary_curve_mapping
--**DEBUG Query End ** */


DECLARE @dst_group_value_id	VARCHAR(100) = NULL
IF @curve_id IS NOT NULL
BEGIN 
	SELECT @dst_group_value_id = tz.dst_group_value_id FROM source_price_curve_def spcd inner join time_zones tz ON spcd.time_zone = tz.TIMEZONE_ID WHERE spcd.source_curve_def_id IN (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id))
END


IF @adhihaTableName IS NOT NULL
BEGIN
	/* This code is used to see the batch report from the message board. */
	EXEC ('SELECT * FROM  ' + @adhihaTableName)
	RETURN	
END
	
IF @tenor_from = ''
	SET @tenor_from = NULL
IF @tenor_to = ''
	SET @tenor_to = NULL

IF @flag = 'e'	
BEGIN
	SELECT dbo.FNADateFormat(hg.exp_date) AS 'ExpirationDate'
	FROM   source_price_curve_def spcd
	LEFT OUTER JOIN holiday_group hg ON  hg.hol_group_value_id = spcd.exp_calendar_id
		WHERE  hg.hol_date = CAST(@tenor_from AS DATETIME)
		    AND spcd.source_curve_def_id = @curve_id
	RETURN
END
	
DECLARE @asOfdateFrom				  DATETIME		, @asOfdateTo			DATETIME		,
		@tenorFrom					  DATETIME		, @tenorTo				DATETIME		,
		@viewModeWhenNoDataExists	  VARCHAR(8000) , @table				VARCHAR(100)    ,					
		@sql						  VARCHAR(8000) , @curve_id_tmp		    VARCHAR(8000)	,
		@curve_name					  VARCHAR(8000) , @curveNamesForPivot	VARCHAR(MAX)	,
		@maturity_date				  DATETIME		, @minutes				INT				,
		@loop						  INT			, @granularity			INT				,
		@differentialCurveIds		  VARCHAR(1000) , @top_curve			VARCHAR(100)	,
		@sql1						  VARCHAR(MAX)	, @sql2					VARCHAR(MAX)	,
		@granularity_true			  CHAR(1)		, @batch_stmt			VARCHAR(MAX)	,
		@adihaTable					  VARCHAR(128)
		,@derived_curve_values		 VARCHAR(250)
		
		
DECLARE @tempTable           VARCHAR(200),
	        @user_login_id       VARCHAR(50),
	        @flag_paging         CHAR(1),@process_id varchar(150)
	        
SET @process_id=REPLACE(newid(),'-','_')       
	          
SET @user_login_id = dbo.FNADBUser()				
-- Apply paging		
IF @apply_paging = 'y'
BEGIN
	
	DECLARE @heading_labels		 VARCHAR(MAX),
	        @heading_definition  VARCHAR(MAX)		
	
	DECLARE @row_to              INT,
	        @row_from            INT
	
		
	------------------------------------
	IF @process_id_paging IS NOT NULL 
	BEGIN					
		SET @tempTable = dbo.FNAProcessTableName('paging_maintain_price_curve', @user_login_id, @process_id_paging)
		SET @row_to = @page_no * @page_size
		
		IF @page_no > 1 
			SET @row_from = ((@page_no -1) * @page_size) + 1
		ELSE
			SET @row_from = @page_no
		
		IF @average = 'l'
		BEGIN	
			SELECT @heading_labels = COALESCE(@heading_labels + ',[' + c.name + ']', '[' + c.name + ']') 
			FROM adiha_process.sys.columns c
			INNER JOIN adiha_process.sys.tables t ON t.[object_id] = c.[object_id]
			WHERE t.name = 'paging_maintain_price_curve_' + @user_login_id + '_' + @process_id_paging
			AND column_id > 1
			
			SET @sql = 'SELECT ' + @heading_labels + '
						FROM '+ @tempTable  +' 
						WHERE sno BETWEEN '+ CAST(@row_from AS VARCHAR) +' AND '+ CAST(@row_to AS VARCHAR)+ ' 
						ORDER BY sno ASC'
								
		END
		ELSE
		BEGIN
			--ORDER BY clause was not necessary in SQL SERVER 2008(Hour and min was always selected first)
			--but in SQL SERVER 2012 ORDER BY clause is mendetory to selec hour and min first. 
			SELECT @heading_labels = COALESCE(@heading_labels + ',[' + c.name + ']', '[' + c.name + ']') 
			FROM adiha_process.sys.columns c
			INNER JOIN adiha_process.sys.tables t ON t.[object_id] = c.[object_id]
			WHERE t.name = 'paging_maintain_price_curve_' + @user_login_id + '_' + @process_id_paging
			AND ((column_id > 3 AND ISNULL(@average,'')<>'a') OR (column_id > 2 AND ISNULL(@average,'')='a'))	
			ORDER BY (CASE WHEN c.name IN ('HOUR', 'MIN') THEN 1 ELSE 2 END), c.name ASC

			SET @sql = 'SELECT as_of_date [AS OF DATE],
						   '+CASE WHEN ISNULL(@average,'')<>'a' THEN 'maturity_date [MATURITY DATE],' ELSE '' END + @heading_labels + '
						FROM '+ @tempTable  +' 
						WHERE sno BETWEEN '+ CAST(@row_from AS VARCHAR) +' AND '+ CAST(@row_to AS VARCHAR)+ ' 
						ORDER BY sno ASC'	
		END
		
		
		--PRINT @sql 
		EXEC (@sql)
		
		RETURN 
	END 		
END
	
/*
Programming flow :
	1. From source_price_curve get all the data you get, after the user given filter is applied ,to the #filteredData. 
	2. Unpivot the same and get them in the table #unpivot
	3. Get only the required values into #price from #unpivot. Now #price will hold all the data with price.
	4. If insert mode,create the template(i.e curve_name,as_of_date,maturity_date and NULL value) for the date range into #template.
	5. Update #template from #price.
	6. Get the data to #output from #price if view mode,from #template if insert mode and from #average if average is checked.
	7. Pivot #output and show the value.
*/	
CREATE TABLE #curveNames(source_curve_def_id INT,curve_name VARCHAR(250) COLLATE DATABASE_DEFAULT )
CREATE TABLE #price (sno INT IDENTITY(1,1),curve_name VARCHAR(250) COLLATE DATABASE_DEFAULT ,as_of_date DATETIME,maturity_date DATETIME,val FLOAT,is_dst INT)
CREATE TABLE #UNPIVOT (curve_name VARCHAR(250) COLLATE DATABASE_DEFAULT ,mode VARCHAR(100) COLLATE DATABASE_DEFAULT ,as_of_date DATETIME,maturity_date DATETIME,val FLOAT,is_dst INT)
CREATE TABLE #template (sno INT IDENTITY(1,1),val FLOAT,curve_name VARCHAR(250) COLLATE DATABASE_DEFAULT ,as_of_date DATETIME,maturity_date DATETIME,is_dst INT)			
CREATE TABLE #OUTPUT (curve_name VARCHAR(250) COLLATE DATABASE_DEFAULT ,as_of_date DATETIME,maturity_date DATETIME,val DECIMAL(38,10),is_dst INT)
	CREATE TABLE #filteredData(source_curve_def_id INT,curve_name VARCHAR(250) COLLATE DATABASE_DEFAULT ,as_of_date DATETIME,maturity_date DATETIME,bid_value FLOAT,ask_value FLOAT,mid_value FLOAT, is_dst int)
CREATE TABLE #settlementData(source_curve_def_id INT,curve_name VARCHAR(250) COLLATE DATABASE_DEFAULT ,as_of_date DATETIME,maturity_date DATETIME,bid_value FLOAT,ask_value FLOAT,mid_value FLOAT,is_dst INT)
CREATE TABLE #templateDates(maturity_date DATETIME)

--test
SET @derived_curve_values= dbo.FNAProcessTableName('derived_curve_values', @user_login_id,@process_id)


IF @flag = 'q'
BEGIN
	CREATE TABLE #primary_curve_mapping(derived_curve_id INT , primary_curve_id INT)
	INSERT INTO #primary_curve_mapping (derived_curve_id, primary_curve_id)
	SELECT spcd.source_curve_def_id, COALESCE(  
	NULLIF(SUBSTRING (
	 SUBSTRING(SUBSTRING(fe.formula,CHARINDEX('FNACURVE',fe.formula),CHARINDEX(',',fe.formula)),0,charindex(',',SUBSTRING(fe.formula,CHARINDEX('FNACURVE',fe.formula),CHARINDEX(',',fe.formula)))),charindex('(',SUBSTRING(fe.formula,CHARINDEX('FNACURVE',fe.formula),CHARINDEX(',',fe.formula)))+1,10), ''),
	NULLIF(SUBSTRING
	 (SUBSTRING(SUBSTRING(fe.formula,CHARINDEX('FNALagCurve',fe.formula),CHARINDEX(',',fe.formula)),0,charindex(',',SUBSTRING(fe.formula,CHARINDEX('FNALagCurve',fe.formula),CHARINDEX(',',fe.formula)))),charindex('(',SUBSTRING(fe.formula,CHARINDEX('FNALagCurve',fe.formula),CHARINDEX(',',fe.formula)))+1,10), ''),
	NULLIF(SUBSTRING
	 (SUBSTRING(SUBSTRING(fe.formula,CHARINDEX('FNAPriorCurve',fe.formula),CHARINDEX(',',fe.formula)),0,charindex(',',SUBSTRING(fe.formula,CHARINDEX('FNAPriorCurve',fe.formula),CHARINDEX(',',fe.formula)))),charindex('(',SUBSTRING(fe.formula,CHARINDEX('FNAPriorCurve',fe.formula),CHARINDEX(',',fe.formula)))+1,10), ''),
	NULLIF(SUBSTRING
	 (SUBSTRING(SUBSTRING(fe.formula,CHARINDEX('FNAWACOG_Sale',fe.formula),CHARINDEX(',',fe.formula)),0,charindex(',',SUBSTRING(fe.formula,CHARINDEX('FNAWACOG_Sale',fe.formula),CHARINDEX(',',fe.formula)))),charindex('(',SUBSTRING(fe.formula,CHARINDEX('FNAWACOG_Sale',fe.formula),CHARINDEX(',',fe.formula)))+1,10), ''),
	NULLIF(SUBSTRING
	 (SUBSTRING(SUBSTRING(fe.formula,CHARINDEX('FNAWACOG_Buy',fe.formula),CHARINDEX(',',fe.formula)),0,charindex(',',SUBSTRING(fe.formula,CHARINDEX('FNAWACOG_Buy',fe.formula),CHARINDEX(',',fe.formula)))),charindex('(',SUBSTRING(fe.formula,CHARINDEX('FNAWACOG_Buy',fe.formula),CHARINDEX(',',fe.formula)))+1,10), ''),
	NULLIF(SUBSTRING
	 (SUBSTRING(SUBSTRING(fe.formula,CHARINDEX('FNAAverageHourlyPrice',fe.formula),CHARINDEX(',',fe.formula)),0,charindex(',',SUBSTRING(fe.formula,CHARINDEX('FNAAverageHourlyPrice',fe.formula),CHARINDEX(',',fe.formula)))),charindex('(',SUBSTRING(fe.formula,CHARINDEX('FNAAverageHourlyPrice',fe.formula),CHARINDEX(',',fe.formula)))+1,10), ''),
	NULLIF(SUBSTRING
	 (SUBSTRING(SUBSTRING(fe.formula,CHARINDEX('FNAAveragePrice',fe.formula),CHARINDEX(',',fe.formula)),0,charindex(',',SUBSTRING(fe.formula,CHARINDEX('FNAAveragePrice',fe.formula),CHARINDEX(',',fe.formula)))),charindex('(',SUBSTRING(fe.formula,CHARINDEX('FNAAveragePrice',fe.formula),CHARINDEX(',',fe.formula)))+1,10), ''),
	SUBSTRING
	 (SUBSTRING(SUBSTRING(fe.formula,CHARINDEX('FNAPriceCurve',fe.formula),CHARINDEX(',',fe.formula)),0,charindex(',',SUBSTRING(fe.formula,CHARINDEX('FNAPriceCurve',fe.formula),CHARINDEX(',',fe.formula)))),charindex('(',SUBSTRING(fe.formula,CHARINDEX('FNAPriceCurve',fe.formula),CHARINDEX(',',fe.formula)))+1,10))
	FROM source_price_curve_def spcd
	INNER JOIN SplitCommaSeperatedValues(@curve_id) item ON  item.Item = spcd.source_curve_def_id
	INNER JOIN formula_editor fe on spcd.formula_id=fe.formula_id
	
END
--SELECT * FROM #primary_curve_mapping
--RETURN
--test

-- Build the indexes	
CREATE NONCLUSTERED INDEX NCI_AS_OF_DATE_XI		ON #template(as_of_date)
CREATE NONCLUSTERED INDEX NCI_MATURITY_DATE_XII ON #template(maturity_date)
CREATE NONCLUSTERED INDEX NCI_CURVE_NAME_XIII	ON #template(curve_name)
CREATE NONCLUSTERED INDEX NCI_AS_OF_DATE_XIV	ON #price(as_of_date)
CREATE NONCLUSTERED INDEX NCI_MATURITY_DATE_XV  ON #price(maturity_date)
CREATE NONCLUSTERED INDEX NCI_CURVE_NAME_XVI	ON #price(curve_name)
CREATE NONCLUSTERED INDEX NCI_CURVE_NAME_XVII	ON #OUTPUT(curve_name)
CREATE NONCLUSTERED INDEX NCI_CURVE_NAME_XVIII	ON #OUTPUT(as_of_date)
CREATE NONCLUSTERED INDEX NCI_CURVE_NAME_XIX	ON #OUTPUT(maturity_date)
CREATE NONCLUSTERED INDEX NCI_AS_OF_DATE_XX		ON #filteredData(as_of_date)
CREATE NONCLUSTERED INDEX NCI_MATURITY_DATE_XXI	ON #filteredData(maturity_date)
CREATE NONCLUSTERED INDEX NCI_CURVE_ID_XXII		ON #filteredData(source_curve_def_id)			

SELECT @asOfdateFrom = CAST(@from_date AS DATETIME),
       @asOfdateTo	 = CAST(@to_date AS DATETIME),
       @tenorFrom	 = CAST(@tenor_from AS DATETIME),
       @tenorTo		 = CAST(@tenor_to AS DATETIME)
				
-- Get the curve names involved
IF @differential_flag = 'd' OR @flag = 't'
BEGIN
	INSERT INTO #curveNames EXEC dbo.spa_getReferenceHierarchy @curve_id
	IF @flag = 't'
	BEGIN
		SELECT @differentialCurveIds = ISNULL(@differentialCurveIds+',','') + CAST(source_curve_def_id AS VARCHAR) FROM #curveNames
		SELECT @differentialCurveIds 'curveId' 
		RETURN
	END
END	
	
ELSE				
	INSERT INTO #curveNames
SELECT  source_curve_def_id, curve_name 
FROM dbo.splitCommaSeperatedValues(@curve_id) 
INNER JOIN source_price_curve_def spcd ON item = spcd.source_curve_def_id
INNER JOIN source_system_description ssd ON spcd.source_system_id = ssd.source_system_id

SELECT  @curve_id_tmp = ISNULL(@curve_id_tmp+',','') + CAST(source_curve_def_id AS VARCHAR) FROM #curveNames

IF @asOfdateFrom IS NULL
	SELECT @asOfdateFrom = MIN(as_of_date)
	FROM   source_price_curve
	WHERE  source_curve_def_id IN (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id_tmp))
	    AND curve_source_value_id = @curve_source		

		        
IF @asOfdateTo IS NULL
BEGIN
	IF @flag = 'i'
		SELECT @asOfdateTo = @asOfdateFrom
	ELSE IF @flag = 's'
		SELECT @asOfdateTo = MAX(as_of_date) 
		FROM source_price_curve spc 
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
		    WHERE EXISTS (SELECT item FROM   dbo.splitCommaSeperatedValues(@curve_id_tmp) WHERE  spc.source_curve_def_id = item)
		AND curve_source_value_id = @curve_source
		--AND spcd.formula_id IS NULL
	ELSE	
		SELECT @asOfdateTo = MAX(as_of_date) 
		FROM source_price_curve spc 
		INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
		    WHERE EXISTS (SELECT item FROM   dbo.splitCommaSeperatedValues(@curve_id_tmp) WHERE  spc.source_curve_def_id = item)
		AND curve_source_value_id = @curve_source
		AND spcd.formula_id IS NULL
END
	
	
IF @tenorFrom IS NULL
	SELECT @tenorFrom = MIN(maturity_date) 
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
	WHERE spc.source_curve_def_id IN (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id_tmp))
		AND as_of_date BETWEEN @asOfdateFrom AND @asOfdateTo
		AND curve_source_value_id = @curve_source
		AND spcd.formula_id IS NULL

IF @tenorTo IS NULL
	SELECT @tenorTo = MAX(maturity_date) 
	FROM source_price_curve spc
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = spc.source_curve_def_id
		WHERE 1=1 AND EXISTS (SELECT item FROM   dbo.splitCommaSeperatedValues(@curve_id_tmp) WHERE  item = spc.source_curve_def_id)
		AND as_of_date BETWEEN @asOfdateFrom AND @asOfdateTo
		AND curve_source_value_id = @curve_source		
		AND spcd.formula_id IS NULL	
		
SELECT @granularity = MAX(Granularity) ,
	   @curve_name  = MAX(REPLACE(spcd.curve_name,'''',''''''))	
FROM source_price_curve_def spcd
INNER JOIN source_system_description ssd ON spcd.source_system_id = ssd.source_system_id
WHERE EXISTS (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id_tmp) WHERE item = spcd.source_curve_def_id) 



	IF EXISTS(SELECT 'X' FROM   source_price_curve_def
	WHERE EXISTS (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id_tmp) WHERE item = source_curve_def_id) 
		AND Granularity IN (982,987,989)
)	
	SELECT @granularity_true = 'y'

IF @granularity_true = 'y'
	SELECT @tenorTo = DATEADD(MI,-15,DATEADD(DD,1,@tenorTo))
	
IF @flag IN ('i', 's', 'r', 'v', 'q')	
BEGIN
	SET @sql1 = 'INSERT INTO #filteredData
		SELECT spc.source_curve_def_id,
		(curve_name) AS curve_name,
		as_of_date,
		maturity_date,
		dbo.FNARemoveTrailingZero(CAST(bid_value AS NUMERIC(38,19))),
		ask_value,
		curve_value AS ''MID_VALUE'',
		is_dst 		 
		FROM '+dbo.[FNAGetProcessTableName](CAST(@asOfdateFrom AS VARCHAR),'source_price_curve')+' spc 
		INNER JOIN source_price_curve_def spcd ON spc.source_curve_def_id = spcd.source_curve_def_id
		INNER JOIN source_system_description ssd ON spcd.source_system_id = ssd.source_system_id
						 WHERE  Assessment_curve_type_value_id = ' + CAST(@curve_type AS VARCHAR) + '
							AND curve_source_value_id = ' + CAST(@curve_source AS VARCHAR) + '
							AND as_of_date BETWEEN ''' + CAST(@asOfdateFrom AS VARCHAR) + ''' AND ''' + CAST(isnull(@asOfdateTo,@asOfdateFrom) AS VARCHAR) + ''''
							+ CASE WHEN @tenorFrom IS NOT NULL AND @tenorTo IS NOT NULL THEN '
								AND maturity_date BETWEEN ''' + CAST(@tenorFrom AS VARCHAR)+''' 
								AND ''' + CAST(@tenorTo AS VARCHAR) + '''' 
								WHEN @tenorFrom IS NOT NULL AND @tenorTo IS NULL THEN '
								AND maturity_date >= ''' + CAST(@tenorFrom AS VARCHAR)+''''
								WHEN @tenorFrom IS NULL AND @tenorTo IS NOT NULL THEN '
								AND maturity_date <= ''' + CAST(@tenorTo AS VARCHAR)+''''
								ELSE '' END +
						  'AND EXISTS (
				  				SELECT item FROM dbo.splitCommaSeperatedValues(' + '''' + CAST(@curve_id_tmp AS VARCHAR(1000)) + '''' + ')
								WHERE  item = spc.source_curve_def_id
						   )'		  
	--PRINT @sql1 
	EXEC(@sql1)	 

	
	-- ONLY call derive SP IF @get_derive_value = 'y'
	IF @get_derive_value='y'
	begin
	
		--@curve_id_tmp,@asOfdateFrom,@asOfdateTo,@curve_source, @derived_curve_values,@tenorFrom,@tenorTo
		EXEC spa_derive_curve_value @curve_id_tmp,@asOfdateFrom,@asOfdateTo,@curve_source, @derived_curve_values,@tenorFrom,@tenorTo	

	set @sql1='
		INSERT INTO #filteredData
		SELECT frml.curve_id,
			   spcd.curve_name AS curve_name,
			   frml.as_of_date,
			   frml.prod_date,
			   NULL,
			   NULL,
			   frml.formula_eval_value,
			   frml.is_dst
		FROM  '+@derived_curve_values+'  frml
		INNER JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = frml.curve_id
		LEFT JOIN #filteredData fltr ON  frml.curve_id = fltr.source_curve_def_id
			AND fltr.as_of_date = frml.as_of_date
			AND fltr.maturity_date = frml.prod_date
			AND ISNULL(fltr.is_dst, 0) = ISNULL(frml.is_dst, 0)
		LEFT JOIN source_system_description ssd ON  ssd.source_system_id = spcd.source_system_id
		WHERE  frml.formula_eval_value IS NOT NULL
			AND fltr.source_curve_def_id IS NULL						
	'
	
	--	print @sql1
	exec(@sql1)
	
	set @sql1='
		UPDATE fltr
		SET    fltr.bid_value = formula_eval_value,
			   fltr.ask_value = formula_eval_value,
			   fltr.mid_value = formula_eval_value
		FROM   #filteredData fltr
		INNER JOIN '+@derived_curve_values+' frml ON  fltr.source_curve_def_id = frml.curve_id
			AND fltr.as_of_date = frml.as_of_date
			AND fltr.maturity_date = frml.prod_date
			AND ISNULL(fltr.is_dst, 0) = ISNULL(frml.is_dst, 0)
		WHERE  frml.formula_eval_value IS NOT NULL	
	'
	EXEC spa_print @sql1
	exec(@sql1)
	END
	UPDATE #filteredData SET bid_value = mid_value WHERE bid_value IS NULL
	UPDATE #filteredData SET    ask_value = mid_value WHERE  ask_value IS NULL
	UPDATE #filteredData SET is_dst = 0 WHERE is_dst IS NULL

	--SELECT '#filteredData', * FROM #filteredData

	IF @settlementPrices = 'y'
	BEGIN
	
		;WITH CTE(
		             exp_calendar_id,
		             source_curve_def_id,
		             curve_name,
		             as_of_date,
		             maturity_date,
		             bid_value,
		             ask_value,
		             curve_value,
		             is_dst
		         )
		AS (
			SELECT DISTINCT exp_calendar_id,
				   spcd.source_curve_def_id,
				   spc.curve_name,
				   spc.as_of_date,
				   spc.maturity_date,
				   spc.bid_value,
				   spc.ask_value,
				   spc.mid_value,
				   spc.is_dst
			FROM   source_price_curve_def spcd
			LEFT OUTER JOIN holiday_group hg ON  hg.hol_group_value_id = spcd.exp_calendar_id
			LEFT OUTER JOIN #filteredData spc ON  spc.source_curve_def_id = spcd.source_curve_def_id
				AND spc.maturity_date = hg.hol_date
				AND spc.as_of_date >= hg.exp_date
			WHERE  hg.hol_date BETWEEN ISNULL(@tenor_from, spc.maturity_date) AND ISNULL(@tenor_to, spc.maturity_date)
				AND spc.as_of_date BETWEEN ISNULL(@from_date, spc.as_of_date) AND ISNULL(@to_date, spc.as_of_date)
				AND spcd.source_curve_def_id IN (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id))
		)
		
		INSERT INTO #SettlementData
		SELECT source_curve_def_id,
		       curve_name,
		       as_of_date,
		       maturity_date,
		       bid_value,
		       ask_value,
		       curve_value,
		       is_dst
		FROM   CTE OPTION(MAXRECURSION 10000);				
		
		DELETE fd
		FROM   #filteredData fd
		LEFT OUTER JOIN #SettlementData sd ON fd.source_curve_def_id = sd.source_curve_def_id
			AND fd.as_of_date = sd.as_of_date
			AND fd.maturity_date = sd.maturity_date
			AND fd.is_dst = sd.is_dst 
		WHERE sd.source_curve_def_id IS NULL
	END
		
	IF @flag IN ('s', 'v', 'q')
	BEGIN				
		IF @differential_flag = 'd' AND @bidAndask_flag IS NULL
		BEGIN											
			INSERT INTO #UNPIVOT
			SELECT curve_name, mode, as_of_date, maturity_date, val, is_dst
			FROM   (SELECT curve_name, as_of_date, maturity_date, mid_value, is_dst FROM #filtereddata) p
			       UNPIVOT(val FOR mode IN (mid_value)) AS unpvt
			
			INSERT INTO #price SELECT curve_name,as_of_date,maturity_date,val,is_dst FROM #UNPIVOT	
			
			SELECT @curveNamesForPivot = ISNULL(@curveNamesForPivot +',','')+'['+curve_name+']' FROM #curveNames		
		END
		ELSE IF @differential_flag IS NULL AND @bidAndask_flag = 'b' 
		BEGIN
		
			INSERT INTO #UNPIVOT
			SELECT curve_name, mode, as_of_date, maturity_date, val, is_dst
			FROM   (
			           SELECT curve_name,
			                  as_of_date,
			                  maturity_date,
			                  bid_value '_BIDVALUE',
			                  ask_value '_ASKVALUE',
			                  mid_value '_MIDVALUE',
			                  is_dst
			           FROM   #filtereddata
			       ) p
			       UNPIVOT(val FOR mode IN (_BIDVALUE, _ASKVALUE, _MIDVALUE)) AS unpvt
			
			INSERT INTO #price SELECT curve_name+mode,as_of_date,maturity_date,val,is_dst FROM #UNPIVOT
	
			SELECT @curveNamesForPivot = ISNULL(@curveNamesForPivot + ',', '') 
					+ '[' + curve_name + '_BIDVALUE],[' + curve_name + '_ASKVALUE],[' + curve_name + '_MIDVALUE]' 
			FROM #curveNames												
		END
		ELSE IF @differential_flag = 'd' AND @bidAndask_flag = 'b' 
		BEGIN
		
			INSERT INTO #UNPIVOT
			SELECT curve_name, mode, as_of_date, maturity_date, val, is_dst
			FROM   (
			           SELECT curve_name,
			                  as_of_date,
			                  maturity_date,
			                  bid_value '_BIDVALUE',
			                  ask_value '_ASKVALUE',
			                  mid_value '_MIDVALUE',
			                  is_dst
			           FROM   #filtereddata
			       ) p
			       UNPIVOT(val FOR mode IN (_BIDVALUE, _ASKVALUE, _MIDVALUE)) AS unpvt
			
			INSERT INTO #price SELECT curve_name+mode,as_of_date,maturity_date,val,is_dst FROM #UNPIVOT

			SELECT @curveNamesForPivot = ISNULL(@curveNamesForPivot + ',', '') + 
			       '[' + curve_name + '_BIDVALUE],[' + curve_name + 
			       '_ASKVALUE],[' + curve_name + '_MIDVALUE]'
			FROM #curveNames															
		END
		ELSE
		BEGIN
		
			INSERT INTO #price SELECT curve_name,as_of_date,maturity_date,mid_value,is_dst FROM #filteredData
			
			SELECT @curveNamesForPivot = ISNULL(@curveNamesForPivot + ',', '') + '[' + curve_name + ']'
			FROM   #curveNames	
			
			--SELECT '#price', * FROM #price			
		END	 								
	END
	ELSE IF @flag IN ('i', 'r')
	BEGIN			
		-- Set the start point and End point for the maturity date.This will be used as the first date in view price insertion.		
		IF (@granularity != 990) AND (DATEPART(dd, @asOfdateFrom) = 1 OR @granularity = 981) 
			SELECT @maturity_date = DATEADD(dd, 1, @asOfdateFrom) 
		ELSE 
			SELECT @maturity_date = @asOfdateFrom

		SELECT @maturity_date = CASE WHEN @tenor_from IS NULL THEN dbo.FNAGetNextFirstDate(@maturity_date, @granularity)
		                             ELSE CASE @granularity
		                                       WHEN 990 THEN DATEADD(dd, CASE DATEPART(dw, @tenorFrom) WHEN 1 THEN 0 ELSE 8 -DATEPART(dw, @tenorFrom) END,@tenorFrom)
		                                       ELSE dbo.FNAGetNextFirstDate(@tenorFrom, @granularity)
		                                  END
		                        END	
	
		SELECT @tenorTo = COALESCE(@tenorTo, @maturity_date)

		SELECT @minutes = CASE @granularity WHEN 987 THEN 15 WHEN 989 THEN 30 WHEN 982 THEN 60 ELSE 0 END
			  ,@loop	= CASE @granularity WHEN 987 THEN 96 WHEN 989 THEN 48 WHEN 982 THEN 24 ELSE 0 END

		-- Get the dates to be used in the template
		;WITH templateDates(maturity_date)
		AS(
			SELECT @maturity_date
		
			UNION ALL
		
			SELECT dbo.FNAGetNextFirstDate(DATEADD(dd, 1, maturity_date), @granularity)
			FROM   templateDates
			WHERE  dbo.FNAGetNextFirstDate(DATEADD(dd, 1, maturity_date), @granularity) <= @tenorTo
		)
		INSERT INTO #templateDates
		SELECT maturity_date
		FROM   templateDates OPTION(MAXRECURSION 10000);
		 
		CREATE TABLE #temp_CTE
		(
			maturity_date  DATETIME,
			[loop]         INT,
			is_DST         INT
		)

	-- Create the template
		SELECT @sql = ';WITH CTE (MATURITY_DATE,loop,DST) 
						AS (
			SELECT maturity_date,1,0 FROM #templateDates
			UNION ALL
			SELECT DATEADD(' + CASE WHEN @granularity =	980 THEN 'MONTH,1,' 
									WHEN @granularity = 987 THEN 'MINUTE,15,' 
									WHEN @granularity = 989 THEN 'MINUTE,30,' 
									WHEN @granularity = 982 THEN 'MINUTE,60,' 
									WHEN @granularity = 981 THEN 'DAY,1,' 
									WHEN @granularity = 993 THEN 'YEAR,1,'
									WHEN @granularity = 992 THEN 'MONTH,6,'
									WHEN @granularity = 991 THEN 'MONTH,3,' 
									WHEN @granularity = 990 THEN 'DAY,7,'
								END + 'maturity_date),loop+1,0
				FROM CTE WHERE loop<'+
						CAST(CASE @granularity 
								WHEN 987 THEN 96
								WHEN 989 THEN 48
								WHEN 982 THEN 24
								ELSE 1
							 END AS VARCHAR)
		+')
		
		INSERT INTO #temp_CTE 
							SELECT CTE.MATURITY_DATE, CTE.loop, 1
							FROM   CTE
		INNER JOIN mv90_dst dst ON YEAR(dst.date) = YEAR(CTE.MATURITY_DATE) 
			AND MONTH(dst.date) = MONTH(CTE.MATURITY_DATE) 
			AND DAY(dst.date) = DAY(CTE.MATURITY_DATE) 
			AND dst.insert_delete = ''i'' 
			AND DATEPART(HOUR, CTE.MATURITY_DATE) = dst.Hour -1
			AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
		
		UNION ALL
		
		SELECT CTE.* FROM CTE
		
							DELETE CTE
							FROM   #temp_CTE CTE
		INNER JOIN mv90_dst dst ON YEAR(dst.date) = YEAR(CTE.MATURITY_DATE) 
			AND MONTH(dst.date) = MONTH(CTE.MATURITY_DATE) 
			AND DAY(dst.date) = DAY(CTE.MATURITY_DATE) 
			AND dst.insert_delete = ''d'' 
			AND DATEPART(HOUR, CTE.MATURITY_DATE) = dst.Hour -1
			AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
		
		INSERT INTO #template' +
		CASE WHEN @differential_flag = 'd' THEN					
		' SELECT NULL ,d.curve_name ''CURVE_NAME'','''+dbo.FNAGetSQLStandardDate(@asOfdateFrom) +''' ''AS_OF_DATE'',CONVERT(VARCHAR(11),c.maturity_date,120) + '''' +CONVERT(VARCHAR(11),maturity_date,108)  m_date,is_DST
		FROM #temp_CTE c 
		CROSS JOIN (SELECT curve_name FROM #curveNames)	d'
		WHEN @bidAndask_flag = 'b' THEN
		' SELECT NULL ,bam.cn ''CURVE_NAME'','''+dbo.FNAGetSQLStandardDate(@asOfdateFrom) +''' ''AS_OF_DATE'',CONVERT(VARCHAR(11),c.maturity_date,120) + '''' +CONVERT(VARCHAR(11),maturity_date,108)  m_date,is_DST
			FROM #temp_CTE c 
				CROSS JOIN (
						SELECT '''+ @curve_name+'_BIDVALUE'' cn 
						UNION ALL SELECT '''+@curve_name+'_ASKVALUE'' cn
						UNION ALL SELECT '''+@curve_name+'_MIDVALUE'' cn) bam'
		ELSE
		' SELECT NULL ,'''+@curve_name +''' ''CURVE_NAME'','''+dbo.FNAGetSQLStandardDate(@asOfdateFrom) +''' ''AS_OF_DATE'',CONVERT(VARCHAR(11),c.maturity_date,120) + '''' +CONVERT(VARCHAR(11),maturity_date,108)  m_date,is_DST
		FROM #temp_CTE c '
		END	+' OPTION (MAXRECURSION 10000)	'	
		
		--PRINT(@sql)
		EXEC(@sql)		
		
		IF @differential_flag = 'd'
		BEGIN
			INSERT INTO #UNPIVOT
			SELECT curve_name, mode, as_of_date, maturity_date, val, is_dst
			FROM   (SELECT curve_name, as_of_date, maturity_date, mid_value, is_dst FROM   #filtereddata) p
			       UNPIVOT(val FOR mode IN (mid_value)) AS unpvt
			
			INSERT INTO #price
			SELECT curve_name, as_of_date, maturity_date, val, is_dst
			FROM   #UNPIVOT	

			UPDATE t
			SET    t.val = fd.mid_value
			FROM   #template t
			INNER JOIN #filteredData fd ON  t.curve_name = fd.curve_name
				AND t.as_of_date = fd.as_of_date
				AND t.maturity_date = fd.maturity_date
				AND t.is_dst = fd.is_dst 	
			
			SELECT @curveNamesForPivot = ISNULL(@curveNamesForPivot+',','')+'['+curve_name+']' FROM #curveNames							
		END
		ELSE IF @bidAndask_flag = 'b' 
		BEGIN	
			INSERT INTO #UNPIVOT
			SELECT curve_name, mode, as_of_date, maturity_date, val, is_dst
			FROM   (
			           SELECT curve_name,
			                  as_of_date,
			                  maturity_date,
			                  bid_value '_BIDVALUE',
			                  ask_value '_ASKVALUE',
			                  mid_value '_MIDVALUE',
			                  is_dst
			           FROM   #filtereddata
			       ) p
			       UNPIVOT(val FOR mode IN (_BIDVALUE, _ASKVALUE, _MIDVALUE)) AS unpvt
			
			INSERT INTO #price
			SELECT curve_name + mode, as_of_date, maturity_date, val, is_dst
			FROM   #UNPIVOT
		
			UPDATE t
			SET    t.val = p.val
			FROM   #template t
			INNER JOIN #price p ON  t.curve_name = p.curve_name
				AND t.as_of_date = p.as_of_date
				AND t.maturity_date = p.maturity_date
				AND t.is_dst = p.is_dst
					
			SELECT @curveNamesForPivot = ISNULL(@curveNamesForPivot + ',', '') + 
			       '[' + curve_name + '_BIDVALUE],[' + curve_name + 
			       '_ASKVALUE],[' + curve_name + '_MIDVALUE]'
					FROM #curveNames												
		END
		ELSE
		BEGIN																
			UPDATE t
			SET    t.val = fd.mid_value
			FROM   #template t
			INNER JOIN #filteredData fd ON  t.curve_name = fd.curve_name
				AND t.as_of_date = fd.as_of_date
				AND t.maturity_date = fd.maturity_date
				AND t.is_dst = fd.is_dst	
								
			SELECT @curveNamesForPivot = '['+REPLACE(@curve_name,'''''','''')+']'		
		END
	END

	-- Previous Average Logic
	IF @average = 'a' AND EXISTS(SELECT 'x' FROM #filteredData)
	BEGIN	
			SELECT CURVE_NAME, AS_OF_DATE, AVG(VAL) 'VAL', is_dst INTO #average FROM #price GROUP BY CURVE_NAME, AS_OF_DATE, is_dst
		
		INSERT INTO #OUTPUT
			SELECT CURVE_NAME, AS_OF_DATE, NULL, val, is_dst FROM #average
	
		UPDATE #OUTPUT
		SET    is_dst = 0
		WHERE  is_dst = 1				
	END
	
	-- Daily Average
	ELSE IF @average = 'd' AND EXISTS(SELECT 'x' FROM #filteredData) AND @flag <> 'v' 
	BEGIN
		INSERT INTO #OUTPUT
		SELECT CURVE_NAME,
		       AS_OF_DATE [AS_OF_DATE],
		       MAX(MATURITY_DATE) [MATURITY_DATE],
		       AVG(val) 'VAL',
		       is_dst
		FROM   #price
		GROUP BY CURVE_NAME, AS_OF_DATE, YEAR(MATURITY_DATE), MONTH(MATURITY_DATE), DAY(MATURITY_DATE), is_dst
		
		UPDATE #OUTPUT SET is_dst = 0 WHERE is_dst = 1
	END
	
	-- Monthly Average
	ELSE IF @average = 'm' AND EXISTS(SELECT 'x' FROM #filteredData) AND @flag <> 'v'
	BEGIN			
		INSERT INTO #OUTPUT
		SELECT CURVE_NAME,
		       AS_OF_DATE [AS_OF_DATE],
		       MAX(MATURITY_DATE) [MATURITY_DATE],
		       AVG(val) 'VAL',
		       is_dst
		FROM   #price
		GROUP BY CURVE_NAME, AS_OF_DATE, YEAR(MATURITY_DATE), MONTH(CONVERT(DATETIME,MATURITY_DATE, 103)), is_dst
		
		UPDATE #OUTPUT SET is_dst = 0 WHERE is_dst = 1
	END
	
	-- Quaterly Average
	ELSE IF @average = 'q' AND EXISTS(SELECT 'x' FROM #filteredData) AND @flag <> 'v'
	BEGIN
		INSERT INTO #OUTPUT
		SELECT CURVE_NAME,
		       AS_OF_DATE [AS_OF_DATE],
		       MAX(MATURITY_DATE) [MATURITY_DATE],
		       AVG(val) 'VAL',
		       is_dst
		FROM   #price
		GROUP BY CURVE_NAME, AS_OF_DATE, YEAR(MATURITY_DATE), DATEPART(QQ,MATURITY_DATE), is_dst
		
		UPDATE #OUTPUT SET is_dst = 0 WHERE is_dst = 1
	END
	
	-- Yearly/Annualy Average
	ELSE IF @average = 'y' AND EXISTS(SELECT 'x' FROM #filteredData) AND @flag <> 'v'
	BEGIN
		INSERT INTO #OUTPUT
		SELECT CURVE_NAME,
		       AS_OF_DATE [AS_OF_DATE],
		       MAX(MATURITY_DATE) [MATURITY_DATE],
		       AVG(val) 'VAL',
		       is_dst
		FROM   #price
		GROUP BY CURVE_NAME,AS_OF_DATE, YEAR(MATURITY_DATE), is_dst
		
		UPDATE #OUTPUT SET is_dst = 0 WHERE is_dst = 1
	END
	
	-- All Average
	ELSE IF @average = 'l' AND EXISTS(SELECT 'x' FROM #filteredData) AND @flag <> 'v'
	BEGIN
		INSERT INTO #OUTPUT
		SELECT CURVE_NAME,
		       MIN(AS_OF_DATE) [AS_OF_DATE],
		       MAX(MATURITY_DATE) [MATURITY_DATE],
		       AVG(val) 'VAL',
		       is_dst
		FROM   #price
		GROUP BY CURVE_NAME, is_dst
		
		UPDATE #OUTPUT SET is_dst = 0 WHERE is_dst = 1
	END	
		
	ELSE
	BEGIN		
		IF @flag IN ('s', 'v', 'q')
			BEGIN
			INSERT INTO #OUTPUT SELECT CURVE_NAME, AS_OF_DATE, MATURITY_DATE, val, is_dst FROM #price
			END		    
		ELSE IF @flag IN ('i', 'r')
		BEGIN
			INSERT INTO #OUTPUT SELECT CURVE_NAME, AS_OF_DATE, MATURITY_DATE, val, is_dst FROM #template
		    IF @flag = 'i'
		    BEGIN
		        -- This is a temporary fix as the XML could not be made to handle the apostrophe.
		        UPDATE #OUTPUT
		        SET    curve_name = REPLACE(curve_name, '''', '')
		        FROM   #OUTPUT
		        
		        SELECT @curveNamesForPivot = REPLACE(@curveNamesForPivot, '''', '')
		    END
		END
	END	
		
	-- When differential is checked, the value has to be deducted from the root curve in the hierarchy.
	IF @differential_flag = 'd'
	BEGIN
		SELECT TOP 1 @top_curve = REPLACE(curve_name, '''', '''''') FROM   #curvenames
		CREATE TABLE #OnlyInTopCurve (CURVE_NAME VARCHAR(250) COLLATE DATABASE_DEFAULT ,AS_OF_DATE DATETIME,MATURITY_DATE DATETIME,is_dst INT)
				
		SELECT @sql = '
			INSERT INTO #OnlyInTopCurve(CURVE_NAME,AS_OF_DATE,MATURITY_DATE,is_dst) 
			SELECT 	crv.CURVE_NAME,crv_value.AS_OF_DATE,crv_value.MATURITY_DATE,is_dst 
			FROM 
				(
				SELECT DISTINCT o.curve_name FROM #output o WHERE '+
				CASE WHEN @bidAndask_flag='b' THEN ' REPLACE(REPLACE(REPLACE(o.curve_name,''_ASKVALUE'',''''),''_MIDVALUE'',''''),''_BIDVALUE'','''')<>'''  ELSE 'o.curve_name<>''' END
				 +@top_curve +'''
				 ) crv
			CROSS JOIN
			( SELECT a.* FROM
				( 
					SELECT o.* FROM #output o where '+
					CASE WHEN @bidAndask_flag='b' THEN ' REPLACE(REPLACE(REPLACE(o.curve_name,''_ASKVALUE'',''''),''_MIDVALUE'',''''),''_BIDVALUE'','''')='''  ELSE 'o.curve_name=''' END
					 +@top_curve +'''
				) a 
				LEFT JOIN #output b ON a.AS_OF_DATE=b.AS_OF_DATE and a.MATURITY_DATE = b. MATURITY_DATE and a.CURVE_NAME<>b.CURVE_NAME' +
				CASE WHEN @bidAndask_flag='b' THEN ' AND RIGHT(a.CURVE_NAME,8)= RIGHT(b.CURVE_NAME,8) ' ELSE '' END
			+') crv_value'
		--PRINT(@sql)
		EXEC(@sql)
		
		INSERT INTO #OUTPUT(CURVE_NAME,AS_OF_DATE,MATURITY_DATE,is_dst) 
			SELECT CURVE_NAME,AS_OF_DATE,MATURITY_DATE,is_dst FROM #OnlyInTopCurve
		
		SELECT @sql = '
			UPDATE b SET b.val= 
			b.VAL-ISNULL(a.val,0)
			FROM 
			( 
			SELECT o.* FROM #output o WHERE '+
			CASE WHEN @bidAndask_flag='b' THEN ' REPLACE(REPLACE(REPLACE(o.curve_name,''_ASKVALUE'',''''),''_MIDVALUE'',''''),''_BIDVALUE'','''')='''  ELSE 'o.curve_name=''' END
			  +@top_curve +'''
			) a 
			RIGHT JOIN #output b ON a.AS_OF_DATE=b.AS_OF_DATE and a.MATURITY_DATE = b. MATURITY_DATE and a.CURVE_NAME<>b.CURVE_NAME' +
			CASE WHEN @bidAndask_flag='b' THEN ' AND RIGHT(a.CURVE_NAME,8)= RIGHT(b.CURVE_NAME,8) ' ELSE '' END
			--PRINT(@sql)
			EXEC(@sql)
	END

	IF @flag = 'v' AND EXISTS (SELECT 'X' FROM #OUTPUT)
	BEGIN
	    UPDATE o
	    SET    o.CURVE_NAME = o.CURVE_NAME + '_' + dbo.FNADateFormat(AS_OF_DATE)
	    FROM   #OUTPUT o
	    
		UPDATE #OUTPUT SET AS_OF_DATE = NULL
	    
		SELECT @curveNamesForPivot    = NULL
	    SELECT DISTINCT CURVE_NAME AS 'CURVE_NAME' INTO #DISTINCT
	    FROM #OUTPUT
	    
		SELECT @curveNamesForPivot = ISNULL(@curveNamesForPivot+',','') + '['+ CURVE_NAME +']' FROM #DISTINCT			
	END

	-- Get the table name for View Price Batch
	IF @batch_process_id IS NOT NULL
		SELECT @adihaTable = dbo.FNAProcessTableName('batch_report',dbo.FNAdbuser(),@batch_process_id)
	
	--check call from save_derived_curve: test
	
	
	IF @flag = 'q'
	BEGIN
		EXEC('IF OBJECT_ID(''' + @adihaTable + ''') IS NOT NULL
			DROP TABLE ' + @adihaTable)
	END
		
		
	
	
	--Whenever @curveNamesForPivot is null, need to show for the same curve_name
    IF @curveNamesForPivot IS NULL
	BEGIN
		DECLARE @curve_name_default VARCHAR(100)

		SELECT  @curve_name_default = '[' + spcd.curve_name + ']'
		FROM    dbo.source_price_curve_def spcd
				INNER JOIN source_system_description ssd ON spcd.source_system_id = ssd.source_system_id
		WHERE   spcd.source_curve_def_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@curve_id))

		SELECT @curveNamesForPivot = ISNULL(@curveNamesForPivot,@curve_name_default)
	END	

	DECLARE @heading_list VARCHAR(MAX),@heading_lists VARCHAR(MAX)
	IF @average IN ('d')
	BEGIN
		-- Pivot the #output table to show the values in desired format.
		SELECT @sql1 = 'SELECT ' 
							+ CASE WHEN @flag IN ('r','v') THEN '' ELSE ' dbo.FNADateFormat(AS_OF_DATE) [AS OF DATE] ,' END + 
							'dbo.FNADateFormat(MATURITY_DATE) [MATURITY DATE] ,'
				   
		SELECT @heading_list = 
				COALESCE(@heading_list + ',' 
							+ 'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' 
							+ item,'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' + item
						)
		FROM dbo.SplitCommaSeperatedValues(@curveNamesForPivot)
		
		SELECT @sql2 = ' ' + @heading_list +
						CASE WHEN @batch_process_id IS NOT NULL THEN ' INTO '+ @adihaTable ELSE '' END +' FROM #output ' 		
						+' PIVOT( MAX(val) FOR curve_name IN ('+@curveNamesForPivot+'))AS p 
						LEFT JOIN mv90_DST dst ON YEAR(dst.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst.date) = MONTH([MATURITY_DATE]) 
							AND dst.insert_delete=''i'' 
							AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						LEFT JOIN mv90_DST dst1 ON YEAR(dst1.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst1.date) = MONTH([MATURITY_DATE]) 
							AND dst1.insert_delete = ''d'' 
							AND dst1.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						ORDER BY AS_OF_DATE'
	END	
	
	ELSE IF @average IN ('m')
	BEGIN	
		-- Pivot the #output table to show the values in desired format.
		SELECT @sql1 = 'SELECT ' 
							+ CASE WHEN @flag IN ('r','v') THEN '' ELSE ' dbo.FNADateFormat(AS_OF_DATE) [AS OF DATE] ,' END + 
							'CAST(DATEPART(MM,dbo.FNADateFormat(MATURITY_DATE)) AS VARCHAR) + ''/'' 
								+ CAST(DATEPART(YY,dbo.FNADateFormat(MATURITY_DATE)) AS VARCHAR) [MATURITY DATE] ,'
				   
		SELECT @heading_list = 
				COALESCE(@heading_list + ',' 
							+ 'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' 
							+ item,'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' + item
						)
		FROM dbo.SplitCommaSeperatedValues(@curveNamesForPivot)
		
		SELECT @sql2 = ' ' + @heading_list +
						CASE WHEN @batch_process_id IS NOT NULL THEN ' INTO '+ @adihaTable ELSE '' END +' FROM #output ' 		
						+' PIVOT( MAX(val) FOR curve_name IN ('+@curveNamesForPivot+'))AS p 
						LEFT JOIN mv90_DST dst ON YEAR(dst.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst.date) = MONTH([MATURITY_DATE]) 
							AND dst.insert_delete=''i''
							AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						LEFT JOIN mv90_DST dst1 ON YEAR(dst1.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst1.date) = MONTH([MATURITY_DATE]) 
							AND dst1.insert_delete = ''d''
							AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						ORDER BY AS_OF_DATE'
	END	
	ELSE IF @average IN ('q')
	BEGIN	
	
		-- Pivot the #output table to show the values in desired format.
		SELECT @sql1 = 'SELECT ' 
							+ CASE WHEN @flag IN ('r','v') THEN '' ELSE ' dbo.FNADateFormat(AS_OF_DATE) [AS OF DATE] ,' END + 
							'''Q'' + CAST(DATEPART(QQ,dbo.FNADateFormat(MATURITY_DATE)) AS VARCHAR) + ''/'' 
								+ CAST(DATEPART(YY,dbo.FNADateFormat(MATURITY_DATE)) AS VARCHAR) [MATURITY DATE] ,'
				   
		SELECT @heading_list = 
				COALESCE(@heading_list + ',' 
							+ 'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' 
							+ item,'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' + item
						)
		FROM dbo.SplitCommaSeperatedValues(@curveNamesForPivot)
		
		SELECT @sql2 = ' ' + @heading_list +
						CASE WHEN @batch_process_id IS NOT NULL THEN ' INTO '+ @adihaTable ELSE '' END +' FROM #output ' 		
						+' PIVOT( MAX(val) FOR curve_name IN ('+@curveNamesForPivot+'))AS p 
						LEFT JOIN mv90_DST dst ON YEAR(dst.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst.date) = MONTH([MATURITY_DATE]) 
							AND dst.insert_delete=''i'' 
							AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						LEFT JOIN mv90_DST dst1 ON YEAR(dst1.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst1.date) = MONTH([MATURITY_DATE]) 
							AND dst1.insert_delete = ''d'' 
							AND dst1.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						ORDER BY AS_OF_DATE'
	END	
	ELSE IF @average IN ('y')
	BEGIN	
		-- Pivot the #output table to show the values in desired format.
		SELECT @sql1 = 'SELECT ' 
							+ CASE WHEN @flag IN ('r','v') THEN '' ELSE ' dbo.FNADateFormat(AS_OF_DATE) [AS OF DATE] ,' END + 
							'CAST(DATEPART(YY,dbo.FNADateFormat(MATURITY_DATE)) AS VARCHAR) [MATURITY DATE] ,'
				   
		SELECT @heading_list = 
				COALESCE(@heading_list + ',' 
							+ 'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' 
							+ item,'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' + item
						)
		FROM dbo.SplitCommaSeperatedValues(@curveNamesForPivot)
		
		SELECT @sql2 = ' ' + @heading_list +
						CASE WHEN @batch_process_id IS NOT NULL THEN ' INTO '+ @adihaTable ELSE '' END +' FROM #output ' 		
						+' PIVOT( MAX(val) FOR curve_name IN ('+@curveNamesForPivot+'))AS p 
						LEFT JOIN mv90_DST dst ON YEAR(dst.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst.date) = MONTH([MATURITY_DATE]) 
							AND dst.insert_delete=''i'' 
							AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						LEFT JOIN mv90_DST dst1 ON YEAR(dst1.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst1.date) = MONTH([MATURITY_DATE]) 
							AND dst1.insert_delete = ''d'' 
							AND dst1.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						ORDER BY AS_OF_DATE'
	END	
	
	ELSE IF @average IN ('l')
	BEGIN	
		-- Pivot the #output table to show the values in desired format.
		SELECT @sql1 = 'SELECT 
							--dbo.FNADateFormat(AS_OF_DATE) [AS OF DATE], 
							--NULL [AS OF DATE],
							--dbo.FNADateFormat(MATURITY_DATE) [MATURITY DATE] ,
							--NULL [MATURITY DATE] ,
							
							'
				   
		SELECT @heading_list = 
				COALESCE(@heading_list + ',' 
							+ 'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' 
							+ item,'dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19)))' + item
						)
		FROM dbo.SplitCommaSeperatedValues(@curveNamesForPivot)
		
		SELECT @sql2 = ' ' + @heading_list +
						CASE WHEN @batch_process_id IS NOT NULL THEN ' INTO '+ @adihaTable ELSE '' END +' FROM #output ' 		
						+' PIVOT( MAX(val) FOR curve_name IN ('+@curveNamesForPivot+'))AS p 
						LEFT JOIN mv90_DST dst ON YEAR(dst.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst.date) = MONTH([MATURITY_DATE]) 
							AND dst.insert_delete=''i''
							AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						LEFT JOIN mv90_DST dst1 ON YEAR(dst1.date) = YEAR([MATURITY_DATE]) 
							AND MONTH(dst1.date) = MONTH([MATURITY_DATE]) 
							AND dst1.insert_delete = ''d''
							AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						ORDER BY AS_OF_DATE'
	END	
		
	ELSE
	BEGIN	
	
		-- Pivot the #output table to show the values in desired format.
		SELECT @sql1 = 
			'SELECT' + 
					CASE WHEN @flag IN ('r','v') THEN '' ELSE ' dbo.FNADateFormat(AS_OF_DATE) [AS OF DATE] ,' END			
				  + CASE WHEN ISNULL(@average,'') <> 'a' THEN ' dbo.FNADateFormat(MATURITY_DATE) [MATURITY_DATE], ' ELSE '' END 
				  + CASE WHEN ISNULL(@average,'') <> 'a' AND @granularity_true = 'y' AND @flag<>'v' 
							THEN 'DATEPART(hh,MATURITY_DATE)+1 [HOUR],' 
									+ CASE WHEN @granularity IN(987,989) THEN 'DATEPART(minute,MATURITY_DATE) [MIN],' ELSE '' END 
						 ELSE '' END
				


		SELECT
			@heading_list = COALESCE(@heading_list + ',' + 'ISNULL(dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19))), '''')' + item,'ISNULL(dbo.FNARemoveTrailingZero(CAST('+ item + ' AS NUMERIC(38,19))), '''')' + item)
		FROM dbo.SplitCommaSeperatedValues(@curveNamesForPivot)		
		
		SELECT @sql2 = CASE WHEN ISNULL(@average,'') <> 'a' 
								THEN CASE 
										WHEN @granularity IN(987,989,982) AND @flag<>'v' 
											THEN ''+ CASE 
														WHEN @flag='i' THEN 'dbo.FNADateFormat(MATURITY_DATE)+'' ''+SUBSTRING(CONVERT(VARCHAR(8),MATURITY_DATE,108),1,5) [Actual_Maturity],is_dst [DST],dbo.FNADateFormat(dst.date) +'' ''+RIGHT(''00''+CAST(dst.hour-1 AS VARCHAR),2)+'':00'' [DST_Time],dbo.FNADateFormat(dst1.date) +'' ''+RIGHT(''00''+CAST(dst1.hour-1 AS VARCHAR),2)+'':00'' [DST_Time_Delete],' 
														ELSE '' 
													 END 
										ELSE '' 
									END  
							ELSE '' 
					   END
					   + @heading_list +
						CASE WHEN @batch_process_id IS NOT NULL THEN ' INTO '+ @adihaTable ELSE '' END +' FROM #output ' 		
						+' PIVOT
						(
							MAX(val) FOR curve_name IN ('+@curveNamesForPivot+')
						)AS p 
						LEFT JOIN mv90_DST dst ON YEAR(dst.date)=YEAR([MATURITY_DATE]) AND MONTH(dst.date)=MONTH([MATURITY_DATE]) 
							AND dst.insert_delete=''i'' 
							AND dst.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						LEFT JOIN mv90_DST dst1 ON YEAR(dst1.date)=YEAR([MATURITY_DATE]) AND MONTH(dst1.date)=MONTH([MATURITY_DATE]) 
							AND dst1.insert_delete=''d'' 
							AND dst1.dst_group_value_id ='+ISNULL(@dst_group_value_id,102200)+'
						ORDER BY '+
					CASE WHEN @flag = 'v' THEN '' ELSE 'AS_OF_DATE' END +
					CASE WHEN @flag = 'v' OR @average = 'a' THEN '' ELSE ',' END+ 
					CASE WHEN ISNULL(@average,'')<>'a' THEN 'CAST(CONVERT(VARCHAR(10),MATURITY_DATE,101) AS datetime), DATEPART(hh, MATURITY_DATE), is_dst, DATEPART(mi, MATURITY_DATE)' ELSE '' END 
	END
		
		
	-- Paging logic starts here
	DECLARE @sql_paging VARCHAR(1000)
	SET @sql_paging = ''

	IF @apply_paging = 'y'
	BEGIN	
		
		SELECT 
			@heading_definition = COALESCE(@heading_definition + ',' + item + ' VARCHAR(50)', item + ' VARCHAR(50)'),
			@heading_lists= COALESCE(@heading_lists + ',' + item  , item )
		FROM dbo.SplitCommaSeperatedValues(@curveNamesForPivot)

		IF @process_id_paging IS NULL
		BEGIN
			SET @flag_paging = 'i'
			SET @process_id_paging = REPLACE(newid(),'-','_')
		END
		
		SET @tempTable=dbo.FNAProcessTableName('paging_maintain_price_curve', @user_login_id,@process_id_paging)
		IF @flag_paging = 'i'
		BEGIN 
			
			IF @average IN ('d','m','q','y')
			BEGIN
				SET @sql = 'CREATE TABLE '+ @tempTable+'
				            (
				            	sno            INT IDENTITY(1, 1),
				            	as_of_date     VARCHAR(20),
				            	maturity_date  VARCHAR(20),
				            	'+ @heading_definition + '
				            )'
				SET @sql_paging = 'INSERT INTO ' + @tempTable +'(as_of_date,maturity_date,'  +@heading_lists+') '	
			END
			ELSE IF @average = 'l'
			BEGIN
				SET @sql = 'CREATE TABLE '+ @tempTable+'
				            (
				            	sno            INT IDENTITY(1, 1),
				            	--as_of_date     VARCHAR(20),
				            	--maturity_date  VARCHAR(20),
				            	'+ @heading_definition + '
				            )'
				SET @sql_paging = 'INSERT INTO ' + @tempTable +'('  +@heading_lists+') '
			END
			ELSE
			BEGIN
				SET @sql = 'CREATE TABLE '+ @tempTable+'
							( 
								sno				INT IDENTITY(1,1),
								as_of_date		VARCHAR(20),
								'+CASE WHEN ISNULL(@average,'')<>'a' THEN 'maturity_date	VARCHAR(20),'+
									+CASE WHEN @granularity_true='y' THEN 'HOUR INT,'+CASE WHEN @granularity IN(987,989) THEN 'MIN INT,' ELSE '' END+'' ELSE '' END ELSE '' END
								+ @heading_definition + '
							)'
				SET @sql_paging = 'INSERT INTO ' + @tempTable +'(as_of_date,'+ CASE WHEN ISNULL(@average,'') <> 'a' THEN 'maturity_date,' + CASE WHEN @granularity_true='y' THEN '[HOUR],'+CASE WHEN @granularity IN(987,989) THEN '[MIN],' ELSE '' END+'' ELSE '' END ELSE '' END  +@heading_lists+') '
			END					
			
			--PRINT @sql
			EXEC(@sql)			

			--PRINT @sql_paging
			--PRINT '******************************************'	
			--PRINT @sql_paging + @sql1 + @sql2
			--PRINT '******************************************'	

			EXEC(@sql_paging + @sql1 + @sql2)
			
			SET @sql = 'SELECT COUNT(*) TotalRow,'''+@process_id_paging + ''' process_id  FROM ' + @tempTable
			--PRINT @sql
			EXEC(@sql)
			
			RETURN 
		END 		
	END	

	--PRINT '******************************************'	
	--PRINT @sql1 + @sql2
	--PRINT '******************************************'	

	EXEC(@sql1 + @sql2)

		--todo: saving derived curve value
		IF @flag = 'q'
		BEGIN
			BEGIN TRY
				DECLARE @error_code VARCHAR(500), @desc VARCHAR(500), 
						@process_id_flag_q VARCHAR(500) = @batch_process_id --dbo.FNAGetNewID()
						, @user_name VARCHAR(100) = dbo.fnadbuser(), @url VARCHAR(500) = ''
				SET @error_code = 's'
				SET @desc = 'Derived Curve Calculation has been completed. '
				SET @user_login_id =  dbo.FNADBUser()
			
				IF EXISTS (	SELECT scsv.item FROM dbo.SplitCommaSeperatedValues(@curve_id) scsv
							INNER JOIN source_price_curve_def spcd ON scsv.item = spcd.source_curve_def_id
							WHERE spcd.curve_name NOT IN (SELECT DISTINCT o.curve_name FROM #OUTPUT o)
				) 
				BEGIN
					INSERT INTO fas_eff_ass_test_run_log (process_id, code, MODULE, source, TYPE, description, nextsteps) 
					SELECT  @process_id_flag_q, 'Error', 'Derived Curve Calculation', 'maintain_price_curve', 
							'Derived Curve Error', 'Curve Value not found for ' + CAST(spcd.curve_name AS VARCHAR(50)) 
							+ ' ( ID = ' + scsv.item + ') due to missing price of Curve ' + spcd2.curve_name + '( ID = ' + CAST(pcm.primary_curve_id AS VARCHAR(20)) + ')' + ' for as of date: ' + CAST(CAST(@asOfdateFrom AS date) AS VARCHAR(20)) + 
							CASE WHEN @asOfdateTo IS NOT NULL THEN ' to ' + CAST(CAST(@asOfdateTo AS date) AS VARCHAR(20)) ELSE '' END +
							CASE WHEN @tenorFrom IS NOT NULL AND @tenorTo IS NOT NULL THEN ' and tenor: ' + CAST(CAST(@tenorFrom AS date) AS VARCHAR(20)) + ' to ' + CAST(CAST(@tenorTo AS date) AS VARCHAR(20))
								 WHEN @tenorFrom IS NOT NULL AND @tenorTo IS NULL THEN ' and tenor from: ' + CAST(CAST(@tenorFrom AS date) AS VARCHAR(20))
								 WHEN @tenorFrom IS NULL AND @tenorTo IS NOT NULL THEN ' and tenor to: ' + CAST(CAST(@tenorTo AS date) AS VARCHAR(20))
								 ELSE ''
							END
							, 'Please Import Price Curves.'
					FROM dbo.SplitCommaSeperatedValues(@curve_id) scsv	
					INNER JOIN source_price_curve_def spcd ON scsv.item = spcd.source_curve_def_id
					INNER JOIN #primary_curve_mapping pcm ON pcm.derived_curve_id = scsv.item
					INNER JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = pcm.primary_curve_id
					WHERE spcd.curve_name NOT IN (SELECT DISTINCT o.curve_name FROM #OUTPUT o)			
				 
				END
				
				BEGIN TRAN
				
					--SELECT '#OUTPUT', * FROM #OUTPUT
					--delete from source_price_curve for that curve, as_of_date, curve_source, curve_type, maturity
					DELETE spc 
					FROM source_price_curve spc					
					INNER JOIN (
						SELECT spcd.source_curve_def_id, o.as_of_date, @curve_type [Assessment_curve_type_value_id]
								, @curve_source [curve_source_value_id], o.maturity_date, SUM (o.val)  [curve_value], o.is_dst 
						FROM #OUTPUT o
						INNER JOIN source_price_curve_def spcd ON spcd.curve_name = o.curve_name
						GROUP BY o.curve_name, spcd.source_curve_def_id, as_of_date, maturity_date, is_dst
					) out_query ON out_query.source_curve_def_id = spc.source_curve_def_id
									AND spc.as_of_date = out_query.as_of_date
									AND spc.Assessment_curve_type_value_id = @curve_type
									AND spc.curve_source_value_id = @curve_source
									AND spc.maturity_date >= CASE WHEN @tenorFrom IS NOT NULL THEN @tenorFrom ELSE spc.maturity_date END
									AND spc.maturity_date <= CASE WHEN @tenorTo IS NOT NULL THEN @tenorTo ELSE spc.maturity_date END
									AND spc.is_dst = out_query.is_dst
					
					-- insert caculated curve values into table source_price_curve
					INSERT INTO source_price_curve
					(
						source_curve_def_id,
						as_of_date,
						Assessment_curve_type_value_id,
						curve_source_value_id,
						maturity_date,
						curve_value,
						is_dst,
						update_user, update_ts
					)
					SELECT spcd.source_curve_def_id, o.as_of_date, @curve_type [Assessment_curve_type_value_id]
							, @curve_source [curve_source_value_id], o.maturity_date, SUM (o.val) [curve_value], o.is_dst, dbo.FNADBUser(), GETDATE()
					FROM #OUTPUT o
					INNER JOIN source_price_curve_def spcd ON spcd.curve_name = o.curve_name
					GROUP BY o.curve_name, spcd.source_curve_def_id, as_of_date, maturity_date, is_dst
					
					
				
				COMMIT
					IF EXISTS (SELECT 1 FROM fas_eff_ass_test_run_log WHERE process_id = @process_id_flag_q AND code = 'Error')
					BEGIN
						SET @error_code = 'e'
						SET @desc = 'Derived Curve Calculation has been completed. (ERRORS FOUND).'
						SET @url = './dev/spa_html.php?__user_name__=' + @user_name +  
								'&spa=exec spa_fas_eff_ass_test_run_log ''' + @process_id_flag_q + ''',''y'', ''Derived Curve Error'''
								
						RAISERROR('CatchError', 16, 1)
					END
					ELSE
					BEGIN
						SET @error_code = 's'
						SET @desc = 'Derived Curve Calculation has been completed. '							
					END
				
				--PRINT '************ derived curve value calculation complete ***********'		
				
				
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK
				
				IF ERROR_MESSAGE() = 'CatchError'
				BEGIN
					SET @desc = 'Derived Curve Calculation has been completed. (ERRORS FOUND).'
					--PRINT @desc
				END
				ELSE
				BEGIN
					SET @desc = 'Calculation critical error found ( Errr Description:' +  ERROR_MESSAGE() + '; Line no: ' + CAST(ERROR_LINE() AS VARCHAR) + ').'
					--PRINT @desc
				END 
				
				SELECT @desc = '<a target="_blank" href="' + @url + '">' + @desc + '.</a>'				
				
			END CATCH
			
			DECLARE @job_name_to_update VARCHAR(500) = 'batch_' + @process_id_flag_q	
		
			EXEC  spa_message_board 'u', @user_login_id,
						NULL, 'Derived Curve Calculation',
						@desc, '', '', @error_code, @job_name_to_update, NULL, @process_id_flag_q, NULL, 'n', '', 'y'
		END 

	-- Code for View Price Batch
	IF @batch_process_id IS NOT NULL
	BEGIN			
		SELECT @batch_report_param = @batch_report_param + 	',NULL,NULL,''' + @adihaTable+''''
		SELECT @batch_stmt = dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_maintain_price_curve','Price Curve')     			

		--PRINT @batch_stmt
		EXEC(@batch_stmt)
	END
END


