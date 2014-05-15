unit BCControls.RadioButton;

interface

uses
  System.SysUtils, System.Classes, JvRadioButton;

type
  TBCRadioButton = class(TJvRadioButton)
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('bonecode', [TBCRadioButton]);
end;

end.
