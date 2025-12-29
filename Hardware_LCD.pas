unit Hardware_LCD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

const
  FILE_DEVICE_VIDEO = $23;
  METHOD_BUFFERED = 0;
  FILE_ANY_ACCESS = 0;

  IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS =
    FILE_DEVICE_VIDEO shl 16 or $127 shl 2 or
    METHOD_BUFFERED shl 14 or
    FILE_ANY_ACCESS;

  IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS =
  FILE_DEVICE_VIDEO Shl 16 Or $126 Shl 2 Or
    METHOD_BUFFERED Shl 14 Or
    FILE_ANY_ACCESS;

  IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS =
    FILE_DEVICE_VIDEO Shl 16 Or $125 Shl 2 Or
    METHOD_BUFFERED Shl 14 Or
    FILE_ANY_ACCESS;

  DISPLAYPOLICY_AC = 1;
  DISPLAYPOLICY_DC = 2;
  DISPLAYPOLICY_BOTH = 3;
  LCDDeviceFile = '\\.\LCD';

type
  TDisplayBrightness = packed record
    ucDisplayPolicy: Byte;
    ucACBrightness: Byte;
    ucDCBrightness: Byte;
  end;

var
 DisplayPolicy: byte = 0; //UCHAR ?
 SupportedLevels: byte;
 SupportedLevelCount: DWORD = 0;
 LCDHandle: Thandle;
 Brightness: TDisplayBrightness;


 function LCD_Get:Integer;
 function LCD_GetBrightnessLevels:Integer;
 function LCD_GetCurrentBrightness:TDisplayBrightness;
 function LCD_SetBrightness(Value:Integer):Boolean;

implementation


function LCD_Get(): integer;
begin
  LCDHandle:= CreateFile(LCDDeviceFile, FILE_ANY_ACCESS, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  //check handle:
  if LCDHandle = INVALID_HANDLE_VALUE then
  begin
    ShowMessage('An error occurred opening the LCD device');
    exit;
  end
  else result:= LCDHandle;
end;

function LCD_GetBrightnessLevels(): integer;
begin
 ZeroMemory(@SupportedLevels, sizeof(SupportedLevels));
 LCDHandle:= LCD_Get();
	if DeviceIoControl(LCDHandle, IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS, nil, 0, @SupportedLevels, 256, &SupportedLevelCount, nil) then begin
   if SupportedLevelCount = 0 then begin
    ShowMessage('Your video card or driver does not support brightness control.');
    Result:= 0;
    Exit;
   end;
    Result:= SupportedLevelCount;
    CloseHandle(LCDHandle);
  end;
end;

function LCD_GetCurrentBrightness: TDisplayBrightness;
Var
    BufSize: DWORD;
Begin
    LCDHandle:= LCD_Get();
    Try
        BufSize := SizeOf(Result);
        If Not DeviceIoControl(LCDHandle, IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS, Nil, 0, @Result, BufSize, BufSize, Nil) Then
            Exit;
    Finally
        CloseHandle(LCDHandle);
    End;
End;

function LCD_SetBrightness(Value: integer): Boolean;
var
 bytesReturned: DWORD;
begin
	DisplayPolicy:= LCD_GetCurrentBrightness.ucDisplayPolicy;
	if DisplayPolicy = DISPLAYPOLICY_AC then brightness.ucACBrightness:= Value;
	if DisplayPolicy = DISPLAYPOLICY_DC then brightness.ucDCBrightness:= Value;
  LCDHandle:= LCD_Get();
  //check handle:
  if LCDHandle = INVALID_HANDLE_VALUE then
  begin
    ShowMessage('An error occurred opening the LCD device');
    exit;
  end;

  if DeviceIoControl(LCDHandle, IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS, @brightness,
    sizeof(Brightness), nil, 0, bytesReturned, nil) = false then
      //If the operation completes successfully, DeviceIoControl returns a nonzero value.  <> 0 werkt niet...
    ShowMessage('Error, DeviceIoControl returned False');
  CloseHandle(LCDHandle);
end;


end.
