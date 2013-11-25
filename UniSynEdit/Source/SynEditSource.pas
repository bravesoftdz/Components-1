{-------------------------------------------------------------------------------

   单元: SynEditSource.pas

   作者: 姚乔锋

   日期: 2005-05-17 17:20

   说明: 提供存储TSynEdit可用属性

   版本: 1.00

-------------------------------------------------------------------------------}

unit SynEditSource;

{$I SynEdit.inc}

interface

uses
  Windows, Classes, SysUtils, Graphics, Dialogs, Forms, Controls, StdCtrls,
  Clipbrd, IniFiles, SynEdit, SynEditTypes, SynEditKeyCmds, SynEditMiscClasses,
  SynEditTextBuffer, SynEditHighlighter, Menus;

type
  TSynEditSourceMask = (
    {$IFDEF CODEFOLDING}
    //### Code Folding ###
    smCodeFolding,
    //### End Code Folding ###
    {$ENDIF}
    smBackground,
    smActiveLine, smBlockWidth, smBookMarkOptions, smBorderStyle,
    smColor, smFont, smGutter, smHideSelection, smHighlighter,
    smInsertCaret, smInsertMode, smKeystrokes, smLines,
    smLineDivider, smLineSpacing, smLineSpacingRule,
    smMaxScrollWidth, smMaxUndo, smOptions, smOverwriteCaret,
    smPopupMenu, smReadOnly, smRightEdge, smSelectedColor, smSelectionMode,
    smScrollBars, smTabWidth, smWantTabs, smWordWrap, smUnicodeName);
  TSynEditSourceMasks = set of TSynEditSourceMask;

const
  DefaultSynEditSourceMask = [
      {$IFDEF CODEFOLDING}
    //### Code Folding ###
    smCodeFolding,
    //### End Code Folding ###
    {$ENDIF}
    smActiveLine, smBlockWidth, smBookMarkOptions, smBorderStyle,
    smColor, smFont, smGutter, smHideSelection, smHighlighter,
    smInsertCaret, smInsertMode, smKeystrokes, smLines,
    smLineDivider, smLineSpacing, smLineSpacingRule,
    smMaxScrollWidth, smMaxUndo, smOptions, smOverwriteCaret,
    smPopupMenu, smReadOnly, smRightEdge, smSelectedColor, smSelectionMode,
    smScrollBars, smTabWidth, smWantTabs, smWordWrap];

type
  TSynEditSource = class(TComponent)
  private
    FMask : TSynEditSourceMasks;
    FMaxScrollWidth: Integer;
    FKeystrokes: TSynEditKeyStrokes;
    FBookmarks: TSynBookMarkOpt;
    FHideSelection: Boolean;
    FMaxUndo: Integer;
    FTabWidth: Integer;
    FSelectedColor: TSynSelectedColor;
    FFont: TFont;
    FWantTabs: Boolean;
    FOverwriteCaret: TSynEditCaretType;
    FInsertCaret: TSynEditCaretType;
    FOptions: TSynEditorOptions;
    FSynGutter: TSynGutter;
    FColor: TColor;
    fBlockWidth: integer;
    FLineSpacing: integer;
    FLineSpacingRule: TLineSpacingRule;
    FActiveLine: TSynActiveLine;
    FLineDivider: TSynLineDivider;
    FWordWrap: TSynWordWrap;
    FRightEdge: TSynRightEdge;
    FLines: TStrings;
    fHighlighter: TSynCustomHighlighter;
    FBorderStyle: TBorderStyle;
    FReadOnly: Boolean;
    FInsertMode: Boolean;
    FPopupMenu: TPopupMenu;
    FScrollBars: TSynScrollBars;
    FSelectionMode: TSynSelectionMode;
    fBackground: TSynEditBackground;
    FUnicodeFontName: TFontName;
     {$IFDEF CODEFOLDING}
    //### Code Folding ###
    fCodeFolding: TSynCodeFolding;
    //### End Code Folding ###
    {$ENDIF}
    procedure SetBookMarks(const Value: TSynBookMarkOpt);
    procedure SetFont(const Value: TFont);
    procedure SetKeystrokes(const Value: TSynEditKeyStrokes);
    procedure SetSynGutter(const Value: TSynGutter);
    procedure SetActiveLine(const Value: TSynActiveLine);
    procedure SetLineDivider(const Value: TSynLineDivider);
    procedure SetRightEdge(const Value: TSynRightEdge);
    procedure SetWordWrap(const Value: TSynWordWrap);
    procedure SetLines(const Value: TStrings);
    procedure SetHighlighter(const Value: TSynCustomHighlighter);
    procedure SetPopupMenu(const Value: TPopupMenu);
    procedure SetSelectedColor(const Value: TSynSelectedColor);
    procedure SetScrollBars(const Value: TSynScrollBars);
    procedure SetBackground(const Value: TSynEditBackground);
    {$IFDEF CODEFOLDING}
    //### Code Folding ###
    procedure setCodeFolding(const Value: TSynCodeFolding);
    //### End Code Folding ###
    {$ENDIF}
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    function IsMask(Mask : TSynEditSourceMask) : Boolean;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    //Assign a TSynEditAcess or AssignTo a TSynEditAcess
    procedure Assign(Source : TPersistent); override;
    procedure AssignTo(Dest : TPersistent); override;
    //Save self To a IniFile or Load from a IniFile to Self
    procedure SaveToIni(IniFile : TCustomIniFile; Section : string);
    procedure LoadFromIni(IniFile : TCustomIniFile; Section : string);
  published
    property Mask : TSynEditSourceMasks read FMask write FMask;
    {$IFDEF CODEFOLDING}
    //### Code Folding ###
    property CodeFolding: TSynCodeFolding read fCodeFolding write setCodeFolding;
    //### End Code Folding ###
    {$ENDIF}
    property ActiveLine : TSynActiveLine read FActiveLine write SetActiveLine;
    property BlockWidth : integer read fBlockWidth write fBlockWidth;
    property Background: TSynEditBackground read fBackground write SetBackground;
    property BookMarkOptions : TSynBookMarkOpt read FBookmarks write SetBookMarks;
    property BorderStyle : TBorderStyle read FBorderStyle write FBorderStyle;
    property Color : TColor read FColor write FColor;
    property Font : TFont read FFont write SetFont;
    property UnicodeFontName : TFontName read FUnicodeFontName write FUnicodeFontName;
    property Gutter : TSynGutter read FSynGutter write SetSynGutter;
    property HideSelection : Boolean read FHideSelection write FHideSelection;
    property Highlighter : TSynCustomHighlighter read fHighlighter write SetHighlighter;
    property InsertCaret : TSynEditCaretType read FInsertCaret write FInsertCaret;
    property InsertMode : Boolean read FInsertMode write FInsertMode;
    property Keystrokes : TSynEditKeyStrokes read FKeystrokes write SetKeystrokes;
    property Lines : TStrings read FLines write SetLines;
    property LineDivider : TSynLineDivider read FLineDivider write SetLineDivider;
    property LineSpacing : integer read FLineSpacing write FLineSpacing;
    property LineSpacingRule : TLineSpacingRule read FLineSpacingRule write FLineSpacingRule;
    property MaxScrollWidth : Integer read FMaxScrollWidth write FMaxScrollWidth;
    property MaxUndo : Integer read FMaxUndo write FMaxUndo;
    property Options : TSynEditorOptions read FOptions write FOptions;
    property OverwriteCaret : TSynEditCaretType read FOverwriteCaret write FOverwriteCaret;
    property PopupMenu : TPopupMenu read FPopupMenu write SetPopupMenu;
    property ReadOnly : Boolean read FReadOnly write FReadOnly;
    property RightEdge : TSynRightEdge read FRightEdge write SetRightEdge;
    property ScrollBars : TSynScrollBars read FScrollBars write SetScrollBars;
    property SelectedColor : TSynSelectedColor read FSelectedColor write SetSelectedColor;
    property SelectionMode : TSynSelectionMode read FSelectionMode write FSelectionMode;
    property TabWidth : Integer read FTabWidth write FTabWidth;
    property WantTabs : Boolean read FWantTabs write FWantTabs;
    property WordWrap : TSynWordWrap read FWordWrap write SetWordWrap;
  end;

  TSynEditAcess = class(TCustomSynEdit);

