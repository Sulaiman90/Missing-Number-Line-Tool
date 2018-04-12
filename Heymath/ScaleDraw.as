package Heymath
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	public class ScaleDraw extends NumberLine
	{
		
		var slider;
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
			resetVars();
			initNumberLine(_rootMain, this);
		}
		
		function resetVars(){
			totalRightCnt = 0;
			totalDisplayUnits = 0;
		}
		
		public function generateScale()
		{
			trace("generateScale ");
			
			var startingPointX = SCALE_STARTING_POS_X;
			var startingPointY = SCALE_STARTING_POS_Y;
			var scrollSpeedValue;
			
			var scaleEndVal = scaleStartingValue + (TOTAL_UNITS * intervalNo) - intervalNo;
			
			// set scaleEndingValue
			scaleEndingValue = scaleEndVal;
			
			//trace("intervalNo " + intervalNo,toolArea.name);
			
			if (intervalNo < 6)
			{
				unitGapValue = unitGap[0];
			}
			else
			{
				unitGapValue = (intervalNo * 10) + (60 - 50); // change according to unitGapValue
			}
			
			// total units present in screen
			displayUnits = Math.round((STAGE_WIDTH - (SCALE_LEFT_RIGHT_PADDING * 2)) / unitGapValue);
			visibleUnits = Math.floor(displayUnits/3);
			
			trace("unitGapValue "+unitGapValue +" displayUnits "+displayUnits  +" visibleUnits "+visibleUnits);
			
			scrollSpeedValue = scrollSpeed[0];
			var totalScaleWidth = (unitGapValue * (TOTAL_UNITS - 1) + (SCALE_LEFT_RIGHT_PADDING * 2));	
			//trace("totalScaleWidth "+totalScaleWidth,unitGapValue,TOTAL_UNITS,(unitGapValue * (TOTAL_UNITS-1) +  SCALE_LEFT_RIGHT_PADDING));
			
			var scaleEndPos = SCALE_STARTING_POS_X + totalScaleWidth;
			
			toolArea.lineMc.leftArrow.x = startingPointX;
			toolArea.lineMc.rightArrow.x = scaleEndPos;
			
			//trace("startingPoint " + startingPointX, startingPointY, scaleEndPos,);
			//trace("scaleEndVal " + scaleEndVal);
			
			var lineContainer = new MovieClip();
			lineContainer.name = "lineContainer";
			toolArea.lineMc.addChild(lineContainer);
			
			var lineShape = new Shape();
			lineShape.graphics.lineStyle(2, LINE_COLOR, 1);
			lineShape.graphics.moveTo(startingPointX, startingPointY);
			lineShape.graphics.lineTo(scaleEndPos, startingPointY);
			lineShape.name = "line";
			
			lineContainer.addChild(lineShape);
			toolArea.lineMc.addChild(toolArea.lineMc.leftArrow);
			toolArea.lineMc.addChild(toolArea.lineMc.rightArrow);
			
			// genreate random numbers to hide the units
			generateRandomNos();
			
			randomUnitsAr.sort(compareNumbers); 
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
				unitLineMC.hide = false;
				unitLineMC.box.visible = false;
				unitLineMC.tick.visible = false;
				//trace("ii " + i,isInArray((i), randomUnitsAr) );
				if (isInArray(i, randomUnitsAr)){
					unitLineMC.no_txt.text = "?";
					unitLineMC.hide = true;
					unitLineMC.box.visible = true;
					
					var refTxt = unitLineMC.no_txt;
					refTxt.maxChars = 5;
					refTxt.restrict = "0-9\\-";
					refTxt.addEventListener("focusIn", focusInNoHandler);
					refTxt.addEventListener("focusOut", focusOutNoHandler);
					refTxt.addEventListener("change", changeFn);
					unitLineMC.tick.visible = true;
					unitLineMC.tick.gotoAndStop("none");
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
					}
				}
			}
			
			slider = new CustomScrollPane(toolArea.parent, toolArea.lineMc, toolArea.scrollTrack, toolArea.scrollFace, toolArea.btnLeft, toolArea.btnRight, scrollSpeedValue, MASK_WIDTH);
			
			// added for testing purpose only		
			toolArea.txt1.text = scaleStartingValue;
			toolArea.txt2.text = scaleEndVal;
			
			// set movieclip state after creating new scale
			resetUnitOptionBtns(1);
			resetUnitOptionBtns(2);
			toolArea.hideMc.hide_ran.gotoAndStop(2);
			
			// add a checkbtn to scale
			check_btn = new checkBtn();
			lineContainer.addChild(check_btn);
			
			check_btn.addEventListener("click", checkBtnHandler);
			check_btn.visible = false;
			check_btn.y = -25;
			
		/*trace("createScale:minScaleValue,maxScaleValue " +  (scaleStartingValue+(minDisplayUnits*intervalNo)),
		   (scaleEndVal - (minDisplayUnits*intervalNo) - 1));*/
		}
		
		function validationCheck(){
			var txtStr = selectedBox.no_txt.text;
			var ansStr = selectedBox.val;
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
				selectedBox.tick.gotoAndStop("wrong");
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
			validationCheck();
		}
		
		function removeAddedChilds(){
			var lineContainerMc = toolArea.lineMc.getChildByName("lineContainer");
			//trace("removeAddedChilds " + lineContainerMc.numChildren);
			toolArea.lineMc.removeChild(lineContainerMc);
			slider.removeAllEvents();
		}
		
		// generate random numbers for scale units
		function generateRandomNos(){
			var startNo = 1;
			var endNo = displayUnits;
			
			var randomAr = [];
			randomUnitsAr = [];
			var randomNo;
			var loopTaken = 0;
			
			totalDisplayUnits = (Math.round(100 / displayUnits)) * visibleUnits;
			var noOfTimes = (Math.round(100 / displayUnits));
			
			//trace("totalDisplayUnits " + totalDisplayUnits);
			
			generate();			
			
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
							//trace("gap not exists");
							randomAr.push(randomNo);
						}
						else{
							//trace("gap exists");
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