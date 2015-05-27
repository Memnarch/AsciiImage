unit AsciiImage.RenderContext.Factory;

interface

uses
  Graphics,
  AsciiImage.RenderContext.Intf;

type
  TRenderContextFactory = class
  public
    class function CreateDefaultRenderContext(ACanvas: TCanvas; AWidth, AHeight: Single): IRenderContext;
  end;

implementation

uses
  AsciiImage.RenderContext.Types,
  {$if Framework = 'VCL'}
  AsciiImage.RenderContext.GDI;
  {$Else}
  AsciiImage.RenderContext.FM;
  {$EndIf}

{ TRenderContextFactory }

class function TRenderContextFactory.CreateDefaultRenderContext(
  ACanvas: TCanvas; AWidth, AHeight: Single): IRenderContext;
begin
  {$if Framework = 'VCL'}
  Result := TGDIRenderContext.Create(ACanvas, AWidth, AHeight);
  {$Else}
  Result := TFMRenderContext.Create(ACanvas);
  {$EndIf}
end;

end.
