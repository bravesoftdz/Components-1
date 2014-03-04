{ -----------------------------------------------------------------------------
  Unit Name: SynEditSearchHighlighter
  Author:    Kiriakos Vlahos
  Date:      24-May-2007
  Purpose:   Classes and support routints for highlighting a search term
  ----------------------------------------------------------------------------- }

unit SynEditSearchHighlighter;

interface

uses
  Windows, Classes, SysUtils, Contnrs, Graphics, Synedit,
  SynEditTypes, SynEditMiscClasses;

type
  TFoundItem = class
    Start: TBufferCoord;
    Length: Word;
  end;

  THighlightSearchPlugin = class(TSynEditPlugin)
  private
    fSynEdit: TSynEdit;
    fFoundItems: TObjectList;
  protected
    procedure AfterPaint(ACanvas: TCanvas; const AClip: TRect;
      FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
  public
    constructor Create(ASynEdit: TSynEdit; AFoundItems: TObjectList);
  end;

{procedure FindSearchTerm(ATerm: string; Synedit: TSynEdit; FoundItems: TObjectList; SearchEngine: TSynEditSearchCustom;
  SearchOptions: TSynSearchOptions);

procedure InvalidateHighlightedTerms(Synedit: TSynEdit; FoundItems: TObjectList); }
//procedure ClearAllHighlightedTerms;

implementation

uses
  Math{, uEditAppIntfs, frmEditor};

{ THighlightSearchPlugin }

procedure THighlightSearchPlugin.AfterPaint(ACanvas: TCanvas; const AClip: TRect; FirstLine, LastLine: integer);

  procedure PaintHightlight(StartXY, EndXY: TBufferCoord);
  var
    Pix: TPoint;
    S: string;
  begin
    if StartXY.Char < EndXY.Char then
    begin
      Pix := fSynEdit.RowColumnToPixels(fSynEdit.BufferToDisplayPos(StartXY));
      ACanvas.Brush.Color := clYellow;
      ACanvas.Brush.Style := bsSolid;
      SetTextCharacterExtra(ACanvas.Handle, fSynEdit.CharWidth -
        ACanvas.TextWidth('W'));
      S := Copy(fSynEdit.Lines[StartXY.Line - 1], StartXY.Char,
        EndXY.Char - StartXY.Char);
      ACanvas.TextOut(Pix.X, Pix.Y, S);
    end;
  end;

var
  i: integer;
  FoundItem: TFoundItem;
  StartXY, EndXY: TBufferCoord;
begin
  for i := 0 to fFoundItems.Count - 1 do
  begin
    FoundItem := fFoundItems[i] as TFoundItem;
    if InRange(FoundItem.Start.Line, FirstLine, LastLine) then
    begin
      // do not highlight selection
      // Highlight front part
      StartXY := FoundItem.Start;
      EndXY := StartXY;
      while not fSynEdit.IsPointInSelection(EndXY) and
        (EndXY.Char < FoundItem.Start.Char + FoundItem.Length) do
        Inc(EndXY.Char);
      PaintHightlight(StartXY, EndXY);

      StartXY.Char := EndXY.Char;
      EndXY.Char := FoundItem.Start.Char + FoundItem.Length;
      // Skip Selection
      while fSynEdit.IsPointInSelection(StartXY) and
        (StartXY.Char < EndXY.Char) do
        Inc(StartXY.Char);
      // Highlight end part
      PaintHightlight(StartXY, EndXY);
    end;
  end;
end;

constructor THighlightSearchPlugin.Create(ASynEdit: TSynEdit;
  AFoundItems: TObjectList);
begin
  inherited Create(ASynEdit);
  fSynEdit := ASynEdit;
  fFoundItems := AFoundItems;
end;

procedure THighlightSearchPlugin.LinesDeleted(FirstLine, Count: integer);
begin
  // Do nothing
end;

procedure THighlightSearchPlugin.LinesInserted(FirstLine, Count: integer);
begin
  // Do nothing
end;

{procedure FindSearchTerm(ATerm: string; Synedit: TSynEdit;
  FoundItems: TObjectList; SearchEngine: TSynEditSearchCustom;
  SearchOptions: TSynSearchOptions);
var
  i: integer;
  j: integer;
  FoundItem: TFoundItem;
begin
  InvalidateHighlightedTerms(Synedit, FoundItems);
  FoundItems.Clear;

  if ATerm = '' then
    Exit;

  for i := 0 to Synedit.Lines.Count - 1 do
  begin
    SearchEngine.Options := SearchOptions;
    SearchEngine.Pattern := ATerm;
    SearchEngine.FindAll(Synedit.Lines[i]);
    for j := 0 to SearchEngine.ResultCount - 1 do
    begin
      FoundItem := TFoundItem.Create;
      FoundItem.Start := BufferCoord(SearchEngine.Results[j], i + 1);
      FoundItem.Length := SearchEngine.Lengths[j];
      FoundItems.Add(FoundItem);
      Synedit.InvalidateLine(i + 1);
    end;
  end;
end;

procedure InvalidateHighlightedTerms(Synedit: TSynEdit;
  FoundItems: TObjectList);
var
  i: integer;
  FoundItem: TFoundItem;
begin
  for i := 0 to FoundItems.Count - 1 do
  begin
    FoundItem := FoundItems[i] as TFoundItem;
    Synedit.InvalidateLine(FoundItem.Start.Line);
  end;
end;  }

{procedure ClearAllHighlightedTerms;
var
  i: integer;
  Editor: IEditor;
begin
  for i := 0 to GI_EditorFactory.Count - 1 do
  begin
    Editor := GI_EditorFactory.Editor[i];
    InvalidateHighlightedTerms(Editor.Synedit, TEditorForm(Editor.Form).FoundSearchItems);
    InvalidateHighlightedTerms(Editor.SynEdit2, TEditorForm(Editor.Form).FoundSearchItems);
    TEditorForm(Editor.Form).FoundSearchItems.Clear;
  end;
end;  }

end.