implementation

function FontToStr(Font: TFont): String;
  function FontStylesToStr(Styles: TFontStyles): String;
  begin
    Result := '';
    if fsBold in Styles then
      Result := Result + 'B';
    if fsItalic in Styles then
      Result := Result + 'I';
    if fsUnderline in Styles then
      Result := Result + 'U';
   if fsStrikeOut in Styles then
      Result := Result + 'S';
  end;
begin
  with Font do
    Result := Format('%s,%d,%s,%d,%s,%d', [Name, Height,
      FontStylesToStr(Style), Ord(Pitch),
      ColorToString(Color), Charset]);
end;

procedure StrToFont(const s: string; Font: TFont);
  function StrToFontStyles(const Styles: string): TFontStyles;
  var
    i: Integer;
  begin
    Result := [];
    for i := 1 to Length(Styles) do
      case Styles[i] of
        'B','b': Include(Result, fsBold);
        'I','i': Include(Result, fsItalic);
        'U','u': Include(Result, fsUnderline);
        'S','s': Include(Result, fsStrikeOut);
      end;
  end;
var
  I, j, State: Integer;
  s2: string;
begin
  i := 1;
  State := 1;
  while i<=Length(s) do
  begin
    j := i;
    while (j<=Length(s)) and (s[j]<>',') do
      inc(j);
    if (j<=Length(s)) and (s[j]=',') then
    begin
      s2 := Copy(s, i, j-i);
      i := j+1;
    end
    else begin
      s2 := Copy(s, i, j-i+1);
      i := j;
    end;
    case State of
      1: Font.Name := s2;
      2: Font.Height := StrToInt(s2);
      3: Font.Style := StrToFontStyles(s2);
      4: Font.Pitch := TFontPitch(StrToInt(s2));
      5: Font.Color := StringToColor(s2);
      6: Font.Charset := TFontCharset(StrToInt(s2));
    end;
    inc(State);
  end;
end;

