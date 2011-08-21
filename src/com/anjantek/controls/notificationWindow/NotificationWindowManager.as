package com.anjantek.controls.notificationWindow
{
	import com.anjantek.controls.notificationWindow.events.NotificationWindowEvent;
	
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;

	public class NotificationWindowManager
	{
		public function NotificationWindowManager()
		{
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		public static const SMOKE: String = "smoke";
		public static const MUSIC_VIDEO: String = "music_video";
		
		//----------------------------------------------------------------------------------------------------------
		
		public static const CROSS_CLICKED: String = "cross_clicked";
		
		//----------------------------------------------------------------------------------------------------------
		
		private static var notification_window: NotificationWindow;
		
		private static var is_popup_being_shown: Boolean;
		
		private static function Create_Notification( title: String, 
													 status_message: String, 
													 show_close_button: Boolean, 
													 auto_close_delay: Number,
													 _close_notification_target: UIComponent,
													 textAlign: String ): void
		{
			// Create a modal TitleWindow container.
			if( !is_popup_being_shown )
			{
				notification_window = new NotificationWindow();
				
				notification_window.title = title;
				notification_window.statusMessage = status_message;
				notification_window.showCloseButton = show_close_button;
				notification_window.textAlign = textAlign;
				notification_window.auto_close_delay = auto_close_delay;
				
				PopUpManager.addPopUp( notification_window, DisplayObject( FlexGlobals.topLevelApplication ), false );
				is_popup_being_shown = true;
			}
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		private static var close_notification_target: UIComponent;
		
		public static function Show_Notification( title: String = "Pat yourself on the back!", 
										   //state: String = SMOKE, 
										   status_message: String = "Everything went fine.", 
										   show_close_button: Boolean = true, 
										   auto_close_delay: Number = 3000,
										   _close_notification_target: UIComponent = null,
										   textAlign: String = TextAlign.CENTER ): void
		{
			if( !is_popup_being_shown )
			{
				Create_Notification( title, status_message, show_close_button, auto_close_delay, _close_notification_target, textAlign);
			}
			else
			{
				//notification_window.currentState = state;
				notification_window.title = title;
				notification_window.statusMessage = status_message;
				notification_window.showCloseButton = show_close_button;
				notification_window.textAlign = textAlign;
				notification_window.auto_close_delay = auto_close_delay;
				notification_window.Restart_Timer();
			}
			
			close_notification_target = _close_notification_target;
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		public static function Hide_Notification():void
		{
			Close_Popup_And_Dispatch_Event();
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		public static function Cross_Clicked(): void
		{
			Close_Popup_And_Dispatch_Event( CROSS_CLICKED );
		}
		
		//----------------------------------------------------------------------------------------------------------
		
		private static function Close_Popup_And_Dispatch_Event( button_clicked: String = "" ): void
		{
			var notification_window_event: NotificationWindowEvent = new NotificationWindowEvent( NotificationWindowEvent.CLOSE, button_clicked );
			
			if( is_popup_being_shown )
			{
				PopUpManager.removePopUp( notification_window );
				is_popup_being_shown = false;
				
				if( close_notification_target != null )
				{
					close_notification_target.dispatchEvent( notification_window_event );
				}
			}
		}
		
		//----------------------------------------------------------------------------------------------------------
		
	}
}