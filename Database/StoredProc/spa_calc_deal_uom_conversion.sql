IF OBJECT_ID('spa_calc_deal_uom_conversion') IS NOT NULL
drop proc dbo.spa_calc_deal_uom_conversion

GO


create proc [dbo].[spa_calc_deal_uom_conversion] (
	@sub varchar(500)=null,
	@str varchar(500)=null,
	@book varchar(500)=null,
	@deal_header_ids varchar(max)=null,
	@user_login_id varchar(30)=null,
	@process_id varchar(50)=null
)

as 


/*

--EXEC [dbo].[spa_calc_deal_uom_conversion] @sub=null,@str=null,@book=null,@deal_header_ids=null, @user_login_id='farrms_admin',@process_id='87C95A3F_5D12_470F_AAF4_A74EEF439CDF'
declare
@sub varchar(500),
@str varchar(500),
@book varchar(500),
@deal_header_ids varchar(max)=3159,@user_login_id varchar(30)='farrms_admin',
@process_id varchar(30)=null

/*

 select * from source_uom
 update source_uom set uom_type='v' where source_uom_id= 73

*/


if object_id('tempdb..#deal_header_ids') is not null
	drop table #deal_header_ids

if object_id('tempdb..#density_multiplier') is not null 
	drop table #density_multiplier

if object_id('tempdb..#volumetric_uom') is not null 
	drop table #volumetric_uom

if object_id('tempdb..#mass_uom') is not null 
	drop table #mass_uom

if object_id('tempdb..#uom_combination') is not null 
	drop table #uom_combination

if object_id('tempdb..#deal_uom_conversion') is not null 
	drop table #deal_uom_conversion

if object_id('tempdb..#book') is not null 
	drop table #book

--*/


/*

select * from #deal_header_ids
select * from  #density_multiplier
select * from user_defined_deal_fields_template uddft where uddft.Field_label in('Density','UOM Conversion')

*/
declare  @st varchar(max),@effected_deals  VARCHAR(130)
declare @from_uom_id int,@to_uom_id int


CREATE TABLE #volumetric_uom (id INT) 	
CREATE TABLE #mass_uom (id INT) 	
CREATE TABLE #deal_header_ids (source_deal_header_id INT) 
CREATE TABLE #density_multiplier (source_deal_detail_id int,from_uom_id int,to_uom_id int,density_mult numeric(21,16))
CREATE TABLE #uom_combination (from_id INT,to_id INT) 
EXEC spa_print @process_id


set @user_login_id=isnull(@user_login_id,dbo.fnadbuser())
SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

insert into #volumetric_uom(id)
	values (73),(75)

insert into #mass_uom(id)
	values (74),(90),(88)

if @deal_header_ids is not null
	INSERT INTO #deal_header_ids SELECT CAST(Item AS INT) FROM dbo.SplitCommaSeperatedValues(@deal_header_ids)
else 
begin
	create table #book (book_id int,book_deal_type_map_id int,source_system_book_id1 int,source_system_book_id2 int,source_system_book_id3 int,source_system_book_id4 int,func_cur_id INT)		
	
	SET @st='insert into #book (book_id,book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4,func_cur_id )		
		select book.entity_id, book_deal_type_map_id ,source_system_book_id1 ,source_system_book_id2 ,source_system_book_id3 ,source_system_book_id4 ,fs.func_cur_value_id
		from source_system_book_map sbm            
			INNER JOIN  portfolio_hierarchy book (NOLOCK) ON book.entity_id=sbm.fas_book_id
			INNER JOIN  Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id 
			INNER JOIN  Portfolio_hierarchy sb (NOLOCK) ON stra.parent_entity_id = sb.entity_id 
			left join fas_subsidiaries fs on sb.entity_id=fs.fas_subsidiary_id
		WHERE 1=1  '
			+CASE WHEN  @sub IS NULL THEN '' ELSE ' and sb.entity_id in ('+@sub+')' END
			+CASE WHEN  @str IS NULL THEN '' ELSE ' and stra.entity_id in ('+@str+')' END
			+CASE WHEN  @book IS NULL THEN '' ELSE ' and book.entity_id in ('+@book+')' END		
		
	exec(@st)

	if @process_id is null
		INSERT INTO #deal_header_ids (source_deal_header_id)
		SELECT dh.source_deal_header_id FROM source_deal_header dh
			INNER JOIN #book sbm ON dh.source_system_book_id1 = sbm.source_system_book_id1 AND 
				dh.source_system_book_id2 = sbm.source_system_book_id2 AND dh.source_system_book_id3 = sbm.source_system_book_id3 AND 
				dh.source_system_book_id4 = sbm.source_system_book_id4
	else
	begin
		SET @st='INSERT INTO #deal_header_ids (source_deal_header_id)
			SELECT source_deal_header_id FROM ' + @effected_deals

		exec spa_print @st
		exec(@st)

	end 