{ TSynEditSource }
procedure TSynEditSource.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TCustomSynEdit) then
  begin
    if IsMask(smBackground) then
      Self.Background := TSynEditAcess(Source).Background;
    if IsMask(smActiveLine) then
      Self.ActiveLine := TSynEditAcess(Source).ActiveLine;
    if IsMask(smBlockWidth) then
      self.BlockWidth := TSynEditAcess(Source).BlockWidth;
    if IsMask(smBookMarkOptions) then
      Self.BookmarkOptions := TSynEditAcess(Source).BookmarkOptions;
    if IsMask(smBorderStyle) then
      self.BorderStyle := TSynEditAcess(Source).BorderStyle;
    if IsMask(smColor) then
      Self.Color := TSynEditAcess(Source).Color;
    if IsMask(smFont) then
      Self.Font := TSynEditAcess(Source).Font;
    if IsMask(smGutter) then
      Self.Gutter := TSynEditAcess(Source).Gutter;
    if IsMask(smHideSelection) then
      Self.HideSelection := TSynEditAcess(Source).HideSelection;
    if IsMask(smHighlighter) then
      self.Highlighter := TSynEditAcess(Source).Highlighter;
    if IsMask(smInsertCaret) then
      Self.InsertCaret := TSynEditAcess(Source).InsertCaret;
    if IsMask(smInsertMode) then
      Self.insertMode := TSynEditAcess(Source).insertMode;
    if IsMask(smKeystrokes) then
      Self.Keystrokes := TSynEditAcess(Source).Keystrokes;
    if IsMask(smLines) then
      self.Lines := TSynEditAcess(Source).Lines;
    if IsMask(smLineDivider) then
      Self.LineDivider := TSynEditAcess(Source).LineDivider;
    if IsMask(smLineSpacing) then
      Self.LineSpacing := TSynEditAcess(Source).LineSpacing;
    if IsMask(smLineSpacingRule) then
      Self.LineSpacingRule := TSynEditAcess(Source).LineSpacingRule;
    if IsMask(smMaxScrollWidth) then
      Self.MaxScrollWidth := TSynEditAcess(Source).MaxScrollWidth;
    if IsMask(smMaxUndo) then
      Self.MaxUndo := TSynEditAcess(Source).MaxUndo;
    if IsMask(smOptions) then
      Self.Options := TSynEditAcess(Source).Options;
    if IsMask(smOverwriteCaret) then
      Self.OverwriteCaret := TSynEditAcess(Source).OverwriteCaret;
    if IsMask(smPopupMenu) then
      Self.PopupMenu := TSynEditAcess(Source).PopupMenu;
    if IsMask(smReadOnly) then
      Self.ReadOnly := TSynEditAcess(Source).ReadOnly;
    if IsMask(smRightEdge) then
      Self.RightEdge := TSynEditAcess(Source).RightEdge;
    if IsMask(smScrollBars) then
      Self.ScrollBars := TSynEditAcess(Source).ScrollBars;
    if IsMask(smSelectedColor) then
      Self.SelectedColor := TSynEditAcess(Source).SelectedColor;
    if IsMask(smSelectionMode) then
      Self.SelectionMode := TSynEditAcess(Source).SelectionMode;
    if IsMask(smTabWidth) then
      Self.TabWidth := TSynEditAcess(Source).TabWidth;
    if IsMask(smWantTabs) then
      Self.WantTabs := TSynEditAcess(Source).WantTabs;
    if IsMask(smWordWrap) then
      Self.WordWrap := TSynEditAcess(Source).WordWrap;
    if IsMask(smUnicodeName) then
      Self.UnicodeFontName := TSynEditAcess(Source).UnicodeFontName;
      {$IFDEF CODEFOLDING}
      //### Code Folding ###
    if IsMask(smCodeFolding) then
      Self.CodeFolding := TSynEditAcess(Source).CodeFolding;
      //### End Code Folding ###
      {$ENDIF}
  end
  else if Assigned(Source) and (Source is TSynEditSource) then
  begin
    if IsMask(smActiveLine) then
      Self.ActiveLine := TSynEditSource(Source).ActiveLine;
    if IsMask(smBlockWidth) then
      self.BlockWidth := TSynEditSource(Source).BlockWidth;
    if IsMask(smBookMarkOptions) then
      Self.BookmarkOptions := TSynEditSource(Source).BookmarkOptions;
    if IsMask(smBorderStyle) then
      self.BorderStyle := TSynEditSource(Source).BorderStyle;
    if IsMask(smColor) then
      Self.Color := TSynEditSource(Source).Color;
    if IsMask(smFont) then
      Self.Font := TSynEditSource(Source).Font;
    if IsMask(smGutter) then
      Self.Gutter := TSynEditSource(Source).Gutter;
    if IsMask(smHideSelection) then
      Self.HideSelection := TSynEditSource(Source).HideSelection;
    if IsMask(smHighlighter) then
      self.Highlighter := TSynEditSource(Source).Highlighter;
    if IsMask(smInsertCaret) then
      Self.InsertCaret := TSynEditSource(Source).InsertCaret;
    if IsMask(smInsertMode) then
      Self.insertMode := TSynEditSource(Source).insertMode;
    if IsMask(smKeystrokes) then
      Self.Keystrokes := TSynEditSource(Source).Keystrokes;
    if IsMask(smLines) then
      self.Lines := TSynEditSource(Source).Lines;
    if IsMask(smLineDivider) then
      Self.LineDivider := TSynEditSource(Source).LineDivider;
    if IsMask(smLineSpacing) then
      Self.LineSpacing := TSynEditSource(Source).LineSpacing;
    if IsMask(smLineSpacingRule) then
      Self.LineSpacingRule := TSynEditSource(Source).LineSpacingRule;
    if IsMask(smMaxScrollWidth) then
      Self.MaxScrollWidth := TSynEditSource(Source).MaxScrollWidth;
    if IsMask(smMaxUndo) then
      Self.MaxUndo := TSynEditSource(Source).MaxUndo;
    if IsMask(smOptions) then
      Self.Options := TSynEditSource(Source).Options;
    if IsMask(smOverwriteCaret) then
      Self.OverwriteCaret := TSynEditSource(Source).OverwriteCaret;
    if IsMask(smPopupMenu) then
      Self.PopupMenu := TSynEditSource(Source).PopupMenu;
    if IsMask(smReadOnly) then
      Self.ReadOnly := TSynEditSource(Source).ReadOnly;
    if IsMask(smRightEdge) then
      Self.RightEdge := TSynEditSource(Source).RightEdge;
    if IsMask(smScrollBars) then
      Self.ScrollBars := TSynEditSource(Source).ScrollBars;
    if IsMask(smSelectedColor) then
      Self.SelectedColor := TSynEditSource(Source).SelectedColor;
    if IsMask(smSelectionMode) then
      Self.SelectionMode := TSynEditSource(Source).SelectionMode;
    if IsMask(smTabWidth) then
      Self.TabWidth := TSynEditSource(Source).TabWidth;
    if IsMask(smWantTabs) then
      Self.WantTabs := TSynEditSource(Source).WantTabs;
    if IsMask(smWordWrap) then
      Self.WordWrap := TSynEditSource(Source).WordWrap;
    if IsMask(smUnicodeName) then
      Self.UnicodeFontName := TSynEditSource(Source).UnicodeFontName;
      {$IFDEF CODEFOLDING}
      //### Code Folding ###
    if IsMask(smCodeFolding) then
      Self.CodeFolding := TSynEditSource(Source).CodeFolding;
      //### End Code Folding ###
      {$ENDIF}
  end else inherited;
end;

