object SplashForm: TSplashForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'SplashForm'
  ClientHeight = 187
  ClientWidth = 380
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ShowTimer: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = ShowTimerTimer
    Left = 120
    Top = 32
  end
end
