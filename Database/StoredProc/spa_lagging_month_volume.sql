/****** Object:  StoredProcedure [dbo].[spa_lagging_month_volume]    Script Date: 07/01/2009 17:05:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_lagging_month_volume]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_lagging_month_volume]
/****** Object:  StoredProcedure [dbo].[spa_lagging_month_volume]    Script Date: 07/01/2009 17:05:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_lagging_month_volume] 
	 @flag VARCHAR(1)
	,@term_start DATETIME
	,@term_end DATETIME
	,@xml VARCHAR(MAX)=NULL
	,@volume numeric(38,20)=null
	,@frequency varchar(25)='m'
	,@leg INT=1
	,@LaggingProcessTableName varchar(200)=null
	,@price numeric(38,20)=null
	,@price_adder numeric(38,20)=NULL
	,@price_adder2 NUMERIC(38,20)=NULL
AS

/*
--exec spa_lagging_month_volume 'u','2011-01-01','2011-06-30',
--'<Root><PSRecordset  term_start="01/01/2011" term_end="01/31/2011" volume="1" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="02/01/2011" term_end="02/28/2011" volume="2" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="03/01/2011" term_end="03/31/2011" volume="3" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="04/01/2011" term_end="04/30/2011" volume="4" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="05/01/2011" term_end="05/31/2011" volume="5" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="06/01/2011" term_end="06/30/2011" volume="6" price="NULL" price_adder="NULL"></PSRecordset></Root>'
--,NULL,'m',1,NULL,NULL,NULL


-- spa_lagging_month_volume 's','2009-07-01','2009-07-31' 
--SELECT * FROM adiha_process.dbo.Lagging_farrms_admin_88985BFB_8E99_48D0_B953_13BB209DC4BD
--Lagging_farrms_admin_88985BFB_8E99_48D0_B953_13BB209DC4BD
DECLARE @flag VARCHAR(1),@term_start DATETIME,@term_end DATETIME,@xml VARCHAR(MAX),@volume FLOAT,@frequency varchar(25)
,@LaggingProcessTableName varchar(100),@leg int
DECLARE @price numeric(38,20)
	,@price_adder numeric(38,20)
	,@price_adder2 NUMERIC(38,20)
set @LaggingProcessTableName=null

SET @term_end='2011-06-30'
SET @term_start='2011-01-01'
SET @xml='<Root><PSRecordset  term_start="01/01/2011" term_end="01/31/2011" volume="1" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="02/01/2011" term_end="02/28/2011" volume="2" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="03/01/2011" term_end="03/31/2011" volume="3" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="04/01/2011" term_end="04/30/2011" volume="4" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="05/01/2011" term_end="05/31/2011" volume="5" price="NULL" price_adder="NULL"></PSRecordset><PSRecordset  term_start="06/01/2011" term_end="06/30/2011" volume="6" price="NULL" price_adder="NULL"></PSRecordset></Root>'

SET @flag='u'
SET @frequency ='m'
set @leg=1

drop table #tmp_avg_vol

--*/
DECLARE @st VARCHAR(max)
IF @flag='s' OR @flag = 't'
BEGIN

	
	CREATE TABLE #tmp_term_vol
	(
		term_start    DATETIME,
		term_end      DATETIME,
		Volume        NUMERIC(38, 20),
		price         NUMERIC(38, 20),
		price_adder   NUMERIC(38, 20),
		price_adder2  NUMERIC(38, 20)
	)

	INSERT INTO #tmp_term_vol
	  (
	    term_start,
	    term_end,
	    volume,
	    price,
	    price_adder,
	    price_adder2
	  )
	SELECT term_start,
	       term_end,
	       @volume,
	       @price,
	       @price_adder,
	       @price_adder2
	FROM   FNATermBreakdown(@frequency, @term_start, @term_end)
	
	
	IF @LaggingProcessTableName IS NOT NULL
	BEGIN
		SET @st='
				UPDATE #tmp_term_vol SET 
					volume =p.volume,
					price =p.price,
					price_adder =p.price_adder,
					price_adder2 =p.price_adder2
				FROM #tmp_term_vol t 
				INNER JOIN  '+ @LaggingProcessTableName +' p ON  t.term_start=p.term_start AND p.leg='+ cast(@leg as varchar) 
		exec spa_print @st
		EXEC(@st)
	END
	IF @flag = 's'  
	BEGIN
		SELECT @leg [leg],
		       [dbo].[FNADateFormat](term_start) AS [term_start],
		       [dbo].[FNADateFormat](term_end) AS [term_end],
		       dbo.FNARemoveTrailingZeroes(volume) AS [volume],
		       dbo.FNARemoveTrailingZeroes(price) AS [price],
		       dbo.FNARemoveTrailingZeroes(price_adder) AS [price_adder],
		       dbo.FNARemoveTrailingZeroes(price_adder2) AS [price_adder2]
		FROM   #tmp_term_vol
	END    
	 ELSE  
	 BEGIN
		SELECT @leg leg,
		       [dbo].[FNAStdDate](term_start),
		       [dbo].[FNAStdDate](term_end),
		       volume,
		       price,
		       price_adder,
		       price_adder2
		FROM   #tmp_term_vol
	END    
