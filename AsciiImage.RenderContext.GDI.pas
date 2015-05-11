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
end;

destructor TGDIRenderContext.Destroy;
begin
  FCanvas.Free;
  inherited;
end;

procedure TGDIRenderContext.DrawEllipsis(const ARect: TRectF);
begin
  FCanvas.Ellipse(Round(ARect.Left), Round(ARect.Top), Round(ARect.Right), Round(ARect.Bottom));
end;

procedure TGDIRenderContext.DrawLine(const AFrom, ATo: TPointF);
begin
  FCanvas.MoveTo(Round(AFrom.X), Round(AFrom.Y));
  FCanvas.LineTo(Round(ATo.X), Round(ATo.Y));
end;

procedure TGDIRenderContext.DrawPolygon(const APoints: array of TPointF);
var
  LPoints: array of TPoint;
  i: Integer;
begin
  SetLength(LPoints, Length(APoints));
  for i := 0 to Length(APoints) - 1 do
  begin
    LPoints[i] := Point(Round(APoints[i].X), Round(APoints[i].Y));
  end;
  FCanvas.Polygon(LPoints);
end;

procedure TGDIRenderContext.FillRectangle(const ARect: TRectF);
begin
  FCanvas.FillRect(Rect(Round(ARect.Left), Round(ARect.Top), Round(ARect.Right), Round(ARect.Bottom)));
end;

procedure TGDIRenderContext.PenChanged;
begin
  inherited;
  FCanvas.Pen.Color := Pen.Color;
  FCanvas.Pen.Width := Pen.Size;
end;

end.
