using Godot;
using System;
using System.Runtime.InteropServices;

public partial class ClickThrough : Node
{
	[DllImport("user32.dll")]
	private static extern IntPtr GetActiveWindow();

	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hwnd, int nIndex, int dwNewLong);

	[DllImport("user32.dll")]
	private static extern int GetWindowLong(IntPtr hwnd, int nIndex);

	[DllImport("user32.dll")]
	private static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

	private const int GWL_EXSTYLE = -20;
	private const int WS_EX_LAYERED = 0x80000;
	private const int WS_EX_TRANSPARENT = 0x20;
	private const uint LWA_ALPHA = 0x2;
	private const uint LWA_COLORKEY = 0x1;

	private IntPtr _hwnd;

	public override void _Ready()
	{
		_hwnd = GetActiveWindow();
		GD.Print("HWND: ", _hwnd);
		SetClickThroughByColorKey();
	}

	public void SetClickThroughByColorKey()
	{
		DisplayServer.WindowSetFlag(DisplayServer.WindowFlags.AlwaysOnTop, true);
		int exStyle = GetWindowLong(_hwnd, GWL_EXSTYLE);
		SetWindowLong(_hwnd, GWL_EXSTYLE, exStyle | WS_EX_LAYERED);
		SetLayeredWindowAttributes(_hwnd, 0, 0, LWA_COLORKEY);
	}

	public void EnableClickThrough()
	{
		int exStyle = GetWindowLong(_hwnd, GWL_EXSTYLE);
		SetWindowLong(_hwnd, GWL_EXSTYLE, exStyle | WS_EX_LAYERED | WS_EX_TRANSPARENT);
	}

	public void DisableClickThrough()
	{
		int exStyle = GetWindowLong(_hwnd, GWL_EXSTYLE);
		SetWindowLong(_hwnd, GWL_EXSTYLE, exStyle & ~WS_EX_TRANSPARENT);
	}
}