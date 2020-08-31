
IF OBJECT_ID('[dbo].[spa_get_cached_curve_value]') IS NOT NULL
	DROP PROC [dbo].[spa_get_cached_curve_value]
GO
--exec dbo.spa_get_cached_curve_value '2011-06-30','b',4500,null,null


CREATE PROC [dbo].[spa_get_cached_curve_value]  
	@as_of_date DATETIME
	, @type VARCHAR(1) = 'b'
	, @curve_source_id INT = 4500
	, @contract_id INT = NULL 
	, @curve_id	INT = NULL
	, @term_start DATETIME = NULL
	, @term_end DATETIME = NULL

AS
/*

--as of date
--type (f, s, b)
--source
--contract_id (NULL)
--curve_id (NULL)
--term_start (NULL)
--term_end (NULL)

[Contract ID], [Index ID], [Index], [As of Date], [Term], [Type], [Value], lag.... 4 round clms

DECLARE @as_of_date DATETIME='2011-06-30',@type varchar(1)='b'
,@term_start DATETIME=NULL
,@term_end DATETIME=NULL
, @curve_id	INT=NULL
, @contract_id INT=NULL 
,@curve_source_id INT=4500
,@pricing_option INT=0,
@volume_multiplier FLOAT=1
	
--DECLARE @index_round_value INT ,@fx_round_value INT,@total_round_value INT ,  @mid bit,@bid_ask_round_value INT
--DECLARE @settlement_curve_id INT,@final_round_value INT		,@lag_round_value INT
--*/

DECLARE @settle_date DATETIME,@settle BIT,@st VARCHAR(MAX)

SET @settle_date=DATEADD(MONTH,1,CAST(CONVERT(VARCHAR(8),@as_of_date,120)+'01' AS DATETIME))-1

IF @settle_date<>@as_of_date
	SET @settle_date=CAST(CONVERT(VARCHAR(8),@as_of_date,120)+'01' AS DATETIME)-1
		
SET @settle=0
IF @as_of_date <= @settle_date
	SET @settle=1

SELECT @term_start=COALESCE(@term_start,MIN(term),'1990-01-01'),@term_end=COALESCE(@term_end,MAX(term),'9999-01-01') FROM  cached_curves_value 
EXEC spa_print @term_start
EXEC spa_print @term_end

SET @st='
SELECT cg.contract_name [Contract],spcd.curve_name [Index],v.as_of_date [As of Date],v.term [Term],v.value_type [Type],
	round(ROUND(CASE WHEN isnull('+CASE WHEN @settle =1 THEN 'r.set_mid' ELSE 'r.mid' END+',1)=1 THEN v.curve_value ELSE v.bid_ask_curve_value END, isnull(r.final_round_value, 12)) 
		,isnull(r.lag_round_value,12)) [Value],c.Strip_Month_From [Strip Month From], c.Lag_Months [Lag Months],c.Strip_Month_To [Strip Month To]
		,r.index_round_value [Index Round By],r.fx_round_value [FX Round By],r.total_round_value [Total Round By],
		r.bid_ask_round_value [Bid Ask Round By],r.final_round_value [Final Round By],r.lag_round_value [Lag Round By]
