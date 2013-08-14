(*******************************************************************************
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/    Contributors(alphabetical order):    /
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Dorin Duminica - http://www.delphigeist.com

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Change Log:

  Lasse Rautiainen - http://www.bonecode.com

  - Added BorderStyle and Ctl3D properties
  - Added support for styles

 ~~~~~~~~~~~~~~~~
/    v 1.1     /
~~~~~~~~~~~~~~~

    new:
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -	editor scroll from MiniMap
    -	options class(to be extended)
    -	published a few more properties

    fixes:
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -	fixed flickering on scroll
    -	fixed line number calculation on click

    other:
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -	cleanups

    known issues:
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -	translation of "char" when clicking the map is
      not always correct needs rewrite

 ~~~~~~~~~~~~~~~
/    v 1.0    /
~~~~~~~~~~~~~~

    -	initial release

*******************************************************************************)
unit SynMiniMap;

interface

uses
   Vcl.Forms, System.SysUtils, Winapi.Windows, System.Classes, Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls, Winapi.Messages,
   SynEdit;

const
  SYNMINIMAP_DEFAULT_HEIGHT = 400;
  SYNMINIMAP_DEFAULT_WIDTH = 200;
  SYNMINIMAP_DEFAULT_FONTFACTOR = 3;
  SYNMINIMAP_FONTFACTOR_MIN = 2;
  SYNMINIMAP_FONTFACTOR_MAX = 4;
  SYNMINIMAP_DEFAULT_OPTIONS_TABWIDTH = 4;

type
  TSynMiniMapCanvasHelper = class Helper for TCanvas
  public
    procedure StretchDrawHalftone(const AX, AY, AWidth, AHeight: Integer;
      const ASource: TCanvas;
      const ASrcX, ASrcY, ASrcWidth, ASrcHeight: Integer); overload;
    procedure StretchDrawHalftone(const APoint: TPoint;
      const AWidth, AHeight: Integer; const ASource: TCanvas;
      const ASrcPoint: TPoint; ASrcWidth, ASrcHeight: Integer); overload;
  end;

type
  ///
  ///  don't modify this, it will be extended to pass other information
  ///  in the future without breaking backwards compatibility
  ///
  PSynMiniMapEventData = ^TSynMiniMapEventData;
  TSynMiniMapEventData = record
    Coord: TBufferCoord;
    Redraw: Boolean;
  end;

const
  szSynMiniMapEventData = SizeOf(TSynMiniMapEventData);

type
  TSynEditStyleHook = class(TMemoStyleHook)
  strict private
    procedure UpdateColors;
    procedure WMEraseBkgnd(var Message: TMessage); message WM_ERASEBKGND;
  strict protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;
  // protection against TRect record method that cause problems with with-statements
  TWithSafeRect = record
    case Integer of
      0: (Left, Top, Right, Bottom: Longint);
      1: (TopLeft, BottomRight: TPoint);
  end;
  ///
  ///  colors for mini map
  ///
  {TSynMiniMapColors = class(TPersistent)
  private
    FBackground: TColor;
    FHighlight: TColor;
    FPreviousLine: TColor;
    FPreviousLineText: TColor;
    FText: TColor;
    FTextHighlight: TColor;
  public
    constructor Create(AOwner: TComponent);
  published
    property Background: TColor read FBackground write FBackground;
    property Highlight: TColor read FHighlight write FHighlight;
    property PreviousLine: TColor read FPreviousLine write FPreviousLine;
    property PreviousLineText: TColor read FPreviousLineText write FPreviousLineText;
    property Text: TColor read FText write FText;
    property TextHighlight: TColor read FTextHighlight write FTextHighlight;
  end; }

  ///
  ///  various behavioral options
  ///
  TSynMinimapOptions = class(TPersistent)
  private
    FAllowScroll: Boolean;
    FReverseScroll: Boolean;
    FTabWidthOverride: Boolean;
    FTabWidth: Integer;
  public
    constructor Create(AOwner: TComponent);
  published
    ///
    ///  scrolling editor using the MiniMap is possible only if AllowScroll
    ///
    property AllowScroll: Boolean read FAllowScroll write FAllowScroll;
    property ReverseScroll: Boolean read FReverseScroll write FReverseScroll;
    property TabWidthOverride: Boolean read FTabWidthOverride write FTabWidthOverride;
    property TabWidth: Integer read FTabWidth write FTabWidth;
  end;

  ///
  ///  event fired under various conditions
  ///
  TSynMiniMapEvent = procedure (Sender: TObject; Data: PSynMiniMapEventData) of Object;


  ///
  ///  forward declaration
  ///
  TSynMiniMap = class;

  ///
  ///  this plugin helps hook a few important events
  ///
  TSynMiniMapEditorPlugin = class(TSynEditPlugin)
  protected
    procedure AfterPaint(ACanvas: TCanvas; const AClip: TRect;
      FirstLine: Integer; LastLine: Integer); override;
    procedure LinesDeleted(FirstLine: Integer; Count: Integer); override;
    procedure LinesInserted(FirstLine: Integer; Count: Integer); override;
  private
    FSynMiniMap: TSynMiniMap;
  public
    constructor Create(ASynMiniMap: TSynMiniMap);
  end;

  // Need to declare the correct WMNCPaint record as the VCL (D5-) doesn't.
  {$if CompilerVersion >= 23}
  TRealWMNCPaint = TWMNCPaint;
  {$else}
  TRealWMNCPaint = packed record
    Msg: UINT;
    Rgn: HRGN;
    lParam: LPARAM;
    Result: LRESULT;
  end;
  {$endif}

  ///
  ///  the minimap itself
  ///
  TSynMiniMap = class(TCustomControl)
  private
    FFullSizeBitmap: TBitmap;
    FOffsetBitmap: TBitmap;
    FEditor: TSynEdit;
    FBorderStyle: TSynBorderStyle;
    FEditorHeight: Integer;
    FEditorWidth: Integer;
    FEditorRealWidth: Integer;
    FFirstLine: Integer;
    FLastLine: Integer;
    FMaxCharsPerLine: Word;
    FLineHeightInPixels: Integer;
    FPreviousLineIndex: Integer;
    FFontFactor: Single;
    FCharWidth: Integer;
    FTabWidth: Integer;
    FOptions: TSynMinimapOptions;
    ///
    ///  mouse down & move => scroll
    ///  mouse down + up => click
    ///
    FMouseDownPoint: TPoint;
    FMouseUpPoint: TPoint;
    FScrolling: Boolean;
    FOnClick: TSynMiniMapEvent;
    //FColors: TSynMiniMapColors;
    FMiniMapPlugin: TSynMiniMapEditorPlugin;
    FUseThemes: Boolean;
