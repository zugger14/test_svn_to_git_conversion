IF OBJECT_ID(N'spa_GetAllUnapprovedItemGen_paging', N'P') IS NOT NULL
DROP PROCEDURE spa_GetAllUnapprovedItemGen_paging
 GO 





create PROCEDURE [dbo].[spa_GetAllUnapprovedItemGen_paging] 
	@book_id varchar(100), 
	@as_of_date_from varchar(20),
	@as_of_date_to	varchar(20),
	@create_ts varchar(1)='n',
	@show_approved varchar(1) = 'n',
	@status_flag CHAR(1) = NULL,
	@process_id VARCHAR(200) = NULL,
	@page_size VARCHAR(50) = NULL,
	@page_no INT = NULL 

AS

SET NOCOUNT ON

exec [dbo].[spa_GetAllUnapprovedItemGen]
	@book_id,
	@as_of_date_from,
	@as_of_date_to,
	@create_ts,
	@show_approved,
	@status_flag ,
	@process_id,
	NULL,
	1   --'1'=enable, '0'=disable
	,@page_size 
	,@page_no 
	