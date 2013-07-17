unit BCControls.SpinEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Mask, JvExMask, JvSpin, Vcl.Graphics, Winapi.Messages;

type
  TBCSpinEdit = class(TJvSpinEdit)
  private
    { Private declarations }
    FEditColor: TColor;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
  protected
    { Protected declarations }
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
  RegisterComponents('bonecode', [TBCSpinEdit]);
end;

constructor TBCSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditColor := clInfoBk;
end;

procedure TBCSpinEdit.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not ReadOnly then
    Color := clwindow;
end;

procedure TBCSpinEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not ReadOnly then
    Color := FEditColor;
end;

end.
