/****** Object:  UserDefinedFunction [dbo].[FNARImbalanceVol]    Script Date: 01/07/2011 17:49:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARImbalanceVol]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARImbalanceVol]

GO
/****** Object:  UserDefinedFunction [dbo].[FNARImbalanceVol]    Script Date: 01/07/2011 17:50:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNARImbalanceVol](
	@source_deal_detail_id int, -- @deal_id is @source_deal_detail_id
	@source_deal_header_id INT,
	@term_start DATETIME,
	@source_minor_location_id INT,
	@counterparty_id int
	
)

RETURNS FLOAT AS
BEGIN
DECLARE @imbalance_volume FLOAT
--DECLARE @source_deal_detail_id INT,@term_start VARCHAR(20),@source_deal_header_id INT
--SET @source_deal_detail_id = NULL
--SET @source_deal_header_id = 158220
--SET @term_start = '2012-07-01'



	SELECT @imbalance_volume = 
			--ISNULL(SUM(ds.delivered_volume),0) -  SUM(sdd.deal_volume)
			ISNULL(SUM(ABS(CASE WHEN sdh.source_deal_type_id = 57 THEN isnull(ds.delivered_volume,0) ELSE 0 END)),0)
			-(SUM(ABS(CASE WHEN sdh.source_deal_type_id = 57 THEN isnull(sdd.deal_volume,0) ELSE 0 END))
			+(-1*SUM(ISNULL(CASE WHEN sdh.source_deal_type_id = 93 THEN sdd.deal_volume ELSE 0 END,0)))
			+(-1*SUM(ISNULL(CASE WHEN sdh.source_deal_type_id = 94 THEN sdd.deal_volume ELSE 0 END,0))))
	FROM
			source_deal_header sdh	
			INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1     		                        
				AND sdh.source_system_book_id2=ssbm.source_system_book_id2                             
				AND sdh.source_system_book_id3=ssbm.source_system_book_id3                             
				AND sdh.source_system_book_id4=ssbm.source_system_book_id4                             
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id=sdh.source_deal_header_id
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id
			LEFT JOIN source_major_location smjl on smjl.source_major_location_id=sml.source_major_location_id
			LEFT JOIN deal_transport_detail dtd ON dtd.source_deal_detail_id_to=sdd.source_deal_detail_id
			LEFT JOIN delivery_status ds ON ds.deal_transport_detail_id=dtd.deal_transport_deatail_id
			INNER JOIN (SELECT MAX(path_id) path_id,max(MeterID) MeterID, locationid ,MAX(FormulaID) FormulaID, max(leg) leg, max(counterparty) counterparty, MAX(imbalance_from) imbalance_from, MAX(imbalance_to) imbalance_to, max(imbalance) imbalance FROM
				(SELECT path_id,
				CASE n
					WHEN 1 THEN meter_from
					WHEN 2 THEN meter_to
				END as MeterID,
				CASE n
					WHEN 1 THEN from_location
					WHEN 2 THEN to_location
				END as LocationID,
				CASE n
					WHEN 1 THEN formula_from
					WHEN 2 THEN formula_to
				END as FormulaID,
				CASE n
					WHEN 1 THEN 1 ELSE 2
				END as Leg, counterparty,
				imbalance_from,imbalance_to,
				CASE n
					WHEN 1 THEN imbalance_from
					WHEN 2 THEN imbalance_to
				END as Imbalance
				FROM delivery_path as S 
				CROSS JOIN
				(
					SELECT 1 UNION
					SELECT 2 
				) AS Nums(n) 
				)a 
				--WHERE FormulaID IS NOT NULL 
				GROUP BY locationid) tdp2 ON  (CASE WHEN tdp2.imbalance = 'y' THEN tdp2.LocationID ELSE -1 END ) = sml.source_minor_location_id	
	
			LEFT JOIN (SELECT MAX(path_id) path_id, max(MeterID) MeterID ,counterparty, max(locationid) locationid , MAX(FormulaID) FormulaID, max(leg) leg, MAX(imbalance_from) imbalance_from, MAX(imbalance_to) imbalance_to, max(imbalance) imbalance FROM
				(SELECT path_id,
				CASE n
					WHEN 1 THEN meter_from
					WHEN 2 THEN meter_to
				END as MeterID,
				CASE n
					WHEN 1 THEN from_location
					WHEN 2 THEN to_location
				END as LocationID,
				CASE n
					WHEN 1 THEN formula_from
					WHEN 2 THEN formula_to
				END as FormulaID,
				CASE n
					WHEN 1 THEN 1 ELSE 2
				END as Leg, counterparty,
				imbalance_from,imbalance_to,
				CASE n
					WHEN 1 THEN imbalance_from
					WHEN 2 THEN imbalance_to
				END as Imbalance
				FROM delivery_path as S 
				CROSS JOIN
				(
					SELECT 1 UNION
					SELECT 2 
				) AS Nums(n) 
				)a 
				--WHERE FormulaID IS NOT NULL 
				GROUP BY counterparty)	 tdp ON tdp.counterparty = sdh.counterparty_id	     
			WHERE 1=1 
			AND ((sdd.source_deal_detail_id = @source_deal_detail_id AND @source_deal_detail_id IS NOT NULL) OR (sdd.source_deal_header_id = @source_deal_header_id AND @source_deal_header_id IS NOT NULL))
			--AND sdh.source_deal_header_id IN(158220,158221,158222,158223,158224,158226)
			AND YEAR(sdd.term_start)=YEAR(@term_start)
			AND MONTH(sdd.term_start)=MONTH(@term_start)
			AND (CASE WHEN sdh.source_deal_type_id IN (93, 94) THEN 1 ELSE ISNULL(dtd.deal_transport_id, -1) END) <> -1
			AND (CASE WHEN sdh.source_deal_type_id IN (93, 94) THEN 'y' ELSE 
				CASE WHEN tdp.imbalance_from ='n' THEN tdp.imbalance_to ELSE tdp.imbalance_from END END) = 'y'
			AND sdh.source_deal_type_id in (57,93,94)
			AND sml.source_minor_location_id = @source_minor_location_id
			AND sdh.counterparty_id = @counterparty_id

	 --SELECT @imbalance_volume			  
	RETURN @imbalance_volume
END


