unit BCControls.ComboBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Vcl.StdCtrls, Dialogs;

type
  TBCComboBox = class(TComboBox)
  private
    { Private declarations }
    FItemWidth : Integer;
    FDropDownFixedWidth: Integer;
    FEditColor: TColor;
    FDKS: Boolean;
    FReadOnly: Boolean;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure SetDropDownFixedWidth(const Value: Integer);
    function GetTextWidth(s: string): Integer;
  protected
    { Protected declarations }
    procedure SetEditable(Value: Boolean);
    procedure KeyPress(var Key: Char); override;
    procedure DropDown; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
    property ItemWidth: Integer read FItemWidth write FItemWidth;
  published
    { Published declarations }
    property EditColor: TColor read FEditColor write FEditColor;
    property DeniedKeyStrokes: Boolean read FDKS write FDKS;
    //property TextCompletion: Boolean read GetTextCompletion write SetTextCompletion;
    property Editable: Boolean write SetEditable;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property DropDownFixedWidth: Integer read FDropDownFixedWidth write SetDropDownFixedWidth;
  end;

procedure Register;

implementation

uses
  System.UITypes;

resourcestring
  TEXT_SET_VALUE = 'Set value %s.';

procedure Register;
begin
  RegisterComponents('bonecode', [TBCComboBox]);
end;

constructor TBCComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditColor := clInfoBk;
  ReadOnly := False;
end;

procedure TBCComboBox.KeyPress(var Key: Char);
begin
  if FDKS or ReadOnly then
    Key := #0
  else
    inherited;
end;

procedure TBCComboBox.CMEnter(var Message: TCMEnter);
begin
  inherited;
  if not Readonly then
    Color := FEditColor
end;

procedure TBCComboBox.CMExit(var Message: TCMExit);
begin
  inherited;
  if not Readonly then
    Color := clwindow;
end;

procedure TBCComboBox.SetEditable(Value: Boolean);
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

function TBCComboBox.IsEmpty: Boolean;
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

procedure TBCComboBox.DropDown;
var
  I : Integer;
begin
  inherited DropDown;
  ItemWidth := 0;
  {Check to see if DropDownFixed Width > 0. Then just set the
   width of the list box. Otherwise, loop through the items
   and set the width of the list box to 8 pixels > than the
   widest string to buffer the right side. Anything less than
   8 for some reason touches the end of the item on high-res
   monitor settings.}
  if (FDropDownFixedWidth > 0) then
    Self.Perform(CB_SETDROPPEDWIDTH, FDropDownFixedWidth, 0)
  else
    begin
      for I := 0 to Items.Count - 1 do
        if (GetTextWidth(Items[I]) > ItemWidth) then
          ItemWidth := GetTextWidth(Items[I]) + 8;
      Self.Perform(CB_SETDROPPEDWIDTH, ItemWidth, 0);
    end;
end;

function TBCComboBox.GetTextWidth(s: String): Integer;
begin
  Result := Canvas.TextWidth(s);
end;

procedure TBCComboBox.SetDropDownFixedWidth(const Value: Integer);
begin
  FDropDownFixedWidth := Value;
end;

end.




