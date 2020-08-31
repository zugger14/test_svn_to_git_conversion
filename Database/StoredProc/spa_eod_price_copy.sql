IF OBJECT_ID('[dbo].[spa_eod_price_copy]') IS NOT NULL
BEGIN
    DROP PROCEDURE [dbo].[spa_eod_price_copy]
END

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- ===============================================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2011-11-17
-- Description: SP to run at the End of the day process 
-- ===============================================================================================================================

CREATE PROC [dbo].[spa_eod_price_copy]
AS

/*** Enter input here *****/
DECLARE @block_define_id  INT,
        @as_of_date       DATETIME,
        @m_curve_id       INT,
        @q_curve_id       INT,
        @y_curve_id       INT

SET @block_define_id = 291997
SET @as_of_date = CONVERT(VARCHAR(10), GETDATE(), 120)
SET @m_curve_id = 162
SET @q_curve_id = 171
SET @y_curve_id = 180

/*** End of input here *****/

IF OBJECT_ID('tempdb..#temp_block_define') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define
END

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
BEGIN
    DROP TABLE #temp
END

--SELECT * FROM static_data_value WHERE value_id = 291899

DECLARE @block_type  INT 
DECLARE @curve_id    INT
SET @curve_id = 76
SET @block_type = 12000 -- always need this check

CREATE TABLE #temp_block_define
(
	term_date  DATETIME,
	[Hour]     INT,
	hr_mult    FLOAT
)

INSERT INTO #temp_block_define
SELECT unpvt.term_date,
       CAST(REPLACE(unpvt.[hour], 'hr', '') AS INT) [Hour],
       unpvt.hr_mult
FROM   ( SELECT hb.term_date,
                hb.block_type,
                hb.block_define_id,
                hr1,
                hr2,
                hr3,
                hr4,
                hr5,
                hr6,
                hr7,
                hr8,
                hr9,
                hr10,
                hr11,
                hr12,
                hr13,
                hr14,
                hr15,
                hr16,
                hr17,
                hr18,
                hr19,
                hr20,
                hr21,
                hr22,
                hr23,
                hr24
         FROM   hour_block_term hb
         WHERE  block_type = @block_type
                AND block_define_id = @block_define_id
       )p
       UNPIVOT(
           hr_mult FOR [hour] IN (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, 
                                 hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, 
                                 hr18, hr19, hr20, hr21, hr22, hr23, hr24)
       ) AS unpvt
WHERE  unpvt.[hr_mult] <> 0
      

	IF @y_curve_id IS NOT NULL
	BEGIN
		SELECT @y_curve_id source_curve_def_id,
	           spc.as_of_date,
	           CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-01-01' maturity,
	           AVG(spc.curve_value) curve_value
	           INTO #temp
	    FROM   source_price_curve spc
	           INNER JOIN #temp_block_define td
	                ON  CAST(
	                        CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
	                        + ':00:00.000' AS DATETIME
	                    ) = spc.maturity_date
	    WHERE  spc.source_curve_def_id = @curve_id
	           AND spc.as_of_date = @as_of_date
	    GROUP BY
	           spc.source_curve_def_id,
	           spc.as_of_date,
	           CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-01-01'
	END
	     
        
     IF @q_curve_id  IS NOT NULL
     BEGIN
		INSERT INTO #temp
		SELECT @q_curve_id source_curve_def_id,
		       spc.as_of_date,
		       CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' +
		       CAST(
		           CASE DATEPART(QQ, spc.maturity_date)
		                WHEN 1 THEN 1
		                WHEN 2 THEN 4
		                WHEN 3 THEN 7
		                WHEN 4 THEN 10
		           END AS VARCHAR
		       ) + '-01' maturity,
		       AVG(spc.curve_value) curve_value
		FROM   source_price_curve spc
		       INNER JOIN #temp_block_define td
		            ON  CAST(
		                    CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
		                    + ':00:00.000' AS DATETIME
		                ) = spc.maturity_date
		WHERE  spc.source_curve_def_id = @curve_id
		       AND spc.as_of_date = @as_of_date
		GROUP BY
		       spc.source_curve_def_id,
		       spc.as_of_date,
		       CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' +
		       CAST(
		           CASE DATEPART(QQ, spc.maturity_date)
		                WHEN 1 THEN 1
		                WHEN 2 THEN 4
		                WHEN 3 THEN 7
		                WHEN 4 THEN 10
		           END AS VARCHAR
		       ) + '-01'	
     END  
      

    IF @m_curve_id  IS NOT NULL
    BEGIN
		INSERT INTO #temp
		SELECT @m_curve_id source_curve_def_id,
		       spc.as_of_date,
		       CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(mm, spc.maturity_date) AS VARCHAR) 
		       + '-01' maturity,
		       AVG(spc.curve_value) curve_value
		FROM   source_price_curve spc
		       INNER JOIN #temp_block_define td
		            ON  CAST(
		                    CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
		                    + ':00:00.000' AS DATETIME
		                ) = spc.maturity_date
		WHERE  spc.source_curve_def_id = @curve_id
		       AND spc.as_of_date = @as_of_date
		GROUP BY
		       spc.source_curve_def_id,
		       spc.as_of_date,
		       CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(mm, spc.maturity_date) AS VARCHAR) 
		       + '-01'
    END
      

	DELETE 
	FROM   source_price_curve 
	       FROM source_price_curve spc
	       INNER JOIN #temp f
	            ON  spc.source_curve_def_id = f.source_curve_def_id
	            AND spc.as_of_date = f.as_of_date
	            AND spc.curve_source_value_id = 4500
	
	INSERT INTO source_price_curve
	  (
	    source_curve_def_id,
	    as_of_date,
	    Assessment_curve_type_value_id,
	    curve_source_value_id,
	    maturity_date,
	    curve_value,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    bid_value,
	    ask_value,
	    is_dst
	  )
	SELECT f.source_curve_def_id,
	       f.as_of_date,
	       77,
	       4500,
	       f.maturity,
	       f.curve_value,
	       dbo.FNADBUser(),
	       GETDATE(),
	       dbo.FNADBUser(),
	       GETDATE(),
	       f.curve_value,
	       f.curve_value,
	       0
	FROM   #temp f
	
IF OBJECT_ID('tempdb..#temp_block_define') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define
END

IF OBJECT_ID('tempdb..#temp') IS NOT NULL
BEGIN
    DROP TABLE #temp
END



/*** Enter input here *****/
DECLARE @block_define_id1  INT,
        @as_of_date1       DATETIME,
        @m_curve_id1       INT,
        @q_curve_id1       INT,
        @y_curve_id1       INT

SET @block_define_id1 = 291996
SET @as_of_date1 = CONVERT(VARCHAR(10), GETDATE(), 120)

SET @m_curve_id1 = 167
SET @q_curve_id1 = 174
SET @y_curve_id1 = 186

/*** End of input here *****/
IF OBJECT_ID('tempdb..#temp_block_define1') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define1
END

IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
    DROP TABLE #temp1
END
 --select * from static_data_value where value_id = 291899


DECLARE @block_type1  INT 
DECLARE @curve_id1    INT
SET @curve_id1 = 76
SET @block_type1 = 12000  -- always need this --check

CREATE TABLE #temp_block_define1
(
	term_date  DATETIME,
	[Hour]     INT,
	hr_mult    FLOAT
)

INSERT INTO #temp_block_define1
SELECT unpvt.term_date,
       CAST(REPLACE(unpvt.[hour], 'hr', '') AS INT) [Hour],
       unpvt.hr_mult
FROM   ( SELECT hb.term_date,
                hb.block_type,
                hb.block_define_id,
                hr1,
                hr2,
                hr3,
                hr4,
                hr5,
                hr6,
                hr7,
                hr8,
                hr9,
                hr10,
                hr11,
                hr12,
                hr13,
                hr14,
                hr15,
                hr16,
                hr17,
                hr18,
                hr19,
                hr20,
                hr21,
                hr22,
                hr23,
                hr24
         FROM   hour_block_term hb
         WHERE  block_type = @block_type
                AND block_define_id = @block_define_id1
       )p
       UNPIVOT(
           hr_mult FOR [hour] IN (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, 
                                 hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, 
                                 hr18, hr19, hr20, hr21, hr22, hr23, hr24)
       ) AS unpvt
