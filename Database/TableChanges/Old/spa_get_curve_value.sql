IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_curve_value]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_curve_value]
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spa_get_curve_value] 
				@curve_id				VARCHAR (8000)		,
				@from_date				VARCHAR(20)			,
				@to_date				VARCHAR(20)	,
				@term_start				VARCHAR(20) 	,
				@term_end				VARCHAR(20) 	,
				@convert_to_FX  int=null,
				@convert_to_UOM int=null
as

/*
DECLARE
				@curve_id				VARCHAR (8000)		,
				@curve_type				INT					,				
				@curve_source			INT					,
				@from_date				VARCHAR(20)			,
				@to_date				VARCHAR(20)	,
				@term				VARCHAR(20) 	,
				@get_derive_value		CHAR(1),
				@relative_term int=null,
				@convert_to_FX  int=null,
				@convert_to_UOM int=null
				----'y'-> get derive curve, 'n'-> do not get derive curve

SELECT 
				@curve_id	=	'82,81'	,
				@curve_type	=	'77'			,				
				@curve_source=	'4500'				,
				@from_date	=	'2012-01-12'		,
				@to_date	 = '2012-05-12'	,
				@term		 = NULL	,
				@get_derive_value	='y'	----'y'-> get derive curve, 'n'-> do not get derive curve

DROP TABLE #curveNames
DROP TABLE #filteredData
DROP TABLE #formulaData
DROP TABLE #tmp_term

--*/
	
	
DECLARE @asOfdateFrom				  DATETIME		, @asOfdateTo			DATETIME		,
		@tenorFrom					  DATETIME		, @tenorTo				DATETIME		,
		@sql						  VARCHAR(8000) , @curve_id_tmp		    VARCHAR(8000)	,
		@curve_name					  VARCHAR(8000) , @curveNamesForPivot	VARCHAR(MAX)	,
		@sql1						  VARCHAR(MAX)	, @sql2					VARCHAR(MAX)	,
		@granularity_true			  CHAR(1)		, @batch_stmt			VARCHAR(MAX)	,
		@granularity				int ,@user_login_id varchar(30),
				@curve_type				INT					,				
				@curve_source			INT					,
				@get_derive_value		CHAR(1)

	
set @user_login_id=dbo.FNADBUser()

select 	@curve_type	=77				,				
				@curve_source	=4500				,
				@get_derive_value='y'

CREATE TABLE #curveNames(source_curve_def_id INT,curve_name VARCHAR(250))
CREATE TABLE #filteredData(source_curve_def_id INT,curve_name VARCHAR(250),as_of_date DATETIME,maturity_date DATETIME,bid_value FLOAT,ask_value FLOAT,mid_value FLOAT, is_dst int
		,source_system_id int,	source_currency_id int, source_currency_to_ID int,Granularity int,uom_id int)	

--create table #tmp_term(term_start date,term_end date)


--if @term is not null
--begin 
--	if @relative_term is null
--		SELECT 	@tenorFrom    = convert(varchar(8),@term,120)+'01'	,
--				@tenorTo      = DATEADD(month,1,convert(varchar(8),@term,120)+'01')-1	
--	else
--	begin
--		insert into #tmp_term	exec [dbo].[spa_get_logical_term] @term,@relative_term 
		
--		SELECT 	@tenorFrom    = term_start	,@tenorTo      = term_end	from #tmp_term
		
--	end
--end
SELECT 	@tenorFrom    = @term_start	,@tenorTo   =@term_end

SELECT 	@asOfdateFrom = CAST(@from_date AS DATETIME)	,
		@asOfdateTo	  = CAST(isnull(@to_date,@from_date) AS DATETIME)	
		
			
-- Get the curve names involved
		
INSERT INTO #curveNames
SELECT  source_curve_def_id, curve_name FROM dbo.splitCommaSeperatedValues(@curve_id) 
			INNER JOIN source_price_curve_def spcd ON item = spcd.source_curve_def_id
			INNER JOIN source_system_description ssd ON spcd.source_system_id = ssd.source_system_id


