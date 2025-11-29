var mydata = data;
var sections = Object.keys(mydata);


for (var i = 0; i < sections.length; i++) {



	var sectionObject = mydata[sections[i]];

	var sectionObjectData = sectionObject.data;
	for (var j = 0; j < sectionObjectData.length; j++) {
		var key = sectionObjectData[j].key;
		var value = sectionObjectData[j].value;
		var type = sectionObjectData[j].type;
		var jsId = sectionObjectData[j].jsId;


		if (type == "IMAGE") {
			console.log("***key="+jsId);
			var bgElement = document.getElementById(jsId);
			
			if (key == "BG_IMG") {
				bgElement.style.backgroundImage = 'url(' + value + ')';
			} else {
				
				bgElement.src = value;
			}
		} else if (type === "VIDEO") {
			var videoElement = document.getElementById(jsId);
			videoElement.src = value;
			videoElement.style.display = "block";
		  } else if (type === "TEXT") {
			var textElement = document.getElementById(jsId);
			textElement.innerHTML = value;
		  }

		// define font selection

		if (key == "BDY_TEXT_FontName" && value == "Virtual" && sections[i] == "BIRTHDAY") {
			var element = document.getElementById(jsId);
			if(element){
				element.style.fontFamily = value;
			}
		}

	}

}


