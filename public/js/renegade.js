jQuery.validator.addMethod(
	"date",
	function(value, element) {
		var check = false;
		var re = /^\d{1,2}\/\d{1,2}\/\d{4}$/;
		var re2 = /^\d{4}-\d{1,2}-\d{1,2}$/;
		if( re.test(value)){
			var adata = value.split('/');
			var month = parseInt(adata[0],10);
			var day = parseInt(adata[1],10);
			var year = parseInt(adata[2],10);
      window.console && console.log(year,month,day);
			var xdata = new Date(year,month-1,day);
      window.console && console.log(xdata);
			if ( ( xdata.getFullYear() == year) && ( xdata.getMonth () == month - 1 ) && ( xdata.getDate() == day ) )
				check = true;
			else
				check = false;
    } else if (re2.test(value)) {
			var adata = value.split('-');
			var year = parseInt(adata[0],10);
			var month = parseInt(adata[1],10);
			var day = parseInt(adata[2],10);
      window.console && console.log(year,month,day);
			var xdata = new Date(year,month-1,day);
      window.console && console.log(xdata);
			if ( ( xdata.getFullYear() == year) && ( xdata.getMonth () == month - 1 ) && ( xdata.getDate() == day ) )
				check = true;
			else
				check = false;
		} else {
			check = false;
    }
		return this.optional(element) || check;
	},
	"Please enter a correct date in the format yyyy-mm-dd or mm/dd/yyyy"
);

