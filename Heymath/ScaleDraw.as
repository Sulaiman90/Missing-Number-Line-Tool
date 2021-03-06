﻿package Heymath
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	public class ScaleDraw extends NumberLine
	{
		
		//var slider;
		var selectedBox;
		var totalRightCnt = 0;
		var totalDisplayUnits = 0;
		
		public function ScaleDraw()
		{
			//trace("ScaleDraw ");
		}
		
		public function initScaleDraw(_rootMain)
		{
			//trace("initScaleDraw ");
			initNumberLine(_rootMain, this);
			resetVars();
		}
		
		function resetVars(){
			totalRightCnt = 0;
			totalDisplayUnits = 0;
			lineCreated = false;
			
			resetUnitOptionBtns(1);
			resetUnitOptionBtns(2);
			hideMc.hide_ran.gotoAndStop(2);
			answerMc.typeAnswer.gotoAndStop(2);
			
			hideMode = "hide_ran";
			answerMode = "typeAnswer";
		}
		
		public function generateScale()
		{
			trace("generateScale ");
			lineCreated = true;
			// set movieclip state after creating new scale
		
			var startingPointX = SCALE_STARTING_POS_X;
			var startingPointY = SCALE_STARTING_POS_Y;
			var scrollSpeedValue;
			
			var scaleEndVal = scaleStartingValue + (TOTAL_UNITS * intervalNo) - intervalNo;
			
			// set scaleEndingValue
			scaleEndingValue = scaleEndVal;
			
			//trace("intervalNo " + intervalNo,toolArea.name);
			
			if (intervalNo < 6){
				unitGapValue = unitGap[0];
			}
			else if (intervalNo > 5 && intervalNo <= MAX_INTERVAL){
				unitGapValue = (intervalNo * 10) + (unitGap[0] - 50); // change according to unitGapValue
			}
			else if (intervalNo > MAX_INTERVAL){
				unitGapValue = unitGap[0];
			}
			trace("-------------------------------- ");
			
			// total units present in screen
			
			displayUnits = 1;
			var val = 0;
			while (val < STAGE_WIDTH){	
				//trace(" displayUnits " + (intervalNo * (displayUnits - 1)) +" val " + val );
				val = SCALE_LEFT_RIGHT_PADDING + 0 + (unitGapValue * displayUnits);	
				if (val >= STAGE_WIDTH){
					break;
				}	
				displayUnits++;
				//trace("val " + val + " displayUnits " + displayUnits);	
			}
			
			visibleUnits = parseInt(displayUnits / 3);
			
			if (visibleUnits <= 0){
				visibleUnits = 1;
			}
			trace("unitGapValue " + unitGapValue +" displayUnits " + displayUnits  +" visibleUnits " + visibleUnits);
			
			scrollSpeedValue = scrollSpeed[0];
			var totalScaleWidth = (unitGapValue * (TOTAL_UNITS - 1) + (SCALE_LEFT_RIGHT_PADDING * 2));	
			//trace("totalScaleWidth "+totalScaleWidth,unitGapValue,TOTAL_UNITS,(unitGapValue * (TOTAL_UNITS-1) +  SCALE_LEFT_RIGHT_PADDING));
			
			var scaleEndPos = SCALE_STARTING_POS_X + totalScaleWidth;
			
			toolArea.lineMc.leftArrow.x = startingPointX;
			toolArea.lineMc.rightArrow.x = scaleEndPos;
			
			trace("startingPoint " + startingPointX, startingPointY, scaleEndPos);
			//trace("scaleEndVal " + scaleEndVal);
			
			var lineContainer = new MovieClip();
			lineContainer.name = "lineContainer";
			toolArea.lineMc.addChild(lineContainer);
			
			var lineShape = new Shape();
			lineShape.graphics.clear();
			lineShape.graphics.lineStyle(2, LINE_COLOR, 1);
			lineShape.graphics.moveTo(startingPointX, startingPointY);
			lineShape.graphics.lineTo(scaleEndPos, startingPointY);
			lineShape.name = "line";
			
			lineContainer.addChild(lineShape);
			toolArea.lineMc.setChildIndex(toolArea.lineMc.leftArrow, toolArea.lineMc.numChildren - 1);
			toolArea.lineMc.setChildIndex(toolArea.lineMc.rightArrow, toolArea.lineMc.numChildren-1);
			toolArea.lineMc.leftArrow.visible = true;
			toolArea.lineMc.rightArrow.visible = true;
			
			trace(" lineMc width " + toolArea.lineMc.width,toolArea.lineMc.height);
			
			// genreate random numbers to hide the units
			if (hideMode != "show_all"){
				generateRandomNos();
			}
			
			trace(" scaleEndingValue " + scaleEndingValue);
			var boxFrameNo = 1;
			var scaleEndValueLen = scaleEndingValue.toString().length;
			if(scaleEndValueLen > 3){
				boxFrameNo = scaleEndValueLen - 1;
			}
			
			//trace("randomUnitsAr " + randomUnitsAr);
				
			for (var i = 0; i < TOTAL_UNITS; i++)
			{
				var unitLineMC = new unitLine();
				unitLineMC.name = "unitLine" + i;
				lineContainer.addChild(unitLineMC);
				unitLineMC.y = startingPointY;
				var scaleUnitPos = startingPointX + SCALE_LEFT_RIGHT_PADDING + (i * unitGapValue);
				unitLineMC.x = scaleUnitPos;
				var txtStr = scaleStartingValue + (i * intervalNo);
				
				unitLineMC.no_txt.text = txtStr;
				unitLineMC.val = txtStr;
				unitLineMC.no_txt.mouseEnabled = false;
				
				unitLineMC.inRandom = false;
				
				unitLineMC.box.visible = false;
				unitLineMC.screen.visible = false;
				unitLineMC.tick.gotoAndStop("none");
				
				unitLineMC.box.gotoAndStop(boxFrameNo);
				unitLineMC.screen.gotoAndStop(boxFrameNo);
				unitLineMC.screen.addEventListener("click", onScreenClickHandler); 
				
				unitLineMC.attempts = 0;
				var refTxt = unitLineMC.no_txt;
				refTxt.removeEventListener("focusIn", focusInNoHandler);
				refTxt.removeEventListener("focusOut", focusOutNoHandler);
				refTxt.removeEventListener("change", changeFn);						
							
				if (isInArray(i, randomUnitsAr)){
					unitLineMC.inRandom = true;
				}
				
				//trace("ii " + i,isInArray((i), randomUnitsAr) );
				if (hideMode == "hide_ran"){
					if (unitLineMC.inRandom){
						unitLineMC.box.visible = true;
						if (answerMode == "typeAnswer"){
							unitLineMC.screen.visible = false;
							refTxt.text = "?";
							refTxt.mouseEnabled = true;
							refTxt.maxChars = scaleEndValueLen;
							refTxt.restrict = "0-9\\-";
							refTxt.addEventListener("focusIn", focusInNoHandler);
							refTxt.addEventListener("focusOut", focusOutNoHandler);
							refTxt.addEventListener("change", changeFn);
						}
						else if (answerMode == "revealAnswer"){
							unitLineMC.screen.visible = true;
							refTxt.mouseEnabled = false;
						}
					}	
				}
				else if (hideMode == "hide_all"){
					if (i != 0 && i != TOTAL_UNITS - 1){
						if (answerMode == "typeAnswer"){
							unitLineMC.box.visible = true;
							unitLineMC.screen.visible = false;
							refTxt.text = "?";
							refTxt.mouseEnabled = true;
							refTxt.maxChars = scaleEndValueLen;
							refTxt.restrict = "0-9\\-";
							refTxt.addEventListener("focusIn", focusInNoHandler);
							refTxt.addEventListener("focusOut", focusOutNoHandler);
							refTxt.addEventListener("change", changeFn);
						}
						else if (answerMode == "revealAnswer"){
							unitLineMC.screen.visible = true;
							refTxt.mouseEnabled = false;
						}
					}
				}
				//trace("i " + i, txtStr, scaleUnitPos);	
				
				if (i < TOTAL_UNITS - 1)
				{
					for (var j = 1; j < intervalNo; j++)
					{
						var intervalLineMC = new intervalLine();
						intervalLineMC.name = "intervalLine" + j;
						lineContainer.addChild(intervalLineMC);
						intervalLineMC.y = startingPointY;
						var intervalPos = Math.round(scaleUnitPos + ((unitGapValue / intervalNo) * j));
						//trace("j " + j,scaleUnitPos,intervalPos);
						intervalLineMC.x = intervalPos;
						if (intervalNo > MAX_INTERVAL){
							intervalLineMC.visible = false;
						}
					}
				}
			}
			
			slider = new CustomScrollPane(toolArea.parent, toolArea.lineMc, toolArea.scrollTrack, toolArea.scrollFace, toolArea.btnLeft, toolArea.btnRight, scrollSpeedValue, MASK_WIDTH);
			
			// added for testing purpose only		
			toolArea.txt1.text = scaleStartingValue;
			toolArea.txt2.text = scaleEndVal;
			
			// add a checkbtn to scale
			check_btn = new checkBtn();
			lineContainer.addChild(check_btn);
			
			check_btn.addEventListener("click", checkBtnHandler);
			check_btn.visible = false;
			check_btn.y = -25;
			
		/*trace("createScale:minScaleValue,maxScaleValue " +  (scaleStartingValue+(minDisplayUnits*intervalNo)),
		   (scaleEndVal - (minDisplayUnits*intervalNo) - 1));*/
		}
		
		function onScreenClickHandler(e){
			//e.currentTarget.visible = false;
			var screen = e.currentTarget;
			var cf = screen.currentFrame;
			screen["c" + cf].gotoAndPlay(2);
		}
		
		function validationCheck(){
			var txtStr = selectedBox.no_txt.text;
			var ansStr = selectedBox.val;
			check_btn.visible = false;
			selectedBox.tick.visible = true;
			if (txtStr == "" || txtStr == "?"){
				check_btn.visible = false;
				selectedBox.no_txt.text = "?";
				selectedBox.tick.gotoAndStop("none");
			}
			else if (txtStr == ansStr){
				selectedBox.no_txt.mouseEnabled = false;
				selectedBox.tick.gotoAndStop("right");
				check_btn.visible = false;
				totalRightCnt++;
			}
			else if (txtStr != ansStr){
				selectedBox.attempts++;
				selectedBox.tick.gotoAndStop("wrong");
				if (selectedBox.attempts > 3){
					selectedBox.no_txt.text = ansStr;
					selectedBox.no_txt.mouseEnabled = false;
					selectedBox.tick.gotoAndStop("none");
					check_btn.visible = false;
				}
			}
			if (totalRightCnt > totalDisplayUnits){
				trace("ALL ANSWERS DONE");
			}
		}
		
		function checkBtnHandler(e){
			validationCheck();
		}
				
		function focusInNoHandler(e){
			e.target.text = "";
			selectedBox = e.currentTarget.parent;
			selectedBox.tick.gotoAndStop("none");
			var id = selectedBox.val;
			var posX = e.currentTarget.parent.x;
			//trace("id " + id + " posX " + posX);
			check_btn.visible = true;
			check_btn.x = posX;
		}
		
		function focusOutNoHandler(evt){
			if (evt.target.text == ""){
				evt.target.text = "?";
			}
			selectedBox = evt.currentTarget.parent;
			//validationCheck();
		}
		
		function removeAddedChilds(){
			if (!lineCreated){
				return;
			}
			var lineContainerMc = toolArea.lineMc.getChildByName("lineContainer");
			//trace("removeAddedChilds " + lineContainerMc.numChildren);
			toolArea.lineMc.removeChild(lineContainerMc);
			toolArea.lineMc.leftArrow.visible = false;
			toolArea.lineMc.rightArrow.visible = false;
			//trace("toolArea.lineMc " + toolArea.lineMc.width);
			slider.removeAllEvents();
		}
		
		// generate random numbers for scale units
		function generateRandomNos(){
			var startNo = 1;
			var endNo = displayUnits-1;
			
			var randomAr = [];
			randomUnitsAr = [];
			var randomNo;
			var loopTaken = 0;
			
			totalDisplayUnits = (Math.round(100 / displayUnits)) * visibleUnits;
			//var noOfTimes = (Math.round(100 / displayUnits));
			var randomIntervalGap = endNo - startNo;
		
			//trace("totalDisplayUnits " + totalDisplayUnits);
			//trace("startNo " + startNo + " endNo " + endNo);
			
			generate();
			
			randomUnitsAr.sort(compareNumbers); 
			
			//trace("loopTaken " + loopTaken);
			//trace("generateRandomNos:randomUnitsAr " + randomUnitsAr + " length "+randomUnitsAr.length);
				
			function checkAndRegenerate(){
				//trace("----------------");
				//trace("checkAndRegenerate:randomUnitsAr "+randomUnitsAr);
				if (randomUnitsAr.length < totalDisplayUnits){
					startNo = startNo + displayUnits;
					if (randomUnitsAr.length == (totalDisplayUnits - visibleUnits)){
						endNo = 99;
					}
					else{
						endNo = endNo + displayUnits;
					}
					randomIntervalGap = endNo - startNo;
					//trace("startNo " + startNo + " endNo " + endNo);
					generate();
				}
			}
			
			function generate(){
				//trace("generate");
				while (randomAr.length < visibleUnits){
					loopTaken++;
					//trace("loopTaken " + loopTaken);
					randomNo = randomBetween(startNo, endNo);
					if (!isInArray(randomNo, randomAr)){
						//trace("value not exists in array");
						if (!checkIfGapExists(randomNo)){
							//trace("gap not exists:randomNo "+randomNo + " randomAr "+randomAr);
							randomAr.push(randomNo);
						}
						else if(randomUnitsAr.length == (totalDisplayUnits - visibleUnits) && randomIntervalGap <=2){
							//trace("gap exists");
							randomAr.push(randomNo);
						}
					}
				}
				if (randomAr.length == visibleUnits){
					//trace("generate:randomAr " + randomAr);
					//randomUnitsAr.push(randomAr);
					for (var i = 0; i < randomAr.length; i++){
						randomUnitsAr.push(randomAr[i]);
					}
					randomAr = [];
					checkAndRegenerate();
				}
			}
			
			function checkIfGapExists(randomNo){
				//trace("randomNo " + randomNo + " randomAr " + randomAr);
				var no = randomNo;
				for (var i = 0; i < randomAr.length; i++){
					if (randomNo+1 == randomAr[i]){
						return true;
					}
					else if (randomNo-1 == randomAr[i]){
						return true;
					}
				}
				return false;
			}
		}
	}
}