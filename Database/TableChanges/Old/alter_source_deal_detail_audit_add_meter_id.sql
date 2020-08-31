IF NOT EXISTS (
       SELECT *
       FROM   information_schema.columns
       WHERE  table_name = 'source_deal_detail_audit'
              AND column_name = 'meter_id'
   )
    ALTER TABLE source_deal_detail_audit ADD meter_id INT