unit BCControls.Edit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sEdit;

type
  TValidateEvent = procedure(Sender: TObject; var Error: Boolean) of Object;

  TBCEdit = class(TsEdit)
  private
    FEnterToTab: Boolean;
    FOnlyNum: Boolean;
    FNumwDots: Boolean;
    FNumwSpots: Boolean;
    FNegativeNumbers: Boolean;
    FErrorColor: TColor;
    FOnValidate: TValidateEvent;
    function GetValueInt: Integer;
    procedure SetEditable(Value: Boolean);
    procedure SetValueInt(Value: Integer);
  protected
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    function IsEmpty: Boolean;
    property ValueInt: Integer read GetValueInt write SetValueInt;
  published
    property EnterToTab: Boolean read FEnterToTab write FEnterToTab;
    property OnlyNumbers: Boolean read FOnlyNum write FOnlyNum;
    property NumbersWithDots: Boolean read FNumwDots write FNumwDots;
    property NumbersWithSpots: Boolean read FNumwSpots write FNumwSpots;
    property ErrorColor: TColor read FErrorColor write FErrorColor;
    property NumbersAllowNegative: Boolean read FNegativeNumbers write FNegativeNumbers;
    property OnValidate: TValidateEvent read FOnValidate write FOnValidate;
    property Editable: Boolean write SetEditable;
  end;

implementation

uses
  System.UITypes;

const
  clError = TColor($E1E1FF);

resourcestring
  TEXT_SET_VALUE = 'Set value %s.';

constructor TBCEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnterToTab := False;
  FOnlyNum := False;
  FNegativeNumbers := False;
  FErrorColor := clError;
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
  LText: string;
begin
  if FOnlyNum then
    if FNegativeNumbers then
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
