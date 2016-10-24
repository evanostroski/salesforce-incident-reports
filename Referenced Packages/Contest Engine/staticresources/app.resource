/**
 *
 * Class Name        : app.resource
 * Class Purpose     : Is the repository of application javascript logic and methods.
 * Class Description : SCB requires a core set of javascript logic to bind events to the pages,
 *                     enhance styles, and provide other utility methods for showing and hiding
 *                     elements on a page. This class provides for all of that.
**/ 

/**Put jQuery in noConflict mode so as to not conflict with standard salesforce logic. */
jQuery.noConflict();

/** Store our version of internet explorer for special use case handling. */
var verIE;

/**
 * When the document is ready (binding through the appropriate jquery event),
 * initialize the page.
 * 
 */
(function($) {
    $(document).ready(function(){
        initPage();
    });
})(jQuery);

/**
 * Helper function used to get a component with a given ID. Due to the
 * way salesforce structures component IDs we need to have this structured this way.
 * 
 */
function getID(_id){
    try {
        return jQuery('[id$="' + _id + '"]');
    } catch (exception) {
        return null;
    }
}

/**
 * Perform common page initialization logic.
 * 
 */
function initPage() {
        var $ = jQuery;
        
        var isIE = getIsIE();
        
        if (isIE >= 9) {
            $('.helpOrb').css('top','auto');
        } else if (isIE < 8) {
            $('.datePicker').css('width', '17em');
            $('.TB_Toolbar td').css('overflow', 'hidden');
        }


        //Update the styling on specific table cells 
        function fixTDs(){
            $('.dataCol').css('width','auto');
            $('.sub input[type="checkbox"], div[id$="leaderboard_updates"] select').each(function(){
                $(this).parent().css('width', $(this).outerWidth() + 5);
            });
            $('.dataCol').each(function(){
                $(this).css('width', $(this).width());
            });
            $('div[id$="leaderboardUpdatesFrequency_Weekly"]').css('margin-top', '-9px');
        }
        
        $(window).resize(function(){
            fixTDs();
        });

                                  
        //keep last within ready()
        fixTDs();
        
        //hide the loader
        var theLoader = getID('theLoader');
        if (theLoader != null) {
            theLoader.css('display', 'none');
        }
        //show the page
        var thePage = getID('thePage');
        if (thePage != null) {
            thePage.css('display', 'block');
        }
}

/**
 * Apply special styling to the leaderboard left hand side menu. 
 * This method is called by LeaderboardMenu.page to ensure that the appropriate menu
 * which is selected has a visual effect applied to it making it look selected.
 * 
 */
function applyLeaderboardMenuStyling() {
	var $ = jQuery;
	
    if($('div.leftMenu').length > 0 && ($('.pbTitle').html() != null || $('#leaderboardLeftHeader').html() != null)){
        if($('#leaderboardLeftHeader').html() != null){
            getID('viewLeaderboardLink').addClass('active');
        }
        else if($('#viewAllContestEntriesHeader').html() != null){
            getID('viewAllContestEntriesLink').addClass('active');
        }
        else if($('#viewContestUsersHeader').html() != null){
            getID('viewContestLink').addClass('active');
        }        
        else if($('.pbTitle').html().search(/notif/i) >= 0){
            getID('editNotificationsLink').addClass('active');
        }
        else if($('.pbTitle').html().search(/win/i) >= 0){
            getID('viewWinnersLink').addClass('active');
        }
        else if($('.pbTitle').html().search(/view/i) >= 0){
            getID('viewContestLink').addClass('active');
        }
        else if($('.pbTitle').html().search(/points|entries/i) >= 0){
            getID('viewAdHocEntriesLink').addClass('active');
        }
        
        $('div.leftMenu a.active').removeClass('tertiaryPalette').addClass('secondaryPalette');
        
        $('.leftMenuTab').each(function(){
            if(!$(this).hasClass('secondaryPalette')){
                $(this).hover(function(){
                    $(this).removeClass('tertiaryPalette').addClass('secondaryPalette');
                }, function(){
                    $(this).addClass('tertiaryPalette').removeClass('secondaryPalette');
                });
            }
        });
    }	
}

