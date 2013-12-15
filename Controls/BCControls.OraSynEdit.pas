unit BCControls.OraSynEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, SynEdit, Ora, SynCompletionProposal;

type
  TBCOraSynEdit = class(TSynEdit)
  private
    FDocumentName: string;
    FFileDateTime: TDateTime;
    FOraQuery: TOraQuery;
    FPlanQuery: TOraQuery;
    FOraSQL: TOraSQL;
    FStartTime: TDateTime;
    FObjectCompletionProposal: TSynCompletionProposal;
    FObjectFieldCompletionProposal: TSynCompletionProposal;
    FInThread: Boolean;
    FEncoding: TEncoding;
    function GetQueryOpened: Boolean;
  public
    //class constructor Create;
    //class destructor Destroy;
    constructor Create(AOwner: TComponent); override;
    procedure LoadFromFile(const FileName: String);
    procedure SaveToFile(const FileName: String);
    property InThread: Boolean read FInThread write FInThread;
    property DocumentName: string read FDocumentName write FDocumentName;
    property FileDateTime: TDateTime read FFileDateTime write FFileDateTime;
    property StartTime: TDateTime read FStartTime write FStartTime;
    property QueryOpened: Boolean read GetQueryOpened;
    property ObjectCompletionProposal: TSynCompletionProposal read FObjectCompletionProposal write FObjectCompletionProposal;
    property ObjectFieldCompletionProposal: TSynCompletionProposal read FObjectFieldCompletionProposal write FObjectFieldCompletionProposal;
    property PlanQuery: TOraQuery read FPlanQuery write FPlanQuery;
    property OraQuery: TOraQuery read FOraQuery write FOraQuery;
    property OraSQL: TOraSQL read FOraSQL write FOraSQL;
  end;

procedure Register;

implementation

uses
  SynUnicode, BCCommon.Encoding, SynEditTextBuffer;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCOraSynEdit]);
end;

{class constructor TBCOraSynEdit.Create;
begin
  TStyleManager.Engine.RegisterStyleHook(TBCOraSynEdit, TSynEditStyleHook);
end;

class destructor TBCOraSynEdit.Destroy;
begin
  TStyleManager.Engine.UnRegisterStyleHook(TBCOraSynEdit, TSynEditStyleHook);
end; }

constructor TBCOraSynEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 0;
  Height := 0;
end;

function TBCOraSynEdit.GetQueryOpened: Boolean;
begin
  Result := (not InThread) and Assigned(FOraQuery) and FOraQuery.Session.Connected and FOraQuery.Active;
end;

procedure TBCOraSynEdit.LoadFromFile(const FileName: String);
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

procedure TBCOraSynEdit.SaveToFile(const FileName: String);
begin
  Lines.SaveToFile(FileName, FEncoding);
end;

end.
