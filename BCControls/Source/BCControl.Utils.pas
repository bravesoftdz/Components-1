unit BCControl.Utils;

interface

uses
  Winapi.Windows;

const
  FILE_READ_DATA         = $0001; // file & pipe
  FILE_LIST_DIRECTORY    = $0001; // directory
  FILE_WRITE_DATA        = $0002; // file & pipe
  FILE_ADD_FILE          = $0002; // directory
  FILE_APPEND_DATA       = $0004; // file
  FILE_ADD_SUBDIRECTORY  = $0004; // directory
  FILE_CREATE_PIPE_INSTANCE = $0004; // named pipe
  FILE_READ_EA           = $0008; // file & directory
  FILE_WRITE_EA          = $0010; // file & directory
  FILE_EXECUTE           = $0020; // file
  FILE_TRAVERSE          = $0020; // directory
  FILE_DELETE_CHILD      = $0040; // directory
  FILE_READ_ATTRIBUTES   = $0080; // all
  FILE_WRITE_ATTRIBUTES  = $0100; // all
  FILE_ALL_ACCESS        = STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $1FF;
  FILE_GENERIC_READ      = STANDARD_RIGHTS_READ or FILE_READ_DATA or FILE_READ_ATTRIBUTES or FILE_READ_EA or SYNCHRONIZE;
  FILE_GENERIC_WRITE     = STANDARD_RIGHTS_WRITE or FILE_WRITE_DATA or FILE_WRITE_ATTRIBUTES or FILE_WRITE_EA or
    FILE_APPEND_DATA or SYNCHRONIZE;
  FILE_GENERIC_EXECUTE   = STANDARD_RIGHTS_EXECUTE or FILE_READ_ATTRIBUTES or FILE_EXECUTE or SYNCHRONIZE;

function CheckAccessToFile(const DesiredAccess: Cardinal; const FileName: string): Boolean;
function GetIconIndex(const AFilename: string; const AMoreFlags: Cardinal = 0): Integer;
function GetIconOverlayIndex(const AFilename: string; const AMoreFlags: Cardinal = 0): Integer;
function GetSysImageList: THandle;
function FileIconInit(FullInit: BOOL): BOOL; stdcall;
function IsExtInFileType(Ext: string; FileType: string): Boolean;
function RemoveDirectory(const Directory: string): Boolean;

implementation

uses
  System.SysUtils, Winapi.ShellAPI;

function CheckAccessToFile(const DesiredAccess: DWORD; const FileName: string): Boolean;
const
  GenericFileMapping: TGenericMapping = (
    GenericRead: FILE_GENERIC_READ;
    GenericWrite: FILE_GENERIC_WRITE;
    GenericExecute: FILE_GENERIC_EXECUTE;
    GenericAll: FILE_ALL_ACCESS
    );
var
  LastError: DWORD;
  LengthNeeded: DWORD;
  SecurityDescriptor: PSecurityDescriptor;
  ClientToken: THandle;
  AccessMask: DWORD;
  PrivilegeSet: TPrivilegeSet;
  PrivilegeSetLength: DWORD;
  GrantedAccess: DWORD;
  AccessStatus: BOOL;
begin
  Result := False;
  LastError := GetLastError;
  if not GetFileSecurityW(PWideChar(FileName), OWNER_SECURITY_INFORMATION or
    GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION, nil, 0,
    LengthNeeded) and (GetLastError <> ERROR_INSUFFICIENT_BUFFER) then
    Exit;
  SetLastError(LastError);
  Inc(LengthNeeded, $1000);
  SecurityDescriptor := PSecurityDescriptor(LocalAlloc(LPTR, LengthNeeded));
  if not Assigned(SecurityDescriptor) then
    Exit;
  try
    if not GetFileSecurityW(PWideChar(FileName), OWNER_SECURITY_INFORMATION or
      GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION,
      SecurityDescriptor, LengthNeeded, LengthNeeded) then
      Exit;
    if not ImpersonateSelf(SecurityImpersonation) then
      Exit;
    try
      if not OpenThreadToken(GetCurrentThread, TOKEN_QUERY or
        TOKEN_IMPERSONATE or TOKEN_DUPLICATE, False, ClientToken) then
        Exit;
      try
        AccessMask := DesiredAccess;
        MapGenericMask(AccessMask, GenericFileMapping);
        PrivilegeSetLength := SizeOf(TPrivilegeSet);
        if AccessCheck(SecurityDescriptor, ClientToken, AccessMask,
          GenericFileMapping, PrivilegeSet, PrivilegeSetLength, GrantedAccess,
          AccessStatus) then
          Result := AccessStatus;
      finally
        CloseHandle(ClientToken);
      end;
    finally
      RevertToSelf;
    end;
  finally
    LocalFree(HLOCAL(SecurityDescriptor));
  end;
end;

