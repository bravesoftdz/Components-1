unit BCControls.LayoutController;

interface

uses
  System.Classes, System.Types, Vcl.Controls, Generics.Collections, Generics.Defaults;

type
  TBCLayoutDirection = (ltHorizontal, ltVertical);

  TBCLayoutController = class(TPersistent)
  private
    FParent: TWinControl;
    FActive: Boolean;
    FLayoutDirection: TBCLayoutDirection;
    FControlSpacing: Integer;
    FTopMargin: Integer;
    FLeftMargin: Integer;
    procedure SetLayoutDirection(const Value: TBCLayoutDirection);
    procedure SetLeftMargin(const Value: Integer);
    procedure SetTopMargin(const Value: Integer);
    procedure SetActive(const Value: Boolean);
  public
    constructor Create(AParent: TWinControl; AControlSpacing: Integer = 5); overload;
    procedure AlignControls;
  published
    property Active: boolean read FActive write SetActive;
    property ControlSpacing : Integer read FControlSpacing write FControlSpacing;
    property LayoutDirection: TBCLayoutDirection read FLayoutDirection write SetLayoutDirection;
    property LeftMargin: Integer read FLeftMargin write SetLeftMargin;
    property TopMargin: Integer read FTopMargin write SetTopMargin;
  end;

implementation

uses
  System.Math;

{ TBCLayoutController }

function CompareControls(Item1, Item2: TControl; LayoutDirection: TBCLayoutDirection): Integer;
var
  LItem1Value, LItem2Value: Integer;
begin
  case LayoutDirection of
    ltHorizontal:
      begin
        LItem1Value := Item1.Left;
        LItem2Value := Item2.Left;
      end;
    ltVertical:
      begin
        LItem1Value := Item1.Top;
        LItem2Value := Item2.Top;
      end
    else
    begin
      LItem1Value := 0;
      LItem2Value := 0;
    end
  end;

  Result := CompareValue(LItem1Value, LItem2Value);
end;


procedure TBCLayoutController.AlignControls;
var
  i: Integer;
  LPosition: Integer;
  LMaxDimension: Integer;
  LControlArray: TObjectList<TControl>;
begin
  if not Active then
    Exit;

  LMaxDimension := 0;
  LPosition := 0;

  case FLayoutDirection of
    ltHorizontal:
      LPosition := FLeftMargin;
    ltVertical:
      LPosition := FTopMargin;
  end;

  LControlArray := TObjectList<TControl>.Create;
  LControlArray.OwnsObjects := False;
  for i := 0 to FParent.ControlCount-1 do
  begin
    if not (csDesigning in FParent.ComponentState) and not FParent.Controls[i].Visible then
      Continue;
    LMaxDimension := Max(LMaxDimension, FParent.Controls[i].Height);
    LControlArray.Add(FParent.Controls[i]);
  end;

  LControlArray.Sort(
     TComparer<TControl>.Construct(
     function (const A, B: TControl): integer
     begin
       result := CompareControls(A, B, FLayoutDirection);
     end
    )
  );

  for i := 0 to LControlArray.Count - 1 do
  begin
    case FLayoutDirection of
      ltHorizontal:
        begin
          LControlArray[i].Top := FTopMargin + LMaxDimension - LControlArray[i].Height;
          LControlArray[i].Left := LPosition;
          LPosition := LPosition + LControlArray[i].Width + FControlSpacing;
        end;
      ltVertical:
        begin
          LControlArray[i].Top := LPosition;
          LControlArray[i].Left := FLeftMargin;
          LPosition := LPosition + LControlArray[i].Height + FControlSpacing;
        end;
    end;
  end;

  LControlArray.Free;
end;

constructor TBCLayoutController.Create(AParent: TWinControl; AControlSpacing: Integer);
begin
  inherited Create;
  FParent := AParent;
  FActive := True;
  FControlSpacing := AControlSpacing;
  FLayoutDirection := ltVertical;
  FLeftMargin := 5;
  FTopMargin := 5;
end;


procedure TBCLayoutController.SetActive(const Value: boolean);
begin
  FActive := Value;
end;

procedure TBCLayoutController.SetLayoutDirection(const Value: TBCLayoutDirection);
begin
  if FLayoutDirection <> Value then
  begin
    FLayoutDirection := Value;
    AlignControls;
  end;
end;

procedure TBCLayoutController.SetLeftMargin(const Value: Integer);
begin
  if FLeftMargin <> Value then
  begin
    FLeftMargin := Value;
    AlignControls;
  end;
end;

procedure TBCLayoutController.SetTopMargin(const Value: Integer);
begin
  if FTopMargin <> Value then
  begin
    FTopMargin := Value;
    AlignControls;
  end;
end;

end.
