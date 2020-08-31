/****** Object:  UserDefinedFunction [dbo].[FNARUDFValue]    Script Date: 12/11/2010 23:12:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARSettlementDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARSettlementDate]
/****** Object:  UserDefinedFunction [dbo].[FNARSettlementDate]    Script Date: 12/11/2010 23:07:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARSettlementDate](
	@deal_id int, -- @deal_id is @source_deal_detail_id
	@frequency INT, --0- day, 1-Month
	@no	INT
)	


RETURNS INT AS
BEGIN
DECLARE @settlementdate INT



			SELECT @settlementdate=
					CASE @frequency WHEN 0 THEN
									CONVERT(VARCHAR(10),DATEADD(d,@no,ISNULL(settlement_date,contract_expiration_date)),112)
									WHEN 1 THEN
									CONVERT(VARCHAR(10),DATEADD(m,@no,ISNULL(settlement_date,contract_expiration_date)),112)
									WHEN 2 THEN
									CONVERT(VARCHAR(10),DATEADD(q,@no,ISNULL(settlement_date,contract_expiration_date)),112)
									WHEN 3 THEN
									CONVERT(VARCHAR(10),DATEADD(q,@no,ISNULL(settlement_date,contract_expiration_date)),112)
					END
				FROM
					 source_deal_detail sdd 					
			WHERE
				sdd.source_deal_detail_id=@deal_id

	RETURN @settlementdate
END


 