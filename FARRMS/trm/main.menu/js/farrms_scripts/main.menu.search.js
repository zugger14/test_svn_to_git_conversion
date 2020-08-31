var list = [];
var searched_text = '';
var index = 0;

// added jquery function to check if element contains text ignoring case
$.extend($.expr[":"], {
    "containsNC": function(elem, i, match, array) {
        return (elem.textContent || elem.innerText || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
    }
});

// added reverse function to reverse the jquery array
jQuery.fn.reverse = [].reverse;


// event for 'Ctrl + M' for searching
$(document).keypress(function(event) {
    if(event.which == 10){
        toggle_menu_searchbar();
    }
});

$(function() {
    var background_color = $('#logo').css('backgroundColor');
    $('#custom').html('.highlighted span{background-color: ' + background_color + '!important;}');

    $('#menu-lists li>ul>li>a').each(function() {
        var i = $(this).find('i');
        $(this).find('i').remove();
        $(this).wrapInner('<span>');
        $(this).append(i);
    });
});

// shows or hide search control tools
function show_tools(state) {
    if (state){
        $('#menu-searchbar > i').show();
    }
    else{
        $('#menu-searchbar > i').hide();
    }
}

// toggles menu search
function show_menu_searchbar() {


    // show expanded Menu
    $('#page-wrapper').removeClass('nav-small');
    $('#page-wrapper').removeClass('nav-none');

    // hide search tools
    if($('#menu-searchbar > input').val() == ''){
        show_tools(false);
    } else {
        show_tools(true);
    }

     // show searchbar and focus
    $('#menu-searchbar').slideToggle(100);
    $('#menu-searchbar > input').focus();
    $('.menu_overlay').show();

    $('#col-left-inner').css({
        transition: 'margin-top ease-in .1s'
    });

    //console.log('dfdfd');
    $('#col-left-inner').toggleClass('offset-top-search');
}

function clear_menu_search() {
    // Show the placeholder text as soon as the field gets cleared
    $('#menu-searchbar > .placeholder').show();

    show_tools(false);
    searched_text = '';
    $('#menu-searchbar > input').val('');
    list = [];
    index = 0;

    // collapse all expanded lists
    $('#menu-lists a.dropdown-toggle').parent().filter('.open').reverse().each(function(index, el) {
        $(this).children('a').click();
    });
    $('#menu-lists > li.open > a').click();
    $('#menu-lists li').show();
    $('#menu-lists li>a').removeClass('highlighted')
}

function highlight_next() {
    index = (index == (list.length - 1)) ? 0 : (index + 1);
    highlight_and_expand_to();
    
}

function highlight_previous() {
    index = (index == 0) ? (list.length - 1) : (index - 1);
    highlight_and_expand_to();
}

function search_menu_item(search_key) {
    searched_text = search_key;
    list = [];
    index = 0;

    if (searched_text != '') {
        show_tools(true);
        $('#menu-lists li').hide();
        $('#menu-lists').find("a:containsNC('" + searched_text + "')").parent().each(function(index, el) {
            $(this).show();
            $(this).parentsUntil('#menu_list').filter('li').show();

            $(this).find('li').show();

            list.push($(this));
        });

        highlight_and_expand_to();
    } else {
        clear_menu_search();

        // Show the placeholder text as soon as the field is empty
        $('#menu-searchbar > .placeholder').show();
    }
}

// Function to handle hiding the placeholder text as soon as the text is typed
function toggle_placeholder() {
    $('#menu-searchbar > .placeholder').hide();
}

function highlight_and_expand_to() {
    $('#menu-lists li>a').removeClass('highlighted');
    if(list[index]){
        list[index].children('a').addClass('highlighted')
        list[index].parentsUntil('#menu-lists').not('li.open').children('a').reverse().each(function(index, el) {
            $(this).click();
        });
        list[index].append("<input>").children('input').focus().remove();
    }
    $('#menu-searchbar>input').focus();
}