IF NOT EXISTS (
       SELECT 1
       FROM   internal_deal_type_subtype_types
       WHERE  internal_deal_type_subtype_id = 102
   )
    INSERT INTO internal_deal_type_subtype_types
      (
        internal_deal_type_subtype_id,
        internal_deal_type_subtype_type,
        type_subtype_flag
      )
    SELECT 102,
           'Linear Model Option',
           'y'