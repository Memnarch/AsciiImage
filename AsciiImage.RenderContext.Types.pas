unit AsciiImage.RenderContext.Types;

interface

type
  TPointF = record
    X: Single;
    Y: Single;
  end;

  TRectF = record
    Left, Top, Right, Bottom: Single;
  end;


function PointF(AX, AY: Single): TPointF; inline;
function RectF(ALeft, ATop, ARight, ABottom: Single): TRectF; inline;

implementation

function PointF(AX, AY: Single): TPointF;
begin
  Result.X := AX;
  Result.Y := AY;
end;

function RectF(ALeft, ATop, ARight, ABottom: Single): TRectF;
begin
  Result.Left := ALeft;
  Result.Top := ATop;
  Result.Right := ARight;
  Result.Bottom := ABottom;
end;

end.
