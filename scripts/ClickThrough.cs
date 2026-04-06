using Godot;
using System;
using System.Runtime.InteropServices;

public partial class ClickThrough : Node
{
	[DllImport("user32.dll")]
	extern static IntPtr GetActiveWindow();

	[DllImport("user32.dll")]
	extern static int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);

	[DllImport("user32.dll")]
	extern static int SetLayeredWindowAttributes(IntPtr hWnd, uint crKey, byte bAlpha, uint dwflags);

	static readonly IntPtr hWnd = GetActiveWindow();

	const int GWL_EX_STYLE = -20;
	const uint WS_EX_LAYERED = 0x00080000;

	// const uint LWA_ALPHA = 0x00000002;
	const uint LWA_COLORKEY = 0x00000001;

	public void SetAlwaysOnTop(bool value)
	{
    	DisplayServer.WindowSetFlag(DisplayServer.WindowFlags.AlwaysOnTop, value);
    	SetWindowLong(hWnd, GWL_EX_STYLE, WS_EX_LAYERED);
    	SetLayeredWindowAttributes(hWnd, 0, 0, LWA_COLORKEY);
	}
}