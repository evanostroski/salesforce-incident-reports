body {
	background:#ffffff; 
	color:#385F81; 
	font-size:13px; 
	font-family: arial, sans-serif;
}   	

.spinner {
	display:none;
}
.spinner2 {
	display:none;
}
/* Fade In Div
---------------------------------------------------- */
.fadeIn {
	clear:both;
	margin:1px;
	opacity:0;
	-webkit-animation:fadeIn ease-in 1;
	-moz-animation:fadeIn ease-in 1;
	animation:fadeIn ease-in 1;
	-webkit-animation-fill-mode:forwards;
	-moz-animation-fill-mode:forwards;
	animation-fill-mode:forwards;
}
.fadeIn-1s {
	-webkit-animation-duration:1s;
	-moz-animation-duration:1s;
	animation-duration:1s;
}
.fadeIn-Delay-2s {
	-webkit-animation-delay:1s;
	-moz-animation-delay:1s;
	animation-delay:1s;
}
/* Key Frames
---------------------------------------------------- */
@-webkit-keyframes fadeIn { 
	from {opacity:0;} 
	to {opacity:1; } 
}
@-moz-keyframes fadeIn { 
	from { opacity:0; } 
	to { opacity:1; } 
}
@keyframes fadeIn { 
	from { opacity:0; } 
	to { opacity:1; } 
}

