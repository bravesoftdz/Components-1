unit BCButtonedEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls, ExtCtrls, Graphics;

type
  TBCButtonedEdit = class(ExtCtrls.TButtonedEdit)
  private
    { Private declarations }
    FEditColor: TColor;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
  protected
    { Protected declarations }
    procedure Loaded; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property EditColor: TColor read FEditColor write FEditColor;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('bonecode', [TBCButtonedEdit]);
end;

constructor TBCButtonedEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditColor := clInfoBk;
end;

procedure TBCButtonedEdit.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not readonly then
    Color := clWindow;
end;

procedure TBCButtonedEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not readonly then
    Color := FEditColor;
end;

procedure TBCButtonedEdit.Loaded;
begin
  inherited;
  { bug fix }
  Ctl3D := True;
  LeftButton.Visible := not LeftButton.Visible;
  LeftButton.Visible := not LeftButton.Visible;
  RightButton.Visible := not RightButton.Visible;
  RightButton.Visible := not RightButton.Visible;
end;

end.
