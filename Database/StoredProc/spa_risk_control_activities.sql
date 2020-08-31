
if object_id('[dbo].[spa_risk_control_activities]','p') is not null
DROP proc [dbo].[spa_risk_control_activities]
go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

CREATE proc [dbo].[spa_risk_control_activities] 
                     @processNumber int=null,
                     @subID varchar(30)=null,
                     @strategy_id varchar(30)=null,
                     @book_id varchar(10)=null, 
                     @risk_description_id int=null, 
                     @activity_category_id int=null,
					 @who_for int=null, 
					 @where int=null, 
					 @why int=null, 
					 @activity_area int=null,
                     @activity_sub_area int=null,
                     @activity_action int=null, 
                     @activity_desc varchar(250)=null, 
                     @control_type int=null, 
                     @montetory_value_defined char(1)=null,
                     @process_owner varchar(30)=null,
                     @risk_owner varchar(30)=null, 
                     @risk_control_id int=null
                                       
AS
BEGIN
CREATE TABLE #tempControls_refine (
	[Subsidiary] [varchar](200) COLLATE DATABASE_DEFAULT NULL ,
	[control_type] [varchar](50) COLLATE DATABASE_DEFAULT  NULL,
    [run_frequency] [varchar](50) COLLATE DATABASE_DEFAULT NULL,
    [control_type_id]  int NULL,
    [process_id] int NULL,
    [control_activity][varchar](200) COLLATE DATABASE_DEFAULT NULL,
	[risk_description_id] int  NULL,
    [risk_control_id] int NULL,
    [process_internal] [char](1) COLLATE DATABASE_DEFAULT  NULL,
    [process_number] [varchar] (200) COLLATE DATABASE_DEFAULT NULL, 
    [risk_description] [varchar] (200) COLLATE DATABASE_DEFAULT NULL 
    
 
)

