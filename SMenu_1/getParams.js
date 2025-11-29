    var mydata = data;
    var sections = Object.keys(mydata);
    //console.log("***sections="+JSON.stringify(sections));

    for ( var i=0; i < sections.length; i++ ) {

			//console.log("***[sections[i]="+sections[i]);

			var sectionObject = mydata[sections[i]];
			//console.log("***sectionObject="+JSON.stringify(sectionObject));
			var sectionObjectData = sectionObject.data;

			for ( var j=0; j < sectionObjectData.length; j++ ) {
				var key = sectionObjectData[j].key;
				var value = sectionObjectData[j].value;
				var type = sectionObjectData[j].type; 
				//console.log("***key="+key);

				if( type == "IMAGE" ){
					if( key == "BG_IMG" ){
						var bgElement = document.getElementById(key);
						bgElement.style.backgroundImage = 'url('+value+')';
					}else{
						document.getElementById(key).src=value;
					}				
				}else if( type=="TEXT" ){
					document.getElementById(key).innerHTML = value;
				}

				// define font selection
				if( key == "FontName" && sections[i] == "TEXT_TOP" ){
					document.getElementById("TEXT_TOP_LINE_1").style.fontFamily = value;
					document.getElementById("TEXT_TOP_LINE_2").style.fontFamily = value;
					document.getElementById("TEXT_TOP_LINE_3").style.fontFamily = value;
				}
			}

    }


