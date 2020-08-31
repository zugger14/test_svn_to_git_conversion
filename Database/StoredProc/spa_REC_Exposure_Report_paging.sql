IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_REC_Exposure_Report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_REC_Exposure_Report_paging]
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE   PROC [dbo].[spa_REC_Exposure_Report_paging]
	@summary_option CHAR(1)='e',
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
--	@batch_report_param varchar(500)=NULL,
--	@enable_paging INT=NULL,
	@page_size int =NULL,
	@page_no int=NULL


 AS
 SET NOCOUNT ON 
BEGIN
	EXEC spa_REC_Exposure_Report @summary_option,@as_of_date, 
	@sub_entity_id, 
	@strategy_entity_id, 
	@book_entity_id, 
	@report_type,  --assignment_type  
	@compliance_year ,
	@assigned_state,
	@curve_id ,
	@convert_uom_id ,
	@program_scope,
	@program_type, --- 'a' -> Compliance, 'b' -> cap&trade 
	@round_value ,
	@udf_group1,
	@udf_group2 ,
	@udf_group3,	
	@tier_type,
	@detail_option, -- 'm' - maximum value , 'a' - All values
    @generation_state,
	@technology,
	@drill_state,
	@drill_vintage,
	@drill_jurisdiction,
	@drill_technology,
  	@batch_process_id,
	NULL,
	1 ,  --'1'=enable, '0'=disable
	@page_size ,
	@page_no 
END