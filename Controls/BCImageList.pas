unit BCImageList;

interface

uses
  Windows, SysUtils, Classes, ImgList, Controls, Graphics, CommCtrl;

type
  TBCImageList = class(TImageList)
  private
    FDisabledBitmap: TBitmap;
    procedure GetDisabledImage(Bitmap: TBitmap; const MaskBitmap: TBitmap; const Index: Integer);
  protected
    { Protected declarations }
    procedure DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
      Style: Cardinal; Enabled: Boolean = True); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure Register;

implementation

uses
  Math;

procedure Register;
begin
  RegisterComponents('bonecode', [TBCImageList]);
end;

constructor TBCImageList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDisabledBitmap := TBitmap.Create;
end;

destructor TBCImageList.Destroy;
begin
  FDisabledBitmap.Free;
  inherited Destroy;
end;

procedure TBCImageList.GetDisabledImage(Bitmap: TBitmap; const MaskBitmap: TBitmap; const Index: Integer);
var
  i, j: Integer;
  Grayshade: Integer;
  Red, Green, Blue: Byte;
  PixelColor: Longint;
begin
  if FDisabledBitmap.Canvas.Pixels[0, Index] = clFuchsia then
    BitBlt(Bitmap.Canvas.Handle, 0, 0, Bitmap.Width, Bitmap.Height, FDisabledBitmap.Canvas.Handle, 1, Index * Bitmap.Width, SRCCOPY)
  else
  with Bitmap do
  begin
    for i := 0 to Width - 1 do
      for j := 0 to Height - 1 do
      begin
        if MaskBitmap.Canvas.Pixels[i,j] = clBlack then
        begin
          PixelColor := ColorToRGB(Canvas.Pixels[i, j]);
          Red := PixelColor;
          Green := PixelColor shr 8;
          Blue := PixelColor shr 16;
          Grayshade := (Red + Green + Blue) div 3;
          Inc(Grayshade, 38); { some contrast }
          if Grayshade > 255 then
            Grayshade := 255
          else
          if Grayshade < 0 then
            Grayshade := 0;
          Canvas.Pixels[i, j] := RGB(Grayshade, Grayshade, Grayshade);
        end;
      end;
    FDisabledBitmap.SetSize(Width + 1, Height * Count);
    FDisabledBitmap.Canvas.Pixels[0, Index] := clFuchsia; { mark it done and copy for later use }
    BitBlt(FDisabledBitmap.Canvas.Handle, 1, Index * Bitmap.Width, Bitmap.Width, Bitmap.Height, Bitmap.Canvas.Handle, 0, 0, SRCCOPY)
  end;
end;

procedure TBCImageList.DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
  Style: Cardinal; Enabled: Boolean);
var
  MaskBitMap : TBitmap;
  DisabledBitMap : TBitmap;
begin
  if Enabled then
    inherited DoDraw(Index, Canvas, X, Y, Style, Enabled)
  else
  if HandleAllocated then
  begin
    DisabledBitMap := TBitmap.Create;
    MaskBitMap := TBitmap.Create;
    try
      DisabledBitMap.SetSize(Width, Height);
      MaskBitMap.SetSize(Width, Height);
      GetImages(Index, DisabledBitMap, MaskBitMap); { get images from the imagelist }
      GetDisabledImage(DisabledBitMap, MaskBitMap, Index);
      BitBlt(Canvas.Handle, X, Y, Width, Height, MaskBitMap.Canvas.Handle, 0, 0, SRCERASE);
      BitBlt(Canvas.Handle, X, Y, Width, Height, DisabledBitMap.Canvas.Handle, 0, 0, SRCINVERT);
    finally
      DisabledBitMap.Free;
      MaskBitMap.Free;
    end;
  end;
end;

end.

