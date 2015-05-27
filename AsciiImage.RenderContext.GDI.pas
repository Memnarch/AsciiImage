unit AsciiImage.RenderContext.GDI;

interface

uses
  Types,
  Windows,
  Graphics,
  AsciiImage.RenderContext,
  AsciiImage.RenderContext.Types;

type
  TDownSampling = (dsNone, dsX2, dsX4, dsX8);

  TGDIRenderContext = class(TRenderContext)
  private
    FTargetCanvas: TCanvas;
    FCanvas: TCanvas;
    FWidth: Single;
    FHeight: Single;
    FScale: Integer;
    FDownSampling: TDownSampling;
    FTemp: TBitmap;
    FTargetRect: TRect;
    procedure SetDownSampling(const Value: TDownSampling);
    class var FDefaultDownSampling: TDownSampling;
  protected
    procedure BrushChanged; override;
    procedure PenChanged; override;
    function GetDownSamplingScale(): Integer;
  public
    class constructor Create();
    class procedure SetDefaultDownSampling(const ADownSampling: TDownSampling);
    class function GetDefaultDownSampling: TDownSampling;
    constructor Create(ACanvas: TCanvas; AWidth, AHeight: Single);
    destructor Destroy(); override;
    procedure Clear(AColor: TColorValue); override;
    procedure DrawEllipsis(const ARect: TRectF); override;
    procedure DrawLine(const AFrom: TPointF; const ATo: TPointF); override;
    procedure DrawPolygon(const APoints: array of TPointF); override;
    procedure FillRectangle(const ARect: TRectF); override;
    procedure BeginScene(const ARect: TRect); override;
    procedure EndScene(); override;
    property DownSampling: TDownSampling read FDownSampling write SetDownSampling;
  end;

implementation

uses
  Math;

{ TGDIRenderContext }

procedure TGDIRenderContext.BeginScene;
begin
  inherited;
  FScale := GetDownSamplingScale();
  FTemp.SetSize(Round(FWidth*FScale), Round(FHeight*FScale));
  FTargetRect := ARect;
end;

procedure TGDIRenderContext.BrushChanged;
begin
  inherited;
  FCanvas.Brush.Color := Brush.Color;
  if Brush.Visible then
    FCanvas.Brush.Style := bsSolid
  else
    FCanvas.Brush.Style := bsClear;
end;

procedure TGDIRenderContext.Clear(AColor: TColorValue);
begin
  FCanvas.Brush.Color := AColor;
  FCanvas.FillRect(FCanvas.ClipRect);
  FCanvas.Brush.Color := Brush.Color;
end;

class constructor TGDIRenderContext.Create;
begin
  FDefaultDownSampling := dsX8;
end;

constructor TGDIRenderContext.Create(ACanvas: TCanvas; AWidth, AHeight: Single);
begin
  inherited Create();
  FTargetCanvas := ACanvas;
  FTemp := TBitmap.Create();
  FCanvas := FTemp.Canvas;
  FWidth := AWidth;
  FHeight := AHeight;
  FDownSampling := FDefaultDownSampling;
  BrushChanged();
  PenChanged();
end;

destructor TGDIRenderContext.Destroy;
begin
  FTemp.Free;
  inherited;
end;

procedure TGDIRenderContext.DrawEllipsis(const ARect: TRectF);
begin
  FCanvas.Ellipse(Trunc(ARect.Left*FScale), Trunc(ARect.Top*FScale), Round(ARect.Right*FScale), Round(ARect.Bottom*FScale));
end;

procedure TGDIRenderContext.DrawLine(const AFrom, ATo: TPointF);
begin
  //draw forward and backwards, otherwhise when drawing in low resolutions, first pixel might not be colored
  FCanvas.MoveTo(Trunc(AFrom.X*FScale), Trunc(AFrom.Y*FScale));
  FCanvas.LineTo(Trunc(ATo.X*FScale), Trunc(ATo.Y*FScale));
  FCanvas.LineTo(Trunc(AFrom.X*FScale), Trunc(AFrom.Y*FScale));
end;

procedure TGDIRenderContext.DrawPolygon(const APoints: array of TPointF);
var
  LPoints: array of TPoint;
  i: Integer;
begin
  SetLength(LPoints, Length(APoints));
  for i := 0 to Length(APoints) - 1 do
  begin
    LPoints[i] := Point(Trunc(APoints[i].X*FScale), Trunc(APoints[i].Y*FScale));
  end;
  FCanvas.Polygon(LPoints);
end;

procedure TGDIRenderContext.EndScene;
var
  LOldMode: Cardinal;
begin
  inherited;
  LOldMode := GetStretchBltMode(FTargetCanvas.Handle);
  SetStretchBltMode(FTargetCanvas.Handle, HALFTONE);
  StretchBlt(FTargetCanvas.Handle, FTargetRect.Left, FTargetRect.Top, FTargetRect.Right - FTargetRect.Left, FTargetRect.Bottom - FTargetRect.Top,
    FTemp.Canvas.Handle, 0, 0, FTemp.Width, FTemp.Height, SRCCOPY);
  SetStretchBltMode(FTargetCanvas.Handle, LOldMode);
end;

procedure TGDIRenderContext.FillRectangle(const ARect: TRectF);
var
  LRect: TRect;
begin
  LRect := Rect(Trunc(ARect.Left*FScale), Trunc(ARect.Top*FScale), Round(ARect.Right*FScale), Round(ARect.Bottom*FSCale));
  FCanvas.FillRect(LRect);
end;

class function TGDIRenderContext.GetDefaultDownSampling: TDownSampling;
begin
  Result := FDefaultDownSampling;
end;

function TGDIRenderContext.GetDownSamplingScale: Integer;
begin
  case FDownSampling of
    dsX2: Result := 2;
    dsX4: Result := 4;
    dsX8: Result := 8;
  else
    Result := 1;
  end;
end;

procedure TGDIRenderContext.PenChanged;
begin
  inherited;
  FCanvas.Pen.Color := Pen.Color;
  FCanvas.Pen.Width := Pen.Size * GetDownSamplingScale();
  if Pen.Visible then
    FCanvas.Pen.Style := psSolid
  else
    FCanvas.Pen.Style := psClear;
end;

class procedure TGDIRenderContext.SetDefaultDownSampling(
  const ADownSampling: TDownSampling);
begin
  FDefaultDownSampling := ADownSampling;
end;

procedure TGDIRenderContext.SetDownSampling(const Value: TDownSampling);
begin
  if FDownSampling <> Value then
  begin
    FDownSampling := Value;
    PenChanged();
  end;
end;

end.
