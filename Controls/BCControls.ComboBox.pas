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
    FEditColor: TColor;
    FUseColoring: Boolean;
    procedure SetEditColor(Value: TColor);
    procedure SetDropDownFixedWidth(const Value: Integer);
    function GetTextWidth(s: string): Integer;
    procedure SetUseColoring(Value: Boolean);
  protected
    { Protected declarations }
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
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
    property DeniedKeyStrokes: Boolean read FDKS write FDKS;
    property Editable: Boolean write SetEditable;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property EditColor: TColor read FEditColor write SetEditColor;
    property UseColoring: Boolean read FUseColoring write SetUseColoring;
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
  FEditColor := clInfoBk;
  FUseColoring := True;
  ReadOnly := False;
  StyleElements := [seFont, seBorder];
end;

procedure TBCComboBox.SetUseColoring(Value: Boolean);
begin
  FUseColoring := Value;
  if FUseColoring then
    StyleElements := [seFont, seBorder]
  else
    StyleElements := [seFont, seClient, seBorder];
end;

procedure TBCComboBox.KeyPress(var Key: Char);
begin
  if FDKS or ReadOnly then
    Key := #0
  else
    inherited;
end;

procedure TBCComboBox.WMSetFocus(var Message: TWMSetFocus);
var
  LStyles: TCustomStyleServices;
begin
  LStyles := StyleServices;
  if not ReadOnly and UseColoring then
  begin
    if LStyles.Enabled then
      Color := LStyles.GetSystemColor(clHighlight)
    else
      Color := FEditColor;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCComboBox.WMKillFocus(var Message: TWMKillFocus);
var
  LStyles: TCustomStyleServices;
begin
  LStyles := StyleServices;
  if UseColoring then
  begin
    if LStyles.Enabled then
      Color := LStyles.GetStyleColor(scEdit)
    else
      Color := clWindow;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCComboBox.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  LStyles: TCustomStyleServices;
begin
  inherited;
  LStyles := StyleServices;

  if (csDesigning in ComponentState) then
    Exit;

  if UseColoring then
  begin
    DC := GetWindowDC(Handle);
    try
      if LStyles.Enabled then
      begin
        if Focused then
          Font.Color := LStyles.GetSystemColor(clHighlightText)
        else
        begin
          Color := LStyles.GetStyleColor(scEdit);
          Font.Color := LStyles.GetStyleFontColor(sfEditBoxTextNormal);
        end;
      end
      else
      begin
        if not Focused then
          Color := clWindow;
        Font.Color := clWindowText;
      end;
      if ReadOnly then
      begin
        if LStyles.Enabled then
          Color := LStyles.GetStyleColor(scEditDisabled)
        else
          Color := clBtnFace;
      end;
      SetBKColor(DC, Color);
      //FrameRect(DC, Rect(1, 1, Pred(Width), Pred(Height)), CreateSolidBrush(ColorToRGB(Color)));
    finally
      ReleaseDC(Handle, DC);
    end;
  end;
end;

procedure TBCComboBox.SetEditColor(Value: TColor);
begin
  if FEditColor <> Value then
    FEditColor := Value;
end;

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