.rich-tab-header { 
	width:170px; 
	font-size:14px; 
} 
.rich-tabpanel-content-position {border-bottom: 4px solid #2D4780;}
.rich-tab-bottom-line{ padding-left: 35px;border-bottom: 4px solid #2D4780;}
.pbBody td .rich-tab-active {
	background: #2D4780;
	background: -moz-linear-gradient(90deg, #4567AE 30%, #2D4780 70%) repeat scroll 0 0 transparent;
	background: -webkit-linear-gradient(90deg, #4567AE 30%, #2D4780 70%);
	background: -o-linear-gradient(90deg, #4567AE 30%, #2D4780 70%);
	background: -ms-linear-gradient(90deg, #4567AE 30%, #2D4780 70%);
	background: linear-gradient(180deg, #4567AE 30%, #2D4780 70%);
	border: 0 none;
	color: #FFFFFF;
	font-size: 13px;
	font-weight: bold;
	height: 25px;
	margin-left:20px;
}
.rich-tabhdr-side-cell{
	border: 0;
}
.rich-tabhdr-side-border {
	background: none repeat scroll 0 0 transparent;
	border: 0 none;
	padding-left: 1px;
}
.pbBody td .inactiveTab { 
	background-color: #EAEBEC;
	background-image: none;
	color: #0F5BEA;
	font-size: 14px;
	text-decoration: underline;
	width: 170px;
	margin-left:20px;
}
.logo {left: 22px;position: absolute;top: 25px;z-index: 5000;}
.rich-tabpanel-content {
	background-color: #EAEBEC;
	border: 0 none;
}
.pbBody td .rich-tab-active, .pbBody td .inactiveTab   {
    vertical-align: middle;
}

.columnTypeIconLabel {
	color: #839ab4;
	display: block;
	font-size: 11px;
	line-height: 1;
	margin: 5px 0 0;
}
/*******************
 * RK Admin Styles *
 *******************/
		#map-ct {
		    float:left; 
		    width: 100%;
		    overflow: auto;
		    white-space: nowrap;
		    padding-left: 8px;
		} 
		.cell {
		    display: inline-block;
		    height: 100%;
		}
		.rk-form {
			background-color: #ffffff;
		    border: 1px solid #cccccc;
		    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) inset;
		    transition: border 0.2s linear 0s, box-shadow 0.2s linear 0s;
		    padding: 5px;	
		}
		.rk-form:focus {
		    border-color: rgba(82, 168, 236, 0.8);
		    box-shadow: 0 1px 1px rgba(0, 0, 0, 0.075) 
		    	inset, 0 0 8px rgba(82,168,236,0.6);
		    outline: 0 none;
		}
		table#map-table {
			width: 700px;
		}
		table#map-table td {
		    border-top: 0.1em solid #c5ced9; 
		    height: 38px;
		    vertical-align: middle;
		}
		table#map-table th {
		    border-bottom: 0.2em solid #c5ced9;
		    color: #4370a2;
		    font-size: 1.1em;
		    font-weight: bold;
		    padding: 0 0.5em 0.3em;
		    text-align: left;
		    text-transform: uppercase;
		}
		table#map-table th.thSub {
		    font-size: .8em;
		    border-bottom: 0 solid #c5ced9;
		    text-align: center;
		}
		.tableSubHeader {
		    background-color: #416084;
		    color: #C5CECE;
		    font-weight: bold;
		    height: 20px;
		    font-size: 1.1em;
		    vertical-align: middle;
		    padding-left: 5px;
		    padding-top: 5px;
		}
		h3 {
		    color: #304762;
		    font-size: 1.2em;
		    font-weight: bold;
		}
		.header-text {
			margin-top: 5px;
			margin-bottom: 10px;
		}
		.advanced-options-country,.advanced-options-leadsource {
			display: none;
		}
		.advanced-options-dialog {

			background-color:#f5f5f5;
			padding: 10px 10px 10px 10px;
		}
		.leadsource-input {
			width: 300px;
			margin-top: 5px;
		}
		.btn-warning {
			color: #ffffff;
			background-color: #f89406;
		}
		#validationErrs {
			display:none;
			background-color: #ffa8aa;
    		border: 1px solid #558d16;
    		padding: 10px;
    		margin-left: 20px;
    		-webkit-box-shadow: 0 0 0.7em rgba(0,0,0,0.3);
			-moz-box-shadow: 0 0 0.7em rgba(0,0,0,0.3);
			box-shadow: 0 0 0.7em rgba(0, 0, 0, 0.3);
			white-space: normal;
		}
		
		#successMsg {
			display:none;
			background-color: #ADFFAD;
    		border: 1px solid #558d16;
    		padding: 10px;
    		margin-left: 20px;
    		-webkit-box-shadow: 0 0 0.7em rgba(0,0,0,0.3);
			-moz-box-shadow: 0 0 0.7em rgba(0,0,0,0.3);
			box-shadow: 0 0 0.7em rgba(0, 0, 0, 0.3);
			white-space: normal;
		}
		
		#saveMsg {
			display:none;
			background-color: #AAE0FF;
    		border: 1px solid #60B2E0;
    		padding: 10px;
    		margin-left: 20px;
    		-webkit-box-shadow: 0 0 0.7em rgba(0,0,0,0.3);
			-moz-box-shadow: 0 0 0.7em rgba(0,0,0,0.3);
			box-shadow: 0 0 0.7em rgba(0, 0, 0, 0.3);
			white-space: normal;
		}
		#submit-spinner {
			display:none;
		}
		
		input[type="text"]:disabled {
		    background: #dddddd;
		}
		#left-margin {
			float: left;
		    height: 800px;
		    margin-right: 20px;
		    margin-top: 0px;
		    width: 200px;
		}
		#map-type {
			margin-top: 20px;
		}
		
		#map-status {
			margin-top: 20px;
			padding: 10px;
			font-size: 1.2em;
			font-weight: bold;
			height: 23px;
			vertical-align: middle;			
			-webkit-box-shadow: 0 0 0.5em rgba(0,0,0,0.6);
			-moz-box-shadow: 0 0 0.5em rgba(0,0,0,0.6);
			box-shadow: 0 0 0.5em rgba(0, 0, 0, 0.6);
		}
		#map-status.undefined {
			border: 1px solid #696969;
			background-color: #dcdcdc;
			line-height: 23px;
		}
		#map-status.active {
			border: 1px solid #558d16;
			background-color: #ADFFAD;
			line-height: 23px;	
		}
		#map-status.inactive {
			background-color: #ffa8aa;
    		border: 1px solid #e88484;
    		line-height: 23px;
		}
		.toggle {
			float:right;
			font-weight: normal;
			font-size: .8em;
			text-decoration: underline;
			color: blue;
		}
		.status {
			float:left;
			white-space: nowrap;
		}
		.updating {
			line-height: 23px;
			font-weight: normal;
			font-size: .8em;
			font-style: italic;
			color: #696969;
			vertical-align: middle;
			padding-bottom: 20px;
	
		}
		.side-bar-ct {
			margin-top: 20px;
			padding: 10px;
			font-size: 1.1em;
			font-weight: bold;
			vertical-align: middle;			
			-webkit-box-shadow: 0 0 0.7em rgba(0,0,0,0.3);
			-moz-box-shadow: 0 0 0.7em rgba(0,0,0,0.3);
			box-shadow: 0 0 0.7em rgba(0, 0, 0, 0.3);
			background-color: #f5f5f5;
    		border: 1px solid #dcdcdc;
		}
		.side-bar-text-area {
			font-size: 1em;
			font-weight: normal;
			white-space: normal;
    		width: 180px;
		}

		#step-box {
			background-color: #f5f5f5;
		    box-shadow: 0 0 0.7em rgba(0, 0, 0, 0.3);
		    height: 37px;
		    margin-top: 7px;
		    margin-left:15px;
		    margin-right:15px;
		    margin-bottom:15px;
		    min-width: 900px;
		    padding: 5px 5px 10px;
		    width: 96%;
		}
		.step-list li::before {
		    background: none repeat scroll 0 0 #304762;
		    border-radius: 2em;
		    color: #fff;
		    content: counter(step, decimal);
		    float: left;
		    font-size: 12px;
		    font-weight: bold;
		    height: 2.2em;
		    line-height: 2.2em;
		    margin-left: -2.5em;
		    margin-top: -0.5em;
		    text-align: center;
		    width: 2.2em;
		}
		.step-list li {
		    counter-increment: step;
		    float: left;
		    margin-right: 0px;
		    margin-top: 5px;
		    padding-left: 3em;
		    vertical-align: middle;
		}
		.step-list {
		    counter-reset: step;
		    list-style: outside none none;
		    

		}
		
		#map-type {
			margin-left: 5px;
    		margin-top: 7px;
    		width:150px;
		}
		
		.congrats {
			font-size: 1.2em;
			font-weight: bold;
		}

