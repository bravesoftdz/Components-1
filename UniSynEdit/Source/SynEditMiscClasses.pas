{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

The Original Code is: SynEditMiscClasses.pas, released 2000-04-07.
The Original Code is based on the mwSupportClasses.pas file from the
mwEdit component suite by Martin Waldenburg and other developers, the Initial
Author of this file is Michael Hieke.
All Rights Reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: SynEditMiscClasses.pas,v 1.35 2004/07/31 15:31:41 markonjezic Exp $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

Known Issues:
-------------------------------------------------------------------------------}

{$IFNDEF QSYNEDITMISCCLASSES}
unit SynEditMiscClasses;
{$ENDIF}

{$I SynEdit.inc}

interface

uses
{$IFDEF SYN_CLX}
  {$IFDEF LINUX}
  Xlib,
  {$ENDIF}
  Types,
  Qt,
  QConsts,
  QGraphics,
  QControls,
  QImgList,
  QStdCtrls,
  QMenus,
  kTextDrawer,
  QSynEditTypes,
  QSynEditKeyConst,
{$ELSE}
  Consts,
  Windows,
  Messages,
  Graphics,
  Controls,
  Forms,
  StdCtrls,
  Menus,
  Registry,
  SynEditTypes,
  SynEditKeyConst,
{$ENDIF}
{$IFDEF SYN_COMPILER_4_UP}
  Math,
{$ENDIF}

	//### Code Folding ###
  SynEditCodeFolding,
  //### End Code Folding ###

  Classes,
  SysUtils;

