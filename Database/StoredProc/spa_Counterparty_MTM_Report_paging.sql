/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Period_Report_paging]    Script Date: 09/03/2009 12:59:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_Counterparty_MTM_Report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_Counterparty_MTM_Report_paging]
/****** Object:  StoredProcedure [dbo].[spa_Create_MTM_Period_Report_paging]    Script Date: 09/03/2009 12:59:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===========================================================================================
CREATE PROC [dbo].[spa_Counterparty_MTM_Report_paging]
					@as_of_date varchar(50),
					@previous_as_of_date varchar(50) = null,
					@sub_entity_id varchar(500), 
					@strategy_entity_id varchar(100) = NULL, 
					@book_entity_id varchar(100) = NULL, 
		--			@discount_option char(1, 
					@settlement_option char(1), 
	--				@report_type char(1, 
					@summary_option char(1),
					@counterparty_id varchar(500)= NULL, 
					@tenor_from varchar(50)= null,
					@tenor_to varchar(50) = null,
					
					@trader_id int = null,
					@include_item char(1)='n', -- to include item in cash flow hedge
					@source_system_book_id1 int=NULL, 
					@source_system_book_id2 int=NULL, 
					@source_system_book_id3 int=NULL, 
					@source_system_book_id4 int=NULL, 
				--	@show_firstday_gain_loss char(1)='n', -- To Show First Day Gain/Loss
					@transaction_type VARCHAR(500)=null,
					@deal_id_from int=null,
					@deal_id_to int=null,
					@deal_id varchar(100)=null,
					@threshold_values float=null,
					@show_prior_processed_values char(1)='n',
					@exceed_threshold_value char(1)='n',   -- For First Day gain Loss Treatment selection
				--	@show_only_for_deal_date char(1)='y',
					@use_create_date char(1)='n',
					@round_value char(1) = '0',
					@counterparty char(1) = 'a', --i means only internal and e means only external, a means all
			--		@mapped char(1) = 'm', --m means mapped only, n means non-mapped only,
					@match_id char(1) = 'n', --'y' means use like for deal ids and 'n' means use 
					@cpty_type_id int = NULL,  
					@curve_source_id INT,
					@deal_sub_type CHAR(1)='t',
					@deal_date_from varchar(20)=NULL,
					@deal_date_to varchar(20)=NULL,
					@phy_fin varchar(1)='b',
					@deal_type_id int=NULL,
					@period_report varchar(1)='n',
					@term_start VARCHAR(20)=NULL,
					@term_end VARCHAR(20)=NULL,
					@settlement_date_from VARCHAR(20)=NULL,
					@settlement_date_to VARCHAR(20)=NULL,
					@settlement_only CHAR(1)='n',
					@grouping CHAR(1)='a',     --a=Sub/Strategy/Book; b=Sub/Strategy/Book/Counterparty; c=Counterparty
												--d= Book; e=Sub f=Strategy
					@deal_list_table VARCHAR(200) = NULL,							
					@process_id varchar(50)=NULL,
					@page_size int =NULL,
					@page_no int=NULL
					

AS

SET NOCOUNT ON

	exec  spa_Counterparty_MTM_Report 
	@as_of_date, 
	@previous_as_of_date,
	@sub_entity_id, 
	@strategy_entity_id, 
	@book_entity_id, 
	@settlement_option,
	@summary_option,
	@counterparty_id,
	@tenor_from,
	@tenor_to,
	
	@trader_id,
	@include_item,
	@source_system_book_id1,
	@source_system_book_id2,
	@source_system_book_id3,
	@source_system_book_id4,
	@transaction_type,
	@deal_id_from,
	@deal_id_to,
	@deal_id,
	@threshold_values,
@show_prior_processed_values,
	@exceed_threshold_value,
	@use_create_date,
	@round_value,
	@counterparty,
	@match_id,
	@cpty_type_id,
	@curve_source_id,
	@deal_sub_type,
	@deal_date_from,
	@deal_date_to,
	@phy_fin,
	@deal_type_id,
	@period_report,
	@term_start,
	@term_end,
	@settlement_date_from,
	@settlement_date_to,
	@settlement_only,
	@grouping,
	@deal_list_table,
	 @process_id         
	,NULL
	,1   --'1'=enable, '0'=disable
	,@page_size 
	,@page_no 
