unit AviWriter;

interface

uses
  Windows, Graphics, Sysutils, Classes, VideoForWindows, MMSystem;

type
  TFourCC = string[4];

  TAviWriter = class(TComponent)
  private
    { Private declarations }
    FAviFile: PAviFile;
    FAviStream: PAviStream;
    FAviCompressedStream: PAviStream;
    FFourCC: TFourCC;
    procedure InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: Integer;
        var ImageSize: longInt; PixelFormat: TPixelFormat);
    function InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
        var BitmapInfo; var Bits; PixelFormat: TPixelFormat): Boolean;
    procedure InitializeBitmapInfoHeader(Bitmap: HBITMAP; var Info: TBitmapInfoHeader;
      PixelFormat: TPixelFormat);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor  Destroy; override;
    procedure StartStream(Filename: string; Scale: Longword; Rate: Longword;
      Quality: Integer; iWidth: integer; iHeight: integer);
    procedure AddBmpToStream(Bitmap: TBitmap; Frame: Integer);
    procedure Close;
    procedure GetCompressorList(const List: TStrings);
    procedure SetCompression(FourCC: TFourCC; iWidth: integer; iHeight: integer);
  end;

procedure Register;

implementation

constructor TAviWriter.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FAviFile := nil;
  FAviStream := nil;
  FAviCompressedStream := nil;
end;

destructor TAviWriter.Destroy;
begin
  Close;
  inherited Destroy;
end;

function FourCCToString(f: DWord): TFourCC;
var
  S, s1: string;
  b: byte;
  c: AnsiChar;
begin
  SetLength(Result, 4);
  S := IntToHex(f, 8);
  s1 := '$' + copy(S, 7, 2);
  b := StrToInt(s1);
  c := AnsiChar(chr(b));
  Result[1] := c;
  Result[2] := AnsiChar(chr(StrToInt('$' + copy(S, 5, 2))));
  Result[3] := AnsiChar(chr(StrToInt('$' + copy(S, 3, 2))));
  Result[4] := AnsiChar(chr(StrToInt('$' + copy(S, 1, 2))));
  //strings are easier than math :)
end;

procedure TAviWriter.SetCompression(FourCC: TFourCC; iWidth: integer; iHeight: integer);
var S: string;
  ic: THandle;
  BitmapInfoHeader: TBitmapInfoHeader;
begin
  fFourCC := '';
  if FourCC = '' then
    exit;
  FillChar(BitmapInfoHeader, SizeOf(BitmapInfoHeader), 0);
  with BitmapInfoHeader do
  begin
    biSize := SizeOf(BitmapInfoHeader);
    biWidth := iWidth;
    biHeight := iHeight;
    biPlanes := 1;
    biCompression := BI_RGB;
    biBitCount := 24;
  end;
  S := string(FourCC);
  ic := ICLocate(ICTYPE_VIDEO, mmioStringToFOURCC(PChar(S), 0), @BitmapInfoHeader, nil,
    ICMODE_COMPRESS);
  if ic <> 0 then
  begin
    fFourCC := FourCC;
    ICClose(ic);
  end
  else
    raise Exception.Create('No compressor for ' + string(FourCC) + ' available');
end;

procedure TAviWriter.GetCompressorList(const List: TStrings);
var
  ii: TICINFO;
  i: DWord;
  ic: THandle;
  BitmapInfoHeader: TBitmapInfoHeader;
  Name: WideString;
  j: integer;

begin
  List.Clear;
  List.add('No Compression');

  FillChar(BitmapInfoHeader, SizeOf(BitmapInfoHeader), 0);
  with BitmapInfoHeader do
  begin
    biSize := SizeOf(BitmapInfoHeader);
    biWidth := 640; // can these be what ever?
    biHeight := 480; // can these be what ever?
    biPlanes := 1;
    biCompression := BI_RGB;
    biBitCount := 24; 
  end;

  ii.dwSize := SizeOf(ii);
  for i := 0 to 200 do // what's a safe number to get all?
  begin
    if ICInfo(ICTYPE_VIDEO, i, @ii) then
    begin
      ic := ICOpen(ICTYPE_VIDEO, ii.fccHandler, ICMODE_QUERY);
      try
        if ic <> 0 then
        begin
          if ICCompressQuery(ic, @BitmapInfoHeader, nil) = 0 then
          begin
            ICGetInfo(ic, @ii, SizeOf(ii));
            //can the following be done any simpler?
            Name := '';
            for j := 0 to 15 do
              Name := Name + ii.szName[j];
            List.add(string(FourCCToString(ii.fccHandler)) + ' ' + string(Name));
          end;
        end;
      finally
        ICClose(ic);
      end;
    end;
  end;
end;
procedure TAviWriter.StartStream(Filename: string; Scale: Longword; Rate: Longword;
  Quality: Integer; iWidth: integer; iHeight: integer);