end
	



delete dbo.deal_uom_conversion_factor
from dbo.deal_uom_conversion_factor a inner join source_deal_detail duc
	on a.source_deal_detail_id=duc.source_deal_detail_id
	inner join #deal_header_ids dhi on dhi.source_deal_header_id=duc.source_deal_header_id

select distinct sdd.source_deal_detail_id,isnull(mul.from_uom_id,su_from.source_uom_id) from_uom_id ,coalesce(den.con_UOM_id,mul.to_uom_id,su_to.source_uom_id) to_uom_id
, coalesce(den.UOM_Conversion,mul.density_mult,1)* (1.00/isnull(den.UOM_Conversion_div,1))  density_mult
into #deal_uom_conversion
  from #deal_header_ids sdh 
	inner join source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
	left join source_price_curve_Def spcd on spcd.source_curve_def_id=sdd.curve_id
	left join source_uom su_from on su_from.source_uom_id=sdd.deal_volume_uom_id
	left join source_uom su_to on su_to.source_uom_id=isnull(spcd.display_uom_id,spcd.uom_id)
	outer apply
	(
		SELECT 	  max(cast(case when uddft.Field_id=-5619 then udddf.udf_value else null end as float)) Density,
			max(nullif(cast(case when uddft.Field_id=-5620 then udddf.udf_value else null end as float),0)) UOM_Conversion,
			max(nullif(cast(case when uddft.Field_id= -5633 then udddf.udf_value else null end as float),0)) UOM_Conversion_div
			,max(nullif(case when uddft.Field_id= -5656 then udddf.udf_value else null end ,0)) con_UOM_id
		FROM user_defined_deal_detail_fields udddf 
			INNER JOIN user_defined_deal_fields_template uddft	ON  uddft.udf_template_id = udddf.udf_template_id 
				AND   udddf.source_deal_detail_id = sdd.source_deal_detail_id
	) den
	left join source_uom su_to1 on su_to1.source_uom_id=den.con_UOM_id
	outer apply
	(
		select g.clm1_value from_uom_id,g.clm2_value to_uom_id, nullif(cast(clm5_value as float),0) density_mult
		from generic_mapping_values g 
			inner join generic_mapping_header h on g.mapping_table_id=h.mapping_table_id
				and h.mapping_name= 'Density Conversion Mapping'
				and den.density between isnull(cast(clm3_value as numeric(18,10)),den.density) and isnull(cast(clm4_value as numeric(18,10)),den.density)
				and ISNUMERIC(clm1_value)=1 and ISNUMERIC(clm2_value)=1 and ISNUMERIC(clm3_value)=1 and ISNUMERIC(clm4_value)=1
		where 
			 nullif(den.UOM_Conversion,0) is null and nullif(den.UOM_Conversion_div,0) is null 
	) mul
where (mul.from_uom_id is null or (mul.from_uom_id=sdd.deal_volume_uom_id and mul.to_uom_id=coalesce(den.con_UOM_id,spcd.display_uom_id,spcd.uom_id))) and
 ((coalesce(su_to1.uom_type,su_to.uom_type,'m')='v' and isnull(su_from.uom_type,'m')='m') or (isnull(su_from.uom_type,'m')='v' and coalesce(su_to1.uom_type,su_to.uom_type,'m')='m'))
 and coalesce(den.UOM_Conversion,den.UOM_Conversion_div,mul.density_mult) is not null

 
--select * from  dbo.deal_uom_conversion_factor

delete dbo.deal_uom_conversion_factor
from dbo.deal_uom_conversion_factor a inner join #deal_uom_conversion duc
	on a.source_deal_detail_id=duc.source_deal_detail_id

INSERT INTO dbo.deal_uom_conversion_factor(source_deal_detail_id,from_uom_id,to_uom_id,conversion_factor,create_ts , create_user)
select duc.source_deal_detail_id, con.from_id,con.to_id 
, case when con.from_id=duc.from_uom_id and con.to_id=duc.to_uom_id and duc.density_mult is not null then duc.density_mult
else 	
	case when density_mult is  null then dbo.FNAGetUOMConvertValue(con.from_id,con.to_id) 
		else dbo.FNAGetUOMConvertValueWithFactor(con.from_id,con.to_id,duc.from_uom_id,duc.to_uom_id,duc.density_mult)
	end
end cov_value 
,getdate(),dbo.fnadbuser()
from #deal_uom_conversion duc cross join (
	select a.id from_id,b.id to_id from #volumetric_uom a cross join #mass_uom b
	union all
	select b.id from_id,a.id to_id from #volumetric_uom a cross join #mass_uom b
 ) con