procedure TSynEditSource.AssignTo(Dest: TPersistent);
begin
  if Assigned(Dest) and (Dest is TCustomSynEdit) then
  begin
    TSynEditAcess(Dest).BeginUpdate;
    if IsMask(smBackground) then
      TSynEditAcess(Dest).Background := Self.Background;
    if IsMask(smActiveLine) then
      TSynEditAcess(Dest).ActiveLine := self.ActiveLine;
    if IsMask(smBlockWidth) then
      TSynEditAcess(Dest).BlockWidth := self.BlockWidth;
    if IsMask(smBookMarkOptions) then
      TSynEditAcess(Dest).BookmarkOptions := self.BookmarkOptions;
    if IsMask(smBorderStyle) then
      TSynEditAcess(Dest).BorderStyle := self.BorderStyle;
    if IsMask(smColor) then
      TSynEditAcess(Dest).Color := self.Color;
    if IsMask(smFont) then
      TSynEditAcess(Dest).Font := self.Font;
    if IsMask(smGutter) then
      TSynEditAcess(Dest).Gutter := self.Gutter;
    if IsMask(smHideSelection) then
      TSynEditAcess(Dest).HideSelection := self.HideSelection;
    if IsMask(smHighlighter) then
      TSynEditAcess(Dest).Highlighter := self.Highlighter;
    if IsMask(smInsertCaret) then
      TSynEditAcess(Dest).InsertCaret := self.InsertCaret;
    if IsMask(smInsertMode) then
      TSynEditAcess(Dest).insertMode := self.insertMode;
    if IsMask(smKeystrokes) then
      TSynEditAcess(Dest).Keystrokes.Assign(self.Keystrokes);
    if IsMask(smLines) then
      TSynEditAcess(Dest).Lines := self.Lines;
    if IsMask(smLineDivider) then
      TSynEditAcess(Dest).LineDivider := self.LineDivider;
    if IsMask(smLineSpacing) then
      TSynEditAcess(Dest).LineSpacing := self.LineSpacing;
    if IsMask(smLineSpacingRule) then
      TSynEditAcess(Dest).LineSpacingRule := self.LineSpacingRule;
    if IsMask(smMaxScrollWidth) then
      TSynEditAcess(Dest).MaxScrollWidth := self.MaxScrollWidth;
    if IsMask(smMaxUndo) then
      TSynEditAcess(Dest).MaxUndo := self.MaxUndo;
    if IsMask(smOptions) then
      TSynEditAcess(Dest).Options := self.Options;
    if IsMask(smOverwriteCaret) then
      TSynEditAcess(Dest).OverwriteCaret := self.OverwriteCaret;
    if IsMask(smPopupMenu) then
      TSynEditAcess(Dest).PopupMenu := self.PopupMenu;
    if IsMask(smReadOnly) then
      TSynEditAcess(Dest).ReadOnly := self.ReadOnly;
    if IsMask(smRightEdge) then
      TSynEditAcess(Dest).RightEdge := self.RightEdge;
    if IsMask(smScrollBars) then
      TSynEditAcess(Dest).ScrollBars := self.ScrollBars;
    if IsMask(smSelectedColor) then
      TSynEditAcess(Dest).SelectedColor := self.SelectedColor;
    if IsMask(smSelectionMode) then
      TSynEditAcess(Dest).SelectionMode := self.SelectionMode;
    if IsMask(smTabWidth) then
      TSynEditAcess(Dest).TabWidth := self.TabWidth;
    if IsMask(smWantTabs) then
      TSynEditAcess(Dest).WantTabs := self.WantTabs;
    if IsMask(smWordWrap) then
      TSynEditAcess(Dest).WordWrap := self.WordWrap;
    if IsMask(smUnicodeName) then
      TSynEditAcess(Dest).UnicodeFontName := self.UnicodeFontName;
      {$IFDEF CODEFOLDING}
      //### Code Folding ###
    if IsMask(smCodeFolding) then
      TSynEditAcess(Dest).CodeFolding := self.CodeFolding;
      //### End Code Folding ###
      {$ENDIF}
    TSynEditAcess(Dest).EndUpdate;
  end else inherited;
end;

constructor TSynEditSource.create(AOwner: TComponent);
begin
  inherited;
  FActiveLine := TSynActiveLine.Create;
  FBookmarks:= TSynBookMarkOpt.Create(Self);
  FFont:= TFont.Create;
  FSynGutter:= TSynGutter.Create;
  FKeystrokes:= TSynEditKeyStrokes.Create(Self);
  FLines := TStringList.Create;
  FLineDivider:= TSynLineDivider.Create;
  FRightEdge:= TSynRightEdge.Create;
  FSelectedColor:= TSynSelectedColor.Create;
  FWordWrap:= TSynWordWrap.Create;
  FScrollBars := TSynScrollBars.create;
  FBackground := TSynEditBackground.Create; 
  {$IFDEF CODEFOLDING}
  //### Code Folding ###
  FCodeFolding := TSynCodeFolding.create;
  //### End Code Folding ###
  {$ENDIF}
  FMask := DefaultSynEditSourceMask;
end;

destructor TSynEditSource.destroy;
begin
  FLines.Free;
  FRightEdge.Free;
  FActiveLine.Free;
  FLineDivider.Free;
  FWordWrap.Free;
  FBookMarks.Free;
  FKeyStrokes.Free;
  FSynGutter.Free;
  FSelectedColor.Free;
  FFont.Free;
  FScrollBars.free;
  FBackground.Free;
  {$IFDEF CODEFOLDING}
  //### Code Folding ###
  fCodeFolding.Free;
  //### End Code Folding ###
  {$ENDIF}
  inherited;
end;

function TSynEditSource.IsMask(Mask: TSynEditSourceMask): Boolean;
begin
  result := Mask in FMask;
end;

procedure TSynEditSource.LoadFromIni(IniFile: TCustomIniFile; Section: String);
  procedure SetOptions(Add : boolean; value: TSynEditorOption);
  begin
    If add then
      Options := Options + [value]
      else Options := Options - [value]
  end;
