unit utils;

interface

uses WinApi.Windows, SysUtils;

     function ISAeroEnabled:boolean;
     function BrowseForFolder(aParent:HWND;aTitle:WideString;var Path:WideString):Boolean;

implementation

uses WinApi.ActiveX, WinApi.ShellApi, WinApi.ShlObj, WinApi.ShLwApi;

function ISAeroEnabled:boolean;
type  TDwmIsCompositionEnabled = function(var IsEnabled:boolean):HRESULT;stdcall;
var
 f:TDwmIsCompositionEnabled;
 h:THandle;
 v:boolean;
begin
 Result:=false;
 if Win32Platform=VER_PLATFORM_WIN32_NT then
  if Win32MajorVersion>=6 then
    begin
     h:=LoadLibrary(PWideChar('dwmapi.dll'));
     if h<>0 then
      begin
       @f:=GetProcAddress(h,'DwmIsCompositionEnabled');
       if Assigned(@f) then
        if f(v)=S_OK then Result:=v;
       FreeLibrary(h);
      end;
    end;
end;

function BrowseForFolder(aParent:HWND;aTitle:WideString;var Path:WideString):Boolean;
var
 pi:PItemIDList;
 bi:TBrowseInfoW;
 pc:array[0..MAX_PATH-1] of WideChar;
begin
 Path:='';
 FillChar(bi,SizeOf(bi),0);
 CoInitialize(nil);
 with bi do
  begin
   hwndOwner:=AParent;
   SHGetSpecialFolderLocation(0,CSIDL_DRIVES,pidlRoot);
   pszDisplayName:=nil; // litle screwup here, requires further investigation
   lpszTitle:=PWideChar(aTitle);
   ulFlags:=BIF_RETURNONLYFSDIRS or BIF_RETURNFSANCESTORS or BIF_DONTGOBELOWDOMAIN or BIF_USENEWUI;
   lpfn:=nil;
   lParam:=0;
   iImage:=0;
  end;
 pi:=SHBrowseForFolderW(bi);
 Result:=pi<>nil;
 if bi.pidlRoot<>nil then CoTaskMemFree(bi.pidlRoot);
 if pi<>nil then
 begin
  SHGetPathFromIDListW(pi,pc);
  Path:=WideString(StrDupW(pc));
  CoTaskMemFree(pi);
 end;
 CoUnInitialize;
end;

end.