function GetIconIndex(const AFilename: string; const AMoreFlags: Cardinal): Integer;
var
  SHFileInfo: TSHFileInfo;
begin
  if SHGetFileInfo(PChar(AFilename), 0, SHFileInfo, SizeOf(SHFileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_ICON or AMoreFlags) = 0 then
    Result := -1
  else
  begin
    Result := SHFileInfo.iIcon;
    { destroy the icon, we are only using the index }
    DestroyIcon(SHFileInfo.hIcon);
  end;
end;

function GetIconOverlayIndex(const AFilename: string; const AMoreFlags: Cardinal): Integer;
var
  SHFileInfo: TSHFileInfo;
begin
  ZeroMemory(@SHFileInfo, SizeOf(SHFileInfo));
  { SHGFI_OVERLAYINDEX: Return the index of the overlay icon. The value of the overlay index is returned in the upper eight
    bits of the iIcon member of the structure specified by psfi. This flag requires that the SHGFI_ICON be set as well. }
  if SHGetFileInfo(PChar(AFilename), 0, SHFileInfo, SizeOf(SHFileInfo), SHGFI_ICON or SHGFI_OVERLAYINDEX or AMoreFlags) = 0 then
    Result := -1
  else
  begin
    Result := SHFileInfo.iIcon;
    Result := (Result shr ((SizeOf(Result) - 1) * 8)) and $FF - 1;
    { destroy the icon, we are only using the index }
    DestroyIcon(SHFileInfo.hIcon);
  end;
end;

const
  IID_IImageList: TGUID = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';

function BackfillSHGetImageList(Flags: Integer; const IID: TGUID; var ImageList: THandle): HRESULT; stdcall;
var
  SHFileInfo: TSHFileInfo;
begin
  Result := S_OK;
  if IID <> IID_IImageList then
    Exit(E_NOINTERFACE);
  ImageList := SHGetFileInfo('', 0, SHFileInfo, SizeOf(SHFileInfo), SHGFI_ICON or SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_ADDOVERLAYS);
  if ImageList = 0 then
    Exit(S_FALSE)
end;

function GetSysImageList: THandle;
var
  Handle: THandle;
  SHGetImageList: function (Flags: Integer; const IID: TGUID; var ImageList: THandle): HRESULT; stdcall;
begin
  Handle := LoadLibrary('Shell32.dll');
  if Handle <> S_OK then
  begin
    SHGetImageList := GetProcAddress(Handle, PChar(727));
    if not Assigned(@SHGetImageList) then
      SHGetImageList := BackfillSHGetImageList;
    if Assigned(SHGetImageList) then
      if SHGetImageList(SHIL_SYSSMALL, IID_IImageList, Result) <> 0 then
        Exit(0);
  end;
end;

function FileIconInit(FullInit: BOOL): BOOL; stdcall;
type
  TFileIconInit = function(FullInit: BOOL): BOOL; stdcall;
var
  ShellDLL: HMODULE;
  PFileIconInit: TFileIconInit;
begin
  Result := False;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    ShellDLL := LoadLibrary(PChar('shell32.dll'));
    PFileIconInit := GetProcAddress(ShellDLL, PChar(660));
    if Assigned(PFileIconInit) then
      Result := PFileIconInit(FullInit);
  end;
end;

function IsExtInFileType(Ext: string; FileType: string): Boolean;
var
  s, FileTypes: string;
begin
  Ext := '*' + Ext;
  FileTypes := FileType;
  if Pos(';', FileTypes) <> 0 then
    while Pos(';', FileTypes) <> 0 do
    begin
      s := System.Copy(FileTypes, 1,  Pos(';', FileTypes) - 1);
      Result := LowerCase(Ext) = LowerCase(s);
      if Result then
        Exit;
      FileTypes := System.Copy(FileTypes, Pos(';', FileTypes) + 1, Length(FileTypes));
    end;
  Result := LowerCase(Ext) = LowerCase(FileTypes);
end;

function RemoveDirectory(const Directory: string): Boolean;
var
  s: string;
  Rec: TSearchRec;
begin
  Result := True;
  {$WARNINGS OFF} { IncludeTrailingPathDelimiter is specific to a platform }
  s := IncludeTrailingPathDelimiter(Directory);
  {$WARNINGS ON}
  if FindFirst(s + '*.*', faAnyFile, Rec) = 0 then
  try
    repeat
      if (Rec.Attr and faDirectory) = faDirectory then
      begin
        if (Rec.Name <> '.') and (Rec.Name <> '..') then
          RemoveDirectory(s + Rec.Name);
      end
      else
        Result := DeleteFile(s + Rec.Name);
    until Result and (FindNext(Rec) <> 0);
  finally
    FindClose(Rec);
  end;
  if Result then
    Result := RemoveDir(s);
end;

initialization

  FileIconInit(True);

end.
