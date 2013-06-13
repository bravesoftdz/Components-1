unit BCDBEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls;

type
  TBCDBEdit = class(TDBEdit)
  private
    { Private declarations }
    FNumAllowNegative: Boolean;
    FOnlyNum: Boolean;
    FNumwDots: Boolean;
    FNumwSpots: Boolean;
    FEditColor: TColor;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure SetEditable(Value: Boolean);
  protected
    { Protected declarations }
    procedure KeyPress(var Key: Char); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
  published
    { Published declarations }
    property OnlyNumbers: Boolean read FOnlyNum write FOnlyNum;
    property NumbersAllowNegative: Boolean read FNumAllowNegative write FNumAllowNegative;
    property NumbersWithDots: Boolean read FNumwDots write FNumwDots;
    property NumbersWithSpots: Boolean read FNumwSpots write FNumwSpots;
    property EditColor: TColor read FEditColor write FEditColor;
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
  FNumAllowNegative := True;
  FOnlyNum := False;
  FEditColor := clInfoBk;
end;

procedure TBCDBEdit.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not ReadOnly then
    Color := clwindow;
end;

procedure TBCDBEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not ReadOnly then
    Color := FEditColor;
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
    if Focused then
      Color := FEditColor
    else
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
