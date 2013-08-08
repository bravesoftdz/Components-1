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
    FFocusOnColor: TColor;
    FFocusOffColor: TColor;
    FUseColoring: Boolean;
    procedure SetFocusOnColor(Value: TColor);
    procedure SetFocusOffColor(Value: TColor);
    procedure SetDropDownFixedWidth(const Value: Integer);
    function GetTextWidth(s: string): Integer;
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
    property FocusOnColor: TColor read FFocusOnColor write SetFocusOnColor;
    property FocusOffColor: TColor read FFocusOffColor write SetFocusOffColor;
    property UseColoring: Boolean read FUseColoring write FUseColoring;
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
  FFocusOnColor := clInfoBk;
  FFocusOffColor := clWindow;
  FUseColoring := True;
  ReadOnly := False;
  StyleElements := [seFont, seBorder];
end;

procedure TBCComboBox.KeyPress(var Key: Char);
begin
  if FDKS or ReadOnly then
    Key := #0
  else
    inherited;
end;

procedure TBCComboBox.WMSetFocus(var Message: TWMSetFocus);
begin
  if not ReadOnly and UseColoring then
  begin
    Color := FFocusOnColor;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCComboBox.WMKillFocus(var Message: TWMKillFocus);
begin
  if not ReadOnly and UseColoring then
  begin
    Color := FFocusOffColor;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCComboBox.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  if UseColoring then
  begin
    DC := GetWindowDC(Handle);
    try
      if ReadOnly then
        Color := clBtnFace;
      SetBKColor(DC, Color);
      //FrameRect(DC, Rect(1, 1, Pred(Width), Pred(Height)), CreateSolidBrush(ColorToRGB(Color)));
    finally
      ReleaseDC(Handle, DC);
    end;
  end;
end;

procedure TBCComboBox.SetFocusOnColor(Value: TColor);
begin
  if FFocusOnColor <> Value then
    FFocusOnColor := Value;
end;

procedure TBCComboBox.SetFocusOffColor(Value: TColor);
begin
  if FocusOffColor <> Value then
    FFocusOffColor := Value;
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