var
  StreamInfo: TAviStreamInfo;
  AviCompressOptions: TAVICOMPRESSOPTIONS;
  CompVars: TCompVars;
  S: String;
begin
  CompVars.cbSize := SizeOf(TCompVars);
  CompVars.dwFlags := ICMF_COMPVARS_VALID;
  CompVars.fccHandler := comptypeDIB;
  CompVars.lQ := Quality;

  { Write the stream header }
  StreamInfo.fccType := streamtypeVIDEO;

  S := string(fFourCC);
  StreamInfo.fccHandler := mmioStringToFOURCC(PChar(S), 0);;
  StreamInfo.dwFlags := 0;
  StreamInfo.dwCaps := 0;
  StreamInfo.wPriority := 0;
  StreamInfo.wLanguage := 0;
  StreamInfo.dwScale := Scale;
  StreamInfo.dwRate := Rate;        // dwRate / dwScale == samples/second
  StreamInfo.dwStart := 0;
  StreamInfo.dwLength := 0;
  StreamInfo.dwInitialFrames := 0;
  StreamInfo.dwSuggestedBufferSize := 0;
  StreamInfo.dwQuality := Quality;
  StreamInfo.dwSampleSize := 0;
  StreamInfo.rcFrame := Rect(0,0, iWidth, iHeight);
  StreamInfo.dwEditCount := 0;
  StreamInfo.dwFormatChangeCount := 0;
  StreamInfo.szName := 'VIDEO';

  AviCompressOptions.fccType := streamtypeVIDEO;
  AviCompressOptions.fccHandler := StreamInfo.fccHandler;
  AviCompressOptions.dwQuality := CompVars.lQ;

  { Open AVI work file for write }
  if (AVIFileOpen(FAviFile, PAnsiChar(AnsiString(Filename)), OF_WRITE + OF_CREATE, nil) <> AVIERR_OK) then
    raise Exception.Create('Failed to create AVI video file');

  { Open AVI data stream }
  if (AVIFileCreateStream(FAviFile, FaviStream, @StreamInfo) <> AVIERR_OK) then
    raise Exception.Create('Failed to create AVI video stream');

  if AVIMakeCompressedStream(FAviCompressedStream, FAviStream, @AviCompressOptions, nil) <> AVIERR_OK then
    raise Exception.Create('Failed to create compressed AVI video stream');
end;

procedure TAviWriter.AddBmpToStream(Bitmap: TBitmap; Frame: Integer);
var
  BitmapInfoSize: Integer;
  BitmapSize: LongInt;
  BitmapInfo: PBitmapInfoHeader;
  BitmapBits: pointer;
  iResult: LongWord;
  Samples_Written: Longint;
  Bytes_Written: Longint;
begin
  BitmapInfo := nil;
  BitmapBits := nil;
  try
    // Determine size of DIB
    InternalGetDIBSizes(Bitmap.Handle, BitmapInfoSize, BitmapSize, pf24bit);
    if (BitmapInfoSize = 0) then
      raise Exception.Create('Failed to retrieve bitmap info');

    // Get DIB header and pixel buffers
    GetMem(BitmapInfo, BitmapInfoSize);
    GetMem(BitmapBits, BitmapSize);
    InternalGetDIB(Bitmap.Handle, 0, BitmapInfo^, BitmapBits^, pf24bit);

    // On the first time through, set the stream format.
    if Frame = 0 then
      if (AVIStreamSetFormat(FAviCompressedStream, 0, BitmapInfo, BitmapInfoSize) <> AVIERR_OK) then
        raise Exception.Create('Failed to set AVI stream format');

    // Write frame to the video stream
    iResult := AVIStreamWrite(FAviCompressedStream, Frame, 1, BitmapBits, BitmapSize, AVIIF_KEYFRAME,
                             @Samples_Written, @Bytes_Written);
    if iResult <> AVIERR_OK then
      raise Exception.Create(Format('Failed to add frame to AVI. Error %s', [inttohex(iResult,8)]));

  finally
    if (BitmapInfo <> nil) then
      FreeMem(BitmapInfo);
    if (BitmapBits <> nil) then
      FreeMem(BitmapBits);
  end;
end;

procedure TAviWriter.Close;
begin
  if Assigned(FAviFile) then
  begin
    AVIFileRelease(FAviFile);
    FAviFile := nil;
  end;
  if Assigned(FAviStream) then
  begin
    AVIStreamRelease(FAviStream);
    FAviStream := nil;
  end;
  if Assigned(FAviCompressedStream) then
  begin
    AVIStreamRelease(FAviCompressedStream);
    FAviCompressedStream := nil;
  end;
end;

procedure Register;
begin
  RegisterComponents('bonecode', [TAviWriter]);
end;