WHERE  unpvt.[hr_mult] <> 0
      

	IF @y_curve_id1 IS NOT NULL
	BEGIN
		SELECT @y_curve_id1 source_curve_def_id,
		       spc.as_of_date,
		       CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-01-01' maturity,
		       AVG(spc.curve_value) curve_value
		       INTO #temp1
		FROM   source_price_curve spc
		       INNER JOIN #temp_block_define1 td
		            ON  CAST(
		                    CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
		                    + ':00:00.000' AS DATETIME
		                ) = spc.maturity_date
		WHERE  spc.source_curve_def_id = @curve_id
		       AND spc.as_of_date = @as_of_date1
		GROUP BY
		       spc.source_curve_def_id,
		       spc.as_of_date,
		       CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-01-01'	
	END
       
        
     IF @q_curve_id1 IS NOT NULL
     BEGIN
		INSERT INTO #temp1
         SELECT @q_curve_id1 source_curve_def_id,
                spc.as_of_date,
                CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' +
                CAST(
                    CASE DATEPART(QQ, spc.maturity_date)
                         WHEN 1 THEN 1
                         WHEN 2 THEN 4
                         WHEN 3 THEN 7
                         WHEN 4 THEN 10
                    END AS VARCHAR
                ) + '-01' maturity,
                AVG(spc.curve_value) curve_value
         FROM   source_price_curve spc
                INNER JOIN #temp_block_define1 td
                     ON  CAST(
                             CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + 
                             CAST(td.[Hour] -1 AS VARCHAR) + ':00:00.000' AS 
                             DATETIME
                         ) = spc.maturity_date
         WHERE  spc.source_curve_def_id = @curve_id
                AND spc.as_of_date = @as_of_date1
         GROUP BY
                spc.source_curve_def_id,
                spc.as_of_date,
                CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' +
                CAST(
                    CASE DATEPART(QQ, spc.maturity_date)
                         WHEN 1 THEN 1
                         WHEN 2 THEN 4
                         WHEN 3 THEN 7
                         WHEN 4 THEN 10
                    END AS VARCHAR
                ) + '-01'
     END
         

    IF @m_curve_id1 IS NOT NULL
    BEGIN
		INSERT INTO #temp1
        SELECT @m_curve_id1 source_curve_def_id,
               spc.as_of_date,
               CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(mm, spc.maturity_date) AS VARCHAR) 
               + '-01' maturity,
               AVG(spc.curve_value) curve_value
        FROM   source_price_curve spc
               INNER JOIN #temp_block_define1 td
                    ON  CAST(
                            CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
                            + ':00:00.000' AS DATETIME
                        ) = spc.maturity_date
        WHERE  spc.source_curve_def_id = @curve_id
               AND spc.as_of_date = @as_of_date1
        GROUP BY
               spc.source_curve_def_id,
               spc.as_of_date,
               CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(mm, spc.maturity_date) AS VARCHAR) 
               + '-01'	
    END
        

	DELETE 
	FROM   source_price_curve 
	       FROM source_price_curve spc
	       INNER JOIN #temp1 f
	            ON  spc.source_curve_def_id = f.source_curve_def_id
	            AND spc.as_of_date = f.as_of_date
	            AND spc.curve_source_value_id = 4500
	
	INSERT INTO source_price_curve
	  (
	    source_curve_def_id,
	    as_of_date,
	    Assessment_curve_type_value_id,
	    curve_source_value_id,
	    maturity_date,
	    curve_value,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    bid_value,
	    ask_value,
	    is_dst
	  )
	SELECT f.source_curve_def_id,
	       f.as_of_date,
	       77,
	       4500,
	       f.maturity,
	       f.curve_value,
	       dbo.FNADBUser(),
	       GETDATE(),
	       dbo.FNADBUser(),
	       GETDATE(),
	       f.curve_value,
	       f.curve_value,
	       0
	FROM   #temp1 f
	
IF OBJECT_ID('tempdb..#temp_block_define1') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define1
END

IF OBJECT_ID('tempdb..#temp1') IS NOT NULL
BEGIN
    DROP TABLE #temp1
END


/*** Enter input here *****/
DECLARE @block_define_id2  INT,
        @as_of_date2       DATETIME,
        @m_curve_id2       INT,
        @q_curve_id2       INT,
        @y_curve_id2        INT

SET @block_define_id2 = 291899
SET @as_of_date2 = CONVERT(VARCHAR(10), GETDATE(), 120)

SET @m_curve_id2 = 188
SET @q_curve_id2 = 192
SET @y_curve_id2 = 182

/*** End of input here *****/

IF OBJECT_ID('tempdb..#temp_block_define2') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define2
END

IF OBJECT_ID('tempdb..#temp2') IS NOT NULL
BEGIN
    DROP TABLE #temp2
END
 --select * from static_data_value where value_id = 291899


DECLARE @block_type2  INT 
DECLARE @curve_id2    INT
SET @curve_id2 = 76
SET @block_type2 = 12000  -- always need this --check

CREATE TABLE #temp_block_define2 (
	term_date  DATETIME,
	[Hour]     INT,
	hr_mult    FLOAT
)

INSERT INTO #temp_block_define2
SELECT unpvt.term_date,
       CAST(REPLACE(unpvt.[hour], 'hr', '') AS INT) [Hour],
       unpvt.hr_mult
FROM   ( SELECT hb.term_date,
                hb.block_type,
                hb.block_define_id,
                hr1,
                hr2,
                hr3,
                hr4,
                hr5,
                hr6,
                hr7,
                hr8,
                hr9,
                hr10,
                hr11,
                hr12,
                hr13,
                hr14,
                hr15,
                hr16,
                hr17,
                hr18,
                hr19,
                hr20,
                hr21,
                hr22,
                hr23,
                hr24
         FROM   hour_block_term hb
         WHERE  block_type = @block_type2
                AND block_define_id = @block_define_id2
       )p
       UNPIVOT(
           hr_mult FOR [hour] IN (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, 
                                 hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, 
                                 hr18, hr19, hr20, hr21, hr22, hr23, hr24)
       ) AS unpvt
WHERE  unpvt.[hr_mult] <> 0
      

	IF @y_curve_id2 IS NOT NULL
	BEGIN
		SELECT @y_curve_id2 source_curve_def_id,
	           spc.as_of_date,
	           CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-01-01' maturity,
	           AVG(spc.curve_value) curve_value
	           INTO #temp2
	    FROM   source_price_curve spc
	           INNER JOIN #temp_block_define2 td
	                ON  CAST(
	                        CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
	                        + ':00:00.000' AS DATETIME
	                    ) = spc.maturity_date
	    WHERE  spc.source_curve_def_id = @curve_id2
	           AND spc.as_of_date = @as_of_date2
	    GROUP BY
	           spc.source_curve_def_id,
	           spc.as_of_date,
	           CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-01-01' 	
	END
	    
        
     IF @q_curve_id2 IS NOT NULL
     BEGIN
		INSERT INTO #temp2
         SELECT @q_curve_id2 source_curve_def_id,
                spc.as_of_date,
                CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' +
                CAST(
                    CASE DATEPART(QQ, spc.maturity_date)
                         WHEN 1 THEN 1
                         WHEN 2 THEN 4
                         WHEN 3 THEN 7
                         WHEN 4 THEN 10
                    END AS VARCHAR
                ) + '-01' maturity,
                AVG(spc.curve_value) curve_value
         FROM   source_price_curve spc
                INNER JOIN #temp_block_define2 td
                     ON  CAST(
                             CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + 
                             CAST(td.[Hour] -1 AS VARCHAR) + ':00:00.000' AS 
                             DATETIME
                         ) = spc.maturity_date
         WHERE  spc.source_curve_def_id = @curve_id2
                AND spc.as_of_date = @as_of_date2
         GROUP BY
                spc.source_curve_def_id,
                spc.as_of_date,
                CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' +
                CAST(
                    CASE DATEPART(QQ, spc.maturity_date)
                         WHEN 1 THEN 1
                         WHEN 2 THEN 4
                         WHEN 3 THEN 7
                         WHEN 4 THEN 10
                    END AS VARCHAR
                ) + '-01'	
     END
         
    IF @m_curve_id2 IS NOT NULL
    BEGIN
		INSERT INTO #temp2
		SELECT @m_curve_id2 source_curve_def_id,
		       spc.as_of_date,
		       CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(mm, spc.maturity_date) AS VARCHAR) 
		       + '-01' maturity,
		       AVG(spc.curve_value) curve_value
		FROM   source_price_curve spc
		       INNER JOIN #temp_block_define2 td
		            ON  CAST(
		                    CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
		                    + ':00:00.000' AS DATETIME
		                ) = spc.maturity_date
		WHERE  spc.source_curve_def_id = @curve_id2
		       AND spc.as_of_date = @as_of_date2
		GROUP BY
		       spc.source_curve_def_id,
		       spc.as_of_date,
		       CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(mm, spc.maturity_date) AS VARCHAR) 
		       + '-01'
    END
      

	DELETE 
	FROM   source_price_curve 
	       FROM source_price_curve spc
	       INNER JOIN #temp2 f
	            ON  spc.source_curve_def_id = f.source_curve_def_id
	            AND spc.as_of_date = f.as_of_date
	            AND spc.curve_source_value_id = 4500
	
	INSERT INTO source_price_curve
	  (
	    source_curve_def_id,
	    as_of_date,
	    Assessment_curve_type_value_id,
	    curve_source_value_id,
	    maturity_date,
	    curve_value,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    bid_value,
	    ask_value,
	    is_dst
	  )
	SELECT f.source_curve_def_id,
	       f.as_of_date,
	       77,
	       4500,
	       f.maturity,
	       f.curve_value,
	       dbo.FNADBUser(),
	       GETDATE(),
	       dbo.FNADBUser(),
	       GETDATE(),
	       f.curve_value,
	       f.curve_value,
	       0
	FROM   #temp2 f
	
