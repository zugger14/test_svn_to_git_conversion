IF OBJECT_ID('spa_rebuild_formula_content') IS NOT NULL
drop proc dbo.[spa_rebuild_formula_content]

GO


CREATE PROCEDURE [dbo].[spa_rebuild_formula_content] (
	@formula_id int=null
	,@nested_id int=null
)
AS


/*

DECLARE @formula_id int=1050,@nested_id int=2


--*/


if  object_id('tempdb..#function_text') is not null
	drop table #function_text

if object_id('tempdb..#formula_breakdown_rebuild') is not null
	drop table #formula_breakdown_rebuild

if object_id('tempdb..#tmp_next_level_func_args') is not null
	drop table #tmp_next_level_func_args


declare @formula_level int,@formula_build varchar(max)
,@formula_nested_id int

--select formula_id,nested_id,max(formula_level) formula_level into #cte_max_level
--from formula_breakdown  where formula_id=740 and nested_id=4
--group by formula_id,nested_id

--select * from formula_breakdown where 
--formula_id =740 and nested_id =4

select 
	formula_id,nested_id,formula_level,func_name,arg_no_for_next_func,parent_nested_id,level_func_sno,parent_level_func_sno,formula_nested_id
	,arg1=cast(case when isnumeric(fb.arg1)=1 then fb.arg1 else ''''+fb.arg1+'''' end as varchar(max))
	,arg2=cast(case when isnumeric(fb.arg2)=1 then fb.arg2 else ''''+fb.arg2+'''' end as varchar(max))
	,arg3=cast(case when isnumeric(fb.arg3)=1 then fb.arg3 else ''''+fb.arg3+'''' end as varchar(max))
	,arg4=cast(case when isnumeric(fb.arg4)=1 then fb.arg4 else ''''+fb.arg4+'''' end as varchar(max))
	,arg5=cast(case when isnumeric(fb.arg5)=1 then fb.arg5 else ''''+fb.arg5+'''' end as varchar(max))
	,arg6=cast(case when isnumeric(fb.arg6)=1 then fb.arg6 else ''''+fb.arg6+'''' end as varchar(max))
	,arg7=cast(case when isnumeric(fb.arg7)=1 then fb.arg7 else ''''+fb.arg7+'''' end as varchar(max))
	,arg8=cast(case when isnumeric(fb.arg8)=1 then fb.arg8 else ''''+fb.arg8+'''' end as varchar(max))
	,arg9=cast(case when isnumeric(fb.arg9)=1 then fb.arg9 else ''''+fb.arg9+'''' end as varchar(max))
	,arg10=cast(case when isnumeric(fb.arg10)=1 then fb.arg10 else ''''+fb.arg10+'''' end as varchar(max))
	,arg11=cast(case when isnumeric(fb.arg11)=1 then fb.arg11 else ''''+fb.arg11+'''' end as varchar(max))
	,arg12=cast(case when isnumeric(fb.arg12)=1 then fb.arg12 else ''''+fb.arg12+'''' end as varchar(max))
	,arg13=cast(case when isnumeric(fb.arg13)=1 then fb.arg13 else ''''+fb.arg13+'''' end as varchar(max))
	,arg14=cast(case when isnumeric(fb.arg14)=1 then fb.arg14 else ''''+fb.arg14+'''' end as varchar(max))
	,arg15=cast(case when isnumeric(fb.arg15)=1 then fb.arg15 else ''''+fb.arg15+'''' end as varchar(max))
	,arg16=cast(case when isnumeric(fb.arg16)=1 then fb.arg16 else ''''+fb.arg16+'''' end as varchar(max))
	,arg17=cast(case when isnumeric(fb.arg17)=1 then fb.arg17 else ''''+fb.arg17+'''' end as varchar(max))
	,arg18=cast(case when isnumeric(fb.arg18)=1 then fb.arg18 else ''''+fb.arg18+'''' end as varchar(max))

INTO #formula_breakdown_rebuild 
 from  #formula_breakdown fb 
--from  formula_breakdown fb 
--where formula_id=@formula_id and isnull(nested_id,-1)=isnull(@nested_id,-1)



DECLARE db_cursor CURSOR FOR  
	select distinct formula_id,nested_id,formula_level,formula_nested_id from #formula_breakdown_rebuild
	order by formula_id,nested_id,formula_level desc
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @formula_id,@nested_id,@formula_level,@formula_nested_id
WHILE @@FETCH_STATUS = 0   
BEGIN   

		if  object_id('tempdb..#function_text') is not null
			drop table #function_text


		if object_id('tempdb..#tmp_next_level_func_args') is not null
			drop table #tmp_next_level_func_args

		select formula_id,nested_id,formula_level,func_name,arg_no_for_next_func,parent_nested_id,level_func_sno,parent_level_func_sno,
			func_text=cast(
			case when fb.func_name in ('^','%','/','*','-','+','<','<=','=','>','>=','<>') then ''  else fb.func_name end +'('
			+
			case when
				isnull(nullif(fb.arg1,'NULL'),'')+isnull(nullif(fb.arg2,'NULL'),'')+isnull(nullif(fb.arg3,'NULL'),'')+isnull(nullif(fb.arg4,'NULL'),'')+
				isnull(nullif(fb.arg5,'NULL'),'')+isnull(nullif(fb.arg6,'NULL'),'')+isnull(nullif(fb.arg7,'NULL'),'')+isnull(nullif(fb.arg8,'NULL'),'')+
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=1
			then isnull(fb.arg1,'NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg2,'NULL'),'')+isnull(nullif(fb.arg3,'NULL'),'')+isnull(nullif(fb.arg4,'NULL'),'')+
				isnull(nullif(fb.arg5,'NULL'),'')+isnull(nullif(fb.arg6,'NULL'),'')+isnull(nullif(fb.arg7,'NULL'),'')+isnull(nullif(fb.arg8,'NULL'),'')+
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=2
			then
				isnull(case when fb.func_name in ('^','%','/','*','-','+','<','<=','=','>','>=','<>') then fb.func_name  else ',' end +fb.arg2,',NULL')
			else '' end	
			+ 
			case when
				isnull(nullif(fb.arg3,'NULL'),'')+isnull(nullif(fb.arg4,'NULL'),'')+
				isnull(nullif(fb.arg5,'NULL'),'')+isnull(nullif(fb.arg6,'NULL'),'')+isnull(nullif(fb.arg7,'NULL'),'')+isnull(nullif(fb.arg8,'NULL'),'')+
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=3
			then isnull(','+fb.arg3,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg4,'NULL'),'')+
				isnull(nullif(fb.arg5,'NULL'),'')+isnull(nullif(fb.arg6,'NULL'),'')+isnull(nullif(fb.arg7,'NULL'),'')+isnull(nullif(fb.arg8,'NULL'),'')+
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=4
			then isnull(','+fb.arg4,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg5,'NULL'),'')+isnull(nullif(fb.arg6,'NULL'),'')+isnull(nullif(fb.arg7,'NULL'),'')+isnull(nullif(fb.arg8,'NULL'),'')+
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=5
			then isnull(','+fb.arg5,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg6,'NULL'),'')+isnull(nullif(fb.arg7,'NULL'),'')+isnull(nullif(fb.arg8,'NULL'),'')+
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=6
			then isnull(','+fb.arg6,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg7,'NULL'),'')+isnull(nullif(fb.arg8,'NULL'),'')+
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=7
			then isnull(','+fb.arg7,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg8,'NULL'),'')+
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=8
			then isnull(','+fb.arg8,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg9,'NULL'),'')+isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=9
			then isnull(','+fb.arg9,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg10,'NULL'),'')+isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=10
			then isnull(','+fb.arg10,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg11,'NULL'),'')+isnull(nullif(fb.arg12,'NULL'),'')+
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=11
			then isnull(','+fb.arg11,',NULL') else '' end	
			+
			case when
				isnull(nullif(fb.arg12,'NULL'),'')+isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=12
			then isnull(','+fb.arg12,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg13,'NULL'),'')+isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=13
			then isnull(','+fb.arg13,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg14,'NULL'),'')+isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=14
			then isnull(','+fb.arg14,',NULL') else '' end	
			+
			case when
				isnull(nullif(fb.arg15,'NULL'),'')+
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=15
			then isnull(','+fb.arg15,',NULL') else '' end
			+
			case when
				isnull(nullif(fb.arg16,'NULL'),'')+isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=16
			then isnull(','+fb.arg16,',NULL') else '' end	
			+
			case when
				isnull(nullif(fb.arg17,'NULL'),'')+isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=17
			then isnull(','+fb.arg17,',NULL') else '' end	
			+
			case when
				isnull(nullif(fb.arg18,'NULL'),'')<>'' or isnull(p.sequence,0)>=18  
			then isnull(','+fb.arg18,',NULL') else '' end	
			+')' as varchar(max))
		into #function_text	
	from #formula_breakdown_rebuild fb
		outer apply
		( 
			select max(fep.sequence) sequence from dbo.formula_editor_parameter fep	
			where fep.function_name=fb.func_name  
		 
		 )  p

		where formula_level=@formula_level
			and formula_id=@formula_id and isnull(nested_id,-1)=isnull(@nested_id,-1)
		
	
		set @formula_build=null
		select @formula_build=func_text from #function_text where arg_no_for_next_func IS  NULL and func_text is not null
				
		if @formula_build is null
		begin
			
			
			SELECT formula_id,nested_id,formula_level, parent_level_func_sno,
				[1], [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18]
			INTO #tmp_next_level_func_args 
			FROM 
			( 
				SELECT f.formula_id,
					f.nested_id,
					f.formula_level-1 formula_level,
					f.arg_no_for_next_func,
					f.parent_level_func_sno,
					f.func_text 
				FROM #function_text f
				where arg_no_for_next_func IS NOT NULL and
				 f.formula_level=@formula_level
				) AS SourceTable
				PIVOT
				(
				max(func_text)
				FOR arg_no_for_next_func IN ([1], [2], [3], [4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18])
			) AS PivotTable
			
			; 	
		
		
		--SELECT '#tmp_next_level_func_args'
		--SELECT * FROM #tmp_next_level_func_args	

		----UPDATE arguments of next level function
			UPDATE  s 
			SET arg1 =case when t.[1] is null then arg1 else t.[1] end ,
				arg2 =case when t.[2] is null then arg2 else t.[2] end ,
				arg3 =case when t.[3] is null then arg3 else t.[3] end ,
				arg4 =case when t.[4] is null then arg4 else t.[4] end ,
				arg5 =case when t.[5] is null then arg5 else t.[5] end ,
				arg6 =case when t.[6] is null then arg6 else t.[6] end ,
				arg7 =case when t.[7] is null then arg7 else t.[7] end ,
				arg8 =case when t.[8] is null then arg8 else t.[8] end ,
				arg9 =case when t.[9] is null then arg9 else t.[9] end ,
				arg10 =case when t.[10] is null then arg10 else t.[10] end ,
				arg11 =case when t.[11] is null then arg11 else t.[11] end ,
				arg12 =case when t.[12] is null then arg12 else t.[12] end ,
				arg13 =case when t.[13] is null then arg13 else t.[13] end ,
				arg14 =case when t.[14] is null then arg14 else t.[14] end ,
				arg15 =case when t.[15] is null then arg15 else t.[15] end ,
				arg16 =case when t.[16] is null then arg16 else t.[16] end ,
				arg17 =case when t.[17] is null then arg17 else t.[17] end ,
				arg18 =case when t.[18] is null then arg18 else t.[18] end 
				 
			FROM
				#formula_breakdown_rebuild s INNER JOIN #tmp_next_level_func_args t ON  
				s.formula_id=t.formula_id 
				AND s.nested_id=t.nested_id 
				AND s.level_func_sno=t.parent_level_func_sno
		end
		else 
		begin
			--select @formula_nested_id,@formula_id,@formula_build

			--select fb.formula_nested_id,* from #formula_breakdown_rebuild fb
			-- inner join #formula_nested fn on fb.formula_nested_id=fn.id 
			--  and fb.formula_nested_id=@formula_nested_id and fb.arg_no_for_next_func is null
			--inner join #formula_editor fe on fn.formula_id=fe.new_recid


		--	select @formula_build,* from #formula_editor  where formula_id=@formula_nested_id
		EXEC spa_print @formula_build
			update #formula_editor set formula=@formula_build
			from #formula_breakdown_rebuild fb
			 inner join #formula_nested fn on fb.formula_nested_id=fn.id 
			  and fb.formula_nested_id=@formula_nested_id and fb.arg_no_for_next_func is null
			inner join #formula_editor fe on fn.formula_id=fe.new_recid

			---goto exit_cursor
		end
		
	
       FETCH NEXT FROM db_cursor INTO @formula_id,@nested_id,@formula_level,@formula_nested_id   
END   

exit_cursor: 
CLOSE db_cursor   
DEALLOCATE db_cursor

--select * from #formula_breakdown_rebuild



--select @formula_build


/*
	
select formula_id,nested_id,formula_level,* from formula_breakdown a 
	--left join formula_breakdown b on a.formula_id=b.formula_id and a.nested_id=b.nested_id and a.formula_level=b.formula_level-1
 where arg1 is null
 
 
 formula_id=65
order by 1,2,3 desc
select * from formula_editor  where formula_id in (10)
741,
742,
743,
744)


select * from formula_editor_parameter

*/