/**
 * Apply special handling to the leaderboard updates frequency fields. 
 * This method is used primarily by AdminContestNotifications.page, 
 * PipelineStep5.page and PipelineStep6.page in order to toggle to appropriate display of 
 * fields depending on if leaderboard updates are specified to be sent daily or weekly.
 * 
 */
function applyLeaderboardUpdatesFrequencyHandling() {
	var $ = jQuery;
	
	//
	//Apply styling to the leaderboardUpdatesFrequency object.
	//
    var dropdowns = [
         'leaderboardUpdatesFrequency'
    ];
    
    for (i = 0; i < dropdowns.length; i++){
    	var sub = getID(dropdowns[i] + '_sub');
        if (sub != null && sub.length > 0){
             //console.log(sub);
             sub.addClass('sub');
             if(!getID(dropdowns[i]).val()) sub.hide();
             getID(dropdowns[i]).attr('data-id', dropdowns[i]).change(function(){
                 var sub = getID($(this).attr('data-id') + '_sub');
                 if ($(this).val()) {
                     sub.slideDown(200, function(){
                         if(isIE != null){
                             $('.helpButton, .helpButtonOn').css('position','static').css('position','relative');
                         }
                     });
                 }
                 else {
                     if (isIE != null){
                         $('.helpButton, .helpButtonOn').css('position','static').css('position','relative');
                     }
                     sub.slideUp(200, function(){
                         if(isIE != null){
                             $('.helpButton, .helpButtonOn').css('position','static').css('position','relative');
                         }
                     });
                 }
             });
         }
    }
	
	//
    //Apply handling logic to the leaderboardUpdatesFrequency select list.
    //Listing for specific selections and show/hide values on the page as appropriate
    //
    var lbuf = getID('leaderboardUpdatesFrequency');
    if (lbuf != null) {
        if (!lbuf.find('option[value="Weekly"]').is(':selected')) {
            var item = getID('leaderboardUpdatesFrequency_Weekly');
            if (item != null) {
                item.hide();
            }
        }
        lbuf.change(function(){
            if (lbuf.find('option[value="Weekly"]').is(':selected')) {
                var item = getID('leaderboardUpdatesFrequency_Weekly');
                item.slideDown(200);
            }
            else {
                var item = getID('leaderboardUpdatesFrequency_Weekly');
                item.slideUp(200);
            }
        });
    }	
}

/**
 * Show the "page loading" div. This is so that
 * the page can display a nice loading message while all javascript processing is going on
 * doing things such as showing and hiding fields.
 * 
 * This is mainly called by PipelineStep2.page after user takes various actions and the page needs to refresh.
 * 
 */
function showLoader() {
    //Hide the page
    var thePage = getID('thePage');
    if (thePage != null) {
        thePage.css('display', 'none');
    }

    //Show the loader
    var theLoader = getID('theLoader');
    if (theLoader != null) {
        theLoader.css('display', 'block');
    }
}

/**
 * This is logic called by the contest wizard when creating a new contest
 * used on the various pipeline step pages. (Mainly step 2). What it does is
 * look for checkboxes where the user checks that they want to filter.
 * 
 * If they check that, then the corresponding section with all the details required to
 * be entered for that section is displayed.
 * 
 * For example, if the user wants to reward on opportunities, then the div which contains
 * all the fields for opportunities will be displayed.
 * 
 * For the IDs of the checkboxes passed in the array, it will look for a checkbox with that ID on 
 * the page. If it finds it, it looks for a section checkboxId + "_sub" appended to it. It then 
 * shows/hides that section based on checkbox state. So if the checkbox ID is events, then
 * this function will look for a section with ID events_sub
 * 
 * @param checkboxes An array of the IDs of checkboxes to find.
 * 					 These checkboxes are then looked up on the page and their
 *                   corresponding sections shown or hidden based on the checkbox state.
 */
