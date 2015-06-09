unit AsciiImage.RenderContext.Factory;

interface

uses
  Graphics,
  AsciiImage.RenderContext.Intf;

type
  TCreateRenderContextHook = reference to function(ACanvas: TCanvas; AWidth, AHeight: Single): IRenderContext;

  TRenderContextFactory = class
  private
    class var FHook: TCreateRenderContextHook;
  public
    class function CreateDefaultRenderContext(ACanvas: TCanvas; AWidth, AHeight: Single): IRenderContext;
    class procedure SetHookCreateDefaultRenderContext(const AHook: TCreateRenderContextHook);
  end;

implementation

uses
  AsciiImage.RenderContext.Types,
  {$if Framework = 'VCL'}
  AsciiImage.RenderContext.GDI;
  {$Else}
  AsciiImage.RenderContext.FM;
  {$IfEnd}

{ TRenderContextFactory }

class function TRenderContextFactory.CreateDefaultRenderContext(
  ACanvas: TCanvas; AWidth, AHeight: Single): IRenderContext;
begin
  if Assigned(FHook) then
  begin
    Result := FHook(ACanvas, AWidth, AHeight);
  end
  else
  begin
    {$if Framework = 'VCL'}
    Result := TGDIRenderContext.Create(ACanvas, AWidth, AHeight);
    {$Else}
    Result := TFMRenderContext.Create(ACanvas);
    {$IfEnd}
  end;
end;

class procedure TRenderContextFactory.SetHookCreateDefaultRenderContext(
  const AHook: TCreateRenderContextHook);
begin
  FHook := AHook;
end;

end.