IF OBJECT_ID('tempdb..#temp_block_define2') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define2
END

IF OBJECT_ID('tempdb..#temp2') IS NOT NULL
BEGIN
    DROP TABLE #temp2
END


/*** Enter input here *****/
DECLARE @block_define_id3  INT,
        @as_of_date3       DATETIME,
        @m_curve_id3       INT,
        @q_curve_id3       INT,
        @y_curve_id3       INT

SET @block_define_id3 = 291995
SET @as_of_date3 = CONVERT(VARCHAR(10), GETDATE(), 120)

SET @m_curve_id3 = 190
SET @q_curve_id3 = 185
SET @y_curve_id3 = 172

/*** End of input here *****/

IF OBJECT_ID('tempdb..#temp_block_define3') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define3
END

IF OBJECT_ID('tempdb..#temp3') IS NOT NULL
BEGIN
    DROP TABLE #temp3
END
--select * from static_data_value where value_id = 291899


DECLARE @block_type3  INT 
DECLARE @curve_id3    INT
SET @curve_id3 = 76
SET @block_type3 = 12000  -- always need this --check

CREATE TABLE #temp_block_define3
(
	term_date  DATETIME,
	[Hour]     INT,
	hr_mult    FLOAT
)

INSERT INTO #temp_block_define3
SELECT unpvt.term_date,
       CAST(REPLACE(unpvt.[hour], 'hr', '') AS INT) [Hour],
       unpvt.hr_mult
FROM   ( SELECT hb.term_date,
                hb.block_type,
                hb.block_define_id,
                hr1,
                hr2,
                hr3,
                hr4,
                hr5,
                hr6,
                hr7,
                hr8,
                hr9,
                hr10,
                hr11,
                hr12,
                hr13,
                hr14,
                hr15,
                hr16,
                hr17,
                hr18,
                hr19,
                hr20,
                hr21,
                hr22,
                hr23,
                hr24
         FROM   hour_block_term hb
         WHERE  block_type = @block_type3
                AND block_define_id = @block_define_id3
       )p
       UNPIVOT(
           hr_mult FOR [hour] IN (hr1, hr2, hr3, hr4, hr5, hr6, hr7, hr8, hr9, 
                                 hr10, hr11, hr12, hr13, hr14, hr15, hr16, hr17, 
                                 hr18, hr19, hr20, hr21, hr22, hr23, hr24)
       ) AS unpvt
WHERE  unpvt.[hr_mult] <> 0
      

	IF @y_curve_id3 IS NOT NULL
	BEGIN
		SELECT @y_curve_id3 source_curve_def_id,
	           spc.as_of_date,
	           CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-01-01' maturity,
	           AVG(spc.curve_value) curve_value
	           INTO #temp3
	    FROM   source_price_curve spc
	           INNER JOIN #temp_block_define3 td
	                ON  CAST(
	                        CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
	                        + ':00:00.000' AS DATETIME
	                    ) = spc.maturity_date
	    WHERE  spc.source_curve_def_id = @curve_id3
	           AND spc.as_of_date = @as_of_date3
	    GROUP BY
	           spc.source_curve_def_id,
	           spc.as_of_date,
	           CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-01-01' 	
	END
	    
        
     IF @q_curve_id3 IS NOT NULL
     BEGIN
         INSERT INTO #temp3
         SELECT @q_curve_id3 source_curve_def_id,
                spc.as_of_date,
                CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' +
                CAST(
                    CASE DATEPART(QQ, spc.maturity_date)
                         WHEN 1 THEN 1
                         WHEN 2 THEN 4
                         WHEN 3 THEN 7
                         WHEN 4 THEN 10
                    END AS VARCHAR
                ) + '-01' maturity,
                AVG(spc.curve_value) curve_value
         FROM   source_price_curve spc
                INNER JOIN #temp_block_define3 td
                     ON  CAST(
                             CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + 
                             CAST(td.[Hour] -1 AS VARCHAR)
                             + ':00:00.000' AS DATETIME
                         ) = spc.maturity_date
         WHERE  spc.source_curve_def_id = @curve_id3
                AND spc.as_of_date = @as_of_date3
         GROUP BY
                spc.source_curve_def_id,
                spc.as_of_date,
                CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' +
                CAST(
                    CASE DATEPART(QQ, spc.maturity_date)
                         WHEN 1 THEN 1
                         WHEN 2 THEN 4
                         WHEN 3 THEN 7
                         WHEN 4 THEN 10
                    END AS VARCHAR
                ) + '-01'
     END
      

    IF @m_curve_id3 IS NOT NULL
    BEGIN
        INSERT INTO #temp3
        SELECT @m_curve_id3 source_curve_def_id,
               spc.as_of_date,
               CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(mm, spc.maturity_date) AS VARCHAR) 
               + '-01' maturity,
               AVG(spc.curve_value) curve_value
        FROM   source_price_curve spc
               INNER JOIN #temp_block_define3 td
                    ON  CAST(
                            CONVERT(VARCHAR(10), td.term_date, 120) + ' ' + CAST(td.[Hour] -1 AS VARCHAR)
                            + ':00:00.000' AS DATETIME
                        ) = spc.maturity_date
        WHERE  spc.source_curve_def_id = @curve_id3
               AND spc.as_of_date = @as_of_date3
        GROUP BY
               spc.source_curve_def_id,
               spc.as_of_date,
               CAST(YEAR(spc.maturity_date) AS VARCHAR) + '-' + CAST(DATEPART(mm, spc.maturity_date) AS VARCHAR) 
               + '-01'
    END
      
	DELETE 
	FROM   source_price_curve 
	       FROM source_price_curve spc
	       INNER JOIN #temp3 f
	            ON  spc.source_curve_def_id = f.source_curve_def_id
	            AND spc.as_of_date = f.as_of_date
	            AND spc.curve_source_value_id = 4500
	
	INSERT INTO source_price_curve
	  (
	    source_curve_def_id,
	    as_of_date,
	    Assessment_curve_type_value_id,
	    curve_source_value_id,
	    maturity_date,
	    curve_value,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    bid_value,
	    ask_value,
	    is_dst
	  )
	SELECT f.source_curve_def_id,
	       f.as_of_date,
	       77,
	       4500,
	       f.maturity,
	       f.curve_value,
	       dbo.FNADBUser(),
	       GETDATE(),
	       dbo.FNADBUser(),
	       GETDATE(),
	       f.curve_value,
	       f.curve_value,
	       0
	FROM   #temp3 f
	
IF OBJECT_ID('tempdb..#temp_block_define3') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define3
END

IF OBJECT_ID('tempdb..#temp3') IS NOT NULL
BEGIN
    DROP TABLE #temp3
END 	

