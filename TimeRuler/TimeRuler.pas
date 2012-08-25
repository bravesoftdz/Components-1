unit TimeRuler;

interface

uses
  Windows, Messages, Classes, Controls, ExtCtrls, Forms, Buttons, Types, SysUtils,
  Graphics, dialogs, ThdTimer, JvSpeedButton;

const
  MSTOH         = 86400000; // Milliseconds to Hours 1000 * 60 * 60 * 24
  TIMEFORMAT    = '%.d:%.2d:%.2d.%.2d';
  TIMEFORMATNEG = '-%.d:%.2d:%.2d.%.2d';
  TEXT_FROM     = ' from ';
  TEXT_TO       = ' to ';


type
  TBtnDown = (bdNone, bdLeftUpper, bdLeftLower, bdRightUpper, bdRightLower);
  TScrollDirection = (sdLeft, sdRight, sdNotScrolling);

  TCustomTimeRuler = class(TCustomPanel)
  private
    FUpperLeftBtn: TJvSpeedButton;
    FUpperRightBtn: TJvSpeedButton;
    FLowerLeftBtn: TJvSpeedButton;
    FLowerRightBtn: TJvSpeedButton;
    FBtnDown: TBtnDown;
    FButtonWidth: Integer;
    FCurrentTime: LongInt;
    FScrollChangeButtons: Word;
    FScrollChangeButtonsMore: Word;
    FScrollChangeKeyDown: Word;
    FTimer: TThreadedTimer;
    FTimeWidth: Integer;
    FEDTLength: Longint;
    FEDTStart: Longint;
    FAviStart: Longint;
    FAviLength: Longint;
    FRangeStart: Longint;
    FRangeEnd: Longint;
    FOnChange: TNotifyEvent;
    FAviEnabled: Boolean;
    FScrolling: TScrollDirection;
    FAviRect: TRect;
    FLeftRangeRect: TRect;
    FRightRangeRect: TRect;
    FHit: Integer;
    FDraggingAvi: Boolean;
    FDraggingLeftRange: Boolean;
    FDraggingRightRange: Boolean;
    FAviFilename: String;
    FEyedatFilename: String;
    FShowCurrentArrow: Boolean;
    FShowRange: Boolean;
    { colors }
    FBackground1: TColor;
    FBackground2: TColor;
    FEyedatBackground: TColor;
    FAviBackground: TColor;
    FRangeSelectLeft: TColor;
    FRangeSelectRight: TColor;
    FRangeSelect: TColor;
    FEyedatText: TColor;
    FAviText: TColor;
    FTimelineText: TColor;
    FCurrentArrow: TColor;
    FEyedatBorders: TColor;
    FAviBorders: TColor;
    FRulerLines: TColor;
    FDisabledBackground: TColor;
    FOnAviChange: TNotifyEvent;
    FOnAviMove: TNotifyEvent;
    procedure DoL1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoL2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoR1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoR2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetCurrentTime(const Value: LongInt);
    procedure StartTimer;
    procedure StopTimer;
    procedure DoTimer(Sender: TObject);
    procedure DrawTimes(ACanvas: TCanvas);
    procedure DrawTimeLine(var Bmp: TBitmap);
    procedure DrawRows(var Bmp: TBitmap);
    procedure DrawEyedatLine(var Bmp: TBitmap);
    procedure DrawAviLine(var Bmp: TBitmap);
    procedure DrawCurrentArrow(var ACanvas: TCanvas);
    procedure DrawRangeSelect(var Bmp: TBitmap);
    function FormatTime(Time: Longint): String;
    procedure SetButtonWidth(const Value: Integer);
    procedure SetTimeWidth(const Value: Integer);
    procedure SetShowRange(const Value: Boolean);
    // this is needed so we receive the arrow keys
    procedure WMGetDlgCode(var Msg: TWmGetDlgCode); message WM_GETDLGCODE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    function PointInRect(const P: TPoint; const R: TRect): Boolean;
  protected
    procedure Paint; override;
    procedure Change; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    property UpperRightButton: TJvSpeedButton read FUpperRightBtn;
    property UpperLeftButton: TJvSpeedButton read FUpperLeftBtn;
    property LowerRightButton: TJvSpeedButton read FLowerRightBtn;
    property LowerLeftButton: TJvSpeedButton read FLowerLeftBtn;
    property CurrentTime: LongInt read FCurrentTime write SetCurrentTime;
    property ScrollChangeButtons: Word read FScrollChangeButtons write FScrollChangeButtons default 100;
    property ScrollChangeButtonsMore: Word read FScrollChangeButtonsMore write FScrollChangeButtonsMore default 1000;
    property ScrollChangeKeyDown: Word read FScrollChangeKeyDown write FScrollChangeKeyDown default 100;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 16;
    property TimeWidth: Integer read FTimeWidth write SetTimeWidth default 80;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property EDTLength: Longint read FEDTLength write FEDTLength;
    property EDTStart: Longint read FEDTStart write FEDTStart;
    property AviLength: Longint read FAviLength write FAviLength;
    property AviStart: Longint read FAviStart write FAviStart;
    property RangeStart: Longint read FRangeStart write FRangeStart;
    property RangeEnd: Longint read FRangeEnd write FRangeEnd;
    property AviEnabled: Boolean read FAviEnabled write FAviEnabled;
    property AviFilename: String read FAviFilename write FAviFilename;
    property EyedatFilename: String read FEyedatFilename write FEyedatFilename;
    property ShowCurrentArrow: Boolean read FShowCurrentArrow write FShowCurrentArrow;
    property ShowRange: Boolean read FShowRange write SetShowRange;
    property Background1: TColor read FBackground1 write FBackground1;
    property Background2: TColor read FBackground2 write FBackground2;
    property EyedatBackground: TColor read FEyedatBackground write FEyedatBackground;
    property AviBackground: TColor read FAviBackground write FAviBackground;
    property EyedatText: TColor read FEyedatText write FEyedatText;
    property AviText: TColor read FAviText write FAviText;
    property TimelineText: TColor read FTimelineText write FTimelineText;
    property CurrentArrow: TColor read FCurrentArrow write FCurrentArrow;
    property EyedatBorders: TColor read FEyedatBorders write FEyedatBorders;
    property AviBorders: TColor read FAviBorders write FAviBorders;
    property RulerLines: TColor read FRulerLines write FRulerLines;
    property DisabledBackground: TColor read FDisabledBackground write FDisabledBackground;
    property RangeSelectLeft: TColor read FRangeSelectLeft write FRangeSelectLeft;
    property RangeSelectRight: TColor read FRangeSelectRight write FRangeSelectRight;
    property RangeSelect: TColor read FRangeSelect write FRangeSelect;
    property OnAviChange: TNotifyEvent read FOnAviChange write FOnAviChange;
    property OnAviMove: TNotifyEvent read FOnAviMove write FOnAviMove;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // scrolls the display milliseconds of time. Milliseconds can be either negative or positive
    procedure ScrollTime(Sender: TObject; milliseconds: LongInt);
  end;

  TTimeRuler = class(TCustomTimeRuler)
  public
    property UpperRightButton;
    property UpperLeftButton;
    property LowerRightButton;
    property LowerLeftButton;
  published
    property BorderStyle;
    property ButtonWidth;
    property CurrentTime;
    property ScrollChangeButtons;
    property ScrollChangeKeyDown;
    property EDTLength;
    property EDTStart;
    property AviLength;
    property AviStart;
    property AviEnabled;
    property RangeStart;
    property RangeEnd;
    property AviFilename;
    property EyedatFilename;
    property ShowCurrentArrow;
    property ShowRange;

    property Background1;
    property Background2;
    property EyedatBackground;
    property AviBackground;
    property RangeSelectLeft;
    property RangeSelectRight;
    property RangeSelect;
    property EyedatText;
    property AviText;
    property TimelineText;
    property CurrentArrow;
    property EyedatBorders;
    property AviBorders;
    property RulerLines;
    property DisabledBackground;
    
    property Action;
    property Align default alTop;
    property Anchors;
    property Constraints;
    property Cursor;
    property Enabled;
    property Font;
    property Height;
    property Hint;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopUpMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Color;
    property OnAviChange;
    property OnAviMove;
    // triggered when the display is scrolled or when the left-most date changes
    property OnChange;
    // triggered when the control is clicked
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