//    function GetClickCoord: TBufferCoord;
    procedure ResetInternals;
    procedure ClearEventData(var AEventData: TSynMiniMapEventData); inline;
    procedure Render; virtual;
    function GetPixelFormat: TPixelFormat;
    procedure SetPixelFormat(const Value: TPixelFormat);
    procedure SetEditor(const Value: TSynEdit);
    procedure SetFontFactor(const Value: Single);
    procedure SetBorderStyle(Value: TSynBorderStyle);
    function GetBorderDimensions: TSize;
    procedure OriginalWMNCPaint(DC: HDC);
    procedure WMNCPaint(var Message: TRealWMNCPaint); message WM_NCPAINT;
  protected
    procedure Resize; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer;
      Y: Integer); override;
    procedure DoClick(const AX, AY: Integer); virtual;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    {$if CompilerVersion >= 23 }
    class constructor Create;
    {$endif}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function TranslatePoint(const APoint: PPoint): TBufferCoord;
    property PreviousLineIndex: Integer read FPreviousLineIndex;
    property Scrolling: Boolean read FScrolling;
  published
    //property Colors: TSynMiniMapColors read FColors write FColors;
    property Editor: TSynEdit read FEditor write SetEditor;
    property FontFactor: Single read FFontFactor write SetFontFactor;
    property Options: TSynMinimapOptions read FOptions write FOptions;
    property PixelFormat: TPixelFormat read GetPixelFormat write SetPixelFormat;
    property OnClick: TSynMiniMapEvent read FOnClick write FOnClick;
    property BorderStyle: TSynBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property UseThemes: Boolean read FUseThemes write FUseThemes;
    property Ctl3D;
    property Align;
    property AlignWithMargins;
    property Constraints;
    property Height;
    property ShowHint;
    property Width;
    property OnDblClick;
    property OnResize;
    property Visible;
  end;

//procedure Register;

implementation

uses
  System.Math, Vcl.Dialogs, System.UITypes, Vcl.Themes;

resourcestring
  SFontFactorMinMax = 'Font factor cannot be smaller than %.d or greater than %.d.';

{procedure Register;
begin
  RegisterComponents('SynEdit', [TSynMiniMap]);
end; }

{ TSynEditStyleHook }

constructor TSynEditStyleHook.Create(AControl: TWinControl);
begin
  inherited;
  OverridePaintNC := True;
  OverrideEraseBkgnd := True;
  UpdateColors;
end;

procedure TSynEditStyleHook.WMEraseBkgnd(var Message: TMessage);
begin
  Handled := True;
end;

procedure TSynEditStyleHook.UpdateColors;
const
  ColorStates: array[Boolean] of TStyleColor = (scEditDisabled, scEdit);
  FontColorStates: array[Boolean] of TStyleFont = (sfEditBoxTextDisabled, sfEditBoxTextNormal);
var
  LStyle: TCustomStyleServices;
