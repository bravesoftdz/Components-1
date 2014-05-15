unit BCControls.CheckBox;

interface

uses
  Winapi.Messages, System.SysUtils, System.Classes, JvCheckBox;

type
  TBCCheckBox = class(TJvCheckBox)
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('bonecode', [TBCCheckBox]);
end;

end.