type
  TSynSelectedColor = class(TPersistent)
  private
    fBG: TColor;
    fFG: TColor;
    fOnChange: TNotifyEvent;
    procedure SetBG(Value: TColor);
    procedure SetFG(Value: TColor);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Background: TColor read fBG write SetBG default clHighLight;
    property Foreground: TColor read fFG write SetFG default clHighLightText;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynMinimap = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FFont: TFont;
    FWidth: Integer;
    FVisible: Boolean;
    FCharWidth: Integer;
    FCharHeight: Integer;
    FLinesInWindow: Integer;
    FTopLine: Integer;
    procedure SetFont(Value: TFont);
    procedure SetWidth(Value: Integer);
    procedure SetVisible(Value: Boolean);
    function GetWidth: Integer;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Font: TFont read FFont write SetFont;
    property Width: Integer read GetWidth write SetWidth default 160;
    property Visible: Boolean read FVisible write SetVisible default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property CharWidth: Integer read FCharWidth write FCharWidth;
    property CharHeight: Integer read FCharHeight write FCharHeight;
    property LinesInWindow: Integer read FLinesInWindow write FLinesInWindow;
    property TopLine: Integer read FTopLine write FTopLine default 1;
  end;

  TSynGutterBorderStyle = (gbsNone, gbsMiddle, gbsRight);

  TSynGutter = class(TPersistent)
  private
    fFont: TFont;
    fColor: TColor;
    fBorderColor: TColor;
    fWidth: integer;
    fShowLineNumbers: boolean;
    FShowLineNumbersAfterLastLine: Boolean;
    fDigitCount: integer;
    fLeadingZeros: boolean;
    fZeroStart: boolean;
    FBookmarkPanelWidth: integer;
    fRightOffset: integer;
    fOnChange: TNotifyEvent;
    fCursor: TCursor;
    fVisible: boolean;
    fUseFontStyle: boolean;
    fAutoSize: boolean;
    fAutoSizeDigitCount: integer;
    fBorderStyle: TSynGutterBorderStyle;
    fLineNumberStart: Integer;
    fGradient: Boolean;
    fGradientStartColor: TColor;
    fGradientEndColor: TColor;
    fGradientSteps: Integer;
    FIntens: boolean;
    FBookmarkPanelColor: TColor;
    fRightOffsetColor: TColor;
    fLineModifiedColor: TColor;
    FShowBookmarks: Boolean;
    FShowBookmarkPanel: Boolean;
    fShowLineModified: Boolean;
    fLineNormalColor: TColor;
    function GetWidth: Integer;
    procedure SetIntens(const Value: boolean);
    procedure SetAutoSize(const Value: boolean);
    procedure SetColor(const Value: TColor);
    procedure SetDigitCount(Value: integer);
    procedure SetLeadingZeros(const Value: boolean);
    procedure SetBookmarkPanelWidth(Value: integer);
    procedure SetRightOffset(Value: integer);
    procedure SetShowLineNumbers(const Value: boolean);
    procedure SetUseFontStyle(Value: boolean);
    procedure SetVisible(Value: boolean);
    procedure SetWidth(Value: integer);
    procedure SetZeroStart(const Value: boolean);
    procedure SetFont(Value: TFont);
    procedure OnFontChange(Sender: TObject);
    procedure SetBorderStyle(const Value: TSynGutterBorderStyle);
    procedure SetLineNumberStart(const Value: Integer);
    procedure SetBorderColor(const Value: TColor);
    procedure SetGradient(const Value: Boolean);
    procedure SetGradientEndColor(const Value: TColor);
    procedure SetGradientStartColor(const Value: TColor);
    procedure SetGradientSteps(const Value: Integer);
    procedure SetBookmarkPanelColor(const Value: TColor);
    procedure SetRightOffsetColor(const Value: TColor);
    procedure SetLineModifiedColor(const Value: TColor);
    procedure SetLineNormalColor(const Value: TColor);
    procedure SetShowLineModified(const Value: Boolean);
    procedure SetShowBookmarks(const Value: Boolean);
    procedure SetShowBookmarkPanel(const Value: Boolean);
    procedure SetShowLineNumbersAfterLastLine(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AutoSizeDigitCount(LinesCount: integer);
    function FormatLineNumber(Line: integer): string;
    function RealGutterWidth(CharWidth: integer): integer;
  published
    property ShowLineModified : Boolean read fShowLineModified write setShowLineModified;
    property LineModifiedColor : TColor read fLineModifiedColor write setLineModifiedColor;
    property LineNormalColor : TColor read fLineNormalColor write setLineNormalColor;
    property Intens : boolean read FIntens write SetIntens default True;
    property AutoSize: boolean read fAutoSize write SetAutoSize default False;
    property BorderStyle: TSynGutterBorderStyle read fBorderStyle write SetBorderStyle default gbsNone;
    property Color: TColor read fColor write SetColor default clBtnFace;
    property Cursor: TCursor read fCursor write fCursor default crDefault;
    property DigitCount: integer read fDigitCount write SetDigitCount default 4;
    property Font: TFont read fFont write SetFont;
    property LeadingZeros: boolean read fLeadingZeros write SetLeadingZeros default False;
    property BookmarkPanelWidth: Integer read FBookmarkPanelWidth write SetBookmarkPanelWidth default 20;
    property BookmarkPanelColor: TColor read FBookmarkPanelColor write SetBookmarkPanelColor;
    property RightOffset: integer read fRightOffset write SetRightOffset default 5;
    property RightOffsetColor: TColor read fRightOffsetColor write SetRightOffsetColor;
    property ShowLineNumbers: boolean read fShowLineNumbers write SetShowLineNumbers default False;
    property ShowLineNumbersAfterLastLine: Boolean read FShowLineNumbersAfterLastLine write SetShowLineNumbersAfterLastLine default False;
    property ShowBookmarks: Boolean read FShowBookmarks write SetShowBookmarks default True;
    property ShowBookmarkPanel: Boolean read FShowBookmarkPanel write SetShowBookmarkPanel default True;
    property UseFontStyle: boolean read fUseFontStyle write SetUseFontStyle default True;
    property Visible: boolean read fVisible write SetVisible default True;
    property Width: integer read GetWidth write SetWidth default 30;
    property ZeroStart: boolean read fZeroStart write SetZeroStart default False;
    property BorderColor: TColor read fBorderColor write SetBorderColor default clWindow;
    property LineNumberStart : Integer read fLineNumberStart write SetLineNumberStart default 1;
    property Gradient: Boolean read fGradient write SetGradient default False;
    property GradientStartColor: TColor read fGradientStartColor write SetGradientStartColor default clWindow;
    property GradientEndColor: TColor read fGradientEndColor write SetGradientEndColor default clBtnFace;
    property GradientSteps: Integer read fGradientSteps write SetGradientSteps default 48;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

	//### Code Folding ###
  TSynCollapsingMarkStyle = (msSquare, msEllipse);
  TSynCodeFoldingChanges = (fcEnabled, fcRefresh, fcRescan);

  TCodeFoldingChangeEvent = procedure(Event: TSynCodeFoldingChanges) of object;

  TSynCodeFolding = class(TPersistent)
  private
    fHighlighterFoldRegions: Boolean;
    fCollapsedCodeHint: Boolean;
    fIndentGuides: Boolean;
    fShowCollapsedLine: Boolean;
    fCollapsedLineColor: TColor;
    fEnabled: Boolean;
    fHighlightIndentGuides: Boolean;
    fFolderBarColor: TColor;
    fFolderBarLinesColor: TColor;
    fCollapsingMarkStyle: TSynCollapsingMarkStyle;
    fFoldRegions: TFoldRegions;
    fCaseSensitive: Boolean;
    fOnChange: TCodeFoldingChangeEvent;

    procedure SetFolderBarColor(const Value: TColor);
    procedure SetFolderBarLinesColor(const Value: TColor);
    procedure SetEnabled(const Value: Boolean);
    procedure SetCollapsedCodeHint(const Value: Boolean);
    procedure SetCollapsedLineColor(const Value: TColor);
    procedure SetCollapsingMarkStyle(const Value: TSynCollapsingMarkStyle);
    procedure SetHighlighterFoldRegions(const Value: Boolean);
    procedure SetHighlightIndentGuides(const Value: Boolean);
    procedure SetIndentGuides(const Value: Boolean);
    procedure SetShowCollapsedLine(const Value: Boolean);
    procedure SetCaseSensitive(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  published //###mod formeditor
    property CaseSensitive: Boolean read fCaseSensitive write SetCaseSensitive;
    property CollapsedCodeHint: Boolean read fCollapsedCodeHint
    	write SetCollapsedCodeHint default True;
    property CollapsedLineColor: TColor read fCollapsedLineColor
    	write SetCollapsedLineColor default clDefault;
    property CollapsingMarkStyle: TSynCollapsingMarkStyle
    	read fCollapsingMarkStyle write SetCollapsingMarkStyle default msSquare;
    property Enabled: Boolean read fEnabled write SetEnabled default False;
    property FoldRegions: TFoldRegions read fFoldRegions;
    property FolderBarColor: TColor read fFolderBarColor
    	write SetFolderBarColor default clDefault;
    property FolderBarLinesColor: TColor read fFolderBarLinesColor
    	write SetFolderBarLinesColor default clDefault;
    property HighlighterFoldRegions: Boolean read fHighlighterFoldRegions
    	write SetHighlighterFoldRegions default True;
    property HighlightIndentGuides: Boolean read fHighlightIndentGuides
    	write SetHighlightIndentGuides default True;
    property IndentGuides: Boolean read fIndentGuides write SetIndentGuides
    	default True;
    property ShowCollapsedLine: Boolean read fShowCollapsedLine
    	write SetShowCollapsedLine default True;
    property OnChange: TCodeFoldingChangeEvent read fOnChange write fOnChange;
  end;
  //### End Code Folding ###

  TSynBookMarkOpt = class(TPersistent)
  private
    fBookmarkImages: TImageList;
    fDrawBookmarksFirst: boolean;
    fEnableKeys: Boolean;
    fGlyphsVisible: Boolean;
    fLeftMargin: Integer;
    fOwner: TComponent;
    fXoffset: integer;
    fOnChange: TNotifyEvent;
    procedure SetBookmarkImages(const Value: TImageList);
    procedure SetDrawBookmarksFirst(Value: boolean);
    procedure SetGlyphsVisible(Value: Boolean);
    procedure SetLeftMargin(Value: Integer);
    procedure SetXOffset(Value: integer);
  public
    constructor Create(AOwner: TComponent);
    procedure Assign(Source: TPersistent); override;
  published
    property BookmarkImages: TImageList read fBookmarkImages write SetBookmarkImages;
    property DrawBookmarksFirst: boolean read fDrawBookmarksFirst write SetDrawBookmarksFirst default True;
    property EnableKeys: Boolean read fEnableKeys write fEnableKeys default True;
    property GlyphsVisible: Boolean read fGlyphsVisible write SetGlyphsVisible default True;
    property LeftMargin: Integer read fLeftMargin write SetLeftMargin default 2;
    property Xoffset: integer read fXoffset write SetXOffset default 12;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynGlyph = class(TPersistent)
  private
    fVisible: boolean;
    fInternalGlyph, fGlyph: TBitmap;
    fInternalMaskColor, fMaskColor: TColor;
    fOnChange: TNotifyEvent;
    procedure SetGlyph(Value: TBitmap);
    procedure GlyphChange(Sender: TObject);
    procedure SetMaskColor(Value: TColor);
    procedure SetVisible(Value: boolean);
    function GetWidth : integer;
    function GetHeight : integer;
  public
    constructor Create(aModule: THandle; const aName: string; aMaskColor: TColor);
    destructor Destroy; override;
    procedure Assign(aSource: TPersistent); override;
    procedure Draw(aCanvas: TCanvas; aX, aY, aLineHeight: integer);
    property Width : integer read GetWidth;
    property Height : integer read GetHeight;
  published
    property Glyph: TBitmap read fGlyph write SetGlyph;
    property MaskColor: TColor read fMaskColor write SetMaskColor default clNone;
    property Visible: boolean read fVisible write SetVisible default True;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  { TSynMethodChain }

  ESynMethodChain = class(Exception);
  TSynExceptionEvent = procedure (Sender: TObject; E: Exception;
    var DoContinue: Boolean) of object;

  TSynMethodChain = class(TObject)
  private
    FNotifyProcs: TList;
    FExceptionHandler: TSynExceptionEvent;
  protected
    procedure DoFire(const AEvent: TMethod); virtual; abstract;
    function DoHandleException(E: Exception): Boolean; virtual;
    property ExceptionHandler: TSynExceptionEvent read FExceptionHandler
      write FExceptionHandler;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Add(AEvent: TMethod);
    procedure Remove(AEvent: TMethod);
    procedure Fire;
  end;

  { TSynNotifyEventChain }

  TSynNotifyEventChain = class(TSynMethodChain)
  private
    FSender: TObject;
  protected
    procedure DoFire(const AEvent: TMethod); override;
  public
    constructor CreateEx(ASender: TObject);
    procedure Add(AEvent: TNotifyEvent);
    procedure Remove(AEvent: TNotifyEvent);
    property ExceptionHandler;
    property Sender: TObject read FSender write FSender;
  end;

  { TSynInternalImage }

  TSynInternalImage = class(TObject)
  private
    fImages : TBitmap;
    fWidth  : Integer;
    fHeight : Integer;
    fCount  : Integer;

    function CreateBitmapFromInternalList(aModule: THandle; const Name: string): TBitmap;
    procedure FreeBitmapFromInternalList;
  public
    constructor Create(aModule: THandle; const Name: string; Count: integer);
    destructor Destroy; override;
    procedure Draw(ACanvas: TCanvas; Number, X, Y, LineHeight: integer);
    procedure DrawTransparent(ACanvas: TCanvas; Number, X, Y,
      LineHeight: integer; TransparentColor: TColor);
  end;

{ TSynHotKey }

const
  {$IFDEF SYN_CLX}
  BorderWidth = 2;
  {$ELSE}
  BorderWidth = 0;
  {$ENDIF}

type
  {$IFDEF SYN_CLX}
  TSynBorderStyle = bsNone..bsSingle;
  {$ELSE}
  TSynBorderStyle = TBorderStyle;
  {$ENDIF}

  THKModifier = (hkShift, hkCtrl, hkAlt);
  THKModifiers = set of THKModifier;
  THKInvalidKey = (hcNone, hcShift, hcCtrl, hcAlt, hcShiftCtrl,
    hcShiftAlt, hcCtrlAlt, hcShiftCtrlAlt);
  THKInvalidKeys = set of THKInvalidKey;

  TSynHotKey = class(TCustomControl)
  private
    FBorderStyle: TSynBorderStyle;
    FHotKey: TShortCut;
    FInvalidKeys: THKInvalidKeys;
    FModifiers: THKModifiers;
    FPressedOnlyModifiers: Boolean;
    procedure SetBorderStyle(const Value: TSynBorderStyle);
    procedure SetHotKey(const Value: TShortCut);
    procedure SetInvalidKeys(const Value: THKInvalidKeys);
    procedure SetModifiers(const Value: THKModifiers);
    {$IFNDEF SYN_CLX}
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
     procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    {$ENDIF}
  protected
    {$IFNDEF SYN_CLX}
    procedure CreateParams(var Params: TCreateParams); override;
    {$ENDIF}
    {$IFDEF SYN_CLX}
    function EventFilter(Sender: QObjectH; Event: QEventH): Boolean; override;
    {$ENDIF}
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    {$IFDEF SYN_CLX}
    function WidgetFlags: Integer; override;
    {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
  published
    property BorderStyle: TSynBorderStyle read FBorderStyle write SetBorderStyle
      default bsSingle;
    property HotKey: TShortCut read FHotKey write SetHotKey default $0041; { Alt+A }
    property InvalidKeys: THKInvalidKeys read FInvalidKeys write SetInvalidKeys default [hcNone, hcShift];
    property Modifiers: THKModifiers read FModifiers write SetModifiers default [hkAlt];
  end;

  TSynEditSearchCustom = class(TComponent)
  protected
    function GetPattern: unicodestring; virtual; abstract;
    procedure SetPattern(const Value: unicodestring); virtual; abstract;
    function GetText: unicodestring; virtual; abstract;
    procedure SetText(const Value: unicodestring); virtual; abstract;
    function GetLength(aIndex: integer): integer; virtual; abstract;
    function GetResult(aIndex: integer): integer; virtual; abstract;
    function GetResultCount: integer; virtual; abstract;
    procedure SetOptions(const Value: TSynSearchOptions); virtual; abstract;
  public
    function FindAll(const NewText: unicodestring): integer; virtual; abstract;
    function Replace(const aOccurrence, aReplacement: unicodestring): unicodestring; virtual; abstract;
    property ResultCount: integer read GetResultCount;
    property Results[aIndex: integer]: integer read GetResult;
    property Lengths[aIndex: integer]: integer read GetLength;
    property Pattern: unicodestring read GetPattern write SetPattern;
    property Options: TSynSearchOptions write SetOptions;
  end;

  TSynLineDivider = class(TPersistent)
  private
    FVisible: boolean;
    FColor: TColor;
    fOnChange: TNotifyEvent;
    FStyle: TPenStyle;
    procedure DoChange;
    procedure SetColor(const Value: TColor);
    procedure SetStyle(const Value: TPenStyle);
    procedure SetVisible(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Visible: boolean read FVisible write SetVisible;
    property Color : TColor Read FColor write SetColor;
    property Style : TPenStyle read FStyle write SetStyle;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynActiveLine = class(TPersistent)
  private
    FVisible: boolean;
    FBackground: TColor;
    FForeground: TColor;
    fOnChange: TNotifyEvent;
    FIndicator: TSynGlyph;
    procedure DoChange(Sender : TObject);
    procedure SetBackground(const Value: TColor);
    procedure SetForeground(const Value: TColor);
    procedure SetIndicator(const Value: TSynGlyph);
    procedure SetVisible(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Background: TColor read FBackground write SetBackground;
    property Foreground: TColor read FForeground write SetForeground;
    property Indicator : TSynGlyph read FIndicator write SetIndicator;
    property Visible: boolean read FVisible write SetVisible;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynRightEdge = class(TPersistent)
  private
    FVisible: Boolean;
    FPosition: Integer;
    FColor: TColor;
    fOnChange: TNotifyEvent;
    FStyle: TPenStyle;
    FMouseMove: Boolean;
    procedure DoChange;
    procedure SetColor(const Value: TColor);
    procedure SetPosition(const Value: Integer);
    procedure SetStyle(const Value: TPenStyle);
    procedure SetVisible(const Value: Boolean);
    procedure SetMouseMove(const Value: Boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property MouseMove : Boolean read FMouseMove write SetMouseMove;
    property Visible : Boolean read FVisible write SetVisible;
    property Position : Integer read FPosition write SetPosition;
    property Color : TColor Read FColor write SetColor;
    property Style : TPenStyle read FStyle write SetStyle;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynWordWrapStyle = (wwsClientWidth, wwsRightEdge, wwsSpecified);

  TSynWordWrap = class(TPersistent)
  private
    FEnabled: Boolean;
    FPosition: Integer;
    fOnChange: TNotifyEvent;
    FIndicator: TSynGlyph;
    FStyle: TSynWordWrapStyle;
    procedure DoChange(Sender: TObject);
    procedure SetEnabled(const Value: Boolean);
    procedure SetIndicator(const Value: TSynGlyph);
    procedure SetPosition(const Value: Integer);
    procedure SetStyle(const Value: TSynWordWrapStyle);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Enabled : Boolean read FEnabled write SetEnabled;
    property Position : Integer read FPosition write SetPosition;
    property Style : TSynWordWrapStyle read FStyle write SetStyle;
    property Indicator : TSynGlyph read FIndicator write SetIndicator;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynScrollBars = class;
  TGetScrollInfoEvent = function(var ScrollInfo : TScrollInfo): Boolean of object;
  TSetScrollInfoEvent = function(const ScrollInfo : TScrollInfo; Redraw : Boolean) : Integer of object;
  TShowScrollBarEvent = function(const sbShow : Boolean): Boolean of object;
  TEnabledScrollBarEvent = function(const sbArrows : Integer): Boolean of object;
  TSynEditScrollBar = class(TComponent)
  private
    FOnGetScrollInfo : TGetScrollInfoEvent;
    FOnSetScrollInfo : TSetScrollInfoEvent;
    FOnShowScrollBar : TShowScrollBarEvent;
    FOnEnabledScrollBar : TEnabledScrollBarEvent;
    FScrollBars : TSynScrollBars;
  public
    destructor Destroy;override;
    procedure Assign(Source: TPersistent); override;
    function DoGetScrollInfo(var ScrollInfo : TScrollInfo): Boolean;
    function DoSetScrollInfo(const ScrollInfo : TScrollInfo; Redraw : Boolean) : Integer;
    function DoShowScrollBar(const sbShow : Boolean): Boolean;
    function DoEnabledScrollBar(const sbArrows : Integer): Boolean;
  published
    property OnGetScrollInfo : TGetScrollInfoEvent read FOnGetScrollInfo write FOnGetScrollInfo;
    property OnSetScrollInfo : TSetScrollInfoEvent read FOnSetScrollInfo write FOnSetScrollInfo;
    property OnShowScrollBar : TShowScrollBarEvent read FOnShowScrollBar write FOnShowScrollBar;
    property OnEnabledScrollBar : TEnabledScrollBarEvent read FOnEnabledScrollBar write FOnEnabledScrollBar;
  end;

  TScrollBarsStyle = (sbsRegular, sbsEncarta, sbsFlat, sbsCustom);
  TScrollHintFormat = (shfTopLineOnly, shfTopToBottom);
  TSynScrollBars = class(TPersistent)
  private
    FScrollBars: System.UITypes.TScrollStyle;
    FStyle: TScrollBarsStyle;
    fHintColor: TColor;
    fHintFormat: TScrollHintFormat;
    FVertical: TSynEditScrollBar;
    FHorizontal: TSynEditScrollBar;
    fOnChange: TNotifyEvent;
    procedure doChange;
    procedure SetHorizontal(const Value: TSynEditScrollBar);
    procedure SetScrollBars(const Value: System.UITypes.TScrollStyle);
    procedure SetStyle(const Value: TScrollBarsStyle);
    procedure SetVertical(const Value: TSynEditScrollBar);
  public
    procedure AfterConstruction; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ScrollBars : System.UITypes.TScrollStyle read FScrollBars write SetScrollBars default ssBoth;
    property Style : TScrollBarsStyle read FStyle write SetStyle default sbsRegular;
    property Horizontal : TSynEditScrollBar read FHorizontal write SetHorizontal;
    property Vertical : TSynEditScrollBar read FVertical write SetVertical;
    property HintColor: TColor read fHintColor write fHintColor default clInfoBk;
    property HintFormat: TScrollHintFormat read fHintFormat write fHintFormat default shfTopLineOnly;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynBackgroundRepeatMode=(brmNone, brmVert, brmHori, brmAll);

  TSynEditBackground = class(TPersistent)
  private
    FBackground: TBitmap;
    FVisible: Boolean;
    FRepeatMode: TSynBackgroundRepeatMode;
    fOnChange: TNotifyEvent;
    procedure doChange;
    procedure SetBackground(const Value: TBitmap);
    procedure SetRepeatMode(const Value: TSynBackgroundRepeatMode);
    procedure SetVisible(const Value: Boolean);
  public
    procedure AfterConstruction; override;
    destructor Destroy;override;
    procedure Draw(Canvas : TCanvas; AbsRect, DestRect : TRect; Back: TColor);
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  published
    property Visible : Boolean read FVisible write SetVisible;
    property RepeatMode : TSynBackgroundRepeatMode read FRepeatMode write SetRepeatMode;
    property Background : TBitmap read FBackground write SetBackground;
  end;

{$IFNDEF SYN_CLX}
  {$IFNDEF SYN_COMPILER_4_UP}
  TBetterRegistry = class(TRegistry)
    function OpenKeyReadOnly(const Key: string): Boolean;
  end;
  {$ELSE}
  TBetterRegistry = TRegistry;
  {$ENDIF}
{$ENDIF}


  TSynEditMark = class
  protected
    fOnChange: TNotifyEvent;
    fLine, fChar, fImage: Integer;
    fVisible: boolean;
    fInternalImage: boolean;
    fBookmarkNum: integer;
    procedure SetChar(const Value: Integer); virtual;
    procedure SetImage(const Value: Integer); virtual;
    procedure SetLine(const Value: Integer); virtual;
    procedure SetVisible(const Value: boolean);
    procedure SetInternalImage(const Value: boolean);
    function GetIsBookmark: boolean;
  public
    constructor Create();
    property Line: integer read fLine write SetLine;
    property Char: integer read fChar write SetChar;
    property ImageIndex: integer read fImage write SetImage;
    property BookmarkNumber: integer read fBookmarkNum write fBookmarkNum;
    property Visible: boolean read fVisible write SetVisible;
    property InternalImage: boolean read fInternalImage write SetInternalImage;
    property IsBookmark: boolean read GetIsBookmark;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TSynEditLineMarks = array[0..16] of TSynEditMark;

  { A list of mark objects. Each object cause a litle picture to be drawn in the
    gutter. }

  { TSynEditMarkList }

  (*TSynEditMarkList = class(TObject)
  private
    fItems: TList;
    fOnChange: TNotifyEvent;
    procedure DoChange;
    function GetItem(Index: Integer): TSynEditMark;
    function GetCount: Integer;
    procedure InternalDelete(Index: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Item: TSynEditMark): Integer;
    function Remove(Item: TSynEditMark): Integer;
    procedure ClearLine(line: integer);
    procedure Clear;
    procedure GetMarksForLine(line: integer; out Marks: TSynEditLineMarks);
  public
    property Items[Index: Integer]: TSynEditMark read GetItem; default;
    property Count: Integer read GetCount;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;*)

implementation

uses
{$IFDEF SYN_CLX}
  QSynEditMiscProcs;
{$ELSE}
  SynEditMiscProcs;
{$ENDIF}

{ TSynSelectedColor }

constructor TSynSelectedColor.Create;
begin
  inherited Create;
  fBG := clHighLight;
  fFG := clHighLightText;
end;

procedure TSynSelectedColor.Assign(Source: TPersistent);
var
  Src: TSynSelectedColor;
begin
  if (Source <> nil) and (Source is TSynSelectedColor) then begin
    Src := TSynSelectedColor(Source);
    fBG := Src.fBG;
    fFG := Src.fFG;
    if Assigned(fOnChange) then fOnChange(Self);
  end else
    inherited Assign(Source);
end;

procedure TSynSelectedColor.SetBG(Value: TColor);
begin
  if (fBG <> Value) then begin
    fBG := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynSelectedColor.SetFG(Value: TColor);
begin
  if (fFG <> Value) then begin
    fFG := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

{ TSynGutter }

constructor TSynGutter.Create;
begin
  inherited Create;
  FIntens := False;

  fFont := TFont.Create;
  fFont.Name := 'Courier New';
  fFont.Size := 8;
  fFont.Style := [];
  fUseFontStyle := True;
  fFont.OnChange := OnFontChange;

  fColor := clBtnFace;
  fVisible := TRUE;
  fWidth := 30;
  FBookmarkPanelWidth := 20;
  FShowBookmarkPanel := True;
  fDigitCount := 4;
  fAutoSizeDigitCount := fDigitCount;
  fRightOffset := 2;
  fBorderStyle := gbsNone;
  fBorderColor := clWindow;
  fShowLineNumbers := False;
  fLineNumberStart := 1;
  fZeroStart := False;
  fGradient := False;
  fGradientStartColor := clWindow;
  fGradientEndColor := clBtnFace;
  fGradientSteps := 48;

  FBookmarkPanelColor := clNone;
  fRightOffsetColor := clNone;

  fShowLineModified := False;
  fLineModifiedColor := clYellow;
  fLineNormalColor := clLime;
end;

destructor TSynGutter.Destroy;
begin
  fFont.Free;
  inherited Destroy;
end;

procedure TSynGutter.Assign(Source: TPersistent);
var
  Src: TSynGutter;
begin
  if Assigned(Source) and (Source is TSynGutter) then begin
    Src := TSynGutter(Source);
    fFont.Assign(src.Font);
    fUseFontStyle := src.fUseFontStyle;
    FIntens := src.FIntens;
    fColor := Src.fColor;
    fVisible := Src.fVisible;
    fWidth := Src.fWidth;
    fShowLineNumbers := Src.fShowLineNumbers;
    fLeadingZeros := Src.fLeadingZeros;
    fZeroStart := Src.fZeroStart;
    FBookmarkPanelWidth := Src.FBookmarkPanelWidth;
    fDigitCount := Src.fDigitCount;
    fRightOffset := Src.fRightOffset;
    fAutoSize := Src.fAutoSize;
    fAutoSizeDigitCount := Src.fAutoSizeDigitCount;
    fLineNumberStart := Src.fLineNumberStart;
    fBorderColor := Src.fBorderColor;
    fBorderStyle := Src.fBorderStyle;
    fGradient := Src.fGradient;
    fGradientStartColor := Src.fGradientStartColor;
    fGradientEndColor := Src.fGradientEndColor;
    fGradientSteps := Src.fGradientSteps;
    fLineModifiedColor := Src.fLineModifiedColor;
    fLineNormalColor := Src.fLineNormalColor;
    fShowLineModified := Src.fShowLineModified;
    if Assigned(fOnChange) then fOnChange(Self);
  end else
    inherited;
end;

procedure TSynGutter.AutoSizeDigitCount(LinesCount: integer);
var
  nDigits: integer;
begin
  if fVisible and fAutoSize and fShowLineNumbers then
  begin
    if fZeroStart then
      Dec(LinesCount)
    else if fLineNumberStart > 1 then
      Inc(LinesCount, fLineNumberStart - 1);

    nDigits := Max(Length(IntToStr(LinesCount)), fDigitCount);
    if fAutoSizeDigitCount <> nDigits then begin
      fAutoSizeDigitCount := nDigits;
      if Assigned(fOnChange) then fOnChange(Self);
    end;
  end else
    fAutoSizeDigitCount := fDigitCount;
end;

function TSynGutter.FormatLineNumber(Line: integer): string;
var
  i: integer;
begin
  if fZeroStart then
    Dec(Line)
  else if fLineNumberStart > 1 then
    Inc(Line, fLineNumberStart - 1);
  Result := Format('%*d', [fAutoSizeDigitCount, Line]);
  if fLeadingZeros then
    for i := 1 to fAutoSizeDigitCount - 1 do begin
      if (Result[i] <> ' ') then break;
      Result[i] := '0';
    end;
end;

function TSynGutter.RealGutterWidth(CharWidth: integer): integer;
var
  PanelWidth: Integer;
begin
  PanelWidth := FBookmarkPanelWidth;
  if not ShowBookmarkPanel and not ShowBookmarks then
    PanelWidth := 0;

  if not fVisible then
    Result := 0
  else
  if fShowLineNumbers then
    Result := PanelWidth + fRightOffset + fAutoSizeDigitCount * CharWidth + 4
  else
    Result := fWidth;
end;

procedure TSynGutter.SetAutoSize(const Value: boolean);
begin
  if fAutoSize <> Value then begin
    fAutoSize := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetColor(const Value: TColor);
begin
  if fColor <> Value then begin
    fColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetFont(Value: TFont);
begin
  fFont.Assign(Value);
end;

procedure TSynGutter.OnFontChange(Sender: TObject);
begin
  if Assigned(fOnChange) then fOnChange(Self);
end;

procedure TSynGutter.SetDigitCount(Value: integer);
begin
  Value := MinMax(Value, 2, 12);
  if fDigitCount <> Value then begin
    fDigitCount := Value;
    fAutoSizeDigitCount := fDigitCount;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetLeadingZeros(const Value: boolean);
begin
  if fLeadingZeros <> Value then begin
    fLeadingZeros := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetBookmarkPanelWidth(Value: integer);
begin
  Value := Max(0, Value);
  if FBookmarkPanelWidth <> Value then
  begin
    FBookmarkPanelWidth := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TSynGutter.SetBookmarkPanelColor(const Value: TColor);
begin
  if Value <> FBookmarkPanelColor then
  begin
    FBookmarkPanelColor := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

procedure TSynGutter.SetRightOffset(Value: integer);
begin
  Value := Max(0, Value);
  if fRightOffset <> Value then begin
    fRightOffset := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetRightOffsetColor(const Value: TColor);
begin
  if Value <> fRightOffsetColor then
  begin
    fRightOffsetColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetShowLineNumbers(const Value: boolean);
begin
  if fShowLineNumbers <> Value then begin
    fShowLineNumbers := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetShowLineNumbersAfterLastLine(const Value: boolean);
begin
  if FShowLineNumbersAfterLastLine <> Value then
  begin
    FShowLineNumbersAfterLastLine := Value;
    if Assigned(fOnChange) then
      fOnChange(Self);
  end;
end;

procedure TSynGutter.SetShowBookmarks(const Value: boolean);
begin
  if FShowBookmarks <> Value then
  begin
    FShowBookmarks := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetShowBookmarkPanel(const Value: boolean);
begin
  if FShowBookmarkPanel <> Value then
  begin
    FShowBookmarkPanel := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetUseFontStyle(Value: boolean);
begin
  if fUseFontStyle <> Value then begin
    fUseFontStyle := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetVisible(Value: boolean);
begin
  if fVisible <> Value then begin
    fVisible := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetWidth(Value: integer);
begin
  Value := Max(0, Value);
  if fWidth <> Value then
  begin
    fWidth := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

function TSynGutter.GetWidth: Integer;
begin
  if FVisible then
    Result := FWidth
  else
    Result := 0;
end;

procedure TSynGutter.SetZeroStart(const Value: boolean);
begin
  if fZeroStart <> Value then begin
    fZeroStart := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetBorderStyle(const Value: TSynGutterBorderStyle);
begin
  fBorderStyle := Value;
  if Assigned(fOnChange) then fOnChange(Self);
end;

procedure TSynGutter.SetLineNumberStart(const Value: Integer);
begin
  if Value <> fLineNumberStart then
  begin
    fLineNumberStart := Value;
    if fLineNumberStart < 0 then
      fLineNumberStart := 0;
    if fLineNumberStart = 0 then
      fZeroStart := True
    else
      fZeroStart := False;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetBorderColor(const Value: TColor);
begin
  if fBorderColor <> Value then
  begin
    fBorderColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetGradient(const Value: Boolean);
begin
  if Value <> fGradient then
  begin
    fGradient := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetGradientEndColor(const Value: TColor);
begin
  if Value <> fGradientEndColor then
  begin
    fGradientEndColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetGradientStartColor(const Value: TColor);
begin
  if Value <> fGradientStartColor then
  begin
    fGradientStartColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetGradientSteps(const Value: Integer);
begin
  if Value <> fGradientSteps then
  begin
    fGradientSteps := Value;
    if fGradientSteps < 2 then
      fGradientSteps := 2;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.SetIntens(const Value: boolean);
begin
  if FIntens <> Value then begin
    FIntens := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.setLineModifiedColor(const Value: TColor);
begin
  if fLineModifiedColor <> Value then begin
    fLineModifiedColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.setLineNormalColor(const Value: TColor);
begin
  if fLineNormalColor <> Value then begin
    fLineNormalColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGutter.setShowLineModified(const Value: Boolean);
begin
  if fShowLineModified <> Value then begin
    fShowLineModified := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

{ TSynBookMarkOpt }

constructor TSynBookMarkOpt.Create(AOwner: TComponent);
begin
  inherited Create;
  fDrawBookmarksFirst := TRUE;
  fEnableKeys := True;
  fGlyphsVisible := True;
  fLeftMargin := 2;
  fOwner := AOwner;
  fXOffset := 12;
end;

procedure TSynBookMarkOpt.Assign(Source: TPersistent);
var
  Src: TSynBookMarkOpt;
begin
  if (Source <> nil) and (Source is TSynBookMarkOpt) then begin
    Src := TSynBookMarkOpt(Source);
    fBookmarkImages := Src.fBookmarkImages;
    fDrawBookmarksFirst := Src.fDrawBookmarksFirst;
    fEnableKeys := Src.fEnableKeys;
    fGlyphsVisible := Src.fGlyphsVisible;
    fLeftMargin := Src.fLeftMargin;
    fXoffset := Src.fXoffset;
    if Assigned(fOnChange) then fOnChange(Self);
  end else
    inherited Assign(Source);
end;

procedure TSynBookMarkOpt.SetBookmarkImages(const Value: TImageList);
begin
  if fBookmarkImages <> Value then begin
    fBookmarkImages := Value;
    if Assigned(fBookmarkImages) then fBookmarkImages.FreeNotification(fOwner);
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynBookMarkOpt.SetDrawBookmarksFirst(Value: boolean);
begin
  if Value <> fDrawBookmarksFirst then begin
    fDrawBookmarksFirst := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynBookMarkOpt.SetGlyphsVisible(Value: Boolean);
begin
  if fGlyphsVisible <> Value then begin
    fGlyphsVisible := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynBookMarkOpt.SetLeftMargin(Value: Integer);
begin
  if fLeftMargin <> Value then begin
    fLeftMargin := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynBookMarkOpt.SetXOffset(Value: integer);
begin
  if fXOffset <> Value then begin
    fXOffset := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

{ TSynGlyph }

constructor TSynGlyph.Create(aModule: THandle; const aName: string; aMaskColor: TColor);
begin
  inherited Create;

  if aName <> '' then
  begin
    fInternalGlyph := TBitmap.Create;
    fInternalGlyph.LoadFromResourceName(aModule, aName);
    fInternalMaskColor := aMaskColor;
  end
  else
    fInternalMaskColor := clNone;

  fVisible := True;
  fGlyph := TBitmap.Create;
  fGlyph.OnChange := GlyphChange;
  fMaskColor := clNone;
end;

destructor TSynGlyph.Destroy;
begin
  if Assigned(fInternalGlyph) then
    FreeAndNil(fInternalGlyph);

  fGlyph.Free;

  inherited Destroy;
end;

procedure TSynGlyph.Assign(aSource: TPersistent);
var
  vSrc : TSynGlyph;
begin
  if Assigned(aSource) and (aSource is TSynGlyph) then
  begin
    vSrc := TSynGlyph(aSource);
    If vSrc.fInternalGlyph <> nil then
      fInternalGlyph.Assign(vSrc.fInternalGlyph);
    fInternalMaskColor := vSrc.fInternalMaskColor;
    fVisible := vSrc.fVisible;
    fGlyph.Assign(vSrc.fGlyph);
    fMaskColor := vSrc.fMaskColor;
    if Assigned(fOnChange) then fOnChange(Self);
  end
  else
    inherited;
end;

procedure TSynGlyph.Draw(aCanvas: TCanvas; aX, aY, aLineHeight: integer);
var
  rcSrc, rcDest : TRect;
  vGlyph : TBitmap;
  vMaskColor : TColor;
begin
  if not fGlyph.Empty then
  begin
    vGlyph := fGlyph;
    vMaskColor := fMaskColor;
  end
  else if Assigned(fInternalGlyph) then
  begin
    vGlyph := fInternalGlyph;
    vMaskColor := fInternalMaskColor;
  end
  else
    Exit;

  if aLineHeight >= vGlyph.Height then
  begin
    rcSrc := Rect(0, 0, vGlyph.Width, vGlyph.Height);
    Inc(aY, (aLineHeight - vGlyph.Height) div 2);
    rcDest := Rect(aX, aY, aX + vGlyph.Width, aY + vGlyph.Height);
  end
  else
  begin
    rcDest := Rect(aX, aY, aX + vGlyph.Width, aY + aLineHeight);
    aY := (vGlyph.Height - aLineHeight) div 2;
    rcSrc := Rect(0, aY, vGlyph.Width, aY + aLineHeight);
  end;

  aCanvas.BrushCopy(rcDest, vGlyph, rcSrc, vMaskColor);
end;

procedure TSynGlyph.SetGlyph(Value: TBitmap);
begin
  fGlyph.Assign(Value);
end;

procedure TSynGlyph.GlyphChange(Sender: TObject);
begin
  if Assigned(fOnChange) then fOnChange(Self);
end;

procedure TSynGlyph.SetMaskColor(Value: TColor);
begin
  if fMaskColor <> Value then
  begin
    fMaskColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TSynGlyph.SetVisible(Value: boolean);
begin
  if fVisible <> Value then
  begin
    fVisible := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

function TSynGlyph.GetWidth : integer;
begin
  if not fGlyph.Empty then
    Result := fGlyph.Width
  else
  if Assigned(fInternalGlyph) then
    Result := fInternalGlyph.Width
  else
    Result := 0;
end;

function TSynGlyph.GetHeight : integer;
begin
  if not fGlyph.Empty then
    Result := fGlyph.Height
  else
  if Assigned(fInternalGlyph) then
    Result := fInternalGlyph.Height
  else
    Result := 0;
end;

{ TSynMethodChain }

procedure TSynMethodChain.Add(AEvent: TMethod);
begin
  if not Assigned(@AEvent) then
    raise ESynMethodChain.CreateFmt(
      '%s.Entry : the parameter `AEvent'' must be specified.', [ClassName]);

  with FNotifyProcs, AEvent do
  begin
    Add(Code);
    Add(Data);
  end
end;

constructor TSynMethodChain.Create;
begin
  inherited;
  FNotifyProcs := TList.Create;
end;

destructor TSynMethodChain.Destroy;
begin
  FNotifyProcs.Free;
  inherited;
end;

function TSynMethodChain.DoHandleException(E: Exception): Boolean;
begin
  if not Assigned(FExceptionHandler) then
    raise E
  else
    try
      Result := True;
      FExceptionHandler(Self, E, Result);
    except
      raise ESynMethodChain.CreateFmt(
        '%s.DoHandleException : MUST NOT occur any kind of exception in '+
        'ExceptionHandler', [ClassName]);
    end;
end;

procedure TSynMethodChain.Fire;
var
  AMethod: TMethod;
  i: Integer;
begin
  i := 0;
  with FNotifyProcs, AMethod do
    while i < Count do
      try
        repeat
          Code := Items[i];
          Inc(i);
          Data := Items[i];
          Inc(i);

          DoFire(AMethod)
        until i >= Count;
      except
        on E: Exception do
          if not DoHandleException(E) then
            i := MaxInt;
      end;
end;

procedure TSynMethodChain.Remove(AEvent: TMethod);
var
  i: Integer;
begin
  if not Assigned(@AEvent) then
    raise ESynMethodChain.CreateFmt(
      '%s.Remove: the parameter `AEvent'' must be specified.', [ClassName]);

  with FNotifyProcs, AEvent do
  begin
    i := Count - 1;
    while i > 0 do
      if Items[i] <> Data then
        Dec(i, 2)
      else
      begin
        Dec(i);
        if Items[i] = Code then
        begin
          Delete(i);
          Delete(i);
        end;
        Dec(i);
      end;
  end;
end;

{ TSynNotifyEventChain }

procedure TSynNotifyEventChain.Add(AEvent: TNotifyEvent);
begin
  inherited Add(TMethod(AEvent));
end;

constructor TSynNotifyEventChain.CreateEx(ASender: TObject);
begin
  inherited Create;
  FSender := ASender;
end;

procedure TSynNotifyEventChain.DoFire(const AEvent: TMethod);
begin
  TNotifyEvent(AEvent)(FSender);
end;

procedure TSynNotifyEventChain.Remove(AEvent: TNotifyEvent);
begin
  inherited Remove(TMethod(AEvent));
end;

{ TSynInternalImage }

type
  TInternalResource = class (TObject)
    public
      UsageCount : Integer;
      Name       : string;
      Bitmap     : TBitmap;
  end;

var
  InternalResources: TList;

constructor TSynInternalImage.Create(aModule: THandle; const Name: string; Count: integer);
begin
  inherited Create;
  fImages := CreateBitmapFromInternalList( aModule, Name );
  fWidth := (fImages.Width + Count shr 1) div Count;
  fHeight := fImages.Height;
  fCount := Count;
  end;

destructor TSynInternalImage.Destroy;
begin
  FreeBitmapFromInternalList;
  inherited Destroy;
end;

function TSynInternalImage.CreateBitmapFromInternalList(aModule: THandle;
  const Name: string): TBitmap;
var
  idx: Integer;
  newIntRes: TInternalResource;
begin
  { There is no list until now }
  if (InternalResources = nil) then
    InternalResources := TList.Create;

  { Search the list for the needed resource }
  for idx := 0 to InternalResources.Count - 1 do
    if (TInternalResource (InternalResources[idx]).Name = UpperCase (Name)) then
      with TInternalResource (InternalResources[idx]) do begin
        UsageCount := UsageCount + 1;
        Result := Bitmap;
        exit;
      end;

  { There is no loaded resource in the list so let's create a new one }
  Result := TBitmap.Create;
  Result.LoadFromResourceName( aModule, Name );

  { Add the new resource to our list }
  newIntRes:= TInternalResource.Create;
  newIntRes.UsageCount := 1;
  newIntRes.Name := UpperCase (Name);
  newIntRes.Bitmap := Result;
  InternalResources.Add (newIntRes);
end;

procedure TSynInternalImage.FreeBitmapFromInternalList;
var
  idx: Integer;
  intRes: TInternalResource;
  function FindImageInList: Integer;
  begin
    for Result := 0 to InternalResources.Count - 1 do
      if (TInternalResource (InternalResources[Result]).Bitmap = fImages) then
        exit;
    Result := -1;
  end;
begin
  { Search the index of our resource in the list }
  idx := FindImageInList;

  { Ey, what's this ???? }
  if (idx = -1) then
    exit;

  { Decrement the usagecount in the object. If there are no more users
    remove the object from the list and free it }
  intRes := TInternalResource (InternalResources[idx]);
  with intRes do begin
    UsageCount := UsageCount - 1;
    if (UsageCount = 0) then begin
      Bitmap.Free;
      InternalResources.Delete (idx);
      intRes.Free;
    end;
  end;

  { If there are no more entries in the list free it }
  if (InternalResources.Count = 0) then begin
    InternalResources.Free;
    InternalResources := nil;
  end;
end;

procedure TSynInternalImage.Draw(ACanvas: TCanvas;
  Number, X, Y, LineHeight: integer);
var
  rcSrc, rcDest: TRect;
begin
  if (Number >= 0) and (Number < fCount) then
  begin
    if LineHeight >= fHeight then begin
      rcSrc := Rect(Number * fWidth, 0, (Number + 1) * fWidth, fHeight);
      Inc(Y, (LineHeight - fHeight) div 2);
      rcDest := Rect(X, Y, X + fWidth, Y + fHeight);
    end else begin
      rcDest := Rect(X, Y, X + fWidth, Y + LineHeight);
      Y := (fHeight - LineHeight) div 2;
      rcSrc := Rect(Number * fWidth, Y, (Number + 1) * fWidth,
        Y + LineHeight);
    end;
    ACanvas.CopyRect(rcDest, fImages.Canvas, rcSrc);
  end;
end;

procedure TSynInternalImage.DrawTransparent(ACanvas: TCanvas; Number, X, Y,
  LineHeight: integer; TransparentColor: TColor);
var
  rcSrc, rcDest: TRect;
begin
  if (Number >= 0) and (Number < fCount) then
  begin
    if LineHeight >= fHeight then begin
      rcSrc := Rect(Number * fWidth, 0, (Number + 1) * fWidth, fHeight);
      Inc(Y, (LineHeight - fHeight) div 2);
      rcDest := Rect(X, Y, X + fWidth, Y + fHeight);
    end else begin
      rcDest := Rect(X, Y, X + fWidth, Y + LineHeight);
      Y := (fHeight - LineHeight) div 2;
      rcSrc := Rect(Number * fWidth, Y, (Number + 1) * fWidth,
        Y + LineHeight);
    end;
{$IFDEF SYN_CLX}
    ACanvas.CopyMode := cmMergeCopy;
    ACanvas.CopyRect(rcDest, fImages.Canvas, rcSrc);
{$ELSE}
    ACanvas.BrushCopy(rcDest, fImages, rcSrc, TransparentColor);
{$ENDIF}
  end;
end;

{ TSynHotKey }

function KeySameAsShiftState(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := (Key = SYNEDIT_SHIFT) and (ssShift in Shift) or
            (Key = SYNEDIT_CONTROL) and (ssCtrl in Shift) or
            (Key = SYNEDIT_MENU) and (ssAlt in Shift);
end;

function ModifiersToShiftState(Modifiers: THKModifiers): TShiftState;
begin
  Result := [];
  if hkShift in Modifiers then Include(Result, ssShift);
  if hkCtrl in Modifiers then Include(Result, ssCtrl);
  if hkAlt in Modifiers then Include(Result, ssAlt);
end;

function ShiftStateToTHKInvalidKey(Shift: TShiftState): THKInvalidKey;
begin
  Shift := Shift * [ssShift, ssAlt, ssCtrl];
  if Shift = [ssShift] then
    Result := hcShift
  else if Shift = [ssCtrl] then
    Result := hcCtrl
  else if Shift = [ssAlt] then
    Result := hcAlt
  else if Shift = [ssShift, ssCtrl] then
    Result := hcShiftCtrl
  else if Shift = [ssShift, ssAlt] then
    Result := hcShiftAlt
  else if Shift = [ssCtrl, ssAlt] then
    Result := hcCtrlAlt
  else if Shift = [ssShift, ssCtrl, ssAlt] then
    Result := hcShiftCtrlAlt
  else
    Result := hcNone;
end;

function ShortCutToTextEx(Key: Word; Shift: TShiftState): WideString;
begin
  if ssCtrl in Shift then Result := SmkcCtrl;
  if ssShift in Shift then Result := Result + SmkcShift;
  if ssAlt in Shift then Result := Result + SmkcAlt;

  {$IFDEF SYN_CLX}
  if Lo(Key) > Ord('Z') then
    Result := Result + Chr(Key)
  else
  {$ENDIF}
    Result := Result + ShortCutToText(TShortCut(Key));
  if Result = '' then
    Result := srNone;
end;

constructor TSynHotKey.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF SYN_CLX}
  InputKeys := [ikAll];
  {$ENDIF}

  BorderStyle := bsSingle;
  {$IFNDEF SYN_CLX}
  {$IFDEF SYN_COMPILER_7_UP}
  ControlStyle := ControlStyle + [csNeedsBorderPaint];
  {$ENDIF}
  {$ENDIF}

  FInvalidKeys := [hcNone, hcShift];
  FModifiers := [hkAlt];
  SetHotKey($0041); { Alt+A }

  ParentColor := False;
  Color := clWindow;
  TabStop := True;
end;

{$IFNDEF SYN_CLX}
procedure TSynHotKey.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TSynBorderStyle] of DWORD = (0, WS_BORDER);
  ClassStylesOff = CS_VREDRAW or CS_HREDRAW;
begin
  inherited CreateParams(Params);
  with Params do
  begin
    WindowClass.Style := WindowClass.Style and not ClassStylesOff;
    Style := Style or BorderStyles[fBorderStyle] or WS_CLIPCHILDREN;

    if NewStyleControls and Ctl3D and (fBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;
{$ENDIF}

procedure TSynHotKey.DoExit;
begin
  inherited;
  if FPressedOnlyModifiers then
  begin
    Text := srNone;
    Invalidate;
  end;
end;

{$IFDEF SYN_CLX}
function TSynHotKey.EventFilter(Sender: QObjectH; Event: QEventH): Boolean;
begin
  Result := inherited EventFilter(Sender, Event);
  case QEvent_type(Event) of
    QEventType_FocusIn:
      begin
        Canvas.Font := Font;
        CreateCaret(Self, 0, 1, Canvas.TextHeight('x') + 2);
        SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
        ShowCaret(Self);
      end;
    QEventType_FocusOut:
      begin
        DestroyCaret;
      end;
  end;
end;
{$ENDIF}

procedure TSynHotKey.KeyDown(var Key: Word; Shift: TShiftState);
var
  MaybeInvalidKey: THKInvalidKey;
  SavedKey: Word;
  {$IFDEF LINUX}
  Code: Byte;
  {$ENDIF}
begin
  {$IFDEF LINUX}
  // uniform Keycode: key has the same value wether Shift is pressed or not
  if Key <= 255 then
  begin
    Code := XKeysymToKeycode(Xlib.PDisplay(QtDisplay), Key);
    Key := XKeycodeToKeysym(Xlib.PDisplay(QtDisplay), Code, 0);
    if Char(Key) in ['a'..'z'] then Key := Ord(UpCase(Char(Key)));
  end;
  {$ENDIF}

  SavedKey := Key;
  FPressedOnlyModifiers := KeySameAsShiftState(Key, Shift);

  MaybeInvalidKey := ShiftStateToTHKInvalidKey(Shift);
  if MaybeInvalidKey in FInvalidKeys then
    Shift := ModifiersToShiftState(FModifiers);

  if not FPressedOnlyModifiers then
  begin
    {$IFDEF SYN_CLX}
    if Lo(Key) > Ord('Z') then
      Key := Lo(Key);
    {$ENDIF}
    FHotKey := ShortCut(Key, Shift)
  end
  else
  begin
    FHotKey := 0;
    Key := 0;
  end;

  if Text <> ShortCutToTextEx(Key, Shift) then
  begin
    Text := ShortCutToTextEx(Key, Shift);
    Invalidate;
    SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
  end;

  Key := SavedKey;
end;

procedure TSynHotKey.KeyUp(var Key: Word; Shift: TShiftState);
{$IFDEF LINUX}
var
  Code: Byte;
{$ENDIF}
begin
  {$IFDEF LINUX}
  // uniform Keycode: key has the same value wether Shift is pressed or not
  if Key <= 255 then
  begin
    Code := XKeysymToKeycode(Xlib.PDisplay(QtDisplay), Key);
    Key := XKeycodeToKeysym(Xlib.PDisplay(QtDisplay), Code, 0);
    if Char(Key) in ['a'..'z'] then Key := Ord(UpCase(Char(Key)));
  end;
  {$ENDIF}

  if FPressedOnlyModifiers then
  begin
    Text := srNone;
    Invalidate;
    SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
  end;
end;

procedure TSynHotKey.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  SetFocus;
end;

procedure TSynHotKey.Paint;
var
  r: TRect;
begin
  r := ClientRect;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  InflateRect(r, -BorderWidth, -BorderWidth);
  Canvas.FillRect(r);
  Canvas.TextRect(r, BorderWidth + 1, BorderWidth + 1, Text);
end;

procedure TSynHotKey.SetBorderStyle(const Value: TSynBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
{$IFDEF SYN_CLX}
    Resize;
    Invalidate;
{$ELSE}
    RecreateWnd;
{$ENDIF}
  end;
end;

procedure TSynHotKey.SetHotKey(const Value: TShortCut);
var
  Key: Word;
  Shift: TShiftState;
  MaybeInvalidKey: THKInvalidKey;
begin
  ShortCutToKey(Value, Key, Shift);

  MaybeInvalidKey := ShiftStateToTHKInvalidKey(Shift);
  if MaybeInvalidKey in FInvalidKeys then
    Shift := ModifiersToShiftState(FModifiers);

  FHotKey := ShortCut(Key, Shift);
  Text := ShortCutToTextEx(Key, Shift);
  Invalidate;
  if not Visible then
    SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
end;

procedure TSynHotKey.SetInvalidKeys(const Value: THKInvalidKeys);
begin
  FInvalidKeys := Value;
  SetHotKey(FHotKey);
end;

procedure TSynHotKey.SetModifiers(const Value: THKModifiers);
begin
  FModifiers := Value;
  SetHotKey(FHotKey);
end;

{$IFDEF SYN_CLX}
function TSynHotKey.WidgetFlags: Integer;
begin
  Result := inherited WidgetFlags or Integer(WidgetFlags_WRepaintNoErase);
end;
{$ENDIF}

{$IFNDEF SYN_CLX}
procedure TSynHotKey.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTTAB or DLGC_WANTARROWS;
end;

procedure TSynHotKey.WMKillFocus(var Msg: TWMKillFocus);
begin
  DestroyCaret;
end;

procedure TSynHotKey.WMSetFocus(var Msg: TWMSetFocus);
begin
  Canvas.Font := Font;
  CreateCaret(Handle, 0, 1, -Canvas.Font.Height + 2);
  SetCaretPos(BorderWidth + 1 + Canvas.TextWidth(Text), BorderWidth + 1);
  ShowCaret(Handle);
end;
{$ENDIF}

{ TSynRightEdge }

procedure TSynRightEdge.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TSynRightEdge) then
    with Source as TSynRightEdge do
    begin
      self.FVisible := FVisible;
      self.FPosition := FPosition;
      self.FColor := FColor;
      self.FStyle := FStyle;
      self.MouseMove := FMouseMove;
      self.DoChange;
    end
  else
    inherited Assign(Source);
end;

constructor TSynRightEdge.Create;
begin
  FVisible:= true;
  FPosition:= 80;
  FColor:= clSilver;
  FStyle:= psSolid;
  FMouseMove := False;
end;

procedure TSynRightEdge.DoChange;
begin
  IF Assigned(FOnChange) then FOnChange(self);
end;

procedure TSynRightEdge.SetColor(const Value: TColor);
begin
  if FColor <> value then
  begin
    FColor := Value;
    Dochange
  end;
end;

procedure TSynRightEdge.SetMouseMove(const Value: Boolean);
begin
  FMouseMove := Value;
end;

procedure TSynRightEdge.SetPosition(const Value: Integer);
begin
  if FPosition <> value then
  begin
    FPosition := Value;
    Dochange
  end;
end;

procedure TSynRightEdge.SetStyle(const Value: TPenStyle);
begin
  if FStyle <> value then
  begin
    FStyle := Value;
    Dochange
  end;
end;

procedure TSynRightEdge.SetVisible(const Value: Boolean);
begin
  if FVisible <> value then
  begin
    FVisible := Value;
    Dochange
  end;
end;


{ TSynActiveLine }

procedure TSynActiveLine.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TSynActiveLine) then
    with Source as TSynActiveLine do
    begin
      self.FBackground := FBackground;
      self.FForeground := FForeground;
      self.FVisible := FVisible;
      self.FIndicator.Assign(FIndicator);
      self.DoChange(self);
    end
  else
    inherited Assign(Source);
end;

constructor TSynActiveLine.Create;
begin
  FVisible := true;
  FBackground := clYellow;
  FForeground := clNavy;
  FIndicator := TSynGlyph.Create(0, '', 0);
  FIndicator.OnChange := DoChange;
end;

destructor TSynActiveLine.Destroy;
begin
  FIndicator.Free;
  inherited;
end;

procedure TSynActiveLine.DoChange(Sender : TObject);
begin
  IF Assigned(FOnChange) then FOnChange(Sender);
end;

procedure TSynActiveLine.SetBackground(const Value: TColor);
begin
  if FBackground <> value then
  begin
    FBackground := Value;
    Dochange(self);
  end;
end;

procedure TSynActiveLine.SetForeground(const Value: TColor);
begin
  if FForeground <> value then
  begin
    FForeground := Value;
    Dochange(self);
  end;
end;

procedure TSynActiveLine.SetIndicator(const Value: TSynGlyph);
begin
  FIndicator.Assign(Value);
end;

procedure TSynActiveLine.SetVisible(const Value: boolean);
begin
  if FVisible <> value then
  begin
    FVisible := Value;
    Dochange(self);
  end;
end;


{ TSynLineDivider }

procedure TSynLineDivider.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TSynLineDivider) then
    with Source as TSynLineDivider do
    begin
      self.FColor := FColor;
      self.FStyle := FStyle;
      self.FVisible := FVisible;
      self.DoChange;
    end
  else
    inherited Assign(Source);
end;

constructor TSynLineDivider.Create;
begin
  FVisible:= false;
  FColor:= clRed;
  FStyle:= psSolid;
end;

procedure TSynLineDivider.DoChange;
begin
  IF Assigned(FOnChange) then FOnChange(self);
end;

procedure TSynLineDivider.SetColor(const Value: TColor);
begin
  if FColor <> value then
  begin
    FColor := Value;
    Dochange
  end;
end;

procedure TSynLineDivider.SetStyle(const Value: TPenStyle);
begin
  if FStyle <> value then
  begin
    FStyle := Value;
    Dochange
  end;
end;

procedure TSynLineDivider.SetVisible(const Value: boolean);
begin
  if FVisible <> value then
  begin
    FVisible := Value;
    Dochange
  end;
end;

{ TSynWordWrap }

procedure TSynWordWrap.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TSynWordWrap) then
    with Source as TSynWordWrap do
    begin
      self.FEnabled := FEnabled;
      self.FPosition := FPosition;
      self.FStyle := FStyle;
      self.FIndicator.Assign(FIndicator);
      self.DoChange(self);
    end
  else
    inherited Assign(Source);
end;

constructor TSynWordWrap.Create;
begin
  FEnabled := false;
  FPosition:= 80;
  FIndicator := TSynGlyph.Create(HINSTANCE, 'SynEditWrapped', clLime);
  FIndicator.OnChange := DoChange;
  FStyle := wwsClientWidth;
end;

destructor TSynWordWrap.Destroy;
begin
  FIndicator.Free;
  inherited;
end;

procedure TSynWordWrap.DoChange(Sender: TObject);
begin
  if Assigned(fOnChange) then fOnChange(Sender);
end;

procedure TSynWordWrap.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> value then
  begin
    FEnabled := Value;
    Dochange(self);
  end;
end;

procedure TSynWordWrap.SetIndicator(const Value: TSynGlyph);
begin
  FIndicator.Assign(Value);
end;

procedure TSynWordWrap.SetPosition(const Value: Integer);
begin
  if FPosition <> value then
  begin
    FPosition := Value;
    Dochange(self);
  end;
end;

procedure TSynWordWrap.SetStyle(const Value: TSynWordWrapStyle);
begin
  if FStyle <> value then
  begin
    FStyle := Value;
    Dochange(self);
  end;
end;

{$IFNDEF SYN_CLX}
  {$IFNDEF SYN_COMPILER_4_UP}

{ TBetterRegistry }

function TBetterRegistry.OpenKeyReadOnly(const Key: string): Boolean;

  function IsRelative(const Value: string): Boolean;
  begin
    Result := not ((Value <> '') and (Value[1] = '\'));
  end;

var
  TempKey: HKey;
  S: string;
  Relative: Boolean;
begin
  S := Key;
  Relative := IsRelative(S);

  if not Relative then Delete(S, 1, 1);
  TempKey := 0;
  Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
      KEY_READ, TempKey) = ERROR_SUCCESS;
  if Result then
  begin
    if (CurrentKey <> 0) and Relative then S := CurrentPath + '\' + S;
    ChangeKey(TempKey, S);
  end;
end; { TBetterRegistry.OpenKeyReadOnly }

  {$ENDIF SYN_COMPILER_4_UP}
{$ENDIF SYN_CLX}

{ TSynEditScrollBar }

procedure TSynEditScrollBar.Assign(Source: TPersistent);
begin
  IF Source is TSynEditScrollBar then
  begin
    with TSynEditScrollBar(Source) do
    begin
      Self.FOnGetScrollInfo := FOnGetScrollInfo;
      Self.FOnSetScrollInfo := FOnSetScrollInfo;
      Self.FOnShowScrollBar := FOnShowScrollBar;
      Self.FOnEnabledScrollBar := FOnEnabledScrollBar;
    end;
  end else inherited;
end;

destructor TSynEditScrollBar.Destroy;
begin
  If FScrollBars <> nil then
  begin
    If FScrollBars.FHorizontal = self then
       FScrollBars.FHorizontal := nil;
    If FScrollBars.FVertical = self then
       FScrollBars.FVertical := nil;
  end;
  inherited;
end;

function TSynEditScrollBar.DoEnabledScrollBar(const sbArrows: Integer): Boolean;
begin
  result := False;
  if Assigned(FOnEnabledScrollBar) then
    result := FOnEnabledScrollBar(sbArrows)
end;

function TSynEditScrollBar.DoGetScrollInfo(
  var ScrollInfo: TScrollInfo): Boolean;
begin
  result := False;
  if Assigned(FOnGetScrollInfo) then
    result := FOnGetScrollInfo(ScrollInfo)
end;

function TSynEditScrollBar.DoSetScrollInfo(const ScrollInfo: TScrollInfo;
  Redraw: Boolean): Integer;
begin
  result := 0;
  if Assigned(FOnSetScrollInfo) then
    result := FOnSetScrollInfo(ScrollInfo, Redraw)
end;

function TSynEditScrollBar.DoShowScrollBar(const sbShow: Boolean): Boolean;
begin
  result := False;
  if Assigned(FOnShowScrollBar) then
    result := FOnShowScrollBar(sbShow)
end;

{ TSynScrollBars }

procedure TSynScrollBars.SetHorizontal(const Value: TSynEditScrollBar);
begin
  FHorizontal := Value;
  if FHorizontal <> nil then
    FHorizontal.FScrollBars := self;
end;

procedure TSynScrollBars.SetScrollBars(const Value: System.UITypes.TScrollStyle);
begin
  if FScrollBars <> Value then
  begin
    FScrollBars := Value;
    doChange;
  end;
end;

procedure TSynScrollBars.SetVertical(const Value: TSynEditScrollBar);
begin
  FVertical := Value;
  if FVertical <> nil then
    FVertical.FScrollBars := self;
end;

procedure TSynScrollBars.SetStyle(const Value: TScrollBarsStyle);
begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    doChange;
  end;
end;

procedure TSynScrollBars.doChange;
begin
  if Assigned(fOnChange) then fOnChange(Self);
end;

procedure TSynScrollBars.Assign(Source: TPersistent);
begin
  IF Source is TSynScrollBars then
  begin
    with TSynScrollBars(Source) do
    begin
      Self.FScrollBars := FScrollBars;
      Self.FStyle := FStyle;
      Self.Horizontal := Horizontal;
      Self.Vertical := FVertical;
      Self.fHintColor := fHintColor;
      Self.fHintFormat := fHintFormat;
      self.doChange;
    end;
  end// else inherited;
end;

procedure TSynScrollBars.AfterConstruction;
begin
  FVertical := nil;
  FHorizontal:= nil;
  FScrollBars := ssBoth;
  FStyle := sbsRegular;
  fHintColor := clInfoBk;
  fHintFormat := shfTopLineOnly;
  inherited;
end;

//### Code Folding ###
{ TSynCodeFolding }

procedure TSynCodeFolding.Assign(Source: TPersistent);
begin
  if Source is TSynCodeFolding then
  begin
    with TSynCodeFolding(Source) do
    begin
      self.fCaseSensitive := fCaseSensitive;
      self.fCollapsedCodeHint := fCollapsedCodeHint;
      self.fCollapsedLineColor := fCollapsedLineColor;
      self.fCollapsingMarkStyle := fCollapsingMarkStyle;
      self.fEnabled := fEnabled;
      self.fFoldRegions.Assign(fFoldRegions);
      self.fFolderBarColor := fFolderBarColor;
      self.fFolderBarLinesColor := fFolderBarLinesColor;
      self.fHighlighterFoldRegions:= fHighlighterFoldRegions;
      self.fHighlightIndentGuides := fHighlightIndentGuides;
      self.fIndentGuides := fIndentGuides;
      self.fShowCollapsedLine := fShowCollapsedLine;
      if Assigned(self.OnChange) then
        self.OnChange(fcRescan);
    end;
  end
  else inherited
end;

constructor TSynCodeFolding.Create;
begin
  fCollapsedCodeHint := True;
  fCollapsedLineColor := clDefault;
  fCollapsingMarkStyle := msSquare;
  fEnabled := False;
  fFolderBarColor := clDefault;
  FolderBarLinesColor := clDefault;
 	fHighlighterFoldRegions := True;
  fHighlightIndentGuides := True;
  fShowCollapsedLine := True;
  fIndentGuides := True;
  fFoldRegions := TFoldRegions.Create(TFoldRegionItem);
end;

destructor TSynCodeFolding.Destroy;
begin
  fFoldRegions.Free;
  inherited;
end;

procedure TSynCodeFolding.SetEnabled(const Value: Boolean);
begin
	fEnabled := Value;

  if Assigned(fOnChange) then fOnChange(fcEnabled);
end;

procedure TSynCodeFolding.SetFolderBarColor(const Value: TColor);
var
	HSLColor: THSLColor;
begin
  if Value = clDefault then
  begin
		HSLColor := RGB2HSL(clBtnFace);
  	Inc(HSLColor.Luminace, 5);
		fFolderBarColor := HSL2RGB(HSLColor);
  end
  else
  	fFolderBarColor := Value;

  if Assigned(fOnChange) then fOnChange(fcRefresh);
end;

procedure TSynCodeFolding.SetFolderBarLinesColor(const Value: TColor);
var
	HSLColor: THSLColor;
begin
	if Value = clDefault then
  begin
  	HSLColor := RGB2HSL(clBtnFace);
  	Dec(HSLColor.Luminace, 20);
  	fFolderBarLinesColor := HSL2RGB(HSLColor);
  end
  else
  	fFolderBarLinesColor := Value;

  if Assigned(fOnChange) then fOnChange(fcRefresh);
end;

procedure TSynCodeFolding.SetCollapsedCodeHint(const Value: Boolean);
begin
	fCollapsedCodeHint := Value;

  if Assigned(fOnChange) then fOnChange(fcRefresh);
end;

procedure TSynCodeFolding.SetCollapsedLineColor(const Value: TColor);
begin
	fCollapsedLineColor := Value;

  if Assigned(fOnChange) then fOnChange(fcRefresh);
end;

procedure TSynCodeFolding.SetCollapsingMarkStyle(const Value: TSynCollapsingMarkStyle);
begin
	fCollapsingMarkStyle := Value;

  if Assigned(fOnChange) then fOnChange(fcRefresh);
end;

procedure TSynCodeFolding.SetHighlighterFoldRegions(const Value: Boolean);
begin
	fHighlighterFoldRegions := Value;

  if Assigned(fOnChange) then fOnChange(fcRescan);
end;

procedure TSynCodeFolding.SetHighlightIndentGuides(const Value: Boolean);
begin
	fHighlightIndentGuides := Value;

  if Assigned(fOnChange) then fOnChange(fcRefresh);
end;

procedure TSynCodeFolding.SetIndentGuides(const Value: Boolean);
begin
	fIndentGuides := Value;

  if Assigned(fOnChange) then fOnChange(fcRefresh);
end;

procedure TSynCodeFolding.SetShowCollapsedLine(const Value: Boolean);
begin
	fShowCollapsedLine := Value;

  if Assigned(fOnChange) then fOnChange(fcRefresh);
end;

procedure TSynCodeFolding.SetCaseSensitive(const Value: Boolean);
begin
	fCaseSensitive := Value;

  if Assigned(fOnChange) then fOnChange(fcRescan);
end;
//### End Code Folding ###

{ TSynEditMark }

function TSynEditMark.GetIsBookmark: boolean;
begin
  Result := (fBookmarkNum >= 0);
end;

procedure TSynEditMark.SetChar(const Value: Integer);
begin
  FChar := Value;
end;

procedure TSynEditMark.SetImage(const Value: Integer);
begin
  FImage := Value;
  if fVisible and Assigned(fOnChange) then
    fOnChange(Self);
//    fEdit.InvalidateGutterLines(fLine, fLine);
end;

procedure TSynEditMark.SetInternalImage(const Value: boolean);
begin
  fInternalImage := Value;
  if fVisible and Assigned(fOnChange) then
    fOnChange(Self);
end;

procedure TSynEditMark.SetLine(const Value: Integer);
begin
  if (fLine <> Value) and fVisible and Assigned(fOnChange) then
  begin
    if fLine > 0 then
      fOnChange(Self);
    fLine := Value;
    if fLine > 0 then
      fOnChange(Self);
  end
  else
    fLine := Value;
end;

procedure TSynEditMark.SetVisible(const Value: boolean);
begin
  if fVisible <> Value then
  begin
    fVisible := Value;
    if Assigned(fOnChange) then
      fOnChange(Self);
  end;
end;

constructor TSynEditMark.Create;
begin
  inherited Create;
  fBookmarkNum := -1;
end;

{ TSynEditMarkList }
(*
function TSynEditMarkList.Add(Item: TSynEditMark): Integer;
begin
  Result := fItems.Add(Item);
  DoChange;
end;

procedure TSynEditMarkList.ClearLine(Line: integer);
var
  i: integer;
  v_Changed: Boolean;
begin
  v_Changed := False;
  for i := fItems.Count -1 downto 0 do
    if not Items[i].IsBookmark and (Items[i].Line = Line) then
    begin
      InternalDelete(i);
      v_Changed := True;
    end;
  if v_Changed then
    DoChange;
end;

constructor TSynEditMarkList.Create;
begin
  inherited Create;
  fItems := TList.Create;
end;

destructor TSynEditMarkList.Destroy;
begin
  Clear;
  fItems.Free;
  inherited Destroy;
end;

procedure TSynEditMarkList.InternalDelete(Index: Integer);
begin
  TObject(fItems[Index]).Free;
  fItems.Delete(Index);
end;

procedure TSynEditMarkList.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TSynEditMarkList.GetItem(Index: Integer): TSynEditMark;
begin
  result := TSynEditMark(fItems[Index]);
end;

procedure TSynEditMarkList.GetMarksForLine(line: integer;
  out marks: TSynEditLineMarks);
//Returns up to maxMarks book/gutter marks for a chosen line.
var
  v_MarkCount: integer;
  i: integer;
begin
  FillChar(marks, SizeOf(marks), 0);
  v_MarkCount := 0;
  for i := 0 to fItems.Count - 1 do
  begin
    if Items[i].Line = line then
    begin
      marks[v_MarkCount] := Items[i];
      Inc(v_MarkCount);
      if v_MarkCount = Length(marks) then
        break;
    end;
  end;
end;

function TSynEditMarkList.GetCount: Integer;
begin
  Result := fItems.Count;
end;

procedure TSynEditMarkList.Clear;
begin
  while fItems.Count <> 0 do
  begin
    InternalDelete(0);
  end;
  DoChange;
end;

function TSynEditMarkList.Remove(Item: TSynEditMark): Integer;
begin
  Result := fItems.IndexOf(Item);
  InternalDelete(Result);
  DoChange;
end;
*)
{ TSynEditBackground }

procedure TSynEditBackground.AfterConstruction;
begin
  inherited;
  FBackground := TBitmap.Create;
end;

procedure TSynEditBackground.Assign(Source: TPersistent);
begin
  IF Source is TSynEditBackground then
  begin
    with TSynScrollBars(Source) do
    begin
      Self.FBackground := FBackground;
      Self.FVisible := FVisible;
      Self.FRepeatMode := FRepeatMode;
      self.doChange;
    end;
  end else inherited;
end;

destructor TSynEditBackground.Destroy;
begin
  inherited;
  FBackground.Free;
end;

procedure TSynEditBackground.doChange;
begin
  if Assigned(FOnChange) then OnChange(Self);
end;

procedure TSynEditBackground.Draw(Canvas: TCanvas; AbsRect, DestRect : TRect;
  Back: TColor);
var
  A : TBitmap;
  R1, R2, R3, R4, R5 : TRect;
begin
  A := TBitmap.Create;
  try

    A.Height := DestRect.Bottom- DestRect.Top;
    A.Width := DestRect.Right - DestRect.Left;
    R1 := DestRect;
    OffsetRect(R1, -DestRect.Left, -DestRect.Top);
    A.Canvas.Brush.Color := Back;
    A.Canvas.Brush.Style := bsSolid;
    A.Canvas.FillRect(R1);

{    R1 := DestRect;
    Canvas.Brush.Color := Back;
    Canvas.Brush.Style := bsSolid;
    Canvas.FillRect(DestRect);}

    case FRepeatMode of
      brmNone : A.Canvas.CopyRect(R1, FBackground.Canvas, AbsRect);
      brmHori:
      begin
        if AbsRect.Left < FBackground.Width then
        begin
          R2 := AbsRect;
          while R2.Top > FBackground.Height do
            OffsetRect(R2, 0, -(FBackground.Height));
          R3 := R1;
          while R3.Top < R1.Bottom do
          begin
            if R2.Bottom > FBackground.Height then
              R2.Bottom := FBackground.Height;
            if (R3.Bottom - R3.Top) < (R2.Bottom-R2.Top) then
              R2.Bottom := R2.Top + R3.Bottom - R3.Top
            else if (R3.Bottom - R3.Top) > (R2.Bottom-R2.Top) then
              R3.Bottom := R3.Top + R2.Bottom-R2.Top;
            A.Canvas.CopyRect(R3, FBackground.Canvas, R2);
            OffsetRect(R3, 0, (R2.Bottom-R2.Top));
            if R3.Bottom > R1.Bottom then R3.Bottom := R1.Bottom;
            if R2.Bottom = FBackground.Height then
              R2.Top := 0
            else R2.Top := R2.Bottom;
            R2.Bottom := FBackground.Height;
          end;
        end;
      end;
      brmVert :
      begin
        if AbsRect.Top < FBackground.Height then
        begin
          R2 := AbsRect;
          while R2.Left > FBackground.Width do
            OffsetRect(R2, -(FBackground.Width), 0);
          R3 := R1;
          while R3.Left < R1.Right do
          begin
            if R2.Right > FBackground.Width then
              R2.Right := FBackground.Width;
            if (R3.Right - R3.Left) < (R2.Right-R2.Left) then
              R2.Right := R2.Left + R3.Right - R3.Left
            else if (R3.Right - R3.Left) > (R2.Right-R2.Left) then
              R3.Right := R3.Left + R2.Right-R2.Left;
            A.Canvas.CopyRect(R3, FBackground.Canvas, R2);
            OffsetRect(R3, (R2.Right-R2.Left), 0);
            if R3.Right > R1.Right then R3.Right := R1.Right;
            if R2.Right = FBackground.Width then
              R2.Left := 0
            else R2.Left := R2.Right;
            R2.Right := FBackground.Width;
          end;
        end;
      end;
      brmAll :
      begin
        R2 := AbsRect;
        while R2.Left > FBackground.Width do
          OffsetRect(R2, -(FBackground.Width), 0);
        while R2.Top > FBackground.Height do
          OffsetRect(R2, 0, -(FBackground.Height));
        R3 := R1;
        while R3.Top < R1.Bottom do
        begin
          if R2.Bottom > FBackground.Height then
            R2.Bottom := FBackground.Height;
          if (R3.Bottom - R3.Top) < (R2.Bottom-R2.Top) then
            R2.Bottom := R2.Top + R3.Bottom - R3.Top
          else if (R3.Bottom - R3.Top) > (R2.Bottom-R2.Top) then
            R3.Bottom := R3.Top + R2.Bottom-R2.Top;
          R5 := R2;
          R4 := R3;
          while R4.Left < R3.Right do
          begin
            if R5.Right > FBackground.Width then
              R5.Right := FBackground.Width;
            if (R4.Right - R4.Left) < (R5.Right-R5.Left) then
              R5.Right := R5.Left + R4.Right - R4.Left
            else if (R4.Right - R4.Left) > (R5.Right-R5.Left) then
              R4.Right := R4.Left + R5.Right-R5.Left;
            A.Canvas.CopyRect(R4, FBackground.Canvas, R5);
            OffsetRect(R4, (R5.Right-R5.Left), 0);
            if R4.Right > R3.Right then R4.Right := R3.Right;
            if R5.Right = FBackground.Width then
              R5.Left := 0
            else R5.Left := R5.Right;
            R5.Right := FBackground.Width;
          end;
          OffsetRect(R3, 0, (R2.Bottom-R2.Top));
          If R3.Bottom > R1.Bottom then R3.Bottom := R1.Bottom;
          if R2.Bottom = FBackground.Height then
            R2.Top := 0
          else R2.Top := R2.Bottom;
          R2.Bottom := FBackground.Height;
        end;
      end;
    end;
    Canvas.CopyRect(DestRect, A.Canvas, R1);
  finally
    A.free;
  end;
end;

procedure TSynEditBackground.SetBackground(const Value: TBitmap);
begin
  if FBackground <> Value then
  begin
  FBackground.Assign(Value);
    doChange;
  end;
end;

procedure TSynEditBackground.SetRepeatMode(const Value: TSynBackgroundRepeatMode);
begin
  if FRepeatMode <> Value then
  begin
  FRepeatMode := Value;
    doChange;
  end;
end;

procedure TSynEditBackground.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
  FVisible := Value;
    doChange;
  end;
end;

{ TSynMinimap }

procedure TSynMinimap.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TSynMinimap.SetWidth(Value: integer);
begin
  Value := Max(0, Value);
  if FWidth <> Value then
  begin
    FWidth := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

function TSynMinimap.GetWidth: Integer;
begin
  if FVisible then
    Result := FWidth
  else
    Result := 0;
end;

procedure TSynMinimap.SetVisible(Value: boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end;
end;

constructor TSynMinimap.Create;
begin
  inherited Create;

  fFont := TFont.Create;
  fFont.Name := 'Courier New';
  fFont.Size := 3;
  fFont.Style := [];

  FVisible := False;
  FWidth := 100;

  FTopLine := 1;
end;

destructor TSynMinimap.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

begin
  InternalResources := nil;
end.


