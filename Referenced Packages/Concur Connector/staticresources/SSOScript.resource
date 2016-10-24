function doSSO(ssoControlName)
{
	var e = document.getElementById(ssoControlName);
	var encodedURL = e.innerHTML;
	if (encodedURL != null)
	{
		var decodedURL = e.innerHTML.replace(/&amp;/g, "&");
		if (decodedURL != null) showWindow(decodedURL);
	}
}

concurSSOWindow = null;
var intVal = null;

function showWindow(url)
{
	if (!concurSSOWindow)
	{
		concurSSOWindow = window.open(url, "_blank");

		//Wait for the window to close.
		intVal = self.setInterval(function()
		{
			if (concurSSOWindow != null && concurSSOWindow.closed)
			{
				concurSSOWindow = null;
				if (intVal) {
					self.clearInterval(intVal);
				} else {
					self.clearInterval();
				}
				location.reload(true);
				intVal = null;
			}
		}, 250);
	}
}
