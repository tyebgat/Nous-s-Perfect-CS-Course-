extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_window()
	_set_click_through(true)


#=================================
# WINDOW SETTINGS
#==================================
func _setup_window() -> void:
	var win := get_window()
	win.borderless = true
	win.transparent = true
	win.always_on_top = true
	win.size = DisplayServer.screen_get_size()
	win.position = Vector2i.ZERO


#=================================
# CLICK THROUGH WINDOW
#==================================
func _set_click_through(enabled: bool) -> void:
	#windows script
	var script := """
	Add-Type @"
	using System;
	using System.Diagnostics;
	using System.Runtime.InteropServices;
	public class WinUtil {
		[DllImport("user32.dll")]
		public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
		[DllImport("user32.dll")]
		public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
	}
"@
	$proc  = Get-Process -Id %d
	$hwnd  = $proc.MainWindowHandle
	$cur   = [WinUtil]::GetWindowLong($hwnd, -20)
	$cur   = $cur -bor 0x80020
	[WinUtil]::SetWindowLong($hwnd, -20, $cur)
	""" % OS.get_process_id()
	if enabled:
		script += "$cur = $cur -bor 0x80020 \n"  # WS_EX_LAYERED | WS_EX_TRANSPARENT
	
	else:
		script += "$cur = $cur -band (-bnot 0x20) \n"  # remove WS_EX_TRANSPARENT only

	script += "[WinUtil]::SetWindowLong($hwnd, -20, $cur)"
	
	OS.execute("powershell", ["-NoProfile", "-WindowStyle", "Hidden", "-Command", script])