{$R TimeRuler.res}

constructor TCustomTimeRuler.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Height := 61;
  //BevelInner := bvNone;
  BevelOuter := bvNone;
  Color := clWindow;
  Align := alTop;
  BorderStyle := bsSingle;
  DoubleBuffered := True;
  ControlStyle := ControlStyle - [csSetCaption, csAcceptsControls];
  ControlStyle := ControlStyle + [csOpaque];

  FDraggingAvi := False;
  FBackground1 := clWhite;
  FBackground2 := clInfoBk;
  FEyedatBackground := clRed;
  FAviBackground := clNavy;
  FEyedatText := clWhite;
  FAviText := clWhite;
  FTimelineText := clBlack;
  FCurrentArrow := clBlack;
  FEyedatBorders := clBlack;
  FAviBorders := clBlack;
  FRulerLines := clBlack;
  FDisabledBackground := clBtnFace;
  FRangeSelectLeft := clBlack;
  FRangeSelectRight := clBlack;
  FRangeSelect := clSkyBlue;

  FButtonWidth := 16;
  FCurrentTime := 0;
  FTimeWidth := 80;
  FScrolling := sdNotScrolling;
  FScrollChangeButtons := 100;
  FScrollChangeButtonsMore := 1000;
  FScrollChangeKeyDown := 100;

  Font.Size := 10;
  Font.Name := 'Tahoma';



  FUpperLeftBtn := TJvSpeedButton.Create(Self);
  with FUpperLeftBtn do
  begin
    Height := 25;
    Width := FButtonWidth;
    Parent := Self;
    Transparent := True;
    Layout := blGlyphTop;
    Glyph.LoadFromResourceName(hInstance, 'SCRL_LEFT');
    OnMouseDown := DoL1MouseDown;
    OnMouseUp := DoMouseUp;
  end;
  FUpperLeftBtn.SetSubComponent(True);

  FLowerLeftBtn := TJvSpeedButton.Create(Self);
  with FLowerLeftBtn do
  begin
    Height := 34;
    Width := FButtonWidth;
    Parent := Self;
    Transparent := True;
    Layout := blGlyphTop;
    Glyph.LoadFromResourceName(hInstance, 'SCRL_LEFTMORE');
    OnMouseDown := DoL2MouseDown;
    OnMouseUp := DoMouseUp;
  end;
  FLowerLeftBtn.SetSubComponent(True);

  FUpperRightBtn := TJvSpeedButton.Create(Self);
  with FUpperRightBtn do
  begin
    Height := 25;
    Width := FButtonWidth;
    Parent := Self;
    Transparent := True;
    Layout := blGlyphTop;
    Glyph.LoadFromResourceName(hInstance, 'SCRL_RIGHT');
    OnMouseDown := DoR1MouseDown;
    OnMouseUp := DoMouseUp;
  end;
  FUpperRightBtn.SetSubComponent(True);

  FLowerRightBtn := TJvSpeedButton.Create(Self);
  with FLowerRightBtn do
  begin
    Height := 34;
    Width := FButtonWidth;
    Parent := Self;
    Transparent := True;
    Layout := blGlyphTop;
    Glyph.LoadFromResourceName(hInstance, 'SCRL_RIGHTMORE');
    OnMouseDown := DoR2MouseDown;
    OnMouseUp := DoMouseUp;
  end;
  FLowerRightBtn.SetSubComponent(True);
