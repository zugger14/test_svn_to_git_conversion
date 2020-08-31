UPDATE generic_mapping_header
SET    mapping_name = 'Ice Tenor Bucket'
WHERE  mapping_name = 'Tenor Bucket'


UPDATE generic_mapping_header
SET    mapping_name = 'Ice Projection Index Group'
WHERE  mapping_name = 'Projection Index Group'

UPDATE generic_mapping_header
SET    mapping_name = 'Ice Trader'
WHERE  mapping_name = 'Trader'

UPDATE generic_mapping_header
SET    mapping_name = 'Ice Broker'
WHERE  mapping_name = 'Broker'

UPDATE generic_mapping_header
SET    mapping_name = 'Ice CounterParty'
WHERE  mapping_name = 'CounterParty'

SELECT * FROM generic_mapping_header