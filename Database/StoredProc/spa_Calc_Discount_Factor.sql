IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_Calc_Discount_Factor]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_Calc_Discount_Factor]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Used ro calculate discount factors
	Parameters:
	@as_of_date  		: Date to run the calculation
	@sub_entity_id 		: Sunsidiary Entity ids
	@strategy_entity_id : Stratege Entity ids
	@book_entity_id 	: Book Entity ids
	@process_id 		: Unique Identifier
	@curve_id  			: Deal Index
	@deal_id			: Deal ids
*/

CREATE PROC [dbo].[spa_Calc_Discount_Factor] 
	@as_of_date VARCHAR(15), 
	@sub_entity_id VARCHAR(MAX) = NULL, 
	@strategy_entity_id VARCHAR(MAX) = NULL, 
	@book_entity_id VARCHAR(MAX) = NULL, 
	@process_id VARCHAR(200), 
	@curve_id INT = NULL, 
	@deal_id VARCHAR(500) = NULL
AS

------START OF TESTING
/*
DECLARE @as_of_date          VARCHAR(15)
DECLARE @sub_entity_id       VARCHAR(100)
DECLARE @strategy_entity_id  VARCHAR(100)
DECLARE @book_entity_id      VARCHAR(100) 
DECLARE @process_id          VARCHAR(100)
DECLARE @curve_id            INT,
        @deal_id             VARCHAR(500)--,@curve_source_value_id int=4500

SET @as_of_date = '2013-01-22'
SET @sub_entity_id = ''
SET @strategy_entity_id = NULL
SET @book_entity_id = NULL
SET @process_id = 'adiha_process.dbo.calcprocess_discount_factor_farrms_admin_20DC37D9_EA98_44C5_ACD5_16E2C344BBEE'
set @deal_id='882'

DROP TABLE adiha_process.dbo.calcprocess_discount_factor_farrms_admin_6EEE17B2_982D_47DC_9E35_131206AC35D8
DROP TABLE #subs
--SELECT * FROM adiha_process.dbo.formula_calc_result_farrms_admin_DBE8B1BB_0447_4F2C_978E_11A9CDDCB45D
--*/
------END OF TESTING
--SELECT @@SPID

SET NOCOUNT ON

DECLARE @continous_compounding  TINYINT,
        @discrete_daily_365     TINYINT,
        @discrete_daily_input   TINYINT,
        @discrete_monthly       TINYINT

DECLARE @derived_curve_table    VARCHAR(128)
DECLARE @user_id                VARCHAR(50)
DECLARE @process_id1            VARCHAR(300)

SET @continous_compounding = 128 
SET @discrete_daily_365 = 126
SET @discrete_daily_input = 127
SET @discrete_monthly = 125
SET @user_id = dbo.FNADBUser()
SET @process_id1 = REPLACE(NEWID(), '-', '_')
SET @derived_curve_table = dbo.FNAProcessTableName('der_price_curve', @user_id, @process_id1)

DECLARE @Sql_Select  VARCHAR(5000)
DECLARE @Sql_From    VARCHAR(5000)
DECLARE @Sql_Where   VARCHAR(5000)
DECLARE @Sql_GpBy    VARCHAR(5000)
DECLARE @Sql         VARCHAR(5000)
DECLARE @TableName   VARCHAR(200)
DECLARE @sqlstmt     VARCHAR(5000)

IF OBJECT_ID(@derived_curve_table) IS NOT NULL
EXEC('DROP TABLE ' + @derived_curve_table)

--SET @sqlstmt ='CREATE TABLE ' + @derived_curve_table + '
--               (
--               	source_curve_def_id  INT,
--               	as_of_date           DATETIME,
--               	maturity_date        DATETIME,
--               	formula_value        FLOAT,
--               	formula_id           INT,
--               	formula_str          VARCHAR(500)
--               )'

--EXEC (@sqlstmt)

SELECT fas_subsidiary_id,
       ISNULL(discount_curve_id, default_discount_curve_id) discount_curve_id,
       CASE 
            WHEN (spcd.formula_id IS NOT NULL) THEN 'y'
            ELSE 'n'
       END derived_curve,
       disc_type_value_id,
       CASE WHEN days_in_year = 0 THEN 1 ELSE days_in_year END days_in_year
       INTO #subs
