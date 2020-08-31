
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARWACOGLocPur]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARWACOGLocPur]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARWACOGLocPur](@source_deal_header_id int)

RETURNS FLOAT AS
 /*
 declare  @source_deal_header_id int=	  9259


--*/
BEGIN
	declare @term datetime ,@location_id int ,@ret_value float

	select @term=term_start	  from source_deal_detail sdd where sdd.source_deal_header_id=@source_deal_header_id and  sdd.leg=1

	SELECT 	@location_id= f.udf_value from  user_defined_deal_fields f
	inner join  user_defined_deal_fields_template uddft on f.udf_template_id=uddft.udf_template_id  and uddft.field_name=-5677 --Purchase Location 
		and f.source_deal_header_id=@source_deal_header_id  and Isnumeric(f.udf_value)=1
						  
	select @ret_value=sum(abs(sds.volume)*abs(sds.net_price ))/sum(abs(sds.volume))   from source_deal_detail sdd
	cross apply
	(
		select max(as_of_date) as_of_date from 	source_deal_settlement where source_deal_header_id=sdd.source_deal_header_id and leg=sdd.Leg  
			and sdd.buy_sell_flag='b' and sdd.location_id=@location_id and 	term_start=@term
	) max_dt
	 inner join source_deal_settlement sds on  sds.source_deal_header_id=sdd.source_deal_header_id and  sds.leg=sdd.Leg  and sdd.buy_sell_flag='b' 
		and sdd.location_id=@location_id and sds.term_start=sdd.term_start  and	sds.term_start=@term and max_dt.as_of_date =sds.as_of_date
	 	
	return @ret_value

	--select @ret_value
END





