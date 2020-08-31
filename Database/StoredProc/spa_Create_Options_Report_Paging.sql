set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

--  exec spa_Create_Position_Report '2006-12-31', '1', '215', '216', 'm', '4', 'a', 301, 319, -3, -4

IF OBJECT_ID('[dbo].[spa_Create_Options_Report_Paging]','p') IS NOT NULL 
drop proc [dbo].[spa_Create_Options_Report_Paging]
go

CREATE proc [dbo].[spa_Create_Options_Report_Paging]
	@report_type char(1),  --Show options expiration 'e' and Show options Greeks 'g'
	@summary_option varchar(1) = 's',
	@as_of_date varchar(50), 
	@sub_entity_id varchar(500) = NULL, 
	@strategy_entity_id varchar(500) = NULL, 
	@book_entity_id varchar(100) = NULL, 
	@counterparty_id varchar(500)= NULL, 
	@tenor_from varchar(50)= null, @tenor_to varchar(50) = null,
	@trader_id int = null,
	@source_system_book_id1 int=NULL, 
	@source_system_book_id2 int=NULL, 
	@source_system_book_id3 int=NULL, 
	@source_system_book_id4 int=NULL, 
	@deal_id_from varchar(100)=null,
	@deal_id_to varchar(100)=null,
	@deal_id varchar(100)=null,
	@round int = 4,
	@option_status varchar(1)=null, -- 'i' In-the-money, 'o' Out-the-money, 'a' At-the-money
	@curve_source_value_id int = 4500 ,
	@transaction_type VARCHAR(100)=NULL,
	@process_id varchar(200)=NULL, 
	@page_size int =NULL,
	@page_no int=NULL 
	
 AS

SET NOCOUNT ON


declare @user_login_id varchar(50),@tempTable varchar(500) ,@flag char(1)
set @user_login_id=dbo.FNADBUser()

if @report_type = 'e' and @summary_option = 'd'
	set @report_type = 'g'
if @process_id is NULL
Begin
	set @flag='i'
	set @process_id=REPLACE(newid(),'-','_')
End
set @tempTable=dbo.FNAProcessTableName('paging_temp_Options_Report', @user_login_id,@process_id)

declare @sqlStmt varchar(max)

if @flag='i'
begin
--if @summary_option='s'

	if @report_type = 'e'
	begin

		set @sqlStmt='create table '+ @tempTable+'( 
			sno int  identity(1,1),
			Subsidiary varchar(500),
			Strategy varchar(500),
			Book varchar(500),
			deal_id int,
			ref_deal_id varchar(100),
			term datetime,
			expiration datetime,
			expiry_status varchar(20),
			counterparty_name varchar(100),
			option_type varchar(10),
			excercise_type varchar(10),
			underlying_index varchar(50),
			deal_volume float,
			deal_volume_frequency varchar(50),
			uom_name varchar(50),
			strike_price float,
			current_price float,
			currency_name varchar(50),
			option_status varchar(50)
			)'
	end
	else if @report_type = 'g'
	begin
		if @summary_option = 's'
		begin

			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				Subsidiary varchar(500),
				Strategy varchar(500),
				Book varchar(500),
				underlying_index varchar(50),
				term datetime,
				expiration datetime,
				strike_price float,
				deal_volume float,
				deal_volume_frequency varchar(50),
				uom_name varchar(50),
				option_status varchar(50),
				options_price FLOAT,
				currency_name varchar(50),
				premium float,
				currency_name varchar(50),
                [Premium Calc] float ,
				delta float,
				gamma float,
				vega float,
				theta float,
				rho float
				)'
		end
		else if @summary_option = 'd'
		begin
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				Subsidiary varchar(500),
				Strategy varchar(500),
				Book varchar(500),
				Book1 varchar(100),
				Book2 varchar(100),
				Book3 varchar(100),
				Book4 varchar(100),
				deal_id varchar(1000),
				ref_deal_id varchar(100),
				term varchar(20),
				expiration varchar(20),
				expiry_status varchar(20),
				counterparty_name varchar(100),
				option_type varchar(10),
				excercise_type varchar(10),
				underlying_index varchar(50),
				deal_volume float,
				deal_volume_frequency varchar(100),
				uom_name varchar(100),
				options_premium FLOAT,
				strike_price float,
				expiry_year float,
				annual_intrate float,
				annual_vol float,
				annual_imp_vol float,
				current_price float, 
				currency_name varchar(100),
				option_status varchar(100),
				premium float,
				delta float,
				delta2 float,
				gamma float,
				gamma2 float,
				vega float,
				--vega2 float,
				theta float,
				rho float
				)'
		end
		else
		begin
			set @sqlStmt='create table '+ @tempTable+'( 
				sno int  identity(1,1),
				deal_id int,
				ref_deal_id varchar(100),
				term datetime,
				expiration datetime,
				option_type varchar(10),
				excercise_type varchar(10),
				underlying_index varchar(50),
				deal_volume float,
				deal_volume_frequency varchar(50),
				uom_name varchar(50),
				strike_price float,
				current_price float, 
				currency_name varchar(50),
				option_status varchar(50),
				premium float,
				delta float,
				gamma float,
				vega float,
				theta float,
				rho float
				)'
		end
		
	end
	exec(@sqlStmt)

