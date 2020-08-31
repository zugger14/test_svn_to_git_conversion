
IF OBJECT_ID('[dbo].[spa_mv90_data_hour]','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_mv90_data_hour]
GO
/*

exec spa_mv90_data_hour 35,980,'<Root><PSRecordset  edit_grid0="1" edit_grid1="02-05-2010" edit_grid2="1" edit_grid3="2" 
edit_grid4="2"></PSRecordset><PSRecordset  edit_grid0="2" edit_grid1="09-05-2010" edit_grid2="1" edit_grid3="" edit_grid4=""></PSRecordset><PSRecordset  edit_grid0="3" 
edit_grid1="16-05-2010" edit_grid2="1" edit_grid3="" edit_grid4=""></PSRecordset><PSRecordset  edit_grid0="4" edit_grid1="23-05-2010" edit_grid2="1" edit_grid3="" 
edit_grid4=""></PSRecordset><PSRecordset  edit_grid0="5" edit_grid1="30-05-2010" edit_grid2="1" edit_grid3="" edit_grid4=""></PSRecordset></Root>'


*/


CREATE PROCEDURE [dbo].[spa_mv90_data_hour] 
	@source_deal_detail_id int,
	@granularity_id int,
	@xml_st  varchar(max)
AS

--DECLARE @source_deal_detail_id int,@as_of_date datetime,@granularity_id int,@xml_st  varchar(max)
--set @source_deal_detail_id = 8434
--set @granularity_id=987
--set @as_of_date ='2009-03-01' 
--set @xml_st='<?xml version="1.0"?>
--	<rows>
--			<row id="0">
--					<cell id="0">01/01/2009</cell>
--						<cell id="1">1_15</cell>
--								<cell id="2">1</cell>
--									<cell id="3">20</cell>
--							</row>
--					<row id="1"><cell id="0">01/01/2009</cell><cell id="1">1_30</cell><cell id="2">2</cell><cell id="3">40</cell></row><row id="2"><cell id="0">01/01/2009</cell><cell id="1">1_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="3"><cell id="0">01/01/2009</cell><cell id="1">1_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="4"><cell id="0">01/01/2009</cell><cell id="1">2_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="5"><cell id="0">01/01/2009</cell><cell id="1">2_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="6"><cell id="0">01/01/2009</cell><cell id="1">2_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="7"><cell id="0">01/01/2009</cell><cell id="1">2_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="8"><cell id="0">01/01/2009</cell><cell id="1">3_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="9"><cell id="0">01/01/2009</cell><cell id="1">3_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="10"><cell id="0">01/01/2009</cell><cell id="1">3_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="11"><cell id="0">01/01/2009</cell><cell id="1">3_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="12"><cell id="0">01/01/2009</cell><cell id="1">4_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="13"><cell id="0">01/01/2009</cell><cell id="1">4_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="14"><cell id="0">01/01/2009</cell><cell id="1">4_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="15"><cell id="0">01/01/2009</cell><cell id="1">4_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="16"><cell id="0">01/01/2009</cell><cell id="1">5_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="17"><cell id="0">01/01/2009</cell><cell id="1">5_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="18"><cell id="0">01/01/2009</cell><cell id="1">5_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="19"><cell id="0">01/01/2009</cell><cell id="1">5_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="20"><cell id="0">01/01/2009</cell><cell id="1">6_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="21"><cell id="0">01/01/2009</cell><cell id="1">6_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="22"><cell id="0">01/01/2009</cell><cell id="1">6_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="23"><cell id="0">01/01/2009</cell><cell id="1">6_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="24"><cell id="0">01/01/2009</cell><cell id="1">7_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="25"><cell id="0">01/01/2009</cell><cell id="1">7_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="26"><cell id="0">01/01/2009</cell><cell id="1">7_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="27"><cell id="0">01/01/2009</cell><cell id="1">7_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="28"><cell id="0">01/01/2009</cell><cell id="1">8_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="29"><cell id="0">01/01/2009</cell><cell id="1">8_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="30"><cell id="0">01/01/2009</cell><cell id="1">8_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="31"><cell id="0">01/01/2009</cell><cell id="1">8_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="32"><cell id="0">01/01/2009</cell><cell id="1">9_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="33"><cell id="0">01/01/2009</cell><cell id="1">9_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="34"><cell id="0">01/01/2009</cell><cell id="1">9_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="35"><cell id="0">01/01/2009</cell><cell id="1">9_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="36"><cell id="0">01/01/2009</cell><cell id="1">10_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="37"><cell id="0">01/01/2009</cell><cell id="1">10_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="38"><cell id="0">01/01/2009</cell><cell id="1">10_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="39"><cell id="0">01/01/2009</cell><cell id="1">10_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="40"><cell id="0">01/01/2009</cell><cell id="1">11_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="41"><cell id="0">01/01/2009</cell><cell id="1">11_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="42"><cell id="0">01/01/2009</cell><cell id="1">11_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="43"><cell id="0">01/01/2009</cell><cell id="1">11_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="44"><cell id="0">01/01/2009</cell><cell id="1">12_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="45"><cell id="0">01/01/2009</cell><cell id="1">12_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="46"><cell id="0">01/01/2009</cell><cell id="1">12_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="47"><cell id="0">01/01/2009</cell><cell id="1">12_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="48"><cell id="0">01/01/2009</cell><cell id="1">13_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="49"><cell id="0">01/01/2009</cell><cell id="1">13_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="50"><cell id="0">01/01/2009</cell><cell id="1">13_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="51"><cell id="0">01/01/2009</cell><cell id="1">13_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="52"><cell id="0">01/01/2009</cell><cell id="1">14_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="53"><cell id="0">01/01/2009</cell><cell id="1">14_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="54"><cell id="0">01/01/2009</cell><cell id="1">14_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="55"><cell id="0">01/01/2009</cell><cell id="1">14_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="56"><cell id="0">01/01/2009</cell><cell id="1">15_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="57"><cell id="0">01/01/2009</cell><cell id="1">15_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="58"><cell id="0">01/01/2009</cell><cell id="1">15_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="59"><cell id="0">01/01/2009</cell><cell id="1">15_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="60"><cell id="0">01/01/2009</cell><cell id="1">16_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="61"><cell id="0">01/01/2009</cell><cell id="1">16_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="62"><cell id="0">01/01/2009</cell><cell id="1">16_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="63"><cell id="0">01/01/2009</cell><cell id="1">16_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="64"><cell id="0">01/01/2009</cell><cell id="1">17_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="65"><cell id="0">01/01/2009</cell><cell id="1">17_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="66"><cell id="0">01/01/2009</cell><cell id="1">17_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="67"><cell id="0">01/01/2009</cell><cell id="1">17_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="68"><cell id="0">01/01/2009</cell><cell id="1">18_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="69"><cell id="0">01/01/2009</cell><cell id="1">18_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="70"><cell id="0">01/01/2009</cell><cell id="1">18_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="71"><cell id="0">01/01/2009</cell><cell id="1">18_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="72"><cell id="0">01/01/2009</cell><cell id="1">19_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="73"><cell id="0">01/01/2009</cell><cell id="1">19_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="74"><cell id="0">01/01/2009</cell><cell id="1">19_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="75"><cell id="0">01/01/2009</cell><cell id="1">19_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="76"><cell id="0">01/01/2009</cell><cell id="1">20_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="77"><cell id="0">01/01/2009</cell><cell id="1">20_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="78"><cell id="0">01/01/2009</cell><cell id="1">20_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="79"><cell id="0">01/01/2009</cell><cell id="1">20_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="80"><cell id="0">01/01/2009</cell><cell id="1">21_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="81"><cell id="0">01/01/2009</cell><cell id="1">21_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="82"><cell id="0">01/01/2009</cell><cell id="1">21_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="83"><cell id="0">01/01/2009</cell><cell id="1">21_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="84"><cell id="0">01/01/2009</cell><cell id="1">22_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="85"><cell id="0">01/01/2009</cell><cell id="1">22_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="86"><cell id="0">01/01/2009</cell><cell id="1">22_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="87"><cell id="0">01/01/2009</cell><cell id="1">22_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="88"><cell id="0">01/01/2009</cell><cell id="1">23_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="89"><cell id="0">01/01/2009</cell><cell id="1">23_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="90"><cell id="0">01/01/2009</cell><cell id="1">23_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="91"><cell id="0">01/01/2009</cell><cell id="1">23_60</cell><cell id="2"></cell><cell id="3"></cell></row><row id="92"><cell id="0">01/01/2009</cell><cell id="1">24_15</cell><cell id="2"></cell><cell id="3"></cell></row><row id="93"><cell id="0">01/01/2009</cell><cell id="1">24_30</cell><cell id="2"></cell><cell id="3"></cell></row><row id="94"><cell id="0">01/01/2009</cell><cell id="1">24_45</cell><cell id="2"></cell><cell id="3"></cell></row><row id="95"><cell id="0">01/01/2009</cell><cell id="1">24_60</cell><cell id="2"></cell><cell id="3"></cell></row></rows>'
--SET @as_of_date=getdate()

--*/

DECLARE @list_fields varchar(1000),@sql varchar(max),@st_tbl varchar(128)
declare  @vol float, @price float
SET @list_fields=''
--drop table #tmpqqq
--CREATE TABLE #tmpqqq (Row_no int,term_start varchar(30) COLLATE DATABASE_DEFAULT,Hrs varchar(10) COLLATE DATABASE_DEFAULT,Volume float,Price float)
BEGIN TRY
	DECLARE @user_login_id VARCHAR(50),
			@process_id VARCHAR(50),
			@table_name VARCHAR(128)

		set @st_tbl='dbo.mv90_data_hour'
		SET @process_id=''
		SET @user_login_id=dbo.FNAdbuser()
		
	--	INSERT INTO #tmpqqq EXEC spa_xml_2_table_clm @xml_st 

	DECLARE @idoc INT 
	EXEC sp_xml_preparedocument @idoc OUTPUT,@xml_st

	SELECT 
		Row_no,
		dbo.FNAStdDate(term_start) as term_start,
		Hrs,
		Volume,
		Price 
	INTO #tmpqqq
	FROM OPENXML(@idoc,'/Root/PSRecordset',2)
	WITH (
		Row_no int				'@edit_grid0',
		term_start VARCHAR(50)	'@edit_grid1',
		Hrs VARCHAR(10)			'@edit_grid2',
		Volume FLOAT			'@edit_grid3',
		Price FLOAT				'@edit_grid4'
	)



	if @granularity_id=987 or @granularity_id=989 
		set @st_tbl='dbo.mv90_data_mins'


	IF @source_deal_detail_id IS NULL
	BEGIN
		set @process_id=REPLACE(newid(),'-','')
		set @table_name=dbo.FNAProcessTableName('hourly_table', @user_login_id,@process_id)	

		EXEC('SELECT * INTO '+@table_name+' FROM '+@st_tbl)
		EXEC('SELECT * INTO '+@table_name+'_price FROM '+ @st_tbl + '_price')

		SET @st_tbl=@table_name
		SET @source_deal_detail_id=-1
	END

	UPDATE #tmpqqq SET hrs ='Hr'+hrs
	SELECT @list_fields=@list_fields + Hrs +',' FROM #tmpqqq GROUP BY Hrs
	SET @list_fields=left(@list_fields,len(@list_fields)-1)
	EXEC spa_print @list_fields

	BEGIN TRAN
		set @sql='DELETE ' + @st_tbl + ' WHERE source_deal_header_id=' + cast(@source_deal_detail_id as varchar)
		exec(@sql)

		SET @sql='
		INSERT INTO ' + @st_tbl + ' ([prod_date],source_deal_header_id,' + @list_fields +')
		SELECT term_start,' + cast (@source_deal_detail_id AS vARCHAR) + ' AS SDH_ID,' + @list_fields + '
		FROM 
		(
		select term_start,Hrs,volume from #tmpqqq
		) p
		PIVOT
		(
		max(volume)
		FOR hrs IN
		( ' + @list_fields + ' )
		) AS pvt
		'
		EXEC spa_print @sql
		EXEC(@sql)

		set @sql='DELETE ' + @st_tbl + '_price WHERE source_deal_header_id=' + cast(@source_deal_detail_id as varchar)
		exec(@sql)

		SET @sql='
		INSERT INTO ' + @st_tbl + '_price ([prod_date],source_deal_header_id,' + @list_fields +')
		SELECT term_start,' + cast (@source_deal_detail_id AS vARCHAR) + ' AS SDH_ID,' + @list_fields + '
		FROM 
		(
		select term_start,Hrs,price from #tmpqqq
		) p
		PIVOT
		(
		max(price)
		FOR hrs IN
		( ' + @list_fields + ' )
		) AS pvt
		'
		EXEC spa_print @sql
		EXEC(@sql)
		
		select  @vol=sum(volume),@price =sum(price) from  #tmpqqq

		
		-- calculate the WACO fo the deal
	--	select @price=((@vol*@price)/sum(volume*price))*sum(price) from #tmpqqq
		select @price=(sum(volume*price)/ISNULL(NULLIF((@vol*@price),0),1)) *sum(price) from #tmpqqq

		update source_deal_detail set deal_volume=@vol,fixed_price=@price  where source_deal_detail_id=@source_deal_detail_id

	COMMIT TRAN

	Exec spa_ErrorHandler 0, 'mv90_data_hour table', 
					'spa_mv90_data_hour', 'Success', 
					'Data Successfully Updated.', @process_id
	--

END TRY
BEGIN CATCH
	EXEC spa_print 'Catch Error'
	if @@TRANCOUNT>0
		ROLLBACK TRAN

		DECLARE @error_num int,@error_msg varchar(1000)
		SELECT @error_num= error_number(),@error_msg=error_message()

		Exec spa_ErrorHandler @error_num, 'mv90_data_hour table', 
					'spa_mv90_data_hour', 'DB Error', 
					'Fail Update Data.', ''

END CATCH

