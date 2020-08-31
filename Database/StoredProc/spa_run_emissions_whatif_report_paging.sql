/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 16:24:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_emissions_whatif_report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_emissions_whatif_report_paging]
GO 
/****** Object:  StoredProcedure [dbo].[spa_get_rec_activity_report_paging]    Script Date: 06/25/2009 15:13:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROC [dbo].[spa_run_emissions_whatif_report_paging]
	@flag char(1)='s', -- 's' summary,'d' detail
	@report_type char(1)='1', -- 1->Emissions,2->Intensity,3->Rate,4->Net Mwh
	@group_by char(1)='1', -- 1->Operating Compnay, 2->Business Units, 3->States, 4->Source/Sinks
	@sub_entity_id varchar(100)=null,
	@strategy_entity_id varchar(500)=null,
	@fas_book_id varchar(500)=null,
	@as_of_date datetime=null,
	@term_start datetime=null,
	@term_end datetime=null,
	@technology int=null,
	@fuel_value_id int=null,
	@ems_book_id varchar(200)=null,
	@curve_id int=null,
	@convert_uom_id int=null,
	@show_co2e char(1)='n',
	@technology_sub_type int=null,
	@fuel_type int=null,
	@source_sink_type int=null,
	@reduction_type int = NULL, 
	@reduction_sub_type int = NULL, 	   
	@udf_source_sink_group int=null,
	@udf_group1 int=null,
	@udf_group2 int=null,
	@udf_group3 int=null,
	@frequency int=null,
	@protocol int=null,
	@include_hypothetical CHAR(1)='n',
	@drill_criteria VARCHAR(100)=NULL,
	@drill_group CHAR(1)=NULL,
	@round_value CHAR(1)='0',
	--@batch_process_id varchar(50)=NULL,
	--@batch_report_param varchar(500)=NULL   ,
	@process_id varchar(200)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL 


 AS
 SET NOCOUNT ON
	

		exec  spa_run_emissions_whatif_report s, 
		@report_type,  
		@group_by,  
		@sub_entity_id,  
		@strategy_entity_id,  
		@fas_book_id, 
		@as_of_date, 
		@term_start, 
		@term_end,
		@technology, 	
		@fuel_value_id,  
		@ems_book_id,  
		@curve_id,  
		@convert_uom_id,  
		@show_co2e, 
		@technology_sub_type, 
		@fuel_type, 
		@source_sink_type,
		@reduction_type, 
		@reduction_sub_type, 
		@udf_source_sink_group,  
		@udf_group1,  
		@udf_group2,  
		@udf_group3,  
		@frequency, 
		@protocol, 
		@include_hypothetical, 
		@drill_criteria,
		@drill_group, 
		@round_value, 
--		@tempTable,  
		@process_id,
		NULL,
		1   --'1'=enable, '0'=disable
		,@page_size 
		,@page_no 

		
		
		




