unit BCControls.StyleHooks;

interface

uses
  Winapi.Messages, Vcl.Controls, Vcl.StdCtrls;

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

implementation

uses
  Winapi.Windows, Vcl.Themes, Vcl.Graphics, System.UITypes;

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

end.
