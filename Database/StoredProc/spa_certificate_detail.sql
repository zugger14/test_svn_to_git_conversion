/****** Object:  StoredProcedure [dbo].[spa_certificate_detail]    Script Date: 10/07/2009 16:30:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_certificate_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_certificate_detail]
GO

CREATE PROCEDURE [dbo].[spa_certificate_detail]
	@flag char(1),
	@source_deal_detail_id INT=NULL,
	@certificate_number_from_int INT=NULL,
	@certificate_number_to_int INT=NULL,
	@gis_cert_date DATETIME
AS


IF @flag='u'
BEGIN

	IF NOT EXISTS (SELECT 'x' FROM gis_certificate WHERE source_deal_header_id=@source_deal_detail_id)
	BEGIN
		INSERT INTO gis_certificate
		( 
			source_deal_header_id,
			certificate_number_from_int,
			certificate_number_to_int,
			gis_certificate_number_from,
			gis_certificate_number_to,
			gis_cert_date	
		 )
		SELECT    
			@source_deal_detail_id,
			@certificate_number_from_int,
			@certificate_number_to_int,	
			dbo.FNACertificateRule(cr.cert_rule,rg.id,ISNULL(@certificate_number_from_int,1),sdd.term_start),   	 	
			dbo.FNACertificateRule(cr.cert_rule,rg.id,ISNULL(@certificate_number_to_int,sdd.deal_volume),sdd.term_start),		   	 	
			@gis_cert_date
		FROM
			source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
			LEFT JOIN rec_generator rg 	ON sdh.generator_id = rg.generator_id     
			LEFT JOIN certificate_rule cr ON rg.gis_value_id=cr.gis_id 
		WHERE
			sdd.source_deal_detail_id = @source_deal_detail_id
	END
	ELSE
	BEGIN

		UPDATE gc
		SET
			gis_certificate_number_from	= dbo.FNACertificateRule(cr.cert_rule,rg.id,ISNULL(@certificate_number_from_int,1),sdd.term_start),
			gis_certificate_number_to = dbo.FNACertificateRule(cr.cert_rule,rg.id,ISNULL(@certificate_number_to_int,sdd.deal_volume),sdd.term_start),
			certificate_number_from_int = @certificate_number_from_int,
			certificate_number_to_int = @certificate_number_to_int,
			gis_cert_date = @gis_cert_date
		FROM gis_certificate gc 
			INNER JOIN source_deal_detail sdd ON gc.source_deal_header_id = sdd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=sdd.source_deal_header_id 
			LEFT JOIN rec_generator rg 	ON sdh.generator_id = RG.generator_id     
			LEFT JOIN certificate_rule cr ON rg.gis_value_id=cr.gis_id 
		WHERE
			gc.source_deal_header_id = @source_deal_detail_id
	END
	
	
	IF @@ERROR <> 0
	BEGIN 
		Exec spa_ErrorHandler @@ERROR, "Update Certificate Detail.", 
				"spa_certificate_detail", "DB Error", 
				"Update Certificate Detail failed.", ''
		RETURN
	END
	ELSE Exec spa_ErrorHandler 0, 'Update Certificate Detail.', 
			'spa_certificate_detail', 'Success', 
			'Successfully Updated Certificate Detail .',''
END


ELSE IF @flag='a'
BEGIN
	 SELECT 
	  certificate_number_from_int, certificate_number_to_int, dbo.FNADateFormat(gis_cert_date), sdd.deal_volume 
	 FROM source_deal_detail sdd
	 LEFT JOIN Gis_Certificate gc ON sdd.source_deal_detail_id = gc.source_deal_header_id
	 WHERE sdd.source_deal_detail_id = @source_deal_detail_id

END