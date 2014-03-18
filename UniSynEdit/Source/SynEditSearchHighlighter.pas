unit SynEditSearchHighlighter;

interface

uses
  Windows, Classes, SysUtils, Contnrs, Graphics, Synedit, SynEditTypes, SynEditMiscClasses;

type
  TFoundItem = class
    Start: TBufferCoord;
    Length: Word;
  end;

  THighlightSearchPlugin = class(TSynEditPlugin)
  private
    FBlendFunc: BLENDFUNCTION;
    FBmp: TBitmap;
    FSynEdit: TSynEdit;
    FFoundItems: TObjectList;
  protected
    procedure AfterPaint(ACanvas: TCanvas; const AClip: TRect; FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
  public
    constructor Create(ASynEdit: TSynEdit; AFoundItems: TObjectList);
    destructor Destroy; override;
    property FoundItems: TObjectList read FFoundItems;
  end;

implementation

uses
  Math, Vcl.Themes;

{ THighlightSearchPlugin }

procedure THighlightSearchPlugin.AfterPaint(ACanvas: TCanvas; const AClip: TRect; FirstLine, LastLine: integer);

  procedure PaintHighlight(StartXY, EndXY: TBufferCoord);
  var
    LStyles: TCustomStyleServices;
    Pix: TPoint;
    S: string;
  begin
    LStyles := StyleServices;
    if StartXY.Char < EndXY.Char then
    begin
      Pix := FSynEdit.RowColumnToPixels(FSynEdit.BufferToDisplayPos(StartXY));

      if LStyles.Enabled then
        FBmp.Canvas.Brush.Color := LStyles.GetSystemColor(clHighlight)
      else
        FBmp.Canvas.Brush.Color := clHighlight;

      FBmp.Canvas.Brush.Style := bsSolid;
      S := Copy(FSynEdit.Lines[StartXY.Line - 1], StartXY.Char, EndXY.Char - StartXY.Char);

      FBmp.Height := FSynEdit.LineHeight;
      FBmp.Width := FSynEdit.CharWidth * Length(S);
      FBmp.Canvas.FillRect(Rect(0, 0, FBmp.Width, FBmp.Height));

      FBmp.Canvas.Font.Assign(FSynEdit.Font);

      if (GetRValue(FSynedit.Color) + GetGValue(FSynedit.Color) + GetBValue(FSynedit.Color) < 500) then
        FBmp.Canvas.Font.Color := clWhite
      else
        FBmp.Canvas.Font.Color := clBlack;
      FBmp.Canvas.TextOut(0, 0, S);

      Windows.AlphaBlend(ACanvas.Handle, Pix.X, Pix.Y, FBmp.Width, FBmp.Height,
        FBmp.Canvas.Handle, 0, 0, FBmp.Width, FBmp.Height, FBlendFunc);
    end;
  end;

var
  i: integer;
  FoundItem: TFoundItem;
  StartXY, EndXY: TBufferCoord;
begin
  if not FSynEdit.ShowSearchHighlighter then
    Exit;
  for i := 0 to FFoundItems.Count - 1 do
  begin
    FoundItem := FFoundItems[i] as TFoundItem;
    if InRange(FoundItem.Start.Line, FirstLine, LastLine) then
    begin
      // do not highlight selection
      // Highlight front part
      StartXY := FoundItem.Start;
      EndXY := StartXY;
      while not FSynEdit.IsPointInSelection(EndXY) and (EndXY.Char < FoundItem.Start.Char + FoundItem.Length) do
        Inc(EndXY.Char);
      PaintHighlight(StartXY, EndXY);

      StartXY.Char := EndXY.Char;
      EndXY.Char := FoundItem.Start.Char + FoundItem.Length;
      // Skip Selection
      while FSynEdit.IsPointInSelection(StartXY) and (StartXY.Char < EndXY.Char) do
        Inc(StartXY.Char);
      // Highlight end part
      PaintHighlight(StartXY, EndXY);
    end;
  end;
end;

constructor THighlightSearchPlugin.Create(ASynEdit: TSynEdit;
  AFoundItems: TObjectList);
begin
  inherited Create(ASynEdit);

  FSynEdit := ASynEdit;
  FFoundItems := AFoundItems;

  FBmp := TBitmap.Create;
  FBlendFunc.BlendOp := AC_SRC_OVER;
  FBlendFunc.SourceConstantAlpha := 128;
end;

destructor THighlightSearchPlugin.Destroy;
begin
  FBmp.Free;
  inherited;
end;

procedure THighlightSearchPlugin.LinesDeleted(FirstLine, Count: integer);
begin
  // Do nothing
end;

procedure THighlightSearchPlugin.LinesInserted(FirstLine, Count: integer);
begin
  // Do nothing
end;

end.
