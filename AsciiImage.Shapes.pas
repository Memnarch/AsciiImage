unit AsciiImage.Shapes;

interface

uses
  Generics.Collections,
  AsciiImage.RenderContext.Types,
  AsciiImage.RenderContext.Intf;

type
  TAsciiShape = class
  private
    FScaledPoints: TList<TPointF>;
    FPoints: TList<TPointF>;
    FScale: Single;
    procedure SetScale(const Value: Single);
    function GetScaledPoints: TList<TPointF>;
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Draw(const AContext: IRenderContext); virtual; abstract;
    property Points: TList<TPointF> read FPoints;
    property ScaledPoints: TList<TPointF> read GetScaledPoints;
    property Scale: Single read FScale write SetScale;
  end;

implementation

{ TAsciiShape }

constructor TAsciiShape.Create;
begin
  inherited;
  FPoints := TList<TPointF>.Create();
  FScaledPoints := TList<TPointF>.Create();
end;

destructor TAsciiShape.Destroy;
begin
  FPoints.Free;
  FScaledPoints.Free;
end;

function TAsciiShape.GetScaledPoints: TList<TPointF>;
var
  LPoint: TPointF;
begin
  if FScaledPoints.Count = 0 then
  begin
    for LPoint in Points do
    begin
      FScaledPoints.Add(PointF(LPoint.X*Scale, LPoint.Y*Scale));
    end;
  end;
  Result := FScaledPoints;
end;

procedure TAsciiShape.SetScale(const Value: Single);
begin
  FScale := Value;
  FScaledPoints.Clear;
end;

end.