begin
  if IniFile <> nil then
    with IniFile do
    begin
      if IsMask(smActiveLine) then
        with ActiveLine do
        begin
           Visible := ReadBool(Section, 'ActiveLine_Visible', Visible);
           Indicator.Visible := ReadBool(Section, 'ActiveLine_Indicator', Indicator.Visible);
           Background := ReadInteger(Section, 'ActiveLine_Background', Background);
           Foreground := ReadInteger(Section, 'ActiveLine_Foreground', Foreground);
        end;
      if IsMask(smBackground) then
        with Background do
        begin
          Visible := ReadBool(Section, 'Background_Visible', Visible);
          RepeatMode := TSynBackgroundRepeatMode(ReadInteger(Section,
            'Background_RepeatMode', Integer(RepeatMode)));
        end;
      if IsMask(smBlockWidth) then
        BlockWidth := ReadInteger(Section, 'BlockWidth', BlockWidth);
      if IsMask(smBookMarkOptions) then
        with BookMarkOptions do
        begin
          DrawBookmarksFirst := ReadBool(Section, 'BookMarkOptions_DrawBookmarksFirst', DrawBookmarksFirst);
          EnableKeys := ReadBool(Section, 'BookMarkOptions_EnableKeys', EnableKeys);
          GlyphsVisible := ReadBool(Section, 'BookMarkOptions_GlyphsVisible', GlyphsVisible);
          LeftMargin := ReadInteger(Section, 'BookMarkOptions_LeftMargin', LeftMargin);
          Xoffset := ReadInteger(Section, 'BookMarkOptions_Xoffset', Xoffset);
        end;
      if IsMask(smBorderStyle) then
        BorderStyle := TBorderStyle(ReadInteger(Section, 'BorderStyle', integer(BorderStyle)));
      if IsMask(smColor) then
        Color := ReadInteger(Section, 'Color', Color);
      if IsMask(smFont) then
        StrToFont(ReadString(Section, 'Font', ''), Font);
      if IsMask(smGutter) then
        with Gutter do
        begin
          LeftOffsetColor := ReadInteger(Section, 'Gutter_LeftOffsetColor', LeftOffsetColor);
          RightOffsetColor := ReadInteger(Section, 'Gutter_RightOffsetColor', RightOffsetColor);
          ShowLineModified := ReadBool(Section, 'Gutter_ShowLineModified', ShowLineModified);
          LineNormalColor := ReadInteger(Section, 'Gutter_LineNormalColor', LineNormalColor);
          LineModifiedColor := ReadInteger(Section, 'Gutter_LineModifiedColor', LineModifiedColor);
          AutoSize := ReadBool(Section, 'Gutter_AutoSize', AutoSize);
          BorderStyle := TSynGutterBorderStyle(ReadInteger(Section, 'Gutter_BorderStyle', Integer(BorderStyle)));
          Color := ReadInteger(Section, 'Gutter_Color', Color);
          DigitCount := ReadInteger(Section, 'Gutter_DigitCount', DigitCount);
          StrToFont(ReadString(Section, 'Gutter_Font', ''), Font);
          LeadingZeros := ReadBool(Section, 'Gutter_LeaderZeros', LeadingZeros);
          LeftOffset := ReadInteger(Section, 'Gutter_LeftOffset', LeftOffset);
          RightOffset := ReadInteger(Section, 'Gutter_RightOffset', RightOffset);
          ShowLineNumbers := ReadBool(Section, 'Gutter_ShowLineNumbers', ShowLineNumbers);
          UseFontStyle := ReadBool(Section, 'Gutter_UseFontStyle', UseFontStyle);
          Visible := ReadBool(Section, 'Gutter_Visible', Visible);
          ZeroStart := ReadBool(Section, 'Gutter_ZeroStart', ZeroStart);
          BorderColor := ReadInteger(Section, 'Gutter_BorderColor', BorderColor);
          Intens := ReadBool(Section, 'Gutter_Intens', Intens);
          LineNumberStart := ReadInteger(Section, 'Gutter_LineNumberStart', LineNumberStart);
          Gradient := ReadBool(Section, 'Gutter_Gradient', Gradient);
          GradientStartColor := ReadInteger(Section, 'Gutter_GradientStartColor', GradientStartColor);
          GradientEndColor := ReadInteger(Section, 'Gutter_GradientEndColor', GradientEndColor);
          GradientSteps := ReadInteger(Section, 'Gutter_GradientSteps', GradientSteps);
        end;
      if IsMask(smHideSelection) then
        HideSelection := ReadBool(Section, 'HideSelection', HideSelection);
//      if IsMask(smHighlighter) then
      if IsMask(smInsertCaret) then
        InsertCaret := TSynEditCaretType(ReadInteger(Section, 'InsertCaret', Integer(InsertCaret)));
      if IsMask(smInsertMode) then
        InsertMode := ReadBool(Section, 'InsertMode', InsertMode);
//      if IsMask(smKeystrokes) then
//      if IsMask(smLines) then
      if IsMask(smLineDivider) then
        with LineDivider do
        begin
          Visible := ReadBool(Section, 'LineDivider_Visible', Visible);
          Color := ReadInteger(Section, 'LineDivider_Color', Color);
          Style := TPenStyle(ReadInteger(Section, 'LineDivider_Style', Integer(Style)));
        end;
      if IsMask(smLineSpacing) then
        LineSpacing := ReadInteger(Section, 'LineSpacing', LineSpacing);
      if IsMask(smLineSpacingRule) then
        LineSpacingRule := TLineSpacingRule(ReadInteger(Section, 'LineSpacingRule', Integer(LineSpacingRule)));
      if IsMask(smMaxScrollWidth) then
        MaxScrollWidth := readInteger(Section, 'MaxScrollWidth', MaxScrollWidth);
      if IsMask(smMaxUndo) then
        MaxUndo := ReadInteger(Section, 'MaxUndo', MaxUndo);
      if IsMask(smOptions) then
      begin
        SetOptions(ReadBool(Section, 'Options_AutoIndent', eoAutoIndent in Options), eoAutoIndent);
        SetOptions(ReadBool(Section, 'Options_AltSetsColumnMode', eoAltSetsColumnMode in Options), eoAltSetsColumnMode);
        SetOptions(ReadBool(Section, 'Options_AutoSizeMaxScrollWidth', eoAutoSizeMaxScrollWidth in Options), eoAutoSizeMaxScrollWidth);
        SetOptions(ReadBool(Section, 'Options_DragDropEditing', eoDragDropEditing in Options), eoDragDropEditing);
        SetOptions(ReadBool(Section, 'Options_DisableScrollArrows', eoDisableScrollArrows in Options), eoDisableScrollArrows);
        SetOptions(ReadBool(Section, 'Options_DropFiles', eoDropFiles in Options), eoDropFiles);
        SetOptions(ReadBool(Section, 'Options_EnhanceHomeKey', eoEnhanceHomeKey in Options), eoEnhanceHomeKey);
        SetOptions(ReadBool(Section, 'Options_EnhanceEndKey', eoEnhanceEndKey in Options), eoEnhanceEndKey);
        SetOptions(ReadBool(Section, 'Options_GroupUndo', eoGroupUndo in Options), eoGroupUndo);
        SetOptions(ReadBool(Section, 'Options_HalfPageScroll', eoHalfPageScroll in Options), eoHalfPageScroll);
        SetOptions(ReadBool(Section, 'Options_HideShowScrollbars', eoHideShowScrollbars in Options), eoHideShowScrollbars);
        SetOptions(ReadBool(Section, 'Options_KeepCaretX', eoKeepCaretX in Options), eoKeepCaretX);
        SetOptions(ReadBool(Section, 'Options_NoCaret', eoNoCaret in Options), eoNoCaret);
        SetOptions(ReadBool(Section, 'Options_NoSelection', eoNoSelection in Options), eoNoSelection);
        SetOptions(ReadBool(Section, 'Options_RightMouseMovesCursor', eoRightMouseMovesCursor in Options), eoRightMouseMovesCursor);
        SetOptions(ReadBool(Section, 'Options_ScrollByOneLess', eoScrollByOneLess in Options), eoScrollByOneLess);
        SetOptions(ReadBool(Section, 'Options_ScrollHintFollows', eoScrollHintFollows in Options), eoScrollHintFollows);
        SetOptions(ReadBool(Section, 'Options_ScrollPastEof', eoScrollPastEof in Options), eoScrollPastEof);
        SetOptions(ReadBool(Section, 'Options_ScrollPastEol', eoScrollPastEol in Options), eoScrollPastEol);
        SetOptions(ReadBool(Section, 'Options_ShowScrollHint', eoShowScrollHint in Options), eoShowScrollHint);
        SetOptions(ReadBool(Section, 'Options_ShowSpecialChars', eoShowSpecialChars in Options), eoShowSpecialChars);
        SetOptions(ReadBool(Section, 'Options_SmartTabs', eoSmartTabs in Options), eoSmartTabs);
        SetOptions(ReadBool(Section, 'Options_SmartTabDelete', eoSmartTabDelete in Options), eoSmartTabDelete);
        SetOptions(ReadBool(Section, 'Options_SpecialLineDefaultFg', eoSpecialLineDefaultFg in Options), eoSpecialLineDefaultFg);
        SetOptions(ReadBool(Section, 'Options_TabsToSpaces', eoTabsToSpaces in Options), eoTabsToSpaces);
        SetOptions(ReadBool(Section, 'Options_TabIndent', eoTabIndent in Options), eoTabIndent);
        SetOptions(ReadBool(Section, 'Options_TrimTrailingSpaces', eoTrimTrailingSpaces in Options), eoTrimTrailingSpaces);
        SetOptions(ReadBool(Section, 'Options_ColumnEditExtension', eoColumnEditExtension in Options), eoColumnEditExtension);
      end;
      if IsMask(smOverwriteCaret) then
        OverwriteCaret := TSynEditCaretType(ReadInteger(Section, 'OverwriteCaret', Integer(OverwriteCaret)));
