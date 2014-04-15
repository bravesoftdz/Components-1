unit BCControls.CheckBox;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics;

type
  TBCCheckBox = class(TCheckBox)
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
  RegisterComponents('bonecode', [TBCCheckBox]);
end;

constructor TBCCheckBox.Create(AOwner: TComponent);
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

destructor TBCCheckBox.Destroy;
begin
  FCanvas.Free;
  inherited Destroy;
end;

procedure TBCCheckBox.DoEnter;
begin
  if not ReadOnly then
    inherited
  else
    Parent.SetFocus
end;

procedure TBCCheckBox.SetAutoSize(Value: Boolean);
begin
  FAutoSize := Value;
  if Value then
    AdjustBounds;
end;

procedure TBCCheckBox.AdjustBounds;
begin
  FCanvas.Font := Font;
  Width := FCanvas.TextWidth(Caption) + GetSystemMetrics(SM_CXMENUCHECK) + 4;
  Height := FCanvas.TextHeight(Caption) + 2;
end;

procedure TBCCheckBox.FontChanged(Sender: TObject);
begin
  if Assigned(FFontChanged) then
    FFontChanged(Sender);
  AdjustBounds;
end;

procedure TBCCheckBox.SetText(const Value: TCaption);
begin
  if GetText <> Value then
  begin
    SetTextBuf(PChar(Value));
    if FAutoSize then
      AdjustBounds;
  end;
end;

function TBCCheckBox.GetText: TCaption;
var
  Len: Integer;
begin
  Len := GetTextLen;
  SetString(Result, PChar(nil), Len);
  if Len <> 0 then
    GetTextBuf(Pointer(Result), Len + 1);
end;

end.
