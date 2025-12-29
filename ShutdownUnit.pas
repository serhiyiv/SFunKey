unit ShutdownUnit;

interface

uses
  Windows, SysUtils, ShlObj, ActiveX, ComObj;
Var
 ShutdownType: String;

 function WindowsExit(RebootParam: Longword): Boolean;



implementation

function WindowsExit(RebootParam: Longword): Boolean;
var
   TTokenHd: THandle;
   TTokenPvg: TTokenPrivileges;
   cbtpPrevious: DWORD;
   rTTokenPvg: TTokenPrivileges;
   pcbtpPreviousRequired: DWORD;
   tpResult: Boolean;
const
   SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
   if Win32Platform = VER_PLATFORM_WIN32_NT then begin

     (*
     The ExitWindowsEx function fails if the calling process does not have
     the SE_SHUTDOWN_NAME privilege. This privilege is disabled by default.
     Use the AdjustTokenPrivileges function to enable this privilege.
     *)
     tpResult := OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, TTokenHd) ;
     if tpResult then begin
       tpResult := LookupPrivilegeValue(nil, SE_SHUTDOWN_NAME, TTokenPvg.Privileges[0].Luid) ;
       TTokenPvg.PrivilegeCount := 1;
       TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
       cbtpPrevious := SizeOf(rTTokenPvg) ;
       pcbtpPreviousRequired := 0;
       if tpResult then
         Windows.AdjustTokenPrivileges(TTokenHd, False, TTokenPvg, cbtpPrevious, rTTokenPvg, pcbtpPreviousRequired) ;
     end;
   end;
   Result := ExitWindowsEx(RebootParam, 0) ;
end;
   {
procedure CreateLink(NomeLink, Descricao: String; IconIndex: Integer);
var
  IObject      : IUnknown;
  ISLink       : IShellLink;
  IPFile       : IPersistFile;
  PIDL         : PItemIDList;
  InFolder     : array[0..MAX_PATH] of Char;
  Aplicacao    : String;
  DescCompleta : WideString;
begin
  Aplicacao := ParamStr(0);

  CoInitialize(Nil);
  IObject := CreateComObject(CLSID_ShellLink);
  ISLink  := IObject as IShellLink;
  IPFile  := IObject as IPersistFile;

  with ISLink do begin
    SetPath(pChar(Aplicacao));
    SetWorkingDirectory(pChar(ExtractFilePath(Aplicacao)));
    SetArguments(PChar(NomeLink));
    SetIconLocation(PChar(Aplicacao), IconIndex);
  end;

  SHGetSpecialFolderLocation(0, CSIDL_DESKTOPDIRECTORY, PIDL);
  SHGetPathFromIDList(PIDL, InFolder);

  DescCompleta := StrPas(InFolder);
  DescCompleta := DescCompleta + '\'+ Descricao +'.lnk';
  IPFile.Save(PWChar(DescCompleta), false);
end;

begin
  If ParamCount = 1 then begin
    ShutdownType := Trim(AnsiLowerCase(ParamStr(1)));
    If ShutdownType = 'install' then begin
      CreateLink('SHUTDOWN', 'Shutdown', 2);
      CreateLink('RESTART', 'Restart', 1);
      CreateLink('LOGOFF', 'Logoff', 0);
    end else
      If ShutdownType = 'shutdown' then
        WindowsExit(EWX_POWEROFF)
      else
        If ShutdownType = 'restart' then
          WindowsExit(EWX_REBOOT)
        else
          If ShutdownType = 'logoff' then
            WindowsExit(EWX_LOGOFF)
          else
            MessageBox(0, 'The parameters are: SHUTDOWN, RESTART, LOGOFF and INSTALL.', 'Shutdown', MB_OK + MB_ICONEXCLAMATION);
  end else begin
    MessageBox(0, 'Fill the correct parameters. The parameters are: SHUTDOWN, RESTART, LOGOFF and INSTALL.', 'Shutdown', MB_OK + MB_ICONEXCLAMATION);
  end; }
end.
