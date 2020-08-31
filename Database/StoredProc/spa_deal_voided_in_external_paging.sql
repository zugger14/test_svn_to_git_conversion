IF OBJECT_ID('spa_deal_voided_in_external_paging') IS NOT null
DROP PROC [dbo].[spa_deal_voided_in_external_paging]
go

--select * from source_deal_header

-- exec spa_deal_voided_in_external_paging 's',NULL,null,null,'n','v','7FD067BF_1446_46DB_ADFD_596D96C9FC98'

CREATE PROC [dbo].[spa_deal_voided_in_external_paging]
				@flag_pre char(1)=null,
				@deal_id varchar(5000)=null, 
				@source_deal_header_id int=null,
				@as_of_date varchar(10)=null,
				@show_linked varchar(1)='n',
				@status varchar(1)='v',
				@process_id_paging varchar(200)=NULL, 
				@page_size int =NULL,
				@page_no int=NULL
	AS
	SET NOCOUNT ON

	DECLARE @user_login_id varchar(50)
	DECLARE @tempTable varchar(300)
	DECLARE @flag char(1)

	SET @user_login_id=dbo.FNADBUser()

	IF @process_id_paging is NULL
	BEGIN
			SET @flag='i'
			SET @process_id_paging=REPLACE(newid(),'-','_')
	END
	SET @tempTable=dbo.FNAProcessTableName('deal_voided',@user_login_id,@process_id_paging)

	EXEC spa_print @tempTable

	DECLARE @sqlStmt VARCHAR(5000)
	
	IF @flag='i'
	BEGIN 
		IF @status='d'
			set @sqlStmt='CREATE TABLE ' + @tempTable + '(
			sno int  identity(1,1),
			RefID VARCHAR(50),
			DealID int,
			voideddate VARCHAR(50),
			deleteddate VARCHAR(50),
			deletedby VARCHAR(50)
			)'
		else
			set @sqlStmt='CREATE TABLE ' + @tempTable + '(
			sno int  identity(1,1),
			DealID int,RefID varchar(50),LinkID varchar(5000),DealDate varchar(20),VoidedDate  varchar(20),
			TenorPeriod  varchar(50),CounterpartyName  varchar(250),TraderName  varchar(250),
			 TranStatus varchar(1)
			)'
		exec(@sqlStmt)

		exec spa_print @sqlStmt
		
		set @sqlStmt=' INSERT INTO  '+@tempTable+' EXEC spa_deal_voided_in_external '
								+dbo.FNASingleQuote(@flag_pre)+' , '
								+dbo.FNASingleQuote(@deal_id) +','
								+dbo.FNASingleQuote(@source_deal_header_id)+','
								+dbo.FNASingleQuote(@as_of_date)+','
								+dbo.FNASingleQuote(@show_linked)+','
								+dbo.FNASingleQuote(@status)

		EXEC spa_print @sqlStmt
		--print '************************'
		exec(@sqlStmt)	
		set @sqlStmt='select count(*) TotalRow,'''+@process_id_paging +''' process_id  from '+ @tempTable
		EXEC spa_print @sqlStmt
		exec(@sqlStmt)
END
ELSE
	BEGIN
		DECLARE @row_to int
		DECLARE @row_from int
	
		SET @row_to=@page_no * @page_size
		
		IF @page_no > 1 
			SET @row_from =((@page_no-1) * @page_size)+1
		ELSE
			SET @row_from =@page_no
		IF @status='d'
			set @sqlStmt='select DealID [Deal ID], RefID [Ref ID], VoidedDate [Voided Date], DeletedDate [Deleted Date], DeletedBy [Deleted By]
 					 from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'
		ELSE 
			set @sqlStmt='select DealID [Deal ID], RefID [Ref ID], LinkID [Link ID], DealDate [Deal Date],VoidedDate [Voided Date], TenorPeriod [Tenor Period],CounterpartyName [Counterparty Name], TraderName [Trader Name], TranStatus [Tran Status]
 					 from '+ @tempTable  +' where sno between '+ cast(@row_from as varchar) +' and '+ cast(@row_to as varchar)+ ' order by sno asc'

	exec(@sqlStmt)
end

