unit BCControls.DBGrid;

interface

uses
  System.Classes, GridsEh, Vcl.Menus, Vcl.Dialogs, DBAxisGridsEh, DBGridEh;

type
  TBCDBGrid = class(TDBGridEh)
  private
    { Private declarations }
    FPopupMenu: TPopupMenu;
    FSaveDialog: TSaveDialog;
    procedure OnClickSelectAll(Sender: TObject);
    procedure OnClickUnselectAll(Sender: TObject);
    procedure OnClickSaveAs(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure Register;

implementation

uses
  DBGridEhImpExp, System.SysUtils;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCDBGrid]);
end;

constructor TBCDBGrid.Create(AOwner: TComponent);
var
  MenuItem: TMenuItem;
begin
  inherited Create(AOwner);

  FPopupMenu := TPopupMenu.Create(Self);
  if gioShowRowselCheckboxesEh in IndicatorOptions then
  begin
    { Select all }
    MenuItem := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := 'Select all';
    MenuItem.OnClick := OnClickSelectAll;
    FPopupMenu.Items.Add(MenuItem);
    { Unselect all }
    MenuItem := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := 'Unselect all';
    MenuItem.OnClick := OnClickUnselectAll;
    FPopupMenu.Items.Add(MenuItem);
    { Separator }
    MenuItem := TMenuItem.Create(FPopupMenu);
    MenuItem.Caption := '-';
    FPopupMenu.Items.Add(MenuItem);
  end;
  { Unselect all }
  MenuItem := TMenuItem.Create(FPopupMenu);
  MenuItem.Caption := 'Save as...';
  MenuItem.OnClick := OnClickSaveAs;
  FPopupMenu.Items.Add(MenuItem);

  IndicatorTitle.ShowDropDownSign := True;
  IndicatorTitle.TitleButton := True;
  IndicatorTitle.UseGlobalMenu := False;
  IndicatorTitle.DropdownMenu := FPopupMenu;

  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.FileName := 'data';
  FSaveDialog.Filter :=
      'Text files (*.txt)|*.TXT|Comma separated values (*.csv)|*.CSV|HTML file (*.htm)|*.HTM|Rich Text Format (*.rtf)' +
      '|*.RTF|Microsoft Excel Workbook (*.xls)|*.XLS';
end;

destructor TBCDBGrid.Destroy;
begin
  while FPopupMenu.Items.Count > 0 do
    FPopupMenu.Items[0].Free;
  FPopupMenu.Free;
  FSaveDialog.Free;
  inherited;
end;

procedure TBCDBGrid.OnClickSelectAll(Sender: TObject);
begin
  SelectedRows.SelectAll;
end;

procedure TBCDBGrid.OnClickUnselectAll(Sender: TObject);
begin
  SelectedRows.Clear;
end;

procedure TBCDBGrid.OnClickSaveAs(Sender: TObject);
var
  ExpClass: TDBGridEhExportClass;
  Ext: string;
begin
  if FSaveDialog.Execute then
  begin
    case FSaveDialog.FilterIndex of
      1:
        begin
          ExpClass := TDBGridEhExportAsText;
          Ext := 'txt';
        end;
      2:
        begin
          ExpClass := TDBGridEhExportAsCSV;
          Ext := 'csv';
        end;
      3:
        begin
          ExpClass := TDBGridEhExportAsHTML;
          Ext := 'htm';
        end;
      4:
        begin
          ExpClass := TDBGridEhExportAsRTF;
          Ext := 'rtf';
        end;
      5:
        begin
          ExpClass := TDBGridEhExportAsXLS;
          Ext := 'xls';
        end;
    else
      ExpClass := nil;
      Ext := '';
    end;
    if ExpClass <> nil then
    begin
      if UpperCase(Copy(FSaveDialog.FileName, Length(FSaveDialog.FileName) - 2, 3)) <> UpperCase(Ext) then
        FSaveDialog.FileName := FSaveDialog.FileName + '.' + Ext;
      SaveDBGridEhToExportFile(ExpClass, Self, FSaveDialog.FileName, False);
    end;
  end;
end;

end.