SELECT  @curve_id_tmp = ISNULL(@curve_id_tmp+',','') + CAST(source_curve_def_id AS VARCHAR) FROM #curveNames


IF @tenorFrom IS NULL
	SELECT @tenorFrom = MIN(maturity_date) 
		FROM source_price_curve 
			WHERE source_curve_def_id IN (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id_tmp))
			AND as_of_date BETWEEN @asOfdateFrom AND @asOfdateTo
			AND curve_source_value_id = @curve_source

IF @tenorTo IS NULL
	SELECT @tenorTo = MAX(maturity_date) 
		FROM source_price_curve 
			WHERE EXISTS (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id_tmp) WHERE item = source_curve_def_id)
			AND as_of_date BETWEEN @asOfdateFrom AND @asOfdateTo
			AND curve_source_value_id = @curve_source			
SELECT @granularity = MAX(Granularity) ,
	   @curve_name  = MAX(REPLACE(spcd.curve_name,'''',''''''))	
		FROM source_price_curve_def spcd
		INNER JOIN source_system_description ssd ON spcd.source_system_id = ssd.source_system_id
			WHERE EXISTS (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id_tmp) WHERE item = spcd.source_curve_def_id) 

IF EXISTS(SELECT 'X' FROM source_price_curve_def 
			WHERE EXISTS (SELECT item FROM dbo.splitCommaSeperatedValues(@curve_id_tmp) WHERE item = source_curve_def_id) 
				AND Granularity IN (982,987,989))	
					SELECT @granularity_true = 'y'

IF @granularity_true = 'y'
	SELECT @tenorTo = DATEADD(MI,-15,DATEADD(DD,1,@tenorTo))

SET @sql1 = 'INSERT INTO #filteredData
		SELECT spc.source_curve_def_id,(curve_name) AS curve_name,as_of_date,maturity_date,dbo.FNARemoveTrailingZero(CAST(bid_value AS NUMERIC(38,19))),ask_value,curve_value AS ''MID_VALUE'',is_dst 		 
		,spcd.source_system_id ,	spcd.source_currency_id , spcd.source_currency_to_ID ,spcd.Granularity ,isnull(spcd.display_uom_id, spcd.uom_id)
			FROM '+dbo.[FNAGetProcessTableName](cast(@asOfdateFrom AS VARCHAR),'source_price_curve')+' spc 
			INNER JOIN source_price_curve_def spcd
				ON spc.source_curve_def_id = spcd.source_curve_def_id
			INNER JOIN source_system_description ssd 
				ON spcd.source_system_id = ssd.source_system_id
			WHERE Assessment_curve_type_value_id = '+cast(@curve_type AS VARCHAR)+
			  ' AND curve_source_value_id = '+cast(@curve_source AS VARCHAR)+
			  ' AND as_of_date BETWEEN '''+cast(@asOfdateFrom AS VARCHAR)+''' AND '''+cast(@asOfdateTo AS varchar)+''''
			  + case when @tenorFrom is not null AND @tenorTo IS NOT NULL THEN ' AND maturity_date  BETWEEN '''+cast(isnull(@tenorFrom,@tenorTo) AS varchar)+''' AND '''+cast(isnull(@tenorTo,@tenorFrom) AS varchar) + '''' ELSE '' END +
			  ' AND EXISTS (SELECT item FROM dbo.splitCommaSeperatedValues('+''''+cast(@curve_id_tmp AS VARCHAR)+''''+') WHERE  item = spc.source_curve_def_id)'		  
PRINT @sql1 
EXEC(@sql1)	  
		  

-- Updation of formulated price for the curves in case when formula exists
SELECT source_curve_def_id,as_of_date,maturity_date,CAST(NULL AS FLOAT) 'formula_value',NULL 'formula_id',NULL 'formula_str' 
	INTO #formulaData 
		FROM #filteredData WHERE 1=2

-- Only call derive SP if @get_derive_value='y'
--		SELECT @curve_id_tmp,@asOfdateFrom,@asOfdateTo,@curve_source, '#formulaData',@tenorFrom,@tenorTo

IF @get_derive_value='y'
	EXEC spa_derive_curve_value @curve_id_tmp,@asOfdateFrom,@asOfdateTo,@curve_source, '#formulaData',@tenorFrom,@tenorTo	

INSERT INTO #filteredData
	SELECT frml.source_curve_def_id,spcd.curve_name AS curve_name,frml.as_of_date,frml.maturity_date,NULL,NULL,frml.formula_value,is_dst 
			,spcd.source_system_id ,	spcd.source_currency_id , spcd.source_currency_to_ID ,spcd.Granularity ,isnull(spcd.display_uom_id, spcd.uom_id) uom_id
			
		FROM #formulaData frml LEFT OUTER JOIN #filteredData fltr
			ON frml.source_curve_def_id = fltr.source_curve_def_id
			AND fltr.as_of_date = frml.as_of_date	
			AND fltr.maturity_date = frml.maturity_date				
			INNER JOIN  source_price_curve_def spcd 
				ON spcd.source_curve_def_id = frml.source_curve_def_id
			LEFT JOIN source_system_description ssd ON ssd.source_system_id=spcd.source_system_id
			WHERE frml.formula_value IS NOT NULL	
			AND fltr.source_curve_def_id IS NULL	
			

UPDATE fltr 
	SET fltr.bid_value = formula_value ,
		fltr.ask_value = formula_value ,
		fltr.mid_value = formula_value 
		FROM #filteredData fltr INNER JOIN #formulaData frml
			ON fltr.source_curve_def_id = frml.source_curve_def_id
			AND fltr.as_of_date = frml.as_of_date
			AND fltr.maturity_date = frml.maturity_date
	WHERE frml.formula_value IS NOT NULL	

UPDATE #filteredData SET bid_value = mid_value WHERE bid_value IS NULL
UPDATE #filteredData SET ask_value = mid_value WHERE ask_value IS NULL

UPDATE #filteredData SET is_dst = 0 WHERE is_dst IS NULL


select spcd.curve_name, spcd.as_of_date, dbo.FNADateFormat(spcd.as_of_date) AsOfDate, spcd.maturity_date, dbo.FNAUserDateTimeFormat(spcd.maturity_date,2,@user_login_id) Term,spcd.is_dst DST,
mid_value * COALESCE(spc_to.curve_value, 1/NULLIF(spc_from.curve_value,0),1) * isnull(vc.conversion_factor,1) Price,sc.currency_name Currency,su.uom_name UOM
from #filteredData spcd 
left join source_price_curve_def fx_to ON	spcd.source_system_id = fx_to.source_system_id  and spcd.source_currency_id = fx_to.source_currency_id AND
	fx_to.source_currency_to_ID =@convert_to_FX --and spcd.Granularity=980	
left join source_price_curve_def fx_from ON	spcd.source_system_id = fx_from.source_system_id  and spcd.source_currency_id = fx_from.source_currency_id AND
	fx_from.source_currency_to_ID = @convert_to_FX --and spcd.Granularity=980	
left join source_price_curve spc_to  with(nolock) ON	spc_to.source_curve_def_id = fx_to.source_curve_def_id AND
		spcd.as_of_date = spc_to.as_of_date AND
		spc_to.curve_source_value_id = @curve_source
left join source_price_curve spc_from  with(nolock) ON	spc_from.source_curve_def_id = fx_from.source_curve_def_id AND
		spcd.as_of_date = spc_from.as_of_date AND
		spc_from.curve_source_value_id = @curve_source							
left join source_currency sc on sc.source_currency_id	= COALESCE(@convert_to_FX,spcd.source_currency_id,-1)
left join rec_volume_unit_conversion vc on vc.from_source_uom_id=spcd.uom_id and vc.to_source_uom_id=COALESCE(@convert_to_UOM,-1)
left join source_uom su on su.source_uom_id	=isnull(@convert_to_UOM,spcd.uom_id)
--order by spcd.maturity_date,spcd.is_dst desc
GO


