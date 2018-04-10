package Heymath{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;

	public class CustomScrollPane{

		var contentMain,scrollTrackWidth,contentWidth,scrollFaceWidth;
		var maskWidth,maskX,scrollFaceInitPos,initContentPos,finalContentPos;

		var scrollTrack,scrollFace;
		var btnLeft,btnRight;
		var speed = 0;
		var moveVal;
		var xx,yy,ww,hh;
		var currentMov;	
		var sliderState = "";
		var rectangle;
		var stageRef;
		var scrollFaceMaxPosX = 696;
		
		var rootStage;

		public function CustomScrollPane(_stage,_contentMain,_scrollTrack,_scrollFace,_btnLeft,
			_btnRight,_speed,_maskWidth){
			//trace("CustomScrollPane ");	
			contentMain = _contentMain;
			scrollTrack = _scrollTrack;
			scrollFace = _scrollFace;
			btnLeft = _btnLeft;
			btnRight = _btnRight;
			speed = _speed;
			stageRef = _stage;
			maskWidth = _maskWidth;
			rootStage = contentMain.parent.parent;
			initSlider();
		}

		public function initSlider(){
			contentMain.x = 0;
			scrollTrackWidth = scrollTrack.width;
			contentWidth = contentMain.width;
			scrollFaceWidth = scrollFace.width;
			maskX = 0;
			scrollFaceInitPos = scrollFace.x = scrollTrack.x;
			initContentPos = contentMain.x;
			finalContentPos = maskWidth-contentWidth+initContentPos;

			moveVal = (contentWidth-maskWidth)/(scrollTrackWidth-scrollFaceWidth);

			xx = scrollTrack.x;
			yy = scrollTrack.y;
			ww = scrollTrack.width - scrollFaceWidth;
			
			//trace("moveVal "+moveVal,finalContentPos);
			trace("contentWidth "+contentWidth);

			rectangle = new Rectangle(xx,yy,ww,0);
	
			scrollFace.addEventListener(MouseEvent.MOUSE_DOWN,scrollFacePressed);
	
			btnLeft.addEventListener(MouseEvent.MOUSE_DOWN,btnPress);
			btnLeft.addEventListener(MouseEvent.MOUSE_UP,btnRelease);
			btnRight.addEventListener(MouseEvent.MOUSE_DOWN,btnPress);
			btnRight.addEventListener(MouseEvent.MOUSE_UP,btnRelease);

			if (contentWidth<maskWidth) {
				scrollFace.visible = false;
				btnLeft.mouseEnabled = false;
				btnRight.mouseEnabled = false;
			} else {
				scrollFace.visible = true;
				btnLeft.mouseEnabled = true;
				btnRight.mouseEnabled = true;
			}
		}

		function scrollFacePressed(e){
			//trace("scrollFacePressed");
			currentMov = e.currentTarget;
			currentMov.startDrag(false, rectangle);
			currentMov.addEventListener(MouseEvent.MOUSE_MOVE, scrollFaceMoved);
			currentMov.stage.addEventListener(MouseEvent.MOUSE_UP,scrollFaceUp);
		}
		
		function scrollFaceMoved(e){
			//trace("scrollFaceMoved");
			sliderState = "mouseMove";
			stageRef.addEventListener(Event.ENTER_FRAME,moveContent);
		}


		function moveContent(e) {
			//trace("moveContent ");
			if(sliderState=="mouseMove"){
				var dy = Math.abs(scrollFaceInitPos - scrollFace.x);
				//moveVal = (contentWidth-maskWidth)/(scrollTrackWidth-scrollFaceWidth);
				var posX = Math.round(dy*-1*moveVal+initContentPos);
				//trace("moveContent:scrollFace:X "+scrollFace.x +" posX "+posX);
				contentMain.x = posX;
			}
			else if(sliderState=="left"){
				if (contentMain.x + speed < maskX) {
					//trace("left scroll");
					if (scrollFace.x<=xx) {
						scrollFace.x = xx;
					} 
					else {
						scrollFace.x -= speed/moveVal;
					}
					contentMain.x += speed;
				} 
				else {
					//trace("no more left scroll");
					scrollFace.x = xx;
					contentMain.x = maskX;
					stageRef.removeEventListener(Event.ENTER_FRAME,moveContent);
				}
			}
			else if (sliderState == "right"){
				trace("right scroll:speed "+speed,scrollFace.x,scrollFaceMaxPosX,finalContentPos);
				if (contentMain.x - speed > finalContentPos) {
					trace("if ");
					if (scrollFace.x >= scrollFaceMaxPosX) {
						scrollFace.x = scrollFaceMaxPosX;
					} 
					else {
						scrollFace.x += speed/moveVal;
					}
					contentMain.x -= speed;
					trace("contentMain "+contentMain.x);
				} 
				else {
					trace("no more right scroll");
					scrollFace.x = scrollFaceMaxPosX;
					contentMain.x = finalContentPos;
					stageRef.removeEventListener(Event.ENTER_FRAME,moveContent);
				}
				//trace("right scroll "+scrollFace.x,contentMain.x);
			}
			if(scrollFace.x <= xx){
				contentMain.x = initContentPos;
			}
			else if (scrollFace.x >= ww){
				//trace("scroll face limit reached");
				contentMain.x = finalContentPos;
			}
		};

		function scrollFaceUp(e) {
			trace("scrollFaceUp "+scrollFace.x,contentMain.x);
			//MovieClip(root).logMsg("scrollFaceUp");
			currentMov.stopDrag();
			currentMov.stage.addEventListener(MouseEvent.MOUSE_UP,scrollFaceUp);
			stageRef.removeEventListener(Event.ENTER_FRAME, moveContent);
			currentMov.removeEventListener(MouseEvent.MOUSE_MOVE, scrollFaceMoved);
		}

		function btnPress(e) {
			var nameStr = e.currentTarget.name;
			//trace("btnPress:nameStr "+nameStr);
			if(nameStr=="btnLeft"){
				sliderState = "left";
			}
			else if(nameStr=="btnRight"){
				sliderState = "right";
			}
			stageRef.addEventListener(Event.ENTER_FRAME,moveContent);
		}

		function btnRelease(e) {
			var nameStr = e.currentTarget.name;
			//trace("btnRelease:nameStr "+nameStr);
			stageRef.removeEventListener(Event.ENTER_FRAME,moveContent);
		}
		
		public function removeAllEvents(){
			scrollFace.removeEventListener(MouseEvent.MOUSE_DOWN, scrollFacePressed);
			try{
				currentMov.stage.removeEventListener(MouseEvent.MOUSE_UP,scrollFaceUp);
			}
			catch (e){
				
			}
			
			btnLeft.removeEventListener(MouseEvent.MOUSE_DOWN,btnPress);
			btnLeft.removeEventListener(MouseEvent.MOUSE_UP,btnRelease);
			btnRight.removeEventListener(MouseEvent.MOUSE_DOWN,btnPress);
			btnRight.removeEventListener(MouseEvent.MOUSE_UP, btnRelease);	
			stageRef.removeEventListener(Event.ENTER_FRAME, moveContent);
		}

		public function setSliderState(_sliderState){
			sliderState = _sliderState;
		}
	
	}
}