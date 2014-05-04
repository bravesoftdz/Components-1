unit BCControls.GroupBox;

interface

uses
  System.Classes, System.Types, Vcl.Controls, Vcl.Graphics, BCControls.LayoutPanel;

type
  TBCGroupBox = class(TBCLayoutPanel)
  private
    { Private declarations }
    FCaptionFont: TFont;
    function GetCaptionHeight: Integer;
    procedure SetCaptionFont(Value: TFont);
  protected
    { Protected declarations }
    procedure Paint; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Caption;
    property CaptionFont: TFont read FCaptionFont write SetCaptionFont;
  end;

procedure register;

implementation

uses
  Vcl.Themes;

procedure register;
begin
  RegisterComponents('bonecode', [TBCGroupBox]);
end;

{ TBCGroupBox }

procedure TBCGroupBox.AlignControls(AControl: TControl; var Rect: TRect);
begin
  if not LayoutManagerActive then
    Rect.Top := Rect.Top + GetCaptionHeight;
  inherited AlignControls(AControl, Rect);
end;

constructor TBCGroupBox.Create(AOwner: TComponent);
begin
  inherited;
  FCaptionFont := TFont.Create;
  FCaptionFont.Name := 'Tahoma';
  FCaptionFont.Size := 8;
  DoubleBuffered := False;
  FLayoutController.LeftMargin := 5;
  LayoutManagerActive := False;
end;

destructor TBCGroupBox.Destroy;
begin
  FCaptionFont.Free;
  inherited;
end;

procedure TBCGroupBox.SetCaptionFont(Value: TFont);
begin
  if FCaptionFont <> Value then
  begin
    FCaptionFont.Assign(Value);
    Canvas.Font.Assign(Value);
    Invalidate;
  end;
end;

function TBCGroupBox.GetCaptionHeight: Integer;
begin
  Result := Canvas.TextHeight(Caption);
end;

procedure TBCGroupBox.Paint;
var
  y, LTextWidth, LTextHeight: Integer;
  LStyles: TCustomStyleServices;
begin
  inherited;
  LStyles := StyleServices;
  FLayoutController.TopMargin := FTopMargin + GetCaptionHeight + 5;
  with Canvas do
  begin
    Font.Assign(FCaptionFont);
    Brush.Style := bsClear;
    Pen.Color := clLtGray;
    if LStyles.Enabled then
    begin
      Pen.Color := LStyles.GetSystemColor(clBtnShadow);
      Font.Color := LStyles.GetStyleFontColor(sfTextLabelNormal);
    end;
    TextOut(FLeftMargin, FTopMargin, Caption);
    LTextWidth := TextWidth(Caption);
    LTextHeight := GetCaptionHeight;
    y := (FTopMargin + LTextHeight div 2) + 1;
    MoveTo(FLeftMargin + LTextWidth + 5, y);
    LineTo(Width - 5, y);
  end;
end;

end.