--Sub,Strategy,Book,DealID,RefDealID,Term,Expiration,Expiration Status,Counterparty,Option Type,Excercise Type,
-- Underlying Index,Volume,Frequency,UOM,Strike,Currency,Current Price,Status

	set @sqlStmt='insert  '+@tempTable+'
	exec  spa_Create_Options_Report '+ 
	dbo.FNASingleQuote(@report_type) +','+ 
	dbo.FNASingleQuote(@summary_option) +','+ 
	dbo.FNASingleQuote(@as_of_date) +','+ 
	dbo.FNASingleQuote(@sub_entity_id) +','+ 
	dbo.FNASingleQuote(@strategy_entity_id) +','+ 
	dbo.FNASingleQuote(@book_entity_id) +','+ 
	dbo.FNASingleQuote(@counterparty_id) +',' +
	dbo.FNASingleQuote(@tenor_from) +',' +
	dbo.FNASingleQuote(@tenor_to) +',' +
	dbo.FNASingleQuote(@trader_id) +',' +
	dbo.FNASingleQuote(@source_system_book_id1)+',' +
	dbo.FNASingleQuote(@source_system_book_id2)+','+
	dbo.FNASingleQuote(@source_system_book_id3)+','+
	dbo.FNASingleQuote(@source_system_book_id4)+','+
	dbo.FNASingleQuote(@deal_id_from) +','+
	dbo.FNASingleQuote(@deal_id_to) +','+
	dbo.FNASingleQuote(@deal_id) +','+
	dbo.FNASingleQuote(@round)+','+
	dbo.FNASingleQuote(@option_status)+','+
	dbo.FNASingleQuote(@curve_source_value_id )+','+
	dbo.FNASingleQuote(@transaction_type)

--	@report_type char(1),  --Show options expiration 'e' and Show options Greeks 'g'
--	@summary_option varchar(1) = 's',
--	@as_of_date varchar(50), 
--	@sub_entity_id varchar(100) = NULL, 
--	@strategy_entity_id varchar(100) = NULL, 
--	@book_entity_id varchar(100) = NULL, 
--	@counterparty_id varchar(500)= NULL, 
--	@tenor_from varchar(50)= null, @tenor_to varchar(50) = null,
--	@trader_id int = null,
--	@source_system_book_id1 int=NULL, 
--	@source_system_book_id2 int=NULL, 
--	@source_system_book_id3 int=NULL, 
--	@source_system_book_id4 int=NULL, 
--	@deal_id_from int=null,
--	@deal_id_to int=null,
--	@deal_id varchar(100)=null,
--	@round int = 4,
--	@option_status

	
	EXEC spa_print @sqlStmt
	exec(@sqlStmt)	

	set @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	EXEC spa_print @sqlStmt
	exec(@sqlStmt)

