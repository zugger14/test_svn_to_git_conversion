IF OBJECT_ID(N'spa_fv_inventory_carrying_amount', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_fv_inventory_carrying_amount]
 GO 



-- exec spa_fv_inventory_carrying_amount   's', 404
-- exec spa_fv_inventory_carrying_amount   'u', 404, '2004-08-01', '2004-08-31', 0

create proc [dbo].[spa_fv_inventory_carrying_amount] @flag varchar(1),
			@source_deal_header_id INT,
			@term_start varchar(20)  = null,
			@term_end varchar(20)  = null,
			@carrying_amount float = null
AS

If @flag = 's'
BEGIN
	SELECT  sdd.source_deal_header_id, 
		dbo.FNADateFormat(ISNULL(fica.term_start, sdd.term_start)) [Term Start] , 
		dbo.FNADateFormat(ISNULL(fica.term_end, sdd.term_end)) [Term End] , 
		fica.carrying_amount [Carrying Amount]
	FROM    (select DISTINCT source_deal_header_id,  term_start, term_end from source_deal_detail) sdd LEFT OUTER JOIN
	                      fv_inventory_carrying_amount fica ON sdd.source_deal_header_id = fica.source_deal_header_id
	and fica.term_start=sdd.term_start and fica.term_end=sdd.term_end
	WHERE	(sdd.source_deal_header_id = @source_deal_header_id) 

END
If @flag = 'u'
BEGIN

	If (select count(*) from  fv_inventory_carrying_amount where
		source_deal_header_id = @source_deal_header_id 
			and term_start = @term_start and term_end = @term_end) = 0
	BEGIN -- Insert
		INSERT INTO fv_inventory_carrying_amount VALUES(@source_deal_header_id,
			@term_start, @term_end, 1,
			@carrying_amount, NULL,NULL,NULL,NULL)
	END
	ELSE
	BEGIN --Update
		UPDATE fv_inventory_carrying_amount 
		SET carrying_amount = @carrying_amount
		where source_deal_header_id = @source_deal_header_id and term_start = @term_start
		and term_end = @term_end
	END

 	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Carrying Amount", 
		"spa_fv_inventory_carrying_amount", "DB Error", 
		"Failed to update fair value carrying amount.", ''
	else
	begin
		Exec spa_ErrorHandler 0, 'Carrying Amount', 
		'spa_fv_inventory_carrying_amount', 'Success', 
		'Fair value carrying amount updated.', '' 
	end
END
If @flag = 'd'
BEGIN

	DELETE fv_inventory_carrying_amount 
	where source_deal_header_id = @source_deal_header_id and term_start = @term_start
	and term_end = @term_end

 	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Carrying Amount", 
		"spa_fv_inventory_carrying_amount", "DB Error", 
		"Failed to delete fair value carrying amount.", ''
	else
	begin
		Exec spa_ErrorHandler 0, 'Carrying Amount', 
		'spa_fv_inventory_carrying_amount', 'Success', 
		'Fair value carrying amount deleted.', '' 
	end
END









