unit BCControls.ProgressBar;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Graphics, acProgressBar;

type
  TBCProgressBar = class(TsProgressBar)
  private
    FPosition: Integer;
    FCount: Integer;
    FOnStepChange: TNotifyEvent;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    procedure SetCount(Value: Integer);
  public
    procedure StepIt;
    procedure Show;
    procedure Hide;
    property Count: Integer read FCount write SetCount;
  published
    property OnStepChange: TNotifyEvent read FOnStepChange write FOnStepChange;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
  end;

implementation

uses
  Winapi.Windows, System.Types;

procedure TBCProgressBar.StepIt;
begin
  Position := Trunc((FPosition / FCount) * 100);
  Inc(FPosition);
  if Assigned(FOnStepChange) then
    FOnStepChange(nil);
end;

procedure TBCProgressBar.Show;
begin
  Visible := True;
  FPosition := 0;
  if Assigned(FOnShow) then
    FOnShow(nil);
end;

procedure TBCProgressBar.Hide;
begin
  Visible := False;
  if Assigned(FOnHide) then
    FOnHide(nil);
end;

procedure TBCProgressBar.SetCount(Value: Integer);
begin
  FCount := Value;
end;

end.
