unit BCControls.DBGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, DBGridEhGrouping, ToolCtrlsEh, DBGridEhToolCtrls, GridsEh,
  DBAxisGridsEh, DBGridEh;

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
