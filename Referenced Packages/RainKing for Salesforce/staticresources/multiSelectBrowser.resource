(function($) {
	var options = {
		autoLoad: true,
		autoLoadTaxonomy: true,
		autoLoadItems: true,
		
		search: true,
		searchKey: "",
		searchTermKey: "term",
		searchPlaceholder: "Filter by name",
		searchSource: [],
		searchSourceMap: function(item) { return item; },
		searchSourceFilter: function(items) { return items; },
		
		taxonomy: true,
		taxonomyAllLabel: "Any Category",
		taxonomyKey: "",
		taxonomyTermKey: "categoryId",
		taxonomySource: [],
		taxonomySourceMap: function(item) { return item; },
		taxonomySourcePreFilter: function(items) { return items; },
		taxonomySourceFilter: function(items) { return items; },
		taxonomyDisplay: "dropdown",
		
		tabs: true,
		
		scrollIndex: 0,
		scrollBatchSize: 100,
		
		onAdd: null,
		onTaxonomyAdd: null,
		onTabChange: null,
		selected: []
	};
	var methods = {
		init: function(args) {
			return $(this).each(function() {
				var instanceArgs = $.extend({}, options, args);
				var $instance = $(this);
				
				$(this).data('multiSelectBrowserSelected', []);
				$(this).data('multiSelectBrowser', instanceArgs);
				
				if( instanceArgs.tabs ) {
					var that = this;
					var $tabs = $('<ul class="msbTabs"></ul>').appendTo(this);
					$.each( instanceArgs.tabs, function( i, tab ) {
						$('<li class="msbTab" data-tab-value="' + tab.value + '">' + tab.label + '</li>').appendTo( $tabs ).data( 'msbTabItem', tab );
					});
					
					$tabs.children().first().addClass("is-active");
					
					$tabs.on("click", ".msbTab", function( e ) {
						$(this).addClass("is-active").siblings().removeClass("is-active");
						
						var selectedTab = $(this).data('msbTabItem');
						
						var taxonomyItems = [];
						$instance.find(".msbTaxonomyWrap").each(function() {
							$(this).find(".msbTaxonomy").val("").trigger("change");
							taxonomyItems.push( $(this).data('msbTaxonomyItems') );
						});
						
						$instance.multiSelectBrowser('_populateTaxonomyItems', taxonomyItems );
						
						if( typeof instanceArgs.onTabChange == "function" ) {
							instanceArgs.onTabChange.call( that, selectedTab );
						}
					});
				}
				
				var $header = $('<header class="msbHeader">').appendTo(this);
				
				if(instanceArgs.search) {
					var $search = $('<input type="search" name="' + instanceArgs.searchKey + '" class="msbSearch" autocomplete="off" placeholder="' + instanceArgs.searchPlaceholder + '">').appendTo($header);
				}
				
				if(instanceArgs.taxonomy) {
					var $taxonomy;
					var $taxonomyWrap = $('<div class="msbTaxonomyWrap"></div>');
					
					var allLabel = instanceArgs.taxonomyAllLabel;
					if( $.isArray( allLabel ) ) {
						allLabel = allLabel[0];
					}
					
					switch( instanceArgs.taxonomyDisplay ) {
						case "dropdown" :
							$('<label>Filter by</label>').appendTo( $header );
							$taxonomyWrap = $taxonomyWrap.appendTo( $header );
							var taxonomyKey = ( $.isArray( instanceArgs.taxonomyKey ) ) ? instanceArgs.taxonomyKey[0] : instanceArgs.taxonomyKey;
							$taxonomy = $('<div class="msbTaxonomyInput"><select class="msbTaxonomy" name="' + taxonomyKey + '"><option value="">' + allLabel + '</option></select></div>').appendTo($taxonomyWrap);
							$('<div class="msbTaxonomyInput"><button type="button" class="btn btn-small msbTaxonomyButton" disabled>+ Add Category</button></div>').appendTo( $taxonomyWrap );
							break;
						
						case "column" :
							$taxonomyWrap = $taxonomyWrap.insertAfter( $header ).addClass("msbTaxonomyColumn");
							$taxonomy = $('<ul class="msbTaxonomy">'
								+ '<li>'
									+ '<input type="radio" id="' + instanceArgs.taxonomyKey + '--" name="' + instanceArgs.taxonomyKey + '" value="" checked>'
									+ '<label for="' + instanceArgs.taxonomyKey + '--">' + allLabel + '</label>'
								+ '</li>'
							+ '</ul>').appendTo($taxonomyWrap);
							break;
					}
				}
				
				var $results = $('<ul class="msbResults">').appendTo(this);
				var $footer = $('<footer class="msbFooter">').appendTo(this);
				
				$footer.append('<span class="msbSelectedCount"></span>');
				$footer.append('<button type="button" class="msbAddSelected btn btn-default btn-small" disabled>Add Selected</button>');
				$footer.append('<button type="button" class="msbAddAll btn btn-default btn-small is-visible" disabled>Add All</button>');
				
				
				if(instanceArgs.autoLoad) {
					if(instanceArgs.autoLoadTaxonomy) {
						if(instanceArgs.taxonomy) {
							$(this).multiSelectBrowser('loadTaxonomyItems');
						}
					}
					
					if(instanceArgs.autoLoadItems) {
						$(this).multiSelectBrowser('loadItems');
					}
				}
				
				$results.on("click", ".msbItem", function(e) {
					if(e.shiftKey || e.ctrlKey || e.metaKey) {
						if( (e.ctrlKey || e.metaKey)) {
							$(this).toggleClass("is-highlighted");
						} 
												
						if( e.shiftKey && $(this).siblings(".msbLastSelection").length ) {
							$(this).addClass("is-highlighted");
							
							var $lastSelection = $(this).siblings(".msbLastSelection");
							if($(this).index() > $lastSelection.index()) {
								$lastSelection.nextUntil(this).not(".is-selected").addClass("is-highlighted");
							} else {
								$(this).nextUntil($lastSelection).not(".is-selected").addClass("is-highlighted");
							}
						}
					} else {
						$(this).addClass("is-highlighted").siblings().removeClass("is-highlighted");
					}
					
					if($(this).hasClass("is-highlighted")) {
						$(this).addClass("msbLastSelection").siblings().removeClass("msbLastSelection");
					} else {
						$(this).removeClass("msbLastSelection").siblings().removeClass("msbLastSelection");
					}
					
					$(this).parents(".multiSelectBrowser").multiSelectBrowser("_refresh");
				});
				
				$results.on("selectstart mousedown", ".msbItem", false);
				
				$results.on("scroll", function(e) {
					if(this.scrollTop + $(this).outerHeight() >= this.scrollHeight - 100) {
						var $container = $(this).parent();
						var instanceArgs = $container.data('multiSelectBrowser');
						instanceArgs.scrollIndex++;
						
						$container.data('multiSelectBrowser', instanceArgs);
						$container.multiSelectBrowser('_populateItems', false);
					}
				});
				
				$results.on("click", ".msbItem:not(.is-highlighted) .msbItemButton, .msbItem:not(.is-highlighted) .msbItemLabel", function(e) {
					e.stopPropagation();
					var $item = $(this).parents(".msbItem");
					var callbackResponse = true;
					
					if(typeof instanceArgs.onAdd == "function") {
						callbackResponse = instanceArgs.onAdd.call( $instance, $item.data("multiSelectBrowserItem"), $item );
					}
					
					if(callbackResponse !== false) {
						$item.addClass("is-selected").removeClass("is-highlighted");
						$(this).parents(".multiSelectBrowser").multiSelectBrowser("_refresh");
					}
				});
				
				$footer.on("click", ".msbAddSelected", function(e) {
					var selectedItems = [];
					var $items = $results.children().filter(".is-highlighted");
					
					$items.each(function() {
						selectedItems.push( $(this).data("multiSelectBrowserItem") );
					});
						
					var callbackResponse = true;
					if(typeof instanceArgs.onAdd == "function") {
						callbackResponse = instanceArgs.onAdd.call( $instance, selectedItems );
					}
					
					if(callbackResponse !== false) {
						$items.removeClass("is-highlighted").addClass("is-selected");
					}
					
					$(this).parents(".multiSelectBrowser").multiSelectBrowser("_refresh");
				});
				
				$footer.on("click", ".msbAddAll", function(e) {
					var selectedItems = [];
					var $items = $results.children();
					
					$items.each(function() {
						selectedItems.push( $(this).data("multiSelectBrowserItem") );
					});

					var callbackResponse = true;
					if(typeof instanceArgs.onAdd == "function") {
						callbackResponse = instanceArgs.onAdd.call( $instance, selectedItems );
					}
					
					if(callbackResponse !== false) {
						$items.removeClass("is-highlighted").addClass("is-selected");
					}
					
					$(this).parents(".multiSelectBrowser").multiSelectBrowser("_refresh");
				});
				
				if(instanceArgs.search) {
					$(this).on("keydown", ".msbSearch", function(e) {
						if(e.which === 13) {
							e.stopPropagation();
							e.preventDefault();
							
							if(this.autocompleteTimeout) clearTimeout(this.autocompleteTimeout);
							
							$(e.delegateTarget).multiSelectBrowser('loadItems');
						} else {
							if(!e.metaKey && !e.ctrlKey) {
								if(this.autocompleteTimeout) clearTimeout(this.autocompleteTimeout);
								
								this.autocompleteTimeout = setTimeout(function() {
									$(e.delegateTarget).multiSelectBrowser('loadItems');
								}, 400);
							}
						}
					});
				}
				
				if( instanceArgs.search ) {
					var inputNames = $.map( [ instanceArgs.searchKey ], function( item ) { return item; } );
					inputNames = $.map( inputNames, function( name ) { return '[name="' + name + '"]'; });

					$(this).on("change", inputNames.join(', '), function(e) {
						$(e.delegateTarget).multiSelectBrowser('loadItems');
					});
				}
				
				if( instanceArgs.taxonomy ) {
					$(this).on("click", ".msbTaxonomyButton", function() {
						var selectedItem = $(this).parents(".msbTaxonomyInput").siblings().find("select").find("option:selected").data("msbTaxonomyItem");
						
						var wasAdded = true;
						if(typeof instanceArgs.onTaxonomyAdd == "function") {
							wasAdded = instanceArgs.onTaxonomyAdd.call( $instance, selectedItem );
						}
						
						if( wasAdded ) {
							$(this).attr("disabled", true);
						}
					});
				}

			});
		},
		loadTaxonomyItems: function() {
			var instanceArgs = $(this).data('multiSelectBrowser');
			var $this = $(this);
				
			var sourceQuery = $(this).multiSelectBrowser('_getSource', "taxonomy");
			if(sourceQuery && typeof sourceQuery.promise != "undefined")
			{
				sourceQuery.done(function(items) {
					var instanceArgs = $(this).data('multiSelectBrowser'); // Promise loses $this context
					items = instanceArgs.taxonomySourcePreFilter.call( this, items );
					
					if( ! $.isArray( items[ 0 ] ) ) {
						items = [ items ];
					}
					
					$.each( items, function( i ) {
						items[ i ] = $.map(items[ i ], instanceArgs.taxonomySourceMap);
						items[ i ] = instanceArgs.taxonomySourceFilter.call( this, items[ i ] );
					});
					
					$(this).multiSelectBrowser('_populateTaxonomyItems', items);
				});
			}
			else
			{
				var items = sourceQuery;

				if( ! $.isArray( items[ 0 ] ) ) {
					items = [ items ];
				}
				
				$.each( items, function( i ) {
					items[ i ] = $.map(items[ i ], instanceArgs.taxonomySourceMap);
					items[ i ] = instanceArgs.taxonomySourceFilter.call( this, items[ i ] );
				});
				
				$(this).multiSelectBrowser('_populateTaxonomyItems', items);
			}
		},
		loadItems: function() {
			var instanceArgs = $(this).data('multiSelectBrowser');
			var $this = $(this);
			
			var searchData = {};
			searchData[instanceArgs.searchTermKey] = (instanceArgs.search) ? $(this).find("[name='" + instanceArgs.searchKey + "']").val().trim() : "";
			
			var taxonomyValue = null;
			switch(instanceArgs.taxonomyDisplay) {
				case "dropdown" :
					if( $.isArray( instanceArgs.taxonomyTermKey ) ) {
						$(this).find(".msbTaxonomy").each(function( i ) {
							searchData[ instanceArgs.taxonomyTermKey[ i ] ] = $(this).val();
						});
					} else {
						$(this).find("[name='" + instanceArgs.taxonomyKey + "']").each(function() {
							if( $(this).val() ) {
								taxonomyValue = $(this).val();
							}
						});
						searchData[instanceArgs.taxonomyTermKey] = taxonomyValue;
					}
					break;
					
				case "column" :
					taxonomyValue = $(this).find("[name='" + instanceArgs.taxonomyKey + "']:checked").val();
					searchData[instanceArgs.taxonomyTermKey] = taxonomyValue;
					break;
			}
			
			if( instanceArgs.tabs ) {
				var tabValue = $(this).find(".msbTab.is-active").attr("data-tab-value");
				searchData[ instanceArgs.tabKey ] = tabValue;
			}
						
			var lastSearchData = $(this).data('lastSearchData');
			
			//if( ! lastSearchData || JSON.stringify( lastSearchData ) !== JSON.stringify( searchData ) ) {
					
				$this.multiSelectBrowser('resetScrollIndex');
				
				var sourceQuery = $(this).multiSelectBrowser('_getSource', "search", searchData);
				if(sourceQuery && sourceQuery.promise)
				{
					sourceQuery.done(function(items) {
						var $this = $(this); // Promise loses context
						var instanceArgs = $this.data('multiSelectBrowser');
						
						$this.data('totalResults', items.length);
						$this.removeClass("is-loading");
						var items;
						items = $.map(items, instanceArgs.searchSourceMap);
						items = instanceArgs.searchSourceFilter.call( this, items );
						$this.data('multiSelectBrowserItems', items);
						$this.multiSelectBrowser('_populateItems');
				
						$this.multiSelectBrowser('_refresh');
					});
				}
				else
				{
					$this.removeClass("is-loading");
					$this.data('totalResults', sourceQuery.length);
					var items;
					items = $.map(sourceQuery, instanceArgs.searchSourceMap);
					items = instanceArgs.searchSourceFilter.call( this, items );
					$this.data('multiSelectBrowserItems', items);
					$this.multiSelectBrowser('_populateItems');
				
					$this.multiSelectBrowser('_refresh');
				}
				
				$this.data('lastSearchData', searchData);
			//}
		},
		resetScrollIndex: function() {
			var instanceArgs = $(this).data('multiSelectBrowser');
			instanceArgs.scrollIndex = 0;
			$(this).data('multiSelectBrowser', instanceArgs);
		},
		_getScrollItems: function(items) {
			var instanceArgs = $(this).data('multiSelectBrowser');

			var start = Math.min(instanceArgs.scrollIndex * instanceArgs.scrollBatchSize, items.length);
			var end = Math.min(start + instanceArgs.scrollBatchSize, items.length);
			
			items = items.slice(start, end);
			
			
			return items;
		},
		_getSource: function(type, sourceData) {
			var instanceArgs = $(this).data('multiSelectBrowser');
			var sourceKey = type + "Source";
			
			var $this = $(this);
			$this.addClass("is-loading");
			
			var existingRequest = $(this).data('multiSelectBrowser' + sourceKey + 'Request');
			if(existingRequest && typeof existingRequest.reject !== "undefined") {
				existingRequest.reject();
			}
			
			if(typeof instanceArgs[sourceKey] !== "object")
			{
				var source = $.Deferred();
				
				Visualforce.remoting.Manager.invokeAction( instanceArgs[sourceKey], ( sourceData || {} ), $.proxy( function( response, event ) {
					if( event.status ) {
						if( ! response ) {
							response = { data: [] };
						} else {
							if( typeof response == "string" ) {
								response = $.parseJSON( response );
							}
						}
						
						source.resolveWith( this, [ response.data ] );
					} else {
						source.reject( event.message );
					}
				}, this ), {
					escape: false
				});
			}
			else
			{
				source = instanceArgs[sourceKey];
			}

			$(this).data('multiSelectBrowser' + sourceKey + 'Request', source);
			
			return source;
		},
		_populateTaxonomyItems: function(items) {
			var instanceArgs = $(this).data('multiSelectBrowser');
			var $instance = $(this);
			var $taxonomyWrap = $(this).find(".msbTaxonomyWrap");
						
			if( instanceArgs.taxonomyDisplay == "dropdown" && items.length > 1 && $taxonomyWrap.length !== items.length ) {
				var $newTaxonomy = $taxonomyWrap.clone().insertAfter( $taxonomyWrap );
				$taxonomyWrap = $(this).find(".msbTaxonomyWrap");
				
				if( $.isArray( instanceArgs.taxonomyAllLabel ) ) {
					$newTaxonomy.find(".msbTaxonomy option:first").text( instanceArgs.taxonomyAllLabel[1] );
				}
				
				if( $.isArray( instanceArgs.taxonomyKey ) ) {
					$newTaxonomy.attr( "name", instanceArgs.taxonomyKey[ 1 ] );
				}
				
				$newTaxonomy.find("button").text("+ Add Subcategory");
			} 
			
			$taxonomyWrap.each(function( i ) {
				var filteredItems = items[ i ];
				if( instanceArgs.tabs ) {
					var selectedTab = $instance.find(".msbTab.is-active").data('msbTabItem');
					if( selectedTab ) {
						filteredItems = $.grep( filteredItems, function( item ) {
							return item[ instanceArgs.tabKey ] == selectedTab.value;
						});
					}
				}
				
				$(this).data( "msbTaxonomyItems", items[ i ] );
				$instance.multiSelectBrowser( "_populateTaxonomyItemInputs", $(this), filteredItems );
			});
			
			var taxonomyKeys = instanceArgs.taxonomyKey;			
			var taxonomyKeySelector = $.map( [ taxonomyKeys ], function( name ) { return '[name="' + name + '"]'; } );
			
			$(this).on("change", taxonomyKeySelector.join(", "), function( e ) {
				if( instanceArgs.taxonomyDisplay == "dropdown") {
					var selectedItem = $(this).find("option:selected").data( "msbTaxonomyItem" );
					
					if( typeof selectedItem !== "undefined" ) {
						if( selectedItem.parent ) {
							$taxonomyWrap.find("[value='" + selectedItem.parent + "']").attr("selected", true).parents(".msbTaxonomyInput").prevAll(".msbTaxonomyInput").find("button").prop("disabled", false);
						} else {
							$taxonomyWrap.not( $(this).parents( ".msbTaxonomyWrap" ) ).each(function() {
								items = $(this).data( "msbTaxonomyItems" );
								
								var filteredItems = $.grep( items, function( item ) {
									return item.parent == selectedItem.value;
								});
								
								$(this).find("select").attr( "disabled", ( filteredItems.length === 0) );
								
								$instance.multiSelectBrowser( "_populateTaxonomyItemInputs", $(this), filteredItems, true );
							});
						}
					} else {
						if( $(this).parents(".msbTaxonomyWrap").prevAll(".msbTaxonomyWrap").length === 0 ) {
							$taxonomyWrap.not( $(this).parents( ".msbTaxonomyWrap" ) ).each(function( i ) {
								var filteredItems = $(this).data('msbTaxonomyItems');
		
								if( instanceArgs.tabs ) {
									var selectedTab = $instance.find(".msbTab.is-active").data('msbTabItem');
									if( selectedTab ) {
										filteredItems = $.grep( filteredItems, function( item ) {
											return item[ instanceArgs.tabKey ] == selectedTab.value;
										});
									}
								}
								
								$instance.multiSelectBrowser( "_populateTaxonomyItemInputs", $(this), filteredItems );
							});
						}
						$(this).parents(".msbTaxonomyWrap").find(".msbTaxonomyInput button").prop("disabled", true);
					}
					
					$(this).parents(".msbTaxonomyWrap").siblings(".msbTaxonomyWrap").addBack().each(function( i ) {
						var taxonomyValue = $(this).find("select").val();
						var isDisabled = ! taxonomyValue.length;
						var selectedTaxonomies = $(e.delegateTarget).multiSelectBrowser('_getTaxonomySelected', i );
						
						if( selectedTaxonomies ) {
							var selectedValues = $.grep( selectedTaxonomies, function( item ) {
								return item.value == taxonomyValue;
							});
							
							if( selectedValues.length ) {
								isDisabled = true;
							}
						}
						
						$(this).find(".msbTaxonomyInput button").prop("disabled", isDisabled);
					});
				}

				$(e.delegateTarget).multiSelectBrowser('loadItems');
			});
		},
		_populateTaxonomyItemInputs: function( $taxonomyWrap, items ) {
			var instanceArgs = $(this).data('multiSelectBrowser');
			var $taxonomy = $taxonomyWrap.find(".msbTaxonomy");
			
			$taxonomy.children().not(":first").detach();
			
			$.each(items, function(i, item) {
				var $item;
				switch( instanceArgs.taxonomyDisplay ) {
					case "dropdown" :
						$item = $('<option value="' + item.value + '">' + item.label + '</option>');
						break;
					
					case "column" :
						$item = $('<li>'
							+ '<input type="radio" id="' + instanceArgs.taxonomyKey + '-' + item.value + '" name="' + instanceArgs.taxonomyKey + '" value="' + item.value + '">'
							+ '<label for="' + instanceArgs.taxonomyKey + '-' + item.value + '">' + item.label + '</label>'
						+ '</li>');
						break;
				}
				
				$item.appendTo( $taxonomy ).data( "msbTaxonomyItem", item );
			});
		},
		_populateItems: function(reset) {
			var instanceArgs = $(this).data('multiSelectBrowser');
			
			var $results = $(this).find(".msbResults");
			if(typeof reset === "undefined" || reset) $results.scrollTop(0).html("");
			
			var items = $(this).data('multiSelectBrowserItems') || [];
			items = $(this).multiSelectBrowser('_getScrollItems', items);
			
			var selected = $(this).multiSelectBrowser('_getSelected');
			var selectedValues = $.map($.makeArray(selected), function(item) { return item.value; });
			
			$.each(items, function(i, item) {
				
				if(typeof item.value == "object") item.value.sort();
				
				var $result = $(''
					+ '<li class="msbItem" data-item-value="' + item.value.toString() + '">'
						+ '<span class="msbItemLabel">' + item.label + '</span>'
						+ '<button type="button" class="msbItemButton">Add</button>'
					+ '</li>').appendTo($results);
				
				var isSelected = false;
				$.each($.makeArray(item.value), function(i, value) {
					if($.inArray(value, selectedValues) >= 0) isSelected = true;
				});
				
				if(isSelected) {
					$result.addClass("is-selected");
				}
				
				$result.data('multiSelectBrowserItem', item);
			});
		},
		_refresh: function() {
			var $results = $(this).find(".msbResults");
			var $footer = $(this).find(".msbFooter");
			
			var $selected = $results.children().filter(".is-highlighted");
			
			$footer.find(".msbAddAll").toggleClass("is-visible", ($selected.length === 0 && parseFloat($(this).data('totalResults')) <= 100)).prop("disabled", ($results.children().not(".is-selected").length === 0));
			$footer.find(".msbSelectedCount").toggleClass('is-visible', ($selected.length > 0)).html($selected.length);
			$footer.find(".msbAddSelected").toggleClass("is-visible", ($selected.length > 0)).prop("disabled", ($results.children().length === 0));

		},
		_getSelected: function() {
			var instanceArgs = $(this).data('multiSelectBrowser');
			
			return (typeof instanceArgs.selected == "function") ? instanceArgs.selected.call( this ) : instanceArgs.selected;
		},
		_getTaxonomySelected: function( taxonomyIndex ) {
			var instanceArgs = $(this).data('multiSelectBrowser');
			
			if( typeof taxonomyIndex == "undefined" ) {
				taxonomyIndex = 0;
			}
			
			if( typeof instanceArgs.taxonomySelected !== "function" && ! $.isArray( instanceArgs.taxonomySelected ) ) {
				instanceArgs.taxonomySelected = [ instanceArgs.taxonomySelected ];
			}
			
			return (typeof instanceArgs.taxonomySelected == "function") ? instanceArgs.taxonomySelected.call( this, taxonomyIndex ) : instanceArgs.taxonomySelected[ taxonomyIndex ];
		}
	};
	
	$.fn.multiSelectBrowser = function(method) {
		if(methods[method]) {
			return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
		} else if(typeof method === 'object' || !method) {
			return methods.init.apply(this, arguments);
		} else {
			$.error('Method ' + method + ' does not exist');
		}
	};
}( jQuery ));