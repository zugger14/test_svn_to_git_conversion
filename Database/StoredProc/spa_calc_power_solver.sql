if object_id('dbo.spa_calc_power_solver') is not null
	drop proc dbo.spa_calc_power_solver

go

create proc dbo.spa_calc_power_solver @process_id varchar(250)
as
 /*

	declare @process_id varchar(250)='0B88941D_3D95_42AA_8180_D7275CFA621D'

*/

declare @lambada numeric(28,18)=45,@solver_value numeric(28,18) ,@totalmw numeric(28,18),@diff numeric(28,18),@i int ,@j int=100
	,@term_hr datetime,@is_dst bit
	,@lambada_pre  numeric(28,18),@diff_pre numeric(28,18),@lowerbound numeric(28,18),@upperbound numeric(28,18)
	 ,@user_login_id varchar(30),@power_solver varchar(500),@st varchar(max)
--adiha_process.dbo.power_solver_sa_0C0E9E23_5448_4A3E_BBB5_0B85D4B9A28D

if OBJECT_ID('tempdb..#power_solver') is not null drop table #power_solver
if OBJECT_ID('tempdb..#power_solver_final') is not null drop table #power_solver_final

create table #power_solver (term_hr datetime,source_deal_header_id int,is_dst bit, variable_om_rate numeric(28,18),coefficient_a  numeric(28,18),coefficient_b  numeric(28,18)
	, price numeric(28,18),min_capacity numeric(28,18),max_capacity numeric(28,18),  totalmw   numeric(28,18),solver_value  numeric(28,18),lambada numeric(28,18) )
create table #power_solver_final (term_hr datetime,source_deal_header_id int, is_dst bit,solver_value  numeric(28,18),lambada numeric(28,18) )

SET @process_id= ISNULL(@process_id, dbo.FNAGetNewID())
SET @user_login_id= dbo.FNADBUser()	
SET @power_solver = dbo.FNAProcessTableName('power_solver', @user_login_id, @process_id) 

if OBJECT_ID('tempdb..#temp_ps') is not null drop table #temp_ps
CREATE TABLE #temp_ps(term_hr DATETIME,is_dst INT)

