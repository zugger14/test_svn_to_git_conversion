IF OBJECT_ID('[dbo].[spa_bifurcate_embedded_deal]','p') IS NOT NULL 
DROP PROCEDURE [dbo].[spa_bifurcate_embedded_deal]
 GO 

create PROC [dbo].[spa_bifurcate_embedded_deal]
	@flag char(1)='s', -- s-> show summary d-> show detail
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@deal_date_from varchar(100)=null,
	@deal_date_to varchar(100)=null,
	@source_system_book_id1 int=NULL, 
	@source_system_book_id2 int=NULL, 
	@source_system_book_id3 int=NULL, 
	@source_system_book_id4 int=NULL, 
	@deal_id_from int=null,
	@deal_id_to int=null,
	@deal_id varchar(100)=null,
	@counterparty_id int=null,
	@source_deal_header_id int =null,
	@show_processed_deals char(1)=null,
	@use_create_date char(1)='n'
AS	

Declare @sql_Select varchar(8000)
Declare @sql_Select1 varchar(8000)
--########### Group Label
declare @group1 varchar(100),@group2 varchar(100),@group3 varchar(100),@group4 varchar(100)
 if exists(select group1,group2,group3,group4 from source_book_mapping_clm)
begin	
	select @group1=group1,@group2=group2,@group3=group3,@group4=group4 from source_book_mapping_clm
end
else
begin
	set @group1='Group1'
	set @group2='Group2'
	set @group3='Group3'
	set @group4='Group4'
end
--######## End
if @deal_id_from is not null and @deal_id_to is null
	set @deal_id_to=@deal_id_from
if @deal_id_from is null and @deal_id_to is not null
	set @deal_id_from=@deal_id_to

if @flag='s'
begin
	SET @sql_Select = 
			'SELECT 
			dbo.FNAHyperLinkText(10131000, sDH.deal_id, sDH.source_deal_header_id) AS [Source Deal ID], 
			sDH.source_deal_header_id AS [Deal ID], 			
			sb1.source_book_name AS ['+ @group1 +'], 
            sb2.source_book_name AS ['+ @group2 +'], sb3.source_book_name AS ['+ @group3 +'], 
            sb4.source_book_name AS ['+ @group4 +'], 
			dbo.FNADateFormat(sDH.deal_date) as [Deal Date], 
			sc.counterparty_name [Counterparty], 
			ssd.source_system_name [Source System],
			dbo.FNADateTimeFormat(max(sdh.update_ts),2) [Created TS]
			
			'+
		' FROM 
						  source_deal_header sDH INNER JOIN
						  source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id	LEFT OUTER JOIN
	                      source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id LEFT OUTER JOIN
	                      source_book sb4 ON sDH.source_system_book_id4 = sb4.source_book_id LEFT OUTER JOIN
	                      source_book sb3 ON sDH.source_system_book_id3 = sb3.source_book_id LEFT OUTER JOIN
	                      source_book sb2 ON sDH.source_system_book_id2 = sb2.source_book_id LEFT OUTER JOIN
	                      source_book sb1 ON sDH.source_system_book_id1 = sb1.source_book_id LEFT OUTER JOIN
						  source_system_description ssd on ssd.source_system_id=sdh.source_system_id left join
						  embedded_deal	ed on ed.source_deal_header_id=sdh.source_deal_header_id
							
						  --and ed.leg=sdd.leg
							'
		+' Where ((sdd.leg=2 and sc.counterparty_name like ''ss %'') or  sdd.leg > 2 )	'	
		if @deal_id is not null
					SET @sql_Select = @sql_Select +' and sdh.deal_id='''+ @deal_id +''''
		else
		begin
            SET @sql_Select = @sql_Select + case when @source_system_book_id1 is not null then ' AND sdh.source_system_book_id1='+cast(@source_system_book_id1 as varchar) else '' end
					+ case when @source_system_book_id2 is not null then ' AND sdh.source_system_book_id2='+cast(@source_system_book_id2 as varchar) else '' end
					+ case when @source_system_book_id3 is not null then ' AND sdh.source_system_book_id3='+cast(@source_system_book_id3 as varchar) else '' end
					+ case when @source_system_book_id4 is not null then ' AND sdh.source_system_book_id4='+cast(@source_system_book_id4 as varchar) else '' end
					+ case when @counterparty_id is not null then ' And sdh.counterparty_id='+cast(@counterparty_id as varchar)  else '' end	
					--+ case when (@deal_id_from IS NOT NULL) AND (@deal_id_to IS NOT NULL) then ' OR (sDH.source_deal_header_id BETWEEN '+ cast(@deal_id_from as varchar)+ ' and '+ cast(@deal_id_to as varchar)+ ')' else '' end

	if 	@deal_date_to is null and @deal_date_from IS NOT NULL
		set @deal_date_to=@deal_date_from

	if 	@deal_id_to is null and @deal_id_from IS NOT NULL
		set @deal_id_to=@deal_id_from

	if 	@deal_id_to is not null and @deal_id_from IS NOT NULL
		SET @sql_Select = @sql_Select  + ' and sdh.source_deal_header_id BETWEEN '+ cast(@deal_id_from as varchar)+ ' and '+ cast(@deal_id_to as varchar) 

	IF @deal_date_from IS NOT NULL AND @deal_date_to IS NOT NULL
	BEGIN
		
			
	IF @use_create_date='y'
		SET @sql_Select = @sql_Select    + ' and dbo.FNAConvertTZAwareDateFormat(isNUll(sdh.update_ts,sdh.create_ts),1) BETWEEN ''' + @deal_date_from + ''' and ''' + @deal_date_to + ' 23:59:59'''	 
