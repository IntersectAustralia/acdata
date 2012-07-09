/*
*
* Placeholder.js (jQuery version) 1.0
* Creates a placeholder for browsers that don't support it
*
* @ Created by Guillaume Gaubert
* @ http://widgetulous.com/placeholderjs/
* @ © 2011 Guillaume Gaubert
*
* @ Default use :
* 	Placeholder.init();
*
*/

Placeholder = {
	
	// The normal and placeholder colors
	defaultSettings : {
		normal		: '#000000',
		placeholder : '#C0C0C0'
	},

	
	init: function(settings)
	{
		// Merge default settings with the ones provided
		if(settings)
		{
			$.extend(Placeholder.defaultSettings, settings);
		}
		
		// Let's make the funky part...
		$('input[type=text], textarea').each(function(){
			if($(this).attr("placeholder"))
			{
				// Set the future methods
				$(this).focus(function(){ Placeholder.onSelected(this); });
				$(this).blur(function(){ Placeholder.unSelected(this); });
				
				var place = $(this).attr("placeholder");
				// Set a faded out color for a "placeholder-effect"
				$(this).css("color", Placeholder.defaultSettings.placeholder);
				// Set the text
				$(this).val(place);
			}
		});
	},
	
	
	onSelected: function(input)
	{
		if($(input).val() == $(input).attr("placeholder"))
		{
			$(input).val('');
		}
		$(input).css("color", Placeholder.defaultSettings.normal);
	},
	
	unSelected: function(input)
	{
		// Reset a placeholder if the user didn't type text
		if($(input).val().length <= 0)
		{
			$(input).css("color", Placeholder.defaultSettings.placeholder);
			$(input).val($(input).attr("placeholder"));
		}
	}
};