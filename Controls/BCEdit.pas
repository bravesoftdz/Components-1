unit BCEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, JvEdit;

type
  TBCEdit = class(TJvEdit)
  private
    { Private declarations }
    FOnlyNum: Boolean;
    FNumwDots: Boolean;
    FNumwSpots: Boolean;
    FNegativeNumbers: Boolean;
    FEditColor: TColor;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure SetEditable(Value: Boolean);
  protected
    { Protected declarations }
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
  published
    { Published declarations }
    property OnlyNumbers: Boolean read FOnlyNum write FOnlyNum;
    property NumbersWithDots: Boolean read FNumwDots write FNumwDots;
    property NumbersWithSpots: Boolean read FNumwSpots write FNumwSpots;
    property EditColor: TColor read FEditColor write FEditColor;
    property NumbersAllowNegative: Boolean read FNegativeNumbers write FNegativeNumbers;
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
  RegisterComponents('bonecode', [TBCEdit]);
end;

constructor TBCEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnlyNum := false;
  FNegativeNumbers := False;
  FEditColor := clInfoBk;
end;

procedure TBCEdit.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not readonly then
    Color := clWindow;
end;

procedure TBCEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not readonly then
    Color := FEditColor;
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

function TBCEdit.IsEmpty: Boolean;
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