declare @sql varchar(5000)


	set @sql='INSERT #tempControls_refine SELECT (sub.entity_name + ''.'' +stra.entity_name + ''.'' + book.entity_name) AS  Subsidiary,'
    set @sql = @sql + 'ISNULL(ct.code,'''') AS control_type,'
    
    set @sql = @sql + 'ISNULL(rf.code,'''') AS run_frequency,'
    set @sql = @sql + 'ISNULL(prc.control_type,'''') AS control_type_id,'
    set @sql = @sql + 'cast(pch.process_id as varchar) as process_id,'
    set @sql = @sql + 'isnull((prr.requirement_no), '''') + ISNULL(DBO.FNAGetActivityName(prc.risk_control_id),'''') control_activity,'
   
    
    
    
   
    set @sql = @sql + 'cast(prd.risk_description_id as varchar) as risk_description_id,'
    set @sql = @sql + 'isnull(cast(prc.risk_control_id as varchar), '''') as risk_control_id,'
    set @sql = @sql + 'pch.process_internal as process_internal,'
   -- set @sql = @sql +'dbo.FNAComplianceHyperlink('a',229, ''Detail...'', cast(pch.process_id as varchar)) ph_url,'
   -- set @sql = @sql + ' dbo.FNAComplianceHyperlink('a',230, ''Detail...'', cast(prd.risk_description_id as varchar)) rd_url,'
   -- set @sql = @sql + 'dbo.FNAComplianceHyperlink('a',231, ''Detail...'', cast(prc.risk_control_id as varchar)) rc_url,'
    set @sql = @sql + '(pch.process_number +  ( + pch.process_name + '' - '' + '' Owner: '' + isnull(aup.user_l_name, '''') + '', '' + isnull(aup.user_f_name, '''') + '' '' + isnull(aup.user_m_name, '''')  )) as process_number,'
    set @sql = @sql +  'ISNULL((cast(prd.risk_description_id as varchar) + '' - '' + isnull(prd.risk_description, ''Not Defined'') + ''Owner:'' + isnull(au.user_l_name, '''') + '', '' + isnull(au.user_f_name, '''') + '' '' + isnull(au.user_m_name, '''') +'')''),'''') risk_description'
    
    
    

    set @sql = @sql + ' from PROCESS_RISK_CONTROLS prc  LEFT OUTER JOIN
                PROCESS_RISK_DESCRIPTION prd ON prd.risk_description_id = prc.risk_description_id LEFT OUTER JOIN 
            PROCESS_CONTROL_HEADER pch ON pch.process_id = prd.process_id LEFT OUTER JOIN
             portfolio_hierarchy book ON book.entity_id = prc.fas_book_id LEFT OUTER JOIN 
             portfolio_hierarchy stra ON stra.entity_id = book.parent_entity_id LEFT OUTER JOIN 
           portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id LEFT OUTER JOIN 
           APPLICATION_USERS au ON au.user_login_id = prd.risk_owner LEFT OUTER JOIN 
            APPLICATION_USERS aup ON aup.user_login_id = pch.process_owner LEFT OUTER JOIN 
            STATIC_DATA_VALUE rp ON rp.value_id = prd.risk_priority LEFT OUTER JOIN 
            STATIC_DATA_VALUE rf ON rf.value_id = prc.run_frequency LEFT OUTER JOIN 
            STATIC_DATA_VALUE ct ON ct.value_id = prc.control_type LEFT OUTER JOIN 
             static_data_value area on area.value_id = prc.activity_area_id LEFT OUTER JOIN 
             static_data_value sarea on sarea.value_id = prc.activity_sub_area_id LEFT OUTER JOIN 
            static_data_value action on action.value_id = prc.activity_action_id  LEFT OUTER JOIN 
             process_requirements_revisions prr on prr.requirements_revision_id = prc.requirements_revision_id' 
   
    If @subID is not NULL 
                 
                set  @sql = @sql + ' WHERE sub.entity_id IN' + '('+@subID+')'
    


    Else
             set   @sql = @sql +  ' WHERE 1 = 1'
            
            If @strategy_id is not NULL 
               set  @sql = @sql + ' AND stra.entity_id IN ' + '('+@strategy_id+')' 

           
            If @book_id is not NULL 
               set  @sql = @sql + ' AND book.entity_id IN ' + '('+@book_id+')' 
           
         
            If @processNumber is not NULL 
                set  @sql = @sql + ' AND pch.process_id = ' + cast(@processNumber as varchar)
          
            If @risk_description_id is not NULL 
               set  @sql = @sql + 'AND prc.risk_description_id =' + cast(@risk_description_id as varchar)
            
            If @activity_category_id is not NULL 
              set   @sql = @sql + 'AND prc.activity_category_id =' + cast(@activity_category_id as varchar)
           
            If @who_for is not NULL 
                set   @sql = @sql + ' AND prc.activity_who_for_id ='  + cast(@who_for as varchar)
           
            If @where is not NULL 
                set   @sql = @sql + 'AND prc.where_id ='  + cast(@where as varchar)
           
            If @why is not NULL 
                 set   @sql = @sql + 'AND prc.control_objective = ' + cast(@why as varchar)
           
            If @activity_area is not NULL  
                 set   @sql = @sql + ' AND prc.activity_area_id = ' + cast(@activity_area as varchar)
          
            If @activity_sub_area is not NULL 
                set   @sql = @sql + 'AND prc.activity_sub_area_id ='  + cast(@activity_sub_area as varchar)
            
            If @activity_action is not NULL
                set   @sql = @sql + 'AND prc.activity_action_id ='  + cast(@activity_action as varchar)
           
            If @activity_desc is not NULL 
               set   @sql = @sql + 'AND (isnull(area.code + '' > '', '''') + isnull(sarea.code + '' > '', '''')  + isnull(action.code + '' > '', '''') + isnull(prc.risk_control_description, '''')) LIKE ''% '+@activity_desc+' %'''
           
            


             If @control_type is not NULL 
                set   @sql = @sql + 'AND prc.control_type = ' + cast(@control_type as varchar)
           
            If @montetory_value_defined is not NULL And upper(@montetory_value_defined) = 'Y' 
               set   @sql = @sql + 'AND prc.monetary_value_changes IS NOT NULL '
          
            
           
            If @risk_owner is not NULL 
                set   @sql = @sql +  'AND prd.risk_owner = ' + ''''+@risk_owner+'''' 

           If @process_owner is not NULL 
                set   @sql = @sql +  'AND pch.process_owner = ' + ''''+@process_owner+'''' 
            
            If @risk_control_id is not NULL 
                 set   @sql = @sql + 'AND prc.risk_control_id ='  + cast(@risk_control_id as varchar)
          



            set   @sql = @sql + ' ORDER BY pch.process_id, prd.risk_description_id, prc.risk_control_id'  
 EXEC spa_print @sql
	
   exec(@sql)


SELECT #tempControls_refine.Subsidiary as Org,
       #tempControls_refine.process_number + ' ' + dbo.FNAComplianceHyperlink('a',10121010,'Detail...', cast(#tempControls_refine.process_id as varchar),default,default,default,default,default,default) as 'Group 1 (Process)', 
       #tempControls_refine.risk_description + ' ' +dbo.FNAComplianceHyperlink('a',10121012, 'Detail...', cast(#tempControls_refine.risk_description_id as varchar),default,default,default,default,default,default) as 'Group 2 (Risk)',  
       dbo.FNAComplianceHyperlink('a',333, #tempControls_refine.control_activity, cast(#tempControls_refine.risk_control_id as varchar),default,default,default,default,default,default) + ' '+ dbo.FNAComplianceHyperlink('a',10121015, 'Detail...', cast(#tempControls_refine.risk_control_id as varchar),default,default,default,default,default,default) AS 'Activities (Controls)',
       #tempControls_refine.run_frequency as Frequency,
       #tempControls_refine.control_type  as 'Control Type'
      
 FROM #tempControls_refine

	   
END










