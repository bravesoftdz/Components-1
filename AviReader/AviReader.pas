unit AviReader;

interface

uses
  Windows, Graphics, Sysutils, Classes, VideoForWindows;

type
  TCustomAviReader = class(TComponent)
  private
    FAviFile: PAviFile;
    FAviFrame: PGetFrame;
    FAviStream: PAVIStream;
    FAviInfo: TAviStreamInfo;
    FFPS: SmallInt;
    FFrameRate: Double;
    FFrameCount: LongInt;
    FDuration: Cardinal;
    FWidth: Cardinal;
    FHeight: Cardinal;
  protected
    function GetFrameCount: LongInt;
    function GetDuration: Cardinal;
    function GetWidth: Cardinal;
    function GetHeight: Cardinal;
    function GetFPS: integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Active: boolean;
    function GetFrame(FrameNumber: cardinal): TBitmap;
    procedure Open(const Filename: string);
    procedure Close;
  published
    property FrameCount: LongInt read FFrameCount;
    property Duration: Cardinal read FDuration;
    property ImageWidth: Cardinal read FWidth;
    property ImageHeight: Cardinal read FHeight;
    property FPS: SmallInt read FFPS;
    property FrameRate: Double read FFrameRate;
  end;

  TAviReader = class(TCustomAviReader)
  published
    property FrameCount;
    property Duration;
    property ImageWidth;
    property ImageHeight;
    property FPS;
    property FrameRate;
  end;

procedure Register;

implementation

constructor TCustomAviReader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAviFile := nil;
  FAviFrame := nil;
  FAviStream := nil;
end;

destructor TCustomAviReader.Destroy;
begin
  Close;
  inherited Destroy;
end;

function TCustomAviReader.Active: boolean;
begin
  Result := (FAviStream <> nil) and (FAviFrame <> nil)
end;

function TCustomAviReader.GetFrameCount: LongInt;
begin
  Result := FAviInfo.dwLength
end;

function TCustomAviReader.GetDuration: cardinal;
begin
  Result := Round((FAviInfo.dwLength/FPS)*1000);
end;

function TCustomAviReader.GetFPS: integer;
begin
  if FAviInfo.dwScale <> 0 then
    Result := Round(FAviInfo.dwRate/FAviInfo.dwScale)
  else
    Result := 0;
end;


function TCustomAviReader.GetWidth: Cardinal;
begin
  Result := FAviInfo.rcFrame.Right - FAviInfo.rcFrame.Left
end;

function TCustomAviReader.GetHeight: Cardinal;
begin
  Result := FAviInfo.rcFrame.Bottom - FAviInfo.rcFrame.Top;
end;

procedure TCustomAviReader.Open(const Filename: string);
var
  iResult: LongWord;
begin
  { Initialize the FAviFile library. }
  AviFileInit;

  { The FAviFileOpen function opens an AVI file }
  iResult := AviFileOpen(FAviFile, PAnsiChar(AnsiString(Filename)), OF_READ + OF_SHARE_DENY_WRITE, nil);
  if iResult <> AVIERR_OK then
    raise Exception.Create(Format('Cannot open AVI file %s.', [Filename]));
  { Open a Stream from the file }
  iResult := AviFileGetStream(FAviFile, FAviStream, streamtypeVIDEO, 0);
  if iResult <> AVIERR_OK then
    raise Exception.Create(Format('Cannot open stream for AVI file %s.', [Filename]));

  { FAviFileInfo obtains information about an AVI file }
  iResult := AviStreamInfo(FAviStream, @FAviInfo, SizeOf(FAviInfo));
  if iResult <> AVIERR_OK then
    raise Exception.Create('Cannot read stream info.');

  FFPS := GetFPS;
  FFrameRate := 1000/FFPS;
  FFrameCount := GetFrameCount;
  FDuration := GetDuration;
  FWidth := GetWidth;
  FHeight := GetHeight;
  {
   Prepares to decompress video frames

   FAviStreamGetFrameOpen returns a GetFrame object that can be used with the
   FAviStreamGetFrame function. If the system cannot find a decompressor that can
   decompress the stream to the given format, or to any RGB format, the function
   returns nil.
  }
  FAviFrame := AviStreamGetFrameOpen(FAviStream, nil);
  if not Assigned(FAviFrame) then
    raise Exception.Create('Cannot find a suitable AVI decompressor.');
end;

procedure TCustomAviReader.Close;
begin
  if Assigned(FAviFile) then
  begin
    AviFileRelease(FAviFile);
    FAviFile := nil;
  end;
  if Assigned(FAviStream) then
  begin
    AviStreamRelease(FAviStream);
    FAviStream := nil;
  end;
  if Assigned(FAviFrame) then
  begin
    AviStreamGetFrameClose(FAviFrame);
    FAviFrame := nil;
  end;
end;

function TCustomAviReader.GetFrame(FrameNumber: Cardinal): TBitmap;
var
  lpbi: PBITMAPINFOHEADER;
  bits: PChar;
  hBmp: HBITMAP;
  TmpBmp: TBitmap;
  DC_Handle: HDC;
begin
  { Read current Frame
    FAviStreamGetFrame Returns the address of a decompressed video frame }
  lpbi := AviStreamGetFrame(FAviFrame, FrameNumber);
  if not Assigned(lpbi) then
    raise Exception.Create('Cannot find the address of a decompressed video frame.');

  TmpBmp := TBitmap.Create;
  try
    TmpBmp.Height := lpbi.biHeight;
    TmpBmp.Width  := lpbi.biWidth;

    bits := Pointer(Integer(lpbi) + SizeOf(TBITMAPINFOHEADER));

    DC_Handle := CreateDC('Display', nil, nil, nil);
    try
      hBmp := CreateDIBitmap(DC_Handle, { handle of device context }
        lpbi^, { address of bitmap size and format data }
        CBM_INIT, { initialization flag }
        bits, { address of initialization data }
        PBITMAPINFO(lpbi)^, { address of bitmap color-format data }
        DIB_RGB_COLORS); { color-data usage }
    finally
      DeleteDC(DC_Handle);
    end;
    TmpBmp.Handle := hBmp;
  finally
    Result := TmpBmp;
  end;
end;

procedure Register;
begin
  RegisterComponents('bonecode', [TAviReader]);
end;

initialization
  AviFileInit;

finalization
  AviFileExit;

end.
