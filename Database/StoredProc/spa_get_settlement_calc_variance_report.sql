
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

IF OBJECT_ID('[dbo].[spa_get_settlement_calc_variance_report]','p') IS NOT NULL
DROP PROC [dbo].[spa_get_settlement_calc_variance_report]
go

CREATE PROC [dbo].[spa_get_settlement_calc_variance_report]
	@flag char(1),
	@process_id varchar(100)
AS
SET NOCOUNT ON 

--DECLARE @prod_date DATETIME
--SET @prod_date='2008-06-01'

declare @stmt varchar(max)
declare @user_login_id varchar(100)
declare @test_process_id varchar(100)

declare @table_calc_invoice_volume_variance varchar(1000)
declare @table_calc_invoice_volume varchar(1000)

declare @c_calc_id	int,
	@c_counterparty_id	int,
	@c_counterparty_name	varchar(100),
	@c_code	varchar(500),
	@c_invoice_line_item_id	int,
	@c_prod_date	datetime,
	@c_allocationvolume_old	float,
	@c_allocationvolume_new	float,
	@c_value_old	float,
	@c_value_new	float,
	@c_volume_diff	float,
	@c_value_diff	float

set @user_login_id=dbo.FNADBUser()
set @test_process_id= @process_id
set @table_calc_invoice_volume_variance=dbo.FNAProcessTableName('calc_invoice_volume_variance', @user_login_id,@test_process_id)
set @table_calc_invoice_volume=dbo.FNAProcessTableName('calc_invoice_volume', @user_login_id,@test_process_id)


set @stmt = ''

if @flag = 'i'
begin

create table #temp_settlement_adjustments(
	calc_id	int,
	counterparty_id	int,
	counterparty_name	varchar(100) COLLATE DATABASE_DEFAULT,
	code	varchar(500) COLLATE DATABASE_DEFAULT,
	invoice_line_item_id	int,
	prod_date	datetime,
	allocationvolume_old	float,
	allocationvolume_new	float,
	value_old	float,
	value_new	float,
	volume_diff	float,
	value_diff	float
)

set @stmt = '
insert into #temp_settlement_adjustments (
	calc_id,counterparty_id,counterparty_name,code,invoice_line_item_id,prod_date,
	allocationvolume_old,allocationvolume_new,value_old,value_new,volume_diff,value_diff
)'

end

set @stmt = @stmt + '
SELECT 
	DISTINCT
	a.calc_id,
	a.COUNTERPARTY_ID,
	SC.COUNTERPARTY_NAME,
	SD.CODE,
	a.invoice_line_item_id,
	a.PROD_DATE,
	a.allocationvolume [OLD Volume],
	b.allocationvolume [NEW volume],	
	a.VALUE [OLD VALUE],
	b.VALUE [NEW VALUE],
	b.allocationvolume-a.allocationvolume [VOLUME DIFFERENCE],
	b.VALUE-a.VALUE [VALUE DIFFERENCE]

FROM
(
select  civ.calc_id,civv.counterparty_id,civv.prod_date,civv.as_of_date,civv.contract_id,civ.volume allocationvolume,civ.value,
  civ.invoice_line_item_id,civ.manual_input from 	
  calc_invoice_volume_variance civv 
	inner join CALC_INVOICE_VOLUME CIV on civv.calc_id=civ.calc_id
) a
	INNER JOIN 
(
select distinct civv.counterparty_id,civv.prod_date,civv.as_of_date,civv.contract_id,civ.volume allocationvolume,civ.value,
	civ.invoice_line_item_id,civ.manual_input from 	
 '+@table_calc_invoice_volume_variance+' civv 
	inner join '+@table_calc_invoice_volume+' CIV on civv.calc_id=civ.calc_id
) b
on 
	a.counterparty_id=b.counterparty_id
    and a.contract_id=b.contract_id
	and a.prod_date=b.prod_date
	and a.as_of_date=b.as_of_date
	and a.invoice_line_item_id=b.invoice_line_item_id
	and ISNULL(a.manual_input,'''')=isnull(b.manual_input,'''') 
    LEFT JOIN SOURCE_COUNTERPARTY SC ON SC.SOURCE_COUNTERPARTY_ID=a.COUNTERPARTY_ID
	LEFT JOIN STATIC_DATA_VALUE SD ON SD.VALUE_ID=a.INVOICE_LINE_ITEM_ID
WHERE 1=1

    
ORDER BY
	SC.COUNTERPARTY_NAME

'

--print (@stmt)
exec(@stmt)

--select * from #temp_settlement_adjustments

if @flag = 'i'
begin
	declare cur_adj cursor for 
		select 
			calc_id,counterparty_id,counterparty_name,code,invoice_line_item_id,prod_date,allocationvolume_old,allocationvolume_new,value_old,value_new,volume_diff,value_diff
		from #temp_settlement_adjustments

	open cur_adj
		fetch next from cur_adj into @c_calc_id,@c_counterparty_id,@c_counterparty_name,@c_code,@c_invoice_line_item_id,@c_prod_date,@c_allocationvolume_old,@c_allocationvolume_new,@c_value_old,@c_value_new,@c_volume_diff,@c_value_diff
	while @@FETCH_STATUS = 0
	begin
		if exists (select 'x' from settlement_adjustments where calc_id = @c_calc_id and invoice_line_item_id = @c_invoice_line_item_id)
		begin
			-- update
			EXEC spa_print 'update is running in settlement adjustments'
			update settlement_adjustments 
			set	counterparty_id = @c_counterparty_id,
				counterparty_name = @c_counterparty_name,
				code = @c_code,
				prod_date = @c_prod_date,
				allocationvolume_old = @c_allocationvolume_old,
				allocationvolume_new = @c_allocationvolume_new,
				value_old = @c_value_old,
				value_new = @c_value_new,
				volume_diff = @c_volume_diff,
				value_diff = @c_value_diff
			where calc_id = @c_calc_id and invoice_line_item_id = @c_invoice_line_item_id
		end
		else
		begin
			-- insert
			EXEC spa_print 'insert is running in settlement adjustments'
			insert into settlement_adjustments(calc_id,counterparty_id,counterparty_name,code,invoice_line_item_id,prod_date,allocationvolume_old,allocationvolume_new,value_old,value_new,volume_diff,value_diff)
				values (@c_calc_id,@c_counterparty_id,@c_counterparty_name,@c_code,@c_invoice_line_item_id,@c_prod_date,@c_allocationvolume_old,@c_allocationvolume_new,@c_value_old,@c_value_new,@c_volume_diff,@c_value_diff)
		end
		fetch next from cur_adj into @c_calc_id,@c_counterparty_id,@c_counterparty_name,@c_code,@c_invoice_line_item_id,@c_prod_date,@c_allocationvolume_old,@c_allocationvolume_new,@c_value_old,@c_value_new,@c_volume_diff,@c_value_diff
	end

	close cur_adj
	deallocate cur_adj
end



