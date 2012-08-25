unit HelpSystem;

interface

uses
  Windows, Classes, hh, hh_funcs;

type
  TCustomHelpSystem = class(TComponent)
  private
    FHelpfile: string;
    FHHelp: THookHelpSystem;
    function GetActive: Boolean;
    procedure SetActive(Value: Boolean);
  protected
    property Active: Boolean read GetActive write SetActive default False;
    property Helpfile: string read FHelpfile write FHelpfile;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open(Topic: integer); overload;
    procedure Open; overload;
  end;

  THelpSystem = class(TCustomHelpSystem)
  published
    property Active;
    property Helpfile;
  end;

procedure Register;

implementation

constructor TCustomHelpSystem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHHelp := nil;
end;

destructor TCustomHelpSystem.Destroy;
begin
  if Assigned(FHHelp) then
  begin
    FHHelp.Free;
    FHHelp := nil;
  end;
  HHCloseAll;
  inherited Destroy;
end;

function TCustomHelpSystem.GetActive: Boolean;
begin
  Result := Assigned(FHHelp);
end;

procedure TCustomHelpSystem.SetActive(Value: Boolean);
begin
  if Active <> Value then
  begin
    if Value then
      FHHelp := THookHelpSystem.Create(FHelpFile,'',htHHAPI)
    else
    begin
      FHHelp.Free;
      FHHelp := nil;
    end;
  end;
end;

procedure TCustomHelpSystem.Open;
begin
  HtmlHelp(GetDesktopWindow, PChar(FHHelp.ChmFile), HH_DISPLAY_TOPIC, 0);
end;

procedure TCustomHelpSystem.Open(Topic: integer);
begin
  HtmlHelp(GetDesktopWindow, PChar(FHelpFile), HH_HELP_CONTEXT, Topic);
end;

procedure Register;
begin
  RegisterComponents('bonecode', [THelpSystem]);
end;

end.
