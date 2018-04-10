package Heymath
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	public class ScaleDraw extends NumberLine
	{
		
		var slider;
		
		public function ScaleDraw()
		{
			//trace("ScaleDraw ");
		}
		
		public function initScaleDraw(_rootMain)
		{
			//trace("initScaleDraw ");
			initNumberLine(_rootMain, this);
		}
		
		public function generateScale()
		{
			var startingPointX = SCALE_STARTING_POS_X;
			var startingPointY = SCALE_STARTING_POS_Y;
			var scrollSpeedValue;
			
			//scaleArea.arrowMc.x = 400;
			
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
			scrollSpeedValue = scrollSpeed[0];
			var totalScaleWidth = (unitGapValue * (TOTAL_UNITS - 1) + (SCALE_LEFT_RIGHT_PADDING * 2));	
			//trace("unitGapValue "+unitGapValue);
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
		
		/*trace("createScale:minScaleValue,maxScaleValue " +  (scaleStartingValue+(minDisplayUnits*intervalNo)),
		   (scaleEndVal - (minDisplayUnits*intervalNo) - 1));*/
		}
		
		function removeAddedChilds()
		{
			var lineContainerMc = toolArea.lineMc.getChildByName("lineContainer");
			//trace("removeAddedChilds " + lineContainerMc.numChildren);
			toolArea.lineMc.removeChild(lineContainerMc);
			slider.removeAllEvents();
		}
	
	}
}