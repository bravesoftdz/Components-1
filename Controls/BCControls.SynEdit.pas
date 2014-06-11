unit BCControls.SynEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, SynEdit, SynHighlighterWebData, SynMacroRecorder,
  SynEditKeyCmds, Winapi.Messages, SynCompletionProposal;

type
  TBCSynEdit = class(TSynEdit)
  private
    FDocumentName: string;
    FFileDateTime: TDateTime;
    FHtmlVersion: TSynWebHtmlVersion;
    FSearchString: string;
    FSynMacroRecorder: TSynMacroRecorder;
    FEncoding: TEncoding;
  protected
    procedure DoOnProcessCommand(var Command: TSynEditorCommand; var AChar: WideChar; Data: pointer); override;
  public
    class constructor Create;
    destructor Destroy; override;
    function SplitTextIntoWords(SynCompletionProposal: TSynCompletionProposal; CaseSensitive: Boolean): string;
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);
    property DocumentName: string read FDocumentName write FDocumentName;
    property FileDateTime: TDateTime read FFileDateTime write FFileDateTime;
    property HtmlVersion: TSynWebHtmlVersion read FHtmlVersion write FHtmlVersion;
    property SearchString: string read FSearchString write FSearchString;
    property SynMacroRecorder: TSynMacroRecorder read FSynMacroRecorder write FSynMacroRecorder;
    property Encoding: TEncoding read FEncoding write FEncoding;
  end;

procedure Register;

implementation

uses
  Winapi.Windows, SynUnicode, BCControls.StyleHooks, Vcl.Themes, BCCommon.Encoding, SynEditTypes, SynEditTextBuffer;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCSynEdit]);
end;

class constructor TBCSynEdit.Create;
begin
  if Assigned(TStyleManager.Engine) then
    TStyleManager.Engine.RegisterStyleHook(TCustomSynEdit, TSynEditStyleHook);
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

function TBCSynEdit.SplitTextIntoWords(SynCompletionProposal: TSynCompletionProposal; CaseSensitive: Boolean): string;
var
  i: Integer;
  S, Word: string;
  StringList: TStringList;
  startpos, endpos: Integer;
  KeywordStringList: TStrings;
begin
  Result := '';
  S := Text;
  SynCompletionProposal.ItemList.Clear;
  startpos := 1;
  KeywordStringList := TStringList.Create;
  StringList := TStringList.Create;
  StringList.CaseSensitive := CaseSensitive;
  try
    { add document words }
    while startpos <= Length(S) do
    begin
      while (startpos <= Length(S)) and not IsCharAlpha(S[startpos]) do
        Inc(startpos);
      if startpos <= Length(S) then
      begin
        endpos := startpos + 1;
        while (endpos <= Length(S)) and IsCharAlpha(S[endpos]) do
          Inc(endpos);
        Word := Copy(S, startpos, endpos - startpos);
        if endpos - startpos > Length(Result) then
          Result := Word;
        if StringList.IndexOf(Word) = -1 then { no duplicates }
          StringList.Add(Word);
        startpos := endpos + 1;
      end;
    end;
    { add highlighter keywords }
    Highlighter.AddKeywords(KeywordStringList);
    for i := 0 to KeywordStringList.Count - 1 do
    begin
      Word := KeywordStringList.Strings[i];
      if Length(Word) > Length(Result) then
        Result := Word;
      if StringList.IndexOf(Word) = -1 then { no duplicates }
        StringList.Add(Word);
    end;
  finally
    StringList.Sort;
    SynCompletionProposal.ItemList.Assign(StringList);
    StringList.Free;
    if Assigned(KeywordStringList) then
      KeywordStringList.Free;
  end;
end;

end.