end
else
begin
declare @row_to int,@row_from int
set @row_to=@page_no * @page_size
if @page_no > 1 
set @row_from =((@page_no-1) * @page_size)+1
else
set @row_from =@page_no

end




if @report_type = 'e'
BEGIN
	set @sqlStmt='select 
		Subsidiary Sub,Strategy,Book,deal_id DealID,ref_deal_id RefDealID,dbo.FNADateFormat(term) [Term],
		dbo.FNADateFormat(expiration) [Expiration],expiry_status [Expiration Status],counterparty_name [Counterparty],
		option_type [Option Type],excercise_type [Exercise Type],underlying_index [Underlying Index],
		deal_volume [Volume],deal_volume_frequency [Frequency],uom_name [UOM],strike_price [Strike],
		current_price [Current Price],currency_name [Currency],option_status [Status] 
		from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'
end
else if @report_type = 'g'
BEGIN
    DECLARE @group1 VARCHAR(100),
        @group2 VARCHAR(100),
        @group3 VARCHAR(100),
        @group4 VARCHAR(100)
    IF EXISTS ( SELECT  *    FROM    source_book_mapping_clm ) 
    BEGIN	
        SELECT  @group1 = group1,
                @group2 = group2,
                @group3 = group3,
                @group4 = group4
        FROM    source_book_mapping_clm
    END
    ELSE 
    BEGIN
        SET @group1 = 'Book1'
        SET @group2 = 'Book2'
        SET @group3 = 'Book3'
        SET @group4 = 'Book4'
    END


	if @summary_option = 's'
	BEGIN
		set @sqlStmt='select 
			Subsidiary Sub,Strategy,Book,underlying_index [Underlying Index],dbo.FNADateFormat(term) [Term],dbo.FNADateFormat(expiration) Expiration,
			strike_price Strike,deal_volume volume,
			deal_volume_frequency Fequency,uom_name UOM,option_status [Status],options_price [Premium Per Unit],
			premium Premium,currency_name Currency,[Premium Calc],delta Delta,gamma Gamma,vega Vega,theta Theta,rho Rho
			from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'
	end
	else if @summary_option = 'd'
	BEGIN
		set @sqlStmt='select 
			Subsidiary [Sub],Strategy,Book,Book1 AS [' + @group1 + '], Book2 AS [' + @group2+ '], Book3 AS [' + @group3 + '], 
						Book4 AS [' + @group4+ '],deal_id DealID,ref_deal_id RefDealID,term Term,expiration Expiration,
			expiry_status [Expiration Status],counterparty_name Counterparty,option_type [Option Type],excercise_type [Excercise Type]
			,underlying_index [Underlying Index],deal_volume Volume,
			deal_volume_frequency Frequency,uom_name UOM,options_premium [Options Premium],strike_price Strike,expiry_year [Expiry in Year]
			,annual_intrate [Annual Int Rate],annual_vol [Annual Vol],annual_imp_vol [Annual Imp Vol],
			current_price  [Current Price],currency_name Currency,option_status [Status],
			premium Premium,delta Delta,delta2 Delta2,gamma Gamma,gamma2 Gamma2,vega Vega,--vega2 Vega2,
			theta Theta,rho Rho
			from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'
	end
	else
	BEGIN
		set @sqlStmt='select 
			deal_id DealID,ref_deal_id RefDealID,dbo.FNADateFormat(term) Term,dbo.FNADateFormat(expiration) Expiration,option_type [Option Type]
				,excercise_type [Excercise Type],underlying_index [Underlying Index],
			deal_volume Volume,deal_volume_frequency Frequency,uom_name UOM,strike_price Strike
			,current_price [Current Price],currency_name Currency,option_status [Status],
			premium Premium,delta Delta,gamma Gamma,vega Vega,theta Theta,rho Rho

			from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'
	end
	
end

EXEC spa_print @sqlStmt
exec(@sqlStmt)