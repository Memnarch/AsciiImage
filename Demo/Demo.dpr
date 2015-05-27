program Demo;

uses
  Forms,
  Main in 'Main.pas' {Form1},
  AsciiImage in '..\AsciiImage.pas',
  AsciiImage.Shapes in '..\AsciiImage.Shapes.pas',
  AsciiImage.RenderContext in '..\AsciiImage.RenderContext.pas',
  AsciiImage.RenderContext.Intf in '..\AsciiImage.RenderContext.Intf.pas',
  AsciiImage.RenderContext.Types in '..\AsciiImage.RenderContext.Types.pas',
  AsciiImage.RenderContext.GDI in '..\AsciiImage.RenderContext.GDI.pas',
  AsciiImage.RenderContext.Factory in '..\AsciiImage.RenderContext.Factory.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
