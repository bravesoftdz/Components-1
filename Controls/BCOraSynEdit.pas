unit BCOraSynEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, SynEdit, SynEditKeyCmds, Vcl.StdCtrls,
  Winapi.Messages, Ora, SynCompletionProposal;

type
  TSynEditStyleHook = class(TMemoStyleHook)
  strict private
    procedure UpdateColors;
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
  strict protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

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
    class constructor Create;
    {$ifend}
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
  SynUnicode, Winapi.Windows, Vcl.Themes;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCOraSynEdit]);
end;

{ TSynEditStyleHook }

constructor TSynEditStyleHook.Create(AControl: TWinControl);
begin
  inherited;
  OverridePaintNC := True;
  OverrideEraseBkgnd := True;
  UpdateColors;
end;

procedure TSynEditStyleHook.WMEraseBkgnd(var Message: TMessage);
begin
  Handled := True;
end;

procedure TSynEditStyleHook.UpdateColors;
const
  ColorStates: array[Boolean] of TStyleColor = (scEditDisabled, scEdit);
  FontColorStates: array[Boolean] of TStyleFont = (sfEditBoxTextDisabled, sfEditBoxTextNormal);
var
  LStyle: TCustomStyleServices;
begin
  LStyle := StyleServices;
  Brush.Color := LStyle.GetStyleColor(ColorStates[Control.Enabled]);
  FontColor := LStyle.GetStyleFontColor(FontColorStates[Control.Enabled]);
end;

procedure TSynEditStyleHook.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CM_ENABLEDCHANGED:
      begin
        UpdateColors;
        Handled := False; // Allow control to handle message
      end
  else
    inherited WndProc(Message);
  end;
end;

{$if CompilerVersion >= 23 }
class constructor TBCOraSynEdit.Create;
begin
  TStyleManager.Engine.RegisterStyleHook(TCustomSynEdit, TSynEditStyleHook);
end;
{$ifend}

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