END  
ELSE IF @flag='u'
BEGIN
	BEGIN TRY


	CREATE TABLE #tmp_avg_vol(vol numeric(38,20),price numeric(38,20), price_adder numeric(38,20),price_adder2 numeric(38,20))
	
	IF @LaggingProcessTableName IS NULL
	BEGIN
		DECLARE @process_id VARCHAR(50),@user_name VARCHAR(50)
		
		set @process_id=REPLACE(newid(),'-','_')
		SET @user_name=dbo.FNADBUser()
		
		SET @LaggingProcessTableName = dbo.FNAProcessTableName('Lagging',@user_name, @process_id)
		
		EXEC(
			'CREATE TABLE '+ @LaggingProcessTableName +' (
				leg tinyint,
				term_start DATETIME,
				term_end DATETIME,
				volume VARCHAR(100),
				price VARCHAR(100),
				price_adder VARCHAR(100)
			,price_adder2 VARCHAR(100)
			)'
		)
	END

	
	
    SET @st='delete ' +@LaggingProcessTableName+' where leg='+CAST(@leg AS VARCHAR)   
	EXEC(@st)
	
    SET @st='
        DECLARE @idoc int
        EXEC sp_xml_preparedocument @idoc OUTPUT, ''' +@xml +'''
        insert INTO    ' + @LaggingProcessTableName + '
        SELECT  ' + cast(@leg as varchar) +' as Leg,CAST(dbo.FNACovertToSTDDate(term_start) AS DATETIME),CAST(dbo.FNACovertToSTDDate(term_end) AS DATETIME),Volume,price,price_adder,'+ CASE WHEN @price_adder2 IS NULL THEN 'NULL' ELSE CAST(@price_adder2 AS VARCHAR) END + '
        FROM    OPENXML (@idoc, ''/Root/PSRecordset'',2)
		WITH ( 
			term_start varchar(50) ''@term_start'', 
			term_end varchar(50) ''@term_end'',
			volume varchar(100) ''@volume'',
			price varchar(100) ''@price'',
			price_adder varchar(100) ''@price_adder''
	--		,price_adder2 varcahr(100) ''@price_adder2''
		);
                
              exec sp_xml_removedocument @idoc
                '
	exec spa_print @st
    EXEC(@st)


	EXEC('update '+@LaggingProcessTableName +' set volume = 0 where volume = ''NULL''')
	EXEC('update '+@LaggingProcessTableName +' set price = 0 where price = ''NULL''')
	EXEC('update '+@LaggingProcessTableName +' set price_adder = NULL where price_adder = ''NULL''')
	EXEC('update '+@LaggingProcessTableName +' set price_adder2 = NULL where price_adder2 = ''NULL''')

    SET @st='INSERT INTO #tmp_avg_vol(vol,price,price_adder,price_adder2) 
				select 
					avg(cast(volume as numeric(38,20))),
					avg(cast(price as numeric(38,20))),
					avg(cast(price_adder as numeric(38,20)))
					,avg(cast(price_adder2 as numeric(38,20)))  
				from ' +@LaggingProcessTableName+' where leg='+CAST(@leg AS VARCHAR)   
	EXEC spa_print @st
	EXEC(@st)

		
--        EXEC spa_ErrorHandler 0, 'Transportation',
--            'spa_schedule_n_delivery', 'Success',
--            'Successfully updated selected deal.',
--            @LaggingProcessTableName
	select 0, 'Transportation',
            'spa_schedule_n_delivery', 'Success',
            'Successfully updated selected deal.',
            @LaggingProcessTableName,
            dbo.FNARemoveTrailingZeroes(vol),
            dbo.FNARemoveTrailingZeroes(price),
            dbo.FNARemoveTrailingZeroes(price_adder) ,
            dbo.FNARemoveTrailingZeroes(price_adder2)
    FROM #tmp_avg_vol
    
    END TRY
    BEGIN CATCH
        DECLARE @err_no3 INT
        EXEC spa_print 'Catch Error'
        SELECT  @err_no3 = ERROR_NUMBER()
        EXEC spa_ErrorHandler @err_no3,
            'spa_lagging_month_volume',
            'spa_lagging_month_volume', 'Error',
            'Fail to create process table for lagging month.', ''
    END CATCH
END