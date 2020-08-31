
/****** Object:  StoredProcedure [dbo].[spa_calculate_credit_risks]    Script Date: 02/08/2010 23:24:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calculate_credit_risks]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calculate_credit_risks]

/****** Object:  StoredProcedure [dbo].[spa_calculate_credit_risks]    Script Date: 02/08/2010 23:24:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_calculate_credit_risks]
	@as_of_date			DATETIME,
	@counterparty_ids	VARCHAR(MAX) = NULL

AS
/*
DECLARE @as_of_date DATETIME,	@counterparty_ids VARCHAR(MAX)
select @as_of_date ='2009-12-16',	@counterparty_ids =null
DROP table #temp_counterparty
DROP TABLE #temp_formula
DROP TABLE #temp_formula_value
DROP TABLE #real_formula_value
--DROP TABLE

--*/

DECLARE @sql VARCHAR(MAX), @formula_stmt VARCHAR(MAX)
SET @sql = ''

CREATE TABLE #temp_counterparty (counterparty_id INT, risk_rating int)

SET @sql = '
		INSERT INTO #temp_counterparty (counterparty_id, risk_rating)
		SELECT sc.source_counterparty_id, cci.risk_rating 
		FROM source_counterparty sc 
		LEFT JOIN 
		(
			SELECT counterparty_id, MAX(risk_rating) risk_rating 
			FROM counterparty_credit_info  
			GROUP BY counterparty_id
		) cci ON sc.source_counterparty_id = cci.counterparty_id
		WHERE sc.int_ext_flag = ''e''' +
		CASE WHEN ISNULL(@counterparty_ids, '') = '' THEN '' 
			 ELSE ' AND sc.source_counterparty_id IN (' + @counterparty_ids + ')' 
		END	
			
exec spa_print @sql
EXEC(@sql)
--SELECT * FROM #temp_counterparty

CREATE TABLE #temp_formula(
	rowid int IDENTITY(1,1),
	counterparty_limit_id int,
	counterparty_id int,-- (can be NULL)
	formula_group_id int,
	formula_id int,
	formula varchar(max) COLLATE DATABASE_DEFAULT,
	sequence_number int
)

--SELECT * FROM static_data_value sdv WHERE sdv.value_id=5650
INSERT INTO #temp_formula(counterparty_limit_id, counterparty_id, formula_group_id, formula_id, formula, sequence_number)		
SELECT 	cl.counterparty_limit_id, COALESCE(tmp_cpty.counterparty_id, tmp_int.counterparty_id
	,tmp_all.counterparty_id)	counterparty_id, f.formula_group_id, f.formula_id, f.formula, f.sequence_order
FROM 		
	counterparty_limits cl  
	LEFT JOIN #temp_counterparty tmp_int ON cl.internal_rating_id = tmp_int.risk_rating 
		AND cl.counterparty_id IS NULL
	LEFT JOIN #temp_counterparty tmp_cpty ON cl.counterparty_id = tmp_cpty.counterparty_id	
		AND cl.internal_rating_id IS NULL	
	LEFT JOIN #temp_counterparty tmp_all ON COALESCE(cl.counterparty_id, cl.internal_rating_id,-1) = -1	
	LEFT JOIN
	(
		SELECT fn.formula_group_id, fn.formula_id, fe1.formula, fn.sequence_order
		FROM formula_editor fe 
		INNER JOIN formula_nested fn ON fe.formula_id = fn.formula_group_id
		INNER JOIN formula_editor fe1 ON fe1.formula_id = fn.formula_id
	) f
	ON cl.formula_id = f.formula_group_id	
WHERE 
	cl.formula_id IS NOT NULL		
ORDER BY 
	cl.counterparty_limit_id, counterparty_id, f.formula_group_id, f.sequence_order	

DECLARE @counterparty_limit_id INT
		,@counterparty_id INT
		,@formula_group_id INT
		,@formula_id INT
		,@formula varchar(1000)
		,@sequence_number INT
	
--select * FROM #temp_formula
CREATE TABLE #temp_formula_value (
	as_of_date datetime,
	counterparty_id int,
	formula_id int,
	formula varchar(max) COLLATE DATABASE_DEFAULT,
	sequence_number int,
	formula_value FLOAT,
	counterparty_limit_id INT,
	formula_group_id int
)
---changed c.counterparty_limit_id to c.counterparty_id

DELETE calc_formula_value 
FROM calc_formula_value c 
INNER JOIN #temp_formula f ON c.counterparty_id = f.counterparty_limit_id 
	AND c.prod_date = @as_of_date
	AND c.counterparty_id = f.counterparty_id
	
	
DECLARE @real_formula VARCHAR(MAX)

CREATE TABLE #real_formula_value (formula_value FLOAT,formula_str VARCHAR(5000) COLLATE DATABASE_DEFAULT)

DECLARE cur2 CURSOR FOR
SELECT counterparty_limit_id, counterparty_id, formula_group_id, formula_id, formula, sequence_number 
FROM #temp_formula
OPEN cur2
FETCH NEXT FROM cur2 INTO @counterparty_limit_id, @counterparty_id, @formula_group_id, @formula_id, @formula, @sequence_number
WHILE @@FETCH_STATUS = 0
BEGIN

	--select '1900-01-01',0,0,0,0,@formula,0,0,0,0,@counterparty_id as counterparty_id,0,0,@sequence_number as sequence_number,0,0,0,0,@formula_id  as formula_id,0,0,0,0,0,@as_of_date as as_of_date
EXEC spa_print '@formula_group_id:', @formula_group_id, '; @sequence_number:', @sequence_number, '; @formula:', @formula
EXEC spa_print '---------------------------------'
	SET @real_formula = dbo.FNAFormulaTextContract(@as_of_date, 0, 0, 0, 0, @formula, 0, 0, 0, 0, @counterparty_id, 0, 0, @sequence_number, 0, 0, 0, 0, @formula_group_id, 0, 0, 0, 981, 0, @as_of_date, NULL)
	EXEC spa_print @real_formula

	SET @formula_stmt = 'INSERT INTO #real_formula_value (formula_value,formula_str) SELECT ' + @real_formula +','''+REPLACE(@real_formula,'''','''''')+''''
	exec spa_print @formula_stmt
	
	BEGIN TRY
		EXEC(@formula_stmt)
	END TRY
	BEGIN CATCH
	
		DECLARE @error_msg VARCHAR(MAX)
		SET @error_msg = ERROR_message()
		
		--Handle Divide by Zero error
--		IF @error_num = 8134
--		BEGIN
		INSERT INTO #real_formula_value (formula_value) VALUES (NULL)
--		END
		EXEC spa_print 'Error:', @error_msg
	END CATCH	
	
	INSERT INTO #temp_formula_value(counterparty_limit_id, as_of_date, counterparty_id, formula_id, formula, sequence_number, formula_value, formula_group_id)
	SELECT 
		@counterparty_limit_id, @as_of_date, @counterparty_id, @formula_id, @formula, @sequence_number, formula_value, @formula_group_id
	FROM
		#real_formula_value

	INSERT INTO calc_formula_value
	(
		seq_number
		, prod_date
		, counterparty_id
		, [value]
		, formula_id
		, formula_str
		, create_user
		, create_ts
		, update_user
		, update_ts
		, counterparty_limit_id
	)
	SELECT @sequence_number, @as_of_date, @counterparty_id, formula_value, @formula_group_id, formula_str
		, dbo.fnadbuser(), GETDATE(), dbo.fnadbuser(), GETDATE(), @counterparty_limit_id
	FROM #real_formula_value

	TRUNCATE TABLE #real_formula_value

	FETCH NEXT FROM cur2 INTO @counterparty_limit_id, @counterparty_id, @formula_group_id, @formula_id, @formula, @sequence_number
END
CLOSE cur2
DEALLOCATE cur2

DELETE counterparty_limit_calc_result 
FROM counterparty_limit_calc_result s 
INNER JOIN #temp_formula_value fv ON fv.counterparty_limit_id = s.counterparty_limit_id 
AND fv.as_of_date = s.as_of_date 
AND fv.counterparty_id = s.counterparty_id

EXEC spa_print 'Inserting counterparty_limit_calc_result...'

INSERT INTO counterparty_limit_calc_result(
	as_of_date 
	, counterparty_id 
	, internal_rating 
	, counterparty_limit_id 
	, limit_type  
	, buck_id 
	, purchase_sales 
	, credit_available 
)

SELECT fv.as_of_date, fv.counterparty_id, cnpty.risk_rating, fv.counterparty_limit_id, cl.limit_type, cl.bucket_detail_id, cl.volume_limit_type, fv.formula_value
FROM #temp_formula_value fv INNER JOIN 
	( 
		SELECT Counterparty_limit_id, counterparty_id,formula_group_id, MAX(sequence_number) sequence_number 
		FROM #temp_formula_value 
		GROUP BY counterparty_limit_id,counterparty_id,formula_group_id
	) f_v ON fv.counterparty_limit_id = f_v.counterparty_limit_id 
			AND fv.counterparty_id = f_v.counterparty_id 
			AND fv.formula_group_id = f_v.formula_group_id 
			AND fv.sequence_number = f_v.sequence_number
INNER JOIN 
	#temp_counterparty cnpty ON fv.counterparty_id = cnpty.counterparty_id
INNER JOIN 
	counterparty_limits cl ON cl.counterparty_limit_id = fv.counterparty_limit_id


/*
ALTER TABLE calc_formula_value ADD 	counterparty_limit_id INT


if object_id('dbo.counterparty_limit_calc_result') is not NULL
drop table dbo.counterparty_limit_calc_result
go

CREATE TABLE dbo.counterparty_limit_calc_result(
rowid INT IDENTITY(1,1),
as_of_date DATETIME,
counterparty_limit_id int,
counterparty_id INT,
internal_rating INT,
limit_type INT ,
buck_id INT,
purchase_sales char(1),
credit_available float
)
*/
--SELECT * FROM formula_editor fe
--SELECT * FROM formula_nested fn
