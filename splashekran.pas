unit splashekran;

interface

uses
  SysUtils, Classes, Controls, Messages, Windows, Forms, pngimage,Graphics;

type
  TSplashEkran = class(TComponent)
  private
    FAlphaDegeri: integer;
    FResim: TPngImage;
    Fhandle: THandle;
    OldWndProc: TFarProc;
    NewWndProc: Pointer;
    procedure SetAlphaDegeri(const Value: integer);
    procedure SetResim(const Value: TPngImage);

    procedure HookOwner;
    procedure UnhookOwner;
  protected
    procedure HookWndProc(var Msg: TMessage); virtual;
    procedure CallDefault(var Msg: TMessage);
  public
  procedure Execute;
    procedure LoadImage(Path:String; Text:String; X, Y:Integer; Font:TFont);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Resim: TPngImage read FResim write SetResim;
    property AlphaDegeri: integer read FAlphaDegeri write SetAlphaDegeri default 255;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('NoktaComp', [TSplashEkran]);
end;

{ TSplashEkran }





constructor TSplashEkran.Create(AOwner: TComponent);
begin
  if not (AOwner is TForm) then
    raise EInvalidCast.Create('Form only');

  inherited Create(AOwner);
  Fhandle := TForm(AOwner).Handle;
  FResim := TPngImage.Create;
  TForm(AOwner).BorderStyle := bsNone;
  FAlphaDegeri := 255;
  HookOwner;
end;

destructor TSplashEkran.Destroy;
begin
  FResim.Free;
  UnhookOwner;
  inherited;
end;

procedure TSplashEkran.LoadImage(Path:String; Text:String; X, Y:Integer; Font:TFont);

function GetFontSize(Current, MaxWidth:Integer):Integer;
var
 I, Size:Integer;
 CWidth:Integer;
begin
 Result:= Current;
 Size:= Current;
 repeat
  Resim.Canvas.Font:= Font;
  Resim.Canvas.Font.Size:= Size;
  CWidth:= Resim.Canvas.TextWidth(Text);
  Size:= Size - 2;
 until (CWidth <= MaxWidth - 10) or (Size <= 5);
 Result:= Size;
end;

begin
 if not FileExists(Path) then Exit;
 FResim.LoadFromFile(Path);
 Resim.Canvas.Brush.Style:= bsClear;
 Resim.Canvas.Font:= Font;
 Resim.Canvas.Font.Size:= GetFontSize(Font.Size, FResim.Width - X);
 Resim.Canvas.TextOut(X, (FResim.Height div 2) - Resim.Canvas.TextHeight(Text) div 2 , Text);
 Execute;
end;

procedure TSplashEkran.Execute;
var
  BlendFunction: TBlendFunction;
  BitmapPos: TPoint;
  BitmapSize: TSize;
  exStyle: DWORD;
  Bitmap: TBitmap;
begin

  if Fhandle = 0 then exit;
  if csDesigning in ComponentState then exit;
  if FResim = nil then exit;
  exStyle := GetWindowLongA(Fhandle, GWL_EXSTYLE);
  if (exStyle and WS_EX_LAYERED = 0) then SetWindowLong(FHandle, GWL_EXSTYLE, exStyle or WS_EX_LAYERED);
  Bitmap := TBitmap.Create;
  try
  Bitmap.Assign(FResim);
  TForm(Owner).ClientWidth := Bitmap.Width;
  TForm(Owner).ClientHeight := Bitmap.Height;
  BitmapPos := Point(0, 0);
  BitmapSize.cx := Bitmap.Width;
  BitmapSize.cy := Bitmap.Height;
  BlendFunction.BlendOp := AC_SRC_OVER;
  BlendFunction.BlendFlags := 0;
  BlendFunction.SourceConstantAlpha := FAlphaDegeri;
  BlendFunction.AlphaFormat := AC_SRC_ALPHA;
  UpdateLayeredWindow(FHandle, 0, nil, @BitmapSize, Bitmap.Canvas.Handle, @BitmapPos, 0, @BlendFunction, ULW_ALPHA);
  finally
      Bitmap.Free;
  end;


end;

procedure TSplashEkran.HookOwner;
begin
  if not Assigned(Owner) then
    Exit;
  OldWndProc := TFarProc(GetWindowLong(TForm(Owner).Handle, GWL_WndProc));
  NewWndProc := MakeObjectInstance(HookWndProc);
  SetWindowLong(TForm(Owner).Handle, GWL_WndProc, LongInt(NewWndProc))

end;

procedure TSplashEkran.CallDefault;
begin
  Msg.Result := CallWindowProc(OldWndProc, TForm(Owner).Handle, Msg.Msg, Msg.wParam, Msg.lParam)
end;


procedure TSplashEkran.UnhookOwner;
begin
  if Assigned(Owner) and Assigned(OldWndProc) then
    SetWindowLong(TForm(Owner).Handle, GWL_WndProc, LongInt(OldWndProc));
  if Assigned(NewWndProc) then
    FreeObjectInstance(NewWndProc);
  NewWndProc := nil;
  OldWndProc := nil
end;


procedure TSplashEkran.HookWndProc(var Msg: TMessage);
begin
  case Msg.Msg of
    WM_PAINT: if (csDesigning in ComponentState) then
        CallDefault(Msg)
      else

      begin
        Execute;
        CallDefault(Msg);
      end;
    WM_EraseBkgnd: if (csDesigning in ComponentState) then
        CallDefault(Msg)
      else
        Msg.Result := 1;

    WM_LBUTTONDOWN:
      begin
        ReleaseCapture;
        SendMessage(FHandle, WM_SYSCOMMAND, SC_MOVE + 1, 0);
        CallDefault(Msg);

      end ;
end;
    CallDefault(Msg)



end;


procedure TSplashEkran.SetAlphaDegeri(const Value: integer);
begin
  FAlphaDegeri := Value;
end;

procedure TSplashEkran.SetResim(const Value: TPngImage);
var
bm :TBitmap;
begin
bm:=TBitmap.Create;
bm.Assign(Value);
if bm.PixelFormat<>pf32bit then
begin
bm.Free;
exit;
end;
  FResim.Assign(Value);
  bm.Free;



end;

end.