------Peak
------291997   62.23213214	43.70203665
------162
------171
------180
-----select * from source_price_curve_def where source_curve_def_id in (166,169,23,162,167) order by source_curve_def_id 
---select * from source_price_curve where source_curve_def_id in (166,169) and as_of_date = '2011-9-26'

------Peak
------291997   62.23213214	43.70203665


------162
------171
------180
-----select * from source_price_curve_def where source_curve_def_id in (166,169,23,162,167) order by source_curve_def_id 
---select * from source_price_curve where source_curve_def_id in (166,169) and as_of_date = '2011-9-26'

EXEC spa_print 'APX 1 Start'

IF OBJECT_ID('tempdb..#temp_block_define4') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define4
END

IF OBJECT_ID('tempdb..#curves') IS NOT NULL
BEGIN
    DROP TABLE #curves
END 

--DECLARE @block_type INT,@block_define_id INT,@curve_id int,@as_of_date DATETIME,
DECLARE @term_start DATETIME, @term_end DATETIME,@forware_curve_id INT
DECLARE @onpeak_curve_id INT, @offpeak_curve_id INT, @maturity_to DATETIME
DECLARE @offpeak_forward_curve_id INT, @onpeak_forward_curve_id INT 
SET @block_type=12000 -- always need this --check
SET @curve_id=23
SET @onpeak_curve_id  = 166
SET @offpeak_curve_id  =169

SET @offpeak_forward_curve_id =167
SET @onpeak_forward_curve_id = 162


SET @as_of_date=CONVERT(VARCHAR(10),getdate(),120)

SET @term_start = CONVERT(varchar(8), @as_of_date, 120) + '01'
SET @term_end = dateadd(MONTH,1,cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME))-1
SET @maturity_to = DATEADD(dd, 1, @as_of_date)


	
CREATE TABLE #temp_block_define4(term_date DATETIME,[Hour] INT,hr_mult FLOAT)

IF @maturity_to <= @term_end
BEGIN
	SET @forware_curve_id = @offpeak_forward_curve_id -- 217 OffPeak 218 OnPeak
	Select @block_define_id = block_define_id from source_price_curve_def where source_curve_def_id = @offpeak_curve_id

--OFFPEAK
	INSERT INTO #temp_block_define4 -----select * from #temp_block_define4 where term_date between '2011-9-1' and '2011-9-30'
	SELECT unpvt.term_date,CAST(REPLACE(unpvt.[hour],'hr','') AS INT) [Hour],unpvt.hr_mult FROM 
	(SELECT
	hb.term_date,
	hb.block_type,
	hb.block_define_id,
	hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
	FROM
	hour_block_term hb
	WHERE block_type=@block_type
	AND block_define_id=@block_define_id
	)p
	UNPIVOT
	(hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
	) AS unpvt 
	WHERE
	unpvt.[hr_mult]<>0



	
	SELECT 
	@offpeak_curve_id source_curve_def_id,
	@as_of_date as_of_date,
	@term_start maturity_date,
	(SUM(spc1.curve_value)+MAX(spc2.curve_value)*MAX(td1.remaining_hour))/MAX(td1.total_hour) curve_value
	
	INTO #curves
	FROM
	source_price_curve spc
	INNER JOIN #temp_block_define4 td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME) = spc.maturity_date
	AND spc.source_curve_def_id=@curve_id 
	--AND spc.as_of_date=td.term_date 
	AND spc.maturity_date BETWEEN @term_start AND @term_end+ ' 23:00:00.000'
	AND YEAR(maturity_date) = YEAR(@as_of_date)
	AND MONTH(maturity_date) = MONTH(@as_of_date)
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve a WHERE a.source_curve_def_id=spc.source_curve_def_id
	AND a.as_of_date=spc.as_of_date
	AND a.maturity_date=spc.maturity_date
	AND a.maturity_date<=@maturity_to+ ' 23:00:00.000') spc1
	OUTER APPLY(SELECT SUM(b.hr_mult) total_hour,SUM(CASE WHEN b.term_date>@maturity_to+ ' 23:00:00.000' THEN 1 ELSE 0 END) remaining_hour FROM #temp_block_define4 b WHERE
	YEAR(b.term_date) = YEAR(@as_of_date)
	AND MONTH(b.term_date) = MONTH(@as_of_date) ) td1
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve c WHERE c.source_curve_def_id=@forware_curve_id
	AND c.as_of_date=@as_of_date
	--AND td.term_date>@maturity_to+ ' 00:00:00.000'
	AND YEAR(c.maturity_date)=YEAR(spc.maturity_date) AND MONTH(c.maturity_date)=MONTH(spc.maturity_date)) spc2
	WHERE 1=1
	GROUP BY spc.source_curve_def_id

--ONPEAK
	DELETE FROM #temp_block_define4

	SET @forware_curve_id = @onpeak_forward_curve_id -- 217 OffPeak 218 OnPeak
	Select @block_define_id = block_define_id from source_price_curve_def where source_curve_def_id = @onpeak_curve_id


	INSERT INTO #temp_block_define4---------- select * from #temp_block_define4 where term_date between '2011-9-1' and '2011-9-30'
	SELECT unpvt.term_date,CAST(REPLACE(unpvt.[hour],'hr','') AS INT) [Hour],unpvt.hr_mult FROM 
	(SELECT
	hb.term_date,
	hb.block_type,
	hb.block_define_id,
	hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
	FROM
	hour_block_term hb
	WHERE block_type=@block_type
	AND block_define_id=@block_define_id
	)p
	UNPIVOT
	(hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
	) AS unpvt 
	WHERE
	unpvt.[hr_mult]<>0

	INSERT INTO #curves
	SELECT 
	@onpeak_curve_id source_curve_def_id,
	@as_of_date as_of_date,
	@term_start maturity_date,
	(SUM(spc1.curve_value)+MAX(spc2.curve_value)*MAX(td1.remaining_hour))/MAX(td1.total_hour) curve_value
	
	FROM
	source_price_curve spc
	INNER JOIN #temp_block_define4 td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME) = spc.maturity_date
	AND spc.source_curve_def_id=@curve_id 
	--AND spc.as_of_date=td.term_date 
	AND spc.maturity_date BETWEEN @term_start AND @term_end+ ' 23:00:00.000'
	AND YEAR(maturity_date) = YEAR(@as_of_date)
	AND MONTH(maturity_date) = MONTH(@as_of_date)
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve a WHERE a.source_curve_def_id=spc.source_curve_def_id
	AND a.as_of_date=spc.as_of_date
	AND a.maturity_date=spc.maturity_date
	AND a.maturity_date<=@maturity_to+ ' 23:00:00.000') spc1
	OUTER APPLY(SELECT SUM(b.hr_mult) total_hour,SUM(CASE WHEN b.term_date>@maturity_to+ ' 23:00:00.000' THEN 1 ELSE 0 END) remaining_hour FROM #temp_block_define4 b WHERE
	YEAR(b.term_date) = YEAR(@as_of_date)
	AND MONTH(b.term_date) = MONTH(@as_of_date) ) td1
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve c WHERE c.source_curve_def_id=@forware_curve_id
	AND c.as_of_date=@as_of_date
	--AND td.term_date>@maturity_to
	AND YEAR(c.maturity_date)=YEAR(spc.maturity_date) AND MONTH(c.maturity_date)=MONTH(spc.maturity_date)) spc2
	WHERE 1=1
	GROUP BY spc.source_curve_def_id


-- select * from #curves

	DELETE FROM source_price_curve 
	FROM source_price_curve spc 
		INNER JOIN #curves f ON spc.source_curve_def_id = f.source_curve_def_id
			AND spc.as_of_date = f.as_of_date

	INSERT INTO source_price_curve (source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, 
				maturity_date ,curve_value, create_user, create_ts, update_user, update_ts, bid_value, ask_value, is_dst)
	SELECT	f.source_curve_def_id, f.as_of_date, 77, 4500, f.maturity_date, f.curve_value
		, dbo.FNADBUser(), GETDATE(), dbo.FNADBUser(), GETDATE(), f.curve_value, f.curve_value, 0
	FROM #curves f

END

--IF OBJECT_ID('tempdb..#temp_block_define4') IS NOT NULL
--BEGIN
--    DROP TABLE #temp_block_define4
--END

--IF OBJECT_ID('tempdb..#curves') IS NOT NULL
--BEGIN
--    DROP TABLE #curves
--END

