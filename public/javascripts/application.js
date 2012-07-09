// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function () {

  $('.field.actions .blue').live('click', function(){
    $('.lightbox form').animate({ scrollTop: 0 }, 600);
  });

    $('.dropdown-toggle').dropdown();

    // add/remove instrument class textfield when you click the add link
    var options = null;
    $('a#add').click(function () {
        if (options == null) {
            options = $('.select_instrument_class').detach();
            $('<div class="new_instrument_class"><label for="instrument_class">Instrument class</label><input id ="instrument_class" type="text" size="30" name="instrument[instrument_class]"/>&nbsp;<a href="#" id="remove">Select existing class</a></div>').appendTo('.new_instrument_class_container');
        }
    });

    $('a[disabled]').click(function(){
        $(this).removeClass('ac_loading');
        return false;
    });

    $('a#remove').live('click', function () {
        if (options) {
            $('.new_instrument_class').remove();
            options.appendTo('.select_instrument_class_container');
            options = null
        }
    });

    // monkey patch for jquery ui autocomplete to highlight terms
    //http://stackoverflow.com/questions/2435964/jqueryui-how-can-i-custom-format-the-autocomplete-plug-in-results
    $.ui.autocomplete.prototype._renderItem = function (ul, item) {
        // escape label
        item.label = $("<pre>").text(item.label).html();
        // highlights first case-insensitive match
        item.label = item.label.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)(" + $.ui.autocomplete.escapeRegex(this.term) + ")(?![^<>]*>)(?![^&;]+;)", "i"), "<strong>$1</strong>");
        return $("<li></li>")
            .data("item.autocomplete", item)
            .append($("<a></a>").html(item.label))
            .appendTo(ul);
    };

});
