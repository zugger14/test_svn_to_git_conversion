/****** Object:  UserDefinedFunction [dbo].[FNARDealType]    Script Date: 04/07/2009 17:15:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARDealType]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARDealType]
/****** Object:  UserDefinedFunction [dbo].[FNARDealType]    Script Date: 04/07/2009 17:16:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
select [dbo].[FNARDealType](123,1,NULL)
*/
CREATE FUNCTION [dbo].[FNARDealType](
	@source_deal_detail_id INT, -- @source_deal_detail_id is @source_deal_detail_id
	@source_deal_header_id INT,
	@deal_type_id INT, --- deal_type
	@deal_subtype_id INT -- internal deal sub type	
)

RETURNS INT AS
BEGIN

DECLARE @deal_type INT

	
	IF @source_deal_detail_id IS NOT NULL
		SELECT @source_deal_header_id= source_deal_header_id FROM source_deal_detail where source_deal_detail_id=@source_deal_detail_id
	
	
	
	
	IF @deal_subtype_id IS NULL
		SELECT @deal_type = MAX(sdh.source_deal_type_id) 
		FROM 
			source_deal_header sdh
		WHERE 
			sdh.source_deal_header_id = @source_deal_header_id 
			AND sdh.source_deal_type_id= @deal_type_id	
	ELSE 		  
		SELECT @deal_type = MAX(sdh.source_deal_type_id) 
		FROM 
			source_deal_header sdh
		WHERE 
			sdh.source_deal_header_id = @source_deal_header_id 
			AND sdh.source_deal_type_id= @deal_type_id	
			AND sdh.internal_deal_subtype_value_id=@deal_subtype_id

	
	IF ISNULL(@deal_type,0)=0
		SET @deal_type=0
	ELSE
		SET @deal_type=1

	RETURN @deal_type

END


