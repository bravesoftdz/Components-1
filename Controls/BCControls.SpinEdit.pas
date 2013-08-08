unit BCControls.SpinEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Mask, JvExMask, JvSpin, Vcl.Graphics, Winapi.Messages;

type
  TBCSpinEdit = class(TJvSpinEdit)
  private
    { Private declarations }
    FEditColor: TColor;
    FFocusOffColor: TColor;
    FUseColoring: Boolean;
    procedure SetEditColor(Value: TColor);
    procedure SetFocusOffColor(Value: TColor);
    procedure SetUseColoring(Value: Boolean);
  protected
    { Protected declarations }
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property EditColor: TColor read FEditColor write SetEditColor;
    property FocusOffColor: TColor read FFocusOffColor write SetFocusOffColor;
    property UseColoring: Boolean read FUseColoring write SetUseColoring;
  end;

procedure Register;

implementation

uses
  Winapi.Windows, System.UITypes, Vcl.Themes;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCSpinEdit]);
end;

constructor TBCSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditColor := clInfoBk;
  FFocusOffColor := clWindow;
  FUseColoring := True;
  StyleElements := [seFont, seBorder];
end;

procedure TBCSpinEdit.SetUseColoring(Value: Boolean);
begin
  FUseColoring := Value;
  if FUseColoring then
    StyleElements := [seFont, seBorder]
  else
    StyleElements := [seFont, seClient, seBorder]
end;

procedure TBCSpinEdit.WMSetFocus(var Message: TWMSetFocus);
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

procedure TBCSpinEdit.WMKillFocus(var Message: TWMKillFocus);
var
  LStyles: TCustomStyleServices;
begin
  LStyles := StyleServices;
  if not ReadOnly and UseColoring then
  begin
    if LStyles.Enabled then
      Color := LStyles.GetStyleColor(scEdit)
    else
      Color := FFocusOffColor;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCSpinEdit.WMPaint(var Message: TWMPaint);
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
          Font.Color := LStyles.GetStyleFontColor(sfEditBoxTextNormal);
      end
      else
        Font.Color := clWindowText;
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

procedure TBCSpinEdit.SetEditColor(Value: TColor);
begin
  if FEditColor <> Value then
    FEditColor := Value;
end;

procedure TBCSpinEdit.SetFocusOffColor(Value: TColor);
begin
  if FocusOffColor <> Value then
    FFocusOffColor := Value;
end;

end.
