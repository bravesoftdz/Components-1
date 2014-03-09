unit BCControls.ButtonedEdit;

interface

uses
  Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TBCButtonedEdit = class(TButtonedEdit)
  private
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  end;

procedure Register;

implementation

uses
  Vcl.Themes, Vcl.Graphics;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCButtonedEdit]);
end;

procedure TBCButtonedEdit.WMPaint(var Message: TWMPaint);
var
  LStyles: TCustomStyleServices;
begin
  LStyles := StyleServices;

  if LStyles.Enabled then
    Color := LStyles.GetStyleColor(scEdit)
  else
    Color := clWindow;

  inherited;
end;

end.
