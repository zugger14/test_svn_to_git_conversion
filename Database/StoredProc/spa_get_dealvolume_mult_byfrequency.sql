/****** Object:  StoredProcedure [dbo].[spa_get_dealvolume_mult_byfrequency]    Script Date: 12/15/2010 18:38:51 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_dealvolume_mult_byfrequency]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_dealvolume_mult_byfrequency]
/****** Object:  StoredProcedure [dbo].[spa_get_dealvolume_mult_byfrequency]    Script Date: 12/15/2010 18:38:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

exec spa_get_dealvolume_by_frequency '2009-01-01','2009-01-31','d'

*/

CREATE PROC [dbo].[spa_get_dealvolume_mult_byfrequency]
	@table_name VARCHAR(500)=NULL,
	@as_of_date VARCHAR(20)=NULL,
	@as_of_date_to VARCHAR(20)=NULL,
	@add_column CHAR(1)= 'y',
	@settlement_option CHAR(1)='c'

AS

BEGIN
	
	DECLARE @sql_stmt VARCHAR(MAX),		
			@dst_group_value_id INT

	SELECT @dst_group_value_id = tz.dst_group_value_id
	FROM dbo.adiha_default_codes_values adcv
		INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
	WHERE adcv.instance_no = 1
		AND adcv.default_code_id = 36
		AND adcv.seq_no = 1
			
IF @as_of_date IS NULL
	SET @as_of_date='1900-01-01'

IF @as_of_date_to IS NULL
	SET @as_of_date_to='9999-01-01'

----###### CREATE Temporary tables
	CREATE TABLE #temp_day(term_date DATETIME,weekdays INT,no_of_days INT)