EXEC('INSERT INTO #temp_ps(term_hr,is_dst)
SELECT DISTINCT term_hr,is_dst FROM '+@power_solver)

DECLARE @term CURSOR

SET @term = CURSOR FOR
	SELECT distinct term_hr,is_dst
	FROM #temp_ps
	-- WHERE term_hr = '2016-01-01 02:00:00.000'
OPEN @term
FETCH NEXT
FROM @term INTO @term_hr,@is_dst
WHILE @@FETCH_STATUS = 0
BEGIN

	EXEC spa_print '@term_hr:', @term_hr, ', @is_dst:', @is_dst

	truncate table #power_solver
	set @i=1
	set @lambada_pre=45
	
	set @st='insert into #power_solver (term_hr,source_deal_header_id,is_dst, variable_om_rate,coefficient_a,coefficient_b
		,price,min_capacity,max_capacity,totalmw,solver_value,lambada) 
	select term_hr,source_deal_header_id,is_dst, variable_om_rate,coefficient_a,coefficient_b,price,min_capacity,max_capacity,totalmw
		,(((45-variable_om_rate)/price)-coefficient_b)/(2*coefficient_a),45 
	from '+ @power_solver +'
	where term_hr='''+CAST(@term_hr AS VARCHAR)+''' and is_dst='+cast(@is_dst as varchar)
	EXEC spa_print @st
	exec(@st)

	select @diff_pre=max(totalmw)-sum(case when min_capacity>(solver_value) then min_capacity when max_capacity<(solver_value) then max_capacity else solver_value end) 
			from #power_solver

	 select @lambada=@lambada_pre+(case when @diff_pre > 0 then 1 else -1 end *10)

	 update  #power_solver  set solver_value=(((@lambada-variable_om_rate)/price)-coefficient_b)/(2*coefficient_a),lambada=@lambada 
	
	--SELECT * FROM #power_solver WHERE term_hr = '2016-01-01 00:00:00.000'
	
	 select @diff=max(totalmw)-sum(case when min_capacity>(solver_value) then min_capacity when max_capacity<(solver_value) then max_capacity else (solver_value) end) 
			from #power_solver
	
	--SELECT @diff
	
	if abs(@diff)<=0.05 
	begin
		insert into #power_solver_final (term_hr ,source_deal_header_id,is_dst ,solver_value,lambada)  
		select term_hr ,source_deal_header_id,is_dst ,solver_value,lambada from #power_solver
		
		BREAK
	end
	 If @diff_pre>0 
	 begin
		If @diff>0 
		begin
			 set @lowerbound= @lambada
			 set @upperbound= @lambada+10
		 end
		 else
		 begin
			set @lowerbound= @lambada_pre
			 set @upperbound= @lambada
		 end
	end
	else
	begin
		If @diff>0 
		begin
			 set @lowerbound= @lambada
			 set @upperbound= @lambada_pre
			 
		 end
		 else
		 begin
			set @lowerbound= @lambada -10
			 set @upperbound= @lambada
		 end
	end
	set @lambada=  (@lowerbound+@upperbound)/2
	
	EXEC spa_print '-----------------------------------------------------'
	EXEC spa_print '@lambada_pre:', @lambada_pre 
	EXEC spa_print '@diff_pre:', @diff_pre 
	EXEC spa_print '@diff:', @diff
	EXEC spa_print '@lowerbound:', @lowerbound
	EXEC spa_print '@upperbound:', @upperbound
	EXEC spa_print '@lambada:', @lambada
	EXEC spa_print '-----------------------------------------------------'
	
	---set @diff_pre =	@diff

   	update  #power_solver  set solver_value=((((@lambada-variable_om_rate)/price)-coefficient_b)/(2*coefficient_a)),lambada=@lambada 

	while 1=1
	begin
		select @diff=max(totalmw)-sum(case when min_capacity>(solver_value) then min_capacity when max_capacity<(solver_value) then max_capacity else (solver_value) end) 
			from #power_solver
		
		--SELECT @lowerbound as [Lowerbound],@upperbound as [Upperbound], @lambada as [Lam], @diff as [Diff], @diff_pre as [Diff Pre] 

	
		if abs(@diff)<=0.05 or @diff_pre=@diff
		begin
			--select * from #power_solver
			insert into #power_solver_final (term_hr ,source_deal_header_id,is_dst ,solver_value,lambada)  
			select term_hr ,source_deal_header_id,is_dst ,solver_value,lambada from #power_solver

			BREAK

		end
		else
		begin

			If @diff_pre>0 
			begin
				If @diff>0 
				begin
					set @lowerbound= @lambada
				end
				else
				begin
					set @upperbound= @lambada
				end
			end
			else
			begin
				If @diff>0 
				begin
					set @lowerbound= @lambada
				end
				else
				begin
					set @upperbound= @lambada
				end
			end

			--print '========================================='
			--print '@diff_pre:'+str(@diff_pre,28,18) 
			--print '@diff:'+str(@diff,28,18)
			--print 'pre @lambada:'+str(@lambada,28,18) 
			--print '@lowerbound:'+str(@lowerbound,28,18)
			--print '@upperbound:'+str(@upperbound,28,18)		
			--print '==========================================='
		
			set @lambada=  (@lowerbound+@upperbound)/2
	

			--print @lambada

			update  #power_solver  set solver_value=((((@lambada-variable_om_rate)/price)-coefficient_b)/(2*coefficient_a)),lambada=@lambada 
	 
			if @i >@j 
			begin
				update  #power_solver  set lambada=-1*lambada
				BREAK
			end
				
			set @diff_pre =	@diff
			
			
			

		end
		set @i=@i+1

	end --while

	FETCH NEXT FROM @term INTO @term_hr,@is_dst
END
CLOSE @term
DEALLOCATE @term

set @st='update s set solver_value= ROUND(
	case when s.min_capacity>f.solver_value then s.min_capacity when s.max_capacity<f.solver_value then s.max_capacity else f.solver_value end, 0)
	,lambada=f.lambada from '+@power_solver+' s 
	inner join #power_solver_final f
	on s.term_hr=f.term_hr and s.is_dst=f.is_dst and s.source_deal_header_id=f.source_deal_header_id '

exec(@st)

--select * from #power_solver_final

--select * FROM adiha_process.dbo.power_solver_sa_0C0E9E23_5448_4A3E_BBB5_0B85D4B9A28D order by 2,1
