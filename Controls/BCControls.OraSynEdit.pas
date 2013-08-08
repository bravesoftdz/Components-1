unit BCControls.OraSynEdit;

interface

uses
  Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls, SynEdit, SynEditKeyCmds,
  Ora, SynCompletionProposal;

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
    function GetQueryOpened: Boolean;
  public
    {$if CompilerVersion >= 23 }
    //class constructor Create;
    {$endif}
    constructor Create(AOwner: TComponent); override;
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
  SynUnicode, BCControls.StyleHooks, Vcl.Themes;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCOraSynEdit]);
end;

{$if CompilerVersion >= 23 }
{class constructor TBCOraSynEdit.Create;
begin
  TStyleManager.Engine.RegisterStyleHook(TCustomSynEdit, TSynEditStyleHook);
end; }
{$endif}

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

end.
