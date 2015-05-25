unit AsciiImage.RenderContext.Types;

interface

uses
  Graphics,
  {$if CompilerVersion > 22}
  System.Types,
  System.UITypes;
  {$Else}
  Types;
  {$EndIf}

{$If declared(TGraphic)}
  const Framework = 'VCL';
{$Else}
  const Framework = 'FM';
  const clNone = TAlphaColorRec.Null;
  const clBlack = TAlphaColorRec.Black;
{$ENDIF}

type
  {$If Framework = 'VCL'}
  TColorValue = TColor;
  {$Else}
  TColorValue = TAlphaColor;
  {$EndIf}


{$if declared(System.Types.TPointF)}
  TPointF = System.Types.TPointF;
{$Else}
  TPointF = record
    X: Single;
    Y: Single;
  end;
{$EndIf}

{$if declared(System.Types.TRectF)}
  TRectF = System.Types.TRectF;
{$Else}
  TRectF = record
    Left, Top, Right, Bottom: Single;
  end;
{$EndIf}


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
