unit BCPopupMenu;

interface

uses
  SysUtils, Classes, Vcl.ActnPopup, ImgList;

type
  TBCPopupMenu = class(Vcl.ActnPopup.TPopupActionBar)
  protected
    { Protected declarations }
    procedure DoPopup(Sender: TObject); override;
  end;

procedure Register;

implementation

uses
  Graphics;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCPopupMenu]);
end;

procedure TBCPopupMenu.DoPopup(Sender: TObject);
begin
  inherited;

end;

end.
