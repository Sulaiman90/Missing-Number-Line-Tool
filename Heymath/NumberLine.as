﻿package Heymath{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.filters.*
	
	public class NumberLine extends Main {
		
		private var mainMov;
		private var toolArea;

		var LINE_COLOR = 0x333333;
		var SCALE_LEFT_RIGHT_PADDING = 37;
		var TOTAL_UNITS = 101;
		var MASK_WIDTH = 800;
		var FADE_VALUE = 0.6;
		var SCROLL_TRACK_STARTING_POINT = 20.30;
		var SCROLL_TRACK_ENDING_POINT = 685.75;
		var scrollTrackUnit;

		var scaleStartingValue = 0;
		var scaleEndingValue = 0;
		var intervalNo = 1;

		var unitGap = [50,100]; // 0th value upto 3 digits & 1st value for more than 3 digits
		var scrollSpeed = [30,60];

		var slider;
		var minDisplayUnits = 7;
		var unitGapValue;
		var scaleShowVal;
		var intervalVal;
		
		function NumberLine(mc) {
			mainMov=mc;
			toolArea = mainMov.toolArea;
			init();
			trace("NumberLine");
		}
		
		function init(){
			mainMov.intro.visible = false;

			// toolArea - whole tool page

			toolArea.startNo_txt.text = 0;
			toolArea.interval_txt.text = 1;

			disableButton(toolArea.reset_btn);

			toolArea.create_btn.addEventListener("click",createBtnHandler);
			toolArea.reset_btn.addEventListener("click", resetBtnHandler);
			toolArea.find_btn.addEventListener("click", findNoBtnHandler);

			enableInputText(toolArea.startNo_txt, 5);
			enableInputText(toolArea.interval_txt, 2);
			enableInputText(toolArea.findTxt_txt, 5);
			
			scrollTrackUnit = (SCROLL_TRACK_ENDING_POINT - SCROLL_TRACK_STARTING_POINT) / TOTAL_UNITS;

			createScale();
			
			//trace("init:scrollTrackUnit " + scrollTrackUnit);
			
			// testing purpose
			toolArea.findTxt_txt.addEventListener(KeyboardEvent.KEY_DOWN,handler);
				
			function handler(e:KeyboardEvent){
				   // if the key is ENTER
				if(e.charCode == 13){
					// your code here
					findNoBtnHandler(e);
				}
			}
		}
		
		function findNoBtnHandler(e){
			var findTxtNo =  Number(toolArea.findTxt_txt.text);
			var maxScaleValue = scaleEndingValue - minDisplayUnits;
			var minScaleValue = scaleStartingValue + minDisplayUnits;
			scaleShowVal = findTxtNo - minDisplayUnits;
			trace("---------------");
			trace("findNoBtnHandler:findTxtNo,minScaleValue,maxScaleValue " + findTxtNo, minScaleValue, maxScaleValue);
			trace("findNoBtnHandler:scaleStartingValue,scaleEndingValue " + scaleStartingValue,scaleEndingValue);
			
			if (findTxtNo >= minScaleValue && findTxtNo <= maxScaleValue){
				trace(" within scale ");	
				
				intervalVal = findTxtNo - minDisplayUnits - scaleStartingValue;
				if (intervalVal <= 0){
					intervalVal = 0;
					toolArea.scrollFace.x = SCROLL_TRACK_STARTING_POINT;
				}
				else{
					moveScrollFace(findTxtNo);
				}
				toolArea.lineMc.x = 0 - unitGapValue * (intervalVal);
			}
			else if (findTxtNo > maxScaleValue){
				trace(" find value gone after");
				scaleStartingValue = findTxtNo - 50;
				removeAddedChilds();
				createScale();				
				moveScrollFace(findTxtNo);
				toolArea.lineMc.x = 0 - unitGapValue * (50 - minDisplayUnits);
			}
			else if (findTxtNo < minScaleValue){
				removeAddedChilds();
				var val = findTxtNo - 50;
				trace(" find value gone before:val "+val);
				if (val > 0){
					scaleStartingValue = val;
					createScale();			
					toolArea.lineMc.x = 0 - unitGapValue * (50 - minDisplayUnits);
					moveScrollFace(findTxtNo);
				}	
				else{
					scaleStartingValue = 0;
					createScale();		
						
					intervalVal = findTxtNo - minDisplayUnits - scaleStartingValue;
					if (intervalVal <= 0){
						intervalVal = 0;
						toolArea.scrollFace.x = SCROLL_TRACK_STARTING_POINT;
					}
					else{
						moveScrollFace(findTxtNo);
					}
					toolArea.lineMc.x = 0 - unitGapValue * (intervalVal);
				}
			}
		}
		
		function moveScrollFace(_findTxtNo){
			var findTxtNo = _findTxtNo;
			var scaleNo = findTxtNo - scaleStartingValue;
			var sliderXPos = (scaleNo+1) * scrollTrackUnit;
			var finalScrollFaceX = SCROLL_TRACK_STARTING_POINT + sliderXPos;
			//trace("findNoBtnHandler:findNo " + findTxtNo, scaleStartingValue, scaleNo, sliderXPos, finalScrollFaceX);
			toolArea.scrollFace.x = finalScrollFaceX + 1;
		}

		function createBtnHandler(e){
			scaleStartingValue = Number(toolArea.startNo_txt.text);
			intervalNo = Number(toolArea.interval_txt.text);
			
			removeAddedChilds();
			createScale();

			toolArea.startNo_txt.mouseEnabled = false;
			toolArea.interval_txt.mouseEnabled = false;
			disableButton(toolArea.create_btn);
			enableButton(toolArea.reset_btn);
		}

		function createScale(){
			var startingPointX = 13.05;
			var startingPointY = 19;
			var scrollSpeedValue;

			if(scaleStartingValue < 1000){
				unitGapValue = unitGap[0];	
				scrollSpeedValue = scrollSpeed[0];
			}
			else{
				unitGapValue = unitGap[1];		
				scrollSpeedValue = scrollSpeed[1];
			}
		
			var totalScaleWidth = SCALE_LEFT_RIGHT_PADDING + (unitGapValue * TOTAL_UNITS);
			var scaleEndPos = startingPointX + totalScaleWidth;

			//trace("startingPoint "+startingPointX,startingPointY);

			toolArea.lineMc.rightArrow.x = scaleEndPos;

			var lineShape = new Shape();
			lineShape.graphics.lineStyle(5, LINE_COLOR, 1);
			lineShape.graphics.moveTo(startingPointX,startingPointY);
			lineShape.graphics.lineTo(scaleEndPos,startingPointY);
			lineShape.name = "line";

			toolArea.lineMc.addChild(lineShape);
			toolArea.lineMc.addChild(toolArea.lineMc.leftArrow);
			toolArea.lineMc.addChild(toolArea.lineMc.rightArrow);

			for(var i=0; i<TOTAL_UNITS; i++){
				var unitLineMC = new unitLine();
				unitLineMC.name = "unitLine"+i;
				toolArea.lineMc.addChild(unitLineMC);
				unitLineMC.y = startingPointY;
				unitLineMC.x = startingPointX + SCALE_LEFT_RIGHT_PADDING + (i * unitGapValue);
				unitLineMC.no_txt.text = scaleStartingValue + (i * intervalNo) ;
				scaleEndingValue = scaleStartingValue + (i * intervalNo);
			}
			
			//trace("toolArea.lineMc " + toolArea.lineMc.width);
			
			slider = new CustomScrollPane(mainMov.parent,toolArea.lineMc, toolArea.scrollTrack, 
					toolArea.scrollFace, toolArea.btnLeft, toolArea.btnRight, scrollSpeedValue , MASK_WIDTH) ;
					
			toolArea.txt1.text = scaleStartingValue;
			toolArea.txt2.text = scaleEndingValue;
			// added for testing purpose only
		}

		function removeAddedChilds(){
			for(var i=0; i<TOTAL_UNITS; i++){
				var mc = toolArea.lineMc.getChildByName("unitLine"+i);
				toolArea.lineMc.removeChild(mc);
			}
			toolArea.lineMc.removeChild(toolArea.lineMc.getChildByName("line"));
			
			slider.removeAllEvents();
		}

		function resetBtnHandler(e){
			toolArea.startNo_txt.mouseEnabled = true;
			toolArea.interval_txt.mouseEnabled = true;
			enableButton(toolArea.create_btn);
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

		
	}
}