unit BCControls.SpinEdit;

interface

uses
  System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Mask, JvExMask, JvSpin, Vcl.Graphics, Winapi.Messages;

type
  TBCSpinEdit = class(TJvSpinEdit)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation



procedure Register;
begin
  RegisterComponents('bonecode', [TBCSpinEdit]);
end;

end.
