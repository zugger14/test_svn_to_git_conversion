IF NOT EXISTS(SELECT 'X' FROM information_schema.columns 
              WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'comments')
      ALTER TABLE source_deal_header_template ADD comments CHAR(1)