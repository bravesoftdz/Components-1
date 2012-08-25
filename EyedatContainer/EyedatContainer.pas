unit EyedatContainer;

interface

uses
  Classes, JclShell, Windows, Sysutils, dialogs;

type
  TDataItem = record
    vert_eye_pos: SmallInt;
    horz_eye_pos: SmallInt;
    pupil_diameter: ShortInt;
  end;

  TCustomEyedatContainer = class(TComponent)
  private
    FFPS: SmallInt;
    FDuration: LongInt;
    FMaxPupil: ShortInt;
    FCount: integer;
    FFrameRate: Double;
  protected
    function GetItem(szLine: String): TDataItem;
    function GetMaxPupil: ShortInt;
    function GetDuration: Longword;
    property MaxPupil: ShortInt read FMaxPupil;
    property Count: integer read FCount;
    property FPS: SmallInt read FFPS;
    property Duration: LongInt read FDuration;
    property FrameRate: Double read FFrameRate;
  public
    EDTOrigData: array of TDataItem;
    EDTData: array of TDataItem;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Active: boolean;
    function GetVertEyePos(index: integer): SmallInt;
    function GetHorzEyePos(index: integer): SmallInt;
    function GetPupilDiameter(index: integer): ShortInt;
    procedure Open(szFilename: String);
    procedure Close;
    procedure ScaleEyedata(SrcWidth: integer; SrcHeight: integer;
      DstWidth: integer; DstHeight: integer);
  end;

  TEyedatContainer = class(TCustomEyedatContainer)
  published
    property MaxPupil;
    property Count;
    property FPS;
    property Duration;
    property FrameRate;
  end;

procedure Register;

implementation

uses ETDFileInput;

constructor TCustomEyedatContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  EDTData := nil;
  EDTOrigData := nil;
end;

destructor TCustomEyedatContainer.Destroy;
begin
  Close;
  inherited Destroy;
end;

function TCustomEyedatContainer.Active: boolean;
begin
  Result := (EDTData <> nil)
end;

procedure TCustomEyedatContainer.Open(szFilename: String);
var
  edt_file: TEdtfio_File_Parameters;
  edt_field: TEdtfio_Field;
  edt_rv: integer;
  StringList: TStringList;
  i: integer;
begin
  edt_rv := ETDFileInput.open_file_for_reading(PAnsiChar(AnsiString(szFilename)), edt_file);
  if edt_rv <> 0 then
    ETDFileInput.process_edt_error(szFilename, edt_rv);

  FFPS := edt_file.update_rate;
  FFrameRate := 1000/FFPS;

  edt_field.segment_number := 1;
  { we can't get the rowcount, so we read lines into StringList at first }
  StringList := TStringList.Create;

  repeat
    edt_rv := ETDFileInput.edtfio_read_field( edt_file, edt_field );
    if edt_rv = EDTFIO_NO_ERROR then
      StringList.Add(inttostr(edt_field.vert_eye_pos)+';'+inttostr(edt_field.horz_eye_pos)+';'+inttostr(edt_field.pupil_diameter)+';');
  until edt_rv <> EDTFIO_NO_ERROR;

  if (edt_rv <> EDTFIO_END_OF_FILE) then
		ETDFileInput.process_edt_error(szFilename, edt_rv);

  edt_rv := ETDFileInput.close_file_after_reading(edt_file);

  if (edt_rv <> EDTFIO_NO_ERROR) then
		ETDFileInput.process_edt_error(szFilename, edt_rv);

  SetLength(EDTData, StringList.Count);
  SetLength(EDTOrigData, StringList.Count);
  
  for i := 0 to StringList.Count - 1 do
    EDTData[i] := getItem(StringList.Strings[i]);

  for i := 0 to Length(EDTData) - 1 do
    EDTOrigData[i] := EDTData[i];
  StringList.Free;

  FCount := Length(EDTData);
  FMaxPupil := getMaxPupil;
  FDuration := GetDuration;
end;

function TCustomEyedatContainer.GetDuration: Longword;
begin
  if FFPS <> 0 then
    Result := Round((FCount / FFPS) * 1000)
  else Result := 0
end;

function TCustomEyedatContainer.GetVertEyePos(index: integer): SmallInt;
begin
  Result := EDTData[index].vert_eye_pos
end;

function TCustomEyedatContainer.GetHorzEyePos(index: integer): SmallInt;
begin
  Result := EDTData[index].horz_eye_pos
end;

function TCustomEyedatContainer.GetPupilDiameter(index: integer): ShortInt;
begin
  Result := EDTData[index].pupil_diameter
end;

function TCustomEyedatContainer.getItem(szLine: String): TDataItem;
var
  DataItem: TDataItem;
  szText: String;

  function GetToken(var Text : string): string;
  var
    nPos : integer;
  begin
    nPos := pos(';', Text);
    if nPos > 0 then
      begin
        Result := Copy(Text, 1, nPos-1);
        Text := Copy(Text, nPos+1, Length(Text));
      end
    else
      begin
        Result := Text;
        Text := '';
      end;
  end;
begin
  szText := szLine;
  DataItem.vert_eye_pos := StrToInt(GetToken(szText));
  DataItem.horz_eye_pos := StrToInt(GetToken(szText));
  DataItem.pupil_diameter := StrToInt(GetToken(szText));

  Result := DataItem;
end;

function TCustomEyedatContainer.getMaxPupil: ShortInt;
var
  i: integer;
  iMax: ShortInt;
begin
  iMax := 0;
  for i := 0 to Length(EDTData) - 1 do
    if iMax < EDTData[i].pupil_diameter then
      iMax := EDTData[i].pupil_diameter;

  Result := iMax;
end;

procedure TCustomEyedatContainer.ScaleEyedata(SrcWidth: integer; SrcHeight: integer;
      DstWidth: integer; DstHeight: integer);
var
  i: integer;
  ScaleX, ScaleY: Double;
begin
  ScaleX := DstWidth/SrcWidth;
  ScaleY := DstHeight/SrcHeight;
  for i := 0 to Length(EDTData) - 1 do
  begin
    EDTData[i].horz_eye_pos := Round(EDTOrigData[i].horz_eye_pos*ScaleX);
    EDTData[i].vert_eye_pos := Round(EDTOrigData[i].vert_eye_pos*ScaleY);
  end;
end;

procedure TCustomEyedatContainer.Close;
begin
  if Assigned(EDTData) then
  begin
    { free EDTData array }
    Finalize(EDTData);
    Finalize(EDTOrigData);
    EDTData := nil;
  end;
end;

procedure Register;
begin
  RegisterComponents('bonecode', [TEyedatContainer]);
end;

end.
