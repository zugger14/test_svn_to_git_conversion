/****** Object:  StoredProcedure [dbo].[spa_REC_Target_Report_Drill]    Script Date: 09/01/2009 00:39:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_REC_Target_Report_Drill]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_REC_Target_Report_Drill]
/****** Object:  StoredProcedure [dbo].[spa_REC_Target_Report_Drill]    Script Date: 09/01/2009 00:39:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_REC_Target_Report_Drill]  
 @as_of_date varchar(50),   
 @sub_entity_id varchar(100),   
 @strategy_entity_id varchar(100) = NULL,   
 @book_entity_id varchar(100) = NULL,   
 @report_type int = null,  --assignment_type    
 --@summary_option char(1), --always 'd'  
 @compliance_year VARCHAR(100),  
 @assigned_state int = null,  
 @include_banked varchar(1) = 'n', -- always 'n'  
 @curve_id int = NULL,  
 @generator_id int = null,  
 @convert_uom_id int = null,  
 @convert_assignment_type_id int = null,  
 @deal_id_from int = null,  
 @deal_id_to int = null,  
 @gis_cert_number varchar(250)= null,  
 @gis_cert_number_to varchar(250)= null,  
 @generation_state int=NULL, 
 @program_scope varchar(50)=null,
 @program_type char(1)='b', --- 'a' -> Compliance, 'b' -> cap&trade ,
 @round_value CHAR(1)='0', 
 @show_cross_tabformat CHAR(1)='n',
 @gen_date_from varchar(20) = null,            
 @gen_date_to varchar(20) = null,  
 @include_expired CHAR(1)='n',
 @carry_forward CHAR(1)='n',
 @udf_group1 INT=NULL,
 @udf_group2 INT=NULL,
 @udf_group3 INT=NULL,	
 @tier_type INT=NULL,
 @technology INT=NULL,
 @Sub varchar(100) = null,  
 @Strategy varchar(100) = null,  
 @Book varchar(100) = null,  
 @State varchar(1000) = null,  
 @Year VARCHAR(100),  
 @Assignment varchar (50) ,  
 @Obligation varchar (100),   
 @type varchar(20) = null  
 AS  
  
SET NOCOUNT ON  
DECLARE @sql varchar(8000)
  
CREATE TABLE [dbo].[#temp_drill] (  
	 [Sub] varchar(100),  
	 [Strategy] varchar(100),  
	 [Book] varchar(100),  
	 [Env Product] [varchar] (100) ,
	 [Tier Type] VARCHAR(100),  
	 [Technology] VARCHAR(100),  
	 [Assignment] [varchar] (50) ,  
	 [Type] varchar (50),  
	 [Assigned/Default Jurisdiction] varchar(1000),  
	 [Gen State] VARCHAR(50),
	 [Complaince Year] VARCHAR(20), 
	 [Vintage] VARCHAR(100) ,  
	 [Cert # From] varchar(250),  
	 [Cert # To] varchar(250),  
	 [Original RefID] varchar (1000),  
	 [Volume] [float] ,  
	 [Bonus] [float] ,  
	 [Total Volume (+Long, -Short)] [float] ,  
	 [UOM] [varchar] (100)  ,
	 conversion_factor float
) ON [PRIMARY]  
  
--INSERT #temp  
EXEC spa_REC_Target_Report @as_of_date, @sub_entity_id, @strategy_entity_id, @book_entity_id, @report_type,   
'g', @compliance_year, @assigned_state, @include_banked, @curve_id,  
NULL, 'n', @generator_id, @convert_uom_id, @convert_assignment_type_id, @deal_id_from,  
@deal_id_to, @gis_cert_number, @gis_cert_number_to,@generation_state,@program_scope,@program_type,
@round_value,@show_cross_tabformat,@gen_date_from,@gen_date_to,@include_expired,@carry_forward,@udf_group1,
@udf_group2,@udf_group3,@tier_type,@technology

set @sql=' Select * from #temp_drill  
Where (Sub = '''+@Sub+''' OR Sub = '''+@Obligation+''' OR ISNULL([Tier Type],-1)='''+@Sub+''')' + 
case when (@Strategy is null or @Strategy='' ) then '' else '  
 AND Strategy = isnull('''+@Strategy+''', Strategy)' end 
+
 case when (@State is null or @State='' ) then '' else '
 AND [Assigned/Default Jurisdiction] like (''%' + @State + '%'') ' end +
 case when @year is null then '' 
	  WHEN LTRIM(RTRIM(@year))='Carry Forward' Then ' AND [Complaince Year] <'+ISNULL(CAST(YEAR(@as_of_date) as varchar),'NULL')
	  ELSE  ' AND [Complaince Year] ='+ISNULL(CAST(@year as varchar),'NULL') end +' AND  
 Assignment ='''+ @Assignment+'''  AND ([Env Product] ='''+ @Obligation+''' OR [Env Product] ='''+ @Sub+''' OR [technology] ='''+ @Sub+''' OR ISNULL([Tier Type],-1)='''+@Sub+''')AND  
 Type ='''+ @type+'''  
 order by Sub, Strategy, Book, [Assigned/Default Jurisdiction], [Vintage] , Assignment  '

EXEC spa_print @sql
EXEC (@sql)