function initEnableDisablePageSectionsByCheckboxState(checkboxes) {
    var $ = jQuery;
	
    for(i = 0; i < checkboxes.length; i++){
	      var sub = getID(checkboxes[i] + '_sub');
	      if (sub != null && sub.length > 0){
	          //console.log(sub);
	          sub.addClass('sub');
	          var cb = getID(checkboxes[i]);
	          if (cb != null) {
	            if (!cb.is(':checked')) {
	            	sub.hide();
	            }
	            
	            cb.attr('data-id', checkboxes[i]).click(function(){
	                var sub = getID($(this).attr('data-id') + '_sub');
	                if ($(this).is(':checked')) {
	                    sub.slideDown(200, function(){
	                        if (isIE != null){
	                            $('.helpButton, .helpButtonOn').css('position','static').css('position','relative');
	                        }
	                    });
	                }
	                else {
	                    if (isIE != null){
	                        $('.helpButton, .helpButtonOn').css('position','static').css('position','relative');
	                    }
	                    sub.slideUp(200, function(){
	                        if(isIE != null){
	                            $('.helpButton, .helpButtonOn').css('position','static').css('position','relative');
	                        }
	                    });
	                }
	            });
          }
      }
    }
}


/**
 * This is logic called by the contest wizard when creating a new contest
 * used on the various pipeline step pages. (Mainly step 2). What it does is
 * look for checkboxes where the user checks that they want to filter on
 * an event created description. If they check that, then the corresponding input textfield
 * where the event created description needs to be specified is enabled. When unchecked,
 * then the field gets disabled.
 * 
 * For the IDs of the checkboxes passed in the array, it will look for a checkbox with that ID on 
 * the page. If it finds it, it looks for a field with the checkboxId + "Value" appended to it. It then 
 * shows/hides that field based on checkbox state. So if the checkbox ID is eventsCreatedDescription, then
 * this function will look for a field with ID eventsCreatedDescriptionValue
 * 
 * @param checkboxes An array of the IDs of checkboxes to find.
 * 					 These checkboxes are then looked up on the page and their
 *                   corresponding input fields shown or hidden based on the checkbox state.
 */
function initEnableDisableFieldsByCheckboxState(checkboxFields) {
    var $ = jQuery;
    
    if (checkboxFields == null) {
    	return;
    }
    
    //for (var i in checkboxFields){
    for (i = 0; i < checkboxFields.length; i++) {
		var fieldId = checkboxFields[i];
		initEnableDisableFieldByCheckboxState (fieldId);

		//Tried this to see if we can make it perform better in IE
		//but it didn't work.
		//setTimeout("initEnableDisableFieldByCheckboxState('" + fieldId + "')", 0);    	
        
    	/*
    	var cb = getID(checkboxFields[i]);
    	
        if (cb != null) {                        
            var input = getID( checkboxFields[i] + 'Value' );
            var lkwgt = getID( checkboxFields[i] + 'Value_lkwgt' );            
            //var itemToHide = getID(checkboxFields[i] + 'Value_lkwgt');
            if (lkwgt != null) {
            	lkwgt.hide();
            }
            
            if (cb != null && cb.is(':checked') ) {
                if (input != null) {
                    input.removeAttr('disabled');
                }
                
                if (lkwgt != null && lkwgt != undefined){
                	lkwgt.show();
                }
            }
            else {
                if (input != null) {
                    input.attr('disabled', 'disabled');
                }
                
                if( lkwgt != null && lkwgt != undefined ){
                	lkwgt.hide();
                }
            }
            
            try {
                cb.attr('data-id', checkboxFields[i]);
                
                cb.click(function(){
                    var cb = $(this);
                    var input = getID( $(this).attr('data-id') + 'Value' );
                    var lkwgt = getID( $(this).attr('data-id') + 'Value_lkwgt' );
                    
                    if( cb.is(':checked') ){
                        if (input != null) {
                            input.removeAttr('disabled');
                        }
                        
                        if( lkwgt != null && lkwgt != undefined ){
                        	lkwgt.show();
                        }
                    }
                    else {
                        if (input != null) {                    
                            input.attr('disabled', 'disabled');
                        }
                        
                        if( lkwgt != null && lkwgt != undefined ){
                        	lkwgt.hide();
                        }
                    }
                });
            } catch (exception) { 
            } 
        }
        */
    }
}

