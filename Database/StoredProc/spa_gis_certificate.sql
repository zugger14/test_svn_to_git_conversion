/****** Object:  StoredProcedure [dbo].[spa_certificate_detail]    Script Date: 10/07/2009 16:30:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_gis_certificate]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_gis_certificate]
GO

CREATE PROCEDURE [dbo].spa_gis_certificate
	@flag char(1),
	@source_deal_detail_id INT = NULL,
	@gis_certificate_number_from VARCHAR (100) = NULL,
	@gis_certificate_number_to VARCHAR (100) = NULL,
	@certificate_number_from_int INT = NULL,
	@certificate_number_to_int INT = NULL,
	@gis_cert_date DATETIME = NULL, 
	@source_deal_header_id INT = NULL
AS


IF @flag='i'
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
		VALUES 
		(
			@source_deal_detail_id,
			@gis_certificate_number_from,
			@gis_certificate_number_to,
			@certificate_number_from_int,
			@certificate_number_to_int,
			@gis_cert_date
		
		)
	
	
	
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

ELSE IF @flag = 'u'
BEGIN
	UPDATE  gc
	SET
		gis_certificate_number_from	= @certificate_number_from_int,
		gis_certificate_number_to = @certificate_number_to_int,
		certificate_number_from_int = @certificate_number_from_int,
		certificate_number_to_int = @certificate_number_to_int,
		gis_cert_date = @gis_cert_date	
	FROM gis_certificate gc
	WHERE
		gc.source_deal_header_id = @source_deal_detail_id
END
	

ELSE IF @flag='a'
BEGIN
	 SELECT sdd.source_deal_header_id [Source Deal Header ID],
			gc.gis_certificate_number_from [Cert# From],
	        gc.gis_certificate_number_to [Cert# To],
	        dbo.FNADateFormat(sdd.term_start)[Term Start],
	        dbo.FNADateFormat(sdd.term_end) [Term End],
	        dbo.FNADateFormat(gis_cert_date) [Certificate Date],	
			gc.certificate_number_from_int [Sequence From],
	        gc.certificate_number_to_int [Sequence To],
			sdd.source_deal_header_id [Source Deal Header ID],
	        sdd.source_deal_detail_id [Source Deal Detail ID],
	        sdd.leg [Leg],
	        gc.gis_cert_date [Create TS],
	        gc.update_ts [Update TS]
	 FROM   source_deal_detail sdd
	        LEFT JOIN Gis_Certificate gc
	             ON  sdd.source_deal_detail_id = gc.source_deal_header_id
	 WHERE  sdd.source_deal_header_id = @source_deal_header_id

END