begin
  LStyle := StyleServices;
  Brush.Color := LStyle.GetStyleColor(ColorStates[Control.Enabled]);
  FontColor := LStyle.GetStyleFontColor(FontColorStates[Control.Enabled]);
end;

procedure TSynEditStyleHook.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CM_ENABLEDCHANGED:
      begin
        UpdateColors;
        Handled := False; // Allow control to handle message
      end
  else
    inherited WndProc(Message);
  end;
end;

{ TSynMiniMapCanvasHelper }

procedure TSynMiniMapCanvasHelper.StretchDrawHalftone(const AX, AY, AWidth,
  AHeight: Integer; const ASource: TCanvas;
  const ASrcX, ASrcY, ASrcWidth, ASrcHeight: Integer);
begin
  ///
  ///  helper function for stretch draw of full size bitmap on to
  ///  a smaller one
  ///
  SetStretchBltMode(Self.Handle, HALFTONE);
  StretchBlt(
    Self.Handle,
    AX, AY,
    AWidth, AHeight,
    ASource.Handle,
    ASrcX, ASrcY,
    ASrcWidth, ASrcHeight,
    SRCCOPY
  );
end;

procedure TSynMiniMapCanvasHelper.StretchDrawHalftone(const APoint: TPoint;
  const AWidth, AHeight: Integer; const ASource: TCanvas;
  const ASrcPoint: TPoint; ASrcWidth, ASrcHeight: Integer);
begin
  StretchDrawHalftone(
    APoint.X, APoint.Y,
    AWidth, AHeight,
    ASource,
    ASrcPoint.X, ASrcPoint.Y,
    ASrcWidth, ASrcHeight);
end;

{ TSynMiniMapColors }

{constructor TSynMiniMapColors.Create(AOwner: TComponent);
begin
  inherited Create;
  ///
  ///  set default values
  ///
  Background := clWhite;
  Highlight := $f4f4f4;
  PreviousLine := clNone;
  PreviousLineText := clNone;
  Text := clGray;
  TextHighlight := Text;
end; }

{ TSynMinimapOptions }

constructor TSynMinimapOptions.Create(AOwner: TComponent);
begin
  inherited Create;
  AllowScroll := False;
  ReverseScroll := False;
  TabWidthOverride := False;
  TabWidth := SYNMINIMAP_DEFAULT_OPTIONS_TABWIDTH;
end;

{ TSynMiniMapEditorPlugin }

procedure TSynMiniMapEditorPlugin.AfterPaint(ACanvas: TCanvas;
  const AClip: TRect; FirstLine, LastLine: Integer);
begin
  inherited;
  FSynMiniMap.Render;
end;

constructor TSynMiniMapEditorPlugin.Create(ASynMiniMap: TSynMiniMap);
begin
  inherited Create(ASynMiniMap.Editor);
  FSynMiniMap := ASynMiniMap;
end;

procedure TSynMiniMapEditorPlugin.LinesDeleted(FirstLine, Count: Integer);
var
  LLineIndex: Integer;
begin
  inherited;
  ///
  ///  check if we need to decrement the previous line index
  ///  if current line index is 10 and the user deleted a few lines
  ///  before that, we need to adjust FPreviousLineIndex
  ///
  LLineIndex := FirstLine -1;
  if FSynMiniMap.PreviousLineIndex >= LLineIndex then begin
    Dec(FSynMiniMap.FPreviousLineIndex, Count);
    FSynMiniMap.Render;
  end;
end;

procedure TSynMiniMapEditorPlugin.LinesInserted(FirstLine, Count: Integer);
var
  LLineIndex: Integer;
begin
  inherited;
  ///
  ///  check if we need to increment the previous line index
  ///  if current line index is 10 and the user added a few lines
  ///  before that, we need to adjust FPreviousLineIndex
  ///
  LLineIndex := FirstLine -1;
  if FSynMiniMap.PreviousLineIndex >= LLineIndex then begin
    Inc(FSynMiniMap.FPreviousLineIndex, Count );
    FSynMiniMap.Render;
  end;
end;

{ TSynMiniMap }

function TSynMiniMap.GetBorderDimensions: TSize;

// Returns the overall width of the current window border, depending on border styles.
// Note: these numbers represent the system's standards not special properties, which can be set for TWinControl
// (e.g. bevels, border width).

var
  Styles: Integer;

begin
  Result.cx := 0;
  Result.cy := 0;

  Styles := GetWindowLong(Handle, GWL_STYLE);
  if (Styles and WS_BORDER) <> 0 then
  begin
    Dec(Result.cx);
    Dec(Result.cy);
  end;
  if (Styles and WS_THICKFRAME) <> 0 then
  begin
    Dec(Result.cx, GetSystemMetrics(SM_CXFIXEDFRAME));
    Dec(Result.cy, GetSystemMetrics(SM_CYFIXEDFRAME));
  end;
  Styles := GetWindowLong(Handle, GWL_EXSTYLE);
  if (Styles and WS_EX_CLIENTEDGE) <> 0 then
  begin
    Dec(Result.cx, GetSystemMetrics(SM_CXEDGE));
    Dec(Result.cy, GetSystemMetrics(SM_CYEDGE));
  end;
