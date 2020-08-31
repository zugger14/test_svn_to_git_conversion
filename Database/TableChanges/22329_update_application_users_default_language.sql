-- Update English as the language to already existing users
UPDATE application_users
SET [language] = 101600
WHERE [language] IS NULL