var mydata = data;
var sections = Object.keys(mydata);
//console.log("***sections="+JSON.stringify(sections));

for (var i = 0; i < sections.length; i++) {

	//console.log("***[sections[i]="+sections[i]);

	var sectionObject = mydata[sections[i]];
	//console.log("***sectionObject="+JSON.stringify(sectionObject));
	var sectionObjectData = sectionObject.data;

	for (var j = 0; j < sectionObjectData.length; j++) {
		var key = sectionObjectData[j].key;
		var value = sectionObjectData[j].value;
		var type = sectionObjectData[j].type;
		//console.log("***key="+key);

		if (type == "IMAGE") {
			if (key == "BG_IMG") {
				var bgElement = document.getElementById(key);
				bgElement.style.backgroundImage = 'url(' + value + ')';
			} else {
				document.getElementById(key).src = value;
			}
		} else if (type === "VIDEO") {
			if (key === "BG_VIDEO") {
			  var videoElement = document.getElementById(key);
			  videoElement.src = value;
			  videoElement.style.display = "block";
			}
		  } else if (type === "TEXT") {
			document.getElementById(key).innerHTML = value;
		  }

		// define font selection

		if (key == "BDY_TEXT_FontName" && value == "Virtual" && sections[i] == "BIRTHDAY") {
			document.getElementById("BDY_TEXT").style.fontFamily = value;
		}

	}

}