EXEC spa_print 'APX 2 Start'
------Peak
------291997   62.23213214	43.70203665
------162
------171
------180
-----select * from source_price_curve_def where source_curve_def_id in (166,169,23,162,167) order by source_curve_def_id 
---select * from source_price_curve where source_curve_def_id in (166,169) and as_of_date = '2011-9-26'

------Peak
------291997   62.23213214	43.70203665


------162
------171
------180
-----select * from source_price_curve_def where source_curve_def_id in (166,169,23,162,167) order by source_curve_def_id 
---select * from source_price_curve where source_curve_def_id in (166,169) and as_of_date = '2011-9-26'

--IF OBJECT_ID('tempdb..#temp_block_define4') IS NOT NULL
--BEGIN
--    DROP TABLE #temp_block_define4
--END

--IF OBJECT_ID('tempdb..#curves') IS NOT NULL
--BEGIN
--    DROP TABLE #curves
--END 

--DECLARE @block_type INT,@block_define_id INT,@curve_id int,@as_of_date DATETIME,@term_start DATETIME, @term_end DATETIME,@forware_curve_id INT
--DECLARE @onpeak_curve_id INT, @offpeak_curve_id INT, @maturity_to DATETIME
--DECLARE @offpeak_forward_curve_id INT, @onpeak_forward_curve_id INT 
SET @block_type=12000 -- always need this --check
SET @curve_id=23
SET @onpeak_curve_id  = 164
SET @offpeak_curve_id  =165

SET @offpeak_forward_curve_id =190
SET @onpeak_forward_curve_id = 188


SET @as_of_date=CONVERT(VARCHAR(10),getdate(),120)

SET @term_start = CONVERT(varchar(8), @as_of_date, 120) + '01'
SET @term_end = dateadd(MONTH,1,cast(convert(varchar(8),@as_of_date,120)+'01' AS DATETIME))-1
SET @maturity_to = DATEADD(dd, 1, @as_of_date)

DELETE FROM #temp_block_define4

IF OBJECT_ID('tempdb..#curves') IS NOT NULL
BEGIN
    DELETE FROM #curves
END 	

--CREATE TABLE #temp_block_define4(term_date DATETIME,[Hour] INT,hr_mult FLOAT)

IF @maturity_to <= @term_end
BEGIN
	SET @forware_curve_id = @offpeak_forward_curve_id -- 217 OffPeak 218 OnPeak
	Select @block_define_id = block_define_id from source_price_curve_def where source_curve_def_id = @offpeak_curve_id

--OFFPEAK
	INSERT INTO #temp_block_define4 -----select * from #temp_block_define4 where term_date between '2011-9-1' and '2011-9-30'
	SELECT unpvt.term_date,CAST(REPLACE(unpvt.[hour],'hr','') AS INT) [Hour],unpvt.hr_mult FROM 
	(SELECT
	hb.term_date,
	hb.block_type,
	hb.block_define_id,
	hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
	FROM
	hour_block_term hb
	WHERE block_type=@block_type
	AND block_define_id=@block_define_id
	)p
	UNPIVOT
	(hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
	) AS unpvt 
	WHERE
	unpvt.[hr_mult]<>0



	INSERT INTO #curves
	SELECT 
	@offpeak_curve_id source_curve_def_id,
	@as_of_date as_of_date,
	@term_start maturity_date,
	(SUM(spc1.curve_value)+MAX(spc2.curve_value)*MAX(td1.remaining_hour))/MAX(td1.total_hour) curve_value
	
	FROM
	source_price_curve spc
	INNER JOIN #temp_block_define4 td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME) = spc.maturity_date
	AND spc.source_curve_def_id=@curve_id 
	--AND spc.as_of_date=td.term_date 
	AND spc.maturity_date BETWEEN @term_start AND @term_end+ ' 23:00:00.000'
	AND YEAR(maturity_date) = YEAR(@as_of_date)
	AND MONTH(maturity_date) = MONTH(@as_of_date)
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve a WHERE a.source_curve_def_id=spc.source_curve_def_id
	AND a.as_of_date=spc.as_of_date
	AND a.maturity_date=spc.maturity_date
	AND a.maturity_date<=@maturity_to+ ' 23:00:00.000') spc1
	OUTER APPLY(SELECT SUM(b.hr_mult) total_hour,SUM(CASE WHEN b.term_date>@maturity_to+ ' 23:00:00.000' THEN 1 ELSE 0 END) remaining_hour FROM #temp_block_define4 b WHERE
	YEAR(b.term_date) = YEAR(@as_of_date)
	AND MONTH(b.term_date) = MONTH(@as_of_date) ) td1
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve c WHERE c.source_curve_def_id=@forware_curve_id
	AND c.as_of_date=@as_of_date
	--AND td.term_date>@maturity_to+ ' 00:00:00.000'
	AND YEAR(c.maturity_date)=YEAR(spc.maturity_date) AND MONTH(c.maturity_date)=MONTH(spc.maturity_date)) spc2
	WHERE 1=1
	GROUP BY spc.source_curve_def_id

--ONPEAK
	DELETE FROM #temp_block_define4

	SET @forware_curve_id = @onpeak_forward_curve_id -- 217 OffPeak 218 OnPeak
	Select @block_define_id = block_define_id from source_price_curve_def where source_curve_def_id = @onpeak_curve_id


	INSERT INTO #temp_block_define4---------- select * from #temp_block_define4 where term_date between '2011-9-1' and '2011-9-30'
	SELECT unpvt.term_date,CAST(REPLACE(unpvt.[hour],'hr','') AS INT) [Hour],unpvt.hr_mult FROM 
	(SELECT
	hb.term_date,
	hb.block_type,
	hb.block_define_id,
	hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
	FROM
	hour_block_term hb
	WHERE block_type=@block_type
	AND block_define_id=@block_define_id
	)p
	UNPIVOT
	(hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
	) AS unpvt 
	WHERE
	unpvt.[hr_mult]<>0

	INSERT INTO #curves
	SELECT 
	@onpeak_curve_id source_curve_def_id,
	@as_of_date as_of_date,
	@term_start maturity_date,
	(SUM(spc1.curve_value)+MAX(spc2.curve_value)*MAX(td1.remaining_hour))/MAX(td1.total_hour) curve_value
	
	FROM
	source_price_curve spc
	INNER JOIN #temp_block_define4 td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME) = spc.maturity_date
	AND spc.source_curve_def_id=@curve_id 
	--AND spc.as_of_date=td.term_date 
	AND spc.maturity_date BETWEEN @term_start AND @term_end+ ' 23:00:00.000'
	AND YEAR(maturity_date) = YEAR(@as_of_date)
	AND MONTH(maturity_date) = MONTH(@as_of_date)
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve a WHERE a.source_curve_def_id=spc.source_curve_def_id
	AND a.as_of_date=spc.as_of_date
	AND a.maturity_date=spc.maturity_date
	AND a.maturity_date<=@maturity_to+ ' 23:00:00.000') spc1
	OUTER APPLY(SELECT SUM(b.hr_mult) total_hour,SUM(CASE WHEN b.term_date>@maturity_to+ ' 23:00:00.000' THEN 1 ELSE 0 END) remaining_hour FROM #temp_block_define4 b WHERE
	YEAR(b.term_date) = YEAR(@as_of_date)
	AND MONTH(b.term_date) = MONTH(@as_of_date) ) td1
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve c WHERE c.source_curve_def_id=@forware_curve_id
	AND c.as_of_date=@as_of_date
	--AND td.term_date>@maturity_to
	AND YEAR(c.maturity_date)=YEAR(spc.maturity_date) AND MONTH(c.maturity_date)=MONTH(spc.maturity_date)) spc2
	WHERE 1=1
	GROUP BY spc.source_curve_def_id


-- select * from #curves

	DELETE FROM source_price_curve 
	FROM source_price_curve spc 
		INNER JOIN #curves f ON spc.source_curve_def_id = f.source_curve_def_id
			AND spc.as_of_date = f.as_of_date

	INSERT INTO source_price_curve (source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, 
				maturity_date ,curve_value, create_user, create_ts, update_user, update_ts, bid_value, ask_value, is_dst)
	SELECT	f.source_curve_def_id, f.as_of_date, 77, 4500, f.maturity_date, f.curve_value
		, dbo.FNADBUser(), GETDATE(), dbo.FNADBUser(), GETDATE(), f.curve_value, f.curve_value, 0
	FROM #curves f

