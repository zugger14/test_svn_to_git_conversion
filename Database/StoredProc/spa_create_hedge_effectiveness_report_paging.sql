IF OBJECT_ID(N'spa_create_hedge_effectiveness_report_paging', N'P') IS NOT NULL
	DROP PROC [dbo].[spa_create_hedge_effectiveness_report_paging]
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC spa_create_hedge_effectiveness_report '36', NULL, NULL, '2009-08-31', null, 'b', 'd', 2, 's'

CREATE PROC [dbo].[spa_create_hedge_effectiveness_report_paging] (
			@sub_entity_id varchar(100), 
			@strategy_entity_id varchar(100), 
			@book_entity_id varchar(100),
			@as_of_date varchar(20), 
			@link_id varchar(50)=NULL, 
			@link_id_to varchar(50)=NULL, 
			@link_desc varchar(50)=NULL, 
			@hedge_mtm varchar(1)='h', 
			@disc_undis varchar(1) ='d', 
			@rounding int = 2,
			@summary_detail varchar(1)='d', 
			@source_deal_header_id INT=NULL, 
			@deal_id VARCHAR(255)=NULL,
			
			@process_id VARCHAR(200) = NULL,
			@page_size VARCHAR(50) = NULL,
			@page_no INT = NULL 
)
AS
SET NOCOUNT ON 

exec [dbo].[spa_create_hedge_effectiveness_report] 
		@sub_entity_id, 
		@strategy_entity_id, 
		@book_entity_id,
		@as_of_date, 
		@link_id, 
		@link_id_to,
		@link_desc,
		@hedge_mtm, 
		@disc_undis, 
		@rounding,
		
		@summary_detail,
		@source_deal_header_id,
		@deal_id,
		@process_id,
		NULL,
		1   --'1'=enable, '0'=disable
		,@page_size 
		,@page_no 
