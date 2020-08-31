update
application_functions
set
func_ref_id = 10202200
where
function_id in (10111300,
10111400,
10141900,
10142400,
10161400,
10162600,
10171100,
10171300,
10201500,
10201900,
10202000,
10202100,
10202120,
10221200,
10221900,
10222400,
10232000,
10232800,
10233900,
10234200,
10234900,
10235100,
10235200,
10235300,
10235400,
10235500,
10235600,
10235700,
10235800,
10236100,
10236200,
10236400,
10236500,
10236600,
10237400,
13121200,
13160000,
13231000)

update
application_functions
set
func_ref_id = NULL
where
function_id in(10131016,
10161200)

Delete from  setup_menu where function_id in (10142400,
10235200,
10235800,
10235300,
10235600,
10235700,
10236400,
10236200,
10236100,
10236500,
10236600,
13121200,
13160000,
10235400,
10235500,
10235100,
10230091,
10230092,
10230093
) and product_category = 10000000 and parent_menu_id  != 10202200

IF exists (select 1 from application_functions where function_id = 10171300)
Begin 
update
application_functions
set
function_name = 'Deal Confirm Report',
function_desc = 'Deal Confirm Report',
func_ref_id = 10202200
where
function_id = 10171300
End
