unit BCDBGrid;

{ Fix: DBGridEh.pas
  3809: AColor := clBtnShadow; => AColor := HighlightColor; }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, DBGridEh;

type
  TBCDBGrid = class(TDBGridEh)
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
  RegisterComponents('bonecode', [TBCDBGrid]);
end;

end.