--		SET @sql_Select = @sql_Select    + ' and isNUll(sdh.update_ts,sdh.create_ts) BETWEEN ''' + @deal_date_from + ''' and ''' + @deal_date_to + ' 23:59:59'''	 
	ELSE
			SET @sql_Select = @sql_Select    + ' and sdh.deal_date BETWEEN ''' + @deal_date_from + ''' and ''' + @deal_date_to + ' 23:59:59'''	 

	END

		end 
		SET @sql_Select = @sql_Select    + ' group by	
			sDH.source_deal_header_id,
			dbo.FNAHyperLinkText(10131000, sDH.source_deal_header_id, sDH.source_deal_header_id), 
			sdh.deal_id,sb1.source_book_name,sb2.source_book_name,sb3.source_book_name,sb4.source_book_name,
			dbo.FNADateFormat(sDH.deal_date),ssd.source_system_name,sc.counterparty_name,sc.counterparty_name'
			+ case when @show_processed_deals='y' then ' having max(isnull(ed.completed,''n''))=''y'' ' else ' having max(isnull(ed.completed,''n''))=''n'' ' end
			
		EXEC spa_print @sql_Select	
		exec(@sql_Select)
end
else if @flag='d'
begin
SET @sql_Select = '
	select 
		   max(sdd.source_deal_detail_id) [Deal Detail ID],	
		   sdh.deal_id [Source Deal ID],
		   spcd.curve_name + 
			case when max(sdd.block_description) is not null then 
			''(''+ left(max(sdd.block_description),4) +'')'' else '''' end 
		 [Curve Name],
		   dbo.fnadateformat(min(sdd.term_start)) [Term Start],
		   dbo.fnadateformat(max(sdd.term_end)) [Term End],	
		   sdd.leg [Leg],
		   buy_sell_flag [Buy/Sell]	,
		   sd.code[Type],
		   dbo.FNAHyperLinkText(10131000, sdh1.deal_id, sDH1.source_deal_header_id) [Embedded Deal ID],	
		   max(ed.embedded_deal_id) [Embd ID],
		   sDH1.source_deal_header_id [Embd Source Deal Header ID],
			ed.type_value_id		
		  	
	from 
		source_deal_detail sdd inner join 
		source_deal_header sdh on sdd.source_deal_header_id=sdh.source_deal_header_id left join 		
		embedded_deal ed on ed.source_deal_header_id=sdh.source_deal_header_id
		and ed.leg=sdd.leg
		left join static_data_value sd on sd.value_id=ed.type_value_id
		left join source_deal_header sdh1 on 
sdh1.source_deal_header_id=ed.bif_source_deal_header_id
		 	left join source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
	where sdh.source_deal_header_id='+cast(@source_deal_header_id as varchar)+
		 
	' group by 
		sdh.deal_id,sdd.leg,buy_sell_flag,sd.code, dbo.FNAHyperLinkText(10131000, sdh1.deal_id, sDH1.source_deal_header_id),sDH1.source_deal_header_id,spcd.curve_name,ed.type_value_id
	order by leg '
EXEC spa_print @sql_Select
exec(@sql_Select)
	
end




















