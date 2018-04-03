package Heymath{
	import flash.geom.Point;
	import flash.display.*;

	public class Main extends MovieClip {


		public function duplicateMovie(target,mov):DisplayObject {
			//trace(target)
			var duplicate:DisplayObject = new target();
			mov.parent.addChild(duplicate);
			return duplicate;
		}
	
		public function randomBetween(val1,val2):Number {
			return Math.floor(Math.random() * ((val2+1)-(val1))) + val1;
		}
		
		public function generateRandom(startIndex:int,endIndex:int):Array{    
			var r:int = 0;
			var tempArr:Array = new Array();
			var narr:Array = new Array();
			var limit:int = endIndex - startIndex;
			for(r=startIndex;r<=endIndex;r++)
			{
				narr.push(r);
			}
			for(r=startIndex;r<=endIndex;r++)
			{
				var rand:int = Math.round( Math.random()* (narr.length-1));
				tempArr.push(narr[rand]);
				narr.splice(rand,1);
			}
			return tempArr;
		}

	}
}