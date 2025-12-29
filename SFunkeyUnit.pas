unit SFunkeyUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Spin, ComCtrls, XPMan, Registry, IniFiles, ShellAPI,
  pngimage, Menus, ImgList, ShutdownUnit, Grids, ValEdit, Contnrs, FileCtrl, Hardware_LCD,
  Buttons, System_Process, System.ImageList;



type
  TSFunkeyMain = class(TForm)
    Delayer: TTimer;
    TrayIcon1: TTrayIcon;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    XPManifest1: TXPManifest;
    Memo1: TMemo;
    Donate: TImage;
    Image1: TImage;
    PopupMenu1: TPopupMenu;
    DisableSfunkey1: TMenuItem;
    Close1: TMenuItem;
    ImageList1: TImageList;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label20: TLabel;
    TabSheet3: TTabSheet;
    ListView1: TListView;
    ComboBox15: TComboBox;
    GroupBox2: TGroupBox;
    CheckBox3: TCheckBox;
    Label3: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    SpinEdit3: TSpinEdit;
    SpinEdit2: TSpinEdit;
    CheckBox4: TCheckBox;
    GroupBox3: TGroupBox;
    CheckBox7: TCheckBox;
    ListView2: TListView;
    GroupBox4: TGroupBox;
    CheckBox2: TCheckBox;
    Label2: TLabel;
    ComboBox13: TComboBox;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    CheckBox1: TCheckBox;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    Label24: TLabel;
    ComboBox16: TComboBox;
    ScreenCheck: TTimer;
    Button1: TButton;
    Button2: TButton;
    FileDialog: TFileOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DelayerTimer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure ComboBox13Select(Sender: TObject);
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DonateClick(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBox15Select(Sender: TObject);
    procedure ScreenCheckTimer(Sender: TObject);
    procedure ComboBox16Select(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DisableSfunkey1Click(Sender: TObject);
    procedure CheckBox2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox4MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox7MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
  public


   CurrentMSG:Integer;
   CommandList:TStringList;
   UsingSfunkey:Boolean;

   procedure SaveSetting(Ident, Value:String);

   function ReadRegistry(Root:Integer; Section:String; Key:String):String;
   procedure RunOnStartup(const sCmdLine: string; bRunOnce: boolean = false; Remove: Boolean = false);
   procedure EnableF12(Value:Boolean = True);
   function  F12Enabled:Boolean;
   procedure ApplicationMinimize(Sender:TObject);
   procedure WMHotkey(var msg:TWMHotkey); message WM_HOTKEY;


    procedure Appmessage(var Msg: TMsg; var Handled: Boolean);


   procedure LoadSettings;
   procedure Localize;
   procedure InitializeKeys;
   procedure SaveSettings;
   function  GetActionID(IDX:Integer):String;
   procedure Disable;
   procedure Enable;
   function  ApplicationRunning:Boolean;
  end;

type
 TKeyData = class (TObject)
  public
   kdID:String;
   kdKey:Cardinal;
   kdEnabled:Boolean;
   kdAction:String;
   kdCaption:String;
  constructor Create;
  destructor Destroy; override;
  function RegisterKey:Boolean;
  function UnRegisterKey:Boolean;
  procedure DoAction;
  procedure SetAction(Action:String);
  procedure Localize;
 end;





var
 SFunkeyMain: TSFunkeyMain;
   Dir:String;
   sfEnabled:Integer;
   sfLanguage:String;
   sfTheme:String;
   sfDisableInApplications:String;
   sfRepeatDelay:Integer;
   sfShowOSD:String;
   sfRememberOSD:String;
   sfOSDPos:TPoint;
   sfOSDFadeOutDelay:Integer;
   sfOSDSpeed:Integer;
   sfOSDTransMin:Integer;
   sfOSDTransMax:Integer;
   sfAppList:TStringList;
   kdList:TObjectList;
   sfLCDMax:Integer;
   sfLCDCurrent:Integer;
   sfButtonPressed:Boolean;
   sfProcessList:TStringList;
   sfRebootMsg1:String;
   sfRebootMSG2:String;
   sfEnable, sfDisable:String;
   sfFont:TFont;
   sfTextX, sfTextY:Integer;
   sfTest:String;

   sfTaskMgr, sfSleep, sfLCDUp, sfLCDDown, sfConnect, sfLCDOff, sfLCDStand, sfLock, sfVolUp, sfVolDown, sfVolMut,
   sfTrackPrev, sfTrackNext, sfPlay, sfEnText, sfDisText, sfRestart, sfTurnOff, sfLogOff :String;
   sfTestMode:Boolean;
   sfRestoreApps:Boolean;
   Item:TListItem;
   SubitemIDX:Integer;
   sfLoaded:Boolean;







implementation

uses SplashUnit, commctrl;

{$R *.dfm}






constructor TKeyData.Create;
begin
 inherited;
 kdID:= '';
 kdKey:= 0;
 kdEnabled:= True;
 kdAction:='Unknown';
 kdCaption:='Unknown';
 IntToStr(kdKey)
end;


destructor TKeyData.Destroy;
begin
 UnRegisterKey;
 inherited;
end;


function TKeyData.RegisterKey:Boolean;
begin
 Result:= False;
 if sfEnabled = 0 then Exit;
 //if kdEnabled then
 Result:= RegisterHotKey(SFunkeyMain.Handle, kdKey, 0, kdKey);
end;

// RegisterHotKey(Handle, 104020 , MOD_CONTROL, ord ('1')





function TKeyData.UnRegisterKey:Boolean;
begin
 UnRegisterHotKey(SFunkeyMain.Handle, kdKey);
end;


function ExtractTopFolder(Path:String):String;
var
 LastPath:String;
begin
 Result:= '';
 LastPath:= ExcludeTrailingBackslash(Path);
 if FileExists(Path) then LastPath:= ExcludeTrailingBackslash(ExtractFilePath(Path));
 Delete(LastPath, 1, LastDelimiter('\', LastPath));
 Result:= LastPath;
end;



procedure TKeyData.DoAction;
var
 Brightnes:Integer;
begin
 if kdAction = 'TaskManager' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\TaskManager.png', sfTaskMgr, sfTextX, sfTextY, sfFont);
  ShellExecute (HWND(nil), 'open', 'taskmgr', '', '', SW_SHOWNORMAL);
 end;
 if kdAction = 'Sleep' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Sleep.png', sfSleep, sfTextX, sfTextY, sfFont);
  Sleep(3000);
  winexec(PAnsichar('rundll32.exe powrprof.dll,SetSuspendState'),sw_Show);
 end;
 if kdAction = 'LCDBrightnessDown' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\BrightnessDown.png', sfLCDDown, sfTextX, sfTextY, sfFont);
  sfLCDMax:= LCD_GetBrightnessLevels div 2;
  sfLCDCurrent:= LCD_GetCurrentBrightness.ucDCBrightness div 10;
  Brightnes:= (sfLCDCurrent - 1) * 10;
  if (sfLCDCurrent - 1) <= 0 then Brightnes:= 1 * 10;
  LCD_SetBrightness(Brightnes);
 end;
 if kdAction = 'LCDBrightnessUp' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\BrightnessUp.png',  sfLCDUp, sfTextX, sfTextY, sfFont);
  sfLCDMax:= LCD_GetBrightnessLevels div 2;
  sfLCDCurrent:= LCD_GetCurrentBrightness.ucDCBrightness div 10;
  Brightnes:= (sfLCDCurrent + 1) * 10;
  if (sfLCDCurrent + 1) >= sfLCDMax then Brightnes:= sfLCDMax * 10;
  LCD_SetBrightness(Brightnes);
 end;
 if kdAction = 'ConnectDisplay' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Connect.png',  sfConnect, sfTextX, sfTextY, sfFont);
  Keybd_event(VK_LWIN,   0, 0, 0);
  Keybd_event(Byte('P'), 0, 0, 0);
  Keybd_event(Byte('P'), 0, KEYEVENTF_KEYUP, 0);
  Keybd_event(VK_LWIN,   0, KEYEVENTF_KEYUP, 0);
 end;
 if kdAction = 'LockPC' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Lock.png',  sfLock, sfTextX, sfTextY, sfFont);
  Sleep(1000);
  LockWorkStation;
 end;

 if kdAction = 'RestartPC' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Restart.png',  sfRestart, sfTextX, sfTextY, sfFont);
  Sleep(2000);
  WindowsExit(EWX_REBOOT or EWX_FORCE);
 end;
 if kdAction = 'TurnOffPC' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\TurnOff.png',  sfTurnOff, sfTextX, sfTextY, sfFont);
  Sleep(2000);
  WindowsExit(EWX_SHUTDOWN or EWX_FORCE);
 end;
 if kdAction = 'LogOff' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\LogOff.png',  sfLogOff, sfTextX, sfTextY, sfFont);
  Sleep(2000);
  WindowsExit(EWX_LOGOFF or EWX_FORCE);
 end;

 if kdAction = 'VolumeMute' then begin
  keybd_event(VK_VOLUME_MUTE, 0, 0, 0);
  keybd_event(VK_VOLUME_MUTE, 0, KEYEVENTF_KEYUP, 0);
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Mute.png',  sfVolMut, sfTextX, sfTextY, sfFont);
 end;
 if kdAction = 'VolumeDown' then begin
  keybd_event(VK_VOLUME_DOWN, 0, 0, 0);
  keybd_event(VK_VOLUME_DOWN, 0, KEYEVENTF_KEYUP, 0);
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\VolDown.png',  sfVolDown, sfTextX, sfTextY, sfFont);
 end;
 if kdAction = 'VolumeUp' then begin
  keybd_event(VK_VOLUME_UP, 0, 0, 0);
  keybd_event(VK_VOLUME_UP, 0, KEYEVENTF_KEYUP, 0);
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\VolUp.png',  sfVolUp, sfTextX, sfTextY, sfFont);
 end;
 if kdAction = 'PreviousTrack' then begin
  keybd_event(VK_MEDIA_PREV_TRACK, 0, 0, 0);
  keybd_event(VK_MEDIA_PREV_TRACK, 0, KEYEVENTF_KEYUP, 0);
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Previous.png',  sfTrackPrev, sfTextX, sfTextY, sfFont);
 end;
 if kdAction = 'Play/Pause' then begin
  keybd_event(VK_MEDIA_PLAY_PAUSE, 0, 0, 0);
  keybd_event(VK_MEDIA_PLAY_PAUSE, 0, KEYEVENTF_KEYUP, 0);
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Play.png',  sfPlay, sfTextX, sfTextY, sfFont);
 end;
 if kdAction = 'NextTrack' then begin
  keybd_event(VK_MEDIA_NEXT_TRACK, 0, 0, 0);
  keybd_event(VK_MEDIA_NEXT_TRACK, 0, KEYEVENTF_KEYUP, 0);
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Next.png',  sfTrackNext, sfTextX, sfTextY, sfFont);
 end;
 if kdAction = 'DisplayPowerOff' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\DisplayOff.png',  sfLCDOff, sfTextX, sfTextY, sfFont);
  Sleep(2000);
  SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MONITORPOWER, 2);
 end;
 if kdAction = 'DisplayStandBy' then begin
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\DisplayOff.png',  sfLCDStand, sfTextX, sfTextY, sfFont);
  Sleep(2000);
  SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MONITORPOWER, 1);
 end;
 if (FileExists(kdAction)) then begin
  ShellExecute (HWND(nil), 'open', PChar(kdAction), '', '', SW_SHOWNORMAL);
  if FileExists(Dir + '\Themes\' + sfTheme + '\' + ExtractFileName(kdAction) + '.png') then
   SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\' + ExtractFileName(kdAction) + '.png', ChangeFileExt(ExtractFileName(kdAction), ''), sfTextX, sfTextY, sfFont) else
    SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Run.png', ChangeFileExt(ExtractFileName(kdAction), ''), sfTextX, sfTextY, sfFont);
 end;
 if (DirectoryExists(kdAction)) then begin
  ShellExecute (HWND(nil), 'open', PChar(kdAction), '', '', SW_SHOWNORMAL);
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\Folder.png',  ExtractTopFolder(kdAction), sfTextX, sfTextY, sfFont);
 end;

end;


procedure TKeyData.SetAction(Action:String);
var
 I:Integer;
 Folder:String;
 Settings:TIniFile;
begin
 if Action = 'OpenFile' then begin
  if SFunkeyMain.FileDialog.Execute then begin
   Action:= SFunkeyMain.FileDialog.FileName;
  end;
 end;
 if Action = 'OpenFolder' then begin
  if SelectDirectory('Select a directory', '', Folder) then begin
   if Folder <> '' then Action:= Folder;
  end;
 end;

 if (Action = 'OpenFile') or (Action = 'OpenFolder') then Action:= '';


 kdAction:= Action;
 Settings:= TIniFile.Create(Dir + '\Settings.ini');
 Settings.WriteString('Keys', kdID, Action);
 kdCaption:= Settings.ReadString(sfLanguage, kdAction, kdAction);
 if Action = '' then kdCaption:= '';
 Settings.Free;
end;


procedure TKeyData.Localize;
var
 Settings:TIniFile;
begin
 Settings:= TIniFile.Create(Dir + '\Settings.ini');
 kdCaption:= Settings.ReadString(sfLanguage, kdAction, kdAction);
 Settings.Free;
end;


procedure TSFunkeyMain.LoadSettings;
var
 Z:Integer;
 Settings:TIniFile;
 TempList:TStringList;

procedure GetThemes;
var
 SR:TSearchRec;
begin
 ComboBox13.Clear;
 try
  if FindFirst(Dir + '\Themes\' + '*.*', faDirectory, sr) < 0 then
   Exit
  else
  repeat
   if ((sr.Attr and faDirectory <> 0) AND (sr.Name <> '.') AND (sr.Name <> '..')) then
    ComboBox13.Items.Add(sr.Name) ;
  until FindNext(sr) <> 0;
 finally
  SysUtils.FindClose(sr) ;
end;
ComboBox13.Text:= sfTheme;
end;

procedure GetLanguages;
var
 I:Integer;
 StringList:TStringList;
begin
 Settings:= TIniFile.Create(Dir + '\Settings.ini');
 StringList:= TStringList.Create;
 Settings.ReadSections(StringList);
 for I:= 0 to StringList.Count - 1 do begin
  if (StringList[I] <> 'SFunkey') and (StringList[I] <> 'Keys') and (StringList[I] <> 'Apps') then begin
   ComboBox16.Items.Add(StringList[I]);
  end;
 end;
 StringList.Free;
 Settings.Free;
 ComboBox16.Text:= sfLanguage;
end;


begin
 Settings:= TIniFile.Create(Dir + '\Settings.ini');
  sfEnabled:= Settings.ReadInteger('SFunkey', 'Enabled', 1);
  sfLanguage:= Settings.ReadString('SFunkey', 'Language', 'English');
  sfTheme:= Settings.ReadString('SFunkey', 'Theme',  'Default (Black)');
  sfDisableInApplications:= Settings.ReadString('SFunkey', 'DisableInApplications', '0');
  sfRepeatDelay:= Settings.ReadInteger('SFunkey', 'RepeatDelay', 0);
  sfShowOSD:= Settings.ReadString('SFunkey', 'ShowOSD', '0');
  sfRememberOSD:= Settings.ReadString('SFunkey', 'RememberOSD', '0');
  sfOSDPos.X:= Settings.ReadInteger('SFunkey', 'OSDPos.X', 0);
  sfOSDPos.Y:= Settings.ReadInteger('SFunkey', 'OSDPos.Y', 0);
  sfOSDFadeOutDelay:= Settings.ReadInteger('SFunkey', 'OSDFadeOutDelay', 0);
  sfOSDSpeed:= Settings.ReadInteger('SFunkey', 'OSDSpeed', 0);
  sfOSDTransMin:= Settings.ReadInteger('SFunkey', 'OSDTransMin', 0);
  sfOSDTransMax:= Settings.ReadInteger('SFunkey', 'OSDTransMax', 0);

 TempList:= TStringList.Create;
 Settings.ReadSection('Apps', TempList);
 for Z:= 0 to TempList.Count - 1 do begin
  ListView2.Items.Add.Caption:= TempList[Z];
 end;
 TempList.Free;

 Settings.Free;



 Image1.Picture.LoadFromFile(Dir + '\Themes\' + sfTheme + '\Top.png');

 CheckBox4.Checked:= sfShowOSD = '1';
  CheckBox3.Checked:= sfRememberOSD = '1';
  CheckBox3.Enabled:= CheckBox4.Checked;
  SpinEdit3.Text:= IntToStr(sfOSDFadeOutDelay);
  SpinEdit3.Enabled:= CheckBox4.Checked;
  SpinEdit2.Text:= IntToStr(sfOSDSpeed);
  SpinEdit2.Enabled:= CheckBox4.Checked;
  TrackBar1.Position:= sfOSDTransMin;
  TrackBar2.Position:= sfOSDTransMax;
  TrackBar1.Enabled:= CheckBox4.Checked;
  TrackBar2.Enabled:= CheckBox4.Checked;
 CheckBox7.Checked:= sfDisableInApplications = '1';
 if CheckBox7.Checked then ListView2.Enabled:= True else ListView2.Enabled:= False;

 if F12Enabled then CheckBox1.Checked:= True else CheckBox1.Checked:= False;
 SpinEdit1.Text:=  IntToStr(sfRepeatDelay);
 Delayer.Interval:= sfRepeatDelay;

  if ReadRegistry(HKEY_CURRENT_USER,  'Software\Microsoft\Windows\CurrentVersion\Run', 'SFunkey') <> 'NO' then
  CheckBox2.Checked:= True else CheckBox2.Checked:= False;


 if (sfDisableInApplications = '1') and (sfEnabled = 1) then ScreenCheck.Enabled:= True else ScreenCheck.Enabled:= False;

 Settings:= TIniFile.Create(Dir + '\Themes\' + sfTheme + '\Theme.sft');
  sfFont.Name:= Settings.ReadString('Theme', 'FontName', 'Calibri');
  sfFont.Size:= Settings.ReadInteger('Theme', 'FontSize', 40);
  sfFont.Color:= Settings.ReadInteger('Theme', 'FontColor', $FFFFFF);
  sfTextX:=  Settings.ReadInteger('Theme', 'TextPosx', 135);
  sfTextY:= Settings.ReadInteger('Theme', 'TextPosy', 70);
 Settings.Free;

 GetThemes;

 GetLanguages;
end;


procedure TSFunkeyMain.Localize;
var
 Settings:TIniFile;
 KeyData:TKeYData;
 I:Integer;
begin
 Settings:= TIniFile.Create(Dir + '\Settings.ini');
 Combobox15.Clear;
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'Disable', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'OpenFile', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'OpenFolder', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'TaskManager', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'Sleep', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'RestartPC', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'TurnOffPC', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'LogOff', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'LockPC', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'LCDBrightnessDown', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'LCDBrightnessUp', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'ConnectDisplay', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'DisplayPowerOff', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'DisplayStandBy', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'VolumeMute', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'VolumeDown', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'VolumeUp', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'PreviousTrack', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'Play/Pause', ''));
 Combobox15.Items.Add(Settings.ReadString(sfLanguage, 'NextTrack', ''));


 sfRebootMsg1:= Settings.ReadString(sfLanguage, 'RebootMSG1', '');
 sfRebootMSG2:= Settings.ReadString(sfLanguage, 'RebootMSG2', '');
 sfEnable:= Settings.ReadString(sfLanguage, 'DisableText', '');
 sfDisable:= Settings.ReadString(sfLanguage, 'EnableText', '');
 sfTest:=  Settings.ReadString(sfLanguage, 'Test', '');


 Label24.Caption:= Settings.ReadString(sfLanguage, 'Language', '');
 CheckBox2.Caption:= Settings.ReadString(sfLanguage, 'StartWithWindows', '');
 Label2.Caption:= Settings.ReadString(sfLanguage, 'Theme', '');
 CheckBox4.Caption:= Settings.ReadString(sfLanguage, 'ShowOSD', '');
 CheckBox3.Caption:= Settings.ReadString(sfLanguage, 'RememberOSD', '');

 Label3.Caption:= Settings.ReadString(sfLanguage, 'FadeOutDelay', '');
 Label18.Caption:= Settings.ReadString(sfLanguage, 'PopSpeed', '');
 Label16.Caption:= Settings.ReadString(sfLanguage, 'TransMin', '');
 Label17.Caption:= Settings.ReadString(sfLanguage, 'TransMax', '');
 CheckBox7.Caption:= Settings.ReadString(sfLanguage, 'DisableInApps', '');

 GroupBox2.Caption:= Settings.ReadString(sfLanguage, 'OSD', '');
 GroupBox3.Caption:= Settings.ReadString(sfLanguage, 'Compatibility', '');
 GroupBox4.Caption:= Settings.ReadString(sfLanguage, 'General', '');

 TabSheet1.Caption:= Settings.ReadString(sfLanguage, 'Settings', '');
 TabSheet2.Caption:= Settings.ReadString(sfLanguage, 'About', '');
 TabSheet3.Caption:= Settings.ReadString(sfLanguage, 'Keys', '');

 Button1.Caption:= Settings.ReadString(sfLanguage, 'Add', '');
 Button2.Caption:= Settings.ReadString(sfLanguage, 'Remove', '');
 ListView1.Columns[0].Caption:= Settings.ReadString(sfLanguage, 'Key', '');
 ListView1.Columns[1].Caption:= Settings.ReadString(sfLanguage, 'Action', '');
 ListView2.Columns[0].Caption:= Settings.ReadString(sfLanguage, 'Path', '');

 CheckBox1.Caption:= Settings.ReadString(sfLanguage, 'Enablef12', '');
 Label1.Caption:= Settings.ReadString(sfLanguage, 'RepeatDelay', '');
 Label22.Caption:= Settings.ReadString(sfLanguage, 'Version', '') +  ' 1.1 (2012.02.04)';
 Label23.Caption:= Settings.ReadString(sfLanguage, 'Author', '') + ' : SIV';

 Caption:= 'SFunKey - ' +  Settings.ReadString(sfLanguage, 'Desc', '') + ' by SIV';
 Label21.Caption:= Caption;




 sfTaskMgr:= Settings.ReadString(sfLanguage, 'oTaskMgr', '');
 sfSleep:= Settings.ReadString(sfLanguage, 'oSleep', '');
 sfLCDUp:= Settings.ReadString(sfLanguage, 'oLCDup', '');
 sfLCDDown:= Settings.ReadString(sfLanguage, 'oLCDdown', '');
 sfConnect:= Settings.ReadString(sfLanguage, 'oConnect', '');
 sfLCDOff:= Settings.ReadString(sfLanguage, 'oLCDOff', '');
 sfLCDStand:= Settings.ReadString(sfLanguage, 'oLCDStandby', '');
 sfLock:= Settings.ReadString(sfLanguage, 'oLock', '');
 sfVolUp:= Settings.ReadString(sfLanguage, 'oVolUp', '');
 sfVolDown:= Settings.ReadString(sfLanguage, 'oVolDown', '');
 sfVolMut:= Settings.ReadString(sfLanguage, 'oVolMute', '');
 sfTrackPrev:= Settings.ReadString(sfLanguage, 'oTrackPrev', '');
 sfTrackNext:= Settings.ReadString(sfLanguage, 'oTrackNext', '');
 sfPlay:= Settings.ReadString(sfLanguage, 'oPlay', '');
 sfEnText:= Settings.ReadString(sfLanguage, 'oEnabled', '');
 sfDisText:= Settings.ReadString(sfLanguage, 'oDisabled', '');
 sfRestart:= Settings.ReadString(sfLanguage, 'oRestart', '');
 sfTurnOff:= Settings.ReadString(sfLanguage, 'oTurnOff', '');
 sfLogOff:= Settings.ReadString(sfLanguage, 'oLogOff', '');





 Settings.Free;

 for I:= 0 to kdList.Count - 1 do begin
  KeyData:= TKeYData(kdList[I]);
  KeyData.Localize;
  if ListView1.Items.Item[I].SubItems.Count > 0 then ListView1.Items.Item[I].SubItems[0]:= KeyData.kdCaption;
 end;


 if FileExists(Dir + '\' + sfLanguage + '.about') then begin
  Memo1.Clear;
  Memo1.Lines.LoadFromFile(Dir + '\' + sfLanguage + '.about');
 end else begin
  Memo1.Clear;
  Memo1.Lines.LoadFromFile(Dir + '\English.about');
 end;




end;




function TSFunkeyMain.GetActionID(IDX:Integer):String;
begin
 Result:= '';
 if IDX = 0 then Result:= '';
 if IDX = 1 then Result:= 'OpenFile';
 if IDX = 2 then Result:= 'OpenFolder';
 if IDX = 3 then Result:= 'TaskManager';
 if IDX = 4 then Result:= 'Sleep';
 if IDX = 5 then Result:= 'RestartPC';
 if IDX = 6 then Result:= 'TurnOffPC';
 if IDX = 7 then Result:= 'LogOff';
 if IDX = 8 then Result:= 'LockPC';
 if IDX = 9 then Result:= 'LCDBrightnessDown';
 if IDX = 10 then Result:= 'LCDBrightnessUp';
 if IDX = 11 then Result:= 'ConnectDisplay';
 if IDX = 12 then Result:= 'DisplayPowerOff';
 if IDX = 13 then Result:= 'DisplayStandBy';
 if IDX = 14 then Result:= 'VolumeMute';
 if IDX = 15 then Result:= 'VolumeDown';
 if IDX = 16 then Result:= 'VolumeUp';
 if IDX = 17 then Result:= 'PreviousTrack';
 if IDX = 18 then Result:= 'Play/Pause';
 if IDX = 19 then Result:= 'NextTrack';





end;

procedure TSFunkeyMain.Disable;
var
 I:Integer;
 KeyData:TKeyData;
begin
 //if sfEnabled = 0 then Exit;
 sfEnabled:= 0;
 for I:= 0 to kdList.Count - 1 do begin
  KeyData:= TKeyData(kdList.Items[I]);
  KeyData.UnRegisterKey;
 end;
 DisableSfunkey1.Caption:= sfDisable;
 TrayIcon1.IconIndex:= 1;
 SaveSettings;
end;







procedure TSFunkeyMain.DisableSfunkey1Click(Sender: TObject);
begin
 if sfEnabled = 1 then begin
  ScreenCheck.Enabled:= False;
  Disable;
 end else begin
  if sfDisableInApplications = '1' then ScreenCheck.Enabled:= True;

  Enable;
 end;
end;

procedure TSFunkeyMain.Enable;
var
 I:Integer;
 KeyData:TKeyData;
begin
 //if sfEnabled = 1 then Exit;
 sfEnabled:= 1;
 for I:= 0 to kdList.Count - 1 do begin
  KeyData:= TKeyData(kdList.Items[I]);
  KeyData.RegisterKey;
 end;
 DisableSfunkey1.Caption:= sfEnable;
 TrayIcon1.IconIndex:= 0;
 SaveSettings;
end;


procedure TSFunkeyMain.SaveSettings;
var
 I:Integer;
 Settings:TIniFile;
begin
 Settings:= TIniFile.Create(Dir + '\Settings.ini');
  Settings.WriteInteger('SFunkey', 'Enabled', sfEnabled);
  Settings.WriteString('SFunkey', 'Language', sfLanguage);
  Settings.WriteString('SFunkey', 'Theme', sfTheme);
  Settings.WriteString('SFunkey', 'DisableInApplications', sfDisableInApplications);
  Settings.WriteInteger('SFunkey', 'RepeatDelay', sfRepeatDelay);
  Settings.WriteString('SFunkey', 'ShowOSD', sfShowOSD);
  Settings.WriteString('SFunkey', 'RememberOSD', sfRememberOSD);
  Settings.WriteInteger('SFunkey', 'OSDPos.X', sfOSDPos.X);
  Settings.WriteInteger('SFunkey', 'OSDPos.Y', sfOSDPos.Y);
  Settings.WriteInteger('SFunkey', 'OSDSpeed', sfOSDSpeed);
  Settings.WriteInteger('SFunkey', 'OSDFadeOutDelay', sfOSDFadeOutDelay);
  Settings.WriteInteger('SFunkey', 'OSDTransMin', sfOSDTransMin);
  Settings.WriteInteger('SFunkey', 'OSDTransMax', sfOSDTransMax);

 Settings.EraseSection('Apps');
 for I:= 0 to ListView2.Items.Count - 1 do begin
  Settings.WriteString('Apps', ListView2.Items.Item[I].Caption, ':)');
 end;

 Settings.Free;
end;



procedure TSFunkeyMain.InitializeKeys;
var
 I:Integer;
 KeyData:TKeyData;
 Settings:TIniFile;
begin
 Settings:= TIniFile.Create(Dir + '\Settings.ini');

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'Escape';
  KeyData.kdKey:= VK_ESCAPE;
  KeyData.kdAction:= Settings.ReadString('Keys', 'Escape', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F1';
  KeyData.kdKey:= VK_F1;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F1', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F2';
  KeyData.kdKey:= VK_F2;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F2', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F3';
  KeyData.kdKey:= VK_F3;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F3', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F4';
  KeyData.kdKey:= VK_F4;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F4', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F5';
  KeyData.kdKey:= VK_F5;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F5', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F6';
  KeyData.kdKey:= VK_F6;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F6', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F7';
  KeyData.kdKey:= VK_F7;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F7', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F8';
  KeyData.kdKey:= VK_F8;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F8', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F9';
  KeyData.kdKey:= VK_F9;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F9', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F10';
  KeyData.kdKey:= VK_F10;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F10', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F11';
  KeyData.kdKey:= VK_F11;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F11', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

  KeyData:= TKeyData.Create;
  KeyData.kdID:= 'F12';
  KeyData.kdKey:= VK_F12;
  KeyData.kdAction:= Settings.ReadString('Keys', 'F12', '');
  KeyData.kdCaption:= Settings.ReadString(sfLanguage, KeyData.kdAction, KeyData.kdAction);
  kdList.Add(KeyData);

 Settings.Free;

 ListView1.Clear;
 for I:= 0 to kdList.Count - 1 do begin
  KeyData:= TKeyData(kdList[I]);
  with ListView1.Items.Add do begin
   Caption:= KeyData.kdID;
   SubItems.Add(KeyData.kdCaption);
   Data:= KeyData;
   ImageIndex:= 2;
  end;
  if sfEnabled = 1 then KeyData.RegisterKey ;
// if not KeyData.RegisterKey then ShowMessage('Can not register key: ' + KeyData.kdID);
 end;

 if sfEnabled = 1 then Enable else Disable;


end;






procedure NTSleep;
var
  hToken: THandle;
  tkp: TTokenPrivileges;
  ReturnLength: Cardinal;
begin



  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, hToken) then
  begin
    LookupPrivilegeValue(nil, 'SeShutdownPrivilege', tkp.Privileges[0].Luid);
    tkp.PrivilegeCount := 1; // one privelege to set
    tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    if AdjustTokenPrivileges(hToken, False, tkp, 0, nil, ReturnLength) then
      SetSystemPowerState(true, true);
  end;
end;




function TSFunkeyMain.ReadRegistry(Root:Integer; Section:String; Key:String):String;
begin
 Result:= '';
 with TRegIniFile.Create('') do
   try
    RootKey:= Root;
     Result:= ReadString(Section, Key, 'NO');
   finally
    Free;
  end;
end;


procedure TSFunkeyMain.RunOnStartup(const sCmdLine: string; bRunOnce: boolean = false; Remove: Boolean = false);
var
 sKey:string;
 Section:string;
const
 ApplicationTitle = 'SFunkey';
begin
 if (bRunOnce) then sKey:= 'Once' else sKey:= '';
 Section := 'Software\Microsoft\Windows\CurrentVersion\Run' + sKey + #0;
  with TRegIniFile.Create('') do
   try
    RootKey := HKEY_CURRENT_USER;
     if Remove then DeleteKey(Section, ApplicationTitle) else
      WriteString(Section, ApplicationTitle, sCmdLine) ;
   finally
    Free;
  end;
end;



function TSFunkeyMain.F12Enabled:Boolean;
var
 Reg:TRegistry;
 Key:string;
 KeyValue1, KeyValue2:Integer;
begin
 Result:= False;
 Reg:= TRegistry.Create;
 try
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  Key := 'Software\Microsoft\Windows NT\CurrentVersion\AeDebug' + #0;
  if Reg.OpenKey(Key, True) then begin
   KeyValue1:= Reg.ReadInteger('UserDebuggerHotKey');
   Reg.CloseKey;
  end;
  finally
  Reg.Free
 end;

 Reg:= TRegistry.Create;
 try
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  Key := 'SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\AeDebug' + #0;
  if Reg.OpenKey(Key, True) then begin
   KeyValue2:= Reg.ReadInteger('UserDebuggerHotKey');
   Reg.CloseKey;
  end;
  finally
  Reg.Free
 end;

 if (KeyValue1 = 134) or (KeyValue1 = 134) then Result:= True;
end;




procedure TSFunkeyMain.EnableF12(Value:Boolean = True);
var
 Reg:TRegistry;
 Key:string;
 tempkey:hkey;
 KeyValue:Integer;
begin
 KeyValue:= 134;
 if not Value then KeyValue:= 0;

 Reg:= TRegistry.Create;
 try
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  Key := 'Software\Microsoft\Windows NT\CurrentVersion\AeDebug' + #0;
  if Reg.OpenKey(Key, True) then
   begin
    Reg.WriteInteger('UserDebuggerHotKey', KeyValue);
    Reg.CloseKey;
     end;
  finally
     Reg.Free
 end;

 RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'Software\Microsoft\Windows NT\CurrentVersion\AeDebug' + #0, 0,KEY_ALL_ACCESS
 or KEY_WOW64_64KEY,tempkey);
 RegSetValueEx(tempkey,'UserDebuggerHotKey', 0, REG_DWORD, @KeyValue, SizeOf(@KeyValue));
end;








procedure TSFunkeyMain.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if CheckBox1.Checked then begin
  EnableF12;
  ShowMessage(sfRebootMsg1);
  WindowsExit(EWX_REBOOT or EWX_FORCE);
 end else begin
  EnableF12(False);
  ShowMessage(sfRebootMSG2);
  WindowsExit(EWX_REBOOT or EWX_FORCE);
 end;





end;

procedure TSFunkeyMain.CheckBox2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
RunOnStartup(Application.ExeName, False, not CheckBox2.Checked);
end;

procedure TSFunkeyMain.CheckBox3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if CheckBox3.Checked then sfRememberOSD:= '1' else sfRememberOSD:= '0';
 SaveSettings;
end;

procedure TSFunkeyMain.CheckBox4MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if CheckBox4.Checked then sfShowOSD:= '1' else sfShowOSD:= '0';
 SaveSettings;

 CheckBox3.Enabled:= CheckBox4.Checked;
 SpinEdit3.Enabled:= CheckBox4.Checked;
 SpinEdit2.Enabled:= CheckBox4.Checked;
 TrackBar1.Enabled:= CheckBox4.Checked;
 TrackBar2.Enabled:= CheckBox4.Checked;



end;

procedure TSFunkeyMain.CheckBox7MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if CheckBox7.Checked then begin
  sfDisableInApplications:= '1';
  ScreenCheck.Enabled:= True;
 end else begin
  sfDisableInApplications:= '0';
  ScreenCheck.Enabled:= False;
  Enable;
 end;
 SaveSettings;
 ListView2.Enabled:= CheckBox7.Checked;
end;

procedure TSFunkeyMain.Close1Click(Sender: TObject);
begin
 Close;
end;

procedure TSFunkeyMain.ComboBox13Select(Sender: TObject);
var
  Settings:TIniFile;
begin
 sfTheme:=ComboBox13.Items[ComboBox13.ItemIndex];
 SaveSettings;
 sfTestMode:= True;

 Settings:= TIniFile.Create(Dir + '\Themes\' + sfTheme + '\Theme.sft');
  sfFont.Name:= Settings.ReadString('Theme', 'FontName', 'Calibri');
  sfFont.Size:= Settings.ReadInteger('Theme', 'FontSize', 40);
  sfFont.Color:= Settings.ReadInteger('Theme', 'FontColor', $FFFFFF);
  sfTextX:=  Settings.ReadInteger('Theme', 'TextPosx', 135);
  sfTextY:= Settings.ReadInteger('Theme', 'TextPosy', 70);
 Settings.Free;



 Image1.Picture.LoadFromFile(Dir + '\Themes\' + sfTheme + '\Top.png');
 SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\SFunKey.png', sfTest , sfTextX, sfTextY, sfFont);

end;

procedure TSFunkeyMain.ComboBox15Select(Sender: TObject);
var
 KeyData:TKeyData;
begin
 if Assigned(Item) then begin
  KeyData:= TKeyData(Item.Data);
  KeyData.SetAction(GetActionID(ComboBox15.ItemIndex));
  Item.SubItems[0]:= KeyData.kdCaption;
 end;

end;




procedure TSFunkeyMain.ComboBox16Select(Sender: TObject);
begin
 sfLanguage:= ComboBox16.Items[ComboBox16.ItemIndex];
 SaveSettings;
 Localize;
end;

procedure TSFunkeyMain.DelayerTimer(Sender: TObject);
begin
 Delayer.Enabled:= False;
 UnRegisterHotKey(SFunkeyMain.Handle, CurrentMSG);
 keybd_event(CurrentMSG, 0, 0, 0);
 keybd_event(CurrentMSG, 0, KEYEVENTF_KEYUP, 0);
 RegisterHotKey(SFunkeyMain.Handle, CurrentMSG, 0, CurrentMSG);
end;


procedure TSFunkeyMain.ListView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
 R:TRect;
 IDX:Integer;
 HitTest:TLVHitTestInfo;
begin
 ComboBox15.Visible:=False;
 Item:= ListView1.GetItemAt(X, Y);
 if Assigned(Item) then begin
  FillChar(HitTest, SizeOf(HitTest), 0);
  HitTest.pt.x:=X;
  HitTest.pt.y:=Y;
  SendMessage(ListView1.Handle, LVM_SUBITEMHITTEST, 0, Integer(@HitTest));
  SubitemIDX:= HitTest.iSubItem;

  if SubitemIDX > 0 then begin
   ListView_GetSubItemRect(ListView1.Handle, Item.Index, SubitemIDX ,LVIR_BOUNDS, @R);
   Offsetrect(R,ListView1.Left,ListView1.Top);
   ComboBox15.SetBounds(R.Left,R.Top,R.Right-R.Left,R.Bottom-R.Top);
   Dec(SubitemIDX);
   ComboBox15.Visible:=True;
   ComboBox15.Text:= Item.SubItems[0];
   ComboBox15.ItemIndex:= -1;
   IDX:= ComboBox15.Items.IndexOf(Item.SubItems[0]);
   if IDX > -1 then ComboBox15.ItemIndex:= IDX;
  end;
end;
end;

procedure TSFunkeyMain.DonateClick(Sender: TObject);
begin

 ShellExecute(self.WindowHandle,'open',
  PChar('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=ZC88U4BDKLGCS'),
   nil,nil, SW_SHOWNORMAL);

end;


procedure TSFunkeyMain.FormDestroy(Sender: TObject);
begin
 kdList.Free;
 sfProcessList.Free;
 sfFont.Free;
end;


procedure TSFunkeyMain.FormShow(Sender: TObject);
begin
ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TSFunkeyMain.Appmessage(var Msg: TMsg; var Handled: Boolean);
var
 message:TWMKey;
begin
 if Msg.message = WM_KeyDown then begin
  sfButtonPressed:= True;
 end;
 if Msg.message = WM_KeyUp  then begin
  sfButtonPressed:= False;
 end;
end;



procedure TSFunkeyMain.Button1Click(Sender: TObject);
begin
 if FileDialog.Execute then begin
  ListView2.Items.Add.Caption:= FileDialog.FileName;
  SaveSettings;
 end;
end;

procedure TSFunkeyMain.Button2Click(Sender: TObject);
begin
 if Assigned(ListView2.Selected) then begin
  ListView2.Selected.Delete;
  SaveSettings;
 end;

end;

procedure TSFunkeyMain.FormCreate(Sender: TObject);
var
 hSysMenu:HMENU;
begin


 ReportMemoryLeaksOnShutdown:= True;
 WindowState:= wsMinimized;
 KeyPreview:=True;
 Application.OnMinimize := ApplicationMinimize;
 Dir:= ExcludeTrailingPathDelimiter( ExtractFilePath( Application.ExeName));

 hSysMenu:=GetSystemMenu(Self.Handle,False);
 if hSysMenu <> 0 then begin
  EnableMenuItem(hSysMenu,SC_CLOSE,MF_BYCOMMAND or MF_GRAYED);
  DrawMenuBar(Self.Handle);
 end;
// Application.OnMessage := AppMessage;
 sfFont:= TFont.Create;
 kdList:= TObjectList.Create;
 sfProcessList:= TStringList.Create;
 
 sfTestMode:= False;
 sfLoaded:= False;
 sfEnabled:= 1;
 sfRestoreApps:= False;

 LoadSettings;
 Localize;
 InitializeKeys;

 RegisterHotKey(Handle, 104020 , MOD_WIN, 83);




 sfLoaded:= True;




end;
















procedure TSFunkeyMain.SaveSetting(Ident, Value:String);
var
 Settings:TIniFile;
begin
 Settings:= TIniFile.Create(Dir + '\Settings.ini');
  Settings.WriteString('SFunkey', Ident, Value);
 Settings.Free;
end;



function TSFunkeyMain.ApplicationRunning:Boolean;
var
 I, Y:Integer;
 ProcessID, AppID:String;
begin
 Result:= False;
 if sfDisableInApplications = '1' then begin
  sfProcessList.Clear;
  RunningProcessesList(sfProcessList, True);
  for I:= 0 to sfProcessList.Count - 1 do begin
   ProcessID:= sfProcessList[I];
   for Y:= 0 to ListView2.Items.Count - 1 do begin
    AppID:= ListView2.Items[Y].Caption;
    if AnsiLowerCase(AppID) = AnsiLowerCase(ProcessID) then begin
     Result:= True;
     Exit;
    end;
   end;
  end;
end;
end;


procedure TSFunkeyMain.ScreenCheckTimer(Sender: TObject);
begin
 ScreenCheck.Enabled:= False;
 if ApplicationRunning then begin
  Disable;
  ScreenCheck.Enabled:= True;
  Exit;
 end;
 Enable;
 ScreenCheck.Enabled:= True;
end;






procedure TSFunkeyMain.SpinEdit1Change(Sender: TObject);
begin
 sfRepeatDelay:= StrToInt(SpinEdit1.Text);
 Delayer.Interval:= sfRepeatDelay;
 SaveSettings;
end;

procedure TSFunkeyMain.SpinEdit2Change(Sender: TObject);
begin
 sfOSDSpeed:= StrToInt(SpinEdit2.Text);
 SaveSettings;
end;

procedure TSFunkeyMain.SpinEdit3Change(Sender: TObject);
begin
 sfOSDFadeOutDelay:= StrToInt(SpinEdit3.Text);
 SaveSettings;
end;

procedure TSFunkeyMain.TrackBar1Change(Sender: TObject);
begin
 sfOSDTransMin:= TrackBar1.Position;
 SaveSettings;
 if not sfLoaded then Exit;
  sfTestMode:= True;
  SplashForm.ShowTimer.Enabled:= False;
  SplashForm.TransMin:= sfOSDTransMin;
  SplashForm.TransMax:= sfOSDTransMax;
  SplashForm.ShowTimer.Interval:= sfOSDFadeOutDelay;
  SplashForm.SplashPNG.LoadImage(Dir + '\Themes\' + sfTheme + '\SFunKey.png',  sfTest, sfTextX, sfTextY, sfFont);
  SplashForm.SplashPNG.AlphaDegeri:= TrackBar1.Position;
  SplashForm.SplashPNG.Execute;
  SplashForm.Show;
  ShowWindow(SplashForm.Handle, SW_SHOWNOACTIVATE);
  SplashForm.ShowTimer.Enabled:= True;


end;

procedure TSFunkeyMain.TrackBar2Change(Sender: TObject);
begin
 sfOSDTransMax:= TrackBar2.Position;
 SaveSettings;

 if not sfLoaded then Exit;
  sfTestMode:= True;
  SplashForm.ShowTimer.Enabled:= False;
  SplashForm.TransMin:= sfOSDTransMin;
  SplashForm.TransMax:= sfOSDTransMax;
  SplashForm.ShowTimer.Interval:= sfOSDFadeOutDelay;
  SplashForm.SplashPNG.LoadImage(Dir + '\Themes\' + sfTheme + '\SFunKey.png', sfTest, sfTextX, sfTextY, sfFont);
  SplashForm.SplashPNG.AlphaDegeri:= TrackBar2.Position;
  SplashForm.SplashPNG.Execute;
  SplashForm.Show;
  ShowWindow(SplashForm.Handle, SW_SHOWNOACTIVATE);
  SplashForm.ShowTimer.Enabled:= True;
end;

procedure TSFunkeyMain.TrayIcon1DblClick(Sender: TObject);
begin
 Visible:= True;
 BringToFront;
 SplashForm.ForceForegroundWindow(Handle);
end;

procedure TSFunkeyMain.ApplicationMinimize(Sender: TObject);
begin
 ShowWindow(Handle, SW_HIDE) ;
end;




procedure TSFunkeyMain.WMHotkey(var msg:TWMHotkey);
var
 I:Integer;
 MSGText:String;
 KeyData:TKeyData;
begin

 if msg.hotkey = 104020 then begin
  if sfEnabled = 1 then begin
   MSGText:= sfDisText;
   Disable;

   if sfDisableInApplications = '1' then sfRestoreApps:= True else sfRestoreApps:= False;
   CheckBox7.Checked:= False;
   sfDisableInApplications:= '0';
   ScreenCheck.Enabled:= False;
   SaveSettings;
   ListView2.Enabled:= False;

  end else begin
   MSGText:= sfEnText;
   if sfRestoreApps then begin
    CheckBox7.Checked:= True;
    sfDisableInApplications:= '1';
    ScreenCheck.Enabled:= True;
    SaveSettings;
    ListView2.Enabled:= True;
   end;
   Enable;
  end;
  SplashForm.PopUp(Dir + '\Themes\' + sfTheme + '\SFunKey.png', MSGText, sfTextX, sfTextY, sfFont);
  Exit;
 end;

if sfEnabled = 0 then Exit;

 if Delayer.Enabled = False then begin
  CurrentMSG:= msg.HotKey;
  Delayer.Enabled:= True;
  Exit;
 end;
 Delayer.Enabled:= False;


 for I:= 0 to kdList.Count - 1 do begin
  KeyData:= TKeyData(kdList.Items[I]);
  if (KeyData.kdEnabled) and (KeyData.kdKey = msg.HotKey) then begin
   KeyData.DoAction;
   Exit;
  end;
 end;

end;






end.