-- Create index

	EXEC(@sql_stmt)

	DECLARE @date_add INT
	IF @settlement_option<>'f'
		SET @date_add=0
	ELSE IF @settlement_option='f'
		SET @date_add=1


	SET @sql_stmt='
	DECLARE @term_start DATETIME,@term_end DATETIME,@term_start_new DATETIME

	DECLARE cur10 CURSOR FOR
		SELECT DISTINCT 
				CASE WHEN '''+CONVERT(VARCHAR(7),@as_of_date,120)+'''=CONVERT(VARCHAR(7),term_start,120)  
					AND  '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=CONVERT(VARCHAR(10),term_start,120) 
				THEN '''+CAST(DATEADD(day,@date_add,@as_of_date) AS VARCHAR(20))+''' ELSE term_start END,
				CASE WHEN '''+CONVERT(VARCHAR(7),@as_of_date_to,120)+'''=CONVERT(VARCHAR(7),term_end,120)  
					AND  '''+CONVERT(VARCHAR(10),@as_of_date_to,120)+'''<CONVERT(VARCHAR(10),term_end,120) 
				THEN '''+CAST(DATEADD(day,0,@as_of_date_to) AS VARCHAR(20))+''' ELSE term_end END
		FROM '+@table_name+' WHERE deal_volume_frequency=''h'' and DATEDIFF(day,term_start,term_end)<>0
		OPEN cur10
		FETCH NEXT FROM cur10 INTO @term_start,@term_end
		WHILE @@FETCH_STATUS=0
			BEGIN
				SET @term_start_new=@term_start
				WHILE @term_start_new<=@term_end
					BEGIN
						INSERT INTO #temp_day(term_date,weekdays,no_of_days)
						SELECT @term_start_new,DATEPART(dw,@term_start_new),DATEDIFF(day,@term_start,@term_end)+1
							where @term_start_new not in(select term_date from #temp_day)

						SET @term_start_new=DATEADD(day,1,@term_start_new)	
					END
			FETCH NEXT FROM cur10 INTO @term_start,@term_end
			END
		CLOSE cur10
		DEALLOCATE cur10
	'
	--print @sql_stmt
	EXEC(@sql_stmt)



	IF @add_column='y'
		BEGIN
			SET @sql_stmt=' ALTER TABLE '+@table_name+' ADD Volume_Mult NUMERIC(38,20) '
			EXEC(@sql_stmt)
		END	

	SET @sql_stmt='
	UPDATE a
		SET a.Volume_Mult=ISNULL(b.VolumeMult,1)
	FROM
		'+@table_name+' a 
		LEFT JOIN
		(SELECT 
			tmp.term_start,
			tmp.term_end,
			tmp.deal_volume_frequency,
			tmp.block_type,
			tmp.block_definition_id,
			(CASE WHEN tmp.deal_volume_frequency=''h'' AND tmp.block_type IS NOT NULL THEN
					CASE WHEN  MAX(hb.onpeak_offpeak)=''p''  THEN CASE WHEN MAX(dst.insert_delete)=''d'' AND MAX(ISNULL(hb.dst_applies,''n''))=''y'' THEN -1 WHEN MAX(dst.insert_delete)=''i'' AND MAX(ISNULL(hb.dst_applies,''n''))=''y''  THEN 1 ELSE 0 END ELSE 0 END +
					SUM(
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr1,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr1,0) ELSE   hb.hr1 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr2,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr2,0) ELSE   hb.hr2 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr3,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr3,0) ELSE   hb.hr3 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr4,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr4,0) ELSE   hb.hr4 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr5,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr5,0) ELSE   hb.hr5 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr6,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr6,0) ELSE   hb.hr6 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr7,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr7,0) ELSE   hb.hr7 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr8,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr8,0) ELSE   hb.hr8 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr9,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr9,0) ELSE   hb.hr9 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr10,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr10,0) ELSE   hb.hr10 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr11,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr11,0) ELSE   hb.hr11 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr12,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr12,0) ELSE   hb.hr12 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr13,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr13,0) ELSE   hb.hr13 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr14,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr14,0) ELSE   hb.hr14 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr15,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr15,0) ELSE   hb.hr15 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr16,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr16,0) ELSE   hb.hr16 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr17,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr17,0) ELSE   hb.hr17 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr18,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr18,0) ELSE   hb.hr18 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr19,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr19,0) ELSE   hb.hr19 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr20,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr20,0) ELSE   hb.hr20 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr21,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr21,0) ELSE   hb.hr21 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr22,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr22,0) ELSE   hb.hr22 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr23,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN  ISNULL(hdb.hr23,0) ELSE   hb.hr23 END +
						CASE WHEN hb.onpeak_offpeak=''o'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr24,1) WHEN hb.onpeak_offpeak=''p'' AND ISNULL(hg.hol_date,'''')<>'''' THEN ISNULL(hdb.hr24,0)  ELSE  hb.hr24 END 
					) 
				WHEN tmp.deal_volume_frequency=''h'' AND tmp.block_type IS NULL THEN (datediff(hour,term_start,dateadd(DAY,1,term_end)))					
				WHEN tmp.deal_volume_frequency=''d''then 
					(datediff(day,CASE WHEN '''+@settlement_option+'''=''s'' THEN term_start
						WHEN '''+CONVERT(VARCHAR(7),@as_of_date,120)+'''=CONVERT(VARCHAR(7),term_start,120) AND  '''+CONVERT(VARCHAR(10),@as_of_date,120)+'''>=CONVERT(VARCHAR(10),term_start,120) THEN '''+CAST(DATEADD(day,@date_add,@as_of_date) AS VARCHAR(20))+'''  	
						ELSE term_start END,
					term_end )+1)
				
				ELSE 1 
			END)  AS VolumeMult
		
		FROM
			'+@table_name+' tmp 
			LEFT JOIN #temp_day td on td.term_date between tmp.term_start and tmp.term_end
			LEFT JOIN hourly_block hb on hb.block_value_id=tmp.block_definition_id
			and hb.week_day=ISNULL(td.weekdays,DATEPART(dw,tmp.term_start))
			AND  hb.onpeak_offpeak =case when tmp.block_type=12000 THEN ''p''
									when tmp.block_type=12001 THEN ''o''
					END
			LEFT JOIN mv90_DST dst on dst.[date]=td.term_date
				AND dst.dst_group_value_id = ' + CAST(@dst_group_value_id AS VARCHAR(20)) + '
			LEFT JOIN holiday_group hg ON hg.hol_group_value_Id=hb.holiday_value_id
				 AND ((tmp.term_start=hg.hol_date AND td.term_date IS NULL) OR (td.term_date=hg.hol_date))
			LEFT JOIN holiday_block hdb ON hdb.block_value_id=hb.block_value_id
				AND hb.onpeak_offpeak=hdb.onpeak_offpeak
				 
		where 1=1
			AND tmp.deal_volume_frequency IN(''d'',''h'')
		GROUP BY 
			tmp.term_end,tmp.term_start,tmp.deal_volume_frequency,tmp.block_type,tmp.block_definition_id
		) 
		b
		ON
			a.term_start=b.term_start AND
			a.term_end=b.term_end AND
			a.deal_volume_frequency=b.deal_volume_frequency AND
			ISNULL(a.block_type,-1)=ISNULL(b.block_type,-1) AND
			ISNULL(a.block_definition_id,-1)=ISNULL(b.block_definition_id,-1)
		'
	--print @sql_stmt
	EXEC(@sql_stmt)

END



