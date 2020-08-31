IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'rec_generator' AND column_name = 'strategy_id')
BEGIN
  ALTER TABLE rec_generator ADD strategy_id INT
END

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'rec_generator' AND column_name = 'book_structure')
BEGIN
  ALTER TABLE rec_generator ADD book_structure VARCHAR(MAX)
END

IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'rec_generator' AND column_name = 'subbook_id')
BEGIN
  ALTER TABLE rec_generator ADD subbook_id VARCHAR(5000)
END