unit BCDBComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls;

type
  TBCDBComboBox = class(TDBComboBox)
  private
    { Private declarations }
    FEditColor: TColor;
    FDKS: Boolean;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure SetEditable(Value: Boolean);
  protected
    { Protected declarations }
    procedure KeyPress(var Key: Char); override;
    procedure DropDown; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
  published
    { Published declarations }
    property EditColor: TColor read FEditColor write FEditColor;
    property DeniedKeyStrokes: Boolean read FDKS write FDKS;
    property Editable: Boolean write SetEditable;
  end;

procedure Register;

implementation

resourcestring
  TEXT_SET_VALUE = 'Set value %s.';

procedure Register;
begin
  RegisterComponents('bonecode', [TBCDBComboBox]);
end;

procedure TBCDBComboBox.KeyPress(var Key: Char);
begin
  inherited;
  if FDKS then
    Key := #0;
end;

procedure TBCDBComboBox.DropDown;
var
  Form: TWinControl;
begin
  if Readonly then
  begin
    Form := Self.parent;
    Form.SetFocus
  end
  else
    inherited;
end;

constructor TBCDBComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditColor := clInfoBk;
end;

procedure TBCDBComboBox.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not ReadOnly then
    Color := clwindow;
end;

procedure TBCDBComboBox.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not ReadOnly then
    Color := FEditColor;
end;

procedure TBCDBComboBox.SetEditable(Value: Boolean);
begin
  if Value then
  begin
    Color := clWindow;
    ReadOnly := False;
    TabStop := True;
  end
  else
  begin
    Color := clBtnFace;
    ReadOnly := True;
    TabStop := False;
  end;
end;

function TBCDBComboBox.IsEmpty: Boolean;
begin
  Result := False;
  if Trim(Text) = '' then
  begin
    MessageDlg(Format(TEXT_SET_VALUE, [LowerCase(Hint)]), mtError, [mbOK], 0);
    try
      SetFocus;
    except
    end;
    exit;
  end;
  Result := True;
end;

end.