/**
 * This is logic called by the contest wizard when creating a new contest
 * used on the various pipeline step pages. (Mainly step 2). What it does is
 * look for checkboxes where the user checks that they want to filter on
 * an event created description. If they check that, then the corresponding input textfield
 * where the event created description needs to be specified is enabled. When unchecked,
 * then the field gets disabled.
 * 
 * For the ID of the checkbox passed in the parameter, it will look for a checkbox with that ID on 
 * the page. If it finds it, it looks for a field with the checkboxId + "Value" appended to it. It then 
 * shows/hides that field based on checkbox state. So if the checkbox ID is eventsCreatedDescription, then
 * this function will look for a field with ID eventsCreatedDescriptionValue
 * 
 * @param checkboxField The ID of checkboxes to find.
 * 					 The checkbox is then looked up on the page and their
 *                   corresponding input fields shown or hidden based on the checkbox state.
 */
function initEnableDisableFieldByCheckboxState(checkboxField) {
    var $ = jQuery;
    	    
    if (checkboxField == null) {
    	return;
    }
    
	var cb = getID(checkboxField);

    if (cb != null) {                        
        var input = getID( checkboxField + 'Value' );
        //lkwgt is the lookup widget, the lookup button that appears next to fields such as account
        var lkwgt = getID( checkboxField + 'Value_lkwgt' );      
        
        if (lkwgt != null) {
        	lkwgt.hide();
        }
        
        if (cb != null && cb.is(':checked') ) {
            if (input != null) {
                input.removeAttr('disabled');
            }
            
            if (lkwgt != null && lkwgt != undefined){
            	lkwgt.show();
            }
        }
        else {
            if (input != null) {
                input.attr('disabled', 'disabled');
                input.val('');
            }
            
            if( lkwgt != null && lkwgt != undefined ){
            	lkwgt.hide();
            }
        }
        
        try {
            cb.attr('data-id', checkboxField);
            
            cb.click(function(){
                var cb = $(this);
                var input = getID( $(this).attr('data-id') + 'Value' );
                var lkwgt = getID( $(this).attr('data-id') + 'Value_lkwgt' );
                
                if( cb.is(':checked') ){
                    if (input != null) {
                        input.removeAttr('disabled');
                    }
                    
                    if( lkwgt != null && lkwgt != undefined ){
                    	lkwgt.show();
                    }
                }
                else {
                    if (input != null) {                    
                        input.attr('disabled', 'disabled');
                        input.val('');
                    }
                    
                    if( lkwgt != null && lkwgt != undefined ){
                    	lkwgt.hide();
                    }
                }
            });
        } catch (exception) { 
        } 
    }
}


/**
 * Get the version of Internet explorer that is being used.
 * Null if not internet explorer, otherwise the version number is returned.
 * 
 */
function getIsIE() {
    if (verIE == null) {
        if (jQuery.browser.msie){
            verIE = parseFloat(jQuery.browser.version);
        }
    }
    return verIE;
}

/**
 * Perform initialization steps to make a single select list into the set of two
 * boxes where the selected items are moved from the left box to the right box.
 * 
 */
