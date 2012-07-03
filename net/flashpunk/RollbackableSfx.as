package net.flashpunk {
	import net.flashpunk.Sfx;
	import net.flashpunk.Rollbackable;
	
	public class RollbackableSfx extends Sfx implements Rollbackable {
		//delegate
		public var getStartFrame:Function;
		
		//private vars
		private var startFrame:uint = 0;
		private var shouldPlay:Boolean = false;
		private var shouldPlayVol:Number = 1;
		private var shouldPlayPan:Number = 0;
		private var shouldDelay:Number = 0;
		private var shouldStartFrame:uint = 0;
		
		//datastructure
		internal var next:RollbackableSfx = null;
		
		public function RollbackableSfx(source:*, complete:Function = null, type:String = null) {
			//super
			super(source, complete, type);
		}
		
		override public function play(vol:Number = 1, pan:Number = 0, pos:Number = 0):void {
			shouldStartFrame = getStartFrame();
			shouldPlay = true;
			shouldPlayVol = vol;
			shouldPlayPan = pan;
			shouldDelay = 0;
		}
		
		//stop
		
		//resume
		
		//loop
		
		public function render():void {
			if (shouldPlay && !playing) {
				//play it with delay
				play(shouldPlayVol, shouldPlayPan);
			}else if (!shouldPlay && playing) {
				//stop it
				stop();
			}
		}
		
		public function rollback(orig:Rollbackable):void {
			//cast
			var s:RollbackableSfx = orig as RollbackableSfx;
			
			//rollback
			startFrame = s.startFrame;
			shouldPlay = s.shouldPlay;
			shouldPlayVol = s.shouldPlayVol;
			shouldPlayPan = s.shouldPlayPan;
			shouldDelay = s.shouldDelay;
			shouldStartFrame = s.shouldStartFrame;
		}
	}
}