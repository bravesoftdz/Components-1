unit BCControls.SynEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, SynEdit, SynHighlighterWebData, SynMacroRecorder,
  SynEditKeyCmds, Winapi.Messages;

type
  TBCSynEdit = class(TSynEdit)
  private
    FDocumentName: string;
    FFileDateTime: TDateTime;
    FHtmlVersion: TSynWebHtmlVersion;
    FSynMacroRecorder: TSynMacroRecorder;
    FEncoding: TEncoding;
  protected
    procedure DoOnProcessCommand(var Command: TSynEditorCommand; var AChar: WideChar; Data: pointer); override;
  public
    class constructor Create;
    class destructor Destroy;
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);
    property DocumentName: string read FDocumentName write FDocumentName;
    property FileDateTime: TDateTime read FFileDateTime write FFileDateTime;
    property HtmlVersion: TSynWebHtmlVersion read FHtmlVersion write FHtmlVersion;
    property SynMacroRecorder: TSynMacroRecorder read FSynMacroRecorder write FSynMacroRecorder;
    property Encoding: TEncoding read FEncoding write FEncoding;
  end;

procedure Register;

implementation

uses
  SynUnicode, BCControls.StyleHooks, Vcl.Themes, BCCommon.Encoding, SynEditTypes, SynEditTextBuffer;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCSynEdit]);
end;

class constructor TBCSynEdit.Create;
begin
  TStyleManager.Engine.RegisterStyleHook(TCustomSynEdit, TSynEditStyleHook);
end;

class destructor TBCSynEdit.Destroy;
begin
  TStyleManager.Engine.UnRegisterStyleHook(TCustomSynEdit, TSynEditStyleHook);
end;

destructor TBCSynEdit.Destroy;
begin
  if Assigned(FSynMacroRecorder) then
    FSynMacroRecorder.Free;
  inherited;
end;

procedure TBCSynEdit.LoadFromFile(const FileName: String);
var
  i: Integer;
  LFileStream: TFileStream;
  LBuffer: TBytes;
  WithBom: Boolean;
begin
  FEncoding := nil;
  LFileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    // Identify encoding
    if SynUnicode.IsUTF8(LFileStream, WithBom) then
    begin
      if WithBom then
        FEncoding := TEncoding.UTF8
      else
        FEncoding := TEncoding.UTF8WithoutBOM;
    end
    else
    begin
      // Read file into buffer
      SetLength(LBuffer, LFileStream.Size);
      LFileStream.ReadBuffer(Pointer(LBuffer)^, Length(LBuffer));
      TEncoding.GetBufferEncoding(LBuffer, FEncoding);
    end;
  finally
    LFileStream.Free;
  end;
  Lines.LoadFromFile(FileName, FEncoding);
  for i := 0 to ExpandLines.Count - 1 do
    ExpandLines.Attributes[i].aLineState := lsNone;
end;

procedure TBCSynEdit.SaveToFile(const FileName: String);
begin
  Lines.SaveToFile(FileName, FEncoding);
end;

procedure TBCSynEdit.DoOnProcessCommand(var Command: TSynEditorCommand; var AChar: WideChar;
  Data: pointer);
begin
  inherited;
  if Assigned(FSynMacroRecorder) then
    if FSynMacroRecorder.State = msRecording then
      FSynMacroRecorder.AddEvent(Command, AChar, Data);
end;

end.
