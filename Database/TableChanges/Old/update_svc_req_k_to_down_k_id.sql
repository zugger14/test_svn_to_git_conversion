--update  Svc Req K to Down K ID
UPDATE static_data_value SET code = 'Down K ID', [description] = 'Down K ID' WHERE [value_id] = -5631 AND code = 'Svc Req K'
PRINT 'Updated Static value -5631 - Down K ID.'
