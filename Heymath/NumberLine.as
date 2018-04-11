package Heymath{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.filters.*
	import flash.text.*;
	
	public class NumberLine extends Main{
		
		var mainMov;
		var toolArea;

		var LINE_COLOR = 0x333333;
		var GRAY_COLOR = 0xcccccc;
		var BLACK_COLOR = 0x000000;
		
		var TOTAL_UNITS = 101;
		var MASK_WIDTH = 800;
		var FADE_VALUE = 0.6;
		var SCROLL_FACE_STARTING_POINT = 20;
		var SCROLL_FACE_ENDING_POINT = 696;
		var SCALE_LEFT_RIGHT_PADDING = 50;
		
		var STAGE_WIDTH = 800;
		
		var SCALE_STARTING_POS_X = 0;
		var SCALE_STARTING_POS_Y = 19;
		
		var scrollTrackUnit;

		var scaleStartingValue = 100;
		var scaleEndingValue = 0;
		var intervalNo = 1;

		var unitGap = [60,100]; // 0th value upto 3 digits & 1st value for more than 3 digits
		var scrollSpeed = [30,60];
		
		var minDisplayUnitsAr = [7, 4];
		var minDisplayUnits = minDisplayUnitsAr[0];
		
		var unitGapValue;
		var scaleShowVal;
		var intervalVal;
		var fourDigitNoEntered = false;
		
		var textGrayColorFormat = new TextFormat();
		var textBlackColorFormat = new TextFormat();
		
		var scaleDraw;
		
		public function NumberLine() {
			trace("NumberLine ");
		}
		
		public function initNumberLine(mc, _scaleDraw) {
			trace("initNumberLine "+mc.name,mc.toolArea.name);
			mainMov=mc;
			toolArea = mainMov.toolArea;
			scaleDraw = _scaleDraw;
			initFun();
		}
		
		function initFun(){
			mainMov.toolArea.visible = false;
			addEvents();

			mainMov.intro.visible = false;
			initScale();
			
			toolArea.findTxt_txt.addEventListener(KeyboardEvent.KEY_DOWN,handler); 	// testing purpose
				
			function handler(e:KeyboardEvent){
				   // if the key is ENTER
				if(e.charCode == 13){
					// your code here
					findNoBtnHandler(e);
				}
			}
		}
		
		function initScale(){
			toolArea.startNo_txt.text = scaleStartingValue;
			toolArea.interval_txt.text = intervalNo;
			toolArea.findTxt_txt.text = 0;
			
			textGrayColorFormat.color = GRAY_COLOR;
			textBlackColorFormat.color = BLACK_COLOR;
			
			toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT;
			
			disableButton(toolArea.reset_btn);
			enableButton(toolArea.create_btn);
			
			enableText(toolArea.startNo_txt);
			enableText(toolArea.interval_txt);
			
			enableInputText(toolArea.startNo_txt, 5);
			enableInputText(toolArea.interval_txt, 2);
			enableInputText(toolArea.findTxt_txt, 5);
			
			scrollTrackUnit = STAGE_WIDTH / (TOTAL_UNITS - 1);
			
			createScale(); // testing purpose
			
			toolArea.visible = true;
			
			toolArea.arrowMc.visible = false;
		}
				
		function findNoBtnHandler(e){
			
			toolArea.arrowMc.visible = true;
			
			var findTxtNo =  Number(toolArea.findTxt_txt.text);
			
			var maxScaleNum = 0;
			
			/*if (findTxtNo + 50 >= 1000 ){
				fourDigitNoEntered = true;
				minDisplayUnits = minDisplayUnitsAr[1];
			}
			else{
				fourDigitNoEntered = false;
				minDisplayUnits = minDisplayUnitsAr[0];
				if (intervalNo > 5 && intervalNo < 10){
					var dif = intervalNo - 5;
					minDisplayUnits = minDisplayUnits - dif;
				}
			}*/
			
			//trace("fourDigitNoEntered " + fourDigitNoEntered,maxScaleNum,scaleEndingValue);
						
			var minScaleValue = scaleStartingValue ;
			var maxScaleValue = scaleEndingValue;
			var minScaleLimit = scaleStartingValue + (minDisplayUnits * intervalNo);
			var maxScaleLimit = scaleEndingValue - ((minDisplayUnits * intervalNo));
			var scaleGapVal = Math.abs(scaleStartingValue - findTxtNo);
			
			trace("---------------");
			trace("findTxtNo,minDisplayUnits "+findTxtNo,minDisplayUnits);
			trace(":minScaleValue: " + minScaleValue +" maxScaleValue: " + maxScaleValue);
			trace(":minScaleLimit: " + minScaleLimit +" maxScaleLimit: " + maxScaleLimit);
			trace(":scaleGapVal: "+scaleGapVal +" scaleStartingValue: "+scaleStartingValue+" scaleEndingValue: "+scaleEndingValue);
			
			var arrowXPos;
			var lineScaleX;
			var scaleIntervalNo;
			
			if (findTxtNo >= minScaleValue && findTxtNo <= maxScaleValue){				
				if (findTxtNo > scaleStartingValue){
					intervalVal = ((findTxtNo - scaleStartingValue)/intervalNo) - minDisplayUnits;
				}			
				// scale unit value
				scaleIntervalNo = Math.abs(findTxtNo - scaleStartingValue) / intervalNo;				
				trace("within scale:intervalVal " + intervalVal + " scaleIntervalNo "+ scaleIntervalNo);	
				
				if (findTxtNo >= minScaleLimit && findTxtNo <= maxScaleLimit){				
					lineScaleX = 0 - ((scaleIntervalNo * unitGapValue) - (minDisplayUnits * 50));
				}
				else if (findTxtNo >= maxScaleLimit){
					lineScaleX = 0 - (((TOTAL_UNITS-minDisplayUnits) * unitGapValue) - (minDisplayUnits * 50));
				}
				else if (findTxtNo <= minScaleLimit){
					lineScaleX = 0;
				}			
				toolArea.lineMc.x = lineScaleX;		
				
				// move scroll face 	
				if (intervalVal < 0){
					intervalVal = 0;
					toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT;
				}
				else if (intervalVal == 0){
					toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT;
				}
				else{
					moveScrollFace(findTxtNo);
				}	
				
				var findTxtMinLimit = minDisplayUnits;
				var findTxtMaxLimit = TOTAL_UNITS-minDisplayUnits;
				
				// arrow x calculation 	
				if (scaleIntervalNo >= findTxtMinLimit && (scaleIntervalNo <= findTxtMaxLimit)){
					// > than minDisplayUnits, make it as center
					arrowXPos = 50 * 8;
				}
				else if (scaleIntervalNo < findTxtMinLimit){
					// else move arrow
					arrowXPos = SCALE_STARTING_POS_X + SCALE_LEFT_RIGHT_PADDING + (scaleIntervalNo * unitGapValue);
				}
				else if (scaleIntervalNo > findTxtMaxLimit){
					// else move arrow 
					// find the difference between center and findtxt value
					var val1 = 400 + ((scaleIntervalNo - (TOTAL_UNITS - minDisplayUnits)) * unitGapValue) ;
					trace("val1 " + val1);
					arrowXPos = val1;
				}
				toolArea.arrowMc.x = arrowXPos;
			
				trace("findTxtNo "+findTxtNo +" arrowXPos "+arrowXPos +" lineScaleX "+lineScaleX);
				
				/*if (fourDigitNoEntered){
					arrowXPos = arrowXPos-50;
				}
					toolArea.arrowMc.x = arrowXPos;
				
				if (intervalVal < 0 && scaleGapVal < minScaleValue){
					trace("lessThanMinScale");
					lessThanMinScale();
				}	
				checkScaleValue();*/
			}
			else if (findTxtNo > maxScaleLimit){
				trace(" find value gone after");
				
				scaleStartingValue = findTxtNo - (50 * intervalNo);
				scaleDraw.removeAddedChilds();
				createScale();	
				moveScrollFace(findTxtNo);
				
				scaleIntervalNo = Math.abs(findTxtNo - scaleStartingValue) / intervalNo;
				lineScaleX = 0 - ((scaleIntervalNo * unitGapValue) - (minDisplayUnits * 50));
				toolArea.lineMc.x = lineScaleX;
				//trace("lineScaleX,scaleIntervalNo " + lineScaleX, scaleIntervalNo,unitGapValue);
					
				arrowXPos = scaleIntervalNo * 8;
				//trace("findTxtNo,arrowXPos " + findTxtNo,arrowXPos);
				if (fourDigitNoEntered){
					arrowXPos = arrowXPos-50;
				}
				toolArea.arrowMc.x = arrowXPos;
				
				checkScaleValue();
			}
			else if (scaleGapVal < minScaleValue){
				lessThanMinScale();
			}
			
			toolArea.startNo_txt.text = scaleStartingValue;
			if (toolArea.startNo_txt.mouseEnabled ){
				toolArea.startNo_txt.setTextFormat(textBlackColorFormat);
			}
			else{
				toolArea.startNo_txt.setTextFormat(textGrayColorFormat);
			}
			
			// find text no less than min scale value
			function lessThanMinScale(){
				scaleDraw.removeAddedChilds();
				var val = findTxtNo - scaleStartingValue - (50 * intervalNo);
				var arrowXPos2;
				trace(" find value gone before:val "+val);
				if (val > 0){
					scaleStartingValue = val;
					createScale();			
					toolArea.lineMc.x = 0 - unitGapValue * (50 - minDisplayUnits);
					moveScrollFace(findTxtNo);	
				}	
				else{
					var val2 = findTxtNo - (50 * intervalNo);
					
					if (val2 > minDisplayUnits){
						scaleStartingValue = val2;
						//trace("if");
						arrowXPos2 = ((findTxtNo - scaleStartingValue) / intervalNo ) * 8;		
					}
					else{
						//trace("else");
						scaleStartingValue = 0;
						arrowXPos2 = ((findTxtNo - scaleStartingValue) / intervalNo ) * 8;			
					}
					createScale();		
					
					intervalVal = ((findTxtNo - scaleStartingValue)/intervalNo) - minDisplayUnits ;
					
					trace(" create scale again:val2,intervalVal "+val2,intervalVal);
					if (intervalVal <= 0){
						intervalVal = 0;
						toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT;			
					}  
					else{
						moveScrollFace(findTxtNo);
					}
					toolArea.lineMc.x = 0 - unitGapValue * (intervalVal);	
					
					if (fourDigitNoEntered){
						arrowXPos2 = arrowXPos2-50;
					}
					trace("findTxtNo,arrowXPos2 " + findTxtNo,arrowXPos2);
					toolArea.arrowMc.x = arrowXPos2;
				}
				checkScaleValue();
			}
		}
		
		
		// check if scale values are greater than 1000
		function checkScaleValue(){
			if (fourDigitNoEntered){
				toolArea.lineMc.x = toolArea.lineMc.x -50;
			}
		}
		
		function moveScrollFace(_findTxtNo){
			var findTxtNo = _findTxtNo;
			trace("moveScrollFace:findTxtNo " + findTxtNo);
			//trace("moveScrollFace:minDisplayUnits"+minDisplayUnits);
			var scaleIntervalNo = Math.abs(findTxtNo - scaleStartingValue) / intervalNo;
			var sliderXPos;
			if (scaleIntervalNo >= (TOTAL_UNITS-1-minDisplayUnitsAr[0]) ){
				toolArea.scrollFace.x = SCROLL_FACE_ENDING_POINT;
			}
			else{
				sliderXPos = (scaleIntervalNo * scrollTrackUnit) - (toolArea.scrollFace.width/2); 
				toolArea.scrollFace.x = sliderXPos ;
			}
			//trace("findNoBtnHandler:findNo " + findTxtNo, scaleIntervalNo, sliderXPos, (scaleIntervalNo * scrollTrackUnit) );
			if (sliderXPos < SCROLL_FACE_STARTING_POINT){
				toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT ;
			}
		}
		
		function moveArrowMc(_findTxtNo){
			toolArea.arrowMc.visible = true;
			var findTxtNo = _findTxtNo;
			var scaleIntervalNo = findTxtNo / intervalNo;
			var arrowXPos = SCALE_STARTING_POS_X + SCALE_LEFT_RIGHT_PADDING + (scaleIntervalNo * unitGapValue);
			//trace("moveArrowMc:findTxtNo,scaleIntervalNo,arrowXPos " + findTxtNo,scaleIntervalNo,arrowXPos);
			toolArea.arrowMc.x = arrowXPos;
		}

		function createScale(){
			//trace("createScale:intervalNo " + intervalNo);
			scaleDraw.generateScale();
		}
		
		function resetScale(){
			scaleStartingValue = 0;
			intervalNo = 1;
			scaleDraw.removeAddedChilds();
			toolArea.arrowMc.visible = false;
		}
		
		function addEvents(){
			mainMov.intro.explore_btn.addEventListener("click", navigateBtnHandler);
			toolArea.home_btn.addEventListener("click",navigateBtnHandler);
			toolArea.create_btn.addEventListener("click",createBtnHandler);
			toolArea.reset_btn.addEventListener("click", resetBtnHandler);
			toolArea.find_btn.addEventListener("click", findNoBtnHandler);	
			toolArea.interval_txt.addEventListener("change", onTextChangeHandler);
		}
		
		function removeEvents(){
			mainMov.intro.explore_btn.removeEventListener("click", navigateBtnHandler);
			toolArea.home_btn.removeEventListener("click",navigateBtnHandler);
			toolArea.create_btn.removeEventListener("click",createBtnHandler);
			toolArea.reset_btn.removeEventListener("click", resetBtnHandler);
			toolArea.find_btn.removeEventListener("click", findNoBtnHandler);	
			toolArea.interval_txt.removeEventListener("change", onTextChangeHandler);
		}
		
		
		
		function createBtnHandler(e){
			scaleStartingValue = Number(toolArea.startNo_txt.text);
			intervalNo = Number(toolArea.interval_txt.text);
			
			scaleDraw.removeAddedChilds();
			createScale();

			disableText(toolArea.startNo_txt);
			disableText(toolArea.interval_txt);

			disableButton(toolArea.create_btn);
			enableButton(toolArea.reset_btn);
			
			toolArea.arrowMc.visible = false;
		}

		function resetBtnHandler(e){
			enableText(toolArea.startNo_txt);
			enableText(toolArea.interval_txt);
			
			enableButton(toolArea.create_btn);
			disableButton(toolArea.reset_btn);
		}
		
		function navigateBtnHandler(e){
			var name = e.currentTarget.name;
			trace("navigateBtnHandler:name " + name);
			if (name == "explore_btn"){
				mainMov.intro.visible = false;
				initScale();
			}
			else if (name == "home_btn"){
				toolArea.visible = false;
				resetScale();
				mainMov.intro.visible = true;	
			}
		}
		
		function onTextChangeHandler(e){
			if (e.target.text=="") {
				intervalNo = 1;
			}
			else{
				intervalNo = Number(toolArea.interval_txt.text);
			}
		}

		function enableInputText(_refTxt, _maxChars){
			var refTxt = _refTxt;
			refTxt.maxChars = _maxChars;
			refTxt.restrict = "0-9";
			refTxt.addEventListener("focusIn",focusInHandler);
			refTxt.addEventListener("focusOut", focusOutHandler);
		}

		function focusInHandler(e){
			e.target.text="";
		}

		function focusOutHandler(evt) {
			if (evt.target.text=="") {
				if(evt.target.name=="interval_txt"){
					evt.target.text="1";
				}
				else{
					evt.target.text="0";
				}
			}
		}

		function disableButton(btn){
			btn.mouseEnabled = false;
			btn.alpha = FADE_VALUE;
		}

		function enableButton(btn){
			btn.mouseEnabled = true;
			btn.alpha = 1;
		}
		
		function disableText(txt){
			txt.mouseEnabled = false;
			txt.setTextFormat(textGrayColorFormat);
		}

		function enableText(txt){
			//trace("enableText " + txt.name);
			txt.mouseEnabled = true;
			txt.setTextFormat(textBlackColorFormat);
		}

		
	}
}



