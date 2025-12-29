unit SplashUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, splashekran, ExtCtrls, StdCtrls, IniFiles;

type
  TSplashForm = class(TForm)
    ShowTimer: TTimer;
    SplashPNG: TSplashEkran;
    procedure ShowTimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
   Showing:Boolean;
   TransMin, TransMax:Integer;
   CurrentImage:String;
   procedure PopUp(Path:String; Text:String; X, Y:Integer; Font:TFont);
   function ForceForegroundWindow(hwnd: THandle): Boolean;

  end;

var
  SplashForm: TSplashForm;
  I:Integer;

implementation
  uses SFunkeyUnit;

{$R *.dfm}




function TSplashForm.ForceForegroundWindow(hwnd: THandle): Boolean;
const
   SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
   SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
   ForegroundThreadID: DWORD;
   ThisThreadID: DWORD;
   timeout: DWORD;
begin
   if IsIconic(hwnd) then ShowWindow(hwnd, SW_RESTORE);

   if GetForegroundWindow = hwnd then Result := True
   else
   begin
     // Windows 98/2000 doesn't want to foreground a window when some other
     // window has keyboard focus

     if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4)) or
       ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
       ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and
       (Win32MinorVersion > 0)))) then
     begin
       // Code from Karl E. Peterson, www.mvps.org/vb/sample.htm
       // Converted to Delphi by Ray Lischner
       // Published in The Delphi Magazine 55, page 16

       Result := False;
       ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow, nil);
       ThisThreadID := GetWindowThreadPRocessId(hwnd, nil);
       if AttachThreadInput(ThisThreadID, ForegroundThreadID, True) then
       begin
         BringWindowToTop(hwnd); // IE 5.5 related hack
         SetForegroundWindow(hwnd);
         AttachThreadInput(ThisThreadID, ForegroundThreadID, False);
         Result := (GetForegroundWindow = hwnd);
       end;
       if not Result then
       begin
         // Code by Daniel P. Stasinski
         SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
         SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0),
           SPIF_SENDCHANGE);
         BringWindowToTop(hwnd); // IE 5.5 related hack
         SetForegroundWindow(hWnd);
         SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout), SPIF_SENDCHANGE);
       end;
     end
     else
     begin
       BringWindowToTop(hwnd); // IE 5.5 related hack
       SetForegroundWindow(hwnd);
     end;

     Result := (GetForegroundWindow = hwnd);
   end;
end; { ForceForegroundWindow }


procedure TSplashForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if sfTestMode = True then begin
  sfTestMode:= False;
  Exit;
 end;
 if SFunkeyMain.CheckBox3.Checked then begin
   sfOSDPos.x:= SplashForm.Left;
   sfOSDPos.y:= SplashForm.Top;
   SFunkeyMain.SaveSettings;
 end;
end;

procedure TSplashForm.FormCreate(Sender: TObject);
begin
 Showing:= False;
end;

procedure TSplashForm.ShowTimerTimer(Sender: TObject);
begin
 SFunkeyMain.BringToFront;
 ShowWindow(SplashForm.Handle, SW_SHOWNOACTIVATE or SW_SHOWNORMAL);
 ShowTimer.Enabled:= False;
 Showing:= False;
 repeat
  I:= SplashPNG.AlphaDegeri;
  I:= I - sfOSDSpeed;
  SplashPNG.AlphaDegeri:= I;
  SplashPNG.Execute;
  Application.ProcessMessages;
 until (SplashPNG.AlphaDegeri <= sfOSDTransMin) or (Showing = True);
 if Showing = False then Close;
end;





procedure TSplashForm.PopUp(Path:String; Text:String; X, Y:Integer; Font:TFont);
begin
 if (sfShowOSD = '0') or not FileExists(Path) then Exit;
  ShowTimer.Enabled:= False;
  ShowTimer.Enabled:= True;
  TransMin:= sfOSDTransMin;
  TransMax:= sfOSDTransMax;
  ShowTimer.Interval:= sfOSDFadeOutDelay;

//  ShowWindow(SFunkeyMain.Handle, SW_SHOWNOACTIVATE or SW_SHOWNORMAL);

 //if CurrentImage <> Path then begin
  CurrentImage:= Path;
  SplashPNG.LoadImage(Path, Text, x, y, Font);

// end;

 Show;
 SFunkeyMain.BringToFront;
 BringToFront;
 ShowWindow(SplashForm.Handle, SW_SHOWNOACTIVATE or SW_SHOWNORMAL);  ///SNOTE: Brings window to top without activating
 //ForceForegroundWindow(handle);
 // BringWindowToTop(handle);

 if sfRememberOSD = '1' then begin
  SplashForm.Left:= sfOSDPos.X;
  SplashForm.Top:= sfOSDPos.Y;
 end;


 if not Showing then begin
  Showing:= True;
  repeat
   I:= SplashPNG.AlphaDegeri;
   I:= I + sfOSDSpeed;
   SplashPNG.AlphaDegeri:= I;
   SplashPNG.Execute;
   SFunkeyMain.BringToFront;
   SFunkeyMain.SetFocus;
    BringWindowToTop(SFunkeyMain.handle);
   ShowWindow(SplashForm.Handle, SW_SHOWNOACTIVATE or SW_SHOWNORMAL);
   Application.ProcessMessages;
  until (I >= sfOSDTransMax);
 end;
  SFunkeyMain.BringToFront;
  SFunkeyMain.SetFocus;
  BringWindowToTop(SFunkeyMain.handle);
  ShowWindow(SplashForm.Handle, SW_SHOWNOACTIVATE or SW_SHOWNORMAL);  ///SNOTE: Brings window to top without activating
 //ForceForegroundWindow(handle);
 //BringWindowToTop(handle);


end;

end.