//      if IsMask(smPopupMenu) then
      if IsMask(smReadOnly) then
        ReadOnly := ReadBool(Section, 'ReadOnly', ReadOnly);
      if IsMask(smRightEdge) then
        with RightEdge do
        begin
          Visible := ReadBool(Section, 'RightEdge_Visible', Visible);
          Position := ReadInteger(Section, 'RightEdge_Position', Position);
          Color := ReadInteger(Section, 'RightEdge_Color', Color);
          Style := TPenStyle(ReadInteger(Section, 'RightEdge_Style', Integer(Style)));
          MouseMove := ReadBool(Section, 'RightEdge_MouseMove', MouseMove);
        end;
      if IsMask(smScrollBars) then
        with ScrollBars do
        begin
          ScrollBars := TScrollStyle(ReadInteger(Section, 'ScrollBars_ScrollBars', Integer(ScrollBars)));
          Style := TScrollBarsStyle(ReadInteger(Section, 'ScrollBars_Style', Integer(Style)));
          HintColor := ReadInteger(Section, 'ScrollBars_HintColor', HintColor);
          HintFormat := TScrollHintFormat(ReadInteger(Section, 'ScrollBars_HintFormat', Integer(HintFormat)));
        end;
      if IsMask(smSelectedColor) then
        with SelectedColor do
        begin
          Background := ReadInteger(Section, 'SelectedColor_Background', Background);
          Foreground := ReadInteger(Section, 'SelectedColor_Foreground', Foreground);
        end;
      if IsMask(smSelectionMode) then
        SelectionMode := TSynSelectionMode(ReadInteger(Section, 'SelectionMode', Integer(SelectionMode)));
      if IsMask(smTabWidth) then
        TabWidth := ReadInteger(Section, 'TabWidth', TabWidth);
      if IsMask(smWantTabs) then
        WantTabs := ReadBool(Section, 'WantTabs', WantTabs);
      if IsMask(smWordWrap) then
        with WordWrap do
        begin
          Indicator.Visible := ReadBool(Section, 'Wordwrap_Indicator', Indicator.Visible);
          Enabled := ReadBool(Section, 'Wordwrap_Enabled', Enabled);
          Position := ReadInteger(Section, 'Wordwrap_Position', Position);
          Style := TSynWordWrapStyle(ReadInteger(Section, 'Wordwrap_Style', Integer(Style)));
        end;
        {$IFDEF CODEFOLDING}
        //### Code Folding ###
      if IsMask(smCodeFolding) then
        with fCodeFolding do
        begin
          CaseSensitive := ReadBool(Section, 'CodeFolding_CaseSensitive', CaseSensitive);
          CollapsedCodeHint := ReadBool(Section, 'CodeFolding_CollapsedCodeHint', CollapsedCodeHint);
          CollapsedLineColor := ReadInteger(Section, 'CodeFolding_CollapsedLineColor', CollapsedLineColor);
          CollapsingMarkStyle := TSynCollapsingMarkStyle(ReadInteger(Section, 'CodeFolding_CollapsingMarkStyle', integer(CollapsingMarkStyle)));
          CollapsedLineColor := ReadInteger(Section, 'CodeFolding_CollapsedLineColor', CollapsedLineColor);
          Enabled := ReadBool(Section, 'CodeFolding_Enabled', Enabled);
          FolderBarColor := ReadInteger(Section, 'CodeFolding_FolderBarColor', FolderBarColor);
          FolderBarLinesColor := ReadInteger(Section, 'CodeFolding_FolderBarLinesColor', FolderBarLinesColor);
          HighlighterFoldRegions := ReadBool(Section, 'CodeFolding_HighlighterFoldRegions', HighlighterFoldRegions);
          HighlightIndentGuides := ReadBool(Section, 'CodeFolding_HighlightIndentGuides', HighlightIndentGuides);
          IndentGuides := ReadBool(Section, 'CodeFolding_IndentGuides', IndentGuides);
          ShowCollapsedLine := ReadBool(Section, 'CodeFolding_ShowCollapsedLine', ShowCollapsedLine);
        end;
        //### End Code Folding ###
        {$ENDIF}

      if IsMask(smUnicodeName) then
        UnicodeFontName := ReadString(Section, 'UnicodeFontName', ''); 
    end;

end;

procedure TSynEditSource.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  If (AComponent = fHighlighter) and (Operation = opRemove) then
    fHighlighter := nil;
  If (AComponent = FPopupMenu) and (Operation = opRemove) then
    FPopupMenu := nil;
end;

