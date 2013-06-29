unit Cards;

interface

{$RESOURCE 'CARD.RES'}

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs;

const
  DEFAULT_CARD_WIDTH          = 73;
  DEFAULT_CARD_HEIGHT         = 97;

type

  TCardValue =
    (Ace, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King);
  TCardSuit = (Clubs, Diamonds, Hearts, Spades);

  TCard = class(TGraphicControl)
  private
    { Private declarations }
  protected
    { Protected declarations }
    FCardValue: TCardValue;
    FCardSuit: TCardSuit;
    FShowCard: Boolean;
    FSelectedCard: Boolean;
    FCardMask: TBitmap;
    FCardWork: TBitmap;
    FMoving: Boolean;

    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetCardValue(CardValue: TCardValue);
    procedure SetShowCard(CardShowValue: Boolean);
    procedure SetCardSuit(CardSuitValue: TCardSuit);
    procedure SetSelectedCard(CardSelectedValue: Boolean);
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  published
    { Published declarations }
    property Moving : Boolean read FMoving write FMoving;
    property CardMask : TBitmap read Fcardmask write fcardmask;
    property CardWork : TBitmap read Fcardwork write fcardwork;
    property Card: TCardValue read FCardValue write SetCardValue;
    property SelectedCard: Boolean read FSelectedCard write SetSelectedCard;
    property ShowCard: Boolean read FShowCard write SetShowCard;
    property Suit: TCardSuit read FCardSuit write SetCardSuit;
    property DragMode;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseMove;
    property OnMouseDown;
    property OnMouseUp;
  end;

procedure Register;

var
  CardInstanceCount: LongInt = 0;
  CardSet: TBitmap;
  CardBack: TBitmap;
  CardMask: TBitmap;
  CardWork: TBitmap;

implementation

constructor TCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCardValue := Ace;
  if (CardInstanceCount < 1) then
    begin
    CardMask := TBitmap.Create;
    with CardMask do
    begin
      Monochrome := True;
      LoadFromResourceName(HInstance, 'CARDMASK');
    end;

    CardWork := TBitmap.Create;
    with CardWork do
    begin
      Width := DEFAULT_CARD_WIDTH;
      Height := DEFAULT_CARD_HEIGHT;
    end;

    CardSet := TBitmap.Create;
    CardSet.LoadFromResourceName(HInstance, 'CARDSET');
    CardBack := TBitmap.Create;
    CardBack.LoadFromResourceName(HInstance, 'CARDBACK');
    end;
  Inc(CardInstanceCount);

  FCardMask := TBitmap.Create;
  with FCardMask do
  begin
    Monochrome := True;
    LoadFromResourceName(HInstance, 'CARDMASK');
  end;

  FCardWork := TBitmap.Create;
  with FCardWork do
  begin
    Width := DEFAULT_CARD_WIDTH;
    Height := DEFAULT_CARD_HEIGHT;
  end;
  Moving := false;
end;

destructor TCard.Destroy;
begin
  Dec(CardInstanceCount);
  if (CardInstanceCount < 1) then
    begin
    CardSet.Free;
    CardMask.Free;
    CardBack.Free;
    CardWork.Free;
    end;
  inherited Destroy;
end;

procedure TCard.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited
  SetBounds(ALeft, ATop, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT);
end;

procedure TCard.Paint;
var
  CardPaintMode: Integer;
begin
  BitBlt(FCardWork.Canvas.Handle,  0, 0, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT,
        CardSet.Canvas.Handle, (LongInt(FCardValue) * DEFAULT_CARD_WIDTH),
        (LongInt(FCardSuit) * DEFAULT_CARD_HEIGHT), SRCCOPY);

  BitBlt(CardWork.Canvas.Handle, 0, 0, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT,
      Canvas.Handle, 0, 0, SRCCOPY);

  if (FSelectedCard = False) then
    begin
    CardPaintMode := SRCPAINT;
    BitBlt(CardWork.Canvas.Handle, 0, 0, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT,
    CardMask.Canvas.Handle, 0, 0, SRCAND);
    end
  else
    begin
    CardPaintMode := NOTSRCERASE;
    BitBlt(CardWork.Canvas.Handle, 0, 0, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT,
      CardMask.Canvas.Handle, 0, 0, SRCERASE);
    end;
  case FShowCard of
    True:
      BitBlt(CardWork.Canvas.Handle, 0, 0, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT,
        CardSet.Canvas.Handle, (LongInt(FCardValue) * DEFAULT_CARD_WIDTH),
        (LongInt(FCardSuit) * DEFAULT_CARD_HEIGHT), CardPaintMode);
    False:
      BitBlt(CardWork.Canvas.Handle, 0, 0, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT,
        CardBack.Canvas.Handle, 0, 0, CardPaintMode);
  end;

  BitBlt(Canvas.Handle, 0, 0, DEFAULT_CARD_WIDTH, DEFAULT_CARD_HEIGHT,
    CardWork.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TCard.SetCardValue(CardValue: TCardValue);
begin
  FCardValue := CardValue;
  case FShowCard of
    True:
      Repaint;
    False:;
  end;
end;

procedure TCard.SetSelectedCard(CardSelectedValue: Boolean);
begin
  if (FSelectedCard <> CardSelectedValue) then
    begin
    FSelectedCard := CardSelectedValue;
    Repaint;
    end;
end;

procedure TCard.SetShowCard(CardShowValue: Boolean);
begin
  if (FShowCard <> CardShowValue) then
    begin
    FShowCard := CardShowValue;
    Repaint;
    end;
end;

procedure TCard.SetCardSuit(CardSuitValue: TCardSuit);
begin
  FCardSuit := CardSuitValue;
  case FShowCard of
    True:
      Repaint;
    False:;
  end;
end;

procedure Register;
begin
  RegisterComponents('bonecode', [TCard]);
end;

end.
