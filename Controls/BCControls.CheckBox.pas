unit BCControls.CheckBox;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls;

type
  TBCCheckBox = class(TCheckBox)
  private
    { Private declarations }
    FReadOnly: Boolean;
  protected
    { Protected declarations }
    procedure DoEnter; override;
  published
    { Published declarations }
    constructor Create(AOwner: TComponent); override;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('bonecode', [TBCCheckBox]);
end;

constructor TBCCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReadOnly := False;
end;

procedure TBCCheckBox.DoEnter;
begin
  if not ReadOnly then
    inherited
  else
    Parent.SetFocus
end;

end.