function initSelectionMoveBoxes(moveBoxes) {
    var $ = jQuery;
    var isIE = getIsIE();
    
    if (moveBoxes == null) {
    	return;
    }
   
    for(i = 0; i < moveBoxes.length; i++){
        //creates second select list with id and name of first
        var lBox = getID(moveBoxes[i]);
        if (lBox != null && getID(moveBoxes[i] + '-l') != null && getID(moveBoxes[i] + '-l').length <= 0 ){
            var rBox = lBox.clone();
            lBox.attr('name',' ').attr('id',moveBoxes[i] + '-l').attr('data-id', moveBoxes[i]);
            rBox.attr('data-id', moveBoxes[i]);
            
            //wraps left box and adds buttons and right box
            lBox.parent().append('\<table class=\"move-box\"\>\<tbody\>\<tr\>\<td\>\</td\>\<td\>\<a style=\"display: block;\" id=\"' + moveBoxes[i] + '-rb\"\>&gt;&gt;\</a\>\<a style=\"display: block;\" id=\"' + moveBoxes[i] + '-lb\"\>&lt;&lt;\</a>\</td\>\<td\>\</td\>\</tr\>\</tbody\>\</table\>');
            lBox.parent().find('table.move-box').find('td:last').append(rBox);
            lBox.parent().find('table.move-box').find('td:first').append(lBox);
            
            rBox.find('option').remove();
            lBox.find('option:selected').remove().appendTo(rBox);
            
            /****TEA 1/15/12 Commented this out to fix fogbugz bug #3311.
             * Added appropriate logic to the IEReset function below to handle this issue
             * which sets the css width property to 0 and then removes it.
             * This forces the control to be redrawn.          	
            if (isIE >= 9){
                if(rBox.find('option').length == 0){
                    rBox.append('\<option class=\"removeMe\" style=\"color: #fff;\"\>text text text text text text text text text text text text text text text text text text text text text text text text text text \</option\>');
                    rBox.focus(function(){
                        $(this).find('.removeMe').remove();
                        rBox.unbind('click');
                    });
                }
            }
            ****/                    
            
            //listener to move objects right
            $('#' + rBox.attr('data-id') + '-rb').addClass('btn').click(function(){
                var id = $(this).attr('id').substr(0,$(this).attr('id').length - 3);
                $('#' + id + '-l option:selected').remove().appendTo(getID(id));
                IEReset(id);
            });
            lBox.dblclick(function(){
                var id = $(this).attr('data-id');
                $('#' + id + '-l option:selected').remove().appendTo(getID(id));
                IEReset(id);            
            });
            
            //listener to move objects left
            $('#' + rBox.attr('data-id') + '-lb').addClass('btn').click(function(){
                var id = $(this).attr('id').substr(0,$(this).attr('id').length - 3);
                getID(id).find('option:selected').remove().appendTo($('#' + id + '-l'));
                IEReset(id + '-l');
            });
            rBox.dblclick(function(){
                var id = $(this).attr('data-id');
                getID(id).find('option:selected').remove().appendTo($('#' + id + '-l'));
                IEReset(id + '-l');
            });
            
            function IEReset(idOfControlToReset){
                if (isIE != null){
                    $('.removeMe').remove();
                    
                    rBox.unbind('click');
                    $('option').css({ 'font-size': '99%', 'font-family':'monospace' }).css({ 'font-size': '100%', 'font-family':'inherit', 'overflow':'visible' });                    
                }
                
                //
                //fix for fogbugz bug #3311. 
				//See post http://stackoverflow.com/questions/5908494/select-only-shows-first-char-of-selected-option
				//Issue specific to IE 9 and adding options dynamically to a select list when the select list was originally empty.
                //When we dont include dummy text and start off with an empty select list, 
                //only the first letter of the selected value getting appended into the control is displayed.
                //This is a workaround to fix that, and not include the dummy text so we dont get the error
                //as referenced in case #3311
                var isIE = getIsIE();
                if (isIE >= 9){
	                getID(idOfControlToReset).css('width', 0);
	                getID(idOfControlToReset).css('width', '');
                }                
            }
        }
        
    }
    //setup form submit
    $('form').submit(function(){
        if(isIE >= 9){
            $('option.removeMe').remove();
        }
        for(i = 0; i < moveBoxes.length; i++){
            if(getID(moveBoxes[i]) != null){
                getID(moveBoxes[i]).find('option').attr('selected','selected');
            }
        }
    });
}

/**
 * For a give select box, find all of the options in it and
 * set them to being selected.
 * 
 */
function selectOptions(selectBox) {
	if (getID(selectBox) != null) {
		getID(selectBox).find('option').attr('selected', 'selected');
	}
}

/*
* This is needed for ajax page requests which contain the dual control multi select boxes.
* On a submit/ajax request, this will need to be called to ensure all the items in the selected box
* are selected and submitted with the request. If this doesnt execute, then only the selected(highlighted) items
* will be submitted.
*/
function selectAllInMultiSelectBoxes() {
    var $ = jQuery;
    var isIE = getIsIE();

    //select move box
    var moveBoxes = [
        'contestUsers',
        'contestAdmins',
        'teamUsers',
        'products',
        'oppProducts',
        'oppProducts2',
        'accountFields',
        'contactFields',
        'eventFields',
        'leadFields',
        'taskFields',
        'opportunityFields',
        'chatterGroups'
    ];
    
    if(isIE >= 9){
        $('option.removeMe').remove();
    }
    for(i = 0; i < moveBoxes.length; i++){
        if(getID(moveBoxes[i]) != null){
            getID(moveBoxes[i]).find('option').attr('selected','selected');
        }
    }                   
}  