end;

procedure TCustomTimeRuler.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  Msg.Result := Msg.Result or DLGC_WANTARROWS;
end;

procedure TCustomTimeRuler.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TCustomTimeRuler.SetShowRange(const Value: Boolean);
begin
  if Value <> FShowRange then
  begin
    FShowRange := Value;
    Invalidate;
  end;
end;

procedure TCustomTimeRuler.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  R: TRect;
  Offset: Integer;
begin
  inherited;
  if (Button = mbLeft) and not (ssDouble in Shift) then
  begin
    if CanFocus then
      SetFocus;
    Offset := -round(((Self.CurrentTime mod 2000)+2000)*(FTimeWidth/2000));
    P := Point(X, Y);

    R := FLeftRangeRect;
    OffsetRect(R, Offset, 0);
    if PointInRect(P, R) then
    begin
      FDraggingLeftRange := True;
      FHit := X - R.Left;
      Exit;
    end;

    R := FRightRangeRect;
    OffsetRect(R, Offset, 0);
    if PointInRect(P, R) then
    begin
      FDraggingRightRange := True;
      FHit := X - R.Left;
      Exit;
    end;

    R := FAviRect;
    OffsetRect(R, Offset, 0);
    if PointInRect(P, R) then
    begin
      FDraggingAvi := True;
      FHit := X - R.Left;
      Exit;
    end;

    { time line clicked }
    R := Rect(ButtonWidth, 0, Width - ButtonWidth, Font.Size + 14);
    if PointInRect(P, R) then
    begin
      FCurrentTime := FCurrentTime + Round((P.X-ButtonWidth)*(2000/FTimeWidth))-1000;
      OnChange(nil);
      Invalidate;
      //Exit;
    end;
  end;