procedure TSynEditSource.SaveToIni(IniFile: TCustomIniFile; Section: String);
begin
  if IniFile <> nil then
    With IniFile do
    begin
      if IsMask(smActiveLine) then
        with ActiveLine do
        begin
          WriteBool(Section, 'ActiveLine_Visible', Visible);
          WriteBool(Section, 'ActiveLine_Indicator', Indicator.Visible);
          WriteInteger(Section, 'ActiveLine_Background', Background);
          WriteInteger(Section, 'ActiveLine_Foreground', Foreground);
        end;
      if IsMask(smBackground) then
        with Background do
        begin
          WriteBool(Section, 'Background_Visible', Visible);
          WriteInteger(Section, 'Background_RepeatMode', Integer(RepeatMode));
        end;
      if IsMask(smBlockWidth) then
        WriteInteger(Section, 'BlockWidth', BlockWidth);
      if IsMask(smBookMarkOptions) then
        with BookMarkOptions do
        begin
          WriteBool(Section, 'BookMarkOptions_DrawBookmarksFirst', DrawBookmarksFirst);
          WriteBool(Section, 'BookMarkOptions_EnableKeys', EnableKeys);
          WriteBool(Section, 'BookMarkOptions_GlyphsVisible', GlyphsVisible);
          WriteInteger(Section, 'BookMarkOptions_LeftMargin', LeftMargin);
          WriteInteger(Section, 'BookMarkOptions_Xoffset', Xoffset);
        end;
      if IsMask(smBorderStyle) then
        WriteInteger(Section, 'BorderStyle', Integer(BorderStyle));
      if IsMask(smColor) then
        WriteInteger(Section, 'Color', Color);
      if IsMask(smFont) then
        WriteString(Section, 'Font', FontToStr(Font));
      if IsMask(smGutter) then
        with Gutter do
        begin
          WriteBool(Section, 'Gutter_AutoSize', AutoSize);
          WriteInteger(Section, 'Gutter_LeftOffsetColor', LeftOffsetColor);
          WriteInteger(Section, 'Gutter_RightOffsetColor', RightOffsetColor);
          WriteBool(Section, 'Gutter_ShowLineModified', ShowLineModified);
          WriteInteger(Section, 'Gutter_LineNormalColor', LineNormalColor);
          WriteInteger(Section, 'Gutter_LineModifiedColor', LineModifiedColor);
          WriteInteger(Section, 'Gutter_BorderStyle', Integer(BorderStyle));
          WriteInteger(Section, 'Gutter_Color', Color);
          WriteInteger(Section, 'Gutter_DigitCount', DigitCount);
          WriteString(Section, 'Gutter_Font', FontToStr(Font));
          WriteBool(Section, 'Gutter_LeaderZeros', LeadingZeros);
          WriteInteger(Section, 'Gutter_LeftOffset', LeftOffset);
          WriteInteger(Section, 'Gutter_RightOffset', RightOffset);
          WriteBool(Section, 'Gutter_ShowLineNumbers', ShowLineNumbers);
          WriteBool(Section, 'Gutter_UseFontStyle', UseFontStyle);
          WriteBool(Section, 'Gutter_Visible', Visible);
          WriteBool(Section, 'Gutter_ZeroStart', ZeroStart);
          WriteInteger(Section, 'Gutter_BorderColor', BorderColor);
          WriteInteger(Section, 'Gutter_LineNumberStart', LineNumberStart);
          WriteBool(Section, 'Gutter_Intens', Intens);
          WriteBool(Section, 'Gutter_Gradient', Gradient);
          WriteInteger(Section, 'Gutter_GradientStartColor', GradientStartColor);
          WriteInteger(Section, 'Gutter_GradientEndColor', GradientEndColor);
          WriteInteger(Section, 'Gutter_GradientSteps', GradientSteps);
        end;
      if IsMask(smHideSelection) then
        WriteBool(Section, 'HideSelection', HideSelection);
//      if IsMask(smHighlighter) then
      if IsMask(smInsertCaret) then
        WriteInteger(Section, 'InsertCaret', Integer(InsertCaret));
      if IsMask(smInsertMode) then
        WriteBool(Section, 'insertMode', insertMode);
//      if IsMask(smKeystrokes) then
//      if IsMask(smLines) then
      if IsMask(smLineDivider) then
        with LineDivider do
        begin
          WriteBool(Section, 'LineDivider_Visible', Visible);
          WriteInteger(Section, 'LineDivider_Color', Color);
          WriteInteger(Section, 'LineDivider_Style', Integer(Style));
        end;
      if IsMask(smLineSpacing) then
        WriteInteger(Section, 'LineSpacing', LineSpacing);
      if IsMask(smLineSpacingRule) then
        WriteInteger(Section, 'LineSpacingRule', Integer(LineSpacingRule));
      if IsMask(smMaxScrollWidth) then
        WriteInteger(Section, 'MaxScrollWidth', MaxScrollWidth);
      if IsMask(smMaxUndo) then
        WriteInteger(Section, 'MaxUndo', MaxUndo);
      if IsMask(smOptions) then
      begin
        WriteBool(Section, 'Options_AltSetsColumnMode', eoAltSetsColumnMode in Options);
        WriteBool(Section, 'Options_AutoSizeMaxScrollWidth', eoAutoSizeMaxScrollWidth in Options);
        WriteBool(Section, 'Options_AutoIndent', eoAutoIndent in Options);
        WriteBool(Section, 'Options_DisableScrollArrows', eoDisableScrollArrows in Options);
        WriteBool(Section, 'Options_DragDropEditing', eoDragDropEditing in Options);
        WriteBool(Section, 'Options_DropFiles', eoDropFiles in Options);
        WriteBool(Section, 'Options_EnhanceHomeKey', eoEnhanceHomeKey in Options);
        WriteBool(Section, 'Options_EnhanceEndKey', eoEnhanceEndKey in Options);
        WriteBool(Section, 'Options_GroupUndo', eoGroupUndo in Options);
        WriteBool(Section, 'Options_HalfPageScroll', eoHalfPageScroll in Options);
        WriteBool(Section, 'Options_HideShowScrollbars', eoHideShowScrollbars in Options);
        WriteBool(Section, 'Options_KeepCaretX', eoKeepCaretX in Options);
        WriteBool(Section, 'Options_NoCaret', eoNoCaret in Options);
        WriteBool(Section, 'Options_NoSelection', eoNoSelection in Options);
        WriteBool(Section, 'Options_RightMouseMovesCursor', eoRightMouseMovesCursor in Options);
        WriteBool(Section, 'Options_ScrollByOneLess', eoScrollByOneLess in Options);
        WriteBool(Section, 'Options_ScrollHintFollows', eoScrollHintFollows in Options);
        WriteBool(Section, 'Options_ScrollPastEof', eoScrollPastEof in Options);
        WriteBool(Section, 'Options_ScrollPastEol', eoScrollPastEol in Options);
        WriteBool(Section, 'Options_ShowScrollHint', eoShowScrollHint in Options);
        WriteBool(Section, 'Options_ShowSpecialChars', eoShowSpecialChars in Options);
        WriteBool(Section, 'Options_SmartTabs', eoSmartTabs in Options);
        WriteBool(Section, 'Options_SmartTabDelete', eoSmartTabDelete in Options);
        WriteBool(Section, 'Options_SpecialLineDefaultFg', eoSpecialLineDefaultFg in Options);
        WriteBool(Section, 'Options_TabsToSpaces', eoTabsToSpaces in Options);
        WriteBool(Section, 'Options_TabIndent', eoTabIndent in Options);
        WriteBool(Section, 'Options_TrimTrailingSpaces', eoTrimTrailingSpaces in Options);
        WriteBool(Section, 'Options_ColumnEditExtension', eoColumnEditExtension in Options);
      end;
      if IsMask(smOverwriteCaret) then
        WriteInteger(Section, 'OverwriteCaret', Integer(OverwriteCaret));
