unit BCControl.LayoutPanel;

interface

uses
  System.Classes, System.Types, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, BCControl.LayoutController;

type
  TBCLayoutPanel = class(TCustomPanel)
  private
    { Private declarations }
    function GetLayoutDirection: TBCLayoutDirection;
    function GetLayoutManagerActive: Boolean;
    function GetControlSpacing: Integer;
    procedure SetLabelColor(const Value: TColor);
    procedure SetLayoutDirection(const Value: TBCLayoutDirection);
    procedure SetLayoutManagerActive(const Value: boolean);
    procedure SetControlSpacing(const Value: integer);
  protected
    { Protected declarations }
    FLeftMargin: Integer;
    FLabelColor: TColor;
    FTopMargin: Integer;
    FLayoutController: TBCLayoutController;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Anchors;
    property Align;
    property AlignWithMargins;
    property AutoSize;
    property Ctl3D;
    property Color default clWindow;
    property ControlSpacing: Integer read GetControlSpacing write SetControlSpacing;
    property DoubleBuffered;
    property Enabled;
    property Font;
    property LayoutManagerActive: Boolean read GetLayoutManagerActive write SetLayoutManagerActive;
    property LayoutType: TBCLayoutDirection read GetLayoutDirection write SetLayoutDirection;
    property LabelColor: TColor read FLabelColor write SetLabelColor;
    property Margins;
    property OnClick;
    property OnResize;
    property ParentColor default True;
    property ParentCtl3D default True;
    property ParentFont;
    property StyleElements;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

implementation

uses
  Winapi.Windows, Vcl.StdCtrls, Vcl.Themes;

procedure TBCLayoutPanel.AlignControls(AControl: TControl; var Rect: TRect);
begin
  if LayoutManagerActive then
    FLayoutController.AlignControls
  else
    inherited AlignControls(AControl, Rect);
end;

constructor TBCLayoutPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ParentColor := True;
  ParentBackground := True;
  ParentFont := True;

  FLabelColor := clWindowText;

  FLayoutController := TBCLayoutController.Create(Self);
  FLayoutController.LeftMargin := Margins.Left;
  FLayoutController.TopMargin := Margins.Top;
end;

destructor TBCLayoutPanel.Destroy;
begin
  FLayoutController.Free;
  inherited;
end;

function TBCLayoutPanel.GetLayoutManagerActive: Boolean;
begin
  Result := FLayoutController.Active;
end;

function TBCLayoutPanel.GetControlSpacing: Integer;
begin
  result := FLayoutController.ControlSpacing;
end;

function TBCLayoutPanel.GetLayoutDirection: TBCLayoutDirection;
begin
  Result := FLayoutController.LayoutDirection;
end;

procedure TBCLayoutPanel.Paint;
var
  Rect: TRect;
begin
  if csDesigning in ComponentState then
    Realign;

  Rect := GetClientRect;
  with Canvas do
  begin
    if {not StyleServices.Enabled or} not ParentBackground then
    begin
      Brush.Style := bsSolid;
      Brush.Color := Color;
      FillRect(Rect);
    end;
  end;
end;

procedure TBCLayoutPanel.SetLayoutManagerActive(const Value: Boolean);
begin
  FLayoutController.Active := Value;
end;

procedure TBCLayoutPanel.SetControlSpacing(const Value: Integer);
begin
  FLayoutController.ControlSpacing := value;
end;

procedure TBCLayoutPanel.SetLabelColor(const Value: TColor);
begin
  FLabelColor := Value;
end;


procedure TBCLayoutPanel.SetLayoutDirection(const Value: TBCLayoutDirection);
begin
  FLayoutController.LayoutDirection := Value;
end;

end.
