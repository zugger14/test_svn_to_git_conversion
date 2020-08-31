IF NOT EXISTS(SELECT 'X' FROM information_schema.columns 
              WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'comments')
      ALTER TABLE source_deal_header_audit ADD comments text