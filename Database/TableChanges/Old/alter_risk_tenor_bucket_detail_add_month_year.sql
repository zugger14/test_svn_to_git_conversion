IF NOT EXISTS(SELECT 'X' FROM information_schema.columns WHERE TABLE_NAME = 'risk_tenor_bucket_detail' AND COLUMN_NAME = 'fromMonthYear')
      ALTER TABLE risk_tenor_bucket_detail ADD fromMonthYear CHAR(1) NULL
      
IF NOT EXISTS(SELECT 'X' FROM information_schema.columns WHERE TABLE_NAME = 'risk_tenor_bucket_detail' AND COLUMN_NAME = 'toMonthYear')
      ALTER TABLE risk_tenor_bucket_detail ADD toMonthYear CHAR(1) NULL