end;

procedure TSynMiniMap.OriginalWMNCPaint(DC: HDC);

// Unfortunately, the painting for the non-client area in TControl is not always correct and does also not consider
// existing clipping regions, so it has been modified here to take this into account.

const
  InnerStyles: array[TBevelCut] of Integer = (0, BDR_SUNKENINNER, BDR_RAISEDINNER, 0);
  OuterStyles: array[TBevelCut] of Integer = (0, BDR_SUNKENOUTER, BDR_RAISEDOUTER, 0);
  EdgeStyles: array[TBevelKind] of Integer = (0, 0, BF_SOFT, BF_FLAT);
  Ctl3DStyles: array[Boolean] of Integer = (BF_MONO, 0);

var
  RC, RW: TRect;
  EdgeSize: Integer;
  Size: TSize;
  LStyle: TCustomStyleServices;
begin
  if (BevelKind <> bkNone) or (BorderWidth > 0) then
  begin
    RC := Rect(0, 0, Width, Height);
    Size := GetBorderDimensions;
    InflateRect(RC, Size.cx, Size.cy);

    RW := RC;

    if BevelKind <> bkNone then
    begin
      DrawEdge(DC, RC, InnerStyles[BevelInner] or OuterStyles[BevelOuter], Byte(BevelEdges) or EdgeStyles[BevelKind] or
        Ctl3DStyles[Ctl3D]);

      EdgeSize := 0;
      if BevelInner <> bvNone then
        Inc(EdgeSize, BevelWidth);
      if BevelOuter <> bvNone then
        Inc(EdgeSize, BevelWidth);
      with TWithSafeRect(RC) do
      begin
        if beLeft in BevelEdges then
          Inc(Left, EdgeSize);
        if beTop in BevelEdges then
          Inc(Top, EdgeSize);
        if beRight in BevelEdges then
          Dec(Right, EdgeSize);
        if beBottom in BevelEdges then
          Dec(Bottom, EdgeSize);
      end;
    end;

    // Repaint only the part in the original clipping region and not yet drawn parts.
    IntersectClipRect(DC, RC.Left, RC.Top, RC.Right, RC.Bottom);

    // Determine inner rectangle to exclude (RC corresponds then to the client area).
    InflateRect(RC, -Integer(BorderWidth), -Integer(BorderWidth));

    // Remove the inner rectangle.
    ExcludeClipRect(DC, RC.Left, RC.Top, RC.Right, RC.Bottom);

    // Erase parts not drawn.
    LStyle := StyleServices;
    if LStyle.Enabled then
      Brush.Color := LStyle.GetStyleColor(scBorder)
    else
      Brush.Color := clBtnFace;
    Winapi.Windows.FillRect(DC, RW, Brush.Handle);
  end;
end;

procedure TSynMiniMap.WMNCPaint(var Message: TRealWMNCPaint);

var
  DC: HDC;
  R: TRect;
  Flags: DWORD;
  ExStyle: Integer;
  TempRgn: HRGN;
  BorderWidth,
  BorderHeight: Integer;

begin
  if FUseThemes then
  begin
    // If theming is enabled and the client edge border is set for the window then prevent the default window proc
    // from painting the old border to avoid flickering.
    ExStyle := GetWindowLong(Handle, GWL_EXSTYLE);
    if (ExStyle and WS_EX_CLIENTEDGE) <> 0 then
    begin
      GetWindowRect(Handle, R);
      // Determine width of the client edge.
      BorderWidth := GetSystemMetrics(SM_CXEDGE);
      BorderHeight := GetSystemMetrics(SM_CYEDGE);
      InflateRect(R, -BorderWidth, -BorderHeight);
      TempRgn := CreateRectRgnIndirect(R);
      // Exclude the border from the message region if there is one. Otherwise just use the inflated
      // window area region.
      if Message.Rgn <> 1 then
        CombineRgn(TempRgn, Message.Rgn, TempRgn, RGN_AND);
      DefWindowProc(Handle, Message.Msg, WPARAM(TempRgn), 0);
      DeleteObject(TempRgn);
    end
    else
      DefaultHandler(Message);
  end
  else
    DefaultHandler(Message);

  Flags := DCX_CACHE or DCX_CLIPSIBLINGS or DCX_WINDOW or DCX_VALIDATE;

  if (Message.Rgn = 1) then
    DC := GetDCEx(Handle, 0, Flags)
  else
    DC := GetDCEx(Handle, Message.Rgn, Flags or DCX_INTERSECTRGN);

  if DC <> 0 then
  begin
    OriginalWMNCPaint(DC);
    ReleaseDC(Handle, DC);
  end;

  if FUseThemes then
    StyleServices.PaintBorder(Self, False);
