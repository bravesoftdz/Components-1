unit BCControls.ToolBar;

interface

uses
  System.Classes, Vcl.ToolWin, Vcl.ComCtrls;

type
  TBCToolBar = class(TToolBar)
  private
    { Private declarations }
    procedure DrawButton(Sender: TToolBar; Button: TToolButton;
      State: TCustomDrawState; var DefaultDraw: Boolean);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('bonecode', [TBCToolBar]);
end;

procedure TBCToolBar.DrawButton(Sender: TToolBar; Button: TToolButton;
  State: TCustomDrawState; var DefaultDraw: Boolean);
var
  X, Y: Integer;
begin
  { the following is done to get the disabled images drawn }
  if Button.Enabled or not Sender.Flat then
    Exit;
  if not Assigned(Images) then
    Exit;
  DefaultDraw := False;
  X := Button.Left + Button.Width div 2 - Sender.Images.Width div 2;
  Y := Button.Top + Button.Height div 2 - Sender.Images.Height div 2;
  Sender.Images.Draw(Sender.Canvas, X, Y, Button.ImageIndex, False);
end;

constructor TBCToolBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { Note! Overriding CustomDrawButton won't work! }
  OnCustomDrawButton := DrawButton;
end;

end.
