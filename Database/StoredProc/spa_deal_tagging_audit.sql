IF OBJECT_ID(N'spa_deal_tagging_audit', N'P') IS NOT NULL
DROP PROCEDURE spa_deal_tagging_audit
 GO 

--exec [spa_Create_Not_Mapped_Deal_Report] NULL,NULL,NULL,NULL,'2006-01-01','200612-31','n',NULL

--@book_deal_type_map_id is required and takes mustiple ids
--@deal_id_from, @deal_id_to are optional
--@deal_date_from, @deal_date_to are optional

-- DROP PROC spa_Create_Deal_Report
-- exec spa_deal_tagging_audit 'i',577,7,3,4,5,'asd','farrms_admin'
-- exec spa_deal_tagging_audit 's','576,577'

create PROC [dbo].[spa_deal_tagging_audit]
			@flag char(1)='s',
            @dealId varchar(5000)=NULL, 
			@source_system_book_id1 int=NULL, 
			@source_system_book_id2 int=NULL, 
			@source_system_book_id3 int=NULL, 
			@source_system_book_id4 int=NULL, 
			@change_reason varchar(500) = NULL,
            @user_name varchar(200) = NULL ,
			@isEnable1 varchar(10)=NULL, 
			@isEnable2 varchar(10)=NULL, 
			@isEnable3 varchar(10)=NULL, 
			@isEnable4 varchar(10)=NULL
			

AS
declare @sql varchar(7000)

if @flag='s'
begin
--	set @sql = 'select 
--		   max(sdh.source_deal_header_id),
--		   max(isnull(dt.source_system_book_id1,sdh.source_system_book_id1)),
--           max(isnull(dt.source_system_book_id2,sdh.source_system_book_id2)),
--           max(isnull(dt.source_system_book_id3,sdh.source_system_book_id3)),
--           max(isnull(dt.source_system_book_id4,sdh.source_system_book_id4)),
--           max(dt.change_reason)
--	from
--		deal_tagging_audit dt
--		right join source_deal_header sdh on dt.source_deal_header_id=sdh.source_deal_header_id
--	where
--		sdh.source_deal_header_id in ('+@dealId+')'
	set @sql = 'select 
		   max(sdh.source_deal_header_id),
		   max(sdh.source_system_book_id1),
           max(sdh.source_system_book_id2),
           max(sdh.source_system_book_id3),
           max(sdh.source_system_book_id4),
           max(dt.change_reason)
	from
		deal_tagging_audit dt
		right join source_deal_header sdh on dt.source_deal_header_id=sdh.source_deal_header_id
	where
		sdh.source_deal_header_id in ('+@dealId+')'
	EXEC spa_print @sql
	exec(@sql)
		
end
else if @flag='i'
begin
set @sql = 'INSERT into deal_tagging_audit(source_deal_header_id,
                                           source_system_book_id1,
                                           source_system_book_id2,
                                           source_system_book_id3,
                                           source_system_book_id4,
                                           change_reason
                                          ) 
                                           
             SELECT source_deal_header_id,
                    source_system_book_id1,
                    source_system_book_id2,
                    source_system_book_id3,
                    source_system_book_id4,
                    '''+isNUll(@change_reason,'')+'''
             FROM  source_deal_header
             WHERE  source_deal_header_id in ('+@dealId+')'
                      
--print(@sql)                                
exec(@sql)
                     
DECLARE @sql_if varchar(1000)

SET @sql_if=''

 set @sql =' UPDATE source_deal_header
    SET '

IF @isEnable1='1' 
 set @sql_if =@sql_if + ' source_system_book_id1= '+cast(@source_system_book_id1 as varchar)
IF @isEnable2='1'
begin
	IF @sql_if <> '' 
		set @sql_if =@sql_if + ','

	set @sql_if =@sql_if + ' source_system_book_id2= '+cast(@source_system_book_id2 as varchar)
END 
IF @isEnable3='1'
begin
	IF @sql_if <> '' 
		set @sql_if =@sql_if + ','
 set @sql_if =@sql_if + ' source_system_book_id3= '+cast(@source_system_book_id3 as varchar)
end
IF @isEnable4='1'
begin
	IF @sql_if <> '' 
		set @sql_if =@sql_if + ','
	set @sql_if =@sql_if + ' source_system_book_id4= '+cast(@source_system_book_id4 as varchar)
end

 set @sql =@sql + @sql_if + ' WHERE source_deal_header_id in ('+@dealId+')'

exec(@sql)
EXEC spa_print @sql
If @@ERROR  <> 0
			Exec spa_ErrorHandler @@ERROR, "source_deal_header", 
					"source_deal_header", "DB Error", 
					"Insert of process requirements assignment trigger Failed.", ''
		else
			Exec spa_ErrorHandler 0, 'source_deal_header', 
					'source_deal_header', 'Success', 
					'source_deal_header Inserted', '' 
        
end