end;

procedure TSynMiniMap.ClearEventData(var AEventData: TSynMiniMapEventData);
begin
  FillChar(AEventData, 0, szSynMiniMapEventData);
end;

{$if CompilerVersion >= 23 }
class constructor TSynMiniMap.Create;
begin
  inherited;
  if Assigned(TStyleManager.Engine) then
    TStyleManager.Engine.RegisterStyleHook(TSynMiniMap, TSynEditStyleHook);
end;
{$endif}

constructor TSynMiniMap.Create(AOwner: TComponent);
begin
  inherited;
  FFullSizeBitmap := TBitmap.Create;
  FOffsetBitmap := TBitmap.Create;
  //FColors := TSynMiniMapColors.Create(Self);
  PixelFormat := pf32bit;
  Self.Height := SYNMINIMAP_DEFAULT_HEIGHT;
  Self.Width := SYNMINIMAP_DEFAULT_WIDTH;
  FMaxCharsPerLine := 100;
  FOptions := TSynMinimapOptions.Create(Self);
  FPreviousLineIndex := -1;
  FFontFactor := SYNMINIMAP_DEFAULT_FONTFACTOR;
  FScrolling := False;
  FBorderStyle := bsSingle;
  FUseThemes := True;
end;

procedure TSynMiniMap.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
  ClassStylesOff = CS_VREDRAW or CS_HREDRAW;
