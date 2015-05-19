unit AsciiImage.RenderContext.GDI;

interface

uses
  Types,
  Windows,
  Graphics,
  AsciiImage.RenderContext,
  AsciiImage.RenderContext.Types;

type
  TGDIRenderContext = class(TRenderContext)
  private
    FCanvas: TCanvas;
  protected
    procedure BrushChanged; override;
    procedure PenChanged; override;
  public
    constructor Create(ADeviceContext: HDC);
    destructor Destroy(); override;
    procedure Clear(AColor: TColor); override;
    procedure DrawEllipsis(const ARect: TRectF); override;
    procedure DrawLine(const AFrom: TPointF; const ATo: TPointF); override;
    procedure DrawPolygon(const APoints: array of TPointF); override;
    procedure FillRectangle(const ARect: TRectF); override;
  end;

implementation

uses
  Math;

{ TGDIRenderContext }

procedure TGDIRenderContext.BrushChanged;
begin
  inherited;
  FCanvas.Brush.Color := Brush.Color;
end;

procedure TGDIRenderContext.Clear(AColor: TColor);
begin
  FCanvas.Brush.Color := AColor;
  FCanvas.FillRect(FCanvas.ClipRect);
  FCanvas.Brush.Color := Brush.Color;
end;

constructor TGDIRenderContext.Create(ADeviceContext: HDC);
begin
  inherited Create();
  FCanvas := TCanvas.Create();
  FCanvas.Handle := ADeviceContext;
  BrushChanged();
  PenChanged();
end;

destructor TGDIRenderContext.Destroy;
begin
  FCanvas.Free;
  inherited;
end;

procedure TGDIRenderContext.DrawEllipsis(const ARect: TRectF);
begin
  FCanvas.Ellipse(Trunc(ARect.Left), Trunc(ARect.Top), Round(ARect.Right), Round(ARect.Bottom));
end;

procedure TGDIRenderContext.DrawLine(const AFrom, ATo: TPointF);
begin
  //draw forward and backwards, otherwhise when drawing in low resolutions, first pixel might not be colored
  FCanvas.MoveTo(Trunc(AFrom.X), Trunc(AFrom.Y));
  FCanvas.LineTo(Trunc(ATo.X), Trunc(ATo.Y));
  FCanvas.LineTo(Trunc(AFrom.X), Trunc(AFrom.Y));
end;

procedure TGDIRenderContext.DrawPolygon(const APoints: array of TPointF);
var
  LPoints: array of TPoint;
  i: Integer;
  LStyle: TPenStyle;
begin
  SetLength(LPoints, Length(APoints));
  for i := 0 to Length(APoints) - 1 do
  begin
    LPoints[i] := Point(Round(APoints[i].X), Round(APoints[i].Y));
  end;
  LStyle := FCanvas.Pen.Style;
  FCanvas.Pen.Style := psClear;
  FCanvas.Polygon(LPoints);
  FCanvas.Pen.Style := LStyle;
  //draw outline manually, for better precision
  for i := 1 to Length(APoints) - 1 do
    DrawLine(APoints[i-1], APoints[i]);

  DrawLine(APoints[Length(APoints)-1], APoints[0]);
end;

procedure TGDIRenderContext.FillRectangle(const ARect: TRectF);
var
  LRect: TRect;
begin
  LRect := Rect(Trunc(ARect.Left), Trunc(ARect.Top), Round(ARect.Right), Round(ARect.Bottom));
  FCanvas.FillRect(LRect);
end;

procedure TGDIRenderContext.PenChanged;
begin
  inherited;
  FCanvas.Pen.Color := Pen.Color;
  FCanvas.Pen.Width := Pen.Size;
end;

end.
