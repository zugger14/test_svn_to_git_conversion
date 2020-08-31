IF OBJECT_ID(N'[dbo].[spa_genhedgegroupdetail]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_genhedgegroupdetail]
 GO 




-- EXEC spa_genhedgegroupdetail 's', NULL, 1
-- EXEC spa_genhedgegroupdetail 'i', NULL, 312, 54102, 1.0

--This proc will be used to perform select, insert, update and delete record
--from the gen_hedge_group_detail table
--The fisrt parameter or flag to pass: select = 's', for Insert='i'. Update='u' and Delete='d'
--For insert and update, pass all the parameters defined for this stored procedure


-- DROP PROC spa_genhedgegroupdetail

CREATE PROCEDURE [dbo].[spa_genhedgegroupdetail]
@flag char(1)=NULL,
@gen_hedge_group_detail_id int=NULL,
@gen_hedge_group_id int=NULL,
@source_deal_header_id int=NULL,
@percentage_use float=NULL

AS
SET NOCOUNT ON
begin

	if @flag='s' and @gen_hedge_group_id IS NULL
		begin
			select gen_hedge_group_detail.gen_hedge_group_detail_id as [Gen Detail ID], 
				gen_hedge_group_detail.gen_hedge_group_id as [Gen Group ID], 
                      		gen_hedge_group_detail.source_deal_header_id as [Deal ID], 
				cast(round(gen_hedge_group_detail.percentage_use, 2) as varchar) as [Percentage Use], 
				gen_hedge_group_detail.create_user as [Created User], 
                      		dbo.FNADateTimeFormat(gen_hedge_group_detail.create_ts,2) as [Created TS], 
				gen_hedge_group_detail.update_user as [Updated User], 
				dbo.FNADateTimeFormat(gen_hedge_group_detail.update_ts,2) as [Updated TS]
			
			from gen_hedge_group_detail
			if @@ERROR<> 0 
			begin
				Exec spa_ErrorHandler @@ERROR, "Hedge Group Detail", 
					"spa_genhedgegroup", "DB Error", 
					"'Failed to select hedge group detail.", ''
			end
		else
			begin
				Exec spa_ErrorHandler 0, 'Hedge Group Detail', 
					'spa_genhedgegroup','Successr', 
					'hedge group detail successfully selected', ''
	
			end
		end
	else if @flag='s' and @gen_hedge_group_id IS NOT NULL
	BEGIN	
		SELECT ghgd.gen_hedge_group_detail_id
			, cast(round(ghgd.percentage_use, 2) as varchar) as percentage_use 
            , ghgd.source_deal_header_id
			, sdh.deal_id
			, dbo.FNADateFormat(sdh.deal_date) deal_date
			, dbo.FNADateFormat(ghg.hedge_effective_date) effective_date
			, dbo.FNADateFormat(sdh.entire_term_start) term_start
			, dbo.FNADateFormat(sdh.entire_term_end) term_end
			, CASE WHEN sdh.header_buy_sell_flag = 'b' THEN 'Buy' ELSE 'Sell' END buy_sell
		FROM gen_hedge_group_detail ghgd
		INNER JOIN gen_hedge_group ghg ON ghg.gen_hedge_group_id = ghgd.gen_hedge_group_id
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ghgd.source_deal_header_id
		WHERE ghgd.gen_hedge_group_id = @gen_hedge_group_id
	
	END
	else if @flag='i'
		begin
			insert into gen_hedge_group_detail (gen_hedge_group_id,source_deal_header_id,percentage_use)
			 values(@gen_hedge_group_id,@source_deal_header_id,@percentage_use)
		

		if @@ERROR<> 0 
			begin
				Exec spa_ErrorHandler @@ERROR, "Hedge Group Detail", 
					"spa_genhedgegroup", "DB Error", 
					"Failed to insert into hedge group detail",''
			end
		else
			begin
				Exec spa_ErrorHandler 0, 'Hedge Group Detail', 
					'spa_genhedgegroup','Success' , 
					'Inserted into hedge group detail successfully ', ''
	
			end
		end


	else if @flag='u'
			begin
				update gen_hedge_group_detail
				set source_deal_header_id = @source_deal_header_id,
				      percentage_use = @percentage_use
				 --where gen_hedge_group_id=@gen_hedge_group_id
				where 	gen_hedge_group_detail_id = @gen_hedge_group_detail_id
			
	
			if @@ERROR<> 0 
				begin
					Exec spa_ErrorHandler @@ERROR, "Hedge Group Detail", 
						"spa_genhedgegroup", "DB Error", 
						"Failed to update hedge group detail",''
				end
			else
				begin
					Exec spa_ErrorHandler 0, 'Hedge Group Detail', 
						'spa_genhedgegroup','Success', 
						' hedge group detail updated successfully ', ''
		
				end
			end

	else if @flag='d'
				begin
					delete gen_hedge_group_detail  
					--where gen_hedge_group_id=@gen_hedge_group_id
					where 	gen_hedge_group_detail_id = @gen_hedge_group_detail_id
				
		
				if @@ERROR<> 0 
					begin
						Exec spa_ErrorHandler @@ERROR, "Hedge Group Detail", 
							"spa_genhedgegroup","DB Error", 
							"Failed to delete hedge group detail",''
					end
				else
					begin
						Exec spa_ErrorHandler 0, 'Hedge Group', 
							'spa_genhedgegroup', 'Success', 
							' data from hedge group detail deleted successfully ', ''
			
					end
				end


end








