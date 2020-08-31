
IF OBJECT_ID(N'spa_embedded_deal', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_embedded_deal]
 GO 

-- exec spa_embedded_deal 'a',NULL,130070
create PROC [dbo].[spa_embedded_deal]
			@flag char(1)='s', -- s- select i- insert u- update d- delete b- select 4 groups
            @embedded_deal_id int=NULL, 
			@source_deal_header_id int=NULL, 
			@leg int=NULL, 
			@type_value_id int=NULL, 
			@comment varchar(500)=NULL,
			@completed char(1)=null,
			@bif_deal_id int=null
	

AS
declare @sql varchar(5000)

if @flag='s'
begin
	set @sql = 'select 
				embedded_deal_id ,
				source_deal_header_id [DealID],
				leg [Leg],
				type_value_id [TypeID],
				comment as [Comment]			
		from
		embedded_deal
	where
		embedded_deal_id in ('+@embedded_deal_id+')'
	EXEC spa_print @sql
	exec(@sql)
		
end
else if @flag='i'
begin
INSERT into embedded_deal(source_deal_header_id,
                           leg,
                           type_value_id,
                           comment,
						   completed,
							bif_source_deal_header_id
                        )                                            
             SELECT 
                     @source_deal_header_id,
                     @leg,
                     @type_value_id,
                     @comment,
					 @completed,
					@bif_deal_id


                      
--print(@sql)                                
exec(@sql)
  UPDATE embedded_deal
    SET source_deal_header_id= @source_deal_header_id,
       leg= @leg,
       type_value_id=@type_value_id,
       comment=@comment,
		bif_source_deal_header_id=@bif_deal_id
    WHERE embedded_deal_id =@embedded_deal_id

exec(@sql)

If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "embedded_deal", 
					"embedded_deal", "DB Error", 
					" ", ''
		else
			Exec spa_ErrorHandler 0, 'embedded_deal', 
					'embedded_deal', 'Success', 
					'embedded_deal Inserted', '' 
        
end
else if @flag='a' -- sleect 4 groups from source_deal_header
begin
	select 
		sdh.source_system_book_id1,
		sdh.source_system_book_id2,
		sdh.source_system_book_id3,
		sdh.source_system_book_id4,
		ed.type_value_id,
		comment,
		completed	
	from
		source_deal_header sdh left join embedded_deal ed 
		on sdh.source_deal_header_id=ed.source_deal_header_id
		and leg=@leg
	where
		sdh.source_deal_header_id=@source_deal_header_id
end

else if @flag='d'
begin
begin tran
	Delete from 
		embedded_deal
	where
		embedded_deal_id=@embedded_deal_id

	if @@ERROR <> 0
		Rollback Tran
	else
		begin
			CREATE TABLE #returnval (
				ErrorCode VARCHAR(500) COLLATE DATABASE_DEFAULT, 
				Mesage VARCHAR(500) COLLATE DATABASE_DEFAULT,
				Area VARCHAR(100) COLLATE DATABASE_DEFAULT,
				Status VARCHAR(50) COLLATE DATABASE_DEFAULT,
				Module VARCHAR(500) COLLATE DATABASE_DEFAULT,
				Recommendation VARCHAR(500) COLLATE DATABASE_DEFAULT
			)
			INSERT INTO #returnval 
			exec [spa_sourcedealheader] 'd',NULL,NULL,NULL,NULL,NULL,@source_deal_header_id
			
			IF exists(SELECT errorcode from #returnval where errorcode='Error')
			BEGIN
				Rollback Tran
				SELECT * FROM #returnval	
				RETURN
			END	
			
			commit Tran
		end
		


If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "source_deal_header", 
					"source_deal_header", "DB Error", 
					"Failed Deleting embedded_deal.", ''
		else
			Exec spa_ErrorHandler 0, 'embedded_deal', 
					'embedded_deal', 'Success', 
					'embedded_deal Deleted', '' 	

end

else if @flag='u'
begin
	update		
		embedded_deal
	set
		type_value_id=@type_value_id,
        comment=@comment,
		completed=@completed
	where
		embedded_deal_id=@embedded_deal_id


If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "embedded_deal", 
					"embedded_deal", "DB Error", 
					" ", ''
		else
			Exec spa_ErrorHandler 0, 'embedded_deal', 
					'embedded_deal', 'Success', 
					'embedded_deal Updated', '' 	

end































