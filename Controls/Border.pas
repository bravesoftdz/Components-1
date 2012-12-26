unit Border;

interface

uses
  Messages, Windows, SysUtils, Classes, System.Types, Controls, Forms, Menus, Graphics,
  StdCtrls;



type
  TBorderStyle = (bsLowered, bsRaised);
  TBorderShape = (bsSingle, bsBox, bsFrame, bsTopLine, bsBottomLine, bsLeftLine,
    bsRightLine, bsSpacer);

  TBorder = class(TGraphicControl)
  private
    FStyle: TBorderStyle;
    FShape: TBorderShape;
    procedure SetStyle(Value: TBorderStyle);
    procedure SetShape(Value: TBorderShape);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property ParentShowHint;
    property Shape: TBorderShape read FShape write SetShape default bsBox;
    property ShowHint;
    property Style: TBorderStyle read FStyle write SetStyle default bsLowered;
    property Visible;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
  end;

procedure Register;

implementation

{ TBorder }

constructor TBorder.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  FStyle := bsLowered;
  FShape := bsBox;
  Width := 50;
  Height := 50;
end;

procedure TBorder.SetStyle(Value: TBorderStyle);
begin
  if Value <> FStyle then
  begin
    FStyle := Value;
    Invalidate;
  end;
end;

procedure TBorder.SetShape(Value: TBorderShape);
begin
  if Value <> FShape then
  begin
    FShape := Value;
    Invalidate;
  end;
end;

procedure TBorder.Paint;
const
  XorColor = $00FFD8CE;
var
  Color1, Color2: TColor;
  Temp: TColor;

  procedure BevelRect(const R: TRect);
  begin
    with Canvas do
    begin
      Pen.Color := Color1;
      PolyLine([Point(R.Left, R.Bottom), Point(R.Left, R.Top),
        Point(R.Right, R.Top)]);
      Pen.Color := Color2;
      PolyLine([Point(R.Right, R.Top), Point(R.Right, R.Bottom),
        Point(R.Left, R.Bottom)]);
    end;
  end;

  procedure BevelLine(C: TColor; X1, Y1, X2, Y2: Integer);
  begin
    with Canvas do
    begin
      Pen.Color := C;
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
    end;
  end;

begin
  with Canvas do
  begin
    if (csDesigning in ComponentState) then
    begin
      if (FShape = bsSpacer) then
      begin
        Pen.Style := psDot;
        Pen.Mode := pmXor;
        Pen.Color := XorColor;
        Brush.Style := bsClear;
        Rectangle(0, 0, ClientWidth, ClientHeight);
        Exit;
      end
      else
      begin
        Pen.Style := psSolid;
        Pen.Mode  := pmCopy;
        Pen.Color := clBlack;
        Brush.Style := bsSolid;
      end;
    end;

    Pen.Width := 1;

    if FStyle = bsLowered then
    begin
      Color1 := clBtnShadow;
      Color2 := clBtnHighlight;
    end
    else
    begin
      Color1 := clBtnHighlight;
      Color2 := clBtnShadow;
    end;

    case FShape of
      bsSingle:
        begin
        BevelRect(Rect(0, 0, Width - 1, Height - 1));
        Color1 := clBlack; Color2 := clBtnFace;
        BevelRect(Rect(1, 1, Width - 2, Height - 2));
        end;
      bsBox:
        BevelRect(Rect(0, 0, Width - 1, Height - 1));
      bsFrame:
        begin
          Temp := Color1;
          Color1 := Color2;
          BevelRect(Rect(1, 1, Width - 1, Height - 1));
          Color2 := Temp;
          Color1 := Temp;
          BevelRect(Rect(0, 0, Width - 2, Height - 2));
        end;
      bsTopLine:
        begin
          BevelLine(Color1, 0, 0, Width, 0);
          BevelLine(Color2, 0, 1, Width, 1);
        end;
      bsBottomLine:
        begin
          BevelLine(Color1, 0, Height - 2, Width, Height - 2);
          BevelLine(Color2, 0, Height - 1, Width, Height - 1);
        end;
      bsLeftLine:
        begin
          BevelLine(Color1, 0, 0, 0, Height);
          BevelLine(Color2, 1, 0, 1, Height);
        end;
      bsRightLine:
        begin
          BevelLine(Color1, Width - 2, 0, Width - 2, Height);
          BevelLine(Color2, Width - 1, 0, Width - 1, Height);
        end;
    end;
  end;
end;

procedure Register;
begin
//  RegisterPropertyEditor(TypeInfo(TCardValue), TCard, '', TCardValueEditor);
  RegisterComponents('bonecode', [TBorder]);
end;

end.
