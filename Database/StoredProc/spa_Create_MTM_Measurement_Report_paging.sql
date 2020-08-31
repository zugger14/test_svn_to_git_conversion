if object_id('spa_Create_MTM_Measurement_Report_paging') is not null
	DROP PROCEDURE [dbo].[spa_Create_MTM_Measurement_Report_paging]
 GO 

--exec spa_create_mtm_measurement_report_paging '2009-11-30','26',null,null,'d','a','a','d',null,'2',null,null,null,'D2CBD7C2_6B50_488B_8EBC_1282DEA426B0', 100, 1 
--exec spa_Create_MTM_Measurement_Report '2005-12-31', '1', '33', NULL, 'd', 'a', 'a', 'd', NULL,'2',NULL
--exec spa_create_mtm_measurement_report_paging '2009-11-30','26',null,null,'d','a','a','d',null,'2',null
--exec spa_create_mtm_measurement_report_paging '2009-11-30','26',null,null,'d','a','a','d',null,'2',null,NULL,NULL,'D2CBD7C2_6B50_488B_8EBC_1282DEA426B0', 100, 1 

--===========================================================================================
--This Procedure create Measuremetnt Reports
--Input Parameters
--@as_of_date - effective date
--@sub_entity_id - subsidiary Id
--@strategy_entity_id - strategy Id
--@book_entity_id - book Id
--@discount_option - takes two values 'd' or 'u', corresponding to 'discounted', 'undiscounted' 
--@settlement_option -  takes 'f','c','s','a' corrsponding to 'forward', 'current & forward', 'current & settled', 'all' transactions
--@report_type - takes 'f', 'c',  corresponding to 'fair value', 'cash flow'
--@summary_option - takes 'd', 's' corresponding to 'detail' , 'summary' report
--===========================================================================================
create PROC [dbo].[spa_Create_MTM_Measurement_Report_paging] 
	@as_of_date varchar(50), @sub_entity_id varchar(100), 
 	@strategy_entity_id varchar(100) = NULL, 
	@book_entity_id varchar(100) = NULL, @discount_option char(1), 
	@settlement_option char(1), @report_type char(1), @summary_option char(1),
	@link_id varchar(500) = null,
	@round_value varchar(1) = '0',
	@legal_entity varchar(50) = NULL,
	@source_deal_header_id VARCHAR(500)=NULL,
	@what_if VARCHAR(10)=NULL,
	@deal_id  VARCHAR(500)=NULL,
	@term_start DATETIME=NULL,
	@term_end DATETIME=NULL,
	@process_id varchar(200)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL 
 AS
 SET NOCOUNT ON 
 
 
--print 'paging'
EXEC [dbo].[spa_Create_MTM_Measurement_Report] 
@as_of_date, 
@sub_entity_id, 
@strategy_entity_id,
@book_entity_id,
@discount_option, 
@settlement_option, 
@report_type, 
@summary_option,
@link_id,
@round_value ,
@legal_entity ,
@source_deal_header_id,	
@what_if ,	
@deal_id ,	
@term_start,
@term_end,
@process_id , 
NULL,1,
@page_size ,
@page_no
	
	