FROM   fas_subsidiaries
FULL OUTER JOIN (SELECT MAX(source_curve_def_id) default_discount_curve_id
                FROM   source_price_curve_def
                WHERE  source_curve_type_value_id = 577
            ) df ON  1 = 1
LEFT OUTER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = ISNULL(discount_curve_id, default_discount_curve_id) 

DECLARE @der_curve_id           INT
DECLARE @min_term_start         DATETIME
DECLARE @max_term_start         DATETIME
DECLARE @curve_as_of_date_from  DATETIME
DECLARE @curve_source_value_id  INT

SET @curve_source_value_id = 4500
SET @min_term_start = dbo.FNAGetContractMonth(DATEADD(mm, 1, @as_of_date))
SET @max_term_start = DATEADD(yy, 50, @min_term_start)

SET @sqlstmt = ' SELECT DISTINCT spc.source_curve_def_id,spc.as_of_date,spc.maturity_date, spc.curve_value formula_value,spcd.formula_id --,NULL formula_str
				INTO ' + @derived_curve_table + '
				FROM #subs s 
				INNER JOIN source_price_curve spc ON s.discount_curve_id=spc.source_curve_def_id AND spc.as_of_date ='''+convert(VARCHAR(10), @as_of_date,120) + '''
					AND spc.maturity_date BETWEEN ''' + CONVERT(VARCHAR(10) ,@min_term_start,120) + ''' AND ''' + CONVERT(VARCHAR(10), @max_term_start, 120) + '''
					AND spc.curve_source_value_id='+cast(@curve_source_value_id AS VARCHAR)+'
				INNER JOIN source_price_curve_def spcd ON spc.source_curve_def_id=spcd.source_curve_def_id
				WHERE  derived_curve = ''y'''
EXEC spa_print @sqlstmt
EXEC(@sqlstmt)

/*
DECLARE formula_cursor_derc CURSOR  
FOR
    SELECT DISTINCT discount_curve_id
    FROM   #subs
    WHERE  derived_curve = 'y'
OPEN formula_cursor_derc
FETCH NEXT FROM formula_cursor_derc
INTO @der_curve_id
WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC spa_derive_curve_value @der_curve_id,
         @as_of_date,
         @as_of_date,
         @curve_source_value_id,
         @derived_curve_table,
         @min_term_start,
         @max_term_start
    
    FETCH NEXT FROM formula_cursor_derc
    INTO @der_curve_id
END
CLOSE formula_cursor_derc
DEALLOCATE  formula_cursor_derc
 */
--DROP TABLE adiha_process.dbo.der_price_curve_sa_8B49EC23_62D2_44B8_9C94_6C86448B5C63

--=====XX Changes =============
-- 0 means it is interest rate, 1 means the vale is already discount factor, 2 discount factor provided at deal level
DECLARE @is_discount_curve_a_factor INT
SELECT @is_discount_curve_a_factor = var_value
FROM adiha_default_codes_values
WHERE instance_no = '1'
    AND default_code_id = 14
    AND seq_no = 1

--=====XX Changes =============

SET @TableName = @process_id
SET @Sql_Select = 'CREATE TABLE ' + @TableName + '
                   (
                   	[as_of_date]                [DATETIME] NOT NULL,
                   	[term_start]                [DATETIME] NOT NULL,
                   	[term_end]                  [DATETIME] NULL,
                   	[contract_expiration_date]  [DATETIME] NULL,
                   	[source_system_id]          [INT] NULL,
                   	[fas_subsidiary_id]         [INT] NULL,
                   	[discount_factor]           [FLOAT] NULL,
                   	[source_deal_header_id]     [INT] NULL
                   ) ON [PRIMARY] '

EXEC( @Sql_Select)

EXEC('CREATE INDEX INDX_AAAAAAA_' + @process_id1 + ' ON ' + @derived_curve_table + '(source_curve_def_id, formula_value)')

IF @is_discount_curve_a_factor IN (0, 1)
BEGIN
	SET @Sql_Select = 'INSERT INTO ' + @TableName + ' 
					SELECT  ''' + @as_of_date + ''' as as_of_date, 
					ISNULL(dct.maturity_date, spc.maturity_date) maturity_date, NULL term_end, 
					NULL contract_expiration_date, NULL source_system_id, fasb.fas_subsidiary_id fas_subsidiary_id, 
					ISNULL(CASE	WHEN (' + CAST(@is_discount_curve_a_factor AS VARCHAR) + ' = 1 ) THEN COALESCE(dct.formula_value, spc.curve_value, 0)
					ELSE
						CASE WHEN(fasb.disc_type_value_id = ' + CAST(@continous_compounding AS VARCHAR) + ') THEN
							power(2.71828, (-1 * COALESCE(dct.formula_value, spc.curve_value, 0) * DATEDIFF(day,''' + @as_of_date + ''', ISNULL(dct.maturity_date, spc.maturity_date)) / NULLIF(fasb.days_in_year,0)))
						WHEN(fasb.disc_type_value_id = ' + CAST(@discrete_monthly AS VARCHAR)+ ') THEN
							POWER( 1 + (COALESCE(dct.formula_value, spc.curve_value, 0) / 12), (-1 * DATEDIFF(month, ''' + @as_of_date + ''', ISNULL(dct.maturity_date, spc.maturity_date))))
						WHEN(fasb.disc_type_value_id = ' + CAST(@discrete_daily_365 AS VARCHAR) + ') THEN
							POWER(1 + (coalesce(dct.formula_value, spc.curve_value, 0) / 365), (-1 * DATEDIFF(day,''' + @as_of_date + ''', ISNULL(dct.maturity_date, spc.maturity_date))))
						ELSE
							POWER(1 + (COALESCE(dct.formula_value, spc.curve_value, 0) / NULLIF(fasb.days_in_year,0)), (-1 * DATEDIFF(day,''' + @as_of_date + ''', ISNULL(dct.maturity_date, spc.maturity_date))))
						END 
					END, 1) AS discount_factor, NULL source_deal_header_id
			FROM #subs fasb 
			LEFT OUTER JOIN ' + @derived_curve_table + ' dct ON fasb.discount_curve_id = dct.source_curve_def_id 
				AND fasb.derived_curve = ''y'' AND dct.formula_value IS NOT NULL 
			LEFT OUTER JOIN source_price_curve spc ON fasb.discount_curve_id = spc.source_curve_def_id 
				AND fasb.derived_curve = ''n'' AND spc.assessment_curve_type_value_id = 77 AND spc.as_of_date = ''' + @as_of_date + '''
				AND spc.curve_source_value_id = ' + CAST(@curve_source_value_id AS VARCHAR) + '
			WHERE ISNULL(dct.maturity_date, spc.maturity_date) IS NOT NULL AND fasb.discount_curve_id IS NOT NULL'
END
ELSE
BEGIN
	SET @Sql_Select = ' INSERT INTO ' + @TableName + ' 
						SELECT ''' + @as_of_date + ''' AS as_of_date,
							   maturity term_start,
							   NULL term_end,
							   NULL contract_expiration_date,
							   NULL source_system_id,
							   NULL fas_subsidiary_id,
							   discount_factor,
							   source_deal_header_id
						FROM ' + dbo.FNAGetProcessTableName(@as_of_date, 'source_deal_discount_factor') + '
						WHERE as_of_date = ''' + @as_of_date + '''' +
						CASE WHEN (@deal_id IS NULL) THEN ' ' ELSE ' AND source_deal_header_id IN (' + @deal_id + ')'END 

END
EXEC spa_print @Sql_Select
EXEC (@Sql_Select)

IF @is_discount_curve_a_factor IN (0, 1)
    SET @Sql_Select = 'CREATE INDEX [ix_discount_factor] ON ' + @TableName + ' (fas_subsidiary_id, term_start)'
ELSE--2
    SET @Sql_Select = 'CREATE INDEX [ix_discount_factor] ON ' + @TableName + ' (source_deal_header_id, term_start)'

EXEC (@Sql_Select)


-- Drop process table after scope is completed, when debug mode is off.
DECLARE @debug_mode VARCHAR(128) = REPLACE(CONVERT(VARCHAR(128), CONTEXT_INFO()), 0x0, '')

IF ISNULL(@debug_mode, '') <> 'DEBUG_MODE_ON'
BEGIN
	EXEC dbo.spa_clear_all_temp_table NULL, @process_id1
END

GO