(function($) {
	var options = {
		inputName: null,
		tagLabel: null,
        itemFilter: /^([a-z]|\d|\s|-|\.|_|&|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+$/i,
		
		relationships: [],
		conflictMessage: "Warning: Your {tagLabel} selection will replace your existing {conflictTagLabel} that is already selected. If you continue, your {conflictTagLabel} selection will be removed.",
		
		selected: [],
		
		onAdd: null,
		onBeforeRemove: null,
		onRemove: null
	};
	var methods = {
		init: function(args) {
			
			return $(this).each(function() {
				var instanceArgs = $.extend({}, options, args);
				$(this).data('searchTags', instanceArgs);
				$(this).data('searchTagsSelection', []);
				var $this = $(this);
				
				// Add heading, if applicable
				var heading = $(this).attr("data-search-tags-heading");
				if(heading) {
					$('<h3 class="searchTagsHeading">' + heading + ' <a href="javascript:void(0);" class="mini-link clearSearchTagsSection">Clear Selected</a></h3>')
						.hide()
						.insertBefore(this)
						.on("click", ".clearSearchTagsSection", function(e) {
							e.preventDefault();
							$this.searchTags('removeAll');
						});
				}
				
				// Add selected
				if(instanceArgs.selected.length) {
					$.each(instanceArgs.selected, function(i, item) {
                        //VE-11589 - toAdd value is being encoded to resolve delete problem.
                        var $item = $('<li>').attr("data-item-value", item.value); /* HERE */
                        if( instanceArgs.inputName == "industryIds")
                            $item = $('<li>').attr("data-item-value", item.value);

                        $('<span class="criteriaSelectionTagLabel">').text(item.label).appendTo($item);
						$item.append('<button type="button" class="criteriaSelectionRemove">&times;</button>');
						
						var values = (typeof item.value == "object") ? item.value : [ item.value ];
						$.each(values, function(i, value) {
		                    $item.append('<input type="hidden" name="' + instanceArgs.inputName + '" value="' + value + '">');
						});
		
						$item.data('searchTagsItem', item).appendTo($this);
					});
					
					$this.data('searchTagsSelection', instanceArgs.selected);
				}

				
				$(this).on("click", ".criteriaSelectionRemove", function(e) {
					$(e.delegateTarget).searchTags('remove', $(this).parent().data('itemValue'));
				});
			});
		},
		add: function(toAdd) {
			var $this = $(this);
			var instanceArgs = $(this).data('searchTags');
			var selected = $(this).data('searchTagsSelection');
			
			if( ! $.isArray(toAdd) ) {
				toAdd = [ toAdd ];
			}
			
			var conflictResolution = null;
			
			var didAdd = false;
			
			// Check for conflicts first
			if( instanceArgs.relationships.length ) {
				$.each(toAdd, function(i, toAdd) {
					for(var i = 0; i < instanceArgs.relationships.length; i++) {
						var relationship = instanceArgs.relationships[i];
						var $relationshipTags = $(relationship.selector);
						var relationshipInstanceArgs = $relationshipTags.data('searchTags');
						var relationshipTags = $.grep($relationshipTags.data('searchTagsSelection'), function(item, i) {
							
							var toAddKey = (relationship.type == "child") ? "value" : relationship.key;
							var itemKey = (relationship.type == "parent") ? "value" : relationship.key;
							
							return item[itemKey] == toAdd[toAddKey];
						});
						
						if(relationshipTags.length) {
							var removeCriteria = conflictResolution;
							if(removeCriteria === null) {
								var conflictMessage = ( $.isArray( instanceArgs.conflictMessage ) ) ? instanceArgs.conflictMessage[ i ] : instanceArgs.conflictMessage;
								
								// Tagging
								var conflictMessageReplacements = {
									"{tagLabel}" : instanceArgs.tagLabel,
									"{itemName}" : toAdd.label,
									"{conflictTagLabel}" : relationshipInstanceArgs.tagLabel,
									"{conflictItemName}" : (relationshipTags.length == 1) ? relationshipTags[0].label : relationshipTags.length + " items"
								};
								
								$.each( conflictMessageReplacements, function( tag, replacement ) {
									var replaceRegEx = new RegExp( tag, 'g' );
									conflictMessage = conflictMessage.replace( replaceRegEx, replacement );
								});
																
								removeCriteria = confirm( conflictMessage );
							}
							
							conflictResolution = removeCriteria;
	
							if(removeCriteria) {
								$.each(relationshipTags, function(index, item) {
									$relationshipTags.searchTags('remove', item.value);
								});
							} else {
	                            return true;
							}
						}
					}
				});
				
				if(conflictResolution === false) {
					return false;
				}
			}
			
			$.each(toAdd, function(i, toAdd) {

				if( typeof instanceArgs.addItemFilter !== "undefined" ) {
		            if( typeof instanceArgs.addItemFilter == "function" ) {
		                toAdd = instanceArgs.addItemFilter(toAdd);
		            } 
		            
		            if( instanceArgs.addItemFilter instanceof RegExp ) {
			            toAdd.label = toAdd.label.replace(instanceArgs.addItemFilter, "");
			            toAdd.value = toAdd.value.replace(instanceArgs.addItemFilter, "");
		            } 
		        }
	
	            if ( typeof toAdd.value == 'string' ){
	                toAdd.label = toAdd.label.replace(/[\\"]/gi, "");
	                toAdd.value = toAdd.value.replace(/[\\"]/gi, "");
	            }
	
	            if( toAdd.value != null && toAdd.value != undefined && typeof toAdd.value == 'string' && toAdd.value.trim().length == 0 ) // prevent adding blank strings
	                return false;

                //VE-11504 - XSS vulnerability on Tags. Restrict the javascript injection.
                if(isNotAlphaNum(toAdd.value))
                    return false;

				var selectedItems = $.grep(selected, function(selectedItem) { 
					if(typeof selectedItem.value == "object") {
						if(typeof toAdd.value == "object") {
							return $(toAdd.value).not(selectedItem.value).length == 0 && $(selectedItem.value).not(toAdd.value).length == 0;
						} else {
							return $.inArray(toAdd.value, selectedItem.value) >= 0;
						}
					} else {
						return selectedItem.label.toLowerCase() == toAdd.label.toLowerCase();
					}
				});

				if(selectedItems.length === 0)
				{
					var shouldAdd = true;

                    //VE-11589 - toAdd value is being encoded to resolve delete problem.
                    var $item = $('<li>').attr("data-item-value", toAdd.value); /* HERE */
                    if( instanceArgs.inputName == "industryIds")
                        $item = $('<li>').attr("data-item-value", toAdd.value);

					$('<span class="criteriaSelectionTagLabel">').text(toAdd.label).appendTo($item);
					$item.append('<button type="button" class="criteriaSelectionRemove">&times;</button>');
					
					var values = (typeof toAdd.value == "object") ? toAdd.value : [ toAdd.value ];
					$.each(values, function(i, value) {
	                    $item.append('<input type="hidden" name="' + instanceArgs.inputName + '" value="' + value + '">');
					});
	
					$item.data('searchTagsItem', toAdd).addClass("in-flux").appendTo($this);
					
					selected.push(toAdd);
					$(this).data('searchTagsSelection', selected);
					
					var addComplete = true
					if(typeof instanceArgs.onAdd == "function") addComplete = instanceArgs.onAdd(toAdd, $item);
					
					$.when(addComplete).then(function() {
						$item.removeClass("in-flux");
					});
					
					didAdd = true;

                    var items = $this.find('li').get();
                    items.sort(function(a,b){
                        var keyA = $(a).text();
                        var keyB = $(b).text();

                        if (keyA < keyB) return -1;
                        if (keyA > keyB) return 1;
                        return 0;
                    });
                    $.each(items, function(i, li){
                        $this.append(li);
                    });

				} else {
					$.each(selectedItems, function(i, item) {
						var $tag = $this.find("[data-item-value='" + item.value + "']");
	
						if($tag.data('highlightTimeout')) clearTimeout($tag.data('highlightTimeout'));
						$tag.addClass("selected-highlight");
	
						$tag.data('highlightTimeout', setTimeout(function() {
							$tag.removeClass("selected-highlight");
						}, 200));
					});
					
					didAdd = selectedItems;
				}
				if(selected.length) $this.prev("h3").show();
			});
			
			return didAdd;
		},
		remove: function(value) {
			var $instance = $(this);
			var instanceArgs = $(this).data('searchTags');
			var selected = $(this).data('searchTagsSelection');
			var $item = $(this).find("[data-item-value='" + value + "']");
			var toRemove = $item.data('searchTagsItem');

			var shouldRemove = true;
			if( $item.length ) {
				if(typeof instanceArgs.onBeforeRemove == "function") shouldRemove = instanceArgs.onBeforeRemove(toRemove, $item);
				
				$item.addClass("in-flux");

				$.when(shouldRemove).then(function() {
					$item.detach();
                    //value = decodeURIComponent(value);
					selected = $.grep(selected, function(selectedItem) { return !(selectedItem.value == value) });

					$instance.data('searchTagsSelection', selected);
					
					if(selected.length === 0) $instance.prev("h3").hide();
					
					if(typeof instanceArgs.onRemove == "function") instanceArgs.onRemove(toRemove);
				}, function() {
					$item.removeClass("in-flux");
					
					alert("Tag could not be deleted");
				});
			}
		},
		removeAll: function() {
			var $this = $(this);
			var instanceArgs = $(this).data('searchTags');
			var selected = $(this).data('searchTagsSelection');
			
			if(selected.length)
			{
				$.each(selected, function(i, value) {
					$this.searchTags('remove', value.value);
				});
			}
		},
		option: function(args) {
			var instanceArgs = $(this).data('searchTags');
			$(this).data('searchTags', $.extend({}, instanceArgs, args));
		}
	};
	
	$.fn.searchTags = function(method) {
		if(methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if(typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist');
		}
	};

    function isNotAlphaNum( itemValue ) {
        var regEx  = /[|<>[\]{}$]/;
        var result = regEx.test(itemValue);
        return result;
    }
}(jQuery));