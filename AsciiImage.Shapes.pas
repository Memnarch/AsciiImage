unit AsciiImage.Shapes;

interface

uses
  {$if CompilerVersion > 22}
  System.Types,
  {$EndIf}
  Generics.Collections,
  AsciiImage.RenderContext.Types,
  AsciiImage.RenderContext.Intf;

type
  TAsciiShape = class
  private
    FScaledPoints: TList<TPointF>;
    FPoints: TList<TPointF>;
    FScaleX: Single;
    FScaleY: Single;
    procedure SetScaleX(const Value: Single);
    function GetScaledPoints: TList<TPointF>;
    procedure SetScaleY(const Value: Single);
  public
    constructor Create();
    destructor Destroy(); override;
    procedure Draw(const AContext: IRenderContext); virtual; abstract;
    property Points: TList<TPointF> read FPoints;
    property ScaledPoints: TList<TPointF> read GetScaledPoints;
    property ScaleX: Single read FScaleX write SetScaleX;
    property ScaleY: Single read FScaleY write SetScaleY;
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
      FScaledPoints.Add(PointF(LPoint.X*ScaleX + ScaleX/2, LPoint.Y*ScaleY + ScaleY / 2));
    end;
  end;
  Result := FScaledPoints;
end;

procedure TAsciiShape.SetScaleX(const Value: Single);
begin
  FScaleX := Value;
  FScaledPoints.Clear;
end;

procedure TAsciiShape.SetScaleY(const Value: Single);
begin
  if FScaleY <> Value then
  begin
    FScaleY := Value;
    FScaledPoints.Clear;
  end;
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
  LRect.Left := LPoint.X - ScaleX / 2;
  LRect.Top := LPoint.Y - ScaleY / 2;
  LRect.Right := LPoint.X + ScaleX / 2;
  LRect.Bottom := LPoint.Y + ScaleY / 2;
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
