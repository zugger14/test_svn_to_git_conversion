 IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNAGetMatchProcessCertificate]') 
			AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
   DROP FUNCTION [dbo].[FNAGetMatchProcessCertificate]
    
GO
    
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[FNAGetMatchProcessCertificate](
	@source_deal_header_id INT
)
returns @sale_deals table(id INT IDENTITY(1,1), link_id INT, deal_id INT, detail_id INT, sale_deal_id INT, sale_detail_id INT, volume FLOAT, cert_from FLOAT, 
		 cert_to FLOAT, uom INT, tier INT, compliance_year INT, state_value_id INT)
AS
BEGIN

 	declare @link_effective_dt DATE , @compliance_yr INT, @link_id INT
	select @link_id = link_id from matching_header_detail_info   where source_deal_header_id  = @source_deal_header_id
	--select @link_id

	SELECT @link_effective_dt = link_effective_date FROM matching_header WHERE link_id = @link_id
	SET @compliance_yr = YEAR(@link_effective_dt)
 			

	INSERT INTO @sale_deals( link_id, deal_id, detail_id, sale_deal_id, sale_detail_id, volume, cert_from, cert_to, uom, tier, compliance_year, state_value_id)
	SELECT m2.link_id,
		m2.source_deal_header_id_from AS deal_id,
		m2.source_deal_detail_id_from AS detail_id,
		m2.source_deal_header_id AS sale_deal_id,
		m2.source_deal_detail_id AS sale_detail_id,
		m2.assigned_vol AS volume, 
		NULL cert_from, 
		NULL cert_to, 
		NULL uom, 
		m2.tier_value_id AS tier,
		@compliance_yr AS compliance_year,
		m2.state_value_id AS state_value_id
		FROM matching_header_detail_info m  
		INNER JOIN matching_header_detail_info m2 ON m2.source_deal_detail_id_from = m.source_deal_detail_id_from
		WHERE m.source_deal_header_id = @source_deal_header_id

		DECLARE @cert_info TABLE( detail_id INT,  from_int INT, to_int INT)

		INSERT INTO @cert_info(detail_id, from_int, to_int)
		SELECT aa.source_deal_header_id_from AS detail_id, 
			MAX(COALESCE(gcc.certificate_number_from_int, 1)) from_int,
			MAX(COALESCE(gcc.certificate_number_to_int, 1)) to_int
		FROM @sale_deals sd
		INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sd.detail_id
		INNER JOIN gis_certificate gcc ON gcc.source_deal_header_id = aa.source_deal_header_id_from
		GROUP BY aa.source_deal_header_id_from

		UPDATE sd SET sd.cert_from = 
			CASE WHEN t.vol IS NULL THEN ci.from_int ELSE t.vol+ CASE WHEN ci.from_int > 1 THEN ci.from_int ELSE 1 END END,
			sd.cert_to = 
			CASE WHEN tt.vol+(ci.from_int-1)>ci.to_int THEN ci.to_int ELSE tt.vol+(ci.from_int-1) END
		FROM @cert_info ci
		INNER JOIN @sale_deals sd ON ci.detail_id = sd.detail_id
		OUTER APPLY(SELECT CAST(SUM(sd1.volume) AS INT) vol FROM @sale_deals sd1 WHERE sd1.link_id < sd.link_id AND sd.detail_id = sd1.detail_id) t
		OUTER APPLY(SELECT CAST(SUM(sd2.volume) AS INT) vol FROM @sale_deals sd2 WHERE sd2.link_id <= sd.link_id AND sd.detail_id = sd2.detail_id) tt


RETURN 

END 

