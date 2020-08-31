/****** Object:  StoredProcedure [dbo].[spa_source_deal_pnl]    Script Date: 09/23/2009 17:44:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_deal_pnl]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_deal_pnl]
GO

CREATE proc [dbo].spa_source_deal_pnl @flag varchar(1),
			@pnl_as_of_date varchar(15),
			@source_deal_header_id INT,
			@term_start varchar(20)  = null,
			@term_end varchar(20)  = null,			
			@intrinsic_pnl float = null,
			@extrinsic_pnl float = null,
			@pnl_conversion_factor  float = null,
			@pnl_currency_id  int = null
AS
--print @flag
If @flag = 's'
BEGIN

-- 	declare @pnl_as_of_date varchar(15),
-- 			@source_deal_header_id int
-- set @pnl_as_of_date = '11/5/2004'
-- set @source_deal_header_id  = 471
	Declare @currency_id int

	select @currency_id=max(fixed_price_currency_id) from source_deal_detail
	where source_deal_header_id = @source_deal_header_id and fixed_price_currency_id is not null

	--print @currency_id
	SELECT   sdd.source_deal_header_id [DealID], 
		dbo.FNADateFormat(sdd.term_start) [Term Start] , 
		dbo.FNADateFormat(sdd.term_end) [Term End] , 
		round(isnull(fica.und_intrinsic_pnl,0), 4) [Intrinsic PNL],
		round(isnull(fica.und_extrinsic_pnl, 0), 4) [Exclude PNL],
		round(isnull(fica.und_pnl, 0), 4)  [PNL],
		ISNULL(fica.pnl_currency_id,@currency_id) [Currency],
		ISNULL(fica.pnl_conversion_factor,1) [Conv Factor]
	FROM    (select DISTINCT source_deal_header_id,  term_start, term_end from source_deal_detail
			where source_deal_header_id = @source_deal_header_id) sdd FULL OUTER JOIN
	        source_deal_pnl fica ON fica.source_deal_header_id  = sdd.source_deal_header_id AND
		fica.term_start = dbo.FNAGetContractMonth(dbo.FNADEALRECExpiration(sdd.source_deal_header_id, sdd.term_start, NULL)) and 
		fica.term_end = dbo.FNADEALRECExpiration(sdd.source_deal_header_id, sdd.term_end, NULL)
		and fica.pnl_as_of_date = @pnl_as_of_date
	--WHERE	(sdd.source_deal_header_id = @source_deal_header_id and fica.pnl_as_of_date = @pnl_as_of_date) 
--	and (fica.und_intrinsic_pnl is not null or fica.und_extrinsic_pnl is not null or fica.und_pnl is not null)
	WHERE	sdd.source_deal_header_id = @source_deal_header_id 
	order by sdd.term_start, sdd.term_end




END
if @flag = 'u'
BEGIN

	If (select count(*) from  source_deal_pnl where
		source_deal_header_id = @source_deal_header_id 
			and term_start = @term_start and 
			term_end = @term_end and
			pnl_as_of_date =  @pnl_as_of_date and leg = 1) = 0
	BEGIN -- Insert
		INSERT INTO source_deal_pnl 
			(source_deal_header_id,term_start,term_end,Leg,pnl_as_of_date,und_pnl,
			und_intrinsic_pnl,und_extrinsic_pnl,dis_pnl,dis_intrinsic_pnl,dis_extrinisic_pnl,
			pnl_source_value_id,pnl_currency_id,pnl_conversion_factor,pnl_adjustment_value,
			deal_volume)
		VALUES
		(@source_deal_header_id,
			@term_start, @term_end, 1, @pnl_as_of_date, 
			isnull(@intrinsic_pnl, 0) + isnull(@extrinsic_pnl, 0), 
			isnull(@intrinsic_pnl, 0), isnull(@extrinsic_pnl, 0), 
			0,0,0, 775, @pnl_currency_id,  isnull(@pnl_conversion_factor, 1), 
			NULL,NULL)
	END
	ELSE
	BEGIN --Update
		UPDATE source_deal_pnl 
		SET 	und_pnl = isnull(@intrinsic_pnl, 0) + isnull(@extrinsic_pnl, 0),
			und_intrinsic_pnl = isnull(@intrinsic_pnl, 0),
			und_extrinsic_pnl = isnull(@extrinsic_pnl, 0),
			pnl_currency_id = @pnl_currency_id,
			pnl_conversion_factor = isnull(@pnl_conversion_factor, 1)
		where source_deal_header_id = @source_deal_header_id and term_start = @term_start
		and term_end = @term_end and pnl_as_of_date =  @pnl_as_of_date and leg = 1
	END

 	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'PNL', 
		'spa_source_deal_pnl', 'DB Error', 
		'Failed to update PNL.', ''
	else
	begin
		Exec spa_ErrorHandler 0, 'PNL', 
		'spa_source_deal_pnl', 'Success', 
		'PNL updated.', '' 
	end
END

if @flag='d'
Begin
		
		delete from source_deal_pnl
		where source_deal_header_id = @source_deal_header_id and term_start = @term_start
		and term_end = @term_end and pnl_as_of_date =  @pnl_as_of_date
		
	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, 'PNL', 
		'spa_source_deal_pnl', 'DB Error', 
		'Failed to delete PNL.', ''
	else
	begin
		Exec spa_ErrorHandler 0, 'PNL', 
		'spa_source_deal_pnl', 'Success', 
		'PNL Deleted.', '' 
	end
End




