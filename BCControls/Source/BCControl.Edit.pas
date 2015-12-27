unit BCControl.Edit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, sEdit;

type
  TValidateEvent = procedure(Sender: TObject; var Error: Boolean) of Object;

  TBCEdit = class(TsEdit)
  private
    FEnterToTab: Boolean;
    FOnlyNum: Boolean;
    FNumbersWithDots: Boolean;
    FNumbersWithSpots: Boolean;
    FNumbersAllowMinus: Boolean;
    FNumbersAllowPlus: Boolean;
    FErrorColor: TColor;
    FOnValidate: TValidateEvent;
    function GetValueInt: Integer;
    procedure SetEditable(Value: Boolean);
    procedure SetValueInt(Value: Integer);
    procedure WMPaste(var Msg: TMessage); message WM_PASTE;
    procedure WMSetText(var Msg: TWMSettext); message WM_SETTEXT;
    procedure EMReplaceSel(var Msg: TWMSettext); message EM_REPLACESEL;
  protected
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;
    function IsCharValid(AChar: Char): Boolean;
    function IsStringValid(const S: string): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
    property ValueInt: Integer read GetValueInt write SetValueInt;
  published
    property EnterToTab: Boolean read FEnterToTab write FEnterToTab;
    property OnlyNumbers: Boolean read FOnlyNum write FOnlyNum;
    property NumbersWithDots: Boolean read FNumbersWithDots
      write FNumbersWithDots;
    property NumbersWithSpots: Boolean read FNumbersWithSpots
      write FNumbersWithSpots;
    property ErrorColor: TColor read FErrorColor write FErrorColor;
    property NumbersAllowMinus: Boolean read FNumbersAllowMinus
      write FNumbersAllowMinus;
    property NumbersAllowPlus: Boolean read FNumbersAllowPlus
      write FNumbersAllowPlus;
    property OnValidate: TValidateEvent read FOnValidate write FOnValidate;
    property Editable: Boolean write SetEditable;
  end;

implementation

uses
  System.UITypes, Vcl.Clipbrd;

const
  clError = TColor($E1E1FF);

resourcestring
  TEXT_SET_VALUE = 'Set value %s.';

constructor TBCEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnterToTab := False;
  FOnlyNum := False;
  FNumbersAllowMinus := False;
  FNumbersAllowPlus := False;
  FErrorColor := clError;
end;

function TBCEdit.IsCharValid(AChar: Char): Boolean;
var
  LCharSet: set of AnsiChar;
begin
  if FOnlyNum then
  begin
    LCharSet := ['0' .. '9'];
    if FNumbersWithDots then
      LCharSet := LCharSet + ['.'];
    if FNumbersWithSpots then
      if Pos(',', Text) = 0 then
        LCharSet := LCharSet + [','];
    if FNumbersAllowMinus then
      if Pos('-', Text) = 0 then
        LCharSet := LCharSet + ['-'];
    if FNumbersAllowPlus then
      if Pos('+', Text) = 0 then
        LCharSet := LCharSet + ['+'];

    Result := CharInSet(AChar, LCharSet);
  end
  else
    Result := True;
end;

procedure TBCEdit.KeyPress(var Key: Char);
begin
  if FOnlyNum then
  begin
    if not IsCharValid(Key) and not CharInSet(Key, [#8, ^C, ^V, ^X]) then
      Key := #0;
  end
  else
    inherited;
end;

procedure TBCEdit.EMReplaceSel(var Msg: TWMSettext);
begin
  if IsStringValid(Msg.Text) then
    inherited;
end;

function TBCEdit.IsStringValid(const S: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(S) do
    if not IsCharValid(S[i]) then
    begin
      Result := False;
      Break;
    end;
end;

procedure TBCEdit.WMPaste(var Msg: TMessage);
begin
  if IsStringValid(Clipboard.AsText) then
    inherited;
end;

procedure TBCEdit.WMSetText(var Msg: TWMSettext);
begin
  if IsStringValid(Msg.Text) then
    inherited;
end;

procedure TBCEdit.DoExit;
var
  LText: string;
begin
  if FOnlyNum then
    if FNumbersAllowMinus then
    begin
      LText := Text;
      if Pos('-', Text) > 1 then
        Delete(LText, Pos('-', LText), 1);
      Text := LText;
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
  if Trim(Text) = '' then
  begin
    MessageDlg(Format(TEXT_SET_VALUE, [LowerCase(Hint)]), mtError, [mbOK], 0);
    if CanFocus then
      SetFocus;
    Exit(False);
  end;
  Result := True;
end;

function TBCEdit.GetValueInt: Integer;
begin
  try
    Result := StrToInt(Text);
  except
    Result := 0;
  end;
end;

procedure TBCEdit.SetValueInt(Value: Integer);
begin
  try
    Text := IntToStr(Value);
  except
    Text := '';
  end;
end;

end.
