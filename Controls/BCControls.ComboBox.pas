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
    FDKS: Boolean;
    FReadOnly: Boolean;
    procedure SetEditable(Value: Boolean);
    procedure SetDropDownFixedWidth(const Value: Integer);
    function GetTextWidth(s: string): Integer;
  protected
    { Protected declarations }
    procedure KeyPress(var Key: Char); override;
    procedure DropDown; override;
//    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
    property ItemWidth: Integer read FItemWidth write FItemWidth;
  published
    { Published declarations }
    property DeniedKeyStrokes: Boolean read FDKS write FDKS;
    property Editable: Boolean write SetEditable;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property DropDownFixedWidth: Integer read FDropDownFixedWidth write SetDropDownFixedWidth;
  end;

procedure Register;

implementation

uses
  System.UITypes, Vcl.Themes, BCControls.StyleHooks;

resourcestring
  TEXT_SET_VALUE = 'Set value %s.';

procedure Register;
begin
  RegisterComponents('bonecode', [TBCComboBox]);
end;

constructor TBCComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ReadOnly := False;
end;

procedure TBCComboBox.KeyPress(var Key: Char);
begin
  if FDKS or ReadOnly then
    Key := #0
  else
    inherited;
end;

{procedure TBCComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  ColorStates: array[Boolean] of TStyleColor = (scComboBoxDisabled, scComboBox);
  FontColorStates: array[Boolean] of TStyleFont = (sfComboBoxItemDisabled, sfComboBoxItemNormal);
var
  LStyles  : TCustomStyleServices;
begin
  LStyles  := StyleServices;
  if LStyles.Enabled then
  begin
    Canvas.Brush.Color := LStyles.GetStyleColor(ColorStates[Enabled]);
    Canvas.Font.Color  := LStyles.GetStyleFontColor(FontColorStates[Enabled]);

    if odSelected in State then
      Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight);

    Canvas.FillRect(Rect) ;
    Canvas.TextOut(Rect.Left+2, Rect.Top, Items[Index]);
  end;
end;  }

procedure TBCComboBox.SetEditable(Value: Boolean);
begin
  if Value then
  begin
    ReadOnly := False;
    TabStop := True;
  end
  else
  begin
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