begin
  // Clear WindowText to avoid it being used as Caption, or else window creation will
  // fail if it's bigger than 64KB. It's useless to set the Caption anyway.
  StrDispose(WindowText);
  WindowText := nil;
  inherited CreateParams(Params);
  with Params do
  begin
    WindowClass.Style := WindowClass.Style and not ClassStylesOff;
    Style := Style or BorderStyles[fBorderStyle] or WS_CLIPCHILDREN;

    {if NewStyleControls and Ctl3D and (fBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end; }
    if FBorderStyle = bsSingle then
    begin
      if Ctl3D then
      begin
        ExStyle := ExStyle or WS_EX_CLIENTEDGE;
        Style := Style and not WS_BORDER;
      end
      else
        Style := Style or WS_BORDER;
    end
    else
      Style := Style and not WS_BORDER;

{$IFNDEF UNICODE}
    if not (csDesigning in ComponentState) then
    begin
      // Necessary for unicode support, especially IME won't work else
      if Win32PlatformIsUnicode then
        WindowClass.lpfnWndProc := @DefWindowProcW;
    end;
{$ENDIF}
  end;
end;

procedure TSynMiniMap.SetBorderStyle(Value: TSynBorderStyle);
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

destructor TSynMiniMap.Destroy;
begin
  //FColors.Free;
  FFullSizeBitmap.Free;
  FOffsetBitmap.Free;
  FOptions.Free;
  inherited;
end;

procedure TSynMiniMap.DoClick(const AX, AY: Integer);
var
  LEventData: TSynMiniMapEventData;
  LPoint: TPoint;
begin
  ///
  ///  OnClick has no value unless we have an editor assign
  ///
  if Assigned(FOnClick) and Assigned(FEditor) then begin
    ///
    ///  save previous line index for drawing in Render
    ///
    FPreviousLineIndex := FEditor.CaretY -1;
    ///
    ///  reset event data record
    ///
    ClearEventData(LEventData);
    ///
    ///  set the Line and Char coordonates
    ///
    LPoint.X := AX;
    LPoint.Y := AY;
    LEventData.Coord := TranslatePoint(@LPoint);
    ///
    ///  invoke assigned event
    ///
    FOnClick(Self, @LEventData);
    ///
    ///  check if we were asked to redraw
    ///
    if LEventData.Redraw then
      Render;
  end;
end;

{function TSynMiniMap.GetClickCoord: TBufferCoord;
var
  LPoint: TPoint;
begin
  ///
  ///  grab the cursor coordonates
  ///
  Windows.GetCursorPos(LPoint);
  LPoint := Self.ScreenToClient(LPoint);
  Result := TranslatePoint(@LPoint);
end; }

function TSynMiniMap.GetPixelFormat: TPixelFormat;
begin
  ///
  ///  return the current pixel format
  ///
  Result := FFullSizeBitmap.PixelFormat;
end;

procedure TSynMiniMap.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FScrolling := ( mbLeft = Button ) and Options.AllowScroll;
  FMouseDownPoint.X := X;
  FMouseDownPoint.Y := Y;
end;

procedure TSynMiniMap.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LDelta: Integer;
  LScrollDown: Boolean;
begin
  inherited;
  if NOT Options.AllowScroll then
    Exit;
  if Scrolling and Assigned(Editor) then begin
    LDelta := FMouseDownPoint.Y - Y;
    LDelta := Trunc(LDelta /  FFontFactor);
    LDelta := Abs(LDelta);

    LScrollDown := (Y > FMouseDownPoint.Y);
    if Options.ReverseScroll then
      LScrollDown := NOT LScrollDown;

    if LScrollDown then
    //if Y > FMouseDownPoint.Y then
      Editor.CaretY := Editor.CaretY + LDelta
    else
      Editor.CaretY := Editor.CaretY - LDelta;
  end;
end;

procedure TSynMiniMap.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  LIsClick: Boolean;
begin
  inherited;
  FScrolling := False;
  FMouseUpPoint.X := X;
  FMouseUpPoint.Y := Y;
  LIsClick := ( NOT Options.AllowScroll )
    or (( FMouseDownPoint.X = FMouseUpPoint.X)
    and (FMouseDownPoint.Y = FMouseUpPoint.Y ));
  if LIsClick then
    DoClick(X, Y);
end;

procedure TSynMiniMap.Paint;
begin
  ///
  ///  draw the buffered bitmap
  ///
  Canvas.Draw(0, 0, FOffsetBitmap);
end;

procedure TSynMiniMap.Render;
var
  LLineHeight: Integer;
  LLineCount: Integer;
  LLineTop: Integer;
  LLineText: string;
  LMaxLineCount: Integer;
  LDrawHeight: Integer;
  LDrawWidth: Integer;
  LTopLineIndex: Integer;
//  LFocusRect: TRect;
//  LFocusTopIndex: Integer;
//  LPreviousLine: Boolean;
  Index: Integer;
  LStyle: TCustomStyleServices;

    function __get_line_xpos: Integer;
    ///
    ///  this function is counting leading spaces and tabs
    ///  could use improvements
    ///
    var
      cIndex: Integer;
    begin
      Result := 0;
      for cIndex := 1 to Length(LLineText) do
        case LLineText[cIndex] of
          #$9: Inc(Result, FTabWidth);
          ' ': Inc(Result, FCharWidth);
          else
            Break;
        end;
    end;

begin
  LStyle := StyleServices;
  if ( NOT Assigned(Editor) ) or ( csDestroying in ComponentState ) then
    Exit;

  ///
  ///  this is where the magic happens
  ///  what it does:
  ///  -  the MiniMap control has a limited height, we need to translate
  ///   that height into a maximum number of lines we can display from
  ///   the synedit control
  ///  -  create a "full size bitmap"
  ///  -  paint various misc stuff(highlight, previous line, etc.)
  ///  -  paint each line starting from X lines before current visible lines
  ///   and Y lines after
  ///  -  scale down the "full size bitmap" and paint it on to the
  ///   "offset bitmap"
  ///   each time the "pain event" occures, the "offset bitmap" is used to
  ///   draw on the MiniMap control
  ///

  ///
  ///  grab the lines
  ///
  LLineCount := Editor.Lines.Count;
  ///
  /// store the first visible line index
  ///  IMPORTANT:
  ///  -  synedit refers to lines as "real index" + 1
  ///
  LTopLineIndex := Editor.TopLine -1;
  ///
  ///  grab the font size of full size bitmap
  ///
  LLineHeight := FFullSizeBitmap.Canvas.Font.Size;
  ///
  ///  add a 2 pixel line spacing
  ///
  Inc(LLineHeight, 2);
  ///
  ///  "shrink" the font to a much small dimension, each character will be
  ///  FontFactor times smaller than the "real thing"
  ///
  FLineHeightInPixels := Trunc( LLineHeight / FFontFactor);
  ///
  ///  calculate the maximum number of lines we can display
  ///  IMPORTANT:
  ///  -  FLineHeightInPixels includes the "line spacing"
  ///
  LMaxLineCount := Self.Height div FLineHeightInPixels;
  ///
  ///  calculate the smalles value of lines we will display
  ///  if the lines in editor are more than we can display
  ///  then we display the maximum possible, otherwise display as many
  ///  as there are in the editor
  ///
  LLineCount := Min(LLineCount, LMaxLineCount);
  ///
  ///  setup the full size bitmap dimensions
  ///
  FFullSizeBitmap.Height := LLineCount * LLineHeight;
  ///
  ///  setup the background color and fill it
  ///
  if LStyle.Enabled then
    FFullSizeBitmap.Canvas.Brush.Color := LStyle.GetStyleColor(scEdit)
  else
    FFullSizeBitmap.Canvas.Brush.Color := clWhite;
  FFullSizeBitmap.Canvas.FillRect(Rect(0, 0, FFullSizeBitmap.Width, FFullSizeBitmap.Height));
  ///
  ///  calculate the first and last lines that we will grab from editor
  ///  and display in the MiniMap
  ///
  FFirstLine := LTopLineIndex - ( LMaxLineCount div 2 ) + (Editor.LinesInWindow div 2);
  FFirstLine := Max(FFirstLine, 0);
  FLastLine := Min(FFirstLine + LLineCount, Editor.Lines.Count -1);
  ///
  ///  setup brush and pen
  ///
(*  FFullSizeBitmap.Canvas.Brush.Style := bsSolid;
  FFullSizeBitmap.Canvas.Brush.Color := Colors.Highlight;
  FFullSizeBitmap.Canvas.Pen.Style := psClear;
  ///
  ///  highlight visible lines with provided color
  ///
  LFocusTopIndex := LTopLineIndex - FFirstLine;
  LFocusRect := Rect(
    0,
    LFocusTopIndex * LLineHeight,
    FFullSizeBitmap.Width,
    ( LFocusTopIndex + Editor.LinesInWindow ) * LLineHeight
  );
  FFullSizeBitmap.Canvas.Rectangle(LFocusRect);  *)
  ///
  ///  check if we need to hightlight previous line
  ///  previous line is saved when the user clicks on the MiniMap
  ///  on MiniMap's OnClick event you can jump to the clicked line
  ///
(*  LPreviousLine := ( Colors.PreviousLine <> clNone ) and
    ( PreviousLineIndex >= FFirstLine ) and ( PreviousLineIndex <= FLastLine );
  if LPreviousLine then begin
    FFullSizeBitmap.Canvas.Brush.Color := Colors.PreviousLine;
    LFocusRect := Rect(
      0,
      ( PreviousLineIndex - FFirstLine ) * LLineHeight,
      FFullSizeBitmap.Width,
      ( PreviousLineIndex - FFirstLine  + 1) * LLineHeight);
    FFullSizeBitmap.Canvas.Rectangle(LFocusRect);
  end; *)
  ///
  ///  set the brush style to clear, otherwise we get uggly background color
  ///  for each line
  ///
  FFullSizeBitmap.Canvas.Brush.Style := bsClear;
  ///
  ///  LLineTop holds the Y pixel value of the line
  ///
  LLineTop := 0;
  ///
  ///  start drawing lines
  ///
  Index := FFirstLine;
  while Index <= FLastLine do begin
    ///
    ///  grab current line text
    ///
    LLineText := Editor.Lines[Index];
(*    if ( Index = PreviousLineIndex ) and (Colors.PreviousLineText <> clNone) then
      ///
      ///  color of the previous line if applies
      ///
      FFullSizeBitmap.Canvas.Font.Color := Colors.PreviousLineText
    else *)
    if ( Index >= LTopLineIndex ) and ( Index <= LTopLineIndex + Editor.LinesInWindow ) then
      ///
      ///  font color of lines visible in the editor
      ///
    begin
      if LStyle.Enabled then
        FFullSizeBitmap.Canvas.Font.Color := LStyle.GetStyleFontColor(sfEditBoxTextNormal)
      else
        FFullSizeBitmap.Canvas.Font.Color := clBlack;
    end
    else
      ///
      ///  normal text font color
      ///
    begin
      if LStyle.Enabled then
        FFullSizeBitmap.Canvas.Font.Color := LStyle.GetStyleFontColor(sfEditBoxTextDisabled)
      else
        FFullSizeBitmap.Canvas.Font.Color := clGray;
    end;
    ///
    ///  draw the text
    ///  at this point, the font size is the same as in the editor
    ///  just the line spacing is smaller
    ///
    FFullSizeBitmap.Canvas.TextOut(__get_line_xpos, LLineTop, LLineText);
    ///
    ///  increment the top pixel
    ///
    Inc(LLineTop, LLineHeight);
    ///
    ///  increment the line
    ///
    Inc(Index);
  end;
  ///
  ///  if the current number of lines in the editor is smaller than
  ///  the maximum we can display, we need to fill the canvas with
  ///  the provided background color
  ///
  if LStyle.Enabled then
    FOffsetBitmap.Canvas.Brush.Color := LStyle.GetStyleColor(scEdit)
  else
    FOffsetBitmap.Canvas.Brush.Color := clWhite;
  FOffsetBitmap.Canvas.FillRect(Rect(0, 0, Width, Height));
  ///
  ///  and adjust the size of the "scaled down" version of full size bitmap
  ///
  LDrawHeight := Height;
  if FOffsetBitmap.Height > LLineCount * FLineHeightInPixels then
    LDrawheight := LLineCount * FLineHeightInPixels;

  LDrawWidth := Trunc(FFullSizeBitmap.Width / FFontFactor);

  FOffsetBitmap.Canvas.StretchDrawHalftone(0, 0, LDrawWidth, LDrawheight,
    FFullSizeBitmap.Canvas, 0, 0, FFullSizeBitmap.Width, FFullSizeBitmap.Height);

  ///
  /// call paint to update the canvas
  ///
  Paint;
end;

procedure TSynMiniMap.ResetInternals;
var
  LStyle: TCustomStyleServices;
begin
  LStyle := StyleServices;
  if NOT Assigned(Editor) then
    Exit;
  FEditorHeight := Editor.Height;
  FEditorWidth := Editor.Width;
  FEditorRealWidth := FEditorWidth - Editor.Gutter.Width;
  FFullSizeBitmap.Canvas.Brush.Style := bsSolid;
  if LStyle.Enabled then
    FFullSizeBitmap.Canvas.Brush.Color := LStyle.GetStyleColor(scEdit)
  else
    FFullSizeBitmap.Canvas.Brush.Color := clWhite;
  FFullSizeBitmap.Canvas.Font.Height := Editor.Font.Height;
  FFullSizeBitmap.Canvas.Font.Size := Editor.Font.Size;
  FFullSizeBitmap.Canvas.Font.Name := Editor.Font.Name;
  FCharWidth := FFullSizeBitmap.Canvas.TextWidth('X');
  if Options.TabWidthOverride then
    FTabWidth := Options.TabWidth
  else
    FTabWidth := FCharWidth * Editor.TabWidth;
  FMaxCharsPerLine := Trunc(Self.Width / (FCharWidth / FFontFactor));
  FFullSizeBitmap.Width := FMaxCharsPerLine * FCharWidth;
  Self.Color := Editor.Color;

  Render;
end;

procedure TSynMiniMap.Resize;
const
  CNO_EDITOR = '(no editor assigned)';
var
  LTextHeight: Integer;
  LTextWidth: Integer;
  LTextX: Integer;
  LTextY: Integer;
  LStyle: TCustomStyleServices;
begin
  LStyle := StyleServices;
  FOffsetBitmap.Height := Self.Height;
  FOffsetBitmap.Width := Self.Width;
  if LStyle.Enabled then
    FOffsetBitmap.Canvas.Brush.Color := LStyle.GetStyleColor(scEdit)
  else
    FOffsetBitmap.Canvas.Brush.Color := clWhite;
  FOffsetBitmap.Canvas.FillRect(Rect(0, 0, Width, Height));
  if LStyle.Enabled then
    FOffsetBitmap.Canvas.Font.Color := LStyle.GetStyleFontColor(sfEditBoxTextNormal)
  else
    FOffsetBitmap.Canvas.Font.Color := clBlack;
  if csDesigning in ComponentState then begin
    LTextHeight := FOffsetBitmap.Canvas.TextHeight(CNO_EDITOR);
    LTextWidth := FOffsetBitmap.Canvas.TextWidth(CNO_EDITOR);
    LTextX := Width div 2 - LTextWidth div 2;
    LTextY := Height div 2 - LTextHeight div 2;
    FOffsetBitmap.Canvas.TextOut(LTextX, LTextY, CNO_EDITOR);
  end;
  ResetInternals;
  inherited Resize;
end;

procedure TSynMiniMap.SetEditor(const Value: TSynEdit);
begin
  FEditor := Value;
  ///
  ///  create a plugin if we don't have one
  ///
  if Value <> NIL then
    FMiniMapPlugin := TSynMiniMapEditorPlugin.Create(Self);

  ResetInternals;
end;

procedure TSynMiniMap.SetFontFactor(const Value: Single);
begin
  if ( Value < SYNMINIMAP_FONTFACTOR_MIN ) or
      ( Value > SYNMINIMAP_FONTFACTOR_MAX ) then begin
    MessageDlg(
      Format(SFontFactorMinMax, [SYNMINIMAP_FONTFACTOR_MIN,
        SYNMINIMAP_FONTFACTOR_MAX]),
      mtError, [mbOK], 0);
    Exit;
  end;
  FFontFactor := Value;
  Render;
end;

procedure TSynMiniMap.SetPixelFormat(const Value: TPixelFormat);
begin
  ///
  ///  set the pixel format on both bitmaps
  ///
  FFullSizeBitmap.PixelFormat := Value;
  FOffsetBitmap.PixelFormat := Value;
end;

function TSynMiniMap.TranslatePoint(const APoint: PPoint): TBufferCoord;
var
  LChar: Integer;
begin
  ///
  ///  this method translates X and Y from control's surface into
  ///  editor's Line and Char, mainly used in OnClick event
  ///
  if APoint.X < 1 then
    LChar := 1
  else
    LChar := Trunc(APoint.X / (FCharWidth / FFontFactor));
  if LChar > FMaxCharsPerLine then
    LChar := FMaxCharsPerLine;
  Result.Char := LChar;
  Result.Line := FFirstLine + APoint.Y div FLineHeightInPixels +1;
end;

initialization

finalization

end.
