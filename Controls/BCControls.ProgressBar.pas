unit BCControls.ProgressBar;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Graphics, JvExComCtrls, JvProgressBar;

type
  TProgressBarStyleHookMarquee = class(TProgressBarStyleHook)
  private
    FTimer: TTimer;
    FStep: Integer;
    procedure TimerAction(Sender: TObject);
  protected
    procedure PaintBar(Canvas: TCanvas); override;
  public
    constructor Create(AControl: TWinControl); override;
    destructor Destroy; override;
  end;

  TBCProgressBar = class(TJvProgressBar)
  private
    { Private declarations }
    FPosition: Integer;
    FCount: Integer;
  public
    { Public declarations }
    class constructor Create;
    class destructor Destroy;
    procedure Init(Count: Integer);
    procedure StepIt;
    procedure Show;
    procedure Hide;
  published
    { Published declarations }
  end;

procedure Register;

implementation

uses
  Winapi.Windows, System.Types, Vcl.Themes;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCProgressBar]);
end;

{ TProgressBarStyleHookMarquee }

constructor TProgressBarStyleHookMarquee.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  FStep := 0;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 100;
  FTimer.OnTimer := TimerAction;
  FTimer.Enabled := TJvProgressBar(Control).Marquee;
end;

destructor TProgressBarStyleHookMarquee.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TProgressBarStyleHookMarquee.PaintBar(Canvas: TCanvas);
var
  FillR, R: TRect;
  W, Pos: Integer;
  Details: TThemedElementDetails;
begin
  if (TJvProgressBar(Control).Marquee) and StyleServices.Available  then
  begin
    R := BarRect;
    InflateRect(R, -1, -1);
    if Orientation = pbHorizontal then
      W := R.Width
    else
      W := R.Height;

    Pos := Round(W * 0.1);
    FillR := R;
    if Orientation = pbHorizontal then
    begin
      FillR.Right := FillR.Left + Pos;
      Details := StyleServices.GetElementDetails(tpChunk);
    end
    else
    begin
      FillR.Top := FillR.Bottom - Pos;
      Details := StyleServices.GetElementDetails(tpChunkVert);
    end;

    FillR.SetLocation(FStep*FillR.Width, FillR.Top);
    StyleServices.DrawElement(Canvas.Handle, Details, FillR);
    Inc(FStep, 1);
    if FStep mod 10=0 then
      FStep := 0;
  end
  else
  inherited;
end;

procedure TProgressBarStyleHookMarquee.TimerAction(Sender: TObject);
var
  Canvas: TCanvas;
begin
  if StyleServices.Available and (TJvProgressBar(Control).Marquee) and Control.Visible  then
  begin
    Canvas := TCanvas.Create;
    try
      Canvas.Handle := GetWindowDC(Control.Handle);
      PaintFrame(Canvas);
      PaintBar(Canvas);
    finally
      ReleaseDC(Handle, Canvas.Handle);
      Canvas.Handle := 0;
      Canvas.Free;
    end;
  end
  else
    FTimer.Enabled := False;
end;

{ TBCProgressBar }

class constructor TBCProgressBar.Create;
begin
  TStyleManager.Engine.RegisterStyleHook(TBCProgressBar, TProgressBarStyleHookMarquee);
end;

class destructor TBCProgressBar.Destroy;
begin
  TStyleManager.Engine.UnRegisterStyleHook(TBCProgressBar, TProgressBarStyleHookMarquee);
end;

procedure TBCProgressBar.Init(Count: Integer);
begin
  FPosition := 0;
  FCount := Count;
end;

procedure TBCProgressBar.StepIt;
begin
  Position := Trunc((FPosition / FCount) * 100);
  Inc(FPosition);
end;

procedure TBCProgressBar.Show;
begin
  Visible := True;
end;

procedure TBCProgressBar.Hide;
begin
  Visible := False;
end;

end.