/** -------------------------- JPLACED JQUERY PLUGIN -------------------------- **/
/*
	Copyright (c) 2011 ePrize LLC., http://eprize.com
	
	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:
	
	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	Author: Glenn Martin
*/
(function( $ ){
	$.fn.jplaced = function( method ) {
		
		var $s = $.fn.jplaced;
		if ( $s.methods[method] ) {
			return $s.methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
		}
		else if( typeof method == 'object' || !method ) {
			return $s.methods.init.apply( this, arguments );
		}
		else {
			$.error('$.fn.jplaced has no method ' + method);
		}
		
	};
	
	$.extend($.fn.jplaced, {
		
		numS : 0,
		
		defaults : {
			appendText : '', //text to append after number
			outputType : 'digits',
			outputClass : 'placed',
			capitalize : true
		},
		
		methods : {
					
			init : function( options ){
				
				var $jplaced = $.fn.jplaced;
				
				return this.each(function() {
					
					var $t = $(this);
					var settings = $jplaced.defaults;
					
					if( options ) $.extend( settings, options );
					
					var fullString = '';
					
					if( settings.outputType.toLowerCase() == 'digits' ){
						fullString = $jplaced.methods.getPlacedDigits( $t.html() , settings ) + settings.appendText;
					}
					else if( settings.outputType.toLowerCase() == 'placedword' || settings.outputType.toLowerCase() == 'placeword' ){
						fullString = '\<span class=\"' + settings.outputClass + '\"\> ' + $jplaced.methods.getPlacedWord( $t.html() , settings ) + settings.appendText + ' \</span\>';
					}
					else if( settings.outputType.toLowerCase() == 'word' ){
						fullString = '\<span class=\"' + settings.outputClass + '\"\> ' + $jplaced.methods.getWord( $t.html() , settings ) + settings.appendText + ' \</span\>';
					}
					
					if( settings.capitalize && settings.outputType.toLowerCase().search('word') ){
						var splitString = fullString.split(' ');						
						fullString = '';
						/*
                        for(var i in splitString){
							splitString[i] = splitString[i].charAt(0).toUpperCase() + splitString[i].slice(1);
							
							fullString += splitString[i] + ' ';
							
						}
                        */
                        for(var i=0; i<splitString.length; i++){
                            splitString[i] = splitString[i].charAt(0).toUpperCase() + splitString[i].slice(1);
                            
                            fullString += splitString[i] + ' ';
                            
                        }
					}
					
					$t.html(fullString);
					
				});
				
			},
			
			getPlacedDigits : function ( _string , settings ){
				
				var num = parseInt( _string , 10 );
				
				if ( !isNaN(num) ){
					
					if ( num % 10 == 1 && num % 100 != 11 ){
						return (num + '\<span class=\"' + settings.outputClass + '\"\>st\</span\>');
					}
					else if ( num % 10 == 2 && num % 100 != 12 ){
						return (num + '\<span class=\"' + settings.outputClass + '\"\>nd\</span\>');
					}
					else if ( num % 10 == 3 && num % 100 != 13 ){
						return (num + '\<span class=\"' + settings.outputClass + '\"\>rd\</span\>');
					}
					else {
						return (num + '\<span class=\"' + settings.outputClass + '\"\>th\</span\>');
					}
				}
				
				return _string;
			},
			
			getWord : function ( _string ){
				var $jp = $.fn.jplaced;
				
				_string = _string.replace(/ /g, '').replace(/\,/g, '');
				var num = parseInt( _string , 10 );
				
				if ( !isNaN(num) ){
					
					var toReturn = '';
					if ( num < 10 ){
						toReturn = $jp.singles[ (num) ];
					}
					else {
						var strNum = String(num);
						
						if ( strNum.length < 3 ){
							if ( strNum[1] == '0' ){
								toReturn = $jp.tens[strNum[0]];
							}
							else if ( strNum[0] != '1' ){
								toReturn = $jp.tens[strNum[0]] + ' ' + $jp.singles[strNum[1]];
							}
							else {
								toReturn = $jp.specials[strNum];
							}
						}
						else if ( strNum.length == 3 ){
							if ( strNum[1] == '0' && strNum[2] == '0' ) {
								toReturn = $jp.singles[strNum[0]];
								if( strNum[0] != '0' ){
									toReturn += ' hundredth';
								}
							}
							else {
								if( strNum[0] != '0' ){
									toReturn = $jp.singles[strNum[0]] + ' hundred and ';
								}
								
								toReturn += $jp.methods.getWord( (strNum[1] + strNum[2]) );
							}
						}
						else {
							if( strNum.length % 3 != 0 ){
								toReturn = $jp.methods.getWord( strNum.substr( 0 , strNum.length % 3 ) );
								if ( strNum.substr( strNum.length % 3 , strNum.length ).search(/[^0]/) < 0 ){
									toReturn += ' ' + $jp.bigNum[ Math.ceil(strNum.length / 3) - 2 ];
								}
								else {
									toReturn += ' ' + $jp.bigNum[ Math.ceil(strNum.length / 3) - 2 ] + ' and ' + $jp.methods.getWord( strNum.substr( strNum.length % 3 , strNum.length ) );
									//console.log( strNum.substr( strNum.length % 3 , strNum.length ) );
								}
							}
							else {
								toReturn = $jp.methods.getWord( strNum.substr( 0 , 3 ) );
								if ( strNum.substr( 3 , strNum.length ).search(/[^0]/) < 0 ){
									toReturn += ' ' + $jp.bigNum[ Math.ceil(strNum.length / 3) - 2 ];
								}
								else {
									toReturn += ' ' + $jp.bigNum[ Math.ceil(strNum.length / 3) - 2 ] + ' and ' + $jp.methods.getWord( strNum.substr( 3 , strNum.length ) );
									//console.log( strNum.substr( strNum.length % 3 , strNum.length ) );
								}
							}
						}
					}
					
					return toReturn;
				}				
				
				return _string;
			},
			
			
			
			getPlacedWord : function ( _string ){
				var $jp = $.fn.jplaced;
				
				_string.replace(/ /g, '').replace(/\,/g, '');
				var num = parseInt( _string , 10 );
				
				if ( !isNaN(num) ){
					
					var toReturn = '';
					if ( num < 10 ){
						toReturn = $jp.placedSingles[ (num) ];
					}
					else {
						var strNum = String(num);
						//console.log( strNum );
						
						if ( strNum.length < 3 ){
							if ( strNum[1] == '0' ){
								toReturn = $jp.placedTens[strNum[0]];
							}
							else if ( strNum[0] != '1' ){
								toReturn = $jp.tens[strNum[0]] + ' ' + $jp.placedSingles[strNum[1]];
							}
							else {
								toReturn = $jp.placedSpecials[strNum];
							}
						}
						else if ( strNum.length == 3 ){
							if ( strNum[1] == '0' && strNum[2] == '0' ) {
								toReturn = $jp.singles[strNum[0]];
								if( strNum[0] != '0' ){
									toReturn += ' hundredth';
								}
							}
							else {
								if( strNum[0] != '0' ){
									toReturn = $jp.singles[strNum[0]] + ' hundred and ';
								}
								
								toReturn += $jp.methods.getPlacedWord( (strNum[1] + strNum[2]) );
							}
						}
						else {
							if( strNum.length % 3 != 0 ){
								toReturn = $jp.methods.getWord( strNum.substr( 0 , strNum.length % 3 ) );
								if ( strNum.substr( strNum.length % 3 , strNum.length ).search(/[^0]/) < 0 ){
									toReturn += ' ' + $jp.bigNum[ Math.ceil(strNum.length / 3) - 2 ] + 'th';
								}
								else {
									toReturn += ' ' + $jp.bigNum[ Math.ceil(strNum.length / 3) - 2 ] + ' and ' + $jp.methods.getPlacedWord( strNum.substr( strNum.length % 3 , strNum.length ) );
									//console.log( strNum.substr( strNum.length % 3 , strNum.length ) );
								}
							}
							else {
								toReturn = $jp.methods.getWord( strNum.substr( 0 , 3 ) );
								if ( strNum.substr( 3 , strNum.length ).search(/[^0]/) < 0 ){
									toReturn += ' ' + $jp.bigNum[ Math.ceil(strNum.length / 3) - 2 ] + 'th';
								}
								else {
									toReturn += ' ' + $jp.bigNum[ Math.ceil(strNum.length / 3) - 2 ] + ' and ' + $jp.methods.getPlacedWord( strNum.substr( 3 , strNum.length ) );
									//console.log( strNum.substr( strNum.length % 3 , strNum.length ) );
								}
							}
							
							
						}
					}
					
					return toReturn;
				}				
				
				return _string;
			},
			
			wordToNum : function( _string ){
			
				/********************************************/
				/********** NOT FULLY IMPLEMENTED ***********/
				/********************************************/
				
				
				var $jp = $.fn.jplaced;
				var words = _string.toLowerCase().split(' ');
				
				var toReturn = '';
				for( i = 0; i < words.length; i++ ){
					var word = words[i];
					
					for( j = 0; j < $jp.singles.length; j++ ){
						var addZero = false;
						if( words[i-1] == 'hundred' ) addZero = true;
						else if ( words[i-1] == 'and' && words[i-2] == 'hundred' ) addZero = true;
						if( word == $jp.singles[j] && !addZero ) toReturn += j;
						else if( word == $jp.singles[j] && addZero ) toReturn += '0' + j;
					}
					for( j = 0; j < $jp.tens.length; j++ ){
						var addZero = false;
						for( k = 0; k < $jp.bigNum.length; k++ ){
							if( words[i-1] == $jp.bigNum[k] ) addZero = true;
							else if( words[i-1] == 'and' && words[i-2] == $jp.bigNum[k] ) addZero = true;
						}
						if( word == $jp.tens[j] && !addZero ) toReturn += j;
						else if( word == $jp.tens[j] && addZero ) toReturn += '0' + j;
						
						if( word == $jp.tens[j] && i == words.length - 1 ) toReturn += '0';
					}
					
					//specials
					for( var key in $jp.specials ){
						var addZero = false;
						for( k = 0; k < $jp.bigNum.length; k++ ){
							if( words[i-1] == $jp.bigNum[k] ) addZero = true;
							else if( words[i-1] == 'and' && words[i-2] == $jp.bigNum[k] ) addZero = true;
						}
						if( word == $jp.specials[key] && !addZero ) toReturn += key;
						else if( word == $jp.specials[key] && addZero ) toReturn += '0' + key;
					}
				}
				
				return toReturn;
			}
			
			
			
		}, // end methods
		
		bigNum : [
			'thousand',
			'million',
			'billion',
			'trillion',
			'quadrillion'
		],
				
		placedSingles : [
			'',
			'first',
			'second',
			'third',
			'fourth',
			'fifth',
			'sixth',
			'seventh',
			'eigth',
			'ninth'
		],
		
		singles : [
			'',
			'one',
			'two',
			'three',
			'four',
			'five',
			'six',
			'seven',
			'eigth',
			'nine'
		],
		
		tens : [
			'',
			'ten',
			'twenty',
			'thirty',
			'forty',
			'fifty',
			'sixty',
			'seventy',
			'eighty',
			'ninety'
		],
		
		specials : {
			'11' : 'eleven',
			'12' : 'twelve',
			'13' : 'thirteen',
			'14' : 'fourteen',
			'15' : 'fifteen',
			'16' : 'sixteen',
			'17' : 'seveteen',
			'18' : 'eighteen',
			'19' : 'nineteen'
		},
		
		placedSpecials : {
			'11' : 'eleventh',
			'12' : 'twelfth',
			'13' : 'thirteenth',
			'14' : 'fourteenth',
			'15' : 'fifteenth',
			'16' : 'sixteenth',
			'17' : 'seveteenth',
			'18' : 'eighteenth',
			'19' : 'nineteenth'
		},
		
		placedTens : [
			'',
			'tenth',
			'twentieth',
			'thirtieth',
			'fortieth',
			'fiftieth',
			'sixtieth',
			'seventieth',
			'eightieth',
			'ninetieth'
		]
		
	});
})( jQuery );