END

IF OBJECT_ID('tempdb..#temp_block_define4') IS NOT NULL
BEGIN
    DROP TABLE #temp_block_define4
END

IF OBJECT_ID('tempdb..#curves') IS NOT NULL
BEGIN
    DROP TABLE #curves
END 


EXEC spa_print 'ENDEX 1 Start'

DECLARE @as_of_date6 DATETIME
---Uncomment here to test
--/*
SET @as_of_date6 = CONVERT(VARCHAR(10), GETDATE(), 120)

IF OBJECT_ID('tempdb..#tcurve') IS NOT NULL
BEGIN
    DROP TABLE #tcurve
END

IF OBJECT_ID('tempdb..#tcurve2') IS NOT NULL
BEGIN
    DROP TABLE #tcurve2
END


--*/

----- THIS SCRIPT CALCUALTES ZBR Heren Swap Curve ---------------
---- If not fully settled it saves for each as of date... 
----- If fully settled it saves for last day in the month as this will be defined as the settlement date in the settlement calendar
--select * from source_price_curve_def where curve_name like '%zbr%'
--select * from holiday_group where hol_group_value_id=292311 and hol_date = '2011-09-01'

DECLARE @zbr_bom_id           INT = 200
DECLARE @zbr_cum_id           INT = 107
DECLARE @zbr_forward_id       INT = 113
DECLARE @zbr_cal              INT --=292298 -- publication days calendar used for ZBR finanacial
DECLARE @max_as_of_date       DATETIME
DECLARE @settled_curve_value  FLOAT
DECLARE @forward_curve_value  FLOAT
DECLARE @prior_month          DATETIME

--select * from source_PRICE_curve_def where curve_name like '%ZBR%'
--select * from source_price_curve where source_curve_def_id = 107 and as_of_date = '2011-08-12'
SELECT @zbr_cal = exp_calendar_id
FROM   source_price_curve_def
WHERE  source_curve_def_id = @zbr_bom_id

--select * from  source_price_curve where source_curve_def_id = 203 and as_of_date = '2011-08-22'

SELECT @max_as_of_date = MAX(as_of_date)
FROM   source_price_curve
WHERE  source_curve_def_id = @zbr_cum_id
       AND maturity_date = CONVERT(VARCHAR(7), DATEADD(mm, 1, @as_of_date6), 120)
           + '-01'
       AND as_of_date <= @as_of_date6

-- I think this should be checking maturity as next month (i.e., in Aug use Sept forward price).. check with user
SELECT @forward_curve_value = curve_value
FROM   source_price_curve
WHERE  source_curve_def_id = @zbr_forward_id
       AND as_of_date = @as_of_date6
       AND maturity_date = CONVERT(VARCHAR(7), DATEADD(mm, 1, @as_of_date6), 120)
           + '-01'
--and maturity_date = convert(varchar(7), dateadd(mm, 1, @max_as_of_date), 120)+'-01'

SELECT @settled_curve_value = curve_value
FROM   source_price_curve
WHERE  source_curve_def_id = @zbr_cum_id
       AND as_of_date = @max_as_of_date
       AND maturity_date = CONVERT(VARCHAR(7), DATEADD(mm, 1, @as_of_date6), 120) + '-01'

SET @prior_month = CONVERT(VARCHAR(7), DATEADD(mm, -1, @max_as_of_date), 120) + '-01'

DECLARE @fx_forward_value FLOAT
SELECT @fx_forward_value = curve_value
FROM   source_price_curve
WHERE  source_curve_def_id = 105
       AND as_of_date = @as_of_date6
       AND maturity_date = CONVERT(VARCHAR(7), @as_of_date6, 120) + '-01'

SELECT @forward_curve_value forward_curve_value,
       @settled_curve_value settled_curve_value,
       --dbo.FNARCLagcurve(@prior_month, @as_of_date6, 4500, NULL, 105,0,0,0,1,NULL, 0, 1, NULL, NULL) gbp_avg_fx,
       @fx_forward_value fx_forward_value,
       @zbr_bom_id zbr_bom_id,
       COUNT(*) total_days,
       SUM(CASE WHEN (exp_date <= @max_as_of_date) THEN 1 ELSE 0 END) 
       expired_days,
       SUM(CASE WHEN (exp_date > @max_as_of_date) THEN 1 ELSE 0 END) 
       remaining_days
       INTO #tcurve
FROM   holiday_group
WHERE  hol_group_value_id = @zbr_cal
       AND CONVERT(VARCHAR(7), exp_date, 120) = CONVERT(VARCHAR(7), @as_of_date6, 120)

--select * from #tcurve

SELECT zbr_bom_id curve_id,
       @as_of_date6 as_of_date,
       CONVERT(VARCHAR(7), DATEADD(mm, 1, @max_as_of_date), 120) + '-01' 
       maturity,
       (
           settled_curve_value * expired_days + forward_curve_value * 
           remaining_days
       ) / total_days curve_value 
       INTO #tcurve2
FROM   #tcurve

--select * from #tcurve2

DELETE 
FROM   source_price_curve 
       FROM source_price_curve spc
       INNER JOIN #tcurve2 f
            ON  spc.source_curve_def_id = f.curve_id
            AND spc.as_of_date = f.as_of_date

INSERT INTO source_price_curve
  (
    source_curve_def_id,
    as_of_date,
    Assessment_curve_type_value_id,
    curve_source_value_id,
    maturity_date,
    curve_value,
    create_user,
    create_ts,
    update_user,
    update_ts,
    bid_value,
    ask_value,
    is_dst
  )
SELECT f.curve_id,
       f.as_of_date,
       77,
       4500,
       f.maturity,
       f.curve_value,
       dbo.FNADBUser(),
       GETDATE(),
       dbo.FNADBUser(),
       GETDATE(),
       f.curve_value,
       f.curve_value,
       0
FROM   #tcurve2 f
WHERE  f.curve_value IS NOT NULL

IF OBJECT_ID('tempdb..#tcurve') IS NOT NULL
BEGIN
    DROP TABLE #tcurve
END

IF OBJECT_ID('tempdb..#tcurve2') IS NOT NULL
BEGIN
    DROP TABLE #tcurve2
END


----- THIS SCRIPT CALCUALTES BRENT SWAP SETTLEMENT VALUES ---------------
---- If not fully settled it saves for each as of date... 
----- If fully settled it saves for last day in the month as this will be defined as the settlement date in the settlement calendar

DECLARE @as_of_date7             DATETIME
DECLARE @ice_future_curve_id     INT = 143,	--ICE Future curve
        @brent_forward_curve_id  INT = 144,	-- Brent forward curve used as proxy
        @brent_curve_id          INT = 201,	-- Brent Swap primary curve
        @brent_sett_curve_id     INT = 202 -- Brent Swap Settlement primary curve
DECLARE @past_months             INT = -1 -- number of past months to calcuatle for

DECLARE @ice_future_cal          INT = 292284 -- ICE Settlement Date (One as of date for one expiration)
                                     --WE DONT NEED BRENT CAL ONCE WE CHANGE THE POSITION LOGIC
DECLARE @brent_cal               INT = 292295 -- ICE Publication Calendar (This is a hanging calendar)


--select * from static_data_value where value_id=292295

---Uncomment here to test
--/*
SET @as_of_date7 = CONVERT(VARCHAR(10), GETDATE(), 120)
IF OBJECT_ID('tempdb..#tcurve3') IS NOT NULL
BEGIN
    DROP TABLE #tcurve3
END

IF OBJECT_ID('tempdb..#tcurve4') IS NOT NULL
BEGIN
    DROP TABLE #tcurve4
END

--*/
--select * from source_price_curve_def where source_curve_def_id = 144


