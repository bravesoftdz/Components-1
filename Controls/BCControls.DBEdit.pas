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
    FFocusOnColor: TColor;
    FFocusOffColor: TColor;
    FUseColoring: Boolean;
    procedure SetFocusOnColor(Value: TColor);
    procedure SetFocusOffColor(Value: TColor);
    procedure SetEditable(Value: Boolean);
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
    property FocusOnColor: TColor read FFocusOnColor write SetFocusOnColor;
    property FocusOffColor: TColor read FFocusOffColor write SetFocusOffColor;
    property UseColoring: Boolean read FUseColoring write FUseColoring;
    property Editable: Boolean write SetEditable;
  end;

procedure Register;

implementation

uses
  System.UITypes;

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
  FFocusOnColor := clInfoBk;
  FFocusOffColor := clWindow;
  FUseColoring := True;
  StyleElements := [seFont, seBorder];
end;

procedure TBCDBEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  if not ReadOnly and UseColoring then
  begin
    Color := FFocusOnColor;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCDBEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  if not ReadOnly and UseColoring then
  begin
    Color := FFocusOffColor;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCDBEdit.WMPaint(var Message: TWMPaint);
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

procedure TBCDBEdit.SetFocusOnColor(Value: TColor);
begin
  if FFocusOnColor <> Value then
    FFocusOnColor := Value;
end;

procedure TBCDBEdit.SetFocusOffColor(Value: TColor);
begin
  if FocusOffColor <> Value then
    FFocusOffColor := Value;
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
