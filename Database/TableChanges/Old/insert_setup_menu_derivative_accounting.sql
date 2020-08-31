

/**
* Module Derivative Accounting
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Derivative Accounting'
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        13240000,
        NULL,
        'Derivative Accounting',
        NULL,
        1,
        10000000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Module Derivative Accounting already exists for TRMTracker'

/**
* Menu Accounting 
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Accounting'
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10235499,
        NULL,
        'Accounting',
        NULL,
        1,
        13240000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Accounting menu already exist for Derivative Accounting Module'
/**
*Sub Menu Maintain Manual Journal Entries
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Maintain Manual Journal Entries'
              AND parent_menu_id       = 10235499
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10237000,
        'windowMaintainManualJournalEntries',
        'Maintain Manual Journal Entries',
        NULL,
        1,
        10235499,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 
    'Sub menu Maintain Manual Journal Entries already exist'
/**
* Sub Menu Close Accounting Period
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Close Accounting Period'
              AND parent_menu_id       = 10235499
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10237500,
        NULL,
        'Close Accounting Period',
        NULL,
        1,
        10235499,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Close Accounting Period  already exist'
/** 
* Menu Hedge Effectiveness Testing
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Hedge Effectivenesss Testing'
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        13200000,
        NULL,
        'Hedge Effectivenesss Testing',
        NULL,
        1,
        13240000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 
    'Hedge Effectivenesss Testing menu already exist for Derivative Accounting Module'
/** 
* Sub menu Hedge Effectiveness Assessment
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Hedge Effectiveness Assessment'
              AND parent_menu_id       = 13200000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10232300,
        NULL,
        'Hedge Effectiveness Assessment',
        NULL,
        1,
        13200000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Hedge Effectiveness Assessment already exists.'
/** 
* Sub menu View/Update Cum PNL Series
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'View/Update Cum PNL Series'
              AND parent_menu_id       = 13200000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10237300,
        NULL,
        'View/Update Cum PNL Series',
        NULL,
        1,
        13200000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu View/Update Cum PNL Series already exist.'


/** 
* Sub menu Run Measurement Process
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Run Measurement Process'
              AND parent_menu_id       = 13200000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10233400,
        NULL,
        'Run Measurement Process',
        NULL,
        1,
        13200000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Run Measurement Process already exist'
/** 
* Sub menu Copy Prior MTM Value
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Copy Prior MTM Value'
              AND parent_menu_id       = 13200000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10233300,
        NULL,
        'Copy Prior MTM Value',
        NULL,
        1,
        13200000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Copy Prior MTM Value already exist'


/** 
* Sub menu First Day Gain/Loss Treatment
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'First Day Gain/Loss Treatment'
              AND parent_menu_id       = 13200000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10234600,
        NULL,
        'First Day Gain/Loss Treatment',
        NULL,
        1,
        13200000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu First Day Gain/Loss Treatment already exist'	

/** 
* Menu Hedge Management
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Hedge Management'
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        13190000,
        NULL,
        'Hedge Management',
        NULL,
        1,
        13240000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Hedge Management menu already exist for Derivative Accounting Module.'
/** 
* Sub menu Delete Voided Deal
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Delete Voided Deal'
              AND parent_menu_id       = 13190000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10233000,
        NULL,
        'Delete Voided Deal',
        NULL,
        1,
        13190000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Delete Voided Deal already exist'


/** 
* Sub menu Setup Hedging Relationship Types
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Setup Hedging Relationship Types'
              AND parent_menu_id       = 13190000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10231900,
        NULL,
        'Setup Hedging Relationship Types',
        NULL,
        1,
        13190000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Setup Hedging Relationship Types already exist'


/** 
* Sub menu Designation of a Hedge
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Designation of a Hedge'
              AND parent_menu_id       = 13190000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10233700,
        NULL,
        'Designation of a Hedge',
        NULL,
        1,
        13190000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Designation of a Hedge already exist'

/** 
* Sub menu Automation of Forecasted Transaction
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Automation of Forecasted Transaction'
              AND parent_menu_id       = 13190000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10233700,
        NULL,
        'Automation of Forecasted Transaction',
        NULL,
        1,
        13190000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Automation of Forecasted Transaction already exist'

/** 
* Sub menu Automate Matching of Hedges
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Automate Matching of Hedges'
              AND parent_menu_id       = 13190000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10234400,
        NULL,
        'Automate Matching of Hedges',
        NULL,
        1,
        13190000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Automate Matching of Hedges already exist'

/** 
* Sub menu View Outstanding Automation Results
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'View Outstanding Automation Results'
              AND parent_menu_id       = 13190000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10234500,
        NULL,
        'View Outstanding Automation Results',
        NULL,
        1,
        13190000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu View Outstanding Automation Results already exist'

/** 
* Sub menu Amortize Deferred AOCI
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Amortize Deferred AOCI'
              AND parent_menu_id       = 13190000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10234100,
        NULL,
        'Amortize Deferred AOCI',
        NULL,
        1,
        13190000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Amortize Deferred AOCI already exist'
/** 
* Sub menu Reclassify Hedge De-Designation
* **/
IF NOT EXISTS (
       SELECT *
       FROM   setup_menu
       WHERE  display_name             = 'Reclassify Hedge De-Designation'
              AND parent_menu_id       = 13190000
              AND product_category     = 10000000
   )
BEGIN
    INSERT INTO setup_menu
      (
        -- setup_menu_id -- this column value is auto-generated
        function_id,
        window_name,
        display_name,
        default_parameter,
        hide_show,
        parent_menu_id,
        product_category,
        menu_order,
        menu_type
      )
    VALUES
      (
        10234000,
        NULL,
        'Reclassify Hedge De-Designation',
        NULL,
        1,
        13190000,
        10000000,
        0,
        1
      )
END
ELSE
    PRINT 'Sub menu Reclassify Hedge De-Designation already exist'