end;

procedure TCustomTimeRuler.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  R: TRect;
  Offset: integer;
  TmpStart: integer;
begin
  inherited MouseMove(Shift, X, Y);
  R := Rect(0,0,0,0);
  TmpStart := 0;
  FScrolling := sdNotScrolling;
  if (Shift = [ssLeft]) then
  begin
    Offset := -round(((Self.CurrentTime mod 2000)+2000)*(FTimeWidth/2000));

    if FDraggingAvi then
    begin
      R := FAviRect;
      OffsetRect(R, Offset, 0);
      FAviStart := Round(FAviStart - (2000/FTimeWidth)*(R.Left+FHit-X));
      if Assigned(FOnAviMove) then FOnAviMove(Self);
    end
    else
    if FDraggingLeftRange then
    begin
      R := FLeftRangeRect;
      OffsetRect(R, Offset, 0);
      if FLeftRangeRect.Right < FRightRangeRect.Left then
        TmpStart := Round(FRangeStart - (2000/FTimeWidth)*(R.Left+FHit-X));

      if TmpStart > FRangeEnd - 200 then
        TmpStart := FRangeEnd - 200;

      FRangeStart := TmpStart;
    end
    else
    if FDraggingRightRange then
    begin
      R := FRightRangeRect;
      OffsetRect(R, Offset, 0);
      if FRightRangeRect.Left > FLeftRangeRect.Right then
        TmpStart := Round(FRangeEnd - (2000/FTimeWidth)*(R.Left+FHit-X));

      if TmpStart < FRangeStart + 200 then
        TmpStart := FRangeStart + 200;

      FRangeEnd := TmpStart;
    end;

    if X + ButtonWidth > Width then
      FScrolling := sdRight
    else
    if X - ButtonWidth < 0 then
      FScrolling := sdLeft
    else
      FScrolling := sdNotScrolling;
    Invalidate;
  end;
end;

function TCustomTimeRuler.PointInRect(const P: TPoint; const R: TRect): Boolean;
begin
  with R do
    Result := (Left <= P.X) and (Top <= P.Y) and
      (Right >= P.X) and (Bottom >= P.Y);
end;

procedure TCustomTimeRuler.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);

  if FDraggingAvi then
  begin
    FDraggingAvi := False;
    if Assigned(FOnAviChange) then FOnAviChange(Self);
  end;
  FDraggingLeftRange := False;
  FDraggingRightRange := False;
end;

destructor TCustomTimeRuler.Destroy;
begin
  inherited Destroy;
end;

procedure TCustomTimeRuler.DoL1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    Exit;

  ScrollTime(Sender, -FScrollChangeButtons);
  FBtnDown := bdLeftUpper;

  StartTimer;
end;

procedure TCustomTimeRuler.DoL2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    Exit;

  ScrollTime(Sender, -FScrollChangeButtonsMore);
  FBtnDown := bdLeftLower;

  StartTimer;
end;

procedure TCustomTimeRuler.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not Enabled then
    Exit;
  // handling keys in KeyDown gives automatic
  // scrolling when holding the key down
  case Key of
    VK_LEFT:
      ScrollTime(nil, -FScrollChangeKeyDown);

    VK_RIGHT:
      ScrollTime(nil, FScrollChangeKeyDown);
  end;
end;

procedure TCustomTimeRuler.ScrollTime(Sender: TObject; milliseconds: LongInt);
begin
  Self.CurrentTime := Self.CurrentTime + milliseconds;
end;

procedure TCustomTimeRuler.SetCurrentTime(const Value: LongInt);
begin
  if FCurrentTime <> Value then
  begin
    FCurrentTime := Value;
    Change;
    Invalidate;
  end;
end;