SELECT CASE 
            WHEN (DATEADD(MONTH, 1, CAST(CONVERT(VARCHAR(8), hgb.hol_date, 120) + '01' AS DATETIME)) -1 <= @as_of_date7) 
				THEN @brent_sett_curve_id
            ELSE @brent_curve_id
       END 
       brent_sett_curve_id,
       hgb.hol_date brent_maturity,
       hgb.exp_date brent_as_of_date,
       hgi.hol_date ice_maturity,
       hgi.exp_date ice_as_of_date,
       spc1.curve_value promt_month_curve_value,
       spc2.curve_value promt_month_plus1_curve_value,
       spc3.curve_value promt_month_forward_curve_value,
       spc3.maturity_date forward_maturity,
       CASE 
            WHEN (hgb.hol_date > @as_of_date7) THEN spc3.curve_value
            ELSE COALESCE(spc1.curve_value, spc2.curve_value, spc3.curve_value)
       END curve_value,
       CONVERT(VARCHAR(8), hgb.hol_date, 120) + '01' curve_maturity,
       --dateadd(MONTH,1,cast(convert(varchar(8),hgb.hol_date,120)+'01' AS DATETIME))-1 curve_end_maturity,
       CASE 
            WHEN (DATEADD(MONTH, 1, CAST(CONVERT(VARCHAR(8), hgb.hol_date, 120) + '01' AS DATETIME)) -1 <= @as_of_date7) 
				THEN DATEADD(MONTH, 1, CAST(CONVERT(VARCHAR(8), hgb.hol_date, 120) + '01' AS DATETIME)) -1
            ELSE @as_of_date7
       END as_of_date,
       CASE 
            WHEN (DATEADD(MONTH, 1, CAST(CONVERT(VARCHAR(8), hgb.hol_date, 120) + '01' AS DATETIME)) -1 <= @as_of_date7) THEN 's'
            ELSE 'f'
       END settled_or_forward
       INTO #tcurve3
FROM   holiday_group hgb
       INNER JOIN holiday_group hgi
            ON  hgi.hol_group_value_id = @ice_future_cal
            AND YEAR(hgb.exp_date) = YEAR(hgi.exp_date)
            AND MONTH(hgb.exp_date) = MONTH(hgi.exp_date)
       LEFT JOIN source_price_curve spc1
            ON  spc1.source_curve_def_id = @ice_future_curve_id
            AND spc1.as_of_date = hgb.exp_date
            AND spc1.maturity_date = hgi.hol_date
            AND spc1.as_of_date <= hgi.exp_date
       LEFT JOIN source_price_curve spc2
            ON  spc2.source_curve_def_id = @ice_future_curve_id
            AND spc2.as_of_date = hgb.exp_date
            AND spc2.maturity_date = DATEADD(mm, 1, hgi.hol_date)
            AND spc2.as_of_date > hgi.exp_date
       LEFT JOIN source_price_curve spc3
            ON  spc3.source_curve_def_id = @brent_forward_curve_id
            AND spc3.as_of_date = @as_of_date7
            AND spc3.maturity_date = CONVERT(VARCHAR(8), DATEADD(mm, -1, hgi.hol_date), 120) + '01'
                --AND
                --spc3.as_of_date = hgi.exp_date
WHERE CONVERT(VARCHAR(8), hgb.exp_date, 120) + '01' BETWEEN CONVERT(VARCHAR(8), DATEADD(mm, @past_months, @as_of_date7), 120) + '01' 
	AND CONVERT(VARCHAR(8), @as_of_date7, 120) + '01'
	AND hgb.hol_group_value_id = @brent_cal -- This should be changed to Brent calendar when position logic is changed
ORDER BY hgb.hol_date

--select * from #tcurve3 where brent_maturity between '2011-07-1' and '2011-07-31'
--select * from #tcurve4

--return 
SELECT as_of_date,
       brent_sett_curve_id,
       curve_maturity,
       AVG(curve_value) curve_value,
       settled_or_forward 
       INTO #tcurve4
FROM   #tcurve3
GROUP BY
       as_of_date,
       brent_sett_curve_id,
       curve_maturity,
       settled_or_forward

--select * from #tcurve4


----DELETE AND INSERT 

DELETE 
FROM   source_price_curve 
       FROM source_price_curve spc
       INNER JOIN #tcurve4 f
            ON  spc.source_curve_def_id = f.brent_sett_curve_id
            AND spc.as_of_date = f.as_of_date

INSERT INTO source_price_curve
  (
    source_curve_def_id,
    as_of_date,
    Assessment_curve_type_value_id,
    curve_source_value_id,
    maturity_date,
    curve_value,
    create_user,
    create_ts,
    update_user,
    update_ts,
    bid_value,
    ask_value,
    is_dst
  )
SELECT f.brent_sett_curve_id,
       f.as_of_date,
       77,
       4500,
       f.curve_maturity,
       f.curve_value,
       dbo.FNADBUser(),
       GETDATE(),
       dbo.FNADBUser(),
       GETDATE(),
       f.curve_value,
       f.curve_value,
       0
FROM   #tcurve4 f

-- select * from source_price_curve where source_curve_def_id = 144 and as_of_date = '2011-08-22'
--select * from source_price_curve where source_curve_def_id in (221, 144)

IF object_id('tempdb..#tcurve3') IS NOT NULL
BEGIN
	DROP TABLE #tcurve3
END

IF object_id('tempdb..#tcurve4') IS NOT NULL
BEGIN
	DROP TABLE #tcurve4
END 


DECLARE @as_of_date8 VARCHAR(20)
SET @as_of_date8 = CONVERT(VARCHAR(10), GETDATE(), 120)

EXEC spa_calculate_offpeak_price @as_of_date8, 168, 161, 163--, 'source_price_curve', '' ----Endex 7-23 M
EXEC spa_calculate_offpeak_price @as_of_date8, 168, 197, 189--, 'source_price_curve', '' ---Endex 8-20 M
EXEC spa_calculate_offpeak_price @as_of_date8, 175, 170, 173--, 'source_price_curve', '' ---Endex 7-20 Q
EXEC spa_calculate_offpeak_price @as_of_date8, 175, 191, 193--, 'source_price_curve', '' ---Endex 8-20 Q
EXEC spa_calculate_offpeak_price @as_of_date8, 187, 176, 183--, 'source_price_curve', '' ---Endex 7-20 Y
EXEC spa_calculate_offpeak_price @as_of_date8, 187, 195, 181--, 'source_price_curve', '' ---Endex 8-20 Y



/*** Enter input here *****/
DECLARE @block_define_id12 INT, @as_of_date12 DATETIME, @m_curve_id12 INT, @q_curve_id12 INT, @y_curve_id12 INT
SET @block_define_id12=292037
SET @as_of_date12=CONVERT(VARCHAR(10),getdate(),120)

set @m_curve_id12 = 203
set @q_curve_id12 = 204
set @y_curve_id12 = 205

/*** End of input here *****/

IF OBJECT_ID('tempdb..#temp12_block_define12') IS NOT NULL
BEGIN
   DROP TABLE #temp12_block_define12
END

IF OBJECT_ID('tempdb..#temp12') IS NOT NULL
BEGIN
   DROP TABLE #temp12
END

 --select * from static_data_value where value_id = 291899


DECLARE @block_type12  INT 
DECLARE @curve_id12  int
SET @curve_id12=77
SET @block_type12=12000  -- always need this --check

CREATE TABLE #temp12_block_define12(term_date DATETIME,[Hour] INT,hr_mult FLOAT)

INSERT INTO #temp12_block_define12
SELECT unpvt.term_date,CAST(REPLACE(unpvt.[hour],'hr','') AS INT) [Hour],unpvt.hr_mult FROM 
      (SELECT
            hb.term_date,
            hb.block_type,
            hb.block_define_id,
            hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
      FROM
            hour_block_term hb
            WHERE block_type=@block_type12
            AND block_define_id=@block_define_id12
      )p
      UNPIVOT
      (hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
      ) AS unpvt  