// --------------
// InternalGetDIB
// --------------
// Converts a bitmap to a DIB of a specified PixelFormat.
//
// Parameters:
// Bitmap	The handle of the source bitmap.
// Pal		The handle of the source palette.
// BitmapInfo	The buffer that will receive the DIB's TBitmapInfo structure.
//		A buffer of sufficient size must have been allocated prior to
//		calling this function.
// Bits		The buffer that will receive the DIB's pixel data.
//		A buffer of sufficient size must have been allocated prior to
//		calling this function.
// PixelFormat	The pixel format of the destination DIB.
//
// Returns:
// True on success, False on failure.
//
// Note: The InternalGetDIBSizes function can be used to calculate the
// nescessary sizes of the BitmapInfo and Bits buffers.
//
function TAviWriter.InternalGetDIB(Bitmap: HBITMAP; Palette: HPALETTE;
  var BitmapInfo; var Bits; PixelFormat: TPixelFormat): Boolean;
// From graphics.pas, "optimized" for our use
var
  OldPal	: HPALETTE;
  DC		: HDC;
begin
  InitializeBitmapInfoHeader(Bitmap, TBitmapInfoHeader(BitmapInfo), PixelFormat);
  OldPal := 0;
  DC := CreateCompatibleDC(0);
  try
    if (Palette <> 0) then
    begin
      OldPal := SelectPalette(DC, Palette, False);
      RealizePalette(DC);
    end;
    Result := (GetDIBits(DC, Bitmap, 0, abs(TBitmapInfoHeader(BitmapInfo).biHeight),
      @Bits, TBitmapInfo(BitmapInfo), DIB_RGB_COLORS) <> 0);
  finally
    if (OldPal <> 0) then
      SelectPalette(DC, OldPal, False);
    DeleteDC(DC);
  end;
end;

// -------------------
// InternalGetDIBSizes
// -------------------
// Calculates the buffer sizes nescessary for convertion of a bitmap to a DIB
// of a specified PixelFormat.
// See the GetDIBSizes API function for more info.
//
// Parameters:
// Bitmap	The handle of the source bitmap.
// InfoHeaderSize
//		The returned size of a buffer that will receive the DIB's
//		TBitmapInfo structure.
// ImageSize	The returned size of a buffer that will receive the DIB's
//		pixel data.
// PixelFormat	The pixel format of the destination DIB.
//
procedure TAviWriter.InternalGetDIBSizes(Bitmap: HBITMAP; var InfoHeaderSize: Integer;
  var ImageSize: longInt; PixelFormat: TPixelFormat);
// From graphics.pas, "optimized" for our use
var
  Info		: TBitmapInfoHeader;
begin
  InitializeBitmapInfoHeader(Bitmap, Info, PixelFormat);
  // Check for palette device format
  if (Info.biBitCount > 8) then
  begin
    // Header but no palette
    InfoHeaderSize := SizeOf(TBitmapInfoHeader);
    if ((Info.biCompression and BI_BITFIELDS) <> 0) then
      Inc(InfoHeaderSize, 12);
  end else
    // Header and palette
    InfoHeaderSize := SizeOf(TBitmapInfoHeader) + SizeOf(TRGBQuad) * (1 shl Info.biBitCount);
  ImageSize := Info.biSizeImage;
end;

procedure TAviWriter.InitializeBitmapInfoHeader(Bitmap: HBITMAP; var Info: TBitmapInfoHeader;
  PixelFormat: TPixelFormat);
// From graphics.pas, "optimized" for our use
var
  DIB		: TDIBSection;
  Bytes		: Integer;
  function AlignBit(Bits, BitsPerPixel, Alignment: Cardinal): Cardinal;
  begin
    Dec(Alignment);
    Result := ((Bits * BitsPerPixel) + Alignment) and not Alignment;
    Result := Result SHR 3;
  end;
begin
  DIB.dsbmih.biSize := 0;
  Bytes := GetObject(Bitmap, SizeOf(DIB), @DIB);
  if (Bytes = 0) then
    raise Exception.Create('Invalid bitmap');
//    Error(sInvalidBitmap);

  if (Bytes >= (sizeof(DIB.dsbm) + sizeof(DIB.dsbmih))) and
    (DIB.dsbmih.biSize >= sizeof(DIB.dsbmih)) then
    Info := DIB.dsbmih
  else
  begin
    FillChar(Info, sizeof(Info), 0);
    with Info, DIB.dsbm do
    begin
      biSize := SizeOf(Info);
      biWidth := bmWidth;
      biHeight := bmHeight;
    end;
  end;
  case PixelFormat of
    pf1bit: Info.biBitCount := 1;
    pf4bit: Info.biBitCount := 4;
    pf8bit: Info.biBitCount := 8;
    pf24bit: Info.biBitCount := 24;
  else
    raise Exception.Create('Invalid pixel foramt');
  end;
  Info.biPlanes := 1;
  Info.biCompression := BI_RGB; // Always return data in RGB format
  Info.biSizeImage := AlignBit(Info.biWidth, Info.biBitCount, 32) * Cardinal(abs(Info.biHeight));
end;

initialization
  AviFileInit;

finalization
  AviFileExit;

end.
