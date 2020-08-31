IF OBJECT_ID(N'[dbo].[spa_assign_rec_deals_schedule]', N'P') IS NOT NULL
   DROP PROCEDURE [dbo].[spa_assign_rec_deals_schedule]
GO


CREATE PROCEDURE [dbo].[spa_assign_rec_deals_schedule] 
		@fas_sub_id varchar(5000) = null,
		@fas_strategy_id varchar(5000) = null,
		@fas_book_id varchar(5000) = null,
		@assignment_type int,
		@assigned_state int,
		@compliance_year int, 
		@assigned_date varchar(20),
		@fifo_lifo varchar(1),
		@volume float,
		@curve_id int = NULL,
		@assigned_counterparty int = null,
		@assigned_price float = null,
		@trader_id int = null,		
		@unassign int = 0,
		@user_id varchar(50) = null,
		@total_tons float = NULL,
		@gen_state int=NULL,  
		@gen_year int=NULL,  
		@gen_date_from datetime=NULL,  
		@gen_date_to datetime=NULL,  
		@generator_id int=NULL,  
		@counterparty_id int=NULL,
		@book_deal_type_map_id int=NULL,
		@cert_from int=NULL,
		@cert_to int=NULL  
AS 

-- DECLARE @source_deal_header_id varchar(5000)
-- DECLARE @assignment_type int
-- DECLARE @assigned_state int
-- DECLARE @compliance_year int 
-- DECLARE @assigned_date varchar(20)
-- DECLARE @assigned_counterparty int
-- DECLARE @assigned_price float
-- DECLARE @trader_id int
-- 
-- 
-- SET @source_deal_header_id = '1283, 1284'
-- --SET @assignment_type = 5146
-- SET @assignment_type = 5173
-- set @assigned_state = 5118
-- SET @compliance_year = 2006
-- SET @assigned_date = '12/24/2005'
-- SET @assigned_counterparty = 2
-- SET @assigned_price = 2.89
-- SET @trader_id = 1

--Can't find deals for assigning to banked state

-- 	Select 'Success' ErrorCode, 'Assign RECs Job' Module, 'spa_assign_rec_deals_job', 
-- 		'Job Run Status' Status, 
-- 		('Assignment ')  Message, 
-- 		'' Recommendation		
-- 	RETURN
-- 
-- set @desc='Assignment of REC Transactions has been run and will complete shortly.'
-- 
-- EXEC spa_print @desc


declare @table_name varchar(128)
declare @source_deal_header_id varchar(5000)

set @source_deal_header_id = ''

set @table_name =dbo.FNAProcessTableName('recassign_', '',REPLACE(newid(),'-','_'))

--SET @table_name = 'recassign_' + 
EXEC spa_print @table_name

EXEC	spa_find_matching_rec_deals
		NULL,
		@fas_sub_id,
		@fas_strategy_id,
		@fas_book_id,
		@assignment_type,
		@assigned_state,
		@compliance_year, 
		@assigned_date,
		@fifo_lifo,
		@volume,
		@curve_id,
		@table_name,
		@unassign,
		@total_tons,
		@gen_state,
		@gen_year,
		@gen_date_from,
		@gen_date_to,
		@generator_id,
		@counterparty_id,
		@cert_from,
		@cert_to



EXEC spa_assign_rec_deals 
		@source_deal_header_id,
		@assignment_type,
		@assigned_state,
		@compliance_year, 
		@assigned_date,
		@assigned_counterparty,
		@assigned_price,
		@trader_id,
		@table_name,
		@unassign,
		@user_id,
		@gen_state,
		@gen_year,
		@gen_date_from,
		@gen_date_to,
		@generator_id,
		@counterparty_id,
		null




