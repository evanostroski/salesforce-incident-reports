(function($) {
	var options = {

	};
	var methods = {
		init: function(args) {
			
			return $(this).each(function() {
				var instanceArgs = $.extend({}, options, args);
				var $this = $(this);
				var $tags = $("#" + $(this).data('searchTags'));
				var $inputs = $(this).find("input");
				var $buttons = $(this).find("button");
				
				$this.data('$tags', $tags);
				$this.data('$inputs', $inputs);
				$this.data('$buttons', $buttons);
				
				$inputs.on("keydown", function(e) {
					if(e.which == 13)
					{
						e.preventDefault();
						e.stopPropagation();
						
						$this.searchTagsAdder('add');
						
						return false;
					}
				});
				
				$buttons.on("click", function(e) {
					e.preventDefault();
					
					$this.searchTagsAdder('add');
				});
			});
		},
		add: function(toAdd) {
			var values = [];
			var $this = $(this);
            var $inputName = $(this).data('searchTags')
            var flag=0;
			$this.data('$inputs').each(function() {
                if($(this).val() != '') {
                    var val = $(this).val();
                    var csv = val.split(',');

                    $.each(csv, function (i, item) {
					item = item.trim(); // Trim whitespace
					item = item.replace(/[\u2018\u2019\u201A]/g, "'"); // Smart apostrophes
					item = item.replace(/[\u201C\u201D\u201E]/g, '"'); // Smart quotes
					item = item.replace(/\u2026/g, "..."); // Ellipses
					item = item.replace(/[\u2013\u2014]/g, "-"); // Dashes
					item = item.replace(/[\u02DC\u00A0]/g, " "); // Weird spaces

					item.replace(/^['" ]/g, ""); // Leading quotes & spaces
					item.replace(/['" ]$/g, ""); // Trailing quotes & spaces

                        if (item) values.push(item);
                    });
                }

                        $this.data('$inputs').one("keydown blur", function () {
                            $(".error.invalid-value").hide();
			            });

			});
			
			if($this.data('$inputs').filter(".js-range-end:visible").length && values.length == 2) {
                $.each(values, function(i, value) {
                    if (value.replace(/\D/g,'').length > 12) {
                        $(".error.invalid-value").remove();
                        var validateErrorText = "Each zip code value should not exceed 12 digits"
                        $('<div class="error invalid-value">' + validateErrorText + '</div>').appendTo($this);
                        return
                    }
                });
                if($('.error.invalid-value').is(':visible')) {
                    return
                }else {
                    flag=1;
                    values = [values.sort().join('-')];
                }
			} 

			var notAdded = [];
            var invalidValue=[];
			$.each(values, function(i, value) {

                if($inputName == "zipTagsUS"){
                    if(value.replace(/\D/g,'').length < 13 || flag==1) {
                        var itemAdded = $this.data('$tags').searchTags('add', {label: value, countryId: 1, value: value});
                        if (itemAdded === false) {
                            notAdded.push({type: "invalid", value: value});
                        } else if (itemAdded.length) {
                            notAdded.push({type: "duplicate", value: value});
                        }
                    }
                    else{
                        invalidValue.push(value)
                        $(".error.invalid-value").remove();
                        var validateErrorText = "Each zip code value should not exceed 12 digits"
                        $('<div class="error invalid-value">' + validateErrorText + '</div>').appendTo($this);
                    }
                }
                else if($inputName == "zipTagsCanadaEurope"){
                    if(value.length < 13) {
                        var itemAdded = $this.data('$tags').searchTags('add', {label: value, value: value});
                        if (itemAdded === false) {
                            notAdded.push({type: "invalid", value: value});
                        } else if (itemAdded.length) {
                            notAdded.push({type: "duplicate", value: value});
                        }
                    }
                    else{
                        invalidValue.push(value)
                        $(".error.invalid-value").remove();
                        var validateErrorText = "Each postal code value should not exceed 12 characters"
                        $('<div class="error invalid-value">' + validateErrorText + '</div>').appendTo($this);
                    }
                }
                else if($inputName == "areaCodeUSCanadaTags" || $inputName == "areaCodeTags"){
                    if(value.replace(/\D/g,'').length < 101) {
                        var itemAdded = $this.data('$tags').searchTags('add', {label: value, value: value});
                        if (itemAdded === false) {
                            notAdded.push({type: "invalid", value: value});
                        } else if (itemAdded.length) {
                            notAdded.push({type: "duplicate", value: value});
                        }
                    }
                    else{
                        invalidValue.push(value)
                        $(".error.invalid-value").remove();
                        var validateErrorText = "Each area code value should not exceed 100 digits"
                        $('<div class="error invalid-value">' + validateErrorText + '</div>').appendTo($this);
                    }
                }
                else {
                    if (value.length < 513) {
                        var itemAdded = $this.data('$tags').searchTags('add', {label: value, value: value});
                        if (itemAdded === false) {
                            notAdded.push({type: "invalid", value: value});
                        } else if (itemAdded.length) {
                            notAdded.push({type: "duplicate", value: value});
                        }
                    }
                    else {
                        invalidValue.push(value)
                        $(".error.invalid-value").remove();
                        var validateErrorText = "Only 512 characters are allowed"
                        $('<div class="error invalid-value">' + validateErrorText + '</div>').appendTo($this);
                    }
               }
			});

			if( ! notAdded.length ) {
				$this.data('$inputs').val("");
			} else {
				var invalidItems = $.grep(notAdded, function(item) { return item.type == "invalid" });
				var duplicateItems = $.grep(notAdded, function(item) { return item.type == "duplicate" });
				
				var errorText = "Error";
				
				if(invalidItems.length === 0) {
					var errorItemText = ((duplicateItems.length == values.length) ? "all" : duplicateItems.length) + " of these items";
					if(duplicateItems.length === 1) {
						errorItemText = duplicateItems[0].value;
					} 
					errorText = "You’ve already added " + errorItemText;
				} else {
					if(duplicateItems.length === 0) {
						if(invalidItems.length === 1) {
                            var value = invalidItems[0].value.replace("<script>", "");
							errorText = value + " is not allowed";
						} else {
							errorText = invalidItems.length + " items are not allowed";
						}
					} else {
						errorText = invalidItems.length + " not allowed, " + duplicateItems.length + " duplicate" + (duplicateItems.length === 1 ? "" : "s");
					}
				}
				
				$this.find(".error").detach();
				var $error = $('<div class="error duplicate-item">' + errorText + '</div>').hide().appendTo($this).fadeIn(200);
				$this.data('$inputs').first().one("keydown blur", function() {
					$error.detach();
				});
			}
            if($('.error.invalid-value').is(':visible')) {
                $this.data('$inputs').first().val(invalidValue)
            }
		},
		option: function(args) {
			var instanceArgs = $(this).data('searchTags');
			$(this).data('searchTags', $.extend({}, instanceArgs, args));
		}
	};
	
	$.fn.searchTagsAdder = function(method) {
		if(methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if(typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist');
		}
	};
}(jQuery));