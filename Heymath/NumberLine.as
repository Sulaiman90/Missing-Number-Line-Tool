package Heymath
{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.*;
	import flash.filters.*
	import flash.text.*;
	
	public class NumberLine extends Main
	{
		
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
		
		var scaleStartingValue = 0;
		var scaleEndingValue = 0;
		var intervalNo = 1;
		
		var unitGap = [60, 100]; // 0th value upto 3 digits & 1st value for more than 3 digits
		var scrollSpeed = [30, 60];
		
		var minDisplayUnitsAr = [7, 4];
		var minDisplayUnits = minDisplayUnitsAr[0];
		
		var unitGapValue;
		var scaleShowVal;
		var intervalVal;
		var fourDigitNoEntered = false;
		var displayUnits = 0; // max total units can visible in screen
		var visibleUnits = 0; // units visible in screen
		
		var textGrayColorFormat = new TextFormat();
		var textBlackColorFormat = new TextFormat();
		
		var scaleDraw;
		var randomUnitsAr = [];
		
		public function NumberLine()
		{
			trace("NumberLine ");
		}
		
		public function initNumberLine(mc, _scaleDraw)
		{
			trace("initNumberLine " + mc.name, mc.toolArea.name);
			mainMov = mc;
			toolArea = mainMov.toolArea;
			scaleDraw = _scaleDraw;
			initFun();
		}
		
		function initFun()
		{
			mainMov.toolArea.visible = false;
			addEvents();
			
			mainMov.intro.visible = false;
			initScale();
			
			toolArea.findTxt_txt.addEventListener(KeyboardEvent.KEY_DOWN, handler); 	// testing purpose
			
			function handler(e:KeyboardEvent)
			{
				// if the key is ENTER
				if (e.charCode == 13)
				{
					// your code here
					findNoBtnHandler(e);
				}
			}
		}
		
		function initScale()
		{
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
			
			enableInputText(toolArea.startNo_txt, 5 , true);
			enableInputText(toolArea.interval_txt, 2 , false);
			enableInputText(toolArea.findTxt_txt, 5, true);
			
			scrollTrackUnit = STAGE_WIDTH / (TOTAL_UNITS - 1);
			
			createScale(); // testing purpose
			
			toolArea.visible = true;
			
			toolArea.arrowMc.visible = false;
		}
		
		function findNoBtnHandler(e)
		{
			
			toolArea.arrowMc.visible = true;
			
			var findTxtNo = Number(toolArea.findTxt_txt.text);	
			
			//trace("fourDigitNoEntered " + fourDigitNoEntered,maxScaleNum,scaleEndingValue);
			
			var minScaleValue = scaleStartingValue;
			var maxScaleValue = scaleEndingValue;
			
			// calculated to not move the scale and move only the arrow
			var minScaleLimit = scaleStartingValue + (minDisplayUnits * intervalNo);
			var maxScaleLimit = scaleEndingValue - ((minDisplayUnits * intervalNo));
			
			// scale difference pos
			var scaleGapVal;
			scaleGapVal = Math.abs(scaleStartingValue - findTxtNo);
			
			var findVal = findTxtNo;
			
			trace("---------------");
			trace("findTxtNo,minDisplayUnits " + findTxtNo, minDisplayUnits);
			trace(":minScaleValue: " + minScaleValue + " maxScaleValue: " + maxScaleValue);
			trace(":minScaleLimit: " + minScaleLimit + " maxScaleLimit: " + maxScaleLimit);
			trace(":scaleGapVal: " + scaleGapVal + " scaleStartingValue: " + scaleStartingValue + " scaleEndingValue: " + scaleEndingValue);
			trace(" findVal " + findVal );
			
			var arrowXPos;
			var lineScaleX;
			var scaleIntervalNo;
			
			if (findTxtNo >= minScaleValue && findTxtNo <= maxScaleValue)
			{
				if (findTxtNo > scaleStartingValue)
				{
					intervalVal = ((findTxtNo - scaleStartingValue) / intervalNo) - minDisplayUnits;
				}
				// find the interval value (0 - 100)
				scaleIntervalNo = Math.abs(findTxtNo - scaleStartingValue) / intervalNo;
				
				trace("within scale:intervalVal " + intervalVal + " scaleIntervalNo " + scaleIntervalNo);
				
				// move the line scale
				if (findTxtNo >= minScaleLimit && findTxtNo <= maxScaleLimit)
				{
					trace("findtxt within scale");
					lineScaleX = 0 - ((scaleIntervalNo * unitGapValue) - (minDisplayUnits * 50));
				}
				else if (findTxtNo >= maxScaleLimit)
				{
					trace("findtxt > scale");
					lineScaleX = 0 - (((TOTAL_UNITS - minDisplayUnits) * unitGapValue) - (minDisplayUnits * 50));
				}
				else if (findTxtNo <= minScaleLimit)
				{
					trace("findtxt <= scale");
					lineScaleX = 0;
				}
				toolArea.lineMc.x = lineScaleX;
				
				// move scroll face 	
				if (intervalVal < 0)
				{
					intervalVal = 0;
					toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT;
				}
				else if (intervalVal == 0)
				{
					toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT;
				}
				else 
				{
					moveScrollFace(findTxtNo);
				}
				
				moveArrowMc(scaleIntervalNo);
				
				trace("findTxtNo " + findTxtNo + " arrowXPos " + arrowXPos + " lineScaleX " + lineScaleX);			
			}
			else if (findTxtNo > maxScaleLimit)
			{
				trace(" find value gone after");
				
				scaleStartingValue = findTxtNo - (50 * intervalNo);
				scaleDraw.removeAddedChilds();
				createScale();
				moveScrollFace(findTxtNo);
				
				scaleIntervalNo = Math.abs(findTxtNo - scaleStartingValue) / intervalNo;
				lineScaleX = 0 - ((scaleIntervalNo * unitGapValue) - (minDisplayUnits * 50));
				toolArea.lineMc.x = lineScaleX;
				trace("lineScaleX,scaleIntervalNo " + lineScaleX, scaleIntervalNo,unitGapValue);
				
				arrowXPos = STAGE_WIDTH / 2;
				//trace("findTxtNo,arrowXPos " + findTxtNo,arrowXPos);
				if (fourDigitNoEntered)
				{
					arrowXPos = arrowXPos - 50;
				}
				toolArea.arrowMc.x = arrowXPos;
				
				checkScaleValue();
			}
			else if (findVal < minScaleValue)
			{
				// remove the present scale 
				scaleDraw.removeAddedChilds();
				
				// check if the scale should start from zero
				var val = findTxtNo - scaleStartingValue - (50 * intervalNo);
				trace("find value gone before:val " + val);
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
						trace("if");
						// create the scale again
						createScale();
						
						// move the scroll Face
						intervalVal = ((findTxtNo - scaleStartingValue) / intervalNo) - minDisplayUnits;				
						trace("create scale again:val2 " + val2 + " intervalVal " + intervalVal);
						
						if (intervalVal <= 0){
							intervalVal = 0;
							toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT;
						}
						else{
							moveScrollFace(findTxtNo);
						}
						
						// move line scale
						scaleIntervalNo = Math.abs(findTxtNo - scaleStartingValue) / intervalNo;
						lineScaleX = 0 - ((scaleIntervalNo * unitGapValue) - (minDisplayUnits * 50));
						trace("scaleIntervalNo " + scaleIntervalNo);
						if (lineScaleX > 0){
							lineScaleX = 0;
						}
						toolArea.lineMc.x = lineScaleX;
						
						trace("findTxtNo " + findTxtNo + " lineScaleX " + lineScaleX);
					}
					else{
						trace("else:start scale from zero");	
						scaleStartingValue = findTxtNo - (50 * intervalNo); // calculate scaleStarting value
						trace("scaleStartingValue " + scaleStartingValue);
						createScale();  // 
						scaleIntervalNo = (findTxtNo - scaleStartingValue) / intervalNo;
						lineScaleX = 0 - ((scaleIntervalNo * unitGapValue) - (minDisplayUnits * 50));
						trace("scaleIntervalNo " + scaleIntervalNo + " lineScaleX "+lineScaleX);		
						toolArea.lineMc.x = lineScaleX;
						moveScrollFace(findTxtNo);
					}
				
					// arrow pos calc	
					var findTxtMinLimit = minDisplayUnits;
					var findTxtMaxLimit = TOTAL_UNITS - minDisplayUnits;
					trace("findTxtMinLimit " + findTxtMinLimit + " findTxtMaxLimit " + findTxtMaxLimit);
					
					// arrow x calculation 	
					if (scaleIntervalNo >= findTxtMinLimit && (scaleIntervalNo <= findTxtMaxLimit)){
						// > && < than findTxtMinLimit,findTxtMaxLimit -- make it as center
						trace("moveArrowMc:within scale");
						arrowXPos = STAGE_WIDTH / 2;
					}
					else if (scaleIntervalNo < findTxtMinLimit){
						// < than findTxtMinLimit, make it as center
						trace("moveArrowMc: < min scale limit");
						arrowXPos = SCALE_STARTING_POS_X + 0 + (scaleIntervalNo * unitGapValue);
						if (lineScaleX == 0){
							arrowXPos = arrowXPos + SCALE_LEFT_RIGHT_PADDING;
						}
					}
					else if (scaleIntervalNo > findTxtMaxLimit){
						// move arrow 
						// find the difference between center and findtxt value
						trace("moveArrowMc: > max scale limit");
						var val1 = (STAGE_WIDTH / 2) + ((scaleIntervalNo - (TOTAL_UNITS - minDisplayUnits)) * unitGapValue);
						//trace("val1 " + val1);
						arrowXPos = val1;
					}
					toolArea.arrowMc.x = arrowXPos;
				}
				checkScaleValue();
			}
			
			toolArea.startNo_txt.text = scaleStartingValue;
			if (toolArea.startNo_txt.mouseEnabled){
				toolArea.startNo_txt.setTextFormat(textBlackColorFormat);
			}
			else{
				toolArea.startNo_txt.setTextFormat(textGrayColorFormat);
			}
		}
		
		// check if scale values are greater than 1000
		function checkScaleValue(){
			if (fourDigitNoEntered){
				toolArea.lineMc.x = toolArea.lineMc.x - 50;
			}
		}
		
		function moveScrollFace(_findTxtNo)
		{
			var findTxtNo = _findTxtNo;
			trace("moveScrollFace:findTxtNo " + findTxtNo);
			//trace("moveScrollFace:minDisplayUnits"+minDisplayUnits);
			var scaleIntervalNo = Math.abs(findTxtNo - scaleStartingValue) / intervalNo;
			var sliderXPos;
			if (scaleIntervalNo >= (TOTAL_UNITS - 1 - minDisplayUnitsAr[0]))
			{
				toolArea.scrollFace.x = SCROLL_FACE_ENDING_POINT;
			}
			else
			{
				sliderXPos = (scaleIntervalNo * scrollTrackUnit) - (toolArea.scrollFace.width / 2);
				toolArea.scrollFace.x = sliderXPos;
			}
			//trace("findNoBtnHandler:findNo " + findTxtNo, scaleIntervalNo, sliderXPos, (scaleIntervalNo * scrollTrackUnit) );
			if (sliderXPos < SCROLL_FACE_STARTING_POINT)
			{
				toolArea.scrollFace.x = SCROLL_FACE_STARTING_POINT;
			}
		}
		
		function moveArrowMc(scaleIntervalNo)
		{
			toolArea.arrowMc.visible = true;
			var findTxtMinLimit = minDisplayUnits;
			var findTxtMaxLimit = TOTAL_UNITS - minDisplayUnits;
			trace("findTxtMinLimit " + findTxtMinLimit + " findTxtMaxLimit " + findTxtMaxLimit);
			
			// arrow x calculation 	
			if (scaleIntervalNo >= findTxtMinLimit && (scaleIntervalNo <= findTxtMaxLimit))
			{
				// > && < than findTxtMinLimit,findTxtMaxLimit -- make it as center
				trace("moveArrowMc:within scale");
				arrowXPos = STAGE_WIDTH / 2;
			}
			else if (scaleIntervalNo < findTxtMinLimit)
			{
				// < than findTxtMinLimit, make it as center
				trace("moveArrowMc: < min scale limit");
				arrowXPos = SCALE_STARTING_POS_X + SCALE_LEFT_RIGHT_PADDING + (scaleIntervalNo * unitGapValue);
			}
			else if (scaleIntervalNo > findTxtMaxLimit)
			{
				// move arrow 
				// find the difference between center and findtxt value
				trace("moveArrowMc: > max scale limit");
				var val1 = (STAGE_WIDTH / 2) + ((scaleIntervalNo - (TOTAL_UNITS - minDisplayUnits)) * unitGapValue);
				//trace("val1 " + val1);
				arrowXPos = val1;
			}
			toolArea.arrowMc.x = arrowXPos;
		}
		
		function createScale()
		{
			//trace("createScale:intervalNo " + intervalNo);
			scaleDraw.generateScale();
		}
		
		function resetScale()
		{
			scaleStartingValue = 0;
			intervalNo = 1;
			scaleDraw.removeAddedChilds();
			toolArea.arrowMc.visible = false;
		}
		
		function addEvents()
		{
			mainMov.intro.explore_btn.addEventListener("click", navigateBtnHandler);
			toolArea.home_btn.addEventListener("click", navigateBtnHandler);
			toolArea.create_btn.addEventListener("click", createBtnHandler);
			toolArea.reset_btn.addEventListener("click", resetBtnHandler);
			toolArea.find_btn.addEventListener("click", findNoBtnHandler);
			toolArea.interval_txt.addEventListener("change", onTextChangeHandler);
			
			// hide units buttons;
			var hideMc = toolArea.hideMc;
			hideMc.hide_ran.gotoAndStop(2);
			hideMc.show_all.gotoAndStop(1);
			hideMc.hide_all.gotoAndStop(1);
			
			hideMc.hide_ran.addEventListener("click", unitsBtnHandler);
			hideMc.show_all.addEventListener("click", unitsBtnHandler);
			hideMc.hide_all.addEventListener("click", unitsBtnHandler);
			
			var answerMc = toolArea.answerMc;
			answerMc.revealAnswer.gotoAndStop(1);
			answerMc.typeAnswer.gotoAndStop(1);
			
			answerMc.revealAnswer.addEventListener("click", unitsBtnHandler);
			answerMc.typeAnswer.addEventListener("click", unitsBtnHandler);
		}
		
		function removeEvents()
		{
			mainMov.intro.explore_btn.removeEventListener("click", navigateBtnHandler);
			toolArea.home_btn.removeEventListener("click", navigateBtnHandler);
			toolArea.create_btn.removeEventListener("click", createBtnHandler);
			toolArea.reset_btn.removeEventListener("click", resetBtnHandler);
			toolArea.find_btn.removeEventListener("click", findNoBtnHandler);
			toolArea.interval_txt.removeEventListener("change", onTextChangeHandler);
		}
		
		function unitsBtnHandler(e){
			var mc = e.currentTarget;
			var btnName = mc.name;
				
			if (btnName == "hide_ran" || btnName == "show_all" || btnName == "hide_all"){
				toolArea.hideMc.hide_ran.gotoAndStop(1);
				toolArea.hideMc.show_all.gotoAndStop(1);
				toolArea.hideMc.hide_all.gotoAndStop(1);
			}
			else if (btnName == "revealAnswer" || btnName == "typeAnswer"){
				toolArea.answerMc.revealAnswer.gotoAndStop(1);
				toolArea.answerMc.typeAnswer.gotoAndStop(1);
			}
			
			mc.gotoAndStop(2);
		
			trace("unitsBtnHandler:btnName " + btnName);
			var lineContainerMc = toolArea.lineMc.getChildByName("lineContainer");
			var unitLineMC;
			var lineName;
			if (btnName == "hide_ran"){
				for (var i = 0; i < TOTAL_UNITS; i++){
					lineName =  "unitLine" + i;
					unitLineMC = lineContainerMc.getChildByName(lineName);
					unitLineMC.no_txt.visible = true;
					if (unitLineMC.hide == true){
						unitLineMC.no_txt.visible = false;
					}
				}
			}
			else if (btnName == "show_all"){
				for (i = 0; i < TOTAL_UNITS; i++){
					lineName =  "unitLine" + i;
					unitLineMC = lineContainerMc.getChildByName(lineName);
					unitLineMC.no_txt.visible = true;
				}
			}
			else if (btnName == "hide_all"){
				for (i = 0; i < TOTAL_UNITS; i++){
					lineName =  "unitLine" + i;
					unitLineMC = lineContainerMc.getChildByName(lineName);
					unitLineMC.no_txt.visible = false;
				}
			}
			else if (btnName == "revealAnswer"){
				
			}
			else if (btnName == "typeAnswer"){
				
			}
		}
		
		function createBtnHandler(e)
		{
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
		
		function resetBtnHandler(e)
		{
			enableText(toolArea.startNo_txt);
			enableText(toolArea.interval_txt);
			
			enableButton(toolArea.create_btn);
			disableButton(toolArea.reset_btn);
		}
		
		function navigateBtnHandler(e)
		{
			var name = e.currentTarget.name;
			trace("navigateBtnHandler:name " + name);
			if (name == "explore_btn")
			{
				mainMov.intro.visible = false;
				initScale();
			}
			else if (name == "home_btn")
			{
				toolArea.visible = false;
				resetScale();
				mainMov.intro.visible = true;
			}
		}
		
		function onTextChangeHandler(e)
		{
			if (e.target.text == "")
			{
				intervalNo = 1;
			}
			else
			{
				intervalNo = Number(toolArea.interval_txt.text);
			}
		}
		
		function enableInputText(_refTxt, _maxChars, _minus)
		{
			var refTxt = _refTxt;
			refTxt.maxChars = _maxChars;
			if (_minus){
				refTxt.restrict = "0-9\\-";
			}
			else{
				refTxt.restrict = "0-9";
			}
			//refTxt.regex = /^[*\+\-]?[\d]*\.?[\d]*$/;
			refTxt.addEventListener("focusIn", focusInHandler);
			refTxt.addEventListener("focusOut", focusOutHandler);
			refTxt.addEventListener("change", changeFn);
		}
		
		function changeFn(e){
			/*var final1 = e.currentTarget.text.split(".");
			if(final1.length >= 3){
				e.currentTarget.text = (final1[0]+"."+final1[1]+final1[2]);
			}*/
			
			var final2 = e.currentTarget.text.split("-");
			//trace("final2 "+final2);
			if(final2.length >= 3){
				e.currentTarget.text = (final2[0]+"-"+final2[1]+final2[2]);
			}
		}
	
		function focusInHandler(e)
		{
			e.target.text = "";
		}
		
		function focusOutHandler(evt)
		{
			if (evt.target.text == "")
			{
				if (evt.target.name == "interval_txt")
				{
					evt.target.text = "1";
				}
				else
				{
					evt.target.text = "0";
				}
			}
		}
		
		function disableButton(btn)
		{
			btn.mouseEnabled = false;
			btn.alpha = FADE_VALUE;
		}
		
		function enableButton(btn)
		{
			btn.mouseEnabled = true;
			btn.alpha = 1;
		}
		
		function disableText(txt)
		{
			txt.mouseEnabled = false;
			txt.setTextFormat(textGrayColorFormat);
		}
		
		function enableText(txt)
		{
			//trace("enableText " + txt.name);
			txt.mouseEnabled = true;
			txt.setTextFormat(textBlackColorFormat);
		}
	
	}
}

