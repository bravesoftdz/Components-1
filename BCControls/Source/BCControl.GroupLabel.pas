unit BCControl.GroupLabel;

interface

uses
  System.Classes, System.Types, Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, sCommonData;

type
  TBCGroupLabel = class(TCustomLabel)
  private
    FCommonData: TsCtrlSkinData;
  protected
    procedure Paint; override;
    procedure UpdateStyleElements; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Caption;
    property SkinData: TsCtrlSkinData read FCommonData write FCommonData;
    property Enabled;
    property Align;
    property Autosize;
    property Anchors;
    property Visible;
  end;

implementation

uses
  System.SysUtils;

{ TBCGroupLabel }

constructor TBCGroupLabel.Create(AOwner: TComponent);
begin
  inherited;
  FCommonData := TsCtrlSkinData.Create(Self, True);
  Font.Name := 'Tahoma';
  Font.Size := 11;
end;

procedure TBCGroupLabel.UpdateStyleElements;
begin
  inherited;
  FCommonData.Loaded;

  if FCommonData.Skinned then
  begin
    if not FCommonData.CustomColor then
      Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Props[0].Color;

    if not FCommonData.CustomFont then
      Font.Color := FCommonData.SkinManager.gd[FCommonData.SkinIndex].Props[0].FontColor.Color;
  end;
end;

destructor TBCGroupLabel.Destroy;
begin
  if Assigned(FCommonData) then
    FreeAndNil(FCommonData);
  inherited;
end;

procedure TBCGroupLabel.Paint;
var
  LTextWidth, LTextHeight: Integer;
begin
  inherited;
  with Canvas do
  begin
    Brush.Style := bsClear;
    if Assigned(SkinData) and Assigned(SkinData.SkinManager) and SkinData.SkinManager.Active then
      Pen.Color := SkinData.SkinManager.GetHighLightColor
    else
      Pen.Color := clLtGray;
    Canvas.TextOut(0, 0, Caption);
    LTextWidth := Canvas.TextWidth(Caption);
    LTextHeight := Canvas.TextHeight(Caption);
    Canvas.MoveTo(LTextWidth+5, LTextHeight div 2);
    Canvas.LineTo(Width, LTextHeight div 2);
  end;
end;

end.
