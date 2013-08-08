unit BCControls.Edit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, JvExStdCtrls, JvEdit;

type
  TValidateEvent = procedure(Sender: TObject; var Error: Boolean) of Object;

  TBCEdit = class(TJvEdit)
  private
    { Private declarations }
    FEnterToTab: Boolean;
    FOnlyNum: Boolean;
    FNumwDots: Boolean;
    FNumwSpots: Boolean;
    FNegativeNumbers: Boolean;
    FErrorColor: TColor;
    FOnValidate: TValidateEvent;
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
    procedure DoExit; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
  published
    { Published declarations }
    property EnterToTab: Boolean read FEnterToTab write FEnterToTab;
    property OnlyNumbers: Boolean read FOnlyNum write FOnlyNum;
    property NumbersWithDots: Boolean read FNumwDots write FNumwDots;
    property NumbersWithSpots: Boolean read FNumwSpots write FNumwSpots;
    property ErrorColor: TColor read FErrorColor write FErrorColor;
    property NumbersAllowNegative: Boolean read FNegativeNumbers write FNegativeNumbers;
    property EditColor: TColor read FEditColor write SetEditColor;
    property UseColoring: Boolean read FUseColoring write SetUseColoring;
    property OnValidate: TValidateEvent read FOnValidate write FOnValidate;
    property Editable: Boolean write SetEditable;
  end;

procedure Register;

implementation

uses
  System.UITypes, Vcl.Themes;

const
  clError = TColor($E1E1FF);

resourcestring
  TEXT_SET_VALUE = 'Set value %s.';

procedure Register;
begin
  RegisterComponents('bonecode', [TBCEdit]);
end;

constructor TBCEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnterToTab := False;
  FOnlyNum := False;
  FNegativeNumbers := False;
  FEditColor := clInfoBk;
  FUseColoring := True;
  FErrorColor := clError;
  StyleElements := [seFont, seBorder];
end;

procedure TBCEdit.SetUseColoring(Value: Boolean);
begin
  FUseColoring := Value;
  if FUseColoring then
    StyleElements := [seFont, seBorder]
  else
    StyleElements := [seFont, seClient, seBorder]
end;

procedure TBCEdit.WMSetFocus(var Message: TWMSetFocus);
var
  Error: Boolean;
  LStyles: TCustomStyleServices;
begin
  LStyles := StyleServices;
  if not ReadOnly and UseColoring then
  begin
    Error := False;
    if Assigned(FOnValidate) then
      FOnValidate(Self, Error);
    if Error then
    begin
      if LStyles.Enabled then
        Color := LStyles.GetSystemColor(FErrorColor)
      else
        Color := FErrorColor
    end
    else
    begin
      if LStyles.Enabled then
        Color := LStyles.GetSystemColor(clHighlight)
      else
        Color := FEditColor;
    end;
    InvalidateRect(Handle, nil, True);
  end;
  inherited;
end;

procedure TBCEdit.WMKillFocus(var Message: TWMKillFocus);
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

procedure TBCEdit.WMPaint(var Message: TWMPaint);
var
  DC: HDC;
  Error: Boolean;
  LStyles: TCustomStyleServices;
begin
  inherited;
  LStyles := StyleServices;

  if (csDesigning in ComponentState) then
    Exit;

  if UseColoring then
  begin
    Error := False;
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
          Color := clBtnFace
      end
      else
      begin
        if Assigned(FOnValidate) then
          FOnValidate(Self, Error);
        if Error then
        begin
          if LStyles.Enabled then
            Color := LStyles.GetSystemColor(FErrorColor)
          else
            Color := FErrorColor;
        end
        else
        if not Focused then
        begin
          if LStyles.Enabled then
            Color := LStyles.GetStyleColor(scEdit)
          else
            Color := clWindow;
        end;
      end;
      SetBKColor(DC, Color);
      //FrameRect(DC, Rect(1, 1, Pred(Width), Pred(Height)), CreateSolidBrush(ColorToRGB(Color)));
    finally
      ReleaseDC(Handle, DC);
    end;
  end;
end;

procedure TBCEdit.SetEditColor(Value: TColor);
begin
  if FEditColor <> Value then
    FEditColor := Value;
end;

procedure TBCEdit.KeyPress(var Key: Char);
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
    if FNegativeNumbers then
      if Pos('-', text) = 0 then
        CharSet := CharSet + ['-'];
    if Pos('+', text) = 0 then
      CharSet := CharSet + ['+'];

    if (not (CharInSet(Key, CharSet))) and (not (Key = #8)) then
      Key := #0;
  end;
end;

procedure TBCEdit.DoExit;
var
  szText: string;
begin
  if FOnlyNum then
    if FNegativeNumbers then
    begin
      szText := Text;
      if Pos('-', Text) > 1 then
        Delete(szText, Pos('-', szText), 1);
      Text := szText;
    end;
  inherited;
end;

procedure TBCEdit.SetEditable(Value: Boolean);
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

function TBCEdit.IsEmpty: Boolean;
begin
  Result := False;
  if Trim(Text) = '' then
  begin
    MessageDlg(Format(TEXT_SET_VALUE, [LowerCase(Hint)]), mtError, [mbOK], 0);
    if CanFocus then
      SetFocus;
    Exit;
  end;
  Result := True;
end;

end.
