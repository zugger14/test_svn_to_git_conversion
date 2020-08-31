
/****** Object:  StoredProcedure [dbo].[spa_REC_Exposure_Report]    Script Date: 09/01/2009 00:39:55 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_REC_Exposure_Report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_REC_Exposure_Report]
/****** Object:  StoredProcedure [dbo].[spa_REC_Exposure_Report]    Script Date: 09/01/2009 00:39:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spa_REC_Exposure_Report '2006-09-30','96',NULL,NULL,'5146',2006,5118,NULL,24
CREATE  PROC [dbo].[spa_REC_Exposure_Report]
	@summary_option CHAR(1)='e', -- Exposure report, 'm'-> market value report
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@report_type int = null,  --assignment_type  
	@compliance_year int,
	@assigned_state int = null,
	@curve_id int = NULL,
	@convert_uom_id int,
	@program_scope varchar(50)=null,
	@program_type char(1)='b', --- 'a' -> Compliance, 'b' -> cap&trade
	@round_value CHAR(1)='0',   
	@udf_group1 INT=NULL,
	@udf_group2 INT=NULL,
	@udf_group3 INT=NULL,	
	@tier_type INT=NULL,
	@detail_option CHAR(1) ='m', -- 'm' - maximum value , 'a' - All values
    @generation_state INT=NULL,
	@technology int =NULL,
	@drill_state VARCHAR(100)=NULL,
	@drill_vintage INT=NULL,
	@drill_jurisdiction VARCHAR(50)=NULL,
	@drill_technology VARCHAR(50)=NULL,
	@batch_process_id varchar(50)=NULL,
	@batch_report_param varchar(500)=NULL,
	@enable_paging int=0,  --'1'=enable, '0'=disable
	@page_size int =NULL,
	@page_no int=NULL
 AS

--SET NOCOUNT ON

EXEC spa_print	'@batch_process_id:', @batch_process_id 
EXEC spa_print	'@batch_report_param:',	@batch_report_param

declare @str_batch_table varchar(max),@str_get_row_number VARCHAR(100)
declare @temptablename varchar(128),@user_login_id varchar(50),@flag CHAR(1)
DECLARE @is_batch bit
declare @maturity_date varchar(50)
set @maturity_date = cast(@compliance_year as varchar) + '-12-01'
set @str_batch_table=''
SET @str_get_row_number=''

declare @sql_stmt varchar(5000)
declare @reportname varchar(5000)	

IF @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL
	SET @is_batch = 1
ELSE
	SET @is_batch = 0
	
IF (@is_batch = 1 OR @enable_paging = 1)
begin
	IF (@batch_process_id IS NULL)
		SET @batch_process_id = REPLACE(NEWID(), '-', '_')
		
	SET @user_login_id = dbo.FNADBUser()	
	SET @temptablename = dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	exec spa_print '@temptablename', @temptablename
	SET @str_batch_table=' INTO ' + @temptablename
	SET @str_get_row_number=', ROWID=IDENTITY(int,1,1)'
	IF @enable_paging = 1
	BEGIN
		
		IF @page_size IS not NULL
		begin
			declare @row_to int,@row_from int
			set @row_to=@page_no * @page_size
			if @page_no > 1 
				set @row_from =((@page_no-1) * @page_size)+1
			else
				set @row_from =@page_no
			set @sql_stmt=''
			--	select @temptablename
			--select * from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id

			select @sql_stmt=@sql_stmt+',['+[name]+']' from adiha_process.sys.columns where [object_id]=object_id(@temptablename) and [name]<>'ROWID' ORDER BY column_id
			SET @sql_stmt=SUBSTRING(@sql_stmt,2,LEN(@sql_stmt))
			
			set @sql_stmt='select '+@sql_stmt +'
				  from '+ @temptablename   +' 
				  where rowid between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar) 
				 
			exec spa_print @sql_stmt		
			exec(@sql_stmt)
			return
		END --else @page_size IS not NULL
	END --enable_paging = 1
		
end



	



--to id = 3 mmbtu

--uncomment these to test locally
-- declare 	@as_of_date varchar(50)
-- declare 	@sub_entity_id varchar(100)
-- declare 	@strategy_entity_id varchar(100)
-- declare 	@book_entity_id varchar(100)
-- declare 	@report_type int
-- declare 	@compliance_year int
-- declare 	@assigned_state int
-- declare 	@curve_id int
-- 
-- set @as_of_date = '2005-12-01'
-- set @sub_entity_id = '96'
-- set @strategy_entity_id = null
-- set @book_entity_id = null
-- set @report_type = 5146
-- set @compliance_year = 2005
-- set @assigned_state = 5118
-- set @curve_id = null
-- 
-- drop table #temp
-----==========end of testdata

CREATE TABLE [dbo].[#temp] (
	[sno] INT IDENTITY(1,1),
	[Sub] [varchar] (100),
	[Strategy] [varchar] (100),
	[Book] [varchar] (100),
	[Obligation] [varchar] (50),
	[Tier Type] VARCHAR(50),
	[technology] VARCHAR(50),
	[Assignment] [varchar] (100),
	[target_actual] varchar(10),
	[State]  [varchar] (250),
	[Gen State] [varchar] (250),
	[Compliance Year] VARCHAR(20),
	[Vintage] [varchar] (100),
	[CertIDFrom] VARCHAR(100),
	[CertIDTo] VARCHAR(100),
	[DealID] VARCHAR(500),
	[volume] float,
	[bonus] float,
	[total_volume] float,
	[uom] varchar(100),
	conversion_factor float
	
) ON [PRIMARY]


INSERT  INTO #temp(	[Sub] ,[Strategy],[Book],[Obligation],[Tier Type] ,[technology] ,[Assignment],[target_actual],[State] ,[Gen State],[Compliance Year],
[Vintage],[CertIDFrom],[CertIDTo],[DealID] ,[volume] ,[bonus],[total_volume],[uom],conversion_factor )
	EXEC spa_get_rec_activity_report @as_of_date,@sub_entity_id,@strategy_entity_id,@book_entity_id,@report_type,'d',@compliance_year,@assigned_state,@curve_id,NULL,@convert_uom_id,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL, @technology, NULL, NULL, NULL, NULL,NULL,NULL,NULL, @generation_state,'n',NULL, NULL, NULL, NULL, @drill_State,NULL,	NULL,NULL,NULL,NULL,NULL,'y','n','y',@program_scope,@program_type,@round_value,@udf_group1,@udf_group2,@udf_group3,@tier_type,'n'  
					
	

UPDATE #temp
	SET [DealID]=LTRIM(RTRIM(SUBSTRING([DealID],CHARINDEX('<u>',[DealID])+3,CHARINDEX('</u>',[DealID])-(CHARINDEX('<u>',[DealID])+3))))




CREATE TABLE #temp_exp(
	
	[Jurisdiction] VARCHAR(500) COLLATE DATABASE_DEFAULT,
	[Env Product] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	--[Eligible State] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Year] INT,
	[Volume (+Long/-Short)] FLOAT,
	[Market Price] FLOAT,	
	[ACP Price] FLOAT,
	[Exposure Market] FLOAT,
	[Exposure ACP] FLOAT,
	[UOM] VARCHAR(100) COLLATE DATABASE_DEFAULT
)	


------#######################
CREATE TABLE #state_properties_pricing(            
	 state_value_id int,            
	 pricing_type_id int,            
	 technology int,            
	 curve_id int,            
)            
            
	INSERT INTO #state_properties_pricing            
		select  DISTINCT
		 COALESCE(bS.state_value_id, bA.state_value_id) state_value_id,            
		 COALESCE(bS.pricing_type_id, bA.pricing_type_id) pricing_type_id,            
		 COALESCE(bS.technology, bA.technology) technology,            
		 COALESCE(bS.curve_id, bA.curve_id) curve_id
     
	from            
		(select state_value_id, pricing_type_id, technology,curve_id from state_properties_pricing  where technology is not null ) bS            
		full outer join            
		(            
		select state_value_id, pricing_type_id,curve_id,tech.value_id technology from            
			(
				select state_value_id, pricing_type_id,curve_id,technology,1 as link_id	from state_properties_pricing where technology is  null
			) pricing inner join            
			(
				select value_id, 1 as link_id from static_data_value where type_id = 10009) tech on pricing.link_id = tech.link_id            
			) bA on bA.state_value_id = bs.state_value_id 
					--AND bA.technology = bS.technology
					AND bA.pricing_type_id = bS.pricing_type_id
					AND bA.curve_id = bs.curve_id     
--------------------------------------------------------------            
CREATE  INDEX [IX_spp1] ON [#state_properties_pricing]([state_value_id])                  
CREATE  INDEX [IX_spp2] ON [#state_properties_pricing]([pricing_type_id])                  
CREATE  INDEX [IX_spp3] ON [#state_properties_pricing]([technology])                  
CREATE  INDEX [IX_spp4] ON [#state_properties_pricing]([curve_id])                  
--------------------------------------------------------------         
------#######################
CREATE TABLE #rec_gen_eligibility(            
	 state_value_id int,            
	 gen_state_value_id int,    
	 technology INT,        
	 program_scope int,            
	 tier_type int,            
)            
            
	INSERT INTO #rec_gen_eligibility            
		select  DISTINCT
--		 COALESCE(bS.state_value_id, bA.state_value_id, bC.state_value_id) state_value_id,            
--		 COALESCE(bS.gen_state_value_id, bA.gen_state_value_id, bC.gen_state_value_id) gen_state_value_id,            
--		 COALESCE(bS.technology, bA.technology, bC.technology) technology,            
--		 COALESCE(bS.program_scope, bA.program_scope, bC.program_scope) program_scope,
--		 COALESCE(bS.tier_type, bA.tier_type,bC.tier_type) tier_type

		 COALESCE(bS.state_value_id, bA.state_value_id) state_value_id,            
		 COALESCE(bS.gen_state_value_id, bA.gen_state_value_id) gen_state_value_id,            
		 COALESCE(bS.technology, bA.technology) technology,            
		 COALESCE(bS.program_scope, bA.program_scope) program_scope,
		 NULL
		 --COALESCE(bS.tier_type, bA.tier_type) tier_type     
	from            
		(select state_value_id, gen_state_value_id, technology,program_scope,tier_type  from rec_gen_eligibility  where technology is not null) bS            
		full outer join            
		(            
		select state_value_id, gen_state_value_id, tech.value_id technology,program_scope,tier_type from            
			(
				select state_value_id, gen_state_value_id, technology,program_scope,tier_type,1 as link_id	from rec_gen_eligibility where technology is  null
			) rge inner join            
			(
				select value_id, 1 as link_id from static_data_value where type_id = 10009) tech on rge.link_id = tech.link_id   
			) bA on bA.state_value_id = bs.state_value_id 
					AND ISNULL(bA.tier_type,-1) = ISNULL(bS.tier_type,-1)
					AND bA.gen_state_value_id = bS.gen_state_value_id
					AND bA.program_scope = bs.program_scope
--		full outer join            
--		(            
--		select state_value_id, gen_state_value_id, technology,program_scope,tiertype.value_id tier_type from            
--			(
--				select state_value_id, gen_state_value_id, technology,program_scope,tier_type,1 as link_id	from rec_gen_eligibility where tier_type IS  NULL
--			) rge inner join            
--			(
--				select value_id, 1 as link_id from static_data_value where type_id = 15000) tiertype on rge.link_id = tiertype.link_id   
--    
--			) bC on bC.state_value_id = bA.state_value_id 
--					--AND bA.technology = bS.technology
--					AND bC.gen_state_value_id = bA.gen_state_value_id
--					AND bC.program_scope = bA.program_scope


--------------------------------------------------------------            
CREATE  INDEX [IX_rge1] ON [#rec_gen_eligibility]([state_value_id])                  
CREATE  INDEX [IX_rge2] ON [#rec_gen_eligibility](gen_state_value_id)                  
CREATE  INDEX [IX_rge3] ON [#rec_gen_eligibility](technology)                  
CREATE  INDEX [IX_rge4] ON [#rec_gen_eligibility](program_scope)    
CREATE  INDEX [IX_rge5] ON [#rec_gen_eligibility](tier_type)                  
--------------------------------------------------------------       
-------###########################


IF @summary_option='e'
BEGIN

	set @sql_stmt='
		INSERT INTO #temp_exp
		Select 
			
			State  [Jurisdiction], 
			[Obligation],
			YEAR([Vintage]), 
			round(sum(CASE WHEN target_actual=''target'' THEN 1 ELSE -1 END * total_volume),' +@round_value + ') [Volume (+Long/-Short)],
			isnull(max(market_price.curve_value), 0) [Market Price], 
			isnull(max(acp_price.curve_value), 0) [ACP Price],
			case when (sum(CASE WHEN target_actual=''target'' THEN 1 ELSE -1 END * total_volume) < 0) then sum(CASE WHEN target_actual=''target'' THEN 1 ELSE -1 END * total_volume) else 0 end * isnull(max(market_price.curve_value), 0) [Exposure Market],
			case when (sum(CASE WHEN target_actual=''target'' THEN 1 ELSE -1 END * total_volume) < 0) then sum(CASE WHEN target_actual=''target'' THEN 1 ELSE -1 END * total_volume) else 0 end * isnull(max(acp_price.curve_value), 0) [Exposure ACP] ,MAX(#temp.UOM) 
			 
		FROM #temp 
			LEFT JOIN source_deal_header sdh on sdh.source_deal_header_id=#temp.DealID
			LEFT JOIN rec_generator rg ON rg.generator_id=sdh.generator_id
			LEFT JOIN static_data_value sd ON sd.value_id=rg.state_value_id
			LEFT JOIN #state_properties_pricing spp ON spp.state_value_id=sd.value_id
					 AND spp.Technology= rg.technology
					 AND spp.pricing_type_id=2100
			LEFT JOIN 
			(select spcd.source_curve_def_id, YEAR(maturity_date) maturity_date, max(as_of_date) as_of_date,MAX(spc.curve_value) curve_value
				from source_price_curve_def spcd inner join 
				source_price_curve spc on spcd.source_curve_def_id = spc.source_curve_def_id 
				and spc.assessment_curve_type_value_id = 77 and
				spc.curve_source_value_id = 4500 
				group by spcd.source_curve_def_id,YEAR(maturity_date)
			) market_price on market_price.source_curve_def_id = spp.curve_id
				 AND YEAR([Vintage])=(market_price.maturity_date)
			LEFT JOIN #state_properties_pricing spp1 ON spp1.state_value_id=sd.value_id 
					 AND (spp1.Technology)= rg.technology
					 AND spp1.pricing_type_id=2101
			LEFT JOIN 
			(select spcd.source_curve_def_id, YEAR(maturity_date) maturity_date, max(as_of_date) as_of_date,MAX(spc.curve_value) curve_value
				from source_price_curve_def spcd inner join 
				source_price_curve spc on spcd.source_curve_def_id = spc.source_curve_def_id 
				and spc.assessment_curve_type_value_id = 77 and
				spc.curve_source_value_id = 4500  
				group by spcd.source_curve_def_id,YEAR(maturity_date) 
			) acp_price on acp_price.source_curve_def_id =  spp1.curve_id
				AND YEAR([Vintage])=(acp_price.maturity_date)
			WHERE
				(target_actual=''target'' OR(target_actual=''Actual'' AND Assignment<>''Banked''))
			 group by 
				State,[Obligation],[Vintage],spp1.curve_id
			ORDER BY 
				State,[Vintage]  
			'
	EXEC spa_print @sql_stmt		
	EXEC(@sql_stmt)
	
--IF OBJECT_ID('temp') IS NOT NULL
--BEGIN
--	DROP table	temp 
--	DROP table state_properties_pricing
--
--END
--	select * into temp from	#temp 
--	select * into state_properties_pricing from #state_properties_pricing
	EXEC spa_print '@temptablename:', @temptablename

	set @sql_stmt='
		SELECT 
			[Jurisdiction],
			[Env Product],
			[Year] ,
			SUM([Volume (+Long/-Short)]) [Volume],
			MAX([Market Price]) [Market Price],	
			MAX([ACP Price]) [ACP Price],
			SUM([Volume (+Long/-Short)]*[Market Price]) [Exposure Market],
			SUM([Volume (+Long/-Short)]*[ACP Price]) [Exposure ACP],
			MAX(UOM) UOM '+ @str_get_row_number+' '+ @str_batch_table +'
		FROM
			#temp_exp
		GROUP BY 
			[Jurisdiction],[Year],[Env Product] 
		ORDER BY 
			[Jurisdiction],[Env Product] ,[Year] '
			exec spa_print  @sql_stmt
	exec( @sql_stmt)

END
ELSE IF @summary_option='m'
BEGIN

	CREATE TABLE #temp_market(
		[Generation State] VARCHAR(20) COLLATE DATABASE_DEFAULT,
		[Vintage] INT,
		[Jurisdiction] VARCHAR(200) COLLATE DATABASE_DEFAULT,
		[Obligation] VARCHAR(50) COLLATE DATABASE_DEFAULT,
		[Technology] VARCHAR(50) COLLATE DATABASE_DEFAULT,
		[Price] FLOAT
	)

	set @sql_stmt='
			INSERT INTO #temp_market
			Select
				DISTINCT
					genstate.code [Generation State],
					YEAR([Vintage]), 
					ISNULL(dbo.FNAHyperLinkText(10101012, sd1.code, cast(sd1.value_id as varchar)),State)  [Jurisdiction], 
					#temp.[Obligation],
					tech.code,
					market_price.curve_value [Price]
			FROM #temp 
					INNER JOIN source_deal_header sdh on sdh.source_deal_header_id=#temp.DealID
					INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id
					LEFT JOIN rec_generator rg ON rg.generator_id=sdh.generator_id
					LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
					LEFT JOIN #rec_gen_eligibility rge ON rge.gen_state_value_id=rg.gen_state_value_id
							  AND rge.technology=ISNULL(rg.technology,-1)
							  AND rge.program_scope=ISNULL(spcd.program_scope_value_id,-1)	
							 --AND rge.state_value_id=rg.state_value_id
					LEFT JOIN static_data_value genstate on genstate.value_id=rg.gen_state_value_id
					LEFT JOIN static_data_value sd1 on sd1.value_id=rge.state_value_id
					LEFT JOIN static_data_value tech ON tech.value_id=rg.technology
					LEFT JOIN #state_properties_pricing spp ON spp.state_value_id=sd1.value_id
						 AND spp.Technology= rg.technology
						 AND spp.pricing_type_id=2100
					LEFT JOIN 
					(select spcd.source_curve_def_id, maturity_date, max(as_of_date) as_of_date,MAX(spc.curve_value) curve_value
						from source_price_curve_def spcd inner join 
						source_price_curve spc on spcd.source_curve_def_id = spc.source_curve_def_id 
						and spc.assessment_curve_type_value_id = 77 and
						spc.curve_source_value_id = 4500 
						group by spcd.source_curve_def_id,maturity_date
					) market_price on market_price.source_curve_def_id = spp.curve_id
						 AND YEAR([Vintage])=YEAR(market_price.maturity_date)

				WHERE
						(assignment=''Banked'' AND target_actual=''Actual'')
		
		'
	EXEC(@sql_stmt)

	IF @detail_option='m'
		set @sql_stmt='	SELECT 
		a.[Gen State],YEAR(a.[Vintage]) [Vintage],MAX(b.[Jurisdiction]) [Jurisdiction],a.[Technology],MAX(b.[Price])/MAX(conversion_factor) [Price],SUM(a.[Volume]) [Volume],MAX(UOM) UOM, SUM(a.[Volume])*(MAX(b.price)/MAX(conversion_factor)) [Value]
		'+ @str_get_row_number+' '+ @str_batch_table +'
		FROM
				#temp a
				INNER JOIN 
				(SELECT 
						a.[Generation State],
						a.[Technology],
						a.[Vintage] ,
						MAX(a.[Jurisdiction]) [Jurisdiction],
						MAX(b.[Price]) price
					FROM
						#temp_market a
						INNER JOIN(SELECT [Generation State],[Technology],
								[Vintage] ,
								MAX(ISNULL([Price],0)) [Price]
							FROM #temp_market 							
							GROUP BY [Generation State],[Vintage],[Technology] 
					)b ON a.[Generation State]=b.[Generation State]
					   AND  a.[Vintage]=b.[Vintage]	
					   AND ISNULL(a.[Price],0)=ISNULL(b.[Price],0)	
					   AND a.[Technology]=b.[Technology]	
					GROUP BY a.[Generation State],a.[Technology],a.[Vintage]
				)b
				ON a.[Gen State]=b.[Generation State]
				   AND  YEAR(a.[Vintage])=b.[Vintage]	
				   AND a.[Technology]=b.[Technology]	
				WHERE
					(assignment=''Banked'' AND target_actual=''Actual'')
				GROUP BY a.[Gen State],YEAR(a.[Vintage]),a.[Technology]
				ORDER BY a.[Gen State],YEAR(a.[Vintage])'
		

	ELSE IF @detail_option='a'
	BEGIN

			SET @sql_stmt='
				SELECT 
					a.[Gen State] [Generation State],
					a.[Vintage] Vintage,
					b.[Jurisdiction],
					a.[Technology] [Technology],
					MAX(b.[Price])/MAX(conversion_factor) [Price],
					MAX(a.[Volume]) [Volume],
					MAX(a.UOM) UOM,
					MAX(a.[Volume])*(MAX(b.[Price])/MAX(conversion_factor)) AS [Value]
					'+ @str_get_row_number+' '+ @str_batch_table +'
				FROM 
				(SELECT	
						[Gen State],
						YEAR([Vintage]) Vintage,
						[Technology] [Technology],
						SUM([Volume]) Volume,
						MAX(UOM) UOM,
						MAX(conversion_factor) conversion_factor
					FROM					
						#temp 
					WHERE
						(assignment=''Banked'' AND target_actual=''Actual'')
					GROUP BY [Gen State],YEAR([Vintage]),[Technology] 
					)a
					INNER JOIN #temp_market b ON a.[Gen State]=b.[Generation State]
							AND  (a.[Vintage])=b.[Vintage]	
							AND a.[Technology]=b.[Technology]	
				WHERE 1=1
				  AND a.[Gen State] IS NOT NULL
				 '+CASE WHEN @drill_state IS NOT NULL THEN ' AND a.[Gen State]='''+@drill_state+'''' ELSE '' END+
				  +CASE WHEN @drill_vintage IS NOT NULL THEN ' AND (a.[Vintage])='+CAST(@drill_vintage AS VARCHAR) ELSE '' END
				  +CASE WHEN @drill_technology IS NOT NULL THEN ' AND a.[Technology]='''+@drill_technology +'''' ELSE '' END+
			' GROUP BY 
				a.[Gen State],(a.[Vintage]),b.[Jurisdiction],a.[Technology]
			ORDER BY 
					a.[Gen State],(a.[Vintage]),b.[Jurisdiction]'
			
	END
	ELSE IF @detail_option='d'
	BEGIN



			SET @sql_stmt='
				SELECT 
					[Sub],
					[Strategy] ,
					[Book] ,
					[Obligation] ,
					[Tier Type],
					[Assignment],
					[target_actual] [Type] ,
					[State],
					'''+@drill_jurisdiction+''' as [Jurisdiction],
					[Vintage],
					[CertIDFrom],
					[CertIDTo],
					dbo.FNAHyperLinkText(10131000, cast([DealID] as varchar),cast([DealID] as varchar)) [DealID],  
					a.volume AS [volume],
					a.[uom] [UOM] '+ @str_get_row_number+' '+ @str_batch_table +'
				FROM #temp a
					LEFT JOIN source_deal_header sdh on a.DealID=sdh.source_deal_header_id
					LEFT JOIN source_deal_detail sdd on a.DealID=sdd.source_deal_header_id				
					LEFT JOIN rec_generator rg ON rg.generator_id=sdh.generator_id
					LEFT JOIN static_data_value sd on sd.value_id=rg.technology
			WHERE 1=1
				  AND (assignment=''Banked'' AND target_actual=''Actual'')
				  --AND sdd.volume_left>0
				 '+CASE WHEN @drill_state IS NOT NULL THEN ' AND [Gen State]='''+@drill_state+'''' ELSE '' END
				  +CASE WHEN @drill_vintage IS NOT NULL THEN ' AND YEAR([Vintage])='+CAST(@drill_vintage AS VARCHAR) ELSE '' END+
				  + CASE WHEN @drill_technology IS NOT NULL THEN ' AND sd.code='''+@drill_technology+'''' ELSE '' END +
			' ORDER BY 
					[Sub],[Strategy],[Book],[Obligation],[Tier Type],[Assignment],[target_actual] '
		
		
	END
	exec spa_print @sql_stmt
	EXEC(@sql_stmt)

END

if @is_batch = 1
BEGIN
	exec spa_print '@str_batch_table'  
	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
		   exec spa_print @str_batch_table
	 EXEC(@str_batch_table)                   
    

IF(@summary_option = 'm') 
	SET	@reportname = 'Run Market Value Report'
ELSE IF(@summary_option = 'e')
	SET	@reportname = 'Run Exposure Report'
Else
	SET	@reportname = 'Run Report'
   
	SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_REC_Exposure_Report',@reportname)         
	EXEC spa_print @str_batch_table
	EXEC(@str_batch_table)        
	EXEC spa_print 'finsh spa_REC_Exposure_Report'
	return

END

IF @enable_paging = 1
BEGIN
		IF @page_size IS NULL
		BEGIN
			set @sql_stmt='select count(*) TotalRow,'''+@batch_process_id +''' process_id  from '+ @temptablename
			EXEC spa_print @sql_stmt
			exec(@sql_stmt)
		END
END 
