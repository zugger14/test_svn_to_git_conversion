<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <?php require('../../../adiha.php.scripts/components/include.file.v3.php'); ?>
</head>
<body>
<?php
    $namespace = 'show_plot';
    $var_criteria_id = get_sanitized_value($_GET['var_criteria_id']);
    $as_of_date = get_sanitized_value($_GET['as_of_date']);

    $layout_json = '[{
        id: "a",
        text: "Plots",
        header: false,
        width: 350
    }]';

    $run_storage_layout_obj = new AdihaLayout();
    echo $run_storage_layout_obj->init_layout('show_plot_layout', '', '1C', $layout_json, $namespace);

    $echarts_location = $app_php_script_loc . 'components/lib/apache-echarts/echarts.min.js';

    echo $run_storage_layout_obj->close_layout();
?>
</body>
<script src="<?php echo $echarts_location; ?>" crossorigin="anonymous"></script>
<script type="text/javascript">
    var var_criteria_id = '<?php echo $var_criteria_id; ?>';
    var as_of_date = '<?php echo $as_of_date; ?>';

    $(function() {
        show_plot.show_plot_layout.progressOn();

        var graph_cell = show_plot.show_plot_layout.cells('a');
        var canvas_Div = create_canvas_div(graph_cell);

        var basic_info = {
            "action": "spa_var_plotting_data",
            "flag": "m",
            "var_criteria_id": var_criteria_id,
            "as_of_date": as_of_date
        };

        adiha_post_data("return_json", basic_info, "", "", function(basic_info_data) {
            var basic_info_json = JSON.parse(basic_info_data);

            var data = {
                "action": "spa_var_plotting_data",
                "flag": "s",
                "var_criteria_id": var_criteria_id,
                "as_of_date": as_of_date
            };

            adiha_post_data("return_array", data, "", "", function(return_json) {
                var day_var_y_axis = 2;
                show_plot.show_plot_layout.progressOff();

                var distChart = echarts.init(canvas_Div);// getElementsByClassName('dhx_cell_cont_layout')[0]);

                var option = {
                    animation: false,
                    title: {
                        text: 'Distribution Chart',
                        left: 'center'
                    },
                    tooltip: {
                        trigger: 'axis',
                        axisPointer: {
                            type: 'cross'
                        },
                        formatter: function(params) {
                            return 'MTM: ' + params[0]["data"][0] + '<br/>PDF: ' + params[0]["data"][1];
                        }
                    },
                    yAxis: {
                        name: 'Probability Density',
                        nameLocation: 'middle',
                        splitNumber: 10,
                        scale: true,
                        axisLine: {show: false},
                        axisTick: {show: false},
                        nameTextStyle: {
                            fontWeight: 'bold',
                            fontSize: 15,
                            padding: [0, 0, 30, 0]
                        }
                    },
                    xAxis: {
                        name: basic_info_json[0]['x_title'] + ' (' + Intl.NumberFormat('en').format(basic_info_json[0]['mtm_avg']) + ')',
                        nameLocation: 'middle',
                        splitNumber: 10,
                        min: Math.round(basic_info_json[0]['xmin']),
                        max: Math.round(basic_info_json[0]['xmax']),
                        scale: true,
                        nameTextStyle: {
                            fontWeight: 'bold',
                            fontSize: 15,
                            padding: [20, 0, 0, 0]
                        }
                    },
                    visualMap: {
                        type: 'piecewise',
                        show: false,
                        dimension: 0,
                        seriesIndex: 0,
                        pieces: [{
                            gt: basic_info_json[0]['xmin'],
                            lt: basic_info_json[0]['var_avg'],
                            color: 'red'
                        }]
                    },
                    series: [{
                        type: 'line',
                        smooth: true,
                        symbol: 'none',
                        lineStyle: {
                            color: 'black',
                            width: 5
                        },
                        markLine: {
                            show: true,
                            silent: true,
                            symbol: ['none', 'none'],
                            label: {show: true, position: 'middle', color: 'black'},
                            lineStyle: {
                                color: 'black',
                                width: 3,
                                type: 'solid',
                            },
                            data: [
                                {
                                    xAxis: basic_info_json[0]['mtm_avg'],
                                    label: {show: false}
                                },
                                [
                                    {
                                        name: basic_info_json[0]['var_title'] + ' (' + Intl.NumberFormat('en').format(basic_info_json[0]['allvar']) + ')',
                                        symbol: ['arrow'],
                                        xAxis: basic_info_json[0]['var_avg'],
                                        yAxis: (basic_info_json[0]['ymin'] + basic_info_json[0]['ymax']) * (day_var_y_axis) / 100
                                    },
                                    {
                                        symbol: ['arrow'],
                                        xAxis: basic_info_json[0]['mtm_avg'],
                                        yAxis: (basic_info_json[0]['ymin'] + basic_info_json[0]['ymax']) * (day_var_y_axis) / 100
                                    }
                                ]
                            ]
                        },
                        areaStyle: {},
                        data: return_json
                    }]
                };

                distChart.setOption(option);
            });
        });
    });
</script>