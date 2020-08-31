/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 16:24:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_target_position_report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_target_position_report_paging]
GO 
/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 15:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROC [dbo].[spa_create_target_position_report_paging]
	@as_of_date varchar(50), 
	@sub_entity_id varchar(100), 
	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@assignment_type int = null,  --assignment_type  
	@summary_option char(1),  --'s' summary, 'd' detail that shows generator, 'i' shows indvidual deals -- 'x' -> called from Exposure report
	@compliance_year int,
	@assigned_state int = null,
	@include_banked varchar(1) = 'n',
	@curve_id int = NULL,
	@curve_name varchar(100)= NULL,
	@plot varchar(1) = 'n',
	@generator_id int = null,
	@convert_uom_id int = null,
	@convert_assignment_type_id int = null,
	@deal_id_from int = null,
	@deal_id_to int = null,
	@gis_cert_number varchar(250)= null,
	@gis_cert_number_to varchar(250)= null,
	@generation_state int=null,
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
	@allocate_banked CHAR(1)=NULL,
	@report_type CHAR(1)=NULL, -- 't' target report, 'p' trader position report
	@curve_source_value_id INT=NULL,
	@drill_State VARCHAR(100)=NULL,
	@batch_process_id varchar(50)=NULL,
	@page_size int =NULL,
	@page_no int=NULL 
 AS
 SET NOCOUNT ON 

EXEC [dbo].[spa_create_target_position_report]
	@as_of_date, 
	@sub_entity_id , 
	@strategy_entity_id, 
	@book_entity_id, 
	@assignment_type,  --assignment_type  
	@summary_option,  --'s' summary, 'd' detail that shows generator, 'i' shows indvidual deals -- 'x' -> called from Exposure report
	@compliance_year,
	@assigned_state,
	@include_banked,
	@curve_id,
	@curve_name,
	@plot,
	@generator_id,
	@convert_uom_id,
	@convert_assignment_type_id,
	@deal_id_from,
	@deal_id_to,
	@gis_cert_number,
	@gis_cert_number_to,
	@generation_state,
	@program_scope,
	@program_type, --- 'a' -> Compliance, 'b' -> cap&trade ,
	@round_value, 
	@show_cross_tabformat,
	@gen_date_from ,            
	@gen_date_to,  
	@include_expired,
	@carry_forward,
	@udf_group1,
	@udf_group2,
	@udf_group3,	
	@tier_type,
	@technology ,
	@allocate_banked,
	@report_type, -- 't' target report, 'p' trader position report
	@curve_source_value_id,
	@drill_State,
	@batch_process_id ,
	NULL,
	1   --'1'=enable, '0'=disable
	,@page_size 
	,@page_no 