procedure TCustomTimeRuler.StartTimer;
begin
  if not Assigned(FTimer) then
  begin
    FTimer := TThreadedTimer.Create(Self);
    FTimer.OnTimer := DoTimer;
    FTimer.Interval := 10;
  end;
  FTimer.Enabled := True;
end;

procedure TCustomTimeRuler.DoTimer(Sender: TObject);
begin
  FTimer.Enabled := False;
  case FBtnDown of
    bdLeftUpper:
      ScrollTime(Sender, -FScrollChangeButtons);
    bdRightUpper:
      ScrollTime(Sender, FScrollChangeButtons);
    bdLeftLower:
      ScrollTime(Sender, -FScrollChangeButtonsMore);
    bdRightLower:
      ScrollTime(Sender, FScrollChangeButtonsMore);
    bdNone:
      begin
        FTimer.Interval := 10;
        Exit;
      end;
  end;
  FTimer.Interval := 10;
  FTimer.Enabled := True;
end;

procedure TCustomTimeRuler.DoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FBtnDown := bdNone;
  StopTimer;
end;

procedure TCustomTimeRuler.StopTimer;
begin
  FTimer.Free;
  FTimer := nil;
end;

procedure TCustomTimeRuler.DoR1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    Exit;

  ScrollTime(Sender, FScrollChangeButtons);

  FBtnDown := bdRightUpper;
  StartTimer;
end;

procedure TCustomTimeRuler.DoR2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    Exit;

  ScrollTime(Sender, FScrollChangeButtonsMore);

  FBtnDown := bdRightLower;
  StartTimer;
end;

procedure TCustomTimeRuler.Paint;
begin
  if not Showing then
    Exit;
  inherited Canvas.Font := Font;
  DrawTimes(inherited Canvas);
end;

function TCustomTimeRuler.FormatTime(Time: Longint): String;
var
  ST: TSystemTime;
begin
  DateTimeToSystemTime(Time/MSTOH, ST);
  if Time < 0 then
    Result := Format(TIMEFORMATNEG, [ST.wHour, ST.wMinute, ST.wSecond, Round(ST.wMilliseconds/10)])
  else
    Result := Format(TIMEFORMAT, [ST.wHour, ST.wMinute, ST.wSecond, Round(ST.wMilliseconds/10)]);
end;

procedure TCustomTimeRuler.DrawTimeLine(var Bmp: TBitmap);
var
  I: Integer;
  S: string;
  R: TRect;
  iTime: Integer;
  Offset: Integer;
begin
  Bmp.Canvas.Brush.Color := FBackground1;
  Bmp.Canvas.Rectangle(0, 0, Bmp.Width, Bmp.Height);
  Bmp.Canvas.Font.Color := FTimelineText;
  for I := -1 to (Width div FTimeWidth) do
  begin
    iTime := Trunc(Self.CurrentTime/2000)*2000+I*2000;
    if iTime = 0 then
    begin
      Bmp.Canvas.Font.Style := [fsBold];
      Offset := 10;
    end
    else
    begin
      Bmp.Canvas.Font.Style := [];
      Offset := 10;
    end;
    S := FormatTime(iTime);

    R := Rect((I+1)* FTimeWidth, Offset, (I+1) * FTimeWidth + FTimeWidth, Font.Size + 4);
    OffsetRect(R, ButtonWidth, 0);

    DrawText(Bmp.Canvas.Handle, PChar(S), Length(S), R, DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX or
      DT_NOCLIP);
    Bmp.Canvas.Pen.Color := FRulerLines;
    Bmp.Canvas.MoveTo((I+1) * FTimeWidth+ButtonWidth, Font.Size + 12);
    Bmp.Canvas.LineTo((I+1) * FTimeWidth+ButtonWidth, Font.Size + 14);
    Bmp.Canvas.MoveTo((I+1) * FTimeWidth + (FTimeWidth div 2)+ButtonWidth, Font.Size + 10);
    Bmp.Canvas.LineTo((I+1) * FTimeWidth + (FTimeWidth div 2)+ButtonWidth, Font.Size + 14);
  end;
end;

procedure TCustomTimeRuler.DrawRows(var Bmp: TBitmap);
begin
  Bmp.Canvas.Pen.Color := FEyedatBorders;

  if Enabled then
    Bmp.Canvas.Brush.Color := FBackground2
  else
    Bmp.Canvas.Brush.Color := FDisabledBackground;

  Bmp.Canvas.Rectangle(0, Font.Size + 14, Bmp.Width, 3 * Font.Size + 15);
  Bmp.Canvas.Pen.Color := FAviBorders;

  if not AviEnabled then
    Bmp.Canvas.Brush.Color := FDisabledBackground;

  Bmp.Canvas.Rectangle(0, 3*Font.Size + 16, Bmp.Width, 6*Font.Size + 9);