WHERE
      unpvt.[hr_mult]<>0
      

	IF @y_curve_id12  IS NOT NULL
      SELECT 
			@y_curve_id12 source_curve_def_id,
            spc.as_of_date,
            cast(year(spc.maturity_date) as varchar) + '-01-01' maturity,
            avg(spc.curve_value) curve_value
	  INTO #temp12
      FROM
            source_price_curve spc
            INNER JOIN #temp12_block_define12 td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME)  = spc.maturity_date
      WHERE
            spc.source_curve_def_id=@curve_id12   
            AND spc.as_of_date=@as_of_date12
       GROUP BY spc.source_curve_def_id,
            spc.as_of_date, cast(year(spc.maturity_date) as varchar) + '-01-01' 
        
     IF @q_curve_id12  IS NOT NULL  
      INSERT INTO #temp12
      SELECT 
			@q_curve_id12 source_curve_def_id, 
            spc.as_of_date,
            cast(year(spc.maturity_date) as varchar) + '-' + 
            cast( CASE DATEpart(QQ, spc.maturity_date) WHEN 1 THEN 1 WHEN 2 THEN 4 WHEN 3 THEN 7 WHEN 4 THEN 10 END as varchar) + '-01' maturity,
            avg(spc.curve_value) curve_value
      FROM
            source_price_curve spc
            INNER JOIN #temp12_block_define12 td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME)  = spc.maturity_date
      WHERE
            spc.source_curve_def_id=@curve_id12   
            AND spc.as_of_date=@as_of_date12
       GROUP BY spc.source_curve_def_id,
            spc.as_of_date, cast(year(spc.maturity_date) as varchar) + '-' + 
            cast( CASE DATEpart(QQ, spc.maturity_date) WHEN 1 THEN 1 WHEN 2 THEN 4 WHEN 3 THEN 7 WHEN 4 THEN 10 END as varchar) + '-01'

    IF @m_curve_id12  IS NOT NULL
      INSERT INTO #temp12
      SELECT 
			@m_curve_id12 source_curve_def_id, 
            spc.as_of_date,
            cast(year(spc.maturity_date) as varchar) + '-' + cast(DATEpart(mm, spc.maturity_date) as varchar) + '-01' maturity,
            avg(spc.curve_value) curve_value
      FROM
            source_price_curve spc
            INNER JOIN #temp12_block_define12 td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME)  = spc.maturity_date
      WHERE
            spc.source_curve_def_id=@curve_id12   
            AND spc.as_of_date=@as_of_date12
       GROUP BY spc.source_curve_def_id,
            spc.as_of_date, cast(year(spc.maturity_date) as varchar) + '-' + cast(DATEpart(mm, spc.maturity_date) as varchar) + '-01'

	DELETE FROM source_price_curve 
	FROM source_price_curve spc 
		INNER JOIN #temp12 f ON spc.source_curve_def_id = f.source_curve_def_id
			AND spc.as_of_date = f.as_of_date
			AND spc.curve_source_value_id=4500

	INSERT INTO source_price_curve (source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, 
				maturity_date ,curve_value, create_user, create_ts, update_user, update_ts, bid_value, ask_value, is_dst)
	SELECT	f.source_curve_def_id, f.as_of_date, 77, 4500, f.maturity, f.curve_value
		, dbo.FNADBUser(), GETDATE(), dbo.FNADBUser(), GETDATE(), f.curve_value, f.curve_value, 0
	FROM #temp12 f





------Peak
------291997   62.23213214	43.70203665


------162
------171
------180
-----select * from source_price_curve_def where source_curve_def_id in (166,169,23,162,167) order by source_curve_def_id 
---select * from source_price_curve where source_curve_def_id in (166,169) and as_of_date = '2011-9-26'
IF OBJECT_ID('tempdb..#temp_block_define13') IS NOT NULL
BEGIN
   DROP TABLE #temp_block_define13
END

IF OBJECT_ID('tempdb..#curves13') IS NOT NULL
BEGIN
   DROP TABLE #curves13
END



DECLARE @block_type13 INT,@block_define_id13 INT,@curve_id13 int,@as_of_date13 DATETIME,@term_start13 DATETIME, @term_end13 DATETIME,@forware_curve_id13 INT
DECLARE @onpeak_curve_id13 INT, @offpeak_curve_id13 INT, @maturity_to13 DATETIME
DECLARE @offpeak_forward_curve_id13 INT, @onpeak_forward_curve_id13 INT 
SET @block_type13=12000 -- always need this --check
SET @curve_id13=82

SET @offpeak_curve_id13 = 208

SET @offpeak_forward_curve_id13 =203



SET @as_of_date13=CONVERT(VARCHAR(10),getdate(),120)

SET @term_start13 = CONVERT(varchar(8), @as_of_date13, 120) + '01'
SET @term_end13 = dateadd(MONTH,1,cast(convert(varchar(8),@as_of_date13,120)+'01' AS DATETIME))-1
SET @maturity_to13 = DATEADD(dd, 1, @as_of_date13)

	
CREATE TABLE #temp_block_define13(term_date DATETIME,[Hour] INT,hr_mult FLOAT)

IF @maturity_to13 <= @term_end13
BEGIN
	SET @forware_curve_id13 = @offpeak_forward_curve_id13 -- 217 OffPeak 218 OnPeak
	Select @block_define_id13 = block_define_id from source_price_curve_def where source_curve_def_id = @offpeak_curve_id13

--Baseload
	INSERT INTO #temp_block_define13 -----select * from #temp_block_define13 where term_date between '2011-9-1' and '2011-9-30'
	SELECT unpvt.term_date,CAST(REPLACE(unpvt.[hour],'hr','') AS INT) [Hour],unpvt.hr_mult FROM 
	(SELECT
	hb.term_date,
	hb.block_type,
	hb.block_define_id,
	hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24
	FROM
	hour_block_term hb
	WHERE block_type=@block_type13
	AND block_define_id=@block_define_id13
	)p
	UNPIVOT
	(hr_mult FOR [hour] IN (hr1,hr2,hr3,hr4,hr5,hr6,hr7,hr8,hr9,hr10,hr11,hr12,hr13,hr14,hr15,hr16,hr17,hr18,hr19,hr20,hr21,hr22,hr23,hr24)
	) AS unpvt 
	WHERE
	unpvt.[hr_mult]<>0



	
	SELECT 
	@offpeak_curve_id13 source_curve_def_id,
	@as_of_date13 as_of_date,
	@term_start13 maturity_date,
	(SUM(spc1.curve_value)+MAX(spc2.curve_value)*MAX(td1.remaining_hour))/MAX(td1.total_hour) curve_value
	
	INTO #curves13
	FROM
	source_price_curve spc
	INNER JOIN #temp_block_define13 td on CAST(CONVERT(VARCHAR(10),td.term_date,120)+' '+CAST(td.[Hour]-1 AS VARCHAR)+':00:00.000' AS DATETIME) = spc.maturity_date
	AND spc.source_curve_def_id=@curve_id13 
	--AND spc.as_of_date=td.term_date 
	AND spc.maturity_date BETWEEN @term_start13 AND @term_end13+ ' 23:00:00.000'
	AND YEAR(maturity_date) = YEAR(@as_of_date13)
	AND MONTH(maturity_date) = MONTH(@as_of_date13)
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve a WHERE a.source_curve_def_id=spc.source_curve_def_id
	AND a.as_of_date=spc.as_of_date
	AND a.maturity_date=spc.maturity_date
	AND a.maturity_date<=@maturity_to13+ ' 23:00:00.000') spc1
	OUTER APPLY(SELECT SUM(b.hr_mult) total_hour,SUM(CASE WHEN b.term_date>@maturity_to13+ ' 23:00:00.000' THEN 1 ELSE 0 END) remaining_hour FROM #temp_block_define13 b WHERE
	YEAR(b.term_date) = YEAR(@as_of_date13)
	AND MONTH(b.term_date) = MONTH(@as_of_date13) ) td1
	OUTER APPLY(SELECT SUM(curve_value) curve_value FROM source_price_curve c WHERE c.source_curve_def_id=@forware_curve_id13
	AND c.as_of_date=@as_of_date13
	--AND td.term_date>@maturity_to13+ ' 00:00:00.000'
	AND YEAR(c.maturity_date)=YEAR(spc.maturity_date) AND MONTH(c.maturity_date)=MONTH(spc.maturity_date)) spc2
	WHERE 1=1
	GROUP BY spc.source_curve_def_id



-- select * from #curves13

	DELETE FROM source_price_curve 
	FROM source_price_curve spc 
		INNER JOIN #curves13 f ON spc.source_curve_def_id = f.source_curve_def_id
			AND spc.as_of_date = f.as_of_date

	INSERT INTO source_price_curve (source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, 
				maturity_date ,curve_value, create_user, create_ts, update_user, update_ts, bid_value, ask_value, is_dst)
	SELECT	f.source_curve_def_id, f.as_of_date, 77, 4500, f.maturity_date, f.curve_value
		, dbo.FNADBUser(), GETDATE(), dbo.FNADBUser(), GETDATE(), f.curve_value, f.curve_value, 0
	FROM #curves13 f

END