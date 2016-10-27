unit BCControl.ProgressBar;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls, Vcl.Graphics, sGauge;

type
  TBCProgressBar = class(TsGauge)
  private
    FRefCount: Integer;
    FPosition: Integer;
    FCount: Integer;
    FOnStepChange: TNotifyEvent;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
  public
    constructor Create(AOwner: TComponent); override;
    procedure StepIt;
    procedure Show(ACount: Integer);
    procedure Hide;
    property Count: Integer read FCount write FCount;
  published
    property OnStepChange: TNotifyEvent read FOnStepChange write FOnStepChange;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
  end;

implementation

uses
  Winapi.Windows, System.Types, System.Math;

constructor TBCProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRefCount := 0;
end;

procedure TBCProgressBar.StepIt;
begin
  Progress := Trunc((FPosition / FCount) * 100);
  Inc(FPosition);
  if Assigned(FOnStepChange) then
    FOnStepChange(nil);
end;

procedure TBCProgressBar.Show(ACount: Integer);
begin
  if not Visible then
  begin
    FCount := Max(ACount, 1);
    Visible := True;
    FPosition := 0;
    Progress := 0;
    if Assigned(FOnShow) then
      FOnShow(nil);
  end
  else
    Inc(FRefCount);
end;

procedure TBCProgressBar.Hide;
begin
  if FRefCount = 0 then
  begin
    Visible := False;
    if Assigned(FOnHide) then
      FOnHide(nil);
  end
  else
    Dec(FRefCount);
end;

end.
