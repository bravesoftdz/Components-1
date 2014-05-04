unit BCControls.RadioButton;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics;

type
  TBCRadioButton = class(TRadioButton)
  strict private
    { Private declarations }
    FCanvas: TControlCanvas;
    FAutoSize: Boolean;
    FReadOnly: Boolean;
    FFontChanged: TNotifyEvent;
    function GetText: TCaption;
    procedure AdjustBounds;
    procedure FontChanged(Sender: TObject);
  protected
    { Protected declarations }
    procedure DoEnter; override;
    procedure SetAutoSize(Value: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetText(const Value: TCaption);
  published
    { Published declarations }
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    property Caption read GetText write SetText;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
  end;

procedure Register;

implementation

uses
  Winapi.Windows;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCRadioButton]);
end;

constructor TBCRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReadOnly := False;
  FAutoSize := True;

  FCanvas := TControlCanvas.Create;
  FCanvas.Control := Self;
  FFontChanged := Font.OnChange;
  Font.OnChange := FontChanged;
  ControlStyle := ControlStyle - [csDoubleClicks];
end;

destructor TBCRadioButton.Destroy;
begin
  FCanvas.Free;
  inherited Destroy;
end;

procedure TBCRadioButton.DoEnter;
begin
  if not ReadOnly then
    inherited
  else
    Parent.SetFocus
end;

procedure TBCRadioButton.SetAutoSize(Value: Boolean);
begin
  FAutoSize := Value;
  if Value then
    AdjustBounds;
end;

procedure TBCRadioButton.AdjustBounds;
begin
  FCanvas.Font := Font;
  Width := FCanvas.TextWidth(Caption) + GetSystemMetrics(SM_CXMENUCHECK) + 4;
  Height := FCanvas.TextHeight(Caption) + 2;
end;

procedure TBCRadioButton.FontChanged(Sender: TObject);
begin
  if Assigned(FFontChanged) then
    FFontChanged(Sender);
  AdjustBounds;
end;

procedure TBCRadioButton.SetText(const Value: TCaption);
var
  s: TCaption;
begin
  if GetText <> Value then
  begin
    s := Value;
    if Pos(' ', s) <> 1 then
      s := Format(' %s', [s]);
    SetTextBuf(PChar(s));
    if FAutoSize then
      AdjustBounds;
  end;
end;

function TBCRadioButton.GetText: TCaption;
var
  Len: Integer;
begin
  Len := GetTextLen;
  SetString(Result, PChar(nil), Len);
  if Len <> 0 then
    GetTextBuf(Pointer(Result), Len + 1);
end;

end.
