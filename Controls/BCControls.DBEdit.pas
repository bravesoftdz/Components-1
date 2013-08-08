unit BCControls.DBEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls;

type
  TBCDBEdit = class(TDBEdit)
  private
    { Private declarations }
    FEnterToTab: Boolean;
    FNumAllowNegative: Boolean;
    FOnlyNum: Boolean;
    FNumwDots: Boolean;
    FNumwSpots: Boolean;
    FEditColor: TColor;
    FUseColoring: Boolean;
    procedure SetEditColor(Value: TColor);
    procedure SetEditable(Value: Boolean);
    procedure SetUseColoring(Value: Boolean);
  protected
    { Protected declarations }
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure KeyPress(var Key: Char); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
  published
    { Published declarations }
    property EnterToTab: Boolean read FEnterToTab write FEnterToTab;
    property OnlyNumbers: Boolean read FOnlyNum write FOnlyNum;
    property NumbersAllowNegative: Boolean read FNumAllowNegative write FNumAllowNegative;
    property NumbersWithDots: Boolean read FNumwDots write FNumwDots;
    property NumbersWithSpots: Boolean read FNumwSpots write FNumwSpots;
    property EditColor: TColor read FEditColor write SetEditColor;
    property UseColoring: Boolean read FUseColoring write SetUseColoring;
    property Editable: Boolean write SetEditable;
  end;

procedure Register;

implementation

uses
  System.UITypes, Vcl.Themes;

resourcestring
  TEXT_SET_VALUE = 'Set value %s.';

procedure Register;
begin
  RegisterComponents('bonecode', [TBCDBEdit]);
end;

constructor TBCDBEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnterToTab := False;
  FNumAllowNegative := True;
  FOnlyNum := False;
  FEditColor := clInfoBk;
  FUseColoring := True;
  StyleElements := [seFont, seBorder];
end;

procedure TBCDBEdit.SetUseColoring(Value: Boolean);
begin
  FUseColoring := Value;
  if FUseColoring then
    StyleElements := [seFont, seBorder]
  else
    StyleElements := [seFont, seClient, seBorder]
end;

procedure TBCDBEdit.WMSetFocus(var Message: TWMSetFocus);
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

procedure TBCDBEdit.WMKillFocus(var Message: TWMKillFocus);
var
  LStyles: TCustomStyleServices;
begin
  LStyles := StyleServices;
  if not ReadOnly and UseColoring then
  begin
    if LStyles.Enabled then
      Color := LStyles.GetStyleColor(scEdit)
    else
      Color := clWindow;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCDBEdit.WMPaint(var Message: TWMPaint);
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

procedure TBCDBEdit.SetEditColor(Value: TColor);
begin
  if FEditColor <> Value then
    FEditColor := Value;
end;

procedure TBCDBEdit.KeyPress(var Key: Char);
var
  CharSet: set of AnsiChar;
begin
  inherited;
  if FOnlyNum then
  begin
    CharSet := ['0'..'9'];
    if FNumwDots then
      CharSet := CharSet + ['.'];
    if FNumwSpots then
    begin
      if Pos(',', text) = 0 then
        CharSet := CharSet + [','];
    end;
    if FNumAllowNegative then
      if Pos('-', text) = 0 then
        CharSet := CharSet + ['-'];
    if Pos('+', text) = 0 then
      CharSet := CharSet + ['+'];

    if (not (CharInSet(Key, CharSet))) and (not (Key = #8)) then
      Key := #0;
  end;
end;

procedure TBCDBEdit.SetEditable(Value: Boolean);
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

function TBCDBEdit.IsEmpty: Boolean;
begin
  Result := False;
  if Trim(Text) = '' then
  begin
    MessageDlg(Format(TEXT_SET_VALUE, [LowerCase(Hint)]), mtError, [mbOK], 0);
    try
      SetFocus;
    except
    end;
    Exit;
  end;
  Result := True;
end;

end.