//      if IsMask(smPopupMenu) then
      if IsMask(smReadOnly) then
        WriteBool(Section, 'ReadOnly', ReadOnly);
      if IsMask(smRightEdge) then
        with RightEdge do
        begin
          WriteBool(Section, 'RightEdge_Visible', Visible);
          WriteInteger(Section, 'RightEdge_Position', Position);
          WriteInteger(Section, 'RightEdge_Color', Color);
          WriteInteger(Section, 'RightEdge_Style', Integer(Style));
          WriteBool(Section, 'RightEdge_MouseMove', MouseMove);
        end;
      if IsMask(smScrollBars) then
        with ScrollBars do
        begin
          WriteInteger(Section, 'ScrollBars_ScrollBars', Integer(ScrollBars));
          WriteInteger(Section, 'ScrollBars_Style', Integer(Style));
          WriteInteger(Section, 'ScrollBars_HintColor', HintColor);
          WriteInteger(Section, 'ScrollBars_HintFormat', Integer(HintFormat));
        end;
      if IsMask(smSelectedColor) then
        with SelectedColor do
        begin
          WriteInteger(Section, 'SelectedColor_Background', Background);
          WriteInteger(Section, 'SelectedColor_Foreground', Foreground);
        end;
      if IsMask(smSelectionMode) then
        WriteInteger(Section, 'SelectionMode', Integer(SelectionMode));
      if IsMask(smTabWidth) then
        WriteInteger(Section, 'TabWidth', TabWidth);
      if IsMask(smWantTabs) then
        WriteBool(Section, 'WantTabs', WantTabs);
      if IsMask(smWordWrap) then
        with WordWrap do
        begin
          WriteBool(Section, 'Wordwrap_Enabled', Enabled);
          WriteInteger(Section, 'Wordwrap_Position', Position);
          WriteInteger(Section, 'Wordwrap_Style', Integer(Style));
          WriteBool(Section, 'Wordwrap_Indicator', Indicator.Visible);
        end;
        {$IFDEF CODEFOLDING}
        //### Code Folding ###
      if IsMask(smCodeFolding) then
        with fCodeFolding do
        begin
          WriteBool(Section, 'CodeFolding_CaseSensitive', CaseSensitive);
          WriteBool(Section, 'CodeFolding_CollapsedCodeHint', CollapsedCodeHint);
          WriteInteger(Section, 'CodeFolding_CollapsedLineColor', CollapsedLineColor);
          WriteInteger(Section, 'CodeFolding_CollapsingMarkStyle', integer(CollapsingMarkStyle));
          WriteInteger(Section, 'CodeFolding_CollapsedLineColor', CollapsedLineColor);
          WriteBool(Section, 'CodeFolding_Enabled', Enabled);
          WriteInteger(Section, 'CodeFolding_FolderBarColor', FolderBarColor);
          WriteInteger(Section, 'CodeFolding_FolderBarLinesColor', FolderBarLinesColor);
          WriteBool(Section, 'CodeFolding_HighlighterFoldRegions', HighlighterFoldRegions);
          WriteBool(Section, 'CodeFolding_HighlightIndentGuides', HighlightIndentGuides);
          WriteBool(Section, 'CodeFolding_IndentGuides', IndentGuides);
          WriteBool(Section, 'CodeFolding_ShowCollapsedLine', ShowCollapsedLine);
        end;
        //### End Code Folding ###
        {$ENDIF}
      if IsMask(smUnicodeName) then
        WriteString(Section, 'UnicodeFontName', UnicodeFontName);
     end;
end;

procedure TSynEditSource.SetActiveLine(const Value: TSynActiveLine);
begin
  FActiveLine.Assign(Value);
end;

procedure TSynEditSource.SetBackground(const Value: TSynEditBackground);
begin
  fBackground.Assign(Value);
end;

procedure TSynEditSource.SetBookMarks(const Value: TSynBookMarkOpt);
begin
  FBookmarks.Assign(Value);
end;

{$IFDEF CODEFOLDING}
//### Code Folding ###
procedure TSynEditSource.setCodeFolding(const Value: TSynCodeFolding);
begin
  fCodeFolding.Assign(Value);
end;
//### End Code Folding ###
{$ENDIF}

procedure TSynEditSource.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TSynEditSource.SetHighlighter(
  const Value: TSynCustomHighlighter);
begin
  if fHighlighter <> nil then
    fHighlighter.RemoveFreeNotification(Self);
  fHighlighter := Value;
  if fHighlighter <> nil then
    fHighlighter.FreeNotification(Self);
end;

procedure TSynEditSource.SetKeystrokes(const Value: TSynEditKeyStrokes);
begin
  FKeystrokes.Assign(Value);
end;

procedure TSynEditSource.SetLineDivider(const Value: TSynLineDivider);
begin
  FLineDivider.Assign(Value);
end;

procedure TSynEditSource.SetLines(const Value: TStrings);
begin
  FLines.Assign(Value);
end;

procedure TSynEditSource.SetPopupMenu(const Value: TPopupMenu);
begin
  if FPopupMenu <> nil then
    FPopupMenu.RemoveFreeNotification(Self);
  FPopupMenu := Value;
  if FPopupMenu <> nil then
    FPopupMenu.FreeNotification(Self);
end;

procedure TSynEditSource.SetRightEdge(const Value: TSynRightEdge);
begin
  FRightEdge.Assign(Value);
end;

procedure TSynEditSource.SetScrollBars(const Value: TSynScrollBars);
begin
  FScrollBars.Assign(Value);
end;

procedure TSynEditSource.SetSelectedColor(const Value: TSynSelectedColor);
begin
  FSelectedColor.Assign(Value);
end;

procedure TSynEditSource.SetSynGutter(const Value: TSynGutter);
begin
  FSynGutter.Assign(Value);
end;

procedure TSynEditSource.SetWordWrap(const Value: TSynWordWrap);
begin
  FWordWrap.Assign(Value);
end;

end.
