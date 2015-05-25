unit AsciiImage.RenderContext.FM;

interface

uses
  FMX.Graphics,
  AsciiImage.RenderContext.Types,
  AsciiImage.RenderContext;

type
  TFMRenderContext = class(TRenderContext)
  private
    FCanvas: TCanvas;
  protected
    procedure BrushChanged; override;
    procedure PenChanged; override;
  public
    constructor Create(ACanvas: TCanvas);
    procedure Clear(AColor: TColorValue); override;
    procedure DrawEllipsis(const ARect: TRectF); override;
    procedure DrawLine(const AFrom: TPointF; const ATo: TPointF); override;
    procedure DrawPolygon(const APoints: array of TPointF); override;
    procedure FillRectangle(const ARect: TRectF); override;
    procedure BeginScene(); override;
    procedure EndScene(); override;
  end;

implementation

uses
  System.Math.Vectors;

{ TFMRenderContext }

procedure TFMRenderContext.BeginScene;
begin
  inherited;
  FCanvas.BeginScene();
end;

procedure TFMRenderContext.BrushChanged;
begin
  inherited;
  FCanvas.Fill.Color := Brush.Color;
  if Brush.Visible then
    FCanvas.Fill.Kind := TBrushKind.Solid
  else
    FCanvas.Fill.Kind := TbrushKind.None;
end;

procedure TFMRenderContext.Clear(AColor: TColorValue);
begin
  inherited;
  FCanvas.Clear(AColor);
end;

constructor TFMRenderContext.Create(ACanvas: TCanvas);
begin
  inherited Create();
  FCanvas := ACanvas;
end;

procedure TFMRenderContext.DrawEllipsis(const ARect: TRectF);
begin
  inherited;
  FCanvas.FillEllipse(ARect, 1);
  FCanvas.DrawEllipse(ARect, 1);
end;

procedure TFMRenderContext.DrawLine(const AFrom, ATo: TPointF);
begin
  inherited;
  FCanvas.DrawLine(AFrom, ATo, 1);
end;

procedure TFMRenderContext.DrawPolygon(const APoints: array of TPointF);
var
  LPolygon: TPolygon;
  i: Integer;
begin
  inherited;
  SetLength(LPolygon, Length(APoints) + 1);
  for i := 0 to Length(APoints) - 1 do
  begin
    LPolygon[i] := APoints[i];
  end;
  LPolygon[High(LPolygon)] := LPolygon[0];
  FCanvas.FillPolygon(LPolygon, 1);
  FCanvas.DrawPolygon(LPolygon, 1);
end;

procedure TFMRenderContext.EndScene;
begin
  inherited;
  FCanvas.EndScene();
end;

procedure TFMRenderContext.FillRectangle(const ARect: TRectF);
begin
  inherited;
  FCanvas.FillRect(ARect, 1, 1, [], 1);
end;

procedure TFMRenderContext.PenChanged;
begin
  inherited;
  FCanvas.Stroke.Color := Pen.Color;
  FCanvas.Stroke.Thickness := Pen.Size;
  if Pen.Visible then
    FCanvas.Stroke.Kind := TBrushKind.Solid
  else
    FCanvas.Stroke.Kind := TBrushKind.None;
end;

end.
