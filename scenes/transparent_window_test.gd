extends Node


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
	var flag_line: String
	if enabled:
		flag_line = "$cur = $cur -bor 0x80020"
	else:
		flag_line = "$cur = $cur -band (-bnot 0x20)"

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
$proc = Get-Process -Id %d
$hwnd = $proc.MainWindowHandle
$cur  = [WinUtil]::GetWindowLong($hwnd, -20)
%s
[WinUtil]::SetWindowLong($hwnd, -20, $cur)
""" % [OS.get_process_id(), flag_line]

	OS.execute("powershell", ["-NoProfile", "-WindowStyle", "Hidden", "-Command", script])
