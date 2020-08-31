IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'manual_je_detail' and column_name='comment')
ALTER TABLE manual_je_detail ADD comment VARCHAR(1000)
ELSE PRINT 'Comment column is already exists.'

IF NOT EXISTS(SELECT 'X' FROM information_schema.columns where table_name = 'manual_je_header' and column_name='comment')
ALTER TABLE manual_je_header ADD comment VARCHAR(1000)
ELSE PRINT 'Comment column is already exists.'