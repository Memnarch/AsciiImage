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

  TAsciiEllipsis = class(TAsciiShape)
  protected
    function GetRect(): TRectF;
  public
    procedure Draw(const AContext: IRenderContext); override;
  end;

  TAsciiPath = class(TAsciiShape)
  public
    procedure Draw(const AContext: IRenderContext); override;
  end;

  TAsciiDot = class(TAsciiShape)
  public
    procedure Draw(const AContext: IRenderContext); override;
  end;

  TAsciiLine = class(TAsciiShape)
  public
    procedure Draw(const AContext: IRenderContext); override;
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
      FScaledPoints.Add(PointF(LPoint.X*Scale + Scale/2, LPoint.Y*Scale + Scale / 2));
    end;
  end;
  Result := FScaledPoints;
end;

procedure TAsciiShape.SetScale(const Value: Single);
begin
  FScale := Value;
  FScaledPoints.Clear;
end;

{ TAsciiLine }

procedure TAsciiLine.Draw(const AContext: IRenderContext);
begin
  AContext.DrawLine(ScaledPoints[0], ScaledPoints[1]);
end;

{ TAsciiDot }

procedure TAsciiDot.Draw(const AContext: IRenderContext);
var
  LPoint: TPointF;
  LRect: TRectF;
begin
  LPoint := ScaledPoints[0];
  LRect.Left := LPoint.X - Scale / 2;
  LRect.Top := LPoint.Y - Scale / 2;
  LRect.Right := LPoint.X + Scale / 2;
  LRect.Bottom := LPoint.Y + Scale / 2;
  AContext.FillRectangle(LRect);
end;

{ TAsciiPath }

procedure TAsciiPath.Draw(const AContext: IRenderContext);
begin
  AContext.DrawPolygon(ScaledPoints.ToArray);
end;

{ TAsciiEllipsis }

procedure TAsciiEllipsis.Draw(const AContext: IRenderContext);
begin
  AContext.DrawEllipsis(GetRect());
end;

function TAsciiEllipsis.GetRect: TRectF;
var
  LPoint: TPointF;
const
  CHighSingle = 10000;
  CLowSingle = -10000;
begin
  Result.Left := CHighSingle;
  Result.Top := CHighSingle;
  Result.Right := CLowSingle;
  Result.Bottom := CLowSingle;
  for LPoint in ScaledPoints do
  begin
    if LPoint.X < Result.Left then
      Result.Left := LPoint.X;

    if LPoint.X > Result.Right then
      Result.Right := LPoint.X;

    if LPoint.Y < Result.Top then
      Result.Top := LPoint.Y;

    if LPoint.Y > Result.Bottom then
      Result.Bottom := LPoint.Y;
  end;
end;

end.
