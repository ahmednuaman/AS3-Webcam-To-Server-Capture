/**
 * @author			Ahmed Nuaman (http://www.ahmednuaman.com)
 * @langversion		3
 * 
 * This work is licenced under the Creative Commons Attribution-Share Alike 2.0 UK: England & Wales License. 
 * To view a copy of this licence, visit http://creativecommons.org/licenses/by-sa/2.0/uk/ or send a letter 
 * to Creative Commons, 171 Second Street, Suite 300, San Francisco, California 94105, USA.
*/
package
{
	import com.adobe.images.JPGEncoder;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	[SWF( backgroundColor=0xFFFFFF, frameRate=30, height=300, width=320 )]
	
	public class App extends Sprite
	{
		// you won't need to touch these
		public static const CAMERA_BANDWIDTH:Number				= 0;
		public static const CAMERA_QUALITY:Number				= 90;
		
		// set the height and width of the camera below
		public static const CAMERA_HEIGHT:Number				= 240;
		public static const CAMERA_WIDTH:Number					= 320;
		
		// set the URL you want the app to post the bytearray to
		public static const POST_URL:String						= '';
		
		private var button:Sprite;
		private var camera:Camera;
		private var preview:Sprite;
		private var video:Video;
		
		public function App()
		{
			// we check to see if the app and stage are ready
			loaderInfo.addEventListener( Event.INIT, handleInit );
		}
		
		private function handleInit(e:Event):void
		{
			loaderInfo.removeEventListener( Event.INIT, handleInit );
			
			// here we add the camera
			getCamera();
			
			// here we add the button to capture and submit the image
			addButton();
		}
		
		private function getCamera():void
		{
			var index:int = 0;
			
			// here we cycle through the user's cameras so that they don't have to select it
			// this is in case they are video editors, for example, as they may have lots of
			// cameras attached to their computer
			for ( var i:int = 0; i < Camera.names.length; i++ ) 
			{
				if ( Camera.names[ i ] == 'USB Video Class Video' ) 
				{
					index = i;
				}
			}
			
			// so we set the selected camera here
			camera = Camera.getCamera( index.toString() );
			
			
			// we set it up
			camera.setMode( CAMERA_WIDTH, CAMERA_HEIGHT, 20, true );
			camera.setQuality( CAMERA_BANDWIDTH, CAMERA_QUALITY );
			
			// we create a video display object for the camera
			video = new Video( CAMERA_WIDTH, CAMERA_HEIGHT );
			
			video.smoothing	= true;
			
			// attach the camera to the video display object
			video.attachCamera( camera );
			
			
			// add the video display object to the stage so the user can see it
			addChild( video );
		}
		
		private function addButton():void
		{
			// here we just set up the button
			var field:TextField	= new TextField();
			var format:TextFormat = new TextFormat( 'Arial', 10, 0xFFFFFF );
			
			field.autoSize = TextFieldAutoSize.LEFT;
			field.text = 'Capture!';
			
			field.setTextFormat( format );
			
			button = new Sprite();
			
			button.graphics.beginFill( 0x333333 );
			button.graphics.drawRoundRect( 0, 0, 60, 20, 3, 3 );
			button.graphics.endFill();
			
			button.addChild( field );
			
			field.x = ( button.width - field.width ) / 2;
			field.y = ( button.height - field.height ) / 2;
			
			addChild( button );
			
			button.buttonMode = true;
			button.mouseChildren = false;
			button.x = ( stage.stageWidth - button.width ) / 2;
			button.y = stage.stageHeight - button.height - 20;
			
			// and this is the listener that links the button to the function we'll
			// use to send the image
			button.addEventListener( MouseEvent.CLICK, handleButtonClick );
		}
		
		private function handleButtonClick(e:MouseEvent):void
		{
			// this is where the magic happens
			// we set up the request and loader
			var request:URLRequest = new URLRequest();
			var loader:URLLoader = new URLLoader();
			
			// we create the encoder
			var encoder:JPGEncoder = new JPGEncoder( CAMERA_QUALITY );
			
			// we set up the snapshot
			var shot:BitmapData	= new BitmapData( CAMERA_WIDTH, CAMERA_HEIGHT );
			
			
			// we then get the snapshot
			shot.draw( video );
			
			// encode it and build the request
			request.data	= encoder.encode( shot );
			request.method	= URLRequestMethod.POST;
			request.url		= POST_URL + loaderInfo.parameters.v;
			
			// not forgetting to add the headers
			request.requestHeaders.push( new URLRequestHeader( 'Content-type', 'application/octet-stream' ) );
			
			loader.addEventListener( Event.COMPLETE, handleComplete );
			
			// and off the request goes!
			loader.load( request );
		}
		
		private function handleComplete(e:Event):void
		{
			// check if the preview container exists
			if ( preview )
			{
				// if it does, clear it
				preview.removeChildAt( 0 );
			}
			else
			{
				// if it doesn't, create it
				preview	= new Sprite();
				
				addChild( preview );
			}
			
			// build the loader and request
			var loader:Loader		= new Loader();
			var request:URLRequest	= new URLRequest( e.target.data );
			
			// add listener
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, handlePreviewComplete );
			
			// load
			loader.load( request );
		}
		
		private function handlePreviewComplete(e:Event):void
		{
			// get the loader
			var image:Loader	= e.target.loader as Loader;
			
			// adjust its size			
			image.height		= CAMERA_HEIGHT / 4;
			image.width			= CAMERA_WIDTH / 4;
			
			// add it to the stage
			preview.addChild( image );
		}
	}
}