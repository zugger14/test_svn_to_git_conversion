IF COL_LENGTH('gis_certificate', 'source_deal_header_id_from') IS NULL
BEGIN
    ALTER TABLE gis_certificate ADD source_deal_header_id_from INT
END
GO