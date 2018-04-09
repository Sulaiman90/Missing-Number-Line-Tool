package Heymath{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.filters.*
	import flash.text.*;
	
	public class NumberLine extends Main {
		
		private var mainMov;
		private var toolArea;

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

		var scaleStartingValue = 0;
		var scaleEndingValue = 0;
		var intervalNo = 6;

		var unitGap = [50,100]; // 0th value upto 3 digits & 1st value for more than 3 digits
		var scrollSpeed = [30,60];

		var slider;
		
		var minDisplayUnitsAr = [7, 4];
		var minDisplayUnits = minDisplayUnitsAr[0];
		
		var unitGapValue;
		var scaleShowVal;
		var intervalVal;
		var fourDigitNoEntered = false;
		
		var textGrayColorFormat = new TextFormat();
		var textBlackColorFormat = new TextFormat();
		
		function NumberLine(mc) {
			mainMov=mc;
			toolArea = mainMov.toolArea;
			initFun();
			//trace("NumberLine");
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
		}
				
		function findNoBtnHandler(e){
			
			var findTxtNo =  Number(toolArea.findTxt_txt.text) / 1;
			
			if (findTxtNo + 50 >= 1000){
				fourDigitNoEntered = true;
				minDisplayUnits = minDisplayUnitsAr[1];
			}
			else{
				fourDigitNoEntered = false;
				minDisplayUnits = minDisplayUnitsAr[0];
			}
			
			var minScaleValue = scaleStartingValue + (minDisplayUnits * intervalNo);
			var maxScaleValue = scaleEndingValue - (minDisplayUnits * intervalNo)  - 1;

			var scaleGapVal = Math.abs(scaleStartingValue - findTxtNo);
			trace("---------------");
			trace("findNoBtnHandler:findTxtNo,minScaleValue,maxScaleValue " + findTxtNo, minScaleValue, maxScaleValue);
			trace("findNoBtnHandler:scaleGapVal,scaleStartingValue,scaleEndingValue " + scaleGapVal,scaleStartingValue,scaleEndingValue);
			
			if (findTxtNo >= minScaleValue && findTxtNo <= maxScaleValue){
								
				intervalVal = ((findTxtNo - scaleStartingValue)/intervalNo) - minDisplayUnits ;
				
				trace("within scale:intervalVal " + intervalVal);	
				
				// condition to check if scale value starts from beginning 
				
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
				
				toolArea.lineMc.x = 0 - unitGapValue * (intervalVal);
				
				if (intervalVal < 0 && scaleGapVal < minScaleValue){
					trace("lessThanMinScale");
					lessThanMinScale();
				}
				
				checkScaleValue();
			}
			else if (findTxtNo > maxScaleValue){
				trace(" find value gone after");
				scaleStartingValue = findTxtNo - (50 * intervalNo);
				removeAddedChilds();
				createScale();	
				moveScrollFace(findTxtNo);
				toolArea.lineMc.x = 0 - unitGapValue * (50 - minDisplayUnits);
				
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
				removeAddedChilds();
				var val = findTxtNo - scaleStartingValue - (50 * intervalNo);
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
					}
					else{
						scaleStartingValue = 0;
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
			trace("moveScrollFace--------------"+findTxtNo,minDisplayUnits);
			var scaleIntervalNo = Math.abs(findTxtNo - scaleStartingValue) / intervalNo;
			var sliderXPos;
			if (scaleIntervalNo >= (TOTAL_UNITS-1-minDisplayUnitsAr[0]) ){
				toolArea.scrollFace.x = SCROLL_FACE_ENDING_POINT;
			}
			else{
				sliderXPos = ((scaleIntervalNo + 0) * scrollTrackUnit) - (toolArea.scrollFace.width/2); 
				toolArea.scrollFace.x = sliderXPos ;
			}
			trace("findNoBtnHandler:findNo " + findTxtNo, scaleIntervalNo, sliderXPos);
			if (sliderXPos < SCROLL_FACE_STARTING_POINT){
				toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT ;
			}
		}

		function createScale(){
			var startingPointX = SCALE_STARTING_POS_X;
			var startingPointY = SCALE_STARTING_POS_Y;
			var scrollSpeedValue;
			
			scaleEndingValue =  scaleStartingValue + (TOTAL_UNITS * intervalNo);
			
			var totalScaleWidth;
			
			if (scaleEndingValue < 1000){
				if (intervalNo < 6){
					unitGapValue = unitGap[0];	
				}
				else{
					unitGapValue = intervalNo * 10;
				}	
				scrollSpeedValue = scrollSpeed[0];
				//trace("unitGapValue "+unitGapValue);
				totalScaleWidth =  (unitGapValue * (TOTAL_UNITS-1) +  (SCALE_LEFT_RIGHT_PADDING * 2)) ;
			}
			else{
				unitGapValue = unitGap[1];		
				scrollSpeedValue = scrollSpeed[1];
				totalScaleWidth =  (unitGapValue * (TOTAL_UNITS));
			}
		
			//trace("totalScaleWidth "+totalScaleWidth,unitGapValue,TOTAL_UNITS,(unitGapValue * (TOTAL_UNITS-1) +  SCALE_LEFT_RIGHT_PADDING));
			var scaleEndPos =  SCALE_STARTING_POS_X + totalScaleWidth;
			
			toolArea.lineMc.leftArrow.x = startingPointX;
			toolArea.lineMc.rightArrow.x = scaleEndPos;

			//trace("startingPoint " + startingPointX, startingPointY, scaleEndPos);
			
			var lineContainer = new MovieClip();
			lineContainer.name = "lineContainer";
			toolArea.lineMc.addChild(lineContainer);

			var lineShape = new Shape();
			lineShape.graphics.lineStyle(2, LINE_COLOR, 1);
			lineShape.graphics.moveTo(startingPointX,startingPointY);
			lineShape.graphics.lineTo(scaleEndPos,startingPointY);
			lineShape.name = "line";

			lineContainer.addChild(lineShape);
			toolArea.lineMc.addChild(toolArea.lineMc.leftArrow);
			toolArea.lineMc.addChild(toolArea.lineMc.rightArrow);

			for(var i=0; i< TOTAL_UNITS ; i++){
				var unitLineMC = new unitLine();
				unitLineMC.name = "unitLine"+i;
				lineContainer.addChild(unitLineMC);
				unitLineMC.y = startingPointY;
				var scaleUnitPos = startingPointX + SCALE_LEFT_RIGHT_PADDING + (i * unitGapValue);
				unitLineMC.x = scaleUnitPos;
				var txtStr = scaleStartingValue + (i * intervalNo) ;
				unitLineMC.no_txt.text = txtStr;
				//trace("i " + i, txtStr, scaleUnitPos);
				
				if (i < TOTAL_UNITS-1){
					for (var j = 1 ; j < intervalNo; j++){
						var intervalLineMC = new intervalLine();
						intervalLineMC.name = "intervalLine"+j;
						lineContainer.addChild(intervalLineMC);
						intervalLineMC.y = startingPointY;
						var intervalPos = Math.round(scaleUnitPos + ((unitGapValue / intervalNo) * j));
						//trace("j " + j,scaleUnitPos,intervalPos);
						intervalLineMC.x = intervalPos;
						 
					}	
				}	
			}
			
			slider = new CustomScrollPane(mainMov.parent,toolArea.lineMc, toolArea.scrollTrack, 
					toolArea.scrollFace, toolArea.btnLeft, toolArea.btnRight, scrollSpeedValue , MASK_WIDTH) ;
				
					
			toolArea.txt1.text = scaleStartingValue;
			toolArea.txt2.text = scaleEndingValue - intervalNo;
			// added for testing purpose only
			
			trace("createScale:minScaleValue,maxScaleValue " +  (scaleStartingValue+(minDisplayUnits*intervalNo)), 
			(scaleEndingValue - (minDisplayUnits*intervalNo) - 1));
		}
		
		function resetScale(){
			scaleStartingValue = 0;
			intervalNo = 1;
			removeAddedChilds();
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
		
		function removeAddedChilds(){		
			var lineContainerMc = toolArea.lineMc.getChildByName("lineContainer");
			//trace("removeAddedChilds " + lineContainerMc.numChildren);
			toolArea.lineMc.removeChild(lineContainerMc);
			slider.removeAllEvents();
		}
		
		function createBtnHandler(e){
			scaleStartingValue = Number(toolArea.startNo_txt.text);
			intervalNo = Number(toolArea.interval_txt.text);
			
			removeAddedChilds();
			createScale();

			disableText(toolArea.startNo_txt);
			disableText(toolArea.interval_txt);

			disableButton(toolArea.create_btn);
			enableButton(toolArea.reset_btn);
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
			trace("enableText " + txt.name);
			txt.mouseEnabled = true;
			txt.setTextFormat(textBlackColorFormat);
		}

		
	}
}