end;

procedure TCustomTimeRuler.DrawEyedatLine(var Bmp: TBitmap);
var
  Current, iLeft: integer;
  S: String;
  R: TRect;
begin
  Current := Trunc(Self.CurrentTime/2000)*2000;
  iLeft := Round(FTimeWidth*(3/2)-(Current-FEDTStart)*(FTimeWidth/2000));
  R := Rect(iLeft+ButtonWidth, Font.Size + 14,
    iLeft + Round(FEDTLength * (FTimeWidth/2000)) + ButtonWidth+1, 3*Font.Size + 15);

  Bmp.Canvas.Brush.Color := FEyedatBackground;
  Bmp.Canvas.Rectangle(R);
  Bmp.Canvas.Font.Color := FEyedatText;
  SetBkMode(Bmp.Canvas.Handle, TRANSPARENT);
  S := '  ' + EyedatFilename + TEXT_FROM + FormatTime(FEDTStart) + TEXT_TO + FormatTime(FEDTStart+FEDTLength);
  DrawText(Bmp.Canvas.Handle, PChar(S), Length(S), R, DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
end;

procedure TCustomTimeRuler.DrawAviLine(var Bmp: TBitmap);
var
  Current, iLeft: integer;
  S: String;
begin
  Current := Trunc(Self.CurrentTime/2000)*2000;
  iLeft := Round(FTimeWidth*(3/2)-(Current-FAviStart)*(FTimeWidth/2000));
  FAviRect := Rect(iLeft+ButtonWidth, 3*Font.Size + 16,
    iLeft + Round(FAviLength * (FTimeWidth/2000)) + ButtonWidth+1, 6*Font.Size + 9);

  Bmp.Canvas.Brush.Color := FAviBackground;
  Bmp.Canvas.Rectangle(FAviRect);
  Bmp.Canvas.Font.Color := FAviText;
  SetBkMode(Bmp.Canvas.Handle, TRANSPARENT);
  S := '  ' + AviFilename + TEXT_FROM +FormatTime(FAviStart) + TEXT_TO + FormatTime(FAviStart+FAviLength);


  DrawText(Bmp.Canvas.Handle, PChar(S), Length(S), FAviRect, DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX or
      DT_NOCLIP);
  Bmp.Canvas.Font.Color := clBlack;
  Bmp.Canvas.Brush.Color := clWindow;
end;

procedure TCustomTimeRuler.DrawRangeSelect(var Bmp: TBitmap);
var
  Current, iLeft, Middle: integer;
  RangeRect: TRect;
  TmpBmp: TBitmap;
begin
  Current := Trunc(Self.CurrentTime/2000)*2000;
  iLeft := Round(FTimeWidth*(3/2)-(Current-FRangeStart)*(FTimeWidth/2000));
  FLeftRangeRect := Rect(iLeft+ButtonWidth-3, 0,
    iLeft + 3 {Round(50 * (FTimeWidth/2000))} + ButtonWidth+1, Bmp.Height);
  iLeft := Round(FTimeWidth*(3/2)-(Current-FRangeEnd)*(FTimeWidth/2000));
  FRightRangeRect := Rect(iLeft+ButtonWidth-3, 0,
    iLeft +  3 {Round(50 * (FTimeWidth/2000))} + ButtonWidth+1, Bmp.Height);

  RangeRect := Rect(FLeftRangeRect.Left+3, 0, FRightRangeRect.Left+3, Bmp.Height);

  TmpBmp := TBitmap.Create;
  try
    TmpBmp.Width := FRightRangeRect.Left - FLeftRangeRect.Left ;
    TmpBmp.Height := Bmp.Height;
    TmpBmp.Canvas.Brush.Color := FRangeSelect;
    TmpBmp.Canvas.FillRect(Rect(0, 0, TmpBmp.Width, TmpBmp.Height));

    Bmp.Canvas.CopyMode := cmSrcAnd;
    Bmp.Canvas.CopyRect(RangeRect, TmpBmp.Canvas, Rect(0, 0, TmpBmp.Width, TmpBmp.Height));

  finally
    TmpBmp.free;
  end;

  Bmp.Canvas.Brush.Color := FRangeSelectLeft;
  Bmp.Canvas.Pen.Color := FRangeSelectLeft;

  Middle := FLeftRangeRect.Left + 3;
  Bmp.Canvas.Polygon([Point(Middle, 4),
                   Point(Middle-4, 0),
                   Point(Middle+4, 0)]);
  Bmp.Canvas.MoveTo(Middle,0);
  Bmp.Canvas.LineTo(Middle, Bmp.Height);

  Bmp.Canvas.Brush.Color := FRangeSelectRight;
  Bmp.Canvas.Pen.Color := FRangeSelectRight;

  Middle := FRightRangeRect.Left + 3;
  Bmp.Canvas.Polygon([Point(Middle, 4),
                   Point(Middle-4, 0),
                   Point(Middle+4, 0)]);
  Bmp.Canvas.MoveTo(Middle,0);
  Bmp.Canvas.LineTo(Middle, Bmp.Height);
end;

procedure TCustomTimeRuler.DrawCurrentArrow(var ACanvas: TCanvas);
var
  Spot: integer;
begin
  Spot := (FTimeWidth div 2)+ButtonWidth;
  ACanvas.Pen.Color := FCurrentArrow;
  ACanvas.Brush.Color := FCurrentArrow;
  ACanvas.MoveTo(Spot, 0);
  ACanvas.LineTo(Spot, Height);
  ACanvas.Polygon([Point(Spot, 4),
                   Point(Spot-4, 0),
                   Point(Spot+4, 0)]);

  ACanvas.Polygon([Point(Spot, Height - 9),
                   Point(Spot-4, Height - 5),
                   Point(Spot+4, Height - 5)]);
end;

procedure TCustomTimeRuler.DrawTimes(ACanvas: TCanvas);
var
  Bmp: TBitmap;

begin
  Bmp := TBitmap.Create;
  try
    Bmp.Width := Width+2*FTimeWidth;
    Bmp.Height := Height;
    ACanvas.Font := Font;
    Bmp.Canvas.Font := Font;
    { set buttons }
    FLowerLeftBtn.Top := 23;
    FLowerRightBtn.Top := 23;
    FLowerRightBtn.Left := Width - FButtonWidth - 4;
    FUpperRightBtn.Left := Width - FButtonWidth - 4;
    { draw timeline }
    DrawTimeLine(Bmp);
    { draw rows }
    DrawRows(Bmp);
    if Enabled then
    begin
      { draw eyedat file line }
      DrawEyedatLine(Bmp);
      { draw avi file line }
      if FAviEnabled then
        DrawAviLine(Bmp);
      { draw range select }
      if FShowRange then
        DrawRangeSelect(Bmp);
    end;

    ACanvas.Draw(-round(((Self.CurrentTime mod 2000)+2000)*(FTimeWidth/2000)), 0, Bmp);
    { draw current arrow }
    if FShowCurrentArrow then
      DrawCurrentArrow(ACanvas);
  finally
    Bmp.Free;
  end; {Try..Finally}

  if FScrolling <> sdNotScrolling then
  begin
    if FScrolling = sdRight then
    begin
      ScrollTime(nil, FScrollChangeButtons);
      Invalidate;
      Sleep(5);
    end
    else
    begin
      ScrollTime(nil, -FScrollChangeButtons);
      Invalidate;
      Sleep(5);
    end; {If}
  end;
end;

procedure TCustomTimeRuler.SetButtonWidth(const Value: Integer);
begin
  if FButtonWidth <> Value then
  begin
    FButtonWidth := Value;
    FUpperLeftBtn.Width := FButtonWidth;
    FUpperRightBtn.Width := FButtonWidth;
    FLowerLeftBtn.Width := FButtonWidth;
    FLowerRightBtn.Width := FButtonWidth;
    Invalidate;
  end;
end;

procedure TCustomTimeRuler.SetTimeWidth(const Value: Integer);
begin
  if (FTimeWidth <> Value) and (Value > 0) then
  begin
    FTimeWidth := Value;
    Invalidate;
  end;
end;

procedure TCustomTimeRuler.Change;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure Register;
begin
   RegisterComponents('bonecode', [TTimeRuler]);
end;

end.

