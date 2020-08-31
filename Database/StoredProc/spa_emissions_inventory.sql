/****** Object:  StoredProcedure [dbo].[spa_emissions_inventory]    Script Date: 04/05/2009 20:39:25 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_emissions_inventory]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_emissions_inventory]
/****** Object:  StoredProcedure [dbo].[spa_emissions_inventory]    Script Date: 04/05/2009 20:39:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec spa_emissions_inventory 'd','1057035' ,'2000-07-01', '2000-07-01','2000-12-31', 3386, null, NULL, NULL, NULL, NULL, NULL, NULL,NULL


CREATE PROCEDURE [dbo].[spa_emissions_inventory]
@flag char(1),
@detail_id varchar(MAX),
@as_of_date varchar(20)=null,
@term_start varchar(20)=null,
@term_end varchar(20)=null,
@generator_id int=null,
@frequency int=null,
@curve_id int=null,
@volume float=null,
@uom_id int=null,
@calculated varchar(1)=null,
@current_forecast varchar(1)=null,
@fas_book_id varchar(500)=null,
@series_type int=NULL,
@sub_entity_id varchar(100)=null,
@strategy_entity_id varchar(100)=NULL

AS
declare @st varchar(MAX),@ems_calc_detail_value VARCHAR(100),@st_tbl VARCHAR(max)
EXEC spa_print '@term_start:', @term_start
EXEC spa_print '@term_end:', @term_end
SET   @st_tbl=[dbo].[FNAGetProcessTableSQL]('ems_calc_detail_value',@term_start,@term_end,@sub_entity_id,'n',NULL,NULL)

set @ems_calc_detail_value=dbo.FNAGetProcessTableName(@term_start, 'ems_calc_detail_value')
--ems_calc_detail_value
--emissions_inventory
if @flag='s' 
BEGIN

set @st='
select [detail_id] ID, dbo.FNADateFormat(as_of_date) as [As of Date], 
	dbo.FNADateFormat(term_start) as [Term Start], dbo.FNADateFormat(term_end) as [Term End], 
	series_type.code [Series],
	fuel_type.code [FuelType],
	cu.curve_name Emissions, volume as [Value], uom_name UOM, 
	case current_forecast when ''t'' then ''Target Emission'' 
		 when ''f'' then ''Forecast Emissions'' 
		 when ''r'' then ''Reporting Emissions'' 
		else ''''
	end Type
	from ems_calc_detail_value i 
	inner join (select ISNULL(year(max(as_of_date)),0) yr from ems_close_archived_year ) c
	on year(i.term_start)>isnull(c.yr,'''')
	left outer join rec_generator rg
	on i.generator_id=rg.generator_id left join source_uom uom on i.uom_id=uom.source_uom_id
	 left join static_data_value st on i.frequency=st.value_id 
	 left join source_price_curve_def cu on i.curve_id=cu.source_curve_def_id
	left join static_data_value fuel_type on fuel_type.value_id=i.fuel_type_value_id
	left join static_data_value series_type on series_type.value_id=i.forecast_type
	where 1=1'
+case when @series_type is not null then ' And i.forecast_type='+cast(@series_type as varchar) else '' end
if @current_forecast is not null
	set @st=@st +' and current_forecast='''+@current_forecast+''''

IF @term_start IS NOT NULL
	SET @st = @st + ' and term_start >= ''' + @term_start + ''' AND term_end >= ''' + @term_start + ''''

IF @term_end IS NOT NULL
	SET @st = @st + ' and term_start <= ''' + @term_end + ''' AND term_end <= ''' + @term_end + ''''
	
--if @term_end is not null and  @term_start is not null
--	set @st=@st +' and  (term_start between '''+@term_start+''' and '''+@term_end+'''
--			or  term_end between '''+@term_start+''' and '''+@term_end+''')'
if @fas_book_id is not null
	set @st=@st +' and i.fas_book_id in ('+@fas_book_id+')'
if @generator_id is not null
	set @st=@st +' and i.generator_id='+cast(@generator_id as varchar)
if @as_of_date is not null
	set @st=@st +' and as_of_date='''+@as_of_date+''''
EXEC spa_print @st
exec (@st)

END

if @flag='b' -- call from emissions Target to display data in grid
begin

SET @st = ''            
CREATE TABLE #ssbm(                      
 fas_book_id int,            
 stra_book_id int,            
 sub_entity_id int            
)            

CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  

----------------------------------            
SET @st=            
		'INSERT INTO #ssbm            
		SELECT                      
		  book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
		FROM            
		 portfolio_hierarchy book (nolock)             
		INNER JOIN            
		 Portfolio_hierarchy stra (nolock)            
		 ON            
		  book.parent_entity_id = stra.entity_id               
		WHERE 1=1 '            

IF @sub_entity_id IS NOT NULL            
	SET @st = @st + ' AND stra.parent_entity_id IN  ( ' + CAST(@sub_entity_id AS VARCHAR(500)) + ') '             
 IF @strategy_entity_id IS NOT NULL            
	SET @st = @st + ' AND (stra.entity_id IN(' + CAST(@strategy_entity_id AS VARCHAR(500)) + ' ))'            
  IF @fas_book_id IS NOT NULL            
	SET @st = @st + ' AND (book.entity_id IN(' + @fas_book_id + ')) '            

EXEC (@st)         


set @st='select detail_id ID, 
	rg.name [Source],rg.[ID] [Facility ID], 
	rg.id2 [Unit],
	dbo.FNADateFormat(term_start) as [Term Start], dbo.FNADateFormat(term_end) as [Term End], 
	cu.curve_name Emissions, volume as [Value], uom_name UOM, series_type.code [Series Type],
	case current_forecast when ''t'' then ''Target Emission'' 
		 when ''f'' then ''Forecast Emissions'' 
		 when ''r'' then ''Reporting Emissions'' 
		else ''''
	end Type
	from (' + @st_tbl + ')  i 
	inner join #ssbm on i.fas_book_id=#ssbm.fas_book_id
	left outer join rec_generator rg
	on i.generator_id=rg.generator_id left join source_uom uom on i.uom_id=uom.source_uom_id
	left join static_data_value st on i.frequency=st.value_id left join source_price_curve_def cu on i.curve_id=cu.source_curve_def_id
	left join static_data_value fuel_type on fuel_type.value_id=i.fuel_type_value_id
	left join static_data_value series_type on series_type.value_id=i.forecast_type
	where 1=1'
+case when @series_type is not null then ' And i.forecast_type='+cast(@series_type as varchar) else '' end
if @current_forecast is not null
	set @st=@st +' and current_forecast='''+@current_forecast+''''
if @term_end is not null and  @term_start is not null
	set @st=@st +' and  (term_start between '''+@term_start+''' and '''+@term_end+'''
			or  term_end between '''+@term_start+''' and '''+@term_end+''')'
if @fas_book_id is not null
	set @st=@st +' and i.fas_book_id in ('+@fas_book_id+')'
if @generator_id is not null
	set @st=@st +' and i.generator_id='+cast(@generator_id as varchar)
if @as_of_date is not null
	set @st=@st +' and as_of_date='''+@as_of_date+''''

exec (@st)
END

else if @flag='a' 
begin
	select detail_id, dbo.FNADateFormat(as_of_date),
	 dbo.FNADateFormat(term_start), dbo.FNADateFormat(term_end), 
	 generator_id, frequency, curve_id, volume, uom_id,null calculated, 
	 current_forecast,fas_book_id,forecast_type
	from ems_calc_detail_value
	where detail_id=@detail_id

END
else if @flag='t' --This is called from Maintain Emissions Input/Output data detail
begin
	select detail_id, dbo.FNADateFormat(as_of_date), dbo.FNADateFormat(term_start), dbo.FNADateFormat(term_end), generator_id, frequency, curve_id, volume, uom_id, 
	null calculated, current_forecast,fas_book_id
	from ems_calc_detail_value
	where term_start=@term_start and term_end=@term_end and generator_id=@generator_id and curve_id=@curve_id
END
else if @flag='m' --This is called from Maintain Target Emissions in Type combo box for filtering
begin
	select 't' code,'Target Emissions' Description
	union  
	select 'f','Forecast Emissions'
	union
	select 'r','Reporting Emissions'

END
else if @flag='n' --This is called from Maintain Target Emissions UI in Emissions Sources/Sink combo box
begin
	select generator_id,[name] from rec_generator
END
else if @flag='i'
BEGIN

	IF EXISTS(
			SELECT stra.entity_id FROM  Rec_generator rg 
			INNER JOIN portfolio_hierarchy book ON book.entity_id =rg.fas_book_id 
			AND rg.generator_id=@generator_id
			INNER JOIN portfolio_hierarchy stra ON stra.entity_id =book.parent_entity_id
			INNER JOIN ems_publish_report epr 
			ON YEAR(epr.as_of_date)>=year(@term_start)
			AND (
					epr.book_entity_id=rg.fas_book_id 
					OR epr.strategy_entity_id=stra.entity_id
					OR epr.sub_id=stra.parent_entity_id
				 )
		)
	BEGIN
		select 'Error', 'Error on Inserting Emissions Inventory(The term start year is already published).', 
							'spa_emissions_inventory', 'DB Error', 
						'Error on Inserting Emissions Inventory(The term start year is already published).', ''
					return
	END

	IF EXISTS(select *  from process_table_location WHERE tbl_name='ems_calc_detail_value' AND ISNULL(prefix_location_table,'')<>'' AND as_of_date>=@term_start)
	BEGIN
		select 'Error', 'Error on Inserting Emissions Inventory(The term start year is already archived).', 
							'spa_emissions_inventory', 'DB Error', 
						'Error on Inserting Emissions Inventory(The term start year is already archived).', ''
					return
	END
--	SELECT * FROM dbo.ems_calc_detail_value WHERE value_id=14302
	INSERT  into ems_calc_detail_value(
			as_of_date,
			term_start,
			term_end,
			generator_id,
			frequency,
			curve_id,
			volume,
			uom_id,
		--	calculated,
			current_forecast,
			fas_book_id,
			forecast_type
	)
	VALUES 	(
			@as_of_date,
			@term_start,
			@term_end,
			@generator_id,
			@frequency,
			@curve_id,
			@volume,
			@uom_id,
			 -- @calculated,
			ISNULL(@current_forecast,'r'),
			@fas_book_id,
			@series_type

	)
		If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Error on Inserting Emissions Inventory.", 
						"spa_emissions_inventory", "DB Error", 
					"Error on Inserting Emissions Inventory.", ''
			else
				Exec spa_ErrorHandler 0, 'ems_calc_detail_value', 
						'spa_emissions_inventory', 'Success', 
						'Emissions Inventory successfully inserted.', ''
END
else if @flag='u'
BEGIN
	IF EXISTS(SELECT stra.entity_id FROM  Rec_generator rg 
		INNER JOIN portfolio_hierarchy book ON book.entity_id =rg.fas_book_id AND rg.generator_id=@generator_id
		INNER JOIN portfolio_hierarchy stra ON stra.entity_id =book.parent_entity_id
		INNER JOIN ems_publish_report epr 
		ON YEAR(epr.as_of_date)>=year(@term_start)
		AND (
		epr.book_entity_id=rg.fas_book_id 
		OR epr.strategy_entity_id=stra.entity_id
		OR epr.sub_id=stra.parent_entity_id )
		)
	BEGIN
		select 'Error', 'Error on Updating Emissions Inventory(The term start year is already published).', 
							'spa_emissions_inventory', 'DB Error', 
						'Error on Updating Emissions Inventory(The term start year is already published).', ''
					return
	END

	IF EXISTS(select *  from process_table_location WHERE tbl_name='ems_calc_detail_value' AND ISNULL(prefix_location_table,'')<>'' AND as_of_date>=@term_start)
	BEGIN
		select 'Error', 'Error on Inserting Emissions Inventory(The term start year is already archived).', 
							'spa_emissions_inventory', 'DB Error', 
						'Error on Inserting Emissions Inventory(The term start year is already archived).', ''
					return
	END
	set @st=ISNULL(dbo.[FNAGetProcessTableName] (@term_start,'ems_calc_detail_value'),'ems_calc_detail_value')
	SET @st='
		UPDATE	ems_calc_detail_value
			set as_of_date=''' + CAST(@as_of_date AS VARCHAR) +''',
			term_start=''' + CAST(@term_start AS VARCHAR) +''',
			term_end=''' + CAST(@term_end AS VARCHAR) +''',
			generator_id=' + CAST(@generator_id AS VARCHAR) +',
			frequency='''+CAST(@frequency AS VARCHAR)+''',
			curve_id=' + CAST(@curve_id AS VARCHAR) +',
			volume=' + CAST(@volume AS VARCHAR) +',
			uom_id=' + CAST(@uom_id AS VARCHAR) +',
			--calculated='''+@calculated +''',
		--	current_forecast='''+ISNULL(@current_forecast,'r')+''',
			fas_book_id='''+ISNULL(@fas_book_id,'')+''',
			forecast_type='+cast(@series_type as varchar)+'
			where detail_id='+@detail_id
	exec spa_print @st
	exec(@st)
	If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Emissions Inventory", 
					"spa_emissions_inventory", "DB Error", 
				"Error on updating Emissions Inventory.", ''
		else
			Exec spa_ErrorHandler 0, 'Emissions Inventory', 
					'spa_emissions_inventory', 'Success', 
					'Emissions Inventory successfully updated.', ''
END
else if @flag='d'
BEGIN
BEGIN try
	CREATE TABLE #pub_year_data(id INT)
	declare @st1 varchar(max)
	set @st1='
		INSERT INTO #pub_year_data(id )
		SELECT  ei.detail_id
		 FROM  ('+@st_tbl+ ') ei  inner join (select ISNULL(year(max(as_of_date)),0) yr from ems_close_archived_year ) c
		on year(term_start)<=c.yr
		where  ei.detail_id IN ( ' + @detail_id  +')'
	exec spa_print @st1		
	EXEC(@st1)

	set @st1='
		INSERT INTO #pub_year_data(id )
		SELECT  ei.detail_id
		 FROM  Rec_generator rg 
			INNER JOIN ('+@st_tbl+ ') ei ON ei.detail_id IN ( ' + @detail_id  +')
			AND  ei.generator_id=rg.generator_id
			INNER JOIN portfolio_hierarchy book ON book.entity_id =rg.fas_book_id 
			INNER JOIN portfolio_hierarchy stra ON stra.entity_id =book.parent_entity_id
			INNER JOIN portfolio_hierarchy sub ON stra.parent_entity_id =sub.entity_id
			INNER JOIN ems_publish_report epr 
			ON YEAR(epr.as_of_date)>=year(ei.term_start)
			AND (
			epr.book_entity_id=rg.fas_book_id 
			OR epr.strategy_entity_id=stra.entity_id
			OR epr.sub_id=stra.parent_entity_id )'

	exec spa_print @st1		
	EXEC(@st1)

	BEGIN tran
		CREATE TABLE #filter_ids(id INT)
		INSERT INTO #filter_ids ( id ) 
		SELECT Item from dbo.SplitCommaSeperatedValues(@detail_id) f
		LEFT JOIN #pub_year_data p ON CAST(f.Item AS INT)=p.id WHERE p.id IS null
	
	set @st1='
		delete calc_formula_value from calc_formula_value d inner join 
		ems_calc_detail_value m on m.generator_id=d.generator_id and d.prod_date=m.term_start
		inner join #filter_ids f on m.detail_id=f.id  ;

		delete calc_formula_value from calc_formula_value d inner join 
		ems_calc_detail_value_arch1 m on m.generator_id=d.generator_id and d.prod_date=m.term_start
		inner join #filter_ids f on m.detail_id=f.id  ;

		delete calc_formula_value from calc_formula_value d inner join 
		ems_calc_detail_value_arch2 m on m.generator_id=d.generator_id and d.prod_date=m.term_start
		inner join #filter_ids f on m.detail_id=f.id  ;

		delete ems_calc_detail_value  from ems_calc_detail_value m
		inner join #filter_ids f on m.detail_id=f.id;
		
		delete ems_calc_detail_value_arch1 from ems_calc_detail_value_arch1 m
		inner join #filter_ids f on m.detail_id=f.id;
		
		delete ems_calc_detail_value_arch2 from ems_calc_detail_value_arch2 m
		inner join #filter_ids f on m.detail_id=f.id;
	'
		
	exec spa_print @st1		
	EXEC(@st1)
	IF EXISTS(SELECT 1 FROM #pub_year_data)
		select 'Error', 'Some term start year is found published/archived (Published/Archived year data are NOT deleted).', 
							'spa_emissions_inventory', 'DB Error', 
						'Some term start year is found published/archived (Published/Archived year data are NOT deleted).', ''
	else
		SELECT  'Success', 'Emissions Inventory', 
					'spa_emissions_inventory', 'Success', 
					'Emissions Inventory successfully deleted.', ''
		
	COMMIT
		
END TRY
BEGIN CATCH
	rollback tran

	DECLARE @ERROR_msg VARCHAR(250)
	SET @ERROR_msg =ERROR_message()
			SELECT  'Error', @ERROR_msg, 
					'spa_emissions_inventory', 'DB Error', 
				@ERROR_msg, ''
		
END CATCH
end