FROM
	contract_formula_rounding_options r	INNER JOIN cached_curves c ON c.curve_id=r.curve_id 
		AND isnull(r.index_round_value,-1)=isnull(c.index_round_value,-1) AND
			isnull(r.fx_round_value,-1)=isnull(c.fx_round_value,-1) AND isnull(r.total_round_value,-1)=isnull(c.total_round_value,-1)
			  AND isnull(r.bid_ask_round_value,-1)=isnull(c.bid_ask_round_value,-1)'
		+ CASE WHEN @contract_id IS NOT NULL THEN ' AND r.contract_id='+CAST(@contract_id AS VARCHAR)  ELSE '' END 	  
		+ CASE WHEN @curve_Id IS NOT NULL THEN ' AND r.curve_id=' +CAST(@curve_Id AS VARCHAR) ELSE '' END
		+ '	INNER  JOIN cached_curves_value v  ON c.rowid=v.Master_ROWID
				and  v.term BETWEEN '''+ CONVERT(VARCHAR(10),@term_start,120) +''' AND '''+ CONVERT(VARCHAR(10),@term_end,120) +''' 
				and v.curve_source_id='+CAST(@curve_source_id AS VARCHAR)
		+ CASE WHEN @curve_Id IS NOT NULL THEN ' AND c.curve_id=' +CAST(@curve_Id AS VARCHAR) ELSE '' END
		+ CASE WHEN ISNULL(@type,'b')='f' THEN ' and 1=2'  ELSE ' AND  v.value_type=''s''' END
		+ ' inner join source_price_curve_def spcd on spcd.source_curve_def_id=c.curve_id
		INNER JOIN contract_group cg ON cg.contract_id = r.contract_id

UNION ALL 
	
SELECT cg.contract_name [Contract],spcd.curve_name [Index],v.as_of_date [As of Date],v.term [Term],v.value_type [Type],
	round(ROUND(CASE WHEN isnull('+CASE WHEN @settle =1 THEN 'r.set_mid' ELSE 'r.mid' END+',1)=1 THEN v.curve_value ELSE v.bid_ask_curve_value END, isnull(r.final_round_value, 12)) 
		,isnull(r.lag_round_value,12)) [Value],c.Strip_Month_From, c.Lag_Months,c.Strip_Month_To,r.index_round_value,r.fx_round_value,r.total_round_value,r.bid_ask_round_value
		,r.final_round_value,r.lag_round_value
FROM
	contract_formula_rounding_options r	INNER JOIN cached_curves c ON c.curve_id=r.curve_id 
		AND isnull(r.index_round_value,-1)=isnull(c.index_round_value,-1) AND
			isnull(r.fx_round_value,-1)=isnull(c.fx_round_value,-1) AND isnull(r.total_round_value,-1)=isnull(c.total_round_value,-1)
			  AND isnull(r.bid_ask_round_value,-1)=isnull(c.bid_ask_round_value,-1)'
		+ CASE WHEN @contract_id IS NOT NULL THEN ' AND r.contract_id='+CAST(@contract_id AS VARCHAR)  ELSE '' END 	  
		+ CASE WHEN @curve_Id IS NOT NULL THEN ' AND r.curve_id=' +CAST(@curve_Id AS VARCHAR) ELSE '' END
		+ '	INNER  JOIN cached_curves_value v  ON c.rowid=v.Master_ROWID
				and  v.term BETWEEN '''+ CONVERT(VARCHAR(10),@term_start,120) +''' AND '''+ CONVERT(VARCHAR(10),@term_end,120) +''' 
				and v.curve_source_id='+CAST(@curve_source_id AS VARCHAR)
		+ CASE WHEN @curve_Id IS NOT NULL THEN ' AND c.curve_id=' +CAST(@curve_Id AS VARCHAR) ELSE '' END
		+ ' AND  v.as_of_date=''' +CONVERT(VARCHAR(10),@as_of_date ,120) +'''' 
		+ CASE WHEN ISNULL(@type,'b')='s' THEN ' and 1=2'  ELSE ' AND  v.value_type=''f''' END 
		+'	inner join source_price_curve_def spcd on spcd.source_curve_def_id=c.curve_id
		INNER JOIN contract_group cg ON cg.contract_id = r.contract_id
	
ORDER BY 
	spcd.curve_name,cg.contract_name,Strip_Month_From,Lag_Months,Strip_Month_To,as_of_date,term
'
		
		
EXEC spa_print @st
EXEC(@st)


--SELECT * FROM cached_curves_value WHERE value_type='s' --162
--SELECT * FROM cached_curves_value WHERE value_type='f' --1458

--1620