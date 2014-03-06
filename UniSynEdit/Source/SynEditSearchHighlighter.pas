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
    FSynEdit: TSynEdit;
    FFoundItems: TObjectList;
  protected
    procedure AfterPaint(ACanvas: TCanvas; const AClip: TRect; FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
  public
    constructor Create(ASynEdit: TSynEdit; AFoundItems: TObjectList);
  end;

implementation

uses
  Math;

{ THighlightSearchPlugin }

procedure THighlightSearchPlugin.AfterPaint(ACanvas: TCanvas; const AClip: TRect; FirstLine, LastLine: integer);

  procedure PaintHighlight(StartXY, EndXY: TBufferCoord);
  var
    Pix: TPoint;
    S: string;
  begin
    if StartXY.Char < EndXY.Char then
    begin
      Pix := FSynEdit.RowColumnToPixels(FSynEdit.BufferToDisplayPos(StartXY));
      ACanvas.Brush.Color := clYellow;
      ACanvas.Brush.Style := bsSolid;
      SetTextCharacterExtra(ACanvas.Handle, FSynEdit.CharWidth - ACanvas.TextWidth('i'));
      S := Copy(FSynEdit.Lines[StartXY.Line - 1], StartXY.Char, EndXY.Char - StartXY.Char);
      //SetBkMode(ACanvas.Handle, TRANSPARENT);
      ACanvas.TextOut(Pix.X, Pix.Y, S);
    end;
  end;

var
  i: integer;
  FoundItem: TFoundItem;
  StartXY, EndXY: TBufferCoord;
begin
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
