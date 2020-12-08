<?php

/**
 * Spa html template screen
 * @copyright Pioneer Solutions
 */
?>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
    <style>
        html,
        body {
            width: 100%;
            height: 100%;
            margin: 0px;
            overflow: hidden;
        }
    </style>
</head>

<body>
    <?php
    $rights_spa_html_template = 10202400;
    $exec_call = (isset($_GET['exec_call'])) ? $_GET['exec_call'] : 'NULL';
    $report_name = (isset($_GET['report_name'])) ? $_GET['report_name'] : 'NULL';
    $report_name  = urldecode($report_name);
    $rnd = get_sanitized_value($_GET['rnd'] ?? '4');
    $enable_paging = get_sanitized_value($_GET['enable_paging'] ?? 0);

    list(
        $has_rights_spa_html_template
    )  = build_security_rights(
        $rights_spa_html_template
    );

    $layout_json = '[{
        id: "a",
        text: "Formula",
        width: 720,
        header: false,
        collapse: false,
        fix_size: [false,null]
    }]';

    $spa_html_menu_json = '[
        { id: "html", img: "html.gif", text: "HTML", title: "HTML"},
        { type: "separator" },
        { id: "batch", img: "batch.gif", text: "Batch", title: "Batch" }	
    ]';

    $name_space = 'spa_html_template';

    $spa_html_template_layout = new AdihaLayout();
    echo $spa_html_template_layout->init_layout('spa_html_template_layout', '', '1C', $layout_json, $name_space);

    $menu_obj = new AdihaMenu();
    echo $spa_html_template_layout->attach_menu_cell("spa_html_template_menu", "a");
    echo $menu_obj->init_by_attach("spa_html_template_menu", $name_space);
    echo $menu_obj->load_menu($spa_html_menu_json);
    echo $menu_obj->attach_event('', 'onClick', $name_space . '.spa_html_template_menu_click');

    echo $spa_html_template_layout->close_layout();
    ?>

    <script>
        var report_name = '<?php echo $report_name; ?>';
        var rnd = '<?php echo $rnd; ?>';

        $(function() {
            load_report('html');
        });

        spa_html_template.spa_html_template_menu_click = function(id, zoneId, cas) {
            if (id == 'html') {
                load_report('html');
            } else if (id == 'pdf') {
                load_report('pdf');
            } else if (id == 'excel') {
                load_report('excel');
            } else if (id == 'batch') {
                run_batch_standard_report();
            } else if (id == 'rp') {
                var exec_sql = "<?php echo $exec_call; ?>";
                open_grid_pivot('', report_name, 0, exec_sql, 'Optimizer Position Detail')
            }
        }

        function load_report(call_type) {
            var exec_call = "<?php echo $exec_call; ?>";
            var enable_paging = "<?php echo $enable_paging; ?>";
            var paging_parameter;

            paging_parameter = (enable_paging == 1) ? '&enable_paging=true&np=1' : '';

            if (call_type == 'html') {
                var std_report_url = js_php_path + '/dev/spa_html.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true&rnd=' + rnd + paging_parameter;
            } else if (call_type == 'pdf') {
                var std_report_url = js_php_path + '/dev/spa_pdf.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true&rnd=' + rnd;
            } else if (call_type == 'excel') {
                var std_report_url = js_php_path + '/dev/spa_html.php?__user_name__=' + js_user_name + '&spa=' + exec_call + '&pop_up=true&writeCSV=true&rnd=' + rnd;
            }

            spa_html_template.spa_html_template_layout.cells('a').attachURL(std_report_url);
        }

        function run_batch_standard_report() {
            var exec_call = "<?php echo $exec_call; ?>";

            if (exec_call != false) {
                var param = 'call_from=' + report_name + '&gen_as_of_date=1';
                adiha_run_batch_process(exec_call, param, report_name);
            }
        }

        function TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, asofdate, asofdate_to) {
            parent.parent.parent.parent.TRMHyperlink(func_id, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, asofdate, asofdate_to)
        }
    </script>
</